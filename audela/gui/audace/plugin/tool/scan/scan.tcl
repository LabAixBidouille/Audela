#
# Fichier : scan.tcl
# Description : Outil pour l'acquisition en mode drift scan
# Compatibilite : Montures LX200, AudeCom et Ouranos avec camera Audine (liaison parallele, Audinet ou EthernAude)
# Auteur : Alain KLOTZ
# Mise a jour $Id: scan.tcl,v 1.23 2007-04-14 08:33:32 robertdelmas Exp $
#

#============================================================
# Declaration du namespace Dscan
#    initialise le namespace
#============================================================
namespace eval ::Dscan {
   package provide scan 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
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
      set panneau(Dscan,titre)           "$caption(scan,drift_scan)"
      set panneau(Dscan,aide)            "$caption(scan,help_titre)"
      set panneau(Dscan,configuration)   "$caption(scan,configuration)"
      set panneau(Dscan,col)             "$caption(scan,colonnes)"
      set panneau(Dscan,lig)             "$caption(scan,lignes)"
      set panneau(Dscan,pixel)           "$caption(scan,pixel)"
      set panneau(Dscan,unite)           "$caption(scan,micron)"
      set panneau(Dscan,interlig)        "$caption(scan,interligne)"
      set panneau(Dscan,bin)             "$caption(scan,binning)"
      set panneau(Dscan,focale)          "$caption(scan,focale)"
      set panneau(Dscan,metres)          "$caption(scan,metre)"
      set panneau(Dscan,declinaison)     "$caption(scan,declinaison)"
      set panneau(Dscan,calcul)          "$caption(scan,calcul)"
      set panneau(Dscan,ms)              "$caption(scan,milliseconde)"
      set panneau(Dscan,acq)             "$caption(scan,acquisition)"
      set panneau(Dscan,go0)             "$caption(scan,goccd)"
      set panneau(Dscan,stop)            "$caption(scan,stop)"
      set panneau(Dscan,go1)             "$caption(scan,en_cours)"
      set panneau(Dscan,go2)             "$caption(scan,visu)"
      set panneau(Dscan,go)              "$panneau(Dscan,go0)"
      set panneau(Dscan,attention)       "$caption(scan,attention)"
      set panneau(Dscan,msg)             "$caption(scan,message)"
      set panneau(Dscan,nom)             "$caption(scan,nom)"
      set panneau(Dscan,extension)       "$caption(scan,extension)"
      set panneau(Dscan,index)           "$caption(scan,index)"
      set panneau(Dscan,sauvegarde)      "$caption(scan,sauvegarde)"
      set panneau(Dscan,pb)              "$caption(scan,pb)"
      set panneau(Dscan,nom_fichier)     "$caption(scan,nom_fichier)"
      set panneau(Dscan,nom_blanc)       "$caption(scan,nom_blanc)"
      set panneau(Dscan,mauvais_car)     "$caption(scan,mauvais_car)"
      set panneau(Dscan,saisir_indice)   "$caption(scan,saisir_indice)"
      set panneau(Dscan,indice_entier)   "$caption(scan,indice_entier)"
      set panneau(Dscan,confirmation)    "$caption(scan,confirmation)"
      set panneau(Dscan,fichier_existe)  "$caption(scan,fichier_existe)"

      #--- Initialisation des variables
      set panneau(Dscan,nom_image)       ""
      set panneau(Dscan,extension_image) "$conf(extension,defaut)"
      set panneau(Dscan,indexer)         "0"
      set panneau(Dscan,indice)          "1"
      set panneau(Dscan,acquisition)     "0"
      set panneau(Scan,Stop)             "0"

      #--- Construction de l'interface
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

