#
# Fichier : foc.tcl
# Description : Outil pour le controle de la focalisation
# Compatibilité : Protocoles LX200 et AudeCom
# Auteurs : Alain KLOTZ et Robert DELMAS
# Mise a jour $Id: foc.tcl,v 1.11 2007-04-14 08:31:03 robertdelmas Exp $
#

set ::graphik(compteur) {}
set ::graphik(inten)    {}
set ::graphik(fwhmx)    {}
set ::graphik(fwhmy)    {}
set ::graphik(contr)    {}
set ::graphik(fichier)  ""

#============================================================
# Declaration du namespace Focs
#    initialise le namespace
#============================================================
namespace eval ::Focs {
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
      set panneau(Focs,titre)            "$caption(foc,focalisation)"
      set panneau(Focs,aide)             "$caption(foc,help_titre)"
      set panneau(Focs,acq)              "$caption(foc,acquisition)"
      set panneau(Focs,menu)             "$caption(foc,centrage)"
      set panneau(Focs,centrage_fenetre) "1"
      set panneau(Focs,compteur)         "0"
      set panneau(Focs,bin)              "1"
      set panneau(Focs,exptime)          "2"
      set panneau(Focs,secondes)         "$caption(foc,seconde)"
      set panneau(Focs,go)               "$caption(foc,go)"
      set panneau(Focs,stop)             "$caption(foc,stop)"
      set panneau(Focs,raz)              "$caption(foc,raz)"
      set panneau(Focs,focuser)          "focuserlx200"
      set panneau(Focs,motorfoc)         "$caption(foc,moteur_focus)"
      set panneau(Focs,position)         "$caption(foc,pos_focus)"
      set panneau(Focs,trouve)           "$caption(foc,se_trouve)"
      set panneau(Focs,pas)              "$caption(foc,pas)"
      set panneau(Focs,deplace)          "$caption(foc,aller_a)"
      set panneau(Focs,initialise)       "$caption(foc,init)"
      set panneau(Focs,graphe)           "$caption(foc,graphe)"

