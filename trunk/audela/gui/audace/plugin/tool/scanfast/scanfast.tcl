#
# Fichier : scanfast.tcl
# Description : Outil pour l'acquisition en mode scan rapide
# Compatibilite : Montures LX200, AudeCom et Ouranos avec camera Audine (liaisons parallele, Audinet et EthernAude)
# Auteur : Alain KLOTZ
# Mise a jour $Id: scanfast.tcl,v 1.26 2007-04-20 21:29:06 robertdelmas Exp $
#

global panneau

set panneau(Scanfast,temps_mort) "0"

proc prescanfast { largpix hautpix dt { firstpix 1 } { bin 1 } } {
   #--- largpix  : Largeur de l'image (en pixels)
   #--- hautpix  : Hauteur de l'image (en pixels)
   #--- dt       : Temps d'integration interligne (en millisecondes)
   #--- firstpix : Indice du premier photosite de la largeur de l'image (commence a 1)
   #--- bin      : Binning du scan
   global audace caption panneau

   ::console::affiche_resultat "\n"
   ::console::affiche_resultat "$caption(scanfast,comment1)\n"
   ::console::affiche_resultat "\n"
   ::console::affiche_resultat "$caption(scanfast,comment2) [ expr int($hautpix*$dt*3/1000.) ] $caption(scanfast,secondes)\n"
   ::console::affiche_resultat "\n"
   ::console::affiche_resultat "$caption(scanfast,comment3)\n"
   cam$audace(camNo) scan $largpix $hautpix $bin 0 -firstpix $firstpix -fast 0 -tmpfile -biny $bin
   set tmort [ expr 1000.*[ lindex [ buf$audace(bufNo) getkwd DTEFF ] 1 ] ]
   ::console::affiche_resultat "   $caption(scanfast,comment4) = $tmort $caption(scanfast,ms/ligne)\n"
   set panneau(Scanfast,temps_mort) $tmort
   set dt0 [ expr $dt-$tmort ]
   if { $dt0 < "0" } {
      ::console::affiche_erreur "$caption(scanfast,comment5) dt=$dt $caption(scanfast,ms)\n"
      ::console::affiche_resultat "\n"
      ::console::disp "\n"
      return [ list 0 0 ]
   }
   ::console::affiche_resultat "\n"
   ::console::affiche_resultat "$caption(scanfast,comment6)\n"
   ::console::affiche_resultat "\n"
   set speed [ cam$audace(camNo) scanloop ]
   ::console::affiche_resultat "$caption(scanfast,iteration) 0 :\n"
   ::console::affiche_resultat "$caption(scanfast,comment7) [ expr int($hautpix*$dt/1000.) ] $caption(scanfast,secondes) $caption(scanfast,comment7a)\n"
   cam$audace(camNo) scan $largpix $hautpix $bin $dt0 -firstpix $firstpix -fast $speed -tmpfile -biny $bin
   set dteff [ lindex [ buf$audace(bufNo) getkwd DTEFF ] 1 ]
   ::console::affiche_resultat "   $caption(scanfast,comment8) = $speed ([ expr 1000*$dteff ] $caption(scanfast,ms/ligne))\n"
   set speed [ expr $dt/$dteff/1000.*$speed ];
   ::console::affiche_resultat "      $caption(scanfast,comment9) = $speed\n"
   ::console::affiche_resultat "\n"
   ::console::affiche_resultat "$caption(scanfast,iteration) 1 :\n"
   ::console::affiche_resultat "$caption(scanfast,comment7) [ expr int($hautpix*$dt/1000.) ] $caption(scanfast,secondes) $caption(scanfast,comment7a)\n"
   cam$audace(camNo) scan $largpix $hautpix $bin $dt0 -firstpix $firstpix -fast $speed -tmpfile -biny $bin
   set dteff [ lindex [ buf$audace(bufNo) getkwd DTEFF ] 1 ]
   ::console::affiche_resultat "   $caption(scanfast,comment8) = $speed ([ expr 1000*$dteff ] $caption(scanfast,ms/ligne))\n"
   set speed [ expr $dt/$dteff/1000.*$speed ];
   ::console::affiche_resultat "      $caption(scanfast,comment9) = $speed\n"
   ::console::affiche_resultat "\n"
   if { [ expr int($hautpix*$dt/1000.) ] < "20" } {
      ::console::affiche_resultat "$caption(scanfast,iteration) 2 :\n"
      ::console::affiche_resultat "$caption(scanfast,comment7) [ expr int($hautpix*$dt/1000.) ] $caption(scanfast,secondes) $caption(scanfast,comment7a)\n"
      cam$audace(camNo) scan $largpix $hautpix $bin $dt0 -firstpix $firstpix -fast $speed -tmpfile -biny $bin
      set dteff [ lindex [ buf$audace(bufNo) getkwd DTEFF ] 1 ]
      ::console::affiche_resultat "   $caption(scanfast,comment8) = $speed ([ expr 1000*$dteff ] $caption(scanfast,ms/ligne))\n"
      set speed [ expr $dt/$dteff/1000.*$speed ];
      ::console::affiche_resultat "      $caption(scanfast,comment9) = $speed\n"
      ::console::affiche_resultat "\n"
      ::console::affiche_resultat "$caption(scanfast,iteration) 3 :\n"
      ::console::affiche_resultat "$caption(scanfast,comment7) [ expr int($hautpix*$dt/1000.) ] $caption(scanfast,secondes) $caption(scanfast,comment7a)\n"
      cam$audace(camNo) scan $largpix $hautpix $bin $dt0 -firstpix $firstpix -fast $speed -tmpfile -biny $bin
      set dteff [ lindex [ buf$audace(bufNo) getkwd DTEFF ] 1 ]
      ::console::affiche_resultat "   $caption(scanfast,comment8) = $speed ([ expr 1000*$dteff ] $caption(scanfast,ms/ligne))\n"
      set speed [ expr $dt/$dteff/1000.*$speed ];
      ::console::affiche_resultat "      $caption(scanfast,comment9) = $speed\n"
      ::console::affiche_resultat "\n"
   }
   ::console::affiche_resultat "$caption(scanfast,comment10)\n"
   ::console::affiche_resultat "cam$audace(camNo) scan $largpix $hautpix $bin $dt0 -firstpix $firstpix -fast $speed -tmpfile -biny $bin \n"
   ::console::affiche_resultat "\n"
   ::console::disp "\n"
   return [ list $dt0 $speed ]
}

