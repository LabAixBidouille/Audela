#
# Fichier : foc.tcl
# Description : Outil pour le controle de la focalisation
# Compatibilit� : Protocoles LX200 et AudeCom
# Auteurs : Alain KLOTZ et Robert DELMAS
# Mise a jour $Id: foc.tcl,v 1.14 2007-06-22 19:48:32 robertdelmas Exp $
#

set ::graphik(compteur) {}
set ::graphik(inten)    {}
set ::graphik(fwhmx)    {}
set ::graphik(fwhmy)    {}
set ::graphik(contr)    {}
set ::graphik(fichier)  ""

#============================================================
# Declaration du namespace focs
#    initialise le namespace
#============================================================
namespace eval ::focs {
   package provide foc 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] foc.cap ]

   #------------------------------------------------------------
   # getPluginTitle
   #    retourne le titre du plugin dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(foc,focalisation)"
   }

   #------------------------------------------------------------
   # getPluginType
   #    retourne le type de plugin
   #------------------------------------------------------------
   proc getPluginType { } {
      return "tool"
   }

   #------------------------------------------------------------
   # getPluginProperty
   #    retourne la valeur de la propriete
   #
   # parametre :
   #    propertyName : nom de la propriete
   # return : valeur de la propriete ou "" si la propriete n'existe pas
   #------------------------------------------------------------
   proc getPluginProperty { propertyName } {
      switch $propertyName {
         function     { return "acquisition" }
         subfunction1 { return "focusing" }
         display      { return "panel" }
      }
   }

   #------------------------------------------------------------
   # initPlugin
   #    initialise le plugin
   #------------------------------------------------------------
   proc initPlugin { tkbase } {

   }

   #------------------------------------------------------------
   # createPluginInstance
   #    cree une nouvelle instance de l'outil
   #------------------------------------------------------------
   proc createPluginInstance { { in "" } { visuNo 1 } } {
      createPanel $in.focs
   }

   #------------------------------------------------------------
   # deletePluginInstance
   #    suppprime l'instance du plugin
   #------------------------------------------------------------
   proc deletePluginInstance { visuNo } {

   }

   #------------------------------------------------------------
   # createPanel
   #    prepare la creation de la fenetre de l'outil
   #------------------------------------------------------------
   proc createPanel { this } {
      variable This
      global caption panneau

      set This $this
      #---
      set panneau(focs,titre)            "$caption(foc,focalisation)"
      set panneau(focs,aide)             "$caption(foc,help_titre)"
      set panneau(focs,acq)              "$caption(foc,acquisition)"
      set panneau(focs,menu)             "$caption(foc,centrage)"
      set panneau(focs,centrage_fenetre) "1"
      set panneau(focs,compteur)         "0"
      set panneau(focs,bin)              "1"
      set panneau(focs,exptime)          "2"
      set panneau(focs,secondes)         "$caption(foc,seconde)"
      set panneau(focs,go)               "$caption(foc,go)"
      set panneau(focs,stop)             "$caption(foc,stop)"
      set panneau(focs,raz)              "$caption(foc,raz)"
      set panneau(focs,focuser)          "focuserlx200"
      set panneau(focs,motorfoc)         "$caption(foc,moteur_focus)"
      set panneau(focs,position)         "$caption(foc,pos_focus)"
      set panneau(focs,trouve)           "$caption(foc,se_trouve)"
      set panneau(focs,pas)              "$caption(foc,pas)"
      set panneau(focs,deplace)          "$caption(foc,aller_a)"
      set panneau(focs,initialise)       "$caption(foc,init)"
      set panneau(focs,graphe)           "$caption(foc,graphe)"

      focsBuildIF $This
   }

   proc adaptOutilFoc { { a "" } { b "" } { c "" } } {
      variable This
      global audace

      if { [ ::focus::possedeControleEtendu $::panneau(focs,focuser) ] == "1" } {
         #--- Avec controle etendu
         set ::panneau(focs,focuser) "focuseraudecom"
         pack $This.fra5.lab1 -in $This.fra5 -anchor center -fill none -padx 4 -pady 1
         pack $This.fra5.but1 -in $This.fra5 -anchor center -fill x -pady 1 -ipadx 15 -ipady 1 -padx 5
         pack $This.fra5.fra1 -in $This.fra5 -anchor center -fill none
         pack $This.fra5.fra1.lab1 -in $This.fra5.fra1 -side left -fill none -pady 2 -padx 4
         pack $This.fra5.fra1.lab2 -in $This.fra5.fra1 -side left -fill none -pady 2 -padx 4
         pack $This.fra5.but2 -in $This.fra5 -anchor center -fill x -pady 1 -ipadx 15 -padx 5
         pack $This.fra5.fra2 -in $This.fra5 -anchor center -fill none
         pack $This.fra5.fra2.ent3 -in $This.fra5.fra2 -side left -fill none -pady 2 -padx 4
         pack $This.fra5.fra2.lab4 -in $This.fra5.fra2 -side left -fill none -pady 2 -padx 4
         pack $This.fra5.but3 -in $This.fra5 -anchor center -fill x -pady 1 -ipadx 15 -padx 5
      } else {
         #--- Sans controle etendu
         set ::panneau(focs,focuser) "focuserlx200"
         pack forget $This.fra5.lab1
         pack forget $This.fra5.but1
         pack forget $This.fra5.fra1.lab1
         pack forget $This.fra5.fra1.lab2
         pack forget $This.fra5.but2
         pack forget $This.fra5.fra2.ent3
         pack forget $This.fra5.fra2.lab4
         pack forget $This.fra5.but3
      }
      $This.fra4.we.lab configure -text $audace(focus,labelspeed)
   }

   #------------------------------------------------------------
   # startTool
   #    affiche la fenetre de l'outil
   #------------------------------------------------------------
   proc startTool { visuNo } {
      variable This

      trace add variable ::conf(telescope) write ::focs::adaptOutilFoc
      pack $This -side left -fill y
      ::focs::adaptOutilFoc
   }

   #------------------------------------------------------------
   # stopTool
   #    masque la fenetre de l'outil
   #------------------------------------------------------------
   proc stopTool { visuNo } {
      variable This
      global audace

      #--- Initialisation du fenetrage
      catch {
         set n1n2 [ cam$audace(camNo) nbcells ]
         cam$audace(camNo) window [ list 1 1 [ lindex $n1n2 0 ] [ lindex $n1n2 1 ] ]
      }
      trace remove variable ::conf(telescope) write ::focs::adaptOutilFoc
      pack forget $This
   }

   proc cmdGo { } {
      variable This
      global audace caption panneau

      #--- Verifie que le temps de pose est bien un r�el positif
      if { [ ::focs::testReel $panneau(focs,exptime) ] == "0" } {
         tk_messageBox -title $caption(foc,probleme) -type ok -message $caption(foc,entier_positif)
         return
      }

      #---
      if { [ ::cam::list ] != "" } {
         #--- Gestion graphique des boutons
         $This.fra2.but1 configure -relief groove -state disabled
         $This.fra2.but2 configure -text $panneau(focs,stop)
         update
         #--- Applique le binning demande si la camera possede bien ce binning
         set binningCamera "2x2"
         if { [ lsearch [ ::confCam::getPluginProperty [ ::confVisu::getCamItem 1 ] binningList ] $binningCamera ] != "-1" } {
            set panneau(focs,bin) "2"
         } else {
            set panneau(focs,bin) "1"
         }
         set panneau(focs,bin_centrage) $panneau(focs,bin)
         #--- Parametrage de la prise de vue en Centrage ou en Fenetrage
         if { [ info exists panneau(focs,actuel) ] == "0" } {
            set panneau(focs,actuel) "$caption(foc,centrage)"
            set dimxy [ cam$audace(camNo) nbcells ]
            set panneau(focs,window) [ list 1 1 [ lindex $dimxy 0 ] [ lindex $dimxy 1 ] ]
         }
         if { $panneau(focs,menu) == "$caption(foc,centrage)" } {
            #--- Applique le binning demande si la camera possede bien ce binning
            set binningCamera "2x2"
            if { [ lsearch [ ::confCam::getPluginProperty [ ::confVisu::getCamItem 1 ] binningList ] $binningCamera ] != "-1" } {
               set panneau(focs,bin) "2"
            } else {
               set panneau(focs,bin) "1"
            }
            set panneau(focs,bin_centrage) $panneau(focs,bin)
            set dimxy [ cam$audace(camNo) nbcells ]
            set panneau(focs,window) [ list 1 1 [ lindex $dimxy 0 ] [ lindex $dimxy 1 ] ]
            set panneau(focs,actuel) "$caption(foc,centrage)"
            set panneau(focs,boucle) "$caption(foc,off)"
         } elseif { $panneau(focs,menu) == "$caption(foc,fenetre)" } {
            set panneau(focs,bin) "1"
            if { $panneau(focs,actuel) == "$caption(foc,centrage)" } {
               if { [ lindex [ list [ ::confVisu::getBox $audace(visuNo) ] ] 0 ] != "" } {
                  set a [ lindex [ list [ ::confVisu::getBox $audace(visuNo) ] ] 0 ]
                  set kk 0
                  set b $a
                  #--- Tient compte du binning
                  foreach e $a {
                     set b [ lreplace $b $kk $kk [ expr $panneau(focs,bin_centrage)*$e ] ]
                     incr kk
                  }
                  set panneau(focs,window) $b
               }
            }
            set panneau(focs,actuel) "$caption(foc,fenetre)"
            set panneau(focs,boucle) "$caption(foc,on)"
         }
         cam$audace(camNo) window $panneau(focs,window)
         #--- Suppression de la zone selectionnee avec la souris
         ::confVisu::deleteBox $audace(visuNo)
         #--- Appel a la fonction d'acquisition
         ::focs::cmdAcq
         #--- Gestion graphique des boutons
         if { $panneau(focs,actuel) == "$caption(foc,centrage)" } {
            $This.fra2.but1 configure -relief raised -text $panneau(focs,go) -state normal
            $This.fra2.but2 configure -relief raised -text $panneau(focs,raz)
            update
         } else {
            $This.fra2.but2 configure -relief raised -text $panneau(focs,raz)
            update
         }
      } else {
         ::confCam::run
         tkwait window $audace(base).confCam
      }
   }

   proc cmdAcq { } {
      variable This
      global audace caption panneau

      #--- Petits raccourcis
      set camera cam$audace(camNo)
      set buffer buf$audace(bufNo)

      #--- La commande exptime permet de fixer le temps de pose de l'image
      $camera exptime $panneau(focs,exptime)

      #--- La commande bin permet de fixer le binning
      $camera bin [ list $panneau(focs,bin) $panneau(focs,bin) ]

      #--- Cas des petites poses : Force l'affichage de l'avancement de la pose avec le statut Lecture du CCD
      if { $panneau(focs,exptime) >= "0" && $panneau(focs,exptime) < "2" } {
         ::camera::Avancement_pose "1"
      }

      #--- Declenchement de l'acquisition
      $camera acq

      #--- Alarme sonore de fin de pose
      ::camera::alarme_sonore $panneau(focs,exptime)

      #--- Appel de l'arret du moteur de foc a 100 millisecondes de la fin de pose
      set delay 0.100
      if { [ expr $panneau(focs,exptime)-$delay ] > "0" } {
         set delay [ expr $panneau(focs,exptime)-$delay ]
         set audace(after,focstop,id) [ after [ expr int($delay*1000) ] { ::focs::cmdFocus stop } ]
      }

      #--- Gestion de la pose : Timer, avancement, attente fin, retournement image, fin anticipee
      ::camera::gestionPose $panneau(focs,exptime) 1 $camera $buffer

      #--- Fenetrage sur le buffer si la camera ne possede pas le mode fenetrage (APN et WebCam)
      if { [ ::confCam::getPluginProperty [ ::confVisu::getCamItem 1 ] window ] == "0" } {
         buf$audace(bufNo) window $panneau(focs,window)
      }

      #--- Visualisation de l'image acquise
      ::audace::autovisu $audace(visuNo)

      #--- Informations sur l'image fenetree
      if { $panneau(focs,actuel) == "$caption(foc,fenetre)" } {
         if { $panneau(focs,boucle) == "$caption(foc,on)" } {
            $This.fra2.but1 configure -relief groove -text $panneau(focs,go)
            $This.fra2.but2 configure -text $panneau(focs,stop)
            update
            incr panneau(focs,compteur)
            lappend ::graphik(compteur) $panneau(focs,compteur)
            #--- Statistiques
            set s [ stat ]
            set maxi [ lindex $s 2 ]
            set fond [ lindex $s 7 ]
            set ::contr [ format "%.0f" [ expr -1.*[ lindex $s 8 ] ] ]
            set ::inten [ format "%.0f" [ expr $maxi-$fond ] ]
            lappend ::graphik(inten) $::inten
            lappend ::graphik(contr) $::contr
            #--- Fwhm
            set naxis1 [ expr [ lindex [ $buffer getkwd NAXIS1 ] 1 ]-0 ]
            set naxis2 [ expr [ lindex [ $buffer getkwd NAXIS2 ] 1 ]-0 ]
            set box [ list 1 1 $naxis1 $naxis2 ]
            set f [ $buffer fwhm $box ]
            set ::fwhmx [ lindex $f 0 ]
            set ::fwhmy [ lindex $f 1 ]
            lappend ::graphik(fwhmx) $::fwhmx
            lappend ::graphik(fwhmy) $::fwhmy
            #--- Graphique
            append ::graphik(fichier) "$::inten $::fwhmx $::fwhmy $::contr \n"
            visuf g_inten $::graphik(compteur) $::graphik(inten) "$caption(foc,intensite_adu)" yes
            visuf g_fwhmx $::graphik(compteur) $::graphik(fwhmx) "$caption(foc,fwhm_x)" yes
            visuf g_fwhmy $::graphik(compteur) $::graphik(fwhmy) "$caption(foc,fwhm_y)" yes
            visuf g_contr $::graphik(compteur) $::graphik(contr) "$caption(foc,contrast_adu)" no
            #--- Valeurs a l'ecran
            ::focs::qualiteFoc
            update
            after idle ::focs::cmdAcq
         }
      }
   }

   proc cmdStop { } {
      variable This
      global audace caption panneau

      if { [ ::cam::list ] != "" } {
         if { [ $This.fra2.but2 cget -text ] == "$panneau(focs,raz)" } {
            set panneau(focs,compteur) "0"
            set ::graphik(compteur) {}
            set ::graphik(inten)    {}
            set ::graphik(fwhmx)    {}
            set ::graphik(fwhmy)    {}
            set ::graphik(contr)    {}
            destroy $audace(base).parafoc
            destroy $audace(base).visufoc
            update
         } else {
            #--- Gestion graphique des boutons
            $This.fra2.but2 configure -relief groove -state disabled
            #--- On annule l'identificateur qui arrete le moteur de foc
            catch { after cancel $audace(after,focstop,id) }
            #--- Graphiques du panneau
            set panneau(focs,boucle) "$caption(foc,off)"
            #--- Annulation de l'alarme de fin de pose
            catch { after cancel bell }
            #--- Gestion de la pose : Timer, avancement, attente fin, retournement image, fin anticipee
            ::camera::gestionPose $panneau(focs,exptime) 0 cam$audace(camNo) buf$audace(bufNo)
            #--- Arret de la pose
            catch { cam$audace(camNo) stop }
            after 200
            #--- Sauvegarde du fichier .log
            ::focs::cmdSauveLog foc.log
            #--- Gestion graphique des boutons
            $This.fra2.but1 configure -relief raised -text $panneau(focs,go) -state normal
            $This.fra2.but2 configure -relief raised -text $panneau(focs,raz) -state normal
            update
         }
      } else {
         ::confCam::run
         tkwait window $audace(base).confCam
      }
   }

   proc testReel { valeur } {
      #--- V�rifie que la chaine pass�e en argument d�crit bien un r�el
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

   proc cmdSauveLog { namefile } {
      global audace

      catch {
         set fileId [ open [ file join $audace(rep_plugin) tool foc $namefile ] w ]
         puts -nonewline $fileId $::graphik(fichier)
         close $fileId
      }
   }

   proc cmdSpeed { } {
      ::focus::incrementSpeed $::panneau(focs,focuser) "tool focs"
   }

   proc cmdFocus { command } {
      variable This

      #--- Gestion graphique des boutons
      $This.fra4.we.canv1 configure -relief ridge
      $This.fra4.we.canv2 configure -relief ridge
      #--- Commande
      ::focus::move $::panneau(focs,focuser) $command
   }

   proc cmdInitFoc { } {
      variable This
      global audace panneau

      if { [ ::tel::list ] != "" } {
         #--- Gestion graphique du bouton
         $This.fra5.but3 configure -relief groove -text $panneau(focs,initialise)
         update
         #--- Met le compteur de foc a zero et rafraichit les affichages
         tel$audace(telNo) focus init 0
         set audace(focus,nbpas1) "00000"
         $This.fra5.fra1.lab1 configure -textvariable audace(focus,nbpas1)
         set audace(focus,nbpas2) ""
         $This.fra5.fra2.ent3 configure -textvariable audace(focus,nbpas2)
         update
         #--- Gestion graphique du bouton
         $This.fra5.but3 configure -relief raised -text $panneau(focs,initialise)
         update
      } else {
         ::confTel::run
         tkwait window $audace(base).confTel
      }
   }

   proc cmdSeTrouveA { } {
      variable This
      global audace panneau

      if { [ ::tel::list ] != "" } {
         #--- Gestion graphique du bouton
         $This.fra5.but1 configure -relief groove -text $panneau(focs,trouve)
         update
         #--- Lit et affiche la position du compteur de foc
         set nbpas1 [ tel$audace(telNo) focus coord ]
         split $nbpas1 "\n"
         set audace(focus,nbpas1) [ lindex $nbpas1 0 ]
         $This.fra5.fra1.lab1 configure -textvariable audace(focus,nbpas1)
         update
         #--- Gestion graphique du bouton
         $This.fra5.but1 configure -relief raised -text $panneau(focs,trouve)
         update
      } else {
         ::confTel::run
         tkwait window $audace(base).confTel
      }
   }

   proc cmdSeDeplaceA { } {
      variable This
      global audace panneau

      if { [ ::tel::list ] != "" } {
         if { $audace(focus,nbpas2) != "" } {
            #--- Gestion graphique des boutons
            $This.fra5.but3 configure -relief groove -state disabled
            $This.fra5.but2 configure -relief groove -text $panneau(focs,deplace)
            update
            #--- Gestion des limites
            if { $audace(focus,nbpas2) > "32767" } {
               #--- Message au-dela de la limite superieure
               ::focs::limiteFoc
               set audace(focus,nbpas2) ""
               $This.fra5.fra2.ent3 configure -textvariable audace(focus,nbpas2)
               update
            } elseif { $audace(focus,nbpas2) < "-32767" } {
               #--- Message au-dela de la limite inferieure
               ::focs::limiteFoc
               set audace(focus,nbpas2) ""
               $This.fra5.fra2.ent3 configure -textvariable audace(focus,nbpas2)
               update
            } else {
               #--- Lit la position de depart du compteur de foc
               set nbpas1 [ tel$audace(telNo) focus coord ]
               split $nbpas1 "\n"
               set audace(focus,nbpas1) [ lindex $nbpas1 0 ]
               #--- Lance le goto du focaliseur
               ::focus::goto $::panneau(focs,focuser)
               #--- Affiche la position d'arrivee
               $This.fra5.fra1.lab1 configure -textvariable audace(focus,nbpas1)
            }
            #--- Gestion graphique des boutons
            $This.fra5.but2 configure -relief raised -text $panneau(focs,deplace)
            $This.fra5.but3 configure -relief raised -state normal
            update
         }
      } else {
         ::confTel::run
         tkwait window $audace(base).confTel
      }
   }

   proc formatFoc { } {
      global audace caption

      if [ winfo exists $audace(base).formatfoc ] {
         destroy $audace(base).formatfoc
      }
      toplevel $audace(base).formatfoc
      wm transient $audace(base).formatfoc $audace(base)
      wm title $audace(base).formatfoc "$caption(foc,attention)"
      set posx_formatfoc [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
      set posy_formatfoc [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
      wm geometry $audace(base).formatfoc +[ expr $posx_formatfoc + 120 ]+[ expr $posy_formatfoc + 340 ]
      wm resizable $audace(base).formatfoc 0 0

      #--- Cree l'affichage du message
      label $audace(base).formatfoc.lab1 -text "$caption(foc,formatfoc1)"
      pack $audace(base).formatfoc.lab1 -padx 10 -pady 2
      label $audace(base).formatfoc.lab2 -text "$caption(foc,formatfoc2)"
      pack $audace(base).formatfoc.lab2 -padx 10 -pady 2

      #--- La nouvelle fenetre est active
      focus $audace(base).formatfoc

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).formatfoc
   }

   proc limiteFoc { } {
      global audace caption

      if [ winfo exists $audace(base).limitefoc ] {
         destroy $audace(base).limitefoc
      }
      toplevel $audace(base).limitefoc
      wm transient $audace(base).limitefoc $audace(base)
      wm title $audace(base).limitefoc "$caption(foc,attention)"
      set posx_limitefoc [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
      set posy_limitefoc [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
      wm geometry $audace(base).limitefoc +[ expr $posx_limitefoc + 120 ]+[ expr $posy_limitefoc + 340 ]
      wm resizable $audace(base).limitefoc 0 0

      #--- Cree l'affichage du message
      label $audace(base).limitefoc.lab1 -text "$caption(foc,limitefoc1)"
      pack $audace(base).limitefoc.lab1 -padx 10 -pady 2
      if { $audace(focus,nbpas2) > "32767" } {
         label $audace(base).limitefoc.lab2 -text "$caption(foc,limitefoc2)"
         pack $audace(base).limitefoc.lab2 -padx 10 -pady 2
      } else {
         label $audace(base).limitefoc.lab2 -text "$caption(foc,limitefoc3)"
         pack $audace(base).limitefoc.lab2 -padx 10 -pady 2
      }

      #--- La nouvelle fenetre est active
      focus $audace(base).limitefoc

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).limitefoc
   }

   proc qualiteFoc { } {
      global audace caption conf panneau

      #--- Fenetre d'affichage des parametres de la foc
      if [ winfo exists $audace(base).parafoc ] {
         ::focs::fermeQualiteFoc
      }
      #--- Initialisation de la position de la fenetre
      if { ! [ info exists conf(parafoc,position) ] } { set conf(parafoc,position) "+500+75" }
      #--- Creation de la fenetre
      toplevel $audace(base).parafoc
      wm transient $audace(base).parafoc $audace(base)
      wm resizable $audace(base).parafoc 0 0
      wm title $audace(base).parafoc "$caption(foc,focalisation)"
      wm geometry $audace(base).parafoc $conf(parafoc,position)
      wm protocol $audace(base).parafoc WM_DELETE_WINDOW ::focs::fermeQualiteFoc
      #--- Cree les etiquettes
      label $audace(base).parafoc.lab1 -text "$panneau(focs,compteur)"
      pack $audace(base).parafoc.lab1 -padx 10 -pady 2
      label $audace(base).parafoc.lab2 -text "$caption(foc,intensite) $caption(foc,egale) $::inten"
      pack $audace(base).parafoc.lab2 -padx 5 -pady 2
      label $audace(base).parafoc.lab3 -text "$caption(foc,fwhm__x) $caption(foc,egale) $::fwhmx"
      pack $audace(base).parafoc.lab3 -padx 5 -pady 2
      label $audace(base).parafoc.lab4 -text "$caption(foc,fwhm__y) $caption(foc,egale) $::fwhmy"
      pack $audace(base).parafoc.lab4 -padx 5 -pady 2
      label $audace(base).parafoc.lab5 -text "$caption(foc,contraste) $caption(foc,egale) $::contr"
      pack $audace(base).parafoc.lab5 -padx 5 -pady 2
      update

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).parafoc
   }

   proc fermeQualiteFoc { } {
      global audace conf

      #--- Determination de la position de la fenetre
      set geometry [ wm geometry $audace(base).parafoc ]
      set deb [ expr 1 + [ string first + $geometry ] ]
      set fin [ string length $geometry ]
      set conf(parafoc,position) "+[ string range $geometry $deb $fin ]"
      #--- Fermeture de la fenetre
      destroy $audace(base).parafoc
   }

}

proc focGraphe { } {
   global audace caption conf panneau

   #--- Fenetre d'affichage des parametres de la foc
   if [ winfo exists $audace(base).visufoc ] {
      fermeGraphe
   }
   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(visufoc,position) ] } { set conf(visufoc,position) "+200+0" }
   #--- Creation et affichage des graphes
   if { [ winfo exists $audace(base).visufoc ] == "0" } {
      package require BLT
      #--- Creation de la fenetre
      toplevel $audace(base).visufoc
      wm title $audace(base).visufoc "$caption(foc,titre_graphe)"
      if { $panneau(focs,exptime) > "2" } {
         wm transient $audace(base).visufoc $audace(base)
      }
      wm resizable $audace(base).visufoc 0 0
      wm geometry $audace(base).visufoc $conf(visufoc,position)
      wm protocol $audace(base).visufoc WM_DELETE_WINDOW { fermeGraphe }
      #---
      ::blt::graph $audace(base).visufoc.g_inten
      ::blt::graph $audace(base).visufoc.g_fwhmx
      ::blt::graph $audace(base).visufoc.g_fwhmy
      ::blt::graph $audace(base).visufoc.g_contr
      visuf g_inten $::graphik(compteur) $::graphik(inten) "$caption(foc,intensite_adu)" yes
      visuf g_fwhmx $::graphik(compteur) $::graphik(fwhmx) "$caption(foc,fwhm_x)" yes
      visuf g_fwhmy $::graphik(compteur) $::graphik(fwhmy) "$caption(foc,fwhm_y)" yes
      visuf g_contr $::graphik(compteur) $::graphik(contr) "$caption(foc,contrast_adu)" no
      update

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).visufoc
   }
}