      #--- Creation des variables si elles n'existent pas
      if { ! [ info exists parametres(Dscan,col1) ] }    { set parametres(Dscan,col1)    "1" }
      if { ! [ info exists parametres(Dscan,col2) ] }    { set parametres(Dscan,col2)    "768" }
      if { ! [ info exists parametres(Dscan,lig1) ] }    { set parametres(Dscan,lig1)    "1500" }
      if { ! [ info exists parametres(Dscan,dimpix) ] }  { set parametres(Dscan,dimpix)  "9.0" }
      if { ! [ info exists parametres(Dscan,binning) ] } { set parametres(Dscan,binning) "2x2" }
      if { ! [ info exists parametres(Dscan,foc) ] }     { set parametres(Dscan,foc)     ".85" }
      if { ! [ info exists parametres(Dscan,dec) ] }     { set parametres(Dscan,dec)     "0d" }

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      ::scanSetup::initToConf
   }

   proc Enregistrement_Var { } {
      variable parametres
      global audace panneau

      #--- Changement de variables
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

   proc Adapt_Outil_Scan { { a "" } { b "" } { c "" } } {
      variable This
      global conf panneau

      #--- Mise a jour de la liste des binnings disponibles
      $This.fra3.bin.but_bin.menu delete 0 20
      set list_binning_scan [ ::confCam::getBinningList_Scan [ ::confVisu::getCamNo 1 ] ]
      foreach valbin $list_binning_scan {
         $This.fra3.bin.but_bin.menu add radiobutton -label "$valbin" \
            -indicatoron "1" \
            -value "$valbin" \
            -variable panneau(Dscan,binning) \
            -command "::Dscan::cmdCalcul"
      }

      #--- Binnings associes aux liaisons
      switch [ ::confLink::getLinkNamespace $conf(audine,port) ] {
         ethernaude {
            if { $panneau(Dscan,binning) == "4x4" } {
               set panneau(Dscan,binning) "2x2"
               ::Dscan::cmdCalcul
            }
         }
         audinet {
            #--- C'est bon, on ne fait rien pour le binning
         }
         parallelport {
            #--- C'est bon, on ne fait rien pour le binning
         }
         default {
            set panneau(Dscan,binning) "1x1"
         }
      }
   }

   proc Update_CellDim { { a "" } { b "" } { c "" } } {
      variable parametres
      global audace panneau

      #--- Mise à jour de la dimension du photosite
      if { [ ::cam::list ] != "" } {
         set panneau(Dscan,pix) "[ expr [ lindex [ cam$audace(camNo) celldim ] 0 ] * 1e006]"
      } else {
         set panneau(Dscan,pix) "$parametres(Dscan,dimpix)"
      }
   }

   proc startTool { visuNo } {
      variable This
      variable parametres
      global audace panneau

      #--- Chargement de la configuration
      ::Dscan::Chargement_Var

      #--- Initialisation des variables de l'outil
      set panneau(Dscan,col1)    "$parametres(Dscan,col1)"
      set panneau(Dscan,col2)    "$parametres(Dscan,col2)"
      set panneau(Dscan,lig1)    "$parametres(Dscan,lig1)"
      set panneau(Dscan,pix)     "$parametres(Dscan,dimpix)"
      set panneau(Dscan,binning) "$parametres(Dscan,binning)"
      set panneau(Dscan,foc)     "$parametres(Dscan,foc)"
      set panneau(Dscan,dec)     "$parametres(Dscan,dec)"

      #--- Initialisation des variables de la boite de configuration
      ::scanSetup::confToWidget

      #--- Calcul de dt en fonction des parametres initialises
      ::Dscan::cmdCalcul

      #--- Configuration dynamique de l'outil en fonction de la liaison
      ::Dscan::Adapt_Outil_Scan
      ::confVisu::addCameraListener 1 ::Dscan::Adapt_Outil_Scan
      trace add variable ::conf(audine,port) write ::Dscan::Adapt_Outil_Scan

      #--- Mise a jour de la dimension du pixel a la connexion d'une camera
      ::Dscan::Update_CellDim
      trace add variable ::confCam(A,super_camNo) write ::Dscan::Update_CellDim
      trace add variable ::confCam(B,super_camNo) write ::Dscan::Update_CellDim
      trace add variable ::confCam(C,super_camNo) write ::Dscan::Update_CellDim

      #---
      pack $This -side left -fill y
   }

   proc stopTool { visuNo } {
      variable This

      #--- Sauvegarde de la configuration
      ::Dscan::Enregistrement_Var

      #--- Arret de la surveillance
      ::confVisu::removeCameraListener 1 ::Dscan::Adapt_Outil_Scan
      trace remove variable ::conf(audine,port) write ::Dscan::Adapt_Outil_Scan

      #--- Supprime la procedure de surveillance de la connexion d'une camera
      trace remove variable ::confCam(A,super_camNo) write ::Dscan::Update_CellDim
      trace remove variable ::confCam(B,super_camNo) write ::Dscan::Update_CellDim
      trace remove variable ::confCam(C,super_camNo) write ::Dscan::Update_CellDim

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
      variable parametres
      global audace panneau

      if { [ ::cam::list ] != "" } {
         if { [ ::confCam::hasScan $audace(camNo) ] == "1" } {
            #--- Initialisation des variables
            set panneau(Dscan,acquisition) "1"
            set panneau(Scan,Stop)         "0"

            #--- La premiere colonne ne peut pas etre inferieure a 1
            if { $panneau(Dscan,col1) < "1" } {
               set panneau(Dscan,col1) "1"
            }

            #--- Gestion graphique du bouton GO CCD
            $This.fra4.but1 configure -relief groove -text $panneau(Dscan,go1) -state disabled

            #--- Gestion graphique du bouton STOP - Inactif avant le debut du scan
            $This.fra4.but2 configure -relief groove -text $panneau(Dscan,stop) -state disabled
            update

            #--- Definition du binning
            set bin 4
            if { $panneau(Dscan,binning) == "4x4" } { set bin 4 }
            if { $panneau(Dscan,binning) == "2x2" } { set bin 2 }
            if { $panneau(Dscan,binning) == "1x1" } { set bin 1 }

            #--- Definition des parametres du scan (w : largeur - h : hauteur - f : firstpix)
            set w [ ::Dscan::int [ expr $panneau(Dscan,col2) - $panneau(Dscan,col1) + 1 ] ]
            set h [ ::Dscan::int $panneau(Dscan,lig1) ]
            set f [ ::Dscan::int $panneau(Dscan,col1) ]

            #--- Gestion du moteur d'A.D.
            if { $motor == "motoroff" } {
               if { [ ::tel::list ] != "" } {
                  #--- Arret du moteur d'AD
                  tel$audace(telNo) radec motor off
               }
            }

            #--- Attente du demarrage du scan
            if { $panneau(Dscan,active) == "1" } {
               #--- Decompte du temps d'attente
               set attente $panneau(Dscan,delai)
               if { $panneau(Dscan,delai) > "0" } {
                  while { $panneau(Dscan,delai) > "0" } {
                     ::camera::Avancement_scan "-10" $panneau(Dscan,lig1) $panneau(Dscan,delai)
                     update
                     after 1000
                     incr panneau(Dscan,delai) "-1"
                  }
               }
               set panneau(Dscan,delai) $attente
            }

            #--- Gestion graphique du bouton STOP - Devient actif avec le debut du scan
            $This.fra4.but2 configure -relief raised -text $panneau(Dscan,stop) -state normal
            update

            #--- Changement de variable
            set dt $panneau(Dscan,interlig1)

            #--- Appel a la fonction d'acquisition
            ::Dscan::scan $w $h $bin $dt $f

            #--- Gestion graphique du bouton GO CCD
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

            #--- Gestion graphique du bouton GO CCD
            set panneau(Dscan,acquisition) "0"
            $This.fra4.but1 configure -relief raised -text $panneau(Dscan,go0) -state normal
            update
         } else {
            tk_messageBox -title $panneau(Dscan,attention) -type ok -message $panneau(Dscan,msg)
         }
      } else {
         ::confCam::run
         tkwait window $audace(base).confCam
      }
   }

   proc scan { w h bin dt f } {
      global audace panneau

      #--- Petit raccourci
      set camera cam$audace(camNo)

      #--- Calcul du nombre de lignes par seconde
      set panneau(Dscan,nblg1) [ expr 1000./$dt ]
      set panneau(Dscan,nblg)  [ expr int($panneau(Dscan,nblg1)) + 1 ]

      #--- Sauvegarde de l'etat de l'obturateur
      set panneau(shutter_state) [ cam$audace(camNo) shutter ]
      cam$audace(camNo) shutter synchro

      #--- Declenchement de l'acquisition
      if { $f == "0" } {
         cam$audace(camNo) scan $w $h $bin $dt -biny $bin
      } else {
         cam$audace(camNo) scan $w $h $bin $dt -firstpix $f -biny $bin
      }

      #--- Alarme sonore de fin de pose
      set pseudoexptime [ expr $panneau(Dscan,lig1)/$panneau(Dscan,nblg1) ]
      ::camera::alarme_sonore $pseudoexptime

      #--- Appel du timer
      if { $panneau(Dscan,lig1) > "$panneau(Dscan,nblg)" } {
         set t [ expr $panneau(Dscan,lig1)/$panneau(Dscan,nblg1) ]
         ::camera::dispLine $t $panneau(Dscan,nblg1) $panneau(Dscan,lig1) $panneau(Dscan,delai)
      }

      #--- Attente de la fin de la pose
      vwait scan_result$audace(camNo)

      #--- Destruction de la fenetre d'avancement du scan
      if [ winfo exists $audace(base).progress_scan ] {
         destroy $audace(base).progress_scan
      }

      #--- Restauration de l'etat initial de l'obturateur
      cam$audace(camNo) shutter $panneau(shutter_state)
   }

   proc cmdStop { } {
      variable This
      global audace panneau

      if { [ ::cam::list ] != "" } {
         if { $panneau(Dscan,acquisition) == "1" } {
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
      global conf panneau

      #--- La premiere colonne ne peut pas etre inferieure a 1
      if { $panneau(Dscan,col1) < "1" } {
         set panneau(Dscan,col1) "1"
      }

      #--- Calcul de dt
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
      global audace panneau

      catch {
         set parametres(Dscan,col2)   "[ lindex [ cam$audace(camNo) nbcells ] 0 ]"
         set parametres(Dscan,dimpix) "[ expr [ lindex [ cam$audace(camNo) celldim ] 0 ] * 1e006]"
         set panneau(Dscan,col2)      "$parametres(Dscan,col2)"
         set panneau(Dscan,pix)       "$parametres(Dscan,dimpix)"
         $This.fra2.fra1.ent2 configure -textvariable panneau(Dscan,col2)
         $This.fra2.fra3.ent1 configure -textvariable panneau(Dscan,pix)
         update
      }

      #--- Calcul de dt en fonction du changement de parametres
      ::Dscan::cmdCalcul
   }

   proc cmdDec { } {
      variable This
      variable parametres
      global audace conf confTel panneau

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
            set panneau(Dscan,dec) "$confTel(ouranos,coord_dec)"
         } else {
            set panneau(Dscan,dec) "$parametres(Dscan,dec)"
         }
      } else {
         set panneau(Dscan,dec) "$parametres(Dscan,dec)"
      }
      $This.fra3.fra3.ent2 configure -textvariable panneau(Dscan,dec)
      update

      #--- Calcul de dt en fonction de la declinaison
      ::Dscan::cmdCalcul
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
      if { $panneau(Dscan,nom_image) == "" } {
         tk_messageBox -title $panneau(Dscan,pb) -type ok \
            -message $panneau(Dscan,nom_fichier)
         return
      }

      #--- Verifier que le nom de fichier n'a pas d'espace
      if { [ llength $panneau(Dscan,nom_image) ] > "1" } {
         tk_messageBox -title $panneau(Dscan,pb) -type ok \
            -message $panneau(Dscan,nom_blanc)
         return
      }

      #--- Verifier que le nom de fichier ne contient pas de caracteres interdits
      if { [ ::Dscan::TestChaine $panneau(Dscan,nom_image) ] == "0" } {
         tk_messageBox -title $panneau(Dscan,pb) -type ok \
            -message $panneau(Dscan,mauvais_car)
         return
      }

      #--- Si la case index est cochee, verifier qu'il y a bien un index
      if { $panneau(Dscan,indexer) == "1" } {
         #--- Verifier que l'index existe
         if { $panneau(Dscan,indice) == "" } {
            tk_messageBox -title $panneau(Dscan,pb) -type ok \
               -message $panneau(Dscan,saisir_indice)
            return
         }
         #--- Verifier que l'index est bien un nombre entier
         if { [ ::Dscan::TestEntier $panneau(Dscan,indice) ] == "0" } {
            tk_messageBox -title $panneau(Dscan,pb) -type ok \
               -message $panneau(Dscan,indice_entier)
            return
         }
      }

      #--- Generer le nom du fichier
      set nom $panneau(Dscan,nom_image)

      #--- Pour eviter un nom de fichier qui commence par un blanc
      set nom [ lindex $nom 0 ]
      if { $panneau(Dscan,indexer) == "1" } {
         append nom $panneau(Dscan,indice)
      }

      #--- Verifier que le nom du fichier n'existe pas deja
      set nom1 "$nom"
      append nom1 $ext
      if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
         #--- Dans ce cas, le fichier existe deja
         set confirmation [ tk_messageBox -title $panneau(Dscan,confirmation) -type yesno \
            -message $panneau(Dscan,fichier_existe) ]
         if { $confirmation == "no" } {
            return
         }
      }

      #--- Incrementer l'index
      if { $panneau(Dscan,indexer) == "1" } {
         if { [ buf$audace(bufNo) imageready ] != "0" } {
            incr panneau(Dscan,indice)
         } else {
            #--- Sortir immediatement s'il n'y a pas d'image dans le buffer
            return
         }
      }

      #--- Sauvegarder l'image
      saveima $nom
   }

}

