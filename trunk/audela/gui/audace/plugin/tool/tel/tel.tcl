#
# Fichier : tel.tcl
# Description : Outil pour le controle des montures
# Compatibilite : Montures LX200, AudeCom, etc.
# Auteurs : Alain KLOTZ, Robert DELMAS et Philippe KAUFFMANN
# Mise a jour $Id: tel.tcl,v 1.4 2006-06-20 21:30:12 robertdelmas Exp $
#

package provide tel 1.0

namespace eval ::Tlscp {
   variable This
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool tel tel.cap ]

   proc init { { in "" } } {
      createPanel $in.tlscp
   }

   proc createPanel { this } {
      variable This
      global panneau
      global caption
      global catalogue

      set This $this
      #---
      set panneau(menu_name,Tlscp)   "$caption(tel,telescope)"
      set panneau(Tlscp,aide)        "$caption(tel,help_titre)"
      set panneau(Tlscp,coordonnees) "$caption(tel,coord)"
      set panneau(Tlscp,match)       "$caption(tel,match)"
      set panneau(Tlscp,goto)        "$caption(tel,goto)"
      set panneau(Tlscp,stopgoto)    "$caption(tel,stop_goto)"
      set panneau(Tlscp,exptime)     "2"
      set panneau(Tlscp,secondes)    "$caption(tel,seconde)"
      set panneau(Tlscp,bin)         "$caption(tel,binning)"
      set panneau(Tlscp,go)          "$caption(tel,goccd)"
      set panneau(Tlscp,choix_bin)   "1x1 2x2 4x4"
      set panneau(Tlscp,binning)     "2x2"
      set panneau(Tlscp,menu)        "$caption(tel,coord)"
      set panneau(Tlscp,cata_coord)  "$caption(tel,coord) $caption(tel,planete) $caption(tel,asteroide) \
         $caption(tel,etoile) $caption(tel,messier) $caption(tel,ngc) $caption(tel,ic) $caption(tel,utilisateur) \
         $caption(tel,zenith)"

      #--- Coordonnees J2000.0 de M104
      set panneau(Tlscp,getobj)      "12h40m0 -11d37m22"
      TlscpBuildIF $This
   }

   proc Adapt_Panneau_Tel { { a "" } { b "" } { c "" } } {
      variable This
      global conf
      global panneau
      global caption

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

   proc startTool { visuNo } {
      variable This

      trace add variable ::conf(telescope) write ::Tlscp::Adapt_Panneau_Tel
      trace add variable ::confTel(conf_temma,modele) write ::Tlscp::Adapt_Panneau_Tel
      pack $This -side left -fill y
      ::Tlscp::Adapt_Panneau_Tel
      #--- Je refraichis l'affichage des coordonnees
      ::telescope::afficheCoord

   }

   proc stopTool { visuNo } {
      variable This

      trace remove variable ::conf(telescope) write ::Tlscp::Adapt_Panneau_Tel
      trace remove variable ::confTel(conf_temma,modele) write ::Tlscp::Adapt_Panneau_Tel
      pack forget $This
   }

   proc cmdMatch { } {
      variable This
      global conf
      global audace
      global panneau
      global caption

      $This.fra2.fra1a.match configure -relief groove -state disabled
      update
      ::telescope::match $panneau(Tlscp,getobj)
      $This.fra2.fra1a.match configure -relief raised -state normal
      update
   }

   proc cmdGoto { } {
      variable This
      global audace
      global caption
      global panneau
      global catalogue
      global cataGoto

      #--- Gestion graphique des boutons GOTO et Stop
      $This.fra2.fra2a.but1 configure -relief groove -state disabled
      $This.fra2.fra2a.but2 configure -text $panneau(Tlscp,stopgoto) -font $audace(font,arial_8_b) \
         -command { ::Tlscp::cmdStopGoto }
      update

      #--- Affichage de champ dans une carte. Parametres : nom_objet, ad, dec, zoom_objet, avant_plan
      if { $cataGoto(carte,validation) == "1" } {
         ::carte::gotoObject $cataGoto(carte,nom_objet) $cataGoto(carte,ad) $cataGoto(carte,dec) $cataGoto(carte,zoom_objet) $cataGoto(carte,avant_plan)
      }

      #--- Cas particulier si le premier pointage est en mode coordonnees
      if { $panneau(Tlscp,menu) == "$caption(tel,coord)" } {
         set panneau(Tlscp,list_radec) $panneau(Tlscp,getobj)
      }

      #--- Prise en compte des corrections de precession, de nutation et d'aberrations (annuelle et diurne)
      if { $panneau(Tlscp,menu) != "$caption(tel,coord)" && $panneau(Tlscp,menu) != "$caption(tel,planete)" \
         && $panneau(Tlscp,menu) != "$caption(tel,asteroide)" && $panneau(Tlscp,menu) != "$caption(tel,zenith)" } {
         #--- Initialisation du temps
         set now now
         catch {
            set now [::audace::date_sys2ut now]
         }
         #--- Calcul des corrections et affichage dans la Console
         set ad_objet_cata  [ lindex $panneau(Tlscp,list_radec) 0 ]
         set dec_objet_cata [ lindex $panneau(Tlscp,list_radec) 1 ]
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
         set panneau(Tlscp,list_radec) "$ad_objet_vrai $dec_objet_vrai"
      }

      #--- Goto
      ::telescope::goto $panneau(Tlscp,list_radec) "0" $This.fra2.fra2a.but1 $This.fra2.fra1a.match

      #--- Affichage des coordonnees pointees par le telescope dans la Console
      if { $panneau(Tlscp,menu) != "$caption(tel,coord)" && $panneau(Tlscp,menu) != "$caption(tel,planete)" \
         && $panneau(Tlscp,menu) != "$caption(tel,asteroide)" && $panneau(Tlscp,menu) != "$caption(tel,zenith)" } {
         ::telescope::afficheCoord
         ::console::disp "$caption(tel,coord_pointees) \n"
         ::console::disp "$caption(tel,ad) $audace(telescope,getra) \n"
         ::console::disp "$caption(tel,dec) $audace(telescope,getdec) \n"
         ::console::disp "\n"
      }

      #--- Gestion graphique du bouton Stop
      $This.fra2.fra2a.but2 configure -relief raised -state normal -text $panneau(Tlscp,coordonnees) \
         -font $audace(font,arial_8_b) -command { ::telescope::afficheCoord }
      update

   }

   proc Gestion_Cata { { type_objets "" } } {
      variable This
      global conf
      global audace
      global panneau
      global caption
      global catalogue

      #--- Force le type d'objets
      catch { set panneau(Tlscp,menu) "$type_objets" }

      #--- Gestion des catalogues
      if { $panneau(Tlscp,menu) == "$caption(tel,coord)" } {
         ::cataGoto::Nettoyage
         set panneau(Tlscp,list_radec) $panneau(Tlscp,getobj)
      } elseif { $panneau(Tlscp,menu) == "$caption(tel,planete)" } {
         ::cataGoto::GotoPlanete
         vwait catalogue(validation)
         if { $catalogue(validation) == "1" } {
            set panneau(Tlscp,list_radec) "$catalogue(planete_ad) $catalogue(planete_dec)"
         } else {
            set panneau(Tlscp,list_radec) $panneau(Tlscp,getobj)
         }
         set panneau(Tlscp,getobj) $panneau(Tlscp,list_radec)
         $This.fra2.ent1 configure -textvariable panneau(Tlscp,getobj)
         update
      } elseif { $panneau(Tlscp,menu) == "$caption(tel,asteroide)" } {
         ::cataGoto::CataAsteroide
         vwait catalogue(validation)
         if { $catalogue(validation) == "1" } {
            set panneau(Tlscp,list_radec) "$catalogue(asteroide_ad) $catalogue(asteroide_dec)"
         } else {
            set panneau(Tlscp,list_radec) $panneau(Tlscp,getobj)
         }
         set panneau(Tlscp,getobj) $panneau(Tlscp,list_radec)
         $This.fra2.ent1 configure -textvariable panneau(Tlscp,getobj) 
         update
      } elseif { $panneau(Tlscp,menu) == "$caption(tel,etoile)" } {
         ::cataGoto::CataEtoiles
         vwait catalogue(validation)
         if { $catalogue(validation) == "1" } {    
            set panneau(Tlscp,list_radec) "$catalogue(etoile_ad) $catalogue(etoile_dec)"
         } else {
            set panneau(Tlscp,list_radec) $panneau(Tlscp,getobj)
         }
         set panneau(Tlscp,getobj) $panneau(Tlscp,list_radec)
         $This.fra2.ent1 configure -textvariable panneau(Tlscp,getobj) 
         update
      } elseif { $panneau(Tlscp,menu) == "$caption(tel,messier)" } {
         ::cataGoto::CataObjet $panneau(Tlscp,menu)
         vwait catalogue(validation)
         if { $catalogue(validation) == "1" } {    
            set panneau(Tlscp,list_radec) "$catalogue(objet_ad) $catalogue(objet_dec)"
         } else {
            set panneau(Tlscp,list_radec) $panneau(Tlscp,getobj)
         }
         set panneau(Tlscp,getobj) $panneau(Tlscp,list_radec)
         $This.fra2.ent1 configure -textvariable panneau(Tlscp,getobj) 
         update
      } elseif { $panneau(Tlscp,menu) == "$caption(tel,ngc)" } {
         ::cataGoto::CataObjet $panneau(Tlscp,menu)
         vwait catalogue(validation)
         if { $catalogue(validation) == "1" } {    
            set panneau(Tlscp,list_radec) "$catalogue(objet_ad) $catalogue(objet_dec)"
         } else {
            set panneau(Tlscp,list_radec) $panneau(Tlscp,getobj)
         }
         set panneau(Tlscp,getobj) $panneau(Tlscp,list_radec)
         $This.fra2.ent1 configure -textvariable panneau(Tlscp,getobj) 
         update
      } elseif { $panneau(Tlscp,menu) == "$caption(tel,ic)" } {
         ::cataGoto::CataObjet $panneau(Tlscp,menu)
         vwait catalogue(validation)
         if { $catalogue(validation) == "1" } {    
            set panneau(Tlscp,list_radec) "$catalogue(objet_ad) $catalogue(objet_dec)"
         } else {
            set panneau(Tlscp,list_radec) $panneau(Tlscp,getobj)
         }
         set panneau(Tlscp,getobj) $panneau(Tlscp,list_radec)
         $This.fra2.ent1 configure -textvariable panneau(Tlscp,getobj)
         update
      } elseif { $panneau(Tlscp,menu) == "$caption(tel,utilisateur)"  } {
         if { $catalogue(autre_catalogue) == "2" } {
            ::cataGoto::CataObjetUtilisateur_Choix
         } else {
            ::cataGoto::CataObjetUtilisateur
         }
         if { $catalogue(utilisateur) != "" } {
            vwait catalogue(validation)
            if { $catalogue(validation) == "1" } {    
               set panneau(Tlscp,list_radec) "$catalogue(objet_utilisateur_ad) $catalogue(objet_utilisateur_dec)"
            } else {
               set panneau(Tlscp,list_radec) $panneau(Tlscp,getobj)
            }
            set panneau(Tlscp,getobj) $panneau(Tlscp,list_radec)
            $This.fra2.ent1 configure -textvariable panneau(Tlscp,getobj) 
            update
         } else {
            set catalogue(validation) "2"
         }
      } else {
         ::cataGoto::Nettoyage
         set lat_zenith [ mc_angle2dms [ lindex $conf(posobs,observateur,gps) 3 ] 90 nozero 0 auto string ]
         set panneau(Tlscp,list_radec) "$audace(tsl,format,zenith) $lat_zenith"
         set panneau(Tlscp,getobj) $panneau(Tlscp,list_radec)
         $This.fra2.ent1 configure -textvariable panneau(Tlscp,getobj) 
         update
      }
      if { $catalogue(validation) == "1" } {
         ::Tlscp::Gestion_Cata $panneau(Tlscp,menu)
      }
   }

   proc PlusLong { } {
      global conf
      global audace
      global caption

      if { $conf(audecom,gotopluslong) == "0" } {
         catch { tel$audace(telNo) slewpath short }
         destroy $audace(base).pluslong
      } else {
         catch { tel$audace(telNo) slewpath long }
         if [ winfo exists $audace(base).pluslong ] {
            destroy $audace(base).pluslong
         }
         toplevel $audace(base).pluslong
         wm transient $audace(base).pluslong $audace(base)
         wm resizable $audace(base).pluslong 0 0
         wm title $audace(base).pluslong "$caption(tel,attention)"
         set posx_pluslong [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
         set posy_pluslong [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
         wm geometry $audace(base).pluslong +[ expr $posx_pluslong + 120 ]+[ expr $posy_pluslong + 105 ]

         #--- Cree l'affichage du message
         label $audace(base).pluslong.lab1 -text "$caption(tel,pluslong1)"
         pack $audace(base).pluslong.lab1 -padx 10 -pady 2
         label $audace(base).pluslong.lab2 -text "$caption(tel,pluslong2)"
         pack $audace(base).pluslong.lab2 -padx 10 -pady 2
         label $audace(base).pluslong.lab3 -text "$caption(tel,pluslong3)"
         pack $audace(base).pluslong.lab3 -padx 10 -pady 2

         #--- La nouvelle fenetre est active
         focus $audace(base).pluslong

         #--- Mise a jour dynamique des couleurs
         ::confColor::applyColor $audace(base).pluslong
      }
   }

   proc cmdStopGoto { } {
      variable This
      global conf

      $This.fra2.fra2a.but2 configure -relief groove -state disabled
      update
      ::telescope::stopGoto $This.fra2.fra2a.but2
   }

   proc cmdInitTel { } {
      variable This

      $This.fra2.but3 configure -relief groove -state disabled
      update
      ::telescope::initTel $This.fra2.but3 
   }

   proc FormatADDec { } {
      global audace
      global caption

      if [ winfo exists $audace(base).formataddec ] {
         destroy $audace(base).formataddec
      }

      toplevel $audace(base).formataddec
      wm transient $audace(base).formataddec $audace(base)
      wm title $audace(base).formataddec "$caption(tel,attention)"
      set posx_formataddec [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
      set posy_formataddec [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
      wm geometry $audace(base).formataddec +[ expr $posx_formataddec + 120 ]+[ expr $posy_formataddec + 105 ]
      wm resizable $audace(base).formataddec 0 0

      #--- Cree l'affichage du message
      label $audace(base).formataddec.lab1 -text "$caption(tel,formataddec1)"
      pack $audace(base).formataddec.lab1 -padx 10 -pady 2
      label $audace(base).formataddec.lab2 -text "$caption(tel,formataddec2)"
      pack $audace(base).formataddec.lab2 -padx 10 -pady 2
      label $audace(base).formataddec.lab3 -text "$caption(tel,formataddec3)"
      pack $audace(base).formataddec.lab3 -padx 10 -pady 2
      label $audace(base).formataddec.lab4 -text "$caption(tel,formataddec4)"
      pack $audace(base).formataddec.lab4 -padx 10 -pady 2
      label $audace(base).formataddec.lab5 -text "$caption(tel,formataddec5)"
      pack $audace(base).formataddec.lab5 -padx 10 -pady 2

      #--- La nouvelle fenetre est active
      focus $audace(base).formataddec

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).formataddec
   }

   proc cmdCtlSuivi { {value " "} } {
      ::telescope::controleSuivi $value
   }

   proc cmdMove { direction } {
      ::telescope::move $direction
   }

   proc cmdStop { direction } {
      ::telescope::stop $direction
   }

   proc cmdSpeed { } {
      ::telescope::incrementSpeed
   }

   proc cmdGo { } {
      variable This
      global audace
      global panneau
      global caption

      #--- Verifie que le temps de pose est bien un réel positif
      if { [ ::Tlscp::TestReel $panneau(Tlscp,exptime) ] == "0" } {
         tk_messageBox -title $caption(tel,probleme) -type ok -message $caption(tel,entier_positif)
         return
      }

      #---
      if { [ ::cam::list ] != "" } {
         #--- Gestion graphiue du bouton
         $This.fra6.but1 configure -relief groove -state disabled
         update

         #--- 
         if { ( $audace(telescope,getra) == "$caption(tel,camera)" ) && \
               ( $audace(telescope,getdec) == "$caption(tel,non_connectee)" ) } {
            ::telescope::afficheCoord
         }
 
         #--- Temps de pose
         set exptime $panneau(Tlscp,exptime)

         #--- Facteur de binning
         set bin 4
         if { $panneau(Tlscp,binning) == "4x4" } { set bin "4" }
         if { $panneau(Tlscp,binning) == "2x2" } { set bin "2" }
         if { $panneau(Tlscp,binning) == "1x1" } { set bin "1" }

         #--- Initialisation du fenetrage
         catch {
            set n1n2 [ cam$audace(camNo) nbcells ]
            cam$audace(camNo) window [ list 1 1 [ lindex $n1n2 0 ] [ lindex $n1n2 1 ] ]
         }

         #--- Appel a la fonction d'acquisition
         ::Tlscp::acq $exptime $bin

         #--- Gestion du graphisme du panneau
         $This.fra6.but1 configure -relief raised -state normal
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

   proc acq { exptime binning } {
      variable This
      global conf
      global audace
      global caption

      #--- Petits raccourcis
      set camera cam$audace(camNo)
      set buffer buf$audace(bufNo)

      #--- La commande exptime permet de fixer le temps de pose de l'image
      $camera exptime $exptime

      #--- La commande bin permet de fixer le binning.
      $camera bin [ list $binning $binning ]

      #--- Cas des poses de 0 s : Force l'affichage de l'avancement de la pose avec le statut Lecture du CCD
      if { $exptime == "0" } {
         ::camera::Avancement_pose "1"
      }

      #--- Declenchement de l'acquisition
      $camera acq

      #--- Alarme sonore de fin de pose
      ::camera::alarme_sonore $exptime

      #--- Gestion de la pose : Timer, avancement, attente fin, retournement image, fin anticipee
      ::camera::gestionPose $exptime 1 $camera $buffer

      #--- Visualisation de l'image
      ::audace::autovisu $audace(visuNo)
   }

   proc TestReel { valeur } {
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
}

proc TlscpBuildIF { This } {
   global conf
   global audace
   global panneau
   global caption

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(menu_name,Tlscp) \
            -command {
               ::audace::showHelpPlugin tool tel tel.htm
            }
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(Tlscp,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame du pointage
      frame $This.fra2 -borderwidth 1 -relief groove

         ComboBox $This.fra2.optionmenu1 \
            -width 12         \
            -height [ llength $panneau(Tlscp,cata_coord) ]  \
            -relief sunken    \
            -borderwidth 1    \
            -editable 0       \
            -textvariable panneau(Tlscp,menu) \
            -modifycmd { ::Tlscp::Gestion_Cata $panneau(Tlscp,menu) } \
            -values $panneau(Tlscp,cata_coord)
         pack $This.fra2.optionmenu1 -in $This.fra2 -anchor center -padx 2 -pady 2

         #--- Bind (clic droit) pour ouvrir la fenetre sans avoir a selectionner dans la listbox
         bind $This.fra2.optionmenu1.e <ButtonPress-3> { ::Tlscp::Gestion_Cata $panneau(Tlscp,menu) }

         #--- Entry pour l'objet a entrer
         entry $This.fra2.ent1 -font $audace(font,arial_8_b) -textvariable panneau(Tlscp,getobj) \
            -relief groove -width 16
         pack $This.fra2.ent1 -in $This.fra2 -anchor center -padx 2 -pady 2

         bind $This.fra2.ent1 <Enter> { ::Tlscp::FormatADDec }
         bind $This.fra2.ent1 <Leave> { destroy $audace(base).formataddec }

         frame $This.fra2.fra1a

            #--- Checkbutton chemin le plus long
            checkbutton $This.fra2.fra1a.check1 -highlightthickness 0 -variable conf(audecom,gotopluslong) \
               -command { ::Tlscp::PlusLong }
            pack $This.fra2.fra1a.check1 -in $This.fra2.fra1a -side left -fill both -anchor center -pady 1

            #--- Bouton MATCH
            button $This.fra2.fra1a.match -borderwidth 2 -text $panneau(Tlscp,match) -command { ::Tlscp::cmdMatch }
            pack $This.fra2.fra1a.match -in $This.fra2.fra1a -side right -expand 1 -fill both -anchor center -pady 1

         pack $This.fra2.fra1a -in $This.fra2 -expand 1 -fill both

         frame $This.fra2.fra2a

            #--- Bouton Coord. / Stop GOTO
            button $This.fra2.fra2a.but2 -borderwidth 2 -text $panneau(Tlscp,coordonnees) \
               -font $audace(font,arial_8_b) -command { ::telescope::afficheCoord }
            pack $This.fra2.fra2a.but2 -in $This.fra2.fra2a -side left -fill both -anchor center -pady 1

            #--- Bouton GOTO
            button $This.fra2.fra2a.but1 -borderwidth 2 -text $panneau(Tlscp,goto) -command { ::Tlscp::cmdGoto }
            pack $This.fra2.fra2a.but1 -in $This.fra2.fra2a -side right -expand 1 -fill both -anchor center -pady 1

            #--- Bouton Stop GOTO
            button $This.fra2.fra2a.but3 -borderwidth 2 -text $panneau(Tlscp,stopgoto) -font $audace(font,arial_10_b) \
               -command { ::telescope::stopGoto }
            pack $This.fra2.fra2a.but3 -in $This.fra2.fra2a -side left -fill y -anchor center -pady 1

         pack $This.fra2.fra2a -in $This.fra2 -expand 1 -fill both

         #--- Bouton Initialisation Telescope
         button $This.fra2.but3 -borderwidth 2 -textvariable audace(telescope,inittel) -command { ::Tlscp::cmdInitTel }
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

      bind $This.fra4.we.lab <ButtonPress-1> { ::Tlscp::cmdSpeed }
      bind $This.fra4.s.lab1 <ButtonPress-1> { ::Tlscp::cmdCtlSuivi }

      #--- Cardinal moves
      bind $zone(e) <ButtonPress-1> { ::Tlscp::cmdMove e }
      bind $zone(e) <ButtonRelease-1> { ::Tlscp::cmdStop e }
      bind $zone(w) <ButtonPress-1> { ::Tlscp::cmdMove w }
      bind $zone(w) <ButtonRelease-1> { ::Tlscp::cmdStop w }
      bind $zone(s) <ButtonPress-1> { ::Tlscp::cmdMove s  }
      bind $zone(s) <ButtonRelease-1> { ::Tlscp::cmdStop s }
      bind $zone(n) <ButtonPress-1> { ::Tlscp::cmdMove n }
      bind $zone(n) <ButtonRelease-1> { ::Tlscp::cmdStop n }

      #--- Frame de l'image
      frame $This.fra6 -borderwidth 1 -relief groove

         #--- Frame invisible pour le temps de pose
         frame $This.fra6.fra1

            #--- Entry pour l'objet a entrer
            entry $This.fra6.fra1.ent1 -font $audace(font,arial_8_b) -textvariable panneau(Tlscp,exptime) \
               -relief groove -width 5 -justify center
            pack $This.fra6.fra1.ent1 -in $This.fra6.fra1 -side left -fill none -padx 4 -pady 2

            label $This.fra6.fra1.lab1 -text $panneau(Tlscp,secondes) -relief flat  
            pack $This.fra6.fra1.lab1 -in $This.fra6.fra1 -side left -fill none -padx 1 -pady 1

         pack $This.fra6.fra1 -in $This.fra6 -side top -fill x

         #--- Menu pour binning
         frame $This.fra6.optionmenu1 -borderwidth 0 -relief groove
            menubutton $This.fra6.optionmenu1.but_bin -text $panneau(Tlscp,bin) \
               -menu $This.fra6.optionmenu1.but_bin.menu -relief raised
            pack $This.fra6.optionmenu1.but_bin -in $This.fra6.optionmenu1 -side left -fill none
            set m [ menu $This.fra6.optionmenu1.but_bin.menu -tearoff 0 ]
            foreach valbin $panneau(Tlscp,choix_bin) {
               $m add radiobutton -label "$valbin" \
                  -indicatoron "1" \
                  -value "$valbin" \
                  -variable panneau(Tlscp,binning) \
                  -command { }
            }
            entry $This.fra6.optionmenu1.lab_bin -width 3 -font {arial 10 bold}  -relief groove \
              -textvariable panneau(Tlscp,binning) -justify center -state disabled
            pack $This.fra6.optionmenu1.lab_bin -in $This.fra6.optionmenu1 -side left -fill both -expand true
         pack $This.fra6.optionmenu1 -anchor n -fill x -expand 0 -pady 2

         #--- Bouton GO
         button $This.fra6.but1 -borderwidth 2 -text $panneau(Tlscp,go) -command { ::Tlscp::cmdGo }
         pack $This.fra6.but1 -in $This.fra6 -fill none -anchor center -pady 1 -ipadx 17

      pack $This.fra6 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

global audace

::Tlscp::init $audace(base)