proc fermeGraphe { } {
   global audace conf

   #--- Determination de la position de la fenetre
   set geometry [ wm geometry $audace(base).visufoc ]
   set deb [ expr 1 + [ string first + $geometry ] ]
   set fin [ string length $geometry ]
   set conf(visufoc,position) "+[ string range $geometry $deb $fin ]"
   #--- Fermeture de la fenetre
   destroy $audace(base).visufoc
}

proc visuf { win_name x y { title "" } { yesno "yes" } } {
   global audace

   if { [ winfo exists $audace(base).visufoc.$win_name ] == "1" } {
      catch { ::blt::vector delete vx$win_name }
      catch { ::blt::vector delete vy$win_name }
      catch { $audace(base).visufoc.$win_name element delete line1 }
      ::blt::vector create vx$win_name
      vx$win_name set $x
      ::blt::vector create vy$win_name
      vy$win_name set $y
      $audace(base).visufoc.$win_name element create line1 -xdata vx$win_name -ydata vy$win_name
      $audace(base).visufoc.$win_name legend configure -hide yes
      $audace(base).visufoc.$win_name axis configure y -title "$title"
      $audace(base).visufoc.$win_name axis configure x -hide $yesno
      if { $yesno == "yes" } {
         set h 110
      } else {
         set h 140
      }
      $audace(base).visufoc.$win_name configure -height $h
      $audace(base).visufoc.$win_name axis configure y2 -hide no
      set ly [ $audace(base).visufoc.$win_name axis limits y ]
      $audace(base).visufoc.$win_name axis configure y2 -min [ lindex $ly 0 ] -max [ lindex $ly 1 ]
      pack $audace(base).visufoc.$win_name
   }
}