#============================================================
# Declaration du namespace Scanfast
#    initialise le namespace
#============================================================
namespace eval ::Scanfast {
   package provide scanfast 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] scanfast.cap ]

   #------------------------------------------------------------
   # getPluginTitle
   #    retourne le titre du plugin dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(scanfast,scanfast)"
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
         subfunction1 { return "scan" }
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
      global audace

      #--- Chargement des fichiers auxiliaires
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool scanfast scanfastSetup.tcl ]\""

      #--- Mise en place de l'interface graphique
      createPanel $in.scanfast
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
      global caption conf panneau

      #--- Initialisation du nom de la fenetre
      set This $this

      #--- Initialisation des captions
      set panneau(Scanfast,titre)           "$caption(scanfast,scanfast)"
      set panneau(Scanfast,aide)            "$caption(scanfast,help_titre)"
      set panneau(Scanfast,configuration)   "$caption(scanfast,configuration)"
      set panneau(Scanfast,col)             "$caption(scanfast,colonnes)"
      set panneau(Scanfast,lig)             "$caption(scanfast,lignes)"
      set panneau(Scanfast,interligne)      "$caption(scanfast,interligne)"
      set panneau(Scanfast,bin)             "$caption(scanfast,binning)"
      set panneau(Scanfast,calcul)          "$caption(scanfast,calcul)"
      set panneau(Scanfast,ms)              "$caption(scanfast,milliseconde)"
      set panneau(Scanfast,calib)           "$caption(scanfast,calibration)"
      set panneau(Scanfast,loops)           "$caption(scanfast,boucles)"
      set panneau(Scanfast,obturateur)      "$caption(scanfast,obt)"
      set panneau(Scanfast,acq)             "$caption(scanfast,acquisition)"
      set panneau(Scanfast,go0)             "$caption(scanfast,goccd)"
      set panneau(Scanfast,stop)            "$caption(scanfast,stop)"
      set panneau(Scanfast,go1)             "$caption(scanfast,en_cours)"
      set panneau(Scanfast,go2)             "$caption(scanfast,visu)"
      set panneau(Scanfast,go)              "$panneau(Scanfast,go0)"
      set panneau(Scanfast,attention)       "$caption(scanfast,attention)"
      set panneau(Scanfast,msg)             "$caption(scanfast,message)"
      set panneau(Scanfast,nom)             "$caption(scanfast,nom)"
      set panneau(Scanfast,extension)       "$caption(scanfast,extension)"
      set panneau(Scanfast,index)           "$caption(scanfast,index)"
      set panneau(Scanfast,sauvegarde)      "$caption(scanfast,sauvegarde)"
      set panneau(Scanfast,pb)              "$caption(scanfast,pb)"
      set panneau(Scanfast,nom_fichier)     "$caption(scanfast,nom_fichier)"
      set panneau(Scanfast,nom_blanc)       "$caption(scanfast,nom_blanc)"
      set panneau(Scanfast,mauvais_car)     "$caption(scanfast,mauvais_car)"
      set panneau(Scanfast,saisir_indice)   "$caption(scanfast,saisir_indice)"
      set panneau(Scanfast,indice_entier)   "$caption(scanfast,indice_entier)"
      set panneau(Scanfast,confirmation)    "$caption(scanfast,confirmation)"
      set panneau(Scanfast,fichier_existe)  "$caption(scanfast,fichier_existe)"
      set panneau(Scanfast,calcul_confirm)  "$caption(scanfast,calcul_confirm)"

      #--- Initialisation des variables
      set panneau(Scanfast,nom_image)       ""
      set panneau(Scanfast,extension_image) "$conf(extension,defaut)"
      set panneau(Scanfast,indexer)         "0"
      set panneau(Scanfast,indice)          "1"
      set panneau(Scanfast,acquisition)     "0"
      set panneau(Scan,Stop)                "0"

      #--- Construction de l'interface
      ScanfastBuildIF $This
   }

   proc Chargement_Var { } {
      variable parametres
      global audace

      #--- Ouverture du fichier de parametres
      set fichier [ file join $audace(rep_plugin) tool scanfast scanfast.ini ]
      if { [ file exists $fichier ] } {
         source $fichier
      }

      #--- Creation des variables si elles n'existent pas
      if { ! [ info exists parametres(Scanfast,col1) ] }       { set parametres(Scanfast,col1)       "1" }
      if { ! [ info exists parametres(Scanfast,col2) ] }       { set parametres(Scanfast,col2)       "768" }
      if { ! [ info exists parametres(Scanfast,lig1) ] }       { set parametres(Scanfast,lig1)       "1500" }
      if { ! [ info exists parametres(Scanfast,binning) ] }    { set parametres(Scanfast,binning)    "2x2" }
      if { ! [ info exists parametres(Scanfast,interligne) ] } { set parametres(Scanfast,interligne) "100" }
      if { ! [ info exists parametres(Scanfast,dt) ] }         { set parametres(Scanfast,dt)         "40" }
      if { ! [ info exists parametres(Scanfast,speed) ] }      { set parametres(Scanfast,speed)      "8000" }
      if { ! [ info exists parametres(Scanfast,obt) ] }        { set parametres(Scanfast,obt)        "2" }

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      ::scanfastSetup::initToConf
   }

   proc Enregistrement_Var { } {
      variable parametres
      global audace panneau

      #--- Changement de variables
      set parametres(Scanfast,col1)       $panneau(Scanfast,col1)
      set parametres(Scanfast,col2)       $panneau(Scanfast,col2)
      set parametres(Scanfast,lig1)       $panneau(Scanfast,lig1)
      set parametres(Scanfast,binning)    $panneau(Scanfast,binning)
      set parametres(Scanfast,interligne) $panneau(Scanfast,interligne)
      set parametres(Scanfast,dt)         $panneau(Scanfast,dt)
      set parametres(Scanfast,speed)      $panneau(Scanfast,speed)
      set parametres(Scanfast,obt)        $panneau(Scanfast,obt)

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

   proc Adapt_Outil_Scanfast { { a "" } { b "" } { c "" } } {
      variable This
      global conf panneau

      #--- Numero de la camera
      set camNo [ ::confVisu::getCamNo 1 ]

      #--- Configuration de l'obturateur
      if { $camNo != "0" } {
         if { ! [ info exists conf(audine,foncobtu) ] } {
            set conf(audine,foncobtu) "2"
         } else {
            if { $conf(audine,foncobtu) == "0" } {
               set panneau(Scanfast,obt) "0"
            } elseif { $conf(audine,foncobtu) == "1" } {
               set panneau(Scanfast,obt) "1"
            } elseif { $conf(audine,foncobtu) == "2" } {
               set panneau(Scanfast,obt) "2"
            }
         }
         pack $This.fra4.obt.but -side left -ipady 3
         pack $This.fra4.obt.lab1 -side left -fill x -expand true -ipady 3
         pack forget $This.fra4.obt.lab2
         $This.fra4.obt.lab1 configure -text $panneau(Scanfast,obt,$panneau(Scanfast,obt))
      } else {
         pack forget $This.fra4.obt.but
         pack forget $This.fra4.obt.lab1
         pack $This.fra4.obt.lab2 -side top -fill x -ipady 3
      }

      #--- Mise a jour de la liste des binnings disponibles
      $This.fra3.bin.but_bin.menu delete 0 20
      set list_binning_scan [ ::confCam::getBinningList_Scan $camNo ]
      foreach valbin $list_binning_scan {
         $This.fra3.bin.but_bin.menu add radiobutton -label "$valbin" \
            -indicatoron "1" \
            -value "$valbin" \
            -variable panneau(Scanfast,binning) \
            -command " "
      }

      #--- Binnings associes aux liaisons
      switch [ ::confLink::getLinkNamespace $conf(audine,port) ] {
         ethernaude {
            pack forget $This.fra33
            pack $This.fra4 -side top -fill x
            pack forget $This.fra4.but2
            pack $This.fra4.but2 -anchor center -fill x -padx 5 -pady 5 -ipadx 15 -ipady 3
            pack $This.fra5 -side top -fill x
            if { $panneau(Scanfast,binning) == "4x4" } {
               set panneau(Scanfast,binning) "2x2"
            }
         }
         audinet {
            pack forget $This.fra33
            pack $This.fra4 -side top -fill x
            pack forget $This.fra4.but2
            pack $This.fra4.but2 -anchor center -fill x -padx 5 -pady 5 -ipadx 15 -ipady 3
            pack $This.fra5 -side top -fill x
            #--- C'est bon, on ne fait rien pour le binning
         }
         parallelport {
            pack $This.fra33 -side top -fill x
            pack forget $This.fra4
            pack $This.fra4 -side top -fill x
            pack forget $This.fra4.but2
            pack forget $This.fra5
            pack $This.fra5 -side top -fill x
            #--- C'est bon, on ne fait rien pour le binning
         }
         default {
            set panneau(Scanfast,binning) "1x1"
         }
      }
   }

   #------------------------------------------------------------
   # startTool
   #    affiche la fenetre de l'outil
   #------------------------------------------------------------
   proc startTool { visuNo } {
      variable This
      variable parametres
      global caption panneau

      #--- Chargement de la configuration
      ::Scanfast::Chargement_Var

      #--- Initialisation des variables de l'outil
      set panneau(Scanfast,col1)       "$parametres(Scanfast,col1)"
      set panneau(Scanfast,col2)       "$parametres(Scanfast,col2)"
      set panneau(Scanfast,lig1)       "$parametres(Scanfast,lig1)"
      set panneau(Scanfast,binning)    "$parametres(Scanfast,binning)"
      set panneau(Scanfast,interligne) "$parametres(Scanfast,interligne)"
      set panneau(Scanfast,dt)         "$parametres(Scanfast,dt)"
      set panneau(Scanfast,speed)      "$parametres(Scanfast,speed)"
      set panneau(Scanfast,obt)        "$parametres(Scanfast,obt)"

      #--- Initialisation des variables de la boite de configuration
      ::scanfastSetup::confToWidget

      #--- Entrer ici les valeurs pour l'obturateur a afficher dans le menu "obt"
      set panneau(Scanfast,obt,0) "$caption(scanfast,obtu_ouvert)"
      set panneau(Scanfast,obt,1) "$caption(scanfast,obtu_ferme)"
      set panneau(Scanfast,obt,2) "$caption(scanfast,obtu_synchro)"

      #--- Configuration dynamique de l'outil en fonction de la liaison
      ::Scanfast::Adapt_Outil_Scanfast
      ::confVisu::addCameraListener 1 ::Scanfast::Adapt_Outil_Scanfast
      trace add variable ::conf(audine,port) write ::Scanfast::Adapt_Outil_Scanfast

      #---
      pack $This -side left -fill y
   }

   #------------------------------------------------------------
   # stopTool
   #    masque la fenetre de l'outil
   #------------------------------------------------------------
   proc stopTool { visuNo } {
      variable This

      #--- Sauvegarde de la configuration
      ::Scanfast::Enregistrement_Var

      #--- Arret de la surveillance
      ::confVisu::removeCameraListener 1 ::Scanfast::Adapt_Outil_Scanfast
      trace remove variable ::conf(audine,port) write ::Scanfast::Adapt_Outil_Scanfast

      #---
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
      global audace caption conf panneau

      if { [ ::cam::list ] != "" } {
         if { [ ::confCam::hasScan $audace(camNo) ] == "1" } {
            #--- Initialisation des variables
            set panneau(Scanfast,acquisition) "1"
            set panneau(Scan,Stop)            "0"

            #--- La premiere colonne (firstpix) ne peut pas etre inferieure a 1
            if { $panneau(Scanfast,col1) < "1" } {
               set panneau(Scanfast,col1) "1"
            }

            #--- Gestion graphique du bouton GO CCD
            $This.fra4.but1 configure -relief groove -text $panneau(Scanfast,go1) -state disabled
            update

            #--- Gestion graphique du bouton STOP - Inactif avant le debut du scan
            $This.fra4.but2 configure -relief groove -text $panneau(Scanfast,stop) -state disabled
            update

            #--- Definition du binning
            set bin 4
            if { $panneau(Scanfast,binning) == "4x4" } { set bin 4 }
            if { $panneau(Scanfast,binning) == "2x2" } { set bin 2 }
            if { $panneau(Scanfast,binning) == "1x1" } { set bin 1 }

            #--- Definition des parametres du scan (w : largeur - h : hauteur - f : firstpix)
            set w [ ::Scanfast::int [ expr $panneau(Scanfast,col2) - $panneau(Scanfast,col1) + 1 ] ]
            set h [ ::Scanfast::int $panneau(Scanfast,lig1) ]
            set f [ ::Scanfast::int $panneau(Scanfast,col1) ]
            if { $panneau(Scanfast,temps_mort) == "0" } {
               set temps_mort "20" ; #--- Estimation du temps mort a 20 ms par ligne
            } else {
               set temps_mort $panneau(Scanfast,temps_mort)
            }
            set duree [ expr ($panneau(Scanfast,dt)+$temps_mort)*$h/1000./86400. ]

            #--- Gestion du moteur d'A.D.
            if { $motor == "motoroff" } {
               if { [ ::tel::list ] != "" } {
                  #--- Arret du moteur d'AD
                  tel$audace(telNo) radec motor off
               }
            }

            #--- Attente du demarrage du scan
            if { $panneau(Scanfast,active) == "1" } {
               #--- Decompte du temps d'attente
               set attente $panneau(Scanfast,delai)
               if { $panneau(Scanfast,delai) > "0" } {
                  while { $panneau(Scanfast,delai) > "0" } {
                     ::camera::Avancement_scan "-10" $panneau(Scanfast,lig1) $panneau(Scanfast,delai)
                     update
                     after 1000
                     incr panneau(Scanfast,delai) "-1"
                  }
               }
               set panneau(Scanfast,delai) $attente
            }

            #--- Gestion graphique du bouton STOP - Devient actif avec le debut du scan
            $This.fra4.but2 configure -relief raised -text $panneau(Scanfast,stop) -state normal
            update

            #--- Declenchement de l'acquisition
            if { [ ::confLink::getLinkNamespace $conf(audine,port) ] == "parallelport" } {
               #--- Destruction de la fenetre indiquant l'attente
               if [ winfo exists $audace(base).progress_scan ] {
                  destroy $audace(base).progress_scan
               }
               #--- Calcul de l'heure TU de debut et de l'heure TU previsionnelle de fin du scan
               set date_beg [ ::audace::date_sys2ut now ]
               set sec [ expr int(floor([ lindex $date_beg 5 ])) ]
               set date_beg [ lreplace $date_beg 5 5 $sec ]
               set date_beg1 [ format "%02d/%02d/%2s %02d:%02d:%02.0f $caption(scanfast,tempsuniversel)" [ lindex $date_beg 2 ] [ lindex $date_beg 1 ] [ string range [ lindex $date_beg 0 ] 2 3 ] [ lindex $date_beg 3 ] [ lindex $date_beg 4 ] [ lindex $date_beg 5 ] ]
               set date_end [ mc_date2ymdhms [ mc_datescomp $date_beg + $duree ] ]
               set sec [ expr int(floor([ lindex $date_end 5 ])) ]
               set date_end [ lreplace $date_end 5 5 $sec ]
               set date_end1 [ format "%02d/%02d/%2s %02d:%02d:%02.0f $caption(scanfast,tempsuniversel)" [ lindex $date_end 2 ] [ lindex $date_end 1 ] [ string range [ lindex $date_end 0 ] 2 3 ] [ lindex $date_end 3 ] [ lindex $date_end 4 ] [ lindex $date_end 5 ] ]
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
               wm geometry $audace(base).wintimeaudace +[ expr $posx_wintimeaudace + 350 ]+[ expr $posy_wintimeaudace + 75 ]
               label $audace(base).wintimeaudace.lab_beg -text "\n$caption(scanfast,debut) $date_beg1"
               pack $audace(base).wintimeaudace.lab_beg -padx 10 -pady 5
               label $audace(base).wintimeaudace.lab_end -text "$caption(scanfast,fin) $date_end1\n"
               pack $audace(base).wintimeaudace.lab_end -padx 10 -pady 5
               #--- Mise a jour dynamique des couleurs
               ::confColor::applyColor $audace(base).wintimeaudace
               #--- Focus
               update
               focus $audace(base).wintimeaudace
               #--- Declenchement de l'acquisition
               cam$audace(camNo) scan $w $h $bin $panneau(Scanfast,dt) -firstpix $f -fast $panneau(Scanfast,speed) -tmpfile -biny $bin
            } else {
               #--- Calcul du nombre de lignes par seconde
               set panneau(Scanfast,nblg1) [ expr 1000./$panneau(Scanfast,interligne) ]
               set panneau(Scanfast,nblg)  [ expr int($panneau(Scanfast,nblg1)) + 1 ]
               #--- Declenchement de l'acquisition
               cam$audace(camNo) scan $w $h $bin $panneau(Scanfast,interligne) -firstpix $f -tmpfile -biny $bin
               #--- Alarme sonore de fin de pose
               set pseudoexptime [ expr $panneau(Scanfast,lig1)/$panneau(Scanfast,nblg1) ]
               ::camera::alarme_sonore $pseudoexptime
               #--- Appel du timer
               if { $panneau(Scanfast,lig1) > "$panneau(Scanfast,nblg)" } {
                  set t [ expr $panneau(Scanfast,lig1)/$panneau(Scanfast,nblg1) ]
                  ::camera::dispLine $t $panneau(Scanfast,nblg1) $panneau(Scanfast,lig1) $panneau(Scanfast,delai)
               }
               #--- Attente de la fin de la pose
               vwait scan_result$audace(camNo)
               #--- Destruction de la fenetre d'avancement du scan
               if [ winfo exists $audace(base).progress_scan ] {
                  destroy $audace(base).progress_scan
               }
            }

            #--- Gestion graphique du bouton GO CCD
            $This.fra4.but1 configure -relief groove -text $panneau(Scanfast,go2) -state disabled
            update

            #--- Visualisation de l'image
            ::audace::autovisu $audace(visuNo)

            #--- Destruction de la fenetre d'affichage des heures de debut et de fin du scan
            destroy $audace(base).wintimeaudace

            #--- Gestion du moteur d'A.D.
            if { $motor == "motoroff" } {
               if { [ ::tel::list ] != "" } {
                  #--- Remise en marche moteur A.D. LX200
                  tel$audace(telNo) radec motor on
               }
            }

            #--- Gestion graphique du bouton GO CCD
            set panneau(Scanfast,acquisition) "0"
            $This.fra4.but1 configure -relief raised -text $panneau(Scanfast,go0) -state normal
            update
         } else {
            tk_messageBox -title $panneau(Scanfast,attention) -type ok -message $panneau(Scanfast,msg)
         }
      } else {
         ::confCam::run
         tkwait window $audace(base).confCam
      }
   }

   proc cmdStop { } {
      variable This
      global audace panneau

      if { [ ::cam::list ] != "" } {
         if { $panneau(Scanfast,acquisition) == "1" } {
            catch {
               #--- Changement de la valeur de la variable
               set panneau(Scan,Stop) "1"

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
               $This.fra4.but1 configure -relief raised -text $panneau(Scanfast,go1) -state disabled
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
      global audace panneau

      if { [ ::cam::list ] != "" } {
         $This.fra33.but1 configure -relief groove -state disabled
         update

         #--- La premiere colonne (firstpix) ne peut pas etre inferieure a 1
         if { $panneau(Scanfast,col1) < "1" } {
            set panneau(Scanfast,col1) "1"
         }

         #---
         if { $panneau(Scanfast,binning) == "4x4" } { set bin 4 }
         if { $panneau(Scanfast,binning) == "2x2" } { set bin 2 }
         if { $panneau(Scanfast,binning) == "1x1" } { set bin 1 }
         set w [ ::Scanfast::int [ expr ( $panneau(Scanfast,col2) - $panneau(Scanfast,col1) + 1 ) / $bin ] ]
         set h [ ::Scanfast::int $panneau(Scanfast,lig1) ]
         set f [ ::Scanfast::int [ expr $panneau(Scanfast,col1) / $bin ] ]
         set results [ prescanfast $w $h $panneau(Scanfast,interligne) $f $bin ]
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
      global audace conf panneau

      if { [ ::cam::list ] != "" } {
         set parametres(Scanfast,col2) "[ lindex [ cam$audace(camNo) nbcells ] 0 ]"
         set panneau(Scanfast,col2)    "$parametres(Scanfast,col2)"
         $This.fra2.fra1.ent2 configure -textvariable panneau(Scanfast,col2)
         update
      }
      if { $conf(audine,port) == "LPT1:" } {
         set choix [ tk_messageBox -type yesno -icon warning -title "$panneau(Scanfast,calcul)" \
            -message "$panneau(Scanfast,calcul_confirm)" ]
         if { $choix == "yes" } {
            ::Scanfast::cmdCalcul
         }
      } elseif { $conf(audine,port) == "LPT2:" } {
         set choix [ tk_messageBox -type yesno -icon warning -title "$panneau(Scanfast,calcul)" \
            -message "$panneau(Scanfast,calcul_confirm)" ]
         if { $choix == "yes" } {
            ::Scanfast::cmdCalcul
         }
      } elseif { $conf(audine,port) == "LPT3:" } {
         set choix [ tk_messageBox -type yesno -icon warning -title "$panneau(Scanfast,calcul)" \
            -message "$panneau(Scanfast,calcul_confirm)" ]
         if { $choix == "yes" } {
            ::Scanfast::cmdCalcul
         }
      }
   }

   proc changeObt { } {
      variable This
      global audace caption confCam frmm panneau

      if { [ ::cam::list ] != "" } {
         #---
         set camNo      $audace(camNo)
         set camProduct [ cam$camNo product ]
         #---
         set ShutterOptionList    [ ::confCam::getShutterOption $camNo ]
         set lg_ShutterOptionList [ llength $ShutterOptionList ]
         #---
         if { [ ::confCam::hasShutter $camNo ] } {
            incr panneau(Scanfast,obt)
            if { $lg_ShutterOptionList == "3" } {
               if { $panneau(Scanfast,obt) == "3" } {
                  set panneau(Scanfast,obt) "0"
               }
            } elseif { $lg_ShutterOptionList == "2" } {
               if { $panneau(Scanfast,obt) == "3" } {
                  set panneau(Scanfast,obt) "1"
               }
            }
            $This.fra4.obt.lab1 configure -text $panneau(Scanfast,obt,$panneau(Scanfast,obt))
            if { "$camProduct" == "audine" } {
               set conf(audine,foncobtu) $panneau(Scanfast,obt)
               catch { set frm $frmm(Camera1) }
            }
            #---
            switch -exact -- $panneau(Scanfast,obt) {
               0  {
                  set confCam(audine,foncobtu) $caption(scanfast,obtu_ouvert)
                  catch {
                     $frm.foncobtu configure -height [ llength $ShutterOptionList ]
                     $frm.foncobtu configure -values $ShutterOptionList
                  }
                  cam$camNo shutter "opened"
               }
               1  {
                  set confCam(audine,foncobtu) $caption(scanfast,obtu_ferme)
                  catch {
                     $frm.foncobtu configure -height [ llength $ShutterOptionList ]
                     $frm.foncobtu configure -values $ShutterOptionList
                  }
                  cam$camNo shutter "closed"
               }
               2  {
                  set confCam(audine,foncobtu) $caption(scanfast,obtu_synchro)
                  catch {
                     $frm.foncobtu configure -height [ llength $ShutterOptionList ]
                     $frm.foncobtu configure -values $ShutterOptionList
                  }
                  cam$camNo shutter "synchro"
               }
            }
         } else {
            tk_messageBox -title $caption(scanfast,pb) -type ok \
               -message $caption(scanfast,onlycam+obt)
         }
      } else {
         ::confCam::run
         tkwait window $audace(base).confCam
      }
   }

   #--- Cette procedure verifie que la chaine passee en argument decrit bien un entier
   #--- Elle retourne 1 si c'est la cas, et 0 si ce n'est pas un entier
   proc TestEntier { valeur } {
      set test 1
      for { set i 0 } { $i < [ string length $valeur ] } { incr i } {
         set a [string index $valeur $i]
         if { ![string match {[0-9]} $a] } {
            set test 0
         }
      }
      if { $valeur == "" } { set test 0 }
      return $test
   }

   #--- Cette procedure verifie que la chaine passee en argument ne contient que des caracteres valides
   #--- Elle retourne 1 si c'est la cas, et 0 si ce n'est pas valable
   proc TestChaine { valeur } {
      set test 1
      for { set i 0 } { $i < [ string length $valeur ] } { incr i } {
         set a [ string index $valeur $i ]
         if { ![string match {[-a-zA-Z0-9_]} $a] } {
            set test 0
         }
      }
      return $test
   }

   proc SauveUneImage { } {
      global audace panneau

      #--- Enregistrer l'extension des fichiers
      set ext [ buf[ ::confVisu::getBufNo 1 ] extension ]

      #--- Tests d'integrite de la requete

      #--- Verifier qu'il y a bien un nom de fichier
      if { $panneau(Scanfast,nom_image) == "" } {
         tk_messageBox -title $panneau(Scanfast,pb) -type ok \
            -message $panneau(Scanfast,nom_fichier)
         return
      }

      #--- Verifier que le nom de fichier n'a pas d'espace
      if { [ llength $panneau(Scanfast,nom_image) ] > "1" } {
         tk_messageBox -title $panneau(Scanfast,pb) -type ok \
            -message $panneau(Scanfast,nom_blanc)
         return
      }

      #--- Verifier que le nom de fichier ne contient pas de caracteres interdits
      if { [ ::Scanfast::TestChaine $panneau(Scanfast,nom_image) ] == "0" } {
         tk_messageBox -title $panneau(Scanfast,pb) -type ok \
            -message $panneau(Scanfast,mauvais_car)
         return
      }

      #--- Si la case index est cochee, verifier qu'il y a bien un index
      if { $panneau(Scanfast,indexer) == "1" } {
         #--- Verifier que l'index existe
         if { $panneau(Scanfast,indice) == "" } {
            tk_messageBox -title $panneau(Scanfast,pb) -type ok \
               -message $panneau(Scanfast,saisir_indice)
            return
         }
         #--- Verifier que l'index est bien un nombre entier
         if { [ ::Scanfast::TestEntier $panneau(Scanfast,indice) ] == "0" } {
            tk_messageBox -title $panneau(Scanfast,pb) -type ok \
               -message $panneau(Scanfast,indice_entier)
            return
         }
      }

      #--- Generer le nom du fichier
      set nom $panneau(Scanfast,nom_image)

      #--- Pour eviter un nom de fichier qui commence par un blanc
      set nom [ lindex $nom 0 ]
      if { $panneau(Scanfast,indexer) == "1" } {
         append nom $panneau(Scanfast,indice)
      }

      #--- Verifier que le nom du fichier n'existe pas deja
      set nom1 "$nom"
      append nom1 $ext
      if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
         #--- Dans ce cas, le fichier existe deja
         set confirmation [ tk_messageBox -title $panneau(Scanfast,confirmation) -type yesno \
            -message $panneau(Scanfast,fichier_existe) ]
         if { $confirmation == "no" } {
            return
         }
      }

      #--- Incrementer l'index
      if { $panneau(Scanfast,indexer) == "1" } {
         if { [ buf$audace(bufNo) imageready ] != "0" } {
            incr panneau(Scanfast,indice)
         } else {
            #--- Sortir immediatement s'il n'y a pas d'image dans le buffer
            return
         }
      }

      #--- Sauvegarder l'image
      saveima $nom
   }

}

#------------------------------------------------------------
# ScanfastBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc ScanfastBuildIF { This } {
   global audace panneau

   #--- Frame de l'outil
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra0 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra0.but -borderwidth 1 -text $panneau(Scanfast,titre) \
            -command "::audace::showHelpPlugin tool scanfast scanfast.htm"
         pack $This.fra0.but -in $This.fra0 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra0.but -text $panneau(Scanfast,aide)

      pack $This.fra0 -side top -fill x

      #--- Frame du bouton de configuration
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du bouton Configuration
         button $This.fra1.but -borderwidth 1 -text $panneau(Scanfast,configuration) \
            -command { ::scanfastSetup::run $audace(base).scanfastSetup }
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5

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

         pack $This.fra2.fra1 -in $This.fra2 -anchor center -fill none

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
         label $This.fra3.lab1 -text $panneau(Scanfast,interligne) -relief flat
         pack $This.fra3.lab1 -in $This.fra3 -anchor center -fill none -padx 4 -pady 1

         #--- Frame pour binning
         frame $This.fra3.bin -borderwidth 0 -relief groove

            #--- Menu pour binning
            menubutton $This.fra3.bin.but_bin -text $panneau(Scanfast,bin) -menu $This.fra3.bin.but_bin.menu -relief raised
            pack $This.fra3.bin.but_bin -in $This.fra3.bin -side left -fill none
            set m [ menu $This.fra3.bin.but_bin.menu -tearoff 0 ]
            foreach valbin [ ::confCam::getBinningList_Scan [ ::confVisu::getCamNo 1 ] ] {
               $m add radiobutton -label "$valbin" \
                  -indicatoron "1" \
                  -value "$valbin" \
                  -variable panneau(Scanfast,binning) \
                  -command " "
            }

            #--- Entry pour binning
            entry $This.fra3.bin.lab_bin -width 2 -font {arial 10 bold} -relief groove \
              -textvariable panneau(Scanfast,binning) -justify center -state disabled
            pack $This.fra3.bin.lab_bin -in $This.fra3.bin -side left -fill both -expand true

         pack $This.fra3.bin -anchor n -fill x -expand 0 -pady 2

         #--- Frame des entry & label
         frame $This.fra3.fra1 -borderwidth 1 -relief flat

            #--- Entry pour les millisecondes
            entry $This.fra3.fra1.ent1 -font $audace(font,arial_8_b) -textvariable panneau(Scanfast,interligne) \
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
            -command "::Scanfast::cmdCalcul"
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

         #--- Frame de l'obturateur
         frame $This.fra4.obt -borderwidth 2 -relief ridge -width 16

            #--- Bouton de changement d'etat de l'obturateur
            button $This.fra4.obt.but -text $panneau(Scanfast,obturateur) -command "::Scanfast::changeObt" \
               -state normal
            pack $This.fra4.obt.but -side left -ipady 3

            #--- Label pour l'etat de l'obturateur
            label $This.fra4.obt.lab1 -text "" -width 6 -font $audace(font,arial_10_b) -relief groove
            pack $This.fra4.obt.lab1 -side left -fill x -expand true -ipady 3

            #--- Label avant la connexion de la camera
            label $This.fra4.obt.lab2 -text "" -font $audace(font,arial_10_b) -relief ridge -justify center
            pack $This.fra4.obt.lab2 -side top -fill x -ipady 3

         pack $This.fra4.obt -side top -fill x

         #--- Label pour l'acquisition
         label $This.fra4.lab1 -text $panneau(Scanfast,acq) -relief flat
         pack $This.fra4.lab1 -in $This.fra4 -anchor center -fill none -padx 4 -pady 1

         #--- Bouton GO
         button $This.fra4.but1 -borderwidth 2 -text $panneau(Scanfast,go) \
            -command "::Scanfast::cmdGo motoroff"
         pack $This.fra4.but1 -in $This.fra4 -anchor center -fill x -padx 5 -ipadx 10 -ipady 3

         #--- Bouton STOP
         button $This.fra4.but2 -borderwidth 2 -text $panneau(Scanfast,stop) \
            -command "::Scanfast::cmdStop"
         pack $This.fra4.but2 -in $This.fra4 -anchor center -fill x -padx 5 -pady 5 -ipadx 15 -ipady 3

      pack $This.fra4 -side top -fill x

      #--- Frame de la sauvegarde de l'image
      frame $This.fra5 -borderwidth 1 -relief groove

         #--- Frame du nom de l'image
         frame $This.fra5.nom -relief ridge -borderwidth 2

            #--- Label du nom de l'image
            label $This.fra5.nom.lab1 -text $panneau(Scanfast,nom) -pady 0
            pack $This.fra5.nom.lab1 -fill x -side top

            #--- Entry du nom de l'image
            entry $This.fra5.nom.ent1 -width 10 -textvariable panneau(Scanfast,nom_image) \
               -font $audace(font,arial_10_b) -relief groove
            pack $This.fra5.nom.ent1 -fill x -side top

            #--- Label de l'extension
            label $This.fra5.nom.lab_extension -text $panneau(Scanfast,extension) -pady 0
            pack $This.fra5.nom.lab_extension -fill x -side left

            #--- Button pour le choix de l'extension
            button $This.fra5.nom.extension -textvariable panneau(Scanfast,extension_image) \
               -width 7 -command "::confFichierIma::run $audace(base).confFichierIma"
            pack $This.fra5.nom.extension -side right -fill x

         pack $This.fra5.nom -side top -fill x

         #--- Frame de l'index
         frame $This.fra5.index -relief ridge -borderwidth 2

            #--- Checkbutton pour le choix de l'indexation
            checkbutton $This.fra5.index.case -pady 0 -text $panneau(Scanfast,index) -variable panneau(Scanfast,indexer)
            pack $This.fra5.index.case -side top -fill x

            #--- Entry de l'index
            entry $This.fra5.index.ent2 -width 3 -textvariable panneau(Scanfast,indice) \
               -font $audace(font,arial_10_b) -relief groove -justify center
            pack $This.fra5.index.ent2 -side left -fill x -expand true

            #--- Bouton de mise a 1 de l'index
            button $This.fra5.index.but1 -text "1" -width 3 \
               -command "set panneau(Scanfast,indice) 1"
            pack $This.fra5.index.but1 -side right -fill x

         pack $This.fra5.index -side top -fill x

         #--- Bouton pour sauvegarder l'image
         button $This.fra5.but_sauve -text $panneau(Scanfast,sauvegarde) -command "::Scanfast::SauveUneImage"
         pack $This.fra5.but_sauve -side top -fill x

      pack $This.fra5 -side top -fill x

      bind $This.fra4.but1 <ButtonPress-3> { ::Scanfast::cmdGo motoron }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

