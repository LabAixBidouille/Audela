#
# Fichier : scan.tcl
# Description : Outil pour l'acquisition en mode drift scan
# Compatibilite : Montures LX200, AudeCom et Ouranos avec camera Audine (liaisons parallele, Audinet et EthernAude)
# Auteur : Alain KLOTZ
# Mise a jour $Id: scan.tcl,v 1.28 2007-05-26 17:55:55 robertdelmas Exp $
#

#============================================================
# Declaration du namespace dscan
#    initialise le namespace
#============================================================
namespace eval ::dscan {
   package provide scan 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] scan.cap ]

   #------------------------------------------------------------
   # getPluginTitle
   #    retourne le titre du plugin dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(scan,drift_scan)"
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
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool scan scanSetup.tcl ]\""

      #--- Mise en place de l'interface graphique
      createPanel $in.dscan
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
      set panneau(dscan,titre)           "$caption(scan,drift_scan)"
      set panneau(dscan,aide)            "$caption(scan,help_titre)"
      set panneau(dscan,configuration)   "$caption(scan,configuration)"
      set panneau(dscan,col)             "$caption(scan,colonnes)"
      set panneau(dscan,lig)             "$caption(scan,lignes)"
      set panneau(dscan,pixel)           "$caption(scan,pixel)"
      set panneau(dscan,unite)           "$caption(scan,micron)"
      set panneau(dscan,interlig)        "$caption(scan,interligne)"
      set panneau(dscan,bin)             "$caption(scan,binning)"
      set panneau(dscan,focale)          "$caption(scan,focale)"
      set panneau(dscan,metres)          "$caption(scan,metre)"
      set panneau(dscan,declinaison)     "$caption(scan,declinaison)"
      set panneau(dscan,calcul)          "$caption(scan,calcul)"
      set panneau(dscan,ms)              "$caption(scan,milliseconde)"
      set panneau(dscan,obturateur)      "$caption(scan,obt)"
      set panneau(dscan,acq)             "$caption(scan,acquisition)"
      set panneau(dscan,go0)             "$caption(scan,goccd)"
      set panneau(dscan,stop)            "$caption(scan,stop)"
      set panneau(dscan,go1)             "$caption(scan,en_cours)"
      set panneau(dscan,go2)             "$caption(scan,visu)"
      set panneau(dscan,go)              "$panneau(dscan,go0)"
      set panneau(dscan,attention)       "$caption(scan,attention)"
      set panneau(dscan,msg)             "$caption(scan,message)"
      set panneau(dscan,nom)             "$caption(scan,nom)"
      set panneau(dscan,extension)       "$caption(scan,extension)"
      set panneau(dscan,index)           "$caption(scan,index)"
      set panneau(dscan,sauvegarde)      "$caption(scan,sauvegarde)"
      set panneau(dscan,pb)              "$caption(scan,pb)"
      set panneau(dscan,nom_fichier)     "$caption(scan,nom_fichier)"
      set panneau(dscan,nom_blanc)       "$caption(scan,nom_blanc)"
      set panneau(dscan,mauvais_car)     "$caption(scan,mauvais_car)"
      set panneau(dscan,saisir_indice)   "$caption(scan,saisir_indice)"
      set panneau(dscan,indice_entier)   "$caption(scan,indice_entier)"
      set panneau(dscan,confirmation)    "$caption(scan,confirmation)"
      set panneau(dscan,fichier_existe)  "$caption(scan,fichier_existe)"

      #--- Initialisation des variables
      set panneau(dscan,nom_image)       ""
      set panneau(dscan,extension_image) "$conf(extension,defaut)"
      set panneau(dscan,indexer)         "0"
      set panneau(dscan,indice)          "1"
      set panneau(dscan,acquisition)     "0"
      set panneau(Scan,Stop)             "0"

      #--- Construction de l'interface
      dscanBuildIF $This
   }

   proc chargementVar { } {
      variable parametres
      global audace

      #--- Ouverture du fichier de parametres
      set fichier [ file join $audace(rep_plugin) tool scan scan.ini ]
      if { [ file exists $fichier ] } {
         source $fichier
      }

      #--- Creation des variables si elles n'existent pas
      if { ! [ info exists parametres(dscan,col1) ] }     { set parametres(dscan,col1)     "1" }
      if { ! [ info exists parametres(dscan,col2) ] }     { set parametres(dscan,col2)     "768" }
      if { ! [ info exists parametres(dscan,lig1) ] }     { set parametres(dscan,lig1)     "1500" }
      if { ! [ info exists parametres(dscan,dimpix) ] }   { set parametres(dscan,dimpix)   "9.0" }
      if { ! [ info exists parametres(dscan,binning) ] }  { set parametres(dscan,binning)  "2x2" }
      if { ! [ info exists parametres(dscan,binningX) ] } { set parametres(dscan,binningX) "2" }
      if { ! [ info exists parametres(dscan,binningY) ] } { set parametres(dscan,binningY) "2" }
      if { ! [ info exists parametres(dscan,foc) ] }      { set parametres(dscan,foc)      ".85" }
      if { ! [ info exists parametres(dscan,dec) ] }      { set parametres(dscan,dec)      "0d" }
      if { ! [ info exists parametres(dscan,obt) ] }      { set parametres(dscan,obt)      "2" }

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      ::scanSetup::initToConf
   }

   proc enregistrementVar { } {
      variable parametres
      global audace panneau

      #--- Changement de variables
      set parametres(dscan,col1)     $panneau(dscan,col1)
      set parametres(dscan,col2)     $panneau(dscan,col2)
      set parametres(dscan,lig1)     $panneau(dscan,lig1)
      set parametres(dscan,dimpix)   $panneau(dscan,pix)
      set parametres(dscan,binning)  $panneau(dscan,binning)
      set parametres(dscan,binningX) $panneau(dscan,binningX)
      set parametres(dscan,binningY) $panneau(dscan,binningY)
      set parametres(dscan,foc)      $panneau(dscan,foc)
      set parametres(dscan,dec)      $panneau(dscan,dec)
      set parametres(dscan,obt)      $panneau(dscan,obt)

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

   proc adaptOutilScan { { a "" } { b "" } { c "" } } {
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
               set panneau(dscan,obt) "0"
            } elseif { $conf(audine,foncobtu) == "1" } {
               set panneau(dscan,obt) "1"
            } elseif { $conf(audine,foncobtu) == "2" } {
               set panneau(dscan,obt) "2"
            }
         }
         pack $This.fra4.obt.but -side left -ipady 3
         pack $This.fra4.obt.lab1 -side left -fill x -expand true -ipady 3
         pack forget $This.fra4.obt.lab2
         $This.fra4.obt.lab1 configure -text $panneau(dscan,obt,$panneau(dscan,obt))
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
            -variable panneau(dscan,binning) \
            -command "::dscan::cmdCalcul"
      }

      #--- Binnings associes aux liaisons
      switch [ ::confLink::getLinkNamespace $conf(audine,port) ] {
         ethernaude {
            #--- Mise en forme de la frame
            pack $This.fra3.lab1 -in $This.fra3 -anchor center -fill none
            pack forget $This.fra3.bin
            pack $This.fra3.binEthernAude -in $This.fra3 -anchor n -fill x -expand 0 -pady 2
            pack $This.fra3.fra2 -in $This.fra3 -anchor center -fill none
            pack $This.fra3.fra3 -in $This.fra3 -anchor center -fill none
            pack $This.fra3.but1 -in $This.fra3 -anchor center -fill none -pady 1 -ipadx 13
            pack $This.fra3.fra1 -in $This.fra3 -anchor center -fill none
            #--- C'est bon, on ne fait rien pour le binning
         }
         audinet {
            #--- Mise en forme de la frame
            pack $This.fra3.lab1 -in $This.fra3 -anchor center -fill none
            pack $This.fra3.bin -in $This.fra3 -anchor n -fill x -expand 0 -pady 2
            pack forget $This.fra3.binEthernAude
            pack $This.fra3.fra2 -in $This.fra3 -anchor center -fill none
            pack $This.fra3.fra3 -in $This.fra3 -anchor center -fill none
            pack $This.fra3.but1 -in $This.fra3 -anchor center -fill none -pady 1 -ipadx 13
            pack $This.fra3.fra1 -in $This.fra3 -anchor center -fill none
            #--- C'est bon, on ne fait rien pour le binning
         }
         parallelport {
            #--- Mise en forme de la frame
            pack $This.fra3.lab1 -in $This.fra3 -anchor center -fill none
            pack $This.fra3.bin -in $This.fra3 -anchor n -fill x -expand 0 -pady 2
            pack forget $This.fra3.binEthernAude
            pack $This.fra3.fra2 -in $This.fra3 -anchor center -fill none
            pack $This.fra3.fra3 -in $This.fra3 -anchor center -fill none
            pack $This.fra3.but1 -in $This.fra3 -anchor center -fill none -pady 1 -ipadx 13
            pack $This.fra3.fra1 -in $This.fra3 -anchor center -fill none
            #--- C'est bon, on ne fait rien pour le binning
         }
         default {
            #--- Mise en forme de la frame
            pack $This.fra3.lab1 -in $This.fra3 -anchor center -fill none
            pack $This.fra3.bin -in $This.fra3 -anchor n -fill x -expand 0 -pady 2
            pack forget $This.fra3.binEthernAude
            pack $This.fra3.fra2 -in $This.fra3 -anchor center -fill none
            pack $This.fra3.fra3 -in $This.fra3 -anchor center -fill none
            pack $This.fra3.but1 -in $This.fra3 -anchor center -fill none -pady 1 -ipadx 13
            pack $This.fra3.fra1 -in $This.fra3 -anchor center -fill none
            #--- Initialisation du binning
            set panneau(dscan,binning) "1x1"
         }
      }
   }

   proc updateCellDim { { a "" } { b "" } { c "" } } {
      variable parametres
      global audace panneau

      #--- Mise à jour de la dimension du photosite
      if { [ ::cam::list ] != "" } {
         set panneau(dscan,pix) "[ expr [ lindex [ cam$audace(camNo) celldim ] 0 ] * 1e006]"
      } else {
         set panneau(dscan,pix) "$parametres(dscan,dimpix)"
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
      ::dscan::chargementVar

      #--- Initialisation des variables de l'outil
      set panneau(dscan,col1)     "$parametres(dscan,col1)"
      set panneau(dscan,col2)     "$parametres(dscan,col2)"
      set panneau(dscan,lig1)     "$parametres(dscan,lig1)"
      set panneau(dscan,pix)      "$parametres(dscan,dimpix)"
      set panneau(dscan,binning)  "$parametres(dscan,binning)"
      set panneau(dscan,binningX) "$parametres(dscan,binningX)"
      set panneau(dscan,binningY) "$parametres(dscan,binningY)"
      set panneau(dscan,foc)      "$parametres(dscan,foc)"
      set panneau(dscan,dec)      "$parametres(dscan,dec)"
      set panneau(dscan,obt)      "$parametres(dscan,obt)"

      #--- Initialisation des variables de la boite de configuration
      ::scanSetup::confToWidget

      #--- Entrer ici les valeurs pour l'obturateur a afficher dans le menu "obt"
      set panneau(dscan,obt,0) "$caption(scan,obtu_ouvert)"
      set panneau(dscan,obt,1) "$caption(scan,obtu_ferme)"
      set panneau(dscan,obt,2) "$caption(scan,obtu_synchro)"

      #--- Calcul de dt en fonction des parametres initialises
      ::dscan::cmdCalcul

      #--- Configuration dynamique de l'outil en fonction de la liaison
      ::dscan::adaptOutilScan
      ::confVisu::addCameraListener 1 ::dscan::adaptOutilScan
      trace add variable ::conf(audine,port) write ::dscan::adaptOutilScan

      #--- Mise a jour de la dimension du pixel a la connexion d'une camera
      ::dscan::updateCellDim
      trace add variable ::confCam(A,super_camNo) write ::dscan::updateCellDim
      trace add variable ::confCam(B,super_camNo) write ::dscan::updateCellDim
      trace add variable ::confCam(C,super_camNo) write ::dscan::updateCellDim

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
      ::dscan::enregistrementVar

      #--- Arret de la surveillance
      ::confVisu::removeCameraListener 1 ::dscan::adaptOutilScan
      trace remove variable ::conf(audine,port) write ::dscan::adaptOutilScan

      #--- Supprime la procedure de surveillance de la connexion d'une camera
      trace remove variable ::confCam(A,super_camNo) write ::dscan::updateCellDim
      trace remove variable ::confCam(B,super_camNo) write ::dscan::updateCellDim
      trace remove variable ::confCam(C,super_camNo) write ::dscan::updateCellDim

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
      global audace conf panneau

      if { [ ::cam::list ] != "" } {
         if { [ ::confCam::hasScan $audace(camNo) ] == "1" } {
            #--- Initialisation des variables
            set panneau(dscan,acquisition) "1"
            set panneau(Scan,Stop)         "0"

            #--- La premiere colonne ne peut pas etre inferieure a 1
            if { $panneau(dscan,col1) < "1" } {
               set panneau(dscan,col1) "1"
            }

            #--- Gestion graphique du bouton GO CCD
            $This.fra4.but1 configure -relief groove -text $panneau(dscan,go1) -state disabled

            #--- Gestion graphique du bouton STOP - Inactif avant le debut du scan
            $This.fra4.but2 configure -relief groove -text $panneau(dscan,stop) -state disabled
            update

            #--- Definition du binning
            set bin 4
            switch [ ::confLink::getLinkNamespace $conf(audine,port) ] {
               ethernaude {
                  set bin  "$panneau(dscan,binningX)"
                  set binY "$panneau(dscan,binningY)"
               }
               default {
                  if { $panneau(dscan,binning) == "4x4" } { set bin 4 }
                  if { $panneau(dscan,binning) == "2x2" } { set bin 2 }
                  if { $panneau(dscan,binning) == "1x1" } { set bin 1 }
                  set binY "$bin"
               }
            }

            #--- Definition des parametres du scan (w : largeur - h : hauteur - f : firstpix)
            set w [ ::dscan::int [ expr $panneau(dscan,col2) - $panneau(dscan,col1) + 1 ] ]
            set h [ ::dscan::int $panneau(dscan,lig1) ]
            set f [ ::dscan::int $panneau(dscan,col1) ]

            #--- Gestion du moteur d'A.D.
            if { $motor == "motoroff" } {
               if { [ ::tel::list ] != "" } {
                  #--- Arret du moteur d'AD
                  tel$audace(telNo) radec motor off
               }
            }

            #--- Attente du demarrage du scan
            if { $panneau(dscan,active) == "1" } {
               #--- Decompte du temps d'attente
               set attente $panneau(dscan,delai)
               if { $panneau(dscan,delai) > "0" } {
                  while { $panneau(dscan,delai) > "0" } {
                     ::camera::Avancement_scan "-10" $panneau(dscan,lig1) $panneau(dscan,delai)
                     update
                     after 1000
                     incr panneau(dscan,delai) "-1"
                  }
               }
               set panneau(dscan,delai) $attente
            }

            #--- Gestion graphique du bouton STOP - Devient actif avec le debut du scan
            $This.fra4.but2 configure -relief raised -text $panneau(dscan,stop) -state normal
            update

            #--- Changement de variable
            set dt $panneau(dscan,interlig1)

            #--- Appel a la fonction d'acquisition
            ::dscan::scan $w $h $bin $binY $dt $f

            #--- Gestion graphique du bouton GO CCD
            $This.fra4.but1 configure -relief groove -text $panneau(dscan,go2) -state disabled
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

            #--- Gestion graphique du bouton GO CCD
            set panneau(dscan,acquisition) "0"
            $This.fra4.but1 configure -relief raised -text $panneau(dscan,go0) -state normal
            update
         } else {
            tk_messageBox -title $panneau(dscan,attention) -type ok -message $panneau(dscan,msg)
         }
      } else {
         ::confCam::run
         tkwait window $audace(base).confCam
      }
   }

   proc scan { w h bin binY dt f } {
      global audace panneau

      #--- Calcul du nombre de lignes par seconde
      set panneau(dscan,nblg1) [ expr 1000./$dt ]

      #--- Declenchement de l'acquisition
      if { $f == "0" } {
         cam$audace(camNo) scan $w $h $bin $dt -biny $binY
      } else {
         cam$audace(camNo) scan $w $h $bin $dt -firstpix $f -biny $binY
      }

      #--- Alarme sonore de fin de pose
      set pseudoexptime [ expr $panneau(dscan,lig1) / $panneau(dscan,nblg1) ]
      ::camera::alarme_sonore $pseudoexptime

      #--- Appel du timer
      if { $panneau(dscan,lig1) > "$panneau(dscan,nblg1)" } {
         set t [ expr $panneau(dscan,lig1) / $panneau(dscan,nblg1) ]
         ::camera::dispLine $t $panneau(dscan,nblg1) $panneau(dscan,lig1) $panneau(dscan,delai)
      }

      #--- Attente de la fin de la pose
      vwait scan_result$audace(camNo)

      #--- Destruction de la fenetre d'avancement du scan
      set panneau(Scan,Stop) "1"
      if [ winfo exists $audace(base).progress_scan ] {
         destroy $audace(base).progress_scan
      }
   }

   proc cmdStop { } {
      variable This
      global audace panneau

      if { [ ::cam::list ] != "" } {
         if { $panneau(dscan,acquisition) == "1" } {
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
               $This.fra4.but1 configure -relief raised -text $panneau(dscan,go1) -state disabled
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
      global conf panneau

      #--- La premiere colonne ne peut pas etre inferieure a 1
      if { $panneau(dscan,col1) < "1" } {
         set panneau(dscan,col1) "1"
      }

      #--- Calcul de dt
      switch [ ::confLink::getLinkNamespace $conf(audine,port) ] {
         ethernaude {
            set bin  "$panneau(dscan,binningX)"
            set binY "$panneau(dscan,binningY)"
         }
         default {
            if { $panneau(dscan,binning) == "4x4" } { set bin 4 }
            if { $panneau(dscan,binning) == "2x2" } { set bin 2 }
            if { $panneau(dscan,binning) == "1x1" } { set bin 1 }
            set binY "$bin"
         }
      }
      set panneau(dscan,interlig1) [ expr $binY*86164*2*atan($panneau(dscan,pix)/2./($panneau(dscan,foc)*1e6))/360.*180/3.1415926*1000./cos( [ mc_angle2rad $panneau(dscan,dec) ] ) ]
      $This.fra3.fra1.ent1 configure -textvariable panneau(dscan,interlig1)
      update
   }

   proc infoCam { } {
      variable This
      variable parametres
      global audace panneau

      if { [ ::cam::list ] != "" } {
         set parametres(dscan,col2)   "[ lindex [ cam$audace(camNo) nbcells ] 0 ]"
         set parametres(dscan,dimpix) "[ expr [ lindex [ cam$audace(camNo) celldim ] 0 ] * 1e006]"
         set panneau(dscan,col2)      "$parametres(dscan,col2)"
         set panneau(dscan,pix)       "$parametres(dscan,dimpix)"
         $This.fra2.fra1.ent2 configure -textvariable panneau(dscan,col2)
         $This.fra2.fra3.ent1 configure -textvariable panneau(dscan,pix)
         update
      }

      #--- Calcul de dt en fonction du changement de parametres
      ::dscan::cmdCalcul
   }

   proc cmdDec { } {
      variable This
      variable parametres
      global audace conf confTel panneau

      #--- Initialisation et/ou determination de la position de la declinaison
      if { [ ::tel::list ] != "" } {
         set radec [ tel$audace(telNo) radec coord ]
         if { [ lindex $radec 0 ] == "tel$audace(telNo)" } {
            set panneau(dscan,dec) "$parametres(dscan,dec)"
         } else {
            set panneau(dscan,dec) [ lindex $radec 1 ]
         }
      } elseif { ( $conf(telescope) == "ouranos" ) && ( $confTel(ouranos,connect) == "1" ) } {
         if { $conf(ouranos,show_coord) == "1" } {
            set panneau(dscan,dec) "$confTel(ouranos,coord_dec)"
         } else {
            set panneau(dscan,dec) "$parametres(dscan,dec)"
         }
      } else {
         set panneau(dscan,dec) "$parametres(dscan,dec)"
      }
      $This.fra3.fra3.ent2 configure -textvariable panneau(dscan,dec)
      update

      #--- Calcul de dt en fonction de la declinaison
      ::dscan::cmdCalcul
   }

   proc changeObt { } {
      variable This
      global audace caption confCam panneau

      if { [ ::cam::list ] != "" } {
         set result [::confCam::setShutter $audace(camNo) $panneau(dscan,obt)]
         if { $result != -1 } {
            set panneau(dscan,obt) $result
            $This.fra4.obt.lab1 configure -text $panneau(dscan,obt,$panneau(dscan,obt))
         }
      } else {
         ::confCam::run
         tkwait window $audace(base).confCam
      }
   }

   #--- Cette procedure verifie que la chaine passee en argument decrit bien un entier
   #--- Elle retourne 1 si c'est la cas, et 0 si ce n'est pas un entier
   proc testEntier { valeur } {
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
   proc testChaine { valeur } {
      set test 1
      for { set i 0 } { $i < [ string length $valeur ] } { incr i } {
         set a [ string index $valeur $i ]
         if { ![string match {[-a-zA-Z0-9_]} $a] } {
            set test 0
         }
      }
      return $test
   }

   proc sauveUneImage { } {
      global audace panneau

      #--- Enregistrer l'extension des fichiers
      set ext [ buf[ ::confVisu::getBufNo 1 ] extension ]

      #--- Tests d'integrite de la requete

      #--- Verifier qu'il y a bien un nom de fichier
      if { $panneau(dscan,nom_image) == "" } {
         tk_messageBox -title $panneau(dscan,pb) -type ok \
            -message $panneau(dscan,nom_fichier)
         return
      }

      #--- Verifier que le nom de fichier n'a pas d'espace
      if { [ llength $panneau(dscan,nom_image) ] > "1" } {
         tk_messageBox -title $panneau(dscan,pb) -type ok \
            -message $panneau(dscan,nom_blanc)
         return
      }

      #--- Verifier que le nom de fichier ne contient pas de caracteres interdits
      if { [ ::dscan::testChaine $panneau(dscan,nom_image) ] == "0" } {
         tk_messageBox -title $panneau(dscan,pb) -type ok \
            -message $panneau(dscan,mauvais_car)
         return
      }

      #--- Si la case index est cochee, verifier qu'il y a bien un index
      if { $panneau(dscan,indexer) == "1" } {
         #--- Verifier que l'index existe
         if { $panneau(dscan,indice) == "" } {
            tk_messageBox -title $panneau(dscan,pb) -type ok \
               -message $panneau(dscan,saisir_indice)
            return
         }
         #--- Verifier que l'index est bien un nombre entier
         if { [ ::dscan::testEntier $panneau(dscan,indice) ] == "0" } {
            tk_messageBox -title $panneau(dscan,pb) -type ok \
               -message $panneau(dscan,indice_entier)
            return
         }
      }

      #--- Generer le nom du fichier
      set nom $panneau(dscan,nom_image)

      #--- Pour eviter un nom de fichier qui commence par un blanc
      set nom [ lindex $nom 0 ]
      if { $panneau(dscan,indexer) == "1" } {
         append nom $panneau(dscan,indice)
      }

      #--- Verifier que le nom du fichier n'existe pas deja
      set nom1 "$nom"
      append nom1 $ext
      if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
         #--- Dans ce cas, le fichier existe deja
         set confirmation [ tk_messageBox -title $panneau(dscan,confirmation) -type yesno \
            -message $panneau(dscan,fichier_existe) ]
         if { $confirmation == "no" } {
            return
         }
      }

      #--- Incrementer l'index
      if { $panneau(dscan,indexer) == "1" } {
         if { [ buf$audace(bufNo) imageready ] != "0" } {
            incr panneau(dscan,indice)
         } else {
            #--- Sortir immediatement s'il n'y a pas d'image dans le buffer
            return
         }
      }

      #--- Sauvegarder l'image
      saveima $nom
   }

}

proc dscanBuildIF { This } {
   global audace panneau

   #--- Frame de l'outil
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra0 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra0.but -borderwidth 1 -text $panneau(dscan,titre) \
            -command "::audace::showHelpPlugin tool scan scan.htm"
         pack $This.fra0.but -in $This.fra0 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra0.but -text $panneau(dscan,aide)

      pack $This.fra0 -side top -fill x

      #--- Frame du bouton de configuration
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du bouton Configuration
         button $This.fra1.but -borderwidth 1 -text $panneau(dscan,configuration) \
            -command { ::scanSetup::run $audace(base).scanSetup }
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5

      pack $This.fra1 -side top -fill x

      #--- Frame des colonnes, des lignes et de la dimension des pixels
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Label pour colonnes
         label $This.fra2.lab1 -text $panneau(dscan,col) -relief flat
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -fill none -padx 4 -pady 1

         #--- Frame des 2 entries de colonnes
         frame $This.fra2.fra1 -borderwidth 1 -relief flat

            #--- Entry pour la colonne de debut
            entry $This.fra2.fra1.ent1 -textvariable panneau(dscan,col1) -font $audace(font,arial_8_b) \
               -relief groove -width 5 -justify center
            pack $This.fra2.fra1.ent1 -in $This.fra2.fra1 -side left -fill none -padx 4 -pady 1

            #--- Entry pour la colonne de fin
            entry $This.fra2.fra1.ent2 -textvariable panneau(dscan,col2) -font $audace(font,arial_8_b) \
               -relief groove -width 5 -justify center
            pack $This.fra2.fra1.ent2 -in $This.fra2.fra1 -side right -fill none -padx 4 -pady 1

         pack $This.fra2.fra1 -in $This.fra2 -anchor center -fill none

         #--- Frame pour lignes
         frame $This.fra2.fra2 -borderwidth 1 -relief flat

            #--- Label pour lignes
            label $This.fra2.fra2.lab2 -text $panneau(dscan,lig) -relief flat
            pack $This.fra2.fra2.lab2 -in $This.fra2.fra2 -side left -fill none -padx 2 -pady 1

            #--- Entry pour lignes
            entry $This.fra2.fra2.ent1 -textvariable panneau(dscan,lig1) -font $audace(font,arial_8_b) \
               -relief groove -width 7 -justify center
            pack $This.fra2.fra2.ent1 -in $This.fra2.fra2 -side right -fill none -padx 2 -pady 1

         pack $This.fra2.fra2 -in $This.fra2 -anchor center -fill none

         #--- Frame pour la dimension des pixels
         frame $This.fra2.fra3 -borderwidth 1 -relief flat

            #--- Label pour la dimension des pixels
            label $This.fra2.fra3.lab3 -text $panneau(dscan,pixel) -relief flat
            pack $This.fra2.fra3.lab3 -in $This.fra2.fra3 -side left -fill none -padx 2 -pady 1

            #--- Entry pour la dimension des pixels
            entry $This.fra2.fra3.ent1 -textvariable panneau(dscan,pix) -font $audace(font,arial_8_b) \
               -relief groove -width 4 -justify center
            pack $This.fra2.fra3.ent1 -in $This.fra2.fra3 -side left -fill none -padx 2 -pady 1

            #--- Label pour l'unite de la dimension des pixels
            label $This.fra2.fra3.lab4 -text $panneau(dscan,unite) -relief flat
            pack $This.fra2.fra3.lab4 -in $This.fra2.fra3 -side right -fill none -padx 2 -pady 1

         pack $This.fra2.fra3 -in $This.fra2 -anchor center -fill none

      pack $This.fra2 -side top -fill x

      #--- Binding sur la zone des infos de la camera
      set zone(camera) $This.fra2
      bind $zone(camera) <ButtonPress-1>           { ::dscan::infoCam }
      bind $zone(camera).lab1 <ButtonPress-1>      { ::dscan::infoCam }
      bind $zone(camera).fra2.lab2 <ButtonPress-1> { ::dscan::infoCam }
      bind $zone(camera).fra3.lab3 <ButtonPress-1> { ::dscan::infoCam }
      bind $zone(camera).fra3.lab4 <ButtonPress-1> { ::dscan::infoCam }

      #--- Frame de l'interligne
      frame $This.fra3 -borderwidth 1 -relief groove

         #--- Label pour interligne
         label $This.fra3.lab1 -text $panneau(dscan,interlig) -relief flat
         pack $This.fra3.lab1 -in $This.fra3 -anchor center -fill none

         #--- Frame pour binning (sauf EthernAude)
         frame $This.fra3.bin -borderwidth 0 -relief groove

            #--- Menu pour binning
            menubutton $This.fra3.bin.but_bin -text $panneau(dscan,bin) -menu $This.fra3.bin.but_bin.menu -relief raised
            pack $This.fra3.bin.but_bin -in $This.fra3.bin -side left -fill none
            set m [ menu $This.fra3.bin.but_bin.menu -tearoff 0 ]
            foreach valbin [ ::confCam::getBinningList_Scan [ ::confVisu::getCamNo 1 ] ] {
               $m add radiobutton -label "$valbin" \
                  -indicatoron "1" \
                  -value "$valbin" \
                  -variable panneau(dscan,binning) \
                  -command "::dscan::cmdCalcul"
            }

            #--- Entry pour binning
            entry $This.fra3.bin.lab_bin -width 2 -font {arial 10 bold} -relief groove \
              -textvariable panneau(dscan,binning) -justify center -state disabled
            pack $This.fra3.bin.lab_bin -in $This.fra3.bin -side left -fill both -expand true

         pack $This.fra3.bin -in $This.fra3 -anchor n -fill x -expand 0 -pady 2

         #--- Frame pour binning (seulement EthernAude)
         frame $This.fra3.binEthernAude -borderwidth 0 -relief groove

            #--- Label pour binning
            label $This.fra3.binEthernAude.lab1 -text $panneau(dscan,bin) -relief flat
            pack $This.fra3.binEthernAude.lab1 -in $This.fra3.binEthernAude -side left -fill none

            #--- Combobox pour binning X
            set listComboboxX [ list 1 2 ]
            ComboBox $This.fra3.binEthernAude.binX \
               -width 2        \
               -font $audace(font,arial_8_b) \
               -justify center \
               -height [ llength $listComboboxX ] \
               -relief sunken  \
               -borderwidth 1  \
               -editable 0     \
               -textvariable panneau(dscan,binningX) \
               -values $listComboboxX \
               -modifycmd "::dscan::cmdCalcul"
            pack $This.fra3.binEthernAude.binX -in $This.fra3.binEthernAude -side left -fill none

            #--- Label pour X
            label $This.fra3.binEthernAude.lab2 -text "x" -relief flat -font $audace(font,arial_8_b)
            pack $This.fra3.binEthernAude.lab2 -in $This.fra3.binEthernAude -side left -fill none

            #--- Combobox pour binning Y
            set listComboboxY [ list 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 \
               31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 ]
            ComboBox $This.fra3.binEthernAude.binY \
               -width 3        \
               -font $audace(font,arial_8_b) \
               -justify center \
               -height 20      \
               -relief sunken  \
               -borderwidth 1  \
               -editable 0     \
               -textvariable panneau(dscan,binningY) \
               -values $listComboboxY \
               -modifycmd "::dscan::cmdCalcul"
            pack $This.fra3.binEthernAude.binY -in $This.fra3.binEthernAude -side left -fill none

         pack $This.fra3.binEthernAude -in $This.fra3 -anchor n -fill x -expand 0 -pady 2

         #--- Frame des entry & labels de la focale
         frame $This.fra3.fra2 -borderwidth 1 -relief flat

            #--- Label pour la focale
            label $This.fra3.fra2.lab1 -text $panneau(dscan,focale) -relief flat
            pack $This.fra3.fra2.lab1 -in $This.fra3.fra2 -side left -fill none -padx 1 -pady 2

            #--- Entry pour la focale
            entry $This.fra3.fra2.ent1 -textvariable panneau(dscan,foc) -font $audace(font,arial_8_b) \
               -relief groove -width 5 -justify center
            pack $This.fra3.fra2.ent1 -in $This.fra3.fra2 -side left -fill none -padx 1 -pady 2

            #--- Label pour l'unite de la focale
            label $This.fra3.fra2.lab2 -text $panneau(dscan,metres) -relief flat
            pack $This.fra3.fra2.lab2 -in $This.fra3.fra2 -side left -fill none -padx 1 -pady 2

         pack $This.fra3.fra2 -in $This.fra3 -anchor center -fill none

         #--- Frame des bouton & entry de la declinaison
         frame $This.fra3.fra3 -borderwidth 1 -relief flat

            #--- Bouton pour la mise a jour de la dec
            button $This.fra3.fra3.but2 -borderwidth 2 -text $panneau(dscan,declinaison) \
               -width 3 -command "::dscan::cmdDec"
            pack $This.fra3.fra3.but2 -in $This.fra3.fra3 -side left -fill none -pady 1

            #--- Entry pour la dec
            entry $This.fra3.fra3.ent2 -textvariable panneau(dscan,dec) -font $audace(font,arial_8_b) \
               -relief groove -width 10
            pack $This.fra3.fra3.ent2 -in $This.fra3.fra3 -side right -fill none -pady 1

         pack $This.fra3.fra3 -in $This.fra3 -anchor center -fill none

         #--- Bouton de calcul
         button $This.fra3.but1 -borderwidth 2 -text $panneau(dscan,calcul) \
            -command "::dscan::cmdCalcul"
         pack $This.fra3.but1 -in $This.fra3 -anchor center -fill none -pady 1 -ipadx 13

         #--- Frame des entry & label
         frame $This.fra3.fra1 -borderwidth 1 -relief flat

            #--- Entry pour les millisecondes
            entry $This.fra3.fra1.ent1 -width 7 -relief groove -font $audace(font,arial_8_b) \
              -textvariable panneau(dscan,interlig1) -state disabled
            pack $This.fra3.fra1.ent1 -in $This.fra3.fra1 -side left -fill none -padx 1 -pady 2

            #--- Label pour l'unite
            label $This.fra3.fra1.ent2 -text $panneau(dscan,ms) -relief flat
            pack $This.fra3.fra1.ent2 -in $This.fra3.fra1 -side left -fill none -padx 1 -pady 2

         pack $This.fra3.fra1 -in $This.fra3 -anchor center -fill none

      pack $This.fra3 -side top -fill x

      #--- Frame de l'acquisition
      frame $This.fra4 -borderwidth 1 -relief groove

         #--- Frame de l'obturateur
         frame $This.fra4.obt -borderwidth 2 -relief ridge -width 16

            #--- Bouton de changement d'etat de l'obturateur
            button $This.fra4.obt.but -text $panneau(dscan,obturateur) -command "::dscan::changeObt" \
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
         label $This.fra4.lab1 -text $panneau(dscan,acq) -relief flat
         pack $This.fra4.lab1 -in $This.fra4 -anchor center -fill none -padx 4 -pady 1

         #--- Bouton GO
         button $This.fra4.but1 -borderwidth 2 -text $panneau(dscan,go) \
            -command "::dscan::cmdGo motoroff"
         pack $This.fra4.but1 -in $This.fra4 -anchor center -fill x -padx 5 -ipadx 10 -ipady 3

         #--- Bouton STOP
         button $This.fra4.but2 -borderwidth 2 -text $panneau(dscan,stop) \
            -command "::dscan::cmdStop"
         pack $This.fra4.but2 -in $This.fra4 -anchor center -fill x -padx 5 -pady 5 -ipadx 15 -ipady 3

      pack $This.fra4 -side top -fill x

      #--- Frame de la sauvegarde de l'image
      frame $This.fra5 -borderwidth 1 -relief groove

        #--- Frame du nom de l'image
        frame $This.fra5.nom -relief ridge -borderwidth 2

           #--- Label du nom de l'image
           label $This.fra5.nom.lab1 -text $panneau(dscan,nom) -pady 0
           pack $This.fra5.nom.lab1 -fill x -side top

           #--- Entry du nom de l'image
           entry $This.fra5.nom.ent1 -width 10 -textvariable panneau(dscan,nom_image) \
              -font $audace(font,arial_10_b) -relief groove
           pack $This.fra5.nom.ent1 -fill x -side top

           #--- Label de l'extension
           label $This.fra5.nom.lab_extension -text $panneau(dscan,extension) -pady 0
           pack $This.fra5.nom.lab_extension -fill x -side left

           #--- Button pour le choix de l'extension
           button $This.fra5.nom.extension -textvariable panneau(dscan,extension_image) \
              -width 7 -command "::confFichierIma::run $audace(base).confFichierIma"
           pack $This.fra5.nom.extension -side right -fill x

        pack $This.fra5.nom -side top -fill x

        #--- Frame de l'index
        frame $This.fra5.index -relief ridge -borderwidth 2

           #--- Checkbutton pour le choix de l'indexation
           checkbutton $This.fra5.index.case -pady 0 -text $panneau(dscan,index) -variable panneau(dscan,indexer)
           pack $This.fra5.index.case -side top -fill x

           #--- Entry de l'index
           entry $This.fra5.index.ent2 -width 3 -textvariable panneau(dscan,indice) \
              -font $audace(font,arial_10_b) -relief groove -justify center
           pack $This.fra5.index.ent2 -side left -fill x -expand true

           #--- Bouton de mise a 1 de l'index
           button $This.fra5.index.but1 -text "1" -width 3 \
              -command "set panneau(dscan,indice) 1"
           pack $This.fra5.index.but1 -side right -fill x

        pack $This.fra5.index -side top -fill x

        #--- Bouton pour sauvegarder l'image
        button $This.fra5.but_sauve -text $panneau(dscan,sauvegarde) -command "::dscan::sauveUneImage"
        pack $This.fra5.but_sauve -side top -fill x

     pack $This.fra5 -side top -fill x

   bind $This.fra4.but1 <ButtonPress-3> { ::dscan::cmdGo motoron }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