#------------------------------------------------------------
# focsBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc focsBuildIF { This } {
   global audace caption panneau

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(focs,titre) \
            -command "::audace::showHelpPlugin tool foc foc.htm"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(focs,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame du centrage/pointage
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Label pour acquistion
         label $This.fra2.lab1 -text $panneau(focs,acq) -relief flat
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -fill none -padx 4 -pady 1

         #--- Menu
         menubutton $This.fra2.optionmenu1 -textvariable panneau(focs,menu) \
            -menu $This.fra2.optionmenu1.menu -relief raised
         pack $This.fra2.optionmenu1 -in $This.fra2 -anchor center -padx 4 -pady 2 -ipadx 3
         set m [ menu $This.fra2.optionmenu1.menu -tearoff 0 ]
         $m add radiobutton -label "$caption(foc,centrage)" \
            -indicatoron "1" \
            -value "1" \
            -variable panneau(focs,centrage_fenetre) \
            -command { set panneau(focs,menu) "$caption(foc,centrage)" ; set panneau(focs,centrage_fenetre) "1" }
         $m add radiobutton -label "$caption(foc,fenetre)" \
            -indicatoron "1" \
            -value "2" \
            -variable panneau(focs,centrage_fenetre) \
            -command { set panneau(focs,menu) "$caption(foc,fenetre)" ; set panneau(focs,centrage_fenetre) "2" }

         #--- Frame des entry & label
         frame $This.fra2.fra1 -borderwidth 1 -relief flat

            #--- Entry pour exptime
            entry $This.fra2.fra1.ent1 -font $audace(font,arial_8_b) -textvariable panneau(focs,exptime) \
               -relief groove -width 6 -justify center
            pack $This.fra2.fra1.ent1 -in $This.fra2.fra1 -side left -fill none -padx 4 -pady 2

            #--- Label secondes
            label $This.fra2.fra1.lab1 -text $panneau(focs,secondes) -relief flat
            pack $This.fra2.fra1.lab1 -in $This.fra2.fra1 -side left -fill none -padx 4 -pady 2

         pack $This.fra2.fra1 -in $This.fra2 -anchor center -fill none

         #--- Bouton GO
         button $This.fra2.but1 -borderwidth 2 -text $panneau(focs,go) -command { ::focs::cmdGo }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill x -padx 5 -pady 2 -ipadx 15 -ipady 1

         #--- Bouton STOP/RAZ
         button $This.fra2.but2 -borderwidth 2 -text $panneau(focs,raz) -command { ::focs::cmdStop }
         pack $This.fra2.but2 -in $This.fra2 -anchor center -fill x -padx 5 -pady 2 -ipadx 15 -ipady 1

      pack $This.fra2 -side top -fill x

      #--- Frame des boutons manuels
      frame $This.fra4 -borderwidth 1 -relief groove

         #--- Frame focuser
         ::confEqt::createFrameFocuserTool $This.fra4.focuser ::panneau(focs,focuser)
         pack $This.fra4.focuser -in $This.fra4 -anchor nw -side top -padx 4 -pady 1

         #--- Label pour moteur focus
         label $This.fra4.lab1 -text $panneau(focs,motorfoc) -relief flat
         pack $This.fra4.lab1 -in $This.fra4 -anchor center -fill none -padx 4 -pady 1

         #--- Create the buttons '- +'
         frame $This.fra4.we -width 27 -borderwidth 0 -relief flat
         pack $This.fra4.we -in $This.fra4 -side top -fill x

         #--- Button '-'
         button $This.fra4.we.canv1 -borderwidth 2 \
            -font [ list {Arial} 12 bold ] \
            -text "-" \
            -width 2  \
            -anchor center \
            -relief ridge
         pack $This.fra4.we.canv1 -in $This.fra4.we -expand 0 -side left -padx 2 -pady 2

         #--- Write the label of speed for LX200 and compatibles
         label $This.fra4.we.lab -font [ list {Arial} 12 bold ] -textvariable audace(focus,labelspeed) -width 2 \
            -borderwidth 0 -relief flat
         pack $This.fra4.we.lab -in $This.fra4.we -expand 1 -side left

         #--- Button '+'
         button $This.fra4.we.canv2 -borderwidth 2 \
            -font [ list {Arial} 12 bold ] \
            -text "+" \
            -width 2  \
            -anchor center \
            -relief ridge
         pack $This.fra4.we.canv2 -in $This.fra4.we -expand 0 -side right -padx 2 -pady 2

         set zone(moins) $This.fra4.we.canv1
         set zone(plus)  $This.fra4.we.canv2

      pack $This.fra4 -side top -fill x

      #--- Speed
      bind $This.fra4.we.lab <ButtonPress-1> { ::focs::cmdSpeed }

      #--- Cardinal moves
      bind $zone(moins) <ButtonPress-1>   { ::focs::cmdFocus - }
      bind $zone(moins) <ButtonRelease-1> { ::focs::cmdFocus stop }
      bind $zone(plus)  <ButtonPress-1>   { ::focs::cmdFocus + }
      bind $zone(plus)  <ButtonRelease-1> { ::focs::cmdFocus stop }

      #--- Frame de la position focus
      frame $This.fra5 -borderwidth 1 -relief groove

         #--- Label pour la position focus
         label $This.fra5.lab1 -text $panneau(focs,position) -relief flat
         pack $This.fra5.lab1 -in $This.fra5 -anchor center -fill none -padx 4 -pady 1

         #--- Bouton "Se trouve �"
         button $This.fra5.but1 -borderwidth 2 -text $panneau(focs,trouve) -command { ::focs::cmdSeTrouveA }
         pack $This.fra5.but1 -in $This.fra5 -anchor center -fill x -padx 5 -pady 2 -ipadx 15

         #--- Frame des labels
         frame $This.fra5.fra1 -borderwidth 1 -relief flat

            #--- Label pour nbpas1
            entry $This.fra5.fra1.lab1 -font $audace(font,arial_8_b) -textvariable audace(focus,nbpas1) \
               -relief groove -width 6 -state disabled
            pack $This.fra5.fra1.lab1 -in $This.fra5.fra1 -side left -fill none -padx 4 -pady 2

            #--- Label pas
            label $This.fra5.fra1.lab2 -text $panneau(focs,pas) -relief flat
            pack $This.fra5.fra1.lab2 -in $This.fra5.fra1 -side left -fill none -padx 4 -pady 2

         pack $This.fra5.fra1 -in $This.fra5 -anchor center -fill none

         #--- Bouton "Aller �"
         button $This.fra5.but2 -borderwidth 2 -text $panneau(focs,deplace) -command { ::focs::cmdSeDeplaceA }
         pack $This.fra5.but2 -in $This.fra5 -anchor center -fill x -padx 5 -pady 2 -ipadx 15

         #--- Frame des entry & label
         frame $This.fra5.fra2 -borderwidth 1 -relief flat

            #--- Entry pour nbpas2
            entry $This.fra5.fra2.ent3 -font $audace(font,arial_8_b) -textvariable audace(focus,nbpas2) \
               -relief groove -width 6 -justify center
            pack $This.fra5.fra2.ent3 -in $This.fra5.fra2 -side left -fill none -padx 4 -pady 2
            bind $This.fra5.fra2.ent3 <Enter> { ::focs::formatFoc }
            bind $This.fra5.fra2.ent3 <Leave> { destroy $audace(base).formatfoc }

            #--- Label pas
            label $This.fra5.fra2.lab4 -text $panneau(focs,pas) -relief flat
            pack $This.fra5.fra2.lab4 -in $This.fra5.fra2 -side left -fill none -padx 4 -pady 2

         pack $This.fra5.fra2 -in $This.fra5 -anchor center -fill none

         #--- Bouton "Initialisation"
         button $This.fra5.but3 -borderwidth 2 -text $panneau(focs,initialise) -command { ::focs::cmdInitFoc }
         pack $This.fra5.but3 -in $This.fra5 -anchor center -fill x -padx 5 -pady 2 -ipadx 15

      pack $This.fra5 -side top -fill x

      #--- Frame du graphe
      frame $This.fra3 -borderwidth 1 -relief groove

         #--- Bouton GRAPHE
         button $This.fra3.but1 -borderwidth 2 -text $panneau(focs,graphe) -command { focGraphe }
         pack $This.fra3.but1 -in $This.fra3 -side bottom -fill x -padx 5 -pady 5 -ipadx 15 -ipady 2

      pack $This.fra3 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}