      FocsBuildIF $This
   }

   proc Adapt_Panneau_Foc { { a "" } { b "" } { c "" } } {
      variable This
      global audace

      if { [ ::focus::possedeControleEtendu $::panneau(Focs,focuser) ] == "1" } {
         #--- Avec controle etendu
         set ::panneau(Focs,focuser) "focuseraudecom"
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
         set ::panneau(Focs,focuser) "focuserlx200"
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

      trace add variable ::conf(telescope) write ::Focs::Adapt_Panneau_Foc
      pack $This -side left -fill y
      ::Focs::Adapt_Panneau_Foc
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
      trace remove variable ::conf(telescope) write ::Focs::Adapt_Panneau_Foc
      pack forget $This
   }

   proc cmdGo { } {
      variable This
      global audace caption panneau

      #--- Verifie que le temps de pose est bien un réel positif
      if { [ ::Focs::TestReel $panneau(Focs,exptime) ] == "0" } {
         tk_messageBox -title $caption(foc,probleme) -type ok -message $caption(foc,entier_positif)
         return
      }

      #---
      if { [ ::cam::list ] != "" } {
         #--- Gestion graphique des boutons
         $This.fra2.but1 configure -relief groove -state disabled
         $This.fra2.but2 configure -text $panneau(Focs,stop)
         update
         #--- Applique le binning demande si la camera possede bien ce binning
         set binningCamera "2"
         if { [ lsearch [ ::confCam::getBinningList $audace(camNo) ] $binningCamera ] != "-1" } {
            set panneau(Focs,bin) "2"
         } else {
            set panneau(Focs,bin) "1"
         }
         #--- Parametrage de la prise de vue en Centrage ou en Fenetrage
         if { [ info exists panneau(Focs,actuel) ] == "0" } {
            set panneau(Focs,actuel) "$caption(foc,centrage)"
            set dimxy [ cam$audace(camNo) nbcells ]
            set panneau(Focs,window) [ list 1 1 [ lindex $dimxy 0 ] [ lindex $dimxy 1 ] ]
         }
         if { $panneau(Focs,menu) == "$caption(foc,centrage)" } {
            #--- Applique le binning demande si la camera possede bien ce binning
            set binningCamera "2"
            if { [ lsearch [ ::confCam::getBinningList $audace(camNo) ] $binningCamera ] != "-1" } {
               set panneau(Focs,bin) "2"
            } else {
               set panneau(Focs,bin) "1"
         }
            set dimxy [ cam$audace(camNo) nbcells ]
            set panneau(Focs,window) [ list 1 1 [ lindex $dimxy 0 ] [ lindex $dimxy 1 ] ]
            set panneau(Focs,actuel) "$caption(foc,centrage)"
            set panneau(Focs,boucle) "$caption(foc,off)"
         } elseif { $panneau(Focs,menu) == "$caption(foc,fenetre)" } {
            set panneau(Focs,bin) "1"
            if { $panneau(Focs,actuel) == "$caption(foc,centrage)" } {
               if { [ lindex [ list [ ::confVisu::getBox $audace(visuNo) ] ] 0 ] != "" } {
                  set a [ lindex [ list [ ::confVisu::getBox $audace(visuNo) ] ] 0 ]
                  set kk 0
                  set b $a
                  #--- Tient compte du binning
                  foreach e $a {
                     set b [ lreplace $b $kk $kk [ expr $panneau(Focs,bin)*$e ] ]
                     incr kk
                  }
                  set panneau(Focs,window) $b
               }
            }
            set panneau(Focs,actuel) "$caption(foc,fenetre)"
            set panneau(Focs,boucle) "$caption(foc,on)"
         }
         cam$audace(camNo) window $panneau(Focs,window)
         #--- Suppression de la zone selectionnee avec la souris
         ::confVisu::deleteBox $audace(visuNo)
         #--- Appel a la fonction d'acquisition
         ::Focs::cmdAcq
         #--- Gestion graphique des boutons
         if { $panneau(Focs,actuel) == "$caption(foc,centrage)" } {
            $This.fra2.but1 configure -relief raised -text $panneau(Focs,go) -state normal
            $This.fra2.but2 configure -relief raised -text $panneau(Focs,raz)
            update
         } else {
            $This.fra2.but2 configure -relief raised -text $panneau(Focs,raz)
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
      $camera exptime $panneau(Focs,exptime)

      #--- La commande bin permet de fixer le binning
      $camera bin [ list $panneau(Focs,bin) $panneau(Focs,bin) ]

      #--- Cas des petites poses : Force l'affichage de l'avancement de la pose avec le statut Lecture du CCD
      if { $panneau(Focs,exptime) >= "0" && $panneau(Focs,exptime) < "2" } {
         ::camera::Avancement_pose "1"
      }

      #--- Declenchement de l'acquisition
      $camera acq

      #--- Alarme sonore de fin de pose
      ::camera::alarme_sonore $panneau(Focs,exptime)

      #--- Appel de l'arret du moteur de foc a 100 millisecondes de la fin de pose
      set delay 0.100
      if { [ expr $panneau(Focs,exptime)-$delay ] > "0" } {
         set delay [ expr $panneau(Focs,exptime)-$delay ]
         set audace(after,focstop,id) [ after [ expr int($delay*1000) ] { ::Focs::cmdFocus stop } ]
      }

      #--- Gestion de la pose : Timer, avancement, attente fin, retournement image, fin anticipee
      ::camera::gestionPose $panneau(Focs,exptime) 1 $camera $buffer

      #--- Fenetrage sur le buffer si la camera ne possede pas le mode fenetrage (APN et WebCam)
      if { [ ::confCam::hasCapability $audace(camNo) window ] == "0" } {
         buf$audace(bufNo) window $panneau(Focs,window)
      }

      #--- Visualisation de l'image acquise
      ::audace::autovisu $audace(visuNo)

      #--- Informations sur l'image fenetree
      if { $panneau(Focs,actuel) == "$caption(foc,fenetre)" } {
         if { $panneau(Focs,boucle) == "$caption(foc,on)" } {
            $This.fra2.but1 configure -relief groove -text $panneau(Focs,go)
            $This.fra2.but2 configure -text $panneau(Focs,stop)
            update
            incr panneau(Focs,compteur)
            lappend ::graphik(compteur) $panneau(Focs,compteur)
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
            ::Focs::ParaFoc
            update
            after idle ::Focs::cmdAcq
         }
      }
   }

   proc cmdStop { } {
      variable This
      global audace caption panneau

      if { [ ::cam::list ] != "" } {
         if { [ $This.fra2.but2 cget -text ] == "$panneau(Focs,raz)" } {
            set panneau(Focs,compteur) "0"
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
            set panneau(Focs,boucle) "$caption(foc,off)"
            #--- Annulation de l'alarme de fin de pose
            catch { after cancel bell }
            #--- Gestion de la pose : Timer, avancement, attente fin, retournement image, fin anticipee
            ::camera::gestionPose $panneau(Focs,exptime) 0 cam$audace(camNo) buf$audace(bufNo)
            #--- Arret de la pose
            catch { cam$audace(camNo) stop }
            after 200
            #--- Sauvegarde du fichier .log
            ::Focs::cmdSauveLog foc.log
            #--- Gestion graphique des boutons
            $This.fra2.but1 configure -relief raised -text $panneau(Focs,go) -state normal
            $This.fra2.but2 configure -relief raised -text $panneau(Focs,raz) -state normal
            update
         }
      } else {
         ::confCam::run
         tkwait window $audace(base).confCam
      }
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

   proc cmdSauveLog { namefile } {
      global audace

      catch {
         set fileId [ open [ file join $audace(rep_plugin) tool foc $namefile ] w ]
         puts -nonewline $fileId $::graphik(fichier)
         close $fileId
      }
   }

   proc cmdSpeed { } {
      ::focus::incrementSpeed $::panneau(Focs,focuser) "tool Focs"
   }

   proc cmdFocus { command } {
      variable This

      #--- Gestion graphique des boutons
      $This.fra4.we.canv1 configure -relief ridge
      $This.fra4.we.canv2 configure -relief ridge
      #--- Commande
      ::focus::move $::panneau(Focs,focuser) $command
   }

   proc cmdInitfoc { } {
      variable This
      global audace panneau

      if { [ ::tel::list ] != "" } {
         #--- Gestion graphique du bouton
         $This.fra5.but3 configure -relief groove -text $panneau(Focs,initialise)
         update
         #--- Met le compteur de foc a zero et rafraichit les affichages
         tel$audace(telNo) focus init 0
         set audace(focus,nbpas1) "00000"
         $This.fra5.fra1.lab1 configure -textvariable audace(focus,nbpas1)
         set audace(focus,nbpas2) ""
         $This.fra5.fra2.ent3 configure -textvariable audace(focus,nbpas2)
         update
         #--- Gestion graphique du bouton
         $This.fra5.but3 configure -relief raised -text $panneau(Focs,initialise)
         update
      } else {
         ::confTel::run
         tkwait window $audace(base).confTel
      }
   }

   proc cmdSetrouvea { } {
      variable This
      global audace panneau

      if { [ ::tel::list ] != "" } {
         #--- Gestion graphique du bouton
         $This.fra5.but1 configure -relief groove -text $panneau(Focs,trouve)
         update
         #--- Lit et affiche la position du compteur de foc
         set nbpas1 [ tel$audace(telNo) focus coord ]
         split $nbpas1 "\n"
         set audace(focus,nbpas1) [ lindex $nbpas1 0 ]
         $This.fra5.fra1.lab1 configure -textvariable audace(focus,nbpas1)
         update
         #--- Gestion graphique du bouton
         $This.fra5.but1 configure -relief raised -text $panneau(Focs,trouve)
         update
      } else {
         ::confTel::run
         tkwait window $audace(base).confTel
      }
   }

   proc cmdSedeplacea { } {
      variable This
      global audace panneau

      if { [ ::tel::list ] != "" } {
         if { $audace(focus,nbpas2) != "" } {
            #--- Gestion graphique des boutons
            $This.fra5.but3 configure -relief groove -state disabled
            $This.fra5.but2 configure -relief groove -text $panneau(Focs,deplace)
            update
            #--- Gestion des limites
            if { $audace(focus,nbpas2) > "32767" } {
               #--- Message au-dela de la limite superieure
               ::Focs::LimiteFoc
               set audace(focus,nbpas2) ""
               $This.fra5.fra2.ent3 configure -textvariable audace(focus,nbpas2)
               update
            } elseif { $audace(focus,nbpas2) < "-32767" } {
               #--- Message au-dela de la limite inferieure
               ::Focs::LimiteFoc
               set audace(focus,nbpas2) ""
               $This.fra5.fra2.ent3 configure -textvariable audace(focus,nbpas2)
               update
            } else {
               #--- Lit la position de depart du compteur de foc
               set nbpas1 [ tel$audace(telNo) focus coord ]
               split $nbpas1 "\n"
               set audace(focus,nbpas1) [ lindex $nbpas1 0 ]
               #--- Lance le goto du focaliseur
               ::focus::goto $::panneau(Focs,focuser)
               #--- Affiche la position d'arrivee
               $This.fra5.fra1.lab1 configure -textvariable audace(focus,nbpas1)
            }
            #--- Gestion graphique des boutons
            $This.fra5.but2 configure -relief raised -text $panneau(Focs,deplace)
            $This.fra5.but3 configure -relief raised -state normal
            update
         }
      } else {
         ::confTel::run
         tkwait window $audace(base).confTel
      }
   }

   proc FormatFoc { } {
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

   proc LimiteFoc { } {
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

   proc ParaFoc { } {
      global audace caption conf panneau

      #--- Fenetre d'affichage des parametres de la foc
      if [ winfo exists $audace(base).parafoc ] {
         ::Focs::ferme_ParaFoc
      }
      #--- Initialisation de la position de la fenetre
      if { ! [ info exists conf(parafoc,position) ] } { set conf(parafoc,position) "+500+75" }
      #--- Creation de la fenetre
      toplevel $audace(base).parafoc
      wm transient $audace(base).parafoc $audace(base)
      wm resizable $audace(base).parafoc 0 0
      wm title $audace(base).parafoc "$caption(foc,focalisation)"
      wm geometry $audace(base).parafoc $conf(parafoc,position)
      wm protocol $audace(base).parafoc WM_DELETE_WINDOW ::Focs::ferme_ParaFoc
      #--- Cree les etiquettes
      label $audace(base).parafoc.lab1 -text "$panneau(Focs,compteur)"
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

   proc ferme_ParaFoc { } {
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

proc FocGraphe { } {
   global audace caption conf panneau

   #--- Fenetre d'affichage des parametres de la foc
   if [ winfo exists $audace(base).visufoc ] {
      ferme_Graphe
   }
   #--- Initialisation de la position de la fenetre
   if { ! [ info exists conf(visufoc,position) ] } { set conf(visufoc,position) "+200+0" }
   #--- Creation et affichage des graphes
   if { [ winfo exists $audace(base).visufoc ] == "0" } {
      package require BLT
      #--- Creation de la fenetre
      toplevel $audace(base).visufoc
      wm title $audace(base).visufoc "$caption(foc,titre_graphe)"
      if { $panneau(Focs,exptime) > "2" } {
         wm transient $audace(base).visufoc $audace(base)
      }
      wm resizable $audace(base).visufoc 0 0
      wm geometry $audace(base).visufoc $conf(visufoc,position)
      wm protocol $audace(base).visufoc WM_DELETE_WINDOW { ferme_Graphe }
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

proc ferme_Graphe { } {
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
# FocsBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc FocsBuildIF { This } {
   global audace caption panneau

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(Focs,titre) \
            -command "::audace::showHelpPlugin tool foc foc.htm"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(Focs,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame du centrage/pointage
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Label pour acquistion
         label $This.fra2.lab1 -text $panneau(Focs,acq) -relief flat
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -fill none -padx 4 -pady 1

         #--- Menu
         menubutton $This.fra2.optionmenu1 -textvariable panneau(Focs,menu) \
            -menu $This.fra2.optionmenu1.menu -relief raised
         pack $This.fra2.optionmenu1 -in $This.fra2 -anchor center -padx 4 -pady 2 -ipadx 3
         set m [ menu $This.fra2.optionmenu1.menu -tearoff 0 ]
         $m add radiobutton -label "$caption(foc,centrage)" \
            -indicatoron "1" \
            -value "1" \
            -variable panneau(Focs,centrage_fenetre) \
            -command { set panneau(Focs,menu) "$caption(foc,centrage)" ; set panneau(Focs,centrage_fenetre) "1" }
         $m add radiobutton -label "$caption(foc,fenetre)" \
            -indicatoron "1" \
            -value "2" \
            -variable panneau(Focs,centrage_fenetre) \
            -command { set panneau(Focs,menu) "$caption(foc,fenetre)" ; set panneau(Focs,centrage_fenetre) "2" }

         #--- Frame des entry & label
         frame $This.fra2.fra1 -borderwidth 1 -relief flat

            #--- Entry pour exptime
            entry $This.fra2.fra1.ent1 -font $audace(font,arial_8_b) -textvariable panneau(Focs,exptime) \
               -relief groove -width 6 -justify center
            pack $This.fra2.fra1.ent1 -in $This.fra2.fra1 -side left -fill none -padx 4 -pady 2

            #--- Label secondes
            label $This.fra2.fra1.lab1 -text $panneau(Focs,secondes) -relief flat
            pack $This.fra2.fra1.lab1 -in $This.fra2.fra1 -side left -fill none -padx 4 -pady 2

         pack $This.fra2.fra1 -in $This.fra2 -anchor center -fill none

         #--- Bouton GO
         button $This.fra2.but1 -borderwidth 2 -text $panneau(Focs,go) -command { ::Focs::cmdGo }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill x -padx 5 -pady 2 -ipadx 15 -ipady 1

         #--- Bouton STOP/RAZ
         button $This.fra2.but2 -borderwidth 2 -text $panneau(Focs,raz) -command { ::Focs::cmdStop }
         pack $This.fra2.but2 -in $This.fra2 -anchor center -fill x -padx 5 -pady 2 -ipadx 15 -ipady 1

      pack $This.fra2 -side top -fill x

      #--- Frame des boutons manuels
      frame $This.fra4 -borderwidth 1 -relief groove

         #--- Frame focuser
         ::confEqt::createFrameFocuserTool $This.fra4.focuser ::panneau(Focs,focuser)
         pack $This.fra4.focuser -in $This.fra4 -anchor nw -side top -padx 4 -pady 1

         #--- Label pour moteur focus
         label $This.fra4.lab1 -text $panneau(Focs,motorfoc) -relief flat
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
      bind $This.fra4.we.lab <ButtonPress-1> { ::Focs::cmdSpeed }

      #--- Cardinal moves
      bind $zone(moins) <ButtonPress-1>   { ::Focs::cmdFocus - }
      bind $zone(moins) <ButtonRelease-1> { ::Focs::cmdFocus stop }
      bind $zone(plus)  <ButtonPress-1>   { ::Focs::cmdFocus + }
      bind $zone(plus)  <ButtonRelease-1> { ::Focs::cmdFocus stop }

      #--- Frame de la position focus
      frame $This.fra5 -borderwidth 1 -relief groove

         #--- Label pour la position focus
         label $This.fra5.lab1 -text $panneau(Focs,position) -relief flat
         pack $This.fra5.lab1 -in $This.fra5 -anchor center -fill none -padx 4 -pady 1

         #--- Bouton "Se trouve à"
         button $This.fra5.but1 -borderwidth 2 -text $panneau(Focs,trouve) -command { ::Focs::cmdSetrouvea }
         pack $This.fra5.but1 -in $This.fra5 -anchor center -fill x -padx 5 -pady 2 -ipadx 15

         #--- Frame des labels
         frame $This.fra5.fra1 -borderwidth 1 -relief flat

            #--- Label pour nbpas1
            entry $This.fra5.fra1.lab1 -font $audace(font,arial_8_b) -textvariable audace(focus,nbpas1) \
               -relief groove -width 6 -state disabled
            pack $This.fra5.fra1.lab1 -in $This.fra5.fra1 -side left -fill none -padx 4 -pady 2

            #--- Label pas
            label $This.fra5.fra1.lab2 -text $panneau(Focs,pas) -relief flat
            pack $This.fra5.fra1.lab2 -in $This.fra5.fra1 -side left -fill none -padx 4 -pady 2

         pack $This.fra5.fra1 -in $This.fra5 -anchor center -fill none

         #--- Bouton "Aller à"
         button $This.fra5.but2 -borderwidth 2 -text $panneau(Focs,deplace) -command { ::Focs::cmdSedeplacea }
         pack $This.fra5.but2 -in $This.fra5 -anchor center -fill x -padx 5 -pady 2 -ipadx 15

         #--- Frame des entry & label
         frame $This.fra5.fra2 -borderwidth 1 -relief flat

            #--- Entry pour nbpas2
            entry $This.fra5.fra2.ent3 -font $audace(font,arial_8_b) -textvariable audace(focus,nbpas2) \
               -relief groove -width 6 -justify center
            pack $This.fra5.fra2.ent3 -in $This.fra5.fra2 -side left -fill none -padx 4 -pady 2
            bind $This.fra5.fra2.ent3 <Enter> { ::Focs::FormatFoc }
            bind $This.fra5.fra2.ent3 <Leave> { destroy $audace(base).formatfoc }

            #--- Label pas
            label $This.fra5.fra2.lab4 -text $panneau(Focs,pas) -relief flat
            pack $This.fra5.fra2.lab4 -in $This.fra5.fra2 -side left -fill none -padx 4 -pady 2

         pack $This.fra5.fra2 -in $This.fra5 -anchor center -fill none

         #--- Bouton "Initialisation"
         button $This.fra5.but3 -borderwidth 2 -text $panneau(Focs,initialise) -command { ::Focs::cmdInitfoc }
         pack $This.fra5.but3 -in $This.fra5 -anchor center -fill x -padx 5 -pady 2 -ipadx 15

      pack $This.fra5 -side top -fill x

      #--- Frame du graphe
      frame $This.fra3 -borderwidth 1 -relief groove

         #--- Bouton GRAPHE
         button $This.fra3.but1 -borderwidth 2 -text $panneau(Focs,graphe) -command { FocGraphe }
         pack $This.fra3.but1 -in $This.fra3 -side bottom -fill x -padx 5 -pady 5 -ipadx 15 -ipady 2

      pack $This.fra3 -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

