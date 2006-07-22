#
# Fichier : scan.tcl
# Description : Outil pour l'acquisition en mode scan
# Compatibilite : Montures LX200, AudeCom et Ouranos avec camera Audine
# Auteur : Alain KLOTZ
# Mise a jour $Id: scan.tcl,v 1.4 2006-07-22 23:22:42 denismarchais Exp $
#

package provide scan 1.0

namespace eval ::Dscan {
   variable This
   variable parametres
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool scan scan.cap ]

   proc init { { in "" } } {
      createPanel $in.dscan
   }

   proc createPanel { this } {
      variable This
      global panneau
      global caption

      set This $this
      #---
      set panneau(Dscan,choix_bin)   "1x1 2x2 4x4"
      set panneau(Dscan,binning)     "2x2"
      set panneau(menu_name,Dscan)   "$caption(scan,drift_scan)"
      set panneau(Dscan,aide)        "$caption(scan,help_titre)"
      set panneau(Dscan,col)         "$caption(scan,colonnes)"
      set panneau(Dscan,lig)         "$caption(scan,lignes)"
      set panneau(Dscan,pixel)       "$caption(scan,pixel)"
      set panneau(Dscan,unite)       "$caption(scan,micron)"
      set panneau(Dscan,interlig)    "$caption(scan,interligne)"
      set panneau(Dscan,bin)         "$caption(scan,binning)"
      set panneau(Dscan,focale)      "$caption(scan,focale)"
      set panneau(Dscan,metres)      "$caption(scan,metre)"
      set panneau(Dscan,declinaison) "$caption(scan,declinaison)"
      set panneau(Dscan,calcul)      "$caption(scan,calcul)"
      set panneau(Dscan,ms)          "$caption(scan,milliseconde)"
      set panneau(Dscan,acq)         "$caption(scan,acquisition)"
      set panneau(Dscan,go0)         "$caption(scan,goccd)"
      set panneau(Dscan,stop)        "$caption(scan,stop)"
      set panneau(Dscan,go1)         "$caption(scan,en_cours)"
      set panneau(Dscan,go2)         "$caption(scan,visu)"
      set panneau(Dscan,go)          "$panneau(Dscan,go0)"
      set panneau(Dscan,stop1)       "0"
      set panneau(Dscan,acquisition) "0"
      DscanBuildIF $This
   }

   proc Chargement_Var { } {
      variable parametres
      global audace

      #--- Ouverture du fichier de parametres
      set fichier [ file join $audace(rep_plugin) tool scan scan.ini ]
      if { [ file exists $fichier ] } {
         source $fichier
      }
      if { ! [ info exists parametres(Dscan,col1) ] }    { set parametres(Dscan,col1)    "1" }
      if { ! [ info exists parametres(Dscan,col2) ] }    { set parametres(Dscan,col2)    "768" }
      if { ! [ info exists parametres(Dscan,lig1) ] }    { set parametres(Dscan,lig1)    "1500" }
      if { ! [ info exists parametres(Dscan,dimpix) ] }  { set parametres(Dscan,dimpix)  "9" }
      if { ! [ info exists parametres(Dscan,binning) ] } { set parametres(Dscan,binning) "2x2" }
      if { ! [ info exists parametres(Dscan,foc) ] }     { set parametres(Dscan,foc)     ".85" }
      if { ! [ info exists parametres(Dscan,dec) ] }     { set parametres(Dscan,dec)     "0d" }
   }

   proc Enregistrement_Var { } {
      variable parametres
      global audace
      global panneau

      set parametres(Dscan,col1)    $panneau(Dscan,col1)
      set parametres(Dscan,col2)    $panneau(Dscan,col2)
      set parametres(Dscan,lig1)    $panneau(Dscan,lig1)
      set parametres(Dscan,dimpix)  $panneau(Dscan,pix)
      set parametres(Dscan,binning) $panneau(Dscan,binning)
      set parametres(Dscan,foc)     $panneau(Dscan,foc)
      set parametres(Dscan,dec)     $panneau(Dscan,dec)

      #--- Sauvegarde des parametres
      catch {
         set nom_fichier [ file join $audace(rep_plugin) tool scan scan.ini ]
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
      global audace

      ::Dscan::Chargement_Var
      pack $This -side left -fill y
   }

   proc stopTool { visuNo } {
      variable This

      ::Dscan::Enregistrement_Var
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
         #--- Initialisation des variables
         set panneau(Dscan,acquisition) "1"
         set panneau(Dscan,stop1)       "0"

         #--- Gestion graphique du bouton GO CCD
         $This.fra4.but1 configure -relief groove -text $panneau(Dscan,go1) -state disabled
         #--- Gestion graphique du bouton STOP - Inactif avant le debut du scan
         $This.fra4.but2 configure -relief groove -text $panneau(Dscan,stop) -state disabled
         update

         #--- Definition des parametres du scan
         set bin 4
         if { $panneau(Dscan,binning) == "4x4" } { set bin 4 }
         if { $panneau(Dscan,binning) == "2x2" } { set bin 2 }
         if { $panneau(Dscan,binning) == "1x1" } { set bin 1 }
         set w [ ::Dscan::int [ expr ($panneau(Dscan,col2)-$panneau(Dscan,col1)+1) ] ]
         set h [ ::Dscan::int $panneau(Dscan,lig1) ]
         set o [ ::Dscan::int [ expr ($panneau(Dscan,col1)-1) ] ]

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

         #--- Attente du demarrage du scan
         if { $conf(tempo_scan,active) == "1" } {
            #--- Decompte du temps d'attente
            set attente $conf(tempo_scan,delai)
            if { $conf(tempo_scan,delai) > "0" } {
               while { $conf(tempo_scan,delai) > "0" } {
                  ::camera::Avancement_scan "-10" $panneau(Dscan,lig1)
                  update
                  after 1000	
                  incr conf(tempo_scan,delai) "-1"
               }
            }
            set conf(tempo_scan,delai) $attente
         }

         #--- Gestion graphique du bouton STOP - Devient actif avec le debut du scan
         $This.fra4.but2 configure -relief raised -text $panneau(Dscan,stop) -state normal
         update

         #--- Changement de variable
         set dt $panneau(Dscan,interlig1)

         #--- Appel a la fonction d'acquisition
         ::Dscan::scan $w $h $bin $dt $o

         #--- Graphisme du panneau
         $This.fra4.but1 configure -relief groove -text $panneau(Dscan,go2) -state disabled
         update

         #--- Visualisation de l'image
         ::audace::autovisu $audace(visuNo)

         #--- Gestion du moteur d'A.D.
         if { $motor == "motoroff" } {
            if { [ ::tel::list ] != "" } {
               #--- Remise en marche du moteur d'AD
               tel$audace(telNo) radec motor on
            }
         }

         #--- Graphisme panneau
         set panneau(Dscan,acquisition) "0"
         $This.fra4.but1 configure -relief raised -text $panneau(Dscan,go0) -state normal
         update
      } else {
         ::confCam::run
         tkwait window $audace(base).confCam
      }
   }

   proc scan { w h bin dt { o "0" } } {
      variable This
      global audace
      global panneau
      global caption
      global scan_result1

      #--- Petit raccourci
      set camera cam$audace(camNo)

      #--- Calcul du nombre de ligne par seconde
      set panneau(Dscan,nblg1) [ expr 1000./$dt ]
      set panneau(Dscan,nblg)  [ expr int($panneau(Dscan,nblg1)) + 1 ]

      #--- Ouverture de l'obturateur
      catch { cam$audace(camNo) shutter opened }

      #--- Declenchement de l'acquisition
      if { $o == "0" } {
         cam$audace(camNo) scan $w $h $bin $dt -biny $bin
      } else {
         cam$audace(camNo) scan $w $h $bin $dt -offset $o -biny $bin
      }

      #--- Alarme sonore de fin de pose
      set pseudoexptime [ expr $panneau(Dscan,lig1)/$panneau(Dscan,nblg1) ]
      ::camera::alarme_sonore $pseudoexptime

      #--- Appel du timer
      if { $panneau(Dscan,lig1) > "$panneau(Dscan,nblg)" } {
         set t [ expr $panneau(Dscan,lig1)/$panneau(Dscan,nblg1) ]
         ::camera::dispLine $t $panneau(Dscan,nblg1) $panneau(Dscan,lig1)
      }

      #--- Attente de la fin de la pose
      vwait scan_result$audace(camNo)

      #--- Destruction de la fenetre d'avancement du scan
      if [ winfo exists $audace(base).progress_scan ] {
         destroy $audace(base).progress_scan
      }

      #--- Obturateur en mode synchro
      catch { cam$audace(camNo) shutter synchro }
   }

   proc cmdStop { } {
      variable This
      global audace
      global panneau
      global caption

      if { [ ::cam::list ] != "" } {
         if { $panneau(Dscan,acquisition) == "1" } {
            catch {
               #--- Changement de la valeur de la variable
               set panneau(Dscan,stop1) "1"
               #--- Annulation de l'alarme de fin de pose
               catch { after cancel bell }
               #--- Annulation de la pose
               cam$audace(camNo) breakscan
               after 200
               #--- Visualisation de l'image
               ::audace::autovisu $audace(visuNo)
               #--- Gestion du moteur d'A.D.
               if { [ ::tel::list ] != "" } {
                  #--- Remise en marche du moteur d'AD
                  tel$audace(telNo) radec motor on
               }
               #--- Gestion du graphisme du bouton
               $This.fra4.but1 configure -relief raised -text $panneau(Dscan,go1) -state disabled
               update
            }
         }
      } else {
         ::confCam::run
         tkwait window $audace(base).confCam
      }
   }

   proc cmdCalcul { } {
      variable This
      global panneau
      global caption

      if { $panneau(Dscan,binning) == "4x4" } { set bin 4 }
      if { $panneau(Dscan,binning) == "2x2" } { set bin 2 }
      if { $panneau(Dscan,binning) == "1x1" } { set bin 1 }
      set panneau(Dscan,interlig1) [ expr $bin*86164*2*atan($panneau(Dscan,pix)/2./($panneau(Dscan,foc)*1e6))/360.*180/3.1415926*1000./cos( [ mc_angle2rad $panneau(Dscan,dec) ] ) ]
      $This.fra3.fra1.ent1 configure -textvariable panneau(Dscan,interlig1)
      update
   }

   proc InfoCam { } {
      variable This
      variable parametres
      global audace
      global panneau

      catch {
         set parametres(Dscan,col2) "[ lindex [ cam$audace(camNo) nbcells ] 0 ]"
         set parametres(Dscan,dimpix) "[ expr [ lindex [ cam$audace(camNo) celldim ] 0 ] * 1e006]"
         set panneau(Dscan,col2) "$parametres(Dscan,col2)"
         set panneau(Dscan,pix) "$parametres(Dscan,dimpix)"
         set panneau(Dscan,binning) "$parametres(Dscan,binning)"
         $This.fra2.fra1.ent2 configure -textvariable panneau(Dscan,col2)
         $This.fra2.fra3.ent1 configure -textvariable panneau(Dscan,pix)
         $This.fra3.bin.lab_bin configure -textvariable panneau(Dscan,binning)
         update
      }
      ::Dscan::cmdCalcul
   }

   proc cmdVisib { } {
      variable This
      variable parametres
      global conf
      global audace
      global panneau
      global confTel

      #--- Initialisation des variables de l'outil (sauf la position de la declinaison)
      set panneau(Dscan,col1)     "$parametres(Dscan,col1)"
      set panneau(Dscan,col2)     "$parametres(Dscan,col2)"
      set panneau(Dscan,lig1)     "$parametres(Dscan,lig1)"
      set panneau(Dscan,pix)      "$parametres(Dscan,dimpix)"
      set panneau(Dscan,binning)  "$parametres(Dscan,binning)"
      set panneau(Dscan,foc)      "$parametres(Dscan,foc)"

      #--- Initialisation et/ou determination de la position de la declinaison
      if { [ ::tel::list ] != "" } {
         set radec [ tel$audace(telNo) radec coord ]
         if { [ lindex $radec 0 ] == "tel$audace(telNo)" } {
            set panneau(Dscan,dec) "$parametres(Dscan,dec)"
         } else {
            set panneau(Dscan,dec) [ lindex $radec 1 ]
         }
      } elseif { ( $conf(telescope) == "ouranos" ) && ( $confTel(ouranos,connect) == "1" ) } {
         if { $conf(ouranos,show_coord) == "1" } {
            set panneau(Dscan,dec) "$confTel(conf_ouranos,coord_dec)"
         } else {
            set panneau(Dscan,dec) "$parametres(Dscan,dec)"
         }
      } else {
         set panneau(Dscan,dec) "$parametres(Dscan,dec)"
      }
      $This.fra3.fra3.ent2 configure -textvariable panneau(Dscan,dec)  
      update
      ::Dscan::cmdCalcul 
   }
}