proc DscanBuildIF { This } {
   global audace panneau

   #--- Frame de l'outil
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra0 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra0.but -borderwidth 1 -text $panneau(Dscan,titre) \
            -command "::audace::showHelpPlugin tool scan scan.htm"
         pack $This.fra0.but -in $This.fra0 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra0.but -text $panneau(Dscan,aide)

      pack $This.fra0 -side top -fill x

      #--- Frame du bouton de configuration
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du bouton Configuration
         button $This.fra1.but -borderwidth 1 -text $panneau(Dscan,configuration) \
            -command { ::scanSetup::run $audace(base).scanSetup }
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5

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

         #--- Frame pour binning
         frame $This.fra3.bin -borderwidth 0 -relief groove

            #--- Menu pour binning
            menubutton $This.fra3.bin.but_bin -text $panneau(Dscan,bin) -menu $This.fra3.bin.but_bin.menu -relief raised
            pack $This.fra3.bin.but_bin -in $This.fra3.bin -side left -fill none
            set m [ menu $This.fra3.bin.but_bin.menu -tearoff 0 ]
            foreach valbin [ ::confCam::getBinningList_Scan [ ::confVisu::getCamNo 1 ] ] {
               $m add radiobutton -label "$valbin" \
                  -indicatoron "1" \
                  -value "$valbin" \
                  -variable panneau(Dscan,binning) \
                  -command "::Dscan::cmdCalcul"
            }

            #--- Entry pour binning
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
               -width 3 -command "::Dscan::cmdDec"
            pack $This.fra3.fra3.but2 -in $This.fra3.fra3 -side left -fill none -pady 1

            #--- Entry pour la dec
            entry $This.fra3.fra3.ent2 -textvariable panneau(Dscan,dec) -font $audace(font,arial_8_b) \
               -relief groove -width 10
            pack $This.fra3.fra3.ent2 -in $This.fra3.fra3 -side right -fill none -pady 1

         pack $This.fra3.fra3 -in $This.fra3 -anchor center -fill none

         #--- Bouton de calcul
         button $This.fra3.but1 -borderwidth 2 -text $panneau(Dscan,calcul) \
            -command "::Dscan::cmdCalcul"
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

         #--- Label pour l'acquisition
         label $This.fra4.lab1 -text $panneau(Dscan,acq) -relief flat
         pack $This.fra4.lab1 -in $This.fra4 -anchor center -fill none -padx 4 -pady 1

         #--- Bouton GO
         button $This.fra4.but1 -borderwidth 2 -text $panneau(Dscan,go) \
            -command "::Dscan::cmdGo motoroff"
         pack $This.fra4.but1 -in $This.fra4 -anchor center -fill x -padx 5 -ipadx 10 -ipady 3

         #--- Bouton STOP
         button $This.fra4.but2 -borderwidth 2 -text $panneau(Dscan,stop) \
            -command "::Dscan::cmdStop"
         pack $This.fra4.but2 -in $This.fra4 -anchor center -fill x -padx 5 -pady 5 -ipadx 15 -ipady 3

      pack $This.fra4 -side top -fill x

      #--- Frame de la sauvegarde de l'image
      frame $This.fra5 -borderwidth 1 -relief groove

        #--- Frame du nom de l'image
        frame $This.fra5.nom -relief ridge -borderwidth 2

           #--- Label du nom de l'image
           label $This.fra5.nom.lab1 -text $panneau(Dscan,nom) -pady 0
           pack $This.fra5.nom.lab1 -fill x -side top

           #--- Entry du nom de l'image
           entry $This.fra5.nom.ent1 -width 10 -textvariable panneau(Dscan,nom_image) \
              -font $audace(font,arial_10_b) -relief groove
           pack $This.fra5.nom.ent1 -fill x -side top

           #--- Label de l'extension
           label $This.fra5.nom.lab_extension -text $panneau(Dscan,extension) -pady 0
           pack $This.fra5.nom.lab_extension -fill x -side left

           #--- Button pour le choix de l'extension
           button $This.fra5.nom.extension -textvariable panneau(Dscan,extension_image) \
              -width 7 -command "::confFichierIma::run $audace(base).confFichierIma"
           pack $This.fra5.nom.extension -side right -fill x

        pack $This.fra5.nom -side top -fill x

        #--- Frame de l'index
        frame $This.fra5.index -relief ridge -borderwidth 2

           #--- Checkbutton pour le choix de l'indexation
           checkbutton $This.fra5.index.case -pady 0 -text $panneau(Dscan,index) -variable panneau(Dscan,indexer)
           pack $This.fra5.index.case -side top -fill x

           #--- Entry de l'index
           entry $This.fra5.index.ent2 -width 3 -textvariable panneau(Dscan,indice) \
              -font $audace(font,arial_10_b) -relief groove -justify center
           pack $This.fra5.index.ent2 -side left -fill x -expand true

           #--- Bouton de mise a 1 de l'index
           button $This.fra5.index.but1 -text "1" -width 3 \
              -command "set panneau(Dscan,indice) 1"
           pack $This.fra5.index.but1 -side right -fill x

        pack $This.fra5.index -side top -fill x

        #--- Bouton pour sauvegarder l'image
        button $This.fra5.but_sauve -text $panneau(Dscan,sauvegarde) -command "::Dscan::SauveUneImage"
        pack $This.fra5.but_sauve -side top -fill x

     pack $This.fra5 -side top -fill x

   bind $This.fra4.but1 <ButtonPress-3> { ::Dscan::cmdGo motoron }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