proc DscanBuildIF { This } {
   global audace
   global panneau
   global caption

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(menu_name,Dscan) \
            -command {
               ::audace::showHelpPlugin tool scan scan.htm
            }
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(Dscan,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame des colonnes, des lignes et de la dimension des pixels
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Label pour colonnes
         label $This.fra2.lab1 -text $panneau(Dscan,col) -relief flat
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -fill none -padx 4 -pady 1

         #--- Frame des 2 entries de colonnes
         frame $This.fra2.fra1 -borderwidth 1 -relief flat

            #--- Entry pour la colonne de debut
            entry $This.fra2.fra1.ent1 -textvariable panneau(Dscan,col1) -font $audace(font,arial_8_b) \
               -relief groove -width 5 -justify center
            pack $This.fra2.fra1.ent1 -in $This.fra2.fra1 -side left -fill none -padx 4 -pady 1

            #--- Entry pour la colonne de fin
            entry $This.fra2.fra1.ent2 -textvariable panneau(Dscan,col2) -font $audace(font,arial_8_b) \
               -relief groove -width 5 -justify center
            pack $This.fra2.fra1.ent2 -in $This.fra2.fra1 -side right -fill none -padx 4 -pady 1

         pack $This.fra2.fra1 -in $This.fra2 -anchor center -fill none

         #--- Frame pour lignes
         frame $This.fra2.fra2 -borderwidth 1 -relief flat

            #--- Label pour lignes
            label $This.fra2.fra2.lab2 -text $panneau(Dscan,lig) -relief flat
            pack $This.fra2.fra2.lab2 -in $This.fra2.fra2 -side left -fill none -padx 2 -pady 1

            #--- Entry pour lignes
            entry $This.fra2.fra2.ent1 -textvariable panneau(Dscan,lig1) -font $audace(font,arial_8_b) \
               -relief groove -width 7 -justify center
            pack $This.fra2.fra2.ent1 -in $This.fra2.fra2 -side right -fill none -padx 2 -pady 1

         pack $This.fra2.fra2 -in $This.fra2 -anchor center -fill none

         #--- Frame pour la dimension des pixels
         frame $This.fra2.fra3 -borderwidth 1 -relief flat

            #--- Label pour la dimension des pixels
            label $This.fra2.fra3.lab3 -text $panneau(Dscan,pixel) -relief flat
            pack $This.fra2.fra3.lab3 -in $This.fra2.fra3 -side left -fill none -padx 2 -pady 1

            #--- Entry pour la dimension des pixels
            entry $This.fra2.fra3.ent1 -textvariable panneau(Dscan,pix) -font $audace(font,arial_8_b) \
               -relief groove -width 4 -justify center
            pack $This.fra2.fra3.ent1 -in $This.fra2.fra3 -side left -fill none -padx 2 -pady 1

            #--- Label pour l'unite de la dimension des pixels
            label $This.fra2.fra3.lab4 -text $panneau(Dscan,unite) -relief flat
            pack $This.fra2.fra3.lab4 -in $This.fra2.fra3 -side right -fill none -padx 2 -pady 1

         pack $This.fra2.fra3 -in $This.fra2 -anchor center -fill none

      pack $This.fra2 -side top -fill x

      #--- Binding sur la zone des infos de la camera
      set zone(camera) $This.fra2
      bind $zone(camera) <ButtonPress-1> { ::Dscan::InfoCam }
      bind $zone(camera).lab1 <ButtonPress-1> { ::Dscan::InfoCam }
      bind $zone(camera).fra2.lab2 <ButtonPress-1> { ::Dscan::InfoCam }
      bind $zone(camera).fra3.lab3 <ButtonPress-1> { ::Dscan::InfoCam }
      bind $zone(camera).fra3.lab4 <ButtonPress-1> { ::Dscan::InfoCam }

      #--- Frame de l'interligne
      frame $This.fra3 -borderwidth 1 -relief groove

         #--- Label pour interligne
         label $This.fra3.lab1 -text $panneau(Dscan,interlig) -relief flat
         pack $This.fra3.lab1 -in $This.fra3 -anchor center -fill none -padx 4 -pady 1

         #--- Menu pour binning
         frame $This.fra3.bin -borderwidth 0 -relief groove
            menubutton $This.fra3.bin.but_bin -text $panneau(Dscan,bin) -menu $This.fra3.bin.but_bin.menu -relief raised
            pack $This.fra3.bin.but_bin -in $This.fra3.bin -side left -fill none
            set m [ menu $This.fra3.bin.but_bin.menu -tearoff 0 ]
            foreach valbin $panneau(Dscan,choix_bin) {
               $m add radiobutton -label "$valbin" \
                  -indicatoron "1" \
                  -value "$valbin" \
                  -variable panneau(Dscan,binning) \
                  -command { ::Dscan::cmdCalcul }
            }
            entry $This.fra3.bin.lab_bin -width 2 -font {arial 10 bold} -relief groove \
              -textvariable panneau(Dscan,binning) -justify center -state disabled
            pack $This.fra3.bin.lab_bin -in $This.fra3.bin -side left -fill both -expand true
         pack $This.fra3.bin -anchor n -fill x -expand 0 -pady 2

         #--- Frame des entry & labels de la focale
         frame $This.fra3.fra2 -borderwidth 1 -relief flat

            #--- Label pour la focale
            label $This.fra3.fra2.lab1 -text $panneau(Dscan,focale) -relief flat
            pack $This.fra3.fra2.lab1 -in $This.fra3.fra2 -side left -fill none -padx 1 -pady 2

            #--- Entry pour la focale
            entry $This.fra3.fra2.ent1 -textvariable panneau(Dscan,foc) -font $audace(font,arial_8_b) \
               -relief groove -width 5 -justify center
            pack $This.fra3.fra2.ent1 -in $This.fra3.fra2 -side left -fill none -padx 1 -pady 2

            #--- Label pour l'unite de la focale
            label $This.fra3.fra2.lab2 -text $panneau(Dscan,metres) -relief flat
            pack $This.fra3.fra2.lab2 -in $This.fra3.fra2 -side left -fill none -padx 1 -pady 2

         pack $This.fra3.fra2 -in $This.fra3 -anchor center -fill none

         #--- Frame des bouton & entry de la declinaison
         frame $This.fra3.fra3 -borderwidth 1 -relief flat

            #--- Bouton pour la mise a jour de la dec
            button $This.fra3.fra3.but2 -borderwidth 2 -text $panneau(Dscan,declinaison) \
               -width 3 -command { ::Dscan::cmdVisib }
            pack $This.fra3.fra3.but2 -in $This.fra3.fra3 -side left -fill none -pady 1

            #--- Entry pour la dec
            entry $This.fra3.fra3.ent2 -textvariable panneau(Dscan,dec) -font $audace(font,arial_8_b) \
               -relief groove -width 10
            pack $This.fra3.fra3.ent2 -in $This.fra3.fra3 -side right -fill none -pady 1

         pack $This.fra3.fra3 -in $This.fra3 -anchor center -fill none

         #--- Bouton de calcul
         button $This.fra3.but1 -borderwidth 2 -text $panneau(Dscan,calcul) \
            -command { ::Dscan::cmdCalcul }
         pack $This.fra3.but1 -in $This.fra3 -anchor center -fill none -pady 1 -ipadx 13

         #--- Frame des entry & label
         frame $This.fra3.fra1 -borderwidth 1 -relief flat

            #--- Entry pour les millisecondes
            entry $This.fra3.fra1.ent1 -width 7 -relief groove -font $audace(font,arial_8_b) \
              -textvariable panneau(Dscan,interlig1) -state disabled
            pack $This.fra3.fra1.ent1 -in $This.fra3.fra1 -side left -fill none -padx 1 -pady 2

            #--- Label pour l'unite
            label $This.fra3.fra1.ent2 -text $panneau(Dscan,ms) -relief flat
            pack $This.fra3.fra1.ent2 -in $This.fra3.fra1 -side left -fill none -padx 1 -pady 2

         pack $This.fra3.fra1 -in $This.fra3 -anchor center -fill none

      pack $This.fra3 -side top -fill x

      #--- Frame de l'acquisition
      frame $This.fra4 -borderwidth 1 -relief groove
         #--- Label pour interligne
         label $This.fra4.lab1 -text $panneau(Dscan,acq) -relief flat
         pack $This.fra4.lab1 -in $This.fra4 -anchor center -fill none -padx 4 -pady 1

         #--- Bouton GO
         button $This.fra4.but1 -borderwidth 2 -text $panneau(Dscan,go) \
            -command { ::Dscan::cmdGo motoroff }
         pack $This.fra4.but1 -in $This.fra4 -anchor center -fill x -padx 5 -ipadx 10 -ipady 3

         #--- Bouton STOP
         button $This.fra4.but2 -borderwidth 2 -text $panneau(Dscan,stop) \
            -command { ::Dscan::cmdStop }
         pack $This.fra4.but2 -in $This.fra4 -anchor center -fill x -padx 5 -pady 5 -ipadx 15 -ipady 3

      pack $This.fra4 -side top -fill x

   bind $This.fra4.but1 <ButtonPress-3> { ::Dscan::cmdGo motoron }
   bind $This <Visibility> { ::Dscan::cmdVisib }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

global audace

::Dscan::init $audace(base)

