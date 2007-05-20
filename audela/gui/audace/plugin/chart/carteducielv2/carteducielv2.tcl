#
# Fichier : carteducielv2.tcl
# Description : Driver de communication avec "Cartes du Ciel" (communication DDE)
#    pour afficher la carte du champ des objets selectionnes dans AudeLA
#    Fonctionne avec Windows uniquement
# Auteur : Michel PUJOL
# Mise a jour $Id: carteducielv2.tcl,v 1.11 2007-05-20 15:52:42 robertdelmas Exp $
#

namespace eval carteducielv2 {

   package provide carteducielv2 1.0
   source [ file join [file dirname [info script]] carteducielv2.cap ]

   #------------------------------------------------------------
   #  initPlugin
   #     initialise le plugin
   #------------------------------------------------------------
   proc initPlugin { } {
      variable private

      if { $::tcl_platform(os) == "Linux" } {
         #--- CarteDuCiel V2 ne fonctionne pas sous Linux
         #--- Je retourne une chaine vide pour que ce driver n'apparaisse pas dans la fenetre de configuration
         return ""
      } else {
         #--- Charge les variables d'environnement
         initConf
         set private(ready) 0
      }
   }

   #------------------------------------------------------------
   #  getPluginProperty
   #     retourne la valeur de la propriete
   #
   # parametre :
   #    propertyName : nom de la propriete
   # return : valeur de la propriete , ou "" si la propriete n'existe pas
   #------------------------------------------------------------
   proc getPluginProperty { propertyName } {
      switch $propertyName {

      }
   }

   #------------------------------------------------------------
   #  getPluginType
   #     retourne le type de plugin
   #------------------------------------------------------------
   proc getPluginType { } {
      return "chart"
   }

   #------------------------------------------------------------
   #  getPluginTitle
   #     retourne le label du driver dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(carteducielv2,titre)"
   }

   #------------------------------------------------------------
   #  getHelp
   #     retourne la documentation du driver
   #
   #  return "nom_driver.htm"
   #------------------------------------------------------------
   proc getHelp { } {
      return "carteducielv2.htm"
   }

   #------------------------------------------------------------
   #  initConf
   #     initialise les parametres dans le tableau conf()
   #
   #  return rien
   #------------------------------------------------------------
   proc initConf { } {
      global conf

      if { ! [ info exists conf(carteducielv2,fixedfovstate) ] } { set conf(carteducielv2,fixedfovstate) "1" }
      if { ! [ info exists conf(carteducielv2,fixedfovvalue) ] } { set conf(carteducielv2,fixedfovvalue) "05d00m00s" }
      if { ! [ info exists conf(carteducielv2,exec) ] }          { set conf(carteducielv2,exec)          "Ciel.exe" }
      if { ! [ info exists conf(carteducielv2,dirname) ] }       { set conf(carteducielv2,dirname)       "c:/" }
      if { ! [ info exists conf(carteducielv2,binarypath) ] }    { set conf(carteducielv2,binarypath)    " " }

      return
   }

   #------------------------------------------------------------
   #  searchFile
   #     lancement de la recherche du fichier executable de Cartes du Ciel
   #
   #  return rien
   #------------------------------------------------------------
   proc searchFile { } {
      variable widget

      if { ( $widget(dirname) != "" ) && ( $widget(fichier_recherche) != "" ) } {
         #--- Fichier a rechercher
         set fichier_recherche $widget(fichier_recherche)
         #--- Sur les dossiers
         set repertoire $::carteducielv2::widget(dirname)

         #--- Gestion du bouton de recherche
         $widget(frm).frame3.recherche configure -relief groove -state disabled
         #--- La variable widget(binarypath) existe deja
         set repertoire_1 [ string trimright "$widget(binarypath)" "$fichier_recherche" ]
         set repertoire_2 [ glob -nocomplain -type f -dir "$repertoire_1" "$fichier_recherche" ]
         set repertoire_2 [ string trimleft $repertoire_2 "\{" ]
         set repertoire_2 [ string trimright $repertoire_2 "\}" ]
         if { "$widget(binarypath)" != "$repertoire_2" || "$widget(binarypath)" == "" } {
            #--- Non, elle a change -> Recherche de la nouvelle variable widget(binarypath) si elle existe
            set repertoire [ ::audace::fichier_partPresent "$fichier_recherche" "$repertoire" ]
            set repertoire [ glob -nocomplain -type f -dir "$repertoire" "$fichier_recherche" ]
            set repertoire [ string trimleft $repertoire "\{" ]
            set repertoire [ string trimright $repertoire "\}" ]
            if { $repertoire == "" } {
               set repertoire " "
            }
            set widget(binarypath) "$repertoire"
         } else {
            #--- Il n'y a rien a faire
         }

         if { $widget(binarypath) == " " } {
            set widget(fichier_recherche) [ string tolower $widget(fichier_recherche) ]
            ::carteducielv2::searchFile
         } else {
            #--- Gestion du bouton de recherche
            $widget(frm).frame3.recherche configure -relief raised -state normal
            update
            return
         }
      }
   }

   #------------------------------------------------------------
   #  confToWidget
   #     copie les parametres du tableau conf() dans les variables des widgets
   #
   #  return rien
   #------------------------------------------------------------
   proc confToWidget { } {
      variable widget
      global conf

      set widget(fixedfovstate)     "$conf(carteducielv2,fixedfovstate)"
      set widget(fixedfovvalue)     "$conf(carteducielv2,fixedfovvalue)"
      set widget(fichier_recherche) "$conf(carteducielv2,exec)"
      set widget(dirname)           "$conf(carteducielv2,dirname)"
      set widget(binarypath)        "$conf(carteducielv2,binarypath)"
   }

   #------------------------------------------------------------
   #  widgetToConf
   #     copie les variable des widgets dans le tableau conf()
   #
   #  return rien
   #------------------------------------------------------------
   proc widgetToConf { } {
      variable widget
      global conf

      set conf(carteducielv2,fixedfovstate) "$widget(fixedfovstate)"
      set conf(carteducielv2,fixedfovvalue) "$widget(fixedfovvalue)"
      set conf(carteducielv2,exec)          "$widget(fichier_recherche)"
      set conf(carteducielv2,dirname)       "$widget(dirname)"
      set conf(carteducielv2,binarypath)    "$widget(binarypath)"
   }

   #------------------------------------------------------------
   #  fillConfigPage
   #     fenetre de configuration du driver
   #
   #  return rien
   #------------------------------------------------------------
   proc fillConfigPage { frm } {
      variable widget
      global audace caption

      #--- je memorise la reference de la frame
      set widget(frm) $frm

      #--- j'initialise les valeurs
      confToWidget

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill x

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side top -fill x

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -side top -fill x

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -side bottom -fill x

      #--- Definition du champ (FOV)
      label $frm.frame1.labFOV -text "$caption(carteducielv2,fov_label)"
      pack $frm.frame1.labFOV -anchor center -side left -padx 10 -pady 10

      checkbutton $frm.frame1.fovState -text "$caption(carteducielv2,fov_state)" \
         -highlightthickness 0 -variable ::carteducielv2::widget(fixedfovstate)
      pack $frm.frame1.fovState -anchor center -side left -padx 10 -pady 5

      label $frm.frame1.labFovValue -text "$caption(carteducielv2,fov_value)"
      pack $frm.frame1.labFovValue -anchor center -side left -padx 10 -pady 10

      entry $frm.frame1.fovValue -textvariable ::carteducielv2::widget(fixedfovvalue) -width 10
      pack $frm.frame1.fovValue -anchor center -side left -padx 10 -pady 5

      #--- Initialisation du chemin du fichier
      label $frm.frame2.labFichier -text "$caption(carteducielv2,fichier)"
      pack $frm.frame2.labFichier -anchor center -side left -padx 10 -pady 10

      entry $frm.frame2.nomFichier -textvariable ::carteducielv2::widget(fichier_recherche) -width 12 -justify center
      pack $frm.frame2.nomFichier -anchor center -side left -padx 10 -pady 5

      label $frm.frame2.labAPartirDe -text "$caption(carteducielv2,a_partir_de)"
      pack $frm.frame2.labAPartirDe -anchor center -side left -padx 10 -pady 10

      entry $frm.frame2.nomDossier -textvariable ::carteducielv2::widget(dirname) -width 20
      pack $frm.frame2.nomDossier -side left -padx 10 -pady 5

      button $frm.frame2.explore -text "$caption(carteducielv2,parcourir)" -width 1 \
         -command {
            set ::carteducielv2::widget(dirname) [ tk_chooseDirectory -title "$caption(carteducielv2,dossier)" \
            -initialdir ".." -parent $::carteducielv2::widget(frm) ]
         }
      pack $frm.frame2.explore -side left -padx 10 -pady 5 -ipady 5

      button $frm.frame3.recherche -text "$caption(carteducielv2,rechercher)" -relief raised -state normal \
         -command { ::carteducielv2::searchFile }
      pack $frm.frame3.recherche -anchor center -side left  -padx 10 -pady 7 -ipadx 10 -ipady 5

      entry $frm.frame3.chemin -textvariable ::carteducielv2::widget(binarypath)
      pack $frm.frame3.chemin -anchor center -side left -padx 10 -fill x -expand 1

      button $frm.frame3.explore -text "$caption(carteducielv2,parcourir)" -width 1 \
         -command {
            set ::carteducielv2::widget(binarypath) [ ::tkutil::box_load $::carteducielv2::widget(frm) \
               $::carteducielv2::widget(dirname) $audace(bufNo) "11" ]
         }
      pack $frm.frame3.explore -side right -padx 10 -pady 5 -ipady 5

      #--- Site web officiel de Cartes du Ciel
      label $frm.frame4.labSite -text "$caption(carteducielv2,site_web)"
      pack $frm.frame4.labSite -side top -fill x -pady 2

      set labelName [ ::confCat::createUrlLabel $frm.frame4 "$caption(carteducielv2,site_web_ref)" \
         "$caption(carteducielv2,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $frm
   }

   #------------------------------------------------------------
   #  createPluginInstance
   #     cree une intance du plugin
   #
   #  return rien
   #------------------------------------------------------------
   proc createPluginInstance { } {
      #--- rien a faire pour carteduciel
      return
   }

   #------------------------------------------------------------
   #  deletePluginInstance
   #     suppprime l'instance du plugin
   #
   #  return rien
   #------------------------------------------------------------
   proc deletePluginInstance { } {
      #--- rien a faire pour carteduciel
      return
   }

   #------------------------------------------------------------
   #  isReady
   #     informe de l'etat de fonctionnement du driver
   #
   #  return 0 (ready) , 1 (not ready)
   #------------------------------------------------------------
   proc isReady { } {
      variable private

      #--- je teste si DDE est disponible
      set erreur [ catch { package require dde } result ]
      if { $erreur } {
         #--- dde n'est pas disponible (on est sous linux ?)
         set private(ready) 1
      } else {
         #--- je teste si carteduciel est lance
        # set erreur [ catch { dde services ciel DdeSkyChart } result ]
        # if { $erreur !=0 || $result=="" } {
        #    #--- carteduciel n'est pas lance
        #    set private(ready) 1
        # } else {
        #    set private(ready) 0
        # }
         set private(ready) 0
      }
      return $private(ready)
   }

   #==============================================================
   # Fonctions specifiques du driver de la categorie "catalog"
   #==============================================================

   #------------------------------------------------------------
   # gotoObject
   # Affiche la carte de champ de l'objet choisi
   #  parametres :
   #     nom_objet :    nom de l'objet     (ex: "NGC7000")
   #     ad :           ascension droite   (ex: "16h41m42s")
   #     dec :          declinaison        (ex: "+36d28m00s")
   #     zoom_objet :   champ 1 � 10
   #     avant_plan :   1=mettre la carte au premier plan, 0=ne pas mettre au premier plan
   #------------------------------------------------------------
   proc gotoObject { nom_objet ad dec zoom_objet avant_plan } {
      set result "0"
     # console::disp "::carteducielv2::gotoObject $nom_objet, $ad, $dec, $zoom_objet, $avant_plan \n"
      if { [isReady] != 0 } {
         return 1
      }

      if { $nom_objet != "#etoile#" && $nom_objet != "" } {
         set result [selectObject $nom_objet]
      } else {
         set result [moveCoord $ad $dec]
      }
      return $result
   }

   #------------------------------------------------------------
   #  moveCoord
   #     centre la fenetre de carteduciel sur les coordonnees passes en parametre
   #     et fixe le champ de diametre fov
   #     envoie a carteducciel  "MOVE RA: xxhxxmxxs DEC:xxdxx'xx" FOV:xxdxx'xx"
   #
   #  return 0 (OK) , 1(error)
   #------------------------------------------------------------
   proc moveCoord { ra dec } {
      global conf

      if { [isReady] != 0 } {
         return 1
      }

      #--- je fixe la taille du champ de la carte
      if { $conf(carteducielv2,fixedfovstate) == 0 } {
         #--- je recupere la champ de carteduciel
         set fov [lindex [getRaDecFov] 2]
         if { $fov == "" } {
            #--- rien a faire, j'abandonne
            return 1
         }
      } else {
         #--- j'utilise le champ fixe
         set fov $conf(carteducielv2,fixedfovvalue)
         #--- je remplace les unites
         set fov  [string map { "d" "\�" "m" "\'" "s" "\"" } $fov ]
      }

      #--- je supprime les diziemes de secondes apres le point decimal
      set ra [lindex [split $ra "."] 0]
      #--- je rajoute le "s" des secondes
      append ra "s"

      set dec  [string map { "d" "\�" "m" "\'" "s" "\"" } $dec ]
      set fov  [string map { "d" "\�" "m" "\'" "s" "\"" } $fov ]

      set command "MOVE RA: $ra DEC:$dec FOV:$fov"
      set result [sendDDECommand $command]
      return $result
   }

   #------------------------------------------------------------
   #  selectObject { }
   #     selectionne un objet dans carteducielv2
   #
   #  return "0" (OK) , "1"(error)
   #------------------------------------------------------------
   proc selectObject { objectName } {
      global conf

      set catid "0"
      set objectid "0"

      if { [isReady] != 0 } {
         return 1
      }

      if { [string compare -length 3 $objectName "MGC" ] == 0 } {
         #--- catalogue MGC absent de carteduciel
         set catid "0"
         set objectid ""
      } elseif { [string compare -length 1 $objectName "M" ] == 0 } {
         set catid "1"
         set objectid [string range $objectName 1 end ]
      } elseif { [string compare -length 3 $objectName "NGC" ] == 0 } {
         set catid "2"
         set objectid [string range $objectName 3 end ]
      } elseif { [string compare -length 2 $objectName "IC" ] == 0 } {
         set catid "3"
         set objectid [string range $objectName 2 end ]
      } elseif { [string compare -length 4 $objectName "GCVS" ] == 0 } {
         set catid "4"
         set objectid [string range $objectName 4 end ]
      } elseif { [string compare -length 2 $objectName "GC" ] == 0 } {
         set catid "5"
         set objectid [string range $objectName 2 end ]
      } elseif { [string compare -length 3 $objectName "GSC" ] == 0 } {
         set catid "6"
         set objectid [string range $objectName 3 end ]
      } elseif { [string compare -length 3 $objectName "SAO" ] == 0 } {
         set catid "7"
         set objectid [string range $objectName 3 end ]
      } elseif { [string compare -length 2 $objectName "HD" ] == 0 } {
         set catid "8"
         set objectid [string range $objectName 2 end ]
      } elseif { [string compare -length 2 $objectName "BD" ] == 0 } {
         set catid "9"
         set objectid [string range $objectName 2 end ]
      } elseif { [string compare -length 2 $objectName "CD" ] == 0 } {
         set catid "10"
         set objectid [string range $objectName 2 end ]
      } elseif { [string compare -length 3 $objectName "CPD" ] == 0 } {
         set catid "11"
         set objectid [string range $objectName 3 end ]
      } elseif { [string compare -length 2 $objectName "HR" ] == 0 } {
         set catid "12"
         set objectid [string range $objectName 2 end ]
      }

      if { $catid == "0" } {
         console::affiche_erreur "selectObject unknown catalog for $objectName"
         return 1
      }

      if { $objectid == "0" } {
         console::affiche_erreur "selectObject unknown object id for $objectName"
         return 1
      }

      set command "FIND CAT: $catid ID:$objectid"
      set result [sendDDECommand $command]

      #--- je fixe la taille du champ de la carte
      if { $conf(carteducielv2,fixedfovstate) == 1 } {
         #--- je recupere la champ de carteduciel
         set ra [lindex [getRaDecFov] 0 ]
         set dec [lindex [getRaDecFov] 1]
         #--- j'utilise le champ fixe
         set fov $conf(carteducielv2,fixedfovvalue)
         #--- je remplace les unites
         set dec  [string map { "d" "\�" "m" "\'" "s" "\"" } $dec ]
         set fov  [string map { "d" "\�" "m" "\'" "s" "\"" } $fov ]
         if { $fov == "" } {
            #--- rien a faire, j'abandonne
            return 1
         }
         set command "MOVE RA: $ra DEC:$dec FOV:$fov"

         set result [sendDDECommand $command]
       }
      return $result
   }

   #------------------------------------------------------------
   #  getSelectedObject {}
   #     recupere les coordonn�es et le nom de l'objet selectionne dans carteducielv2
   #     par communication DDE (en attendant une communication pas socket TCP ?)
   #
   #  return [list $ra $dec $objName ]
   #     $ra : right ascension  (ex: "16h41m42")
   #     $dec : declinaison     (ex: "+36d28m00")
   #     $objName: object name  (ex: "M 13")
   #
   #  Remarque : Si aucun objet n'est selectionne dans carteducielv2,
   #  alors getSelectedObject retourne les coordonn�es du centre de la carte
   #
   #  Description de l'interface Audela / carteducielv2
   #  -------------------------------------
   #  Requete DDE envoyee a carteducielv2 :
   #     dde request ciel DdeSkyChart DdeData
   #  Reponse DDE retournee par carteducielv2 :
   #     ligne 0 : date et heure de la machine
   #     ligne 1 : position du centre et champ de vision de la carte
   #     ligne 2 : contenu de la barre d'etat (dernier objet selectionne)
   #     ligne 3 : date et heure de la carte
   #     ligne 4 : position et nom du lieu d'observation
   #
   #  exemple de reponse :
   #     ligne 0 ==> 22/12/2001 23:50:57
   #     ligne 1 ==> RA: 13h40m13.00s DEC:+30�59'55.0" FOV:+90�00'00"
   #     ligne 2 ==> 14h15m39.70s +19�10'57.0"   * HR 5340 HD124897 Fl: 16 Ba:Alp  const:Boo mV:-0.04 b-v: 1.23 sp:  K1.5IIIFe-0.5      pm:-1.093 -1.998 ;ARCTURUS; Haris-el-sema
   #     ligne 3 ==> 2001-12-22T23:50:58
   #     ligne 4 ==> LAT:+43d37m00s LON:-01d27m00s ALT:200m OBS:Toulouse
   #
   #     Les coordonn�es et le nom de l'objet sont extraits de la ligne 2
   #     Les autres lignes ne sont pas utilisees.
   #
   #     Format de la ligne 2 : "$ra $dec $objType $detail"
   #     avec
   #       $ra      = right ascension  ex: "16h41m42.00s"
   #       $dec     = declinaison      ex: "+36�28'00.0""
   #       $objType = object type      ex: "M "
   #       $detail  = object detail    ex :"13 NGC 6205 const: HER Dim: 23.2'x 23.2'  m: 5.90 sbr:12.00 desc: !!eB,vRi,vgeCM,*11...;Hercules cluster;Messier said round nebula contains no star"
   #
   #  Mise en forme de la reponse
   #  ---------------------------
   #  1)Mise en forme de l'ascension droite $ra
   #       supprimer les fractions de secondes dans $ra
   #
   #  2)Mise en forme de la declinaison $dec
   #       remplacer "�" par "d"
   #       remplacer "'" par "m"
   #       remplacer """ par "s"
   #       supprimer les fractions de secondes
   #
   #  3)Mise en forme du nom de l'objet $objName
   #
   #     SI $objType = "*" ALORS
   #        je mets dans $objName le nom usuel de l'etoile s'il existe
   #        ou le nom du catalogue et le num�ro de l'�toile
   #        et eventuellement le nom de la constellation (catalogues Ba et Fl)
   #
   #       SI existe un point virgule dans $detail  ALORS
   #          $objName = nom usuel de l'etoile se situant
   #                     apres le premier point virgule de $detail
   #                     et jusqu'au point virgule suivant ou la fin de $detail
   #       SINON
   #          $catName = premiere chaine de caract�re de $detail jusqu'au premier espace
   #          $const   = chaine de caractere dans $detail qui suit "const:" jusqu'au premier espace suivant
   #          SI       $catName = "GSC"  ALORS $objName = "GSC"+ 10 caracteres de $detail apres catName
   #          SINON SI $catName = "TYC"  ALORS $objName = "TYC"+ 15 caracteres de $detail apres catName
   #          SINON SI $catName = "SAO"  ALORS $objName = "SAO"+ 9 caracteres de $detail apres catName
   #          SINON SI $catName = "Ba:" ALORS  $objName = "Ba" + 3 caracteres de $detail apres catName + $const
   #          SINON SI $catName = "BD"  ALORS  $objName = "BD" + 10 caracteres de $detail apres catName
   #          SINON SI $catName = "Fl:"  ALORS $objName = "Fl" + 3 caracteres de $detail apres catName + $const
   #          SINON SI $catName = "HD"   ALORS $objName = "HD" + 8 caracteres de $detail apres catName
   #          SINON SI $catName = "HR"   ALORS $objName = "HR" + 7 caracteres de $detail apres catName
   #        FINSI
   #     FINSI
   #
   #     SI $objType = "Gb" ou "Gx" ou "Nb" ou "OC" ou "Pl"
   #       je mets dans $objName le nom du catalogue et le num�ro de l'objet
   #
   #       $catName = premiere chaine de caract�re de $detail jusqu'au premier espace
   #       SI       $catName = "M "   ALORS  $objName = "M "  + 3 caracteres de $detail apres catName
   #       SINON SI $catName = "NGC"  ALORS  $objName = "NGC" + 9 caracteres de $detail apres catName
   #       SINON SI $catName = "UGC"  ALORS  $objName = "UGC" + 9 caracteres de $detail apres catName
   #       SINON SI $catName = "PGC"  ALORS  $objName = "PGC" + 8 caracteres de $detail apres catName
   #       SINON SI $catName = "PNG"  ALORS  $objName = "PNG" + 13 caracteres de $detail apres catName
   #       SINON SI $catName = "LBN"  ALORS  $objName = "LBN" + 6 caracteres de $detail apres catName
   #       SINON SI $catName = "OCL"  ALORS  $objName = "OCL" + 6 caracteres de $detail apres catName
   #     FINSI
   #
   #     SI $objType = "As"  ALORS
   #       $objName = 17 premiers caracteres de $detail
   #     FINSI
   #
   #     SI $objType = "Cm"  ALORS
   #       $objName = debut de detail jusqu'a la premiere parenthese fermante ")"
   #     FINSI
   #
   #     SI $objType = "P"  ALORS
   #       $objName = debut de detail jusqu'au premier espace ""
   #     FINSI
   #
   #     SI $objType = "C2"  ALORS             (catalogue externe UGC )
   #       $objName = debut de detail jusqu'a Dim
   #     FINSI
   #
   # Remarque
   # ------------------------
   #  Quand un objet est reference dans plusieurs catalogues,
   #  le nom retenu depend de l'ordre des SI $catName=... SINON
   #  Si vous preferez retenir en priorit� le nom de l'objet d'un autre catalogue
   #  il suffit de changer l'ordre des SI $catName=... SINON
   #
   #  ex: l'amas  M13 a s'appelle aussi NGC6205
   #
   #  Par defaut , objName est retourne avec la valeur "M 13"
   #  car l'agorithme commence par chercher si l'objet a un nom dans le catalogue Messier
   #       SI       $catName = "M "   ALORS  $objName = "M "  + 3 caracteres de $detail apres catName
   #       SINON SI $catName = "NGC"  ALORS  $objName = "NGC" + 9 caracteres de $detail apres catName
   #       SINON SI $catName = "UGC"  ALORS  $objName = "UGC" + 9 caracteres de $detail apres catName
   #       ...
   #
   #  Si vous pr�f�rez retenir en priorit� le nom du catalogue NGC,
   #  il suffit d'inverser l'ordre des tests :
   #       SI       $catName = "NGC"  ALORS  $objName = "NGC" + 9 caracteres de $detail apres catName
   #       SINON SI $catName = "M "   ALORS  $objName = "M "  + 3 caracteres de $detail apres catName
   #       SINON SI $catName = "UGC"  ALORS  $objName = "UGC" + 9 caracteres de $detail apres catName
   #       ...
   #
   #  le catalogue externe UGC peut etre trouve sur :
   #     http://www.astrogeek.org/ftp/pub/cdc/ugc2001a.exe (version catgen)
   #     http://astrosurf.com/astropc/cartes/prog/ugc.zip  (ancienne version non catgen)
   #------------------------------------------------------------
   proc getSelectedObject { } {
      global caption

      if { [isReady] != 0 } {
         console::affiche_erreur "$caption(carteducielv2,no_connect)\n"
         tk_messageBox -message "$caption(carteducielv2,no_connect)" -icon info
         return ""
      } else {
         set erreur [catch {dde request ciel DdeSkyChart DdeData } result ]
         if { $erreur == 1 } {
            #--- si erreur :
            set choix [tk_messageBox -type yesno -icon warning -title "$caption(carteducielv2,attention)" \
               -message "$caption(carteducielv2,option) $caption(carteducielv2,creation)\n\n$caption(carteducielv2,lance)"]
            if { $choix == "yes" } {
               set erreur [launch]
               if { $erreur == "1" } {
                  tk_messageBox -type ok -icon error -title "$caption(carteducielv2,attention)" \
                     -message "$caption(carteducielv2,verification)"
                  return ""
               }
               #--- nouvelle tentative
               set erreur [catch {dde request ciel DdeSkyChart DdeData } result ]
               if { $erreur == 1 } {
                  console::affiche_erreur "$caption(carteducielv2,no_connect)\n"
                  tk_messageBox -message "$caption(carteducielv2,no_connect)" -icon info
                  return ""
               }
            } else {
              return ""
            }
            return ""
         }
      }

      #--- je decoupe les 5 lignes d'information
      set ligneList [split $result "\n"]

     # foreach c $ligneList {
     #    console::disp "==> $c\n"
     # }

      #--- je s�pare les coordonnees des autres donn�es
      set ligne2 [lindex $ligneList 2]
      set ra  ""
      set dec ""
      set objType ""
      set detail ""
      scan $ligne2 "%s %s %s %\[^\r\] " ra dec objType detail

     # console::disp "CDC ----------------\n"
     # console::disp "CDC entry ra=$ra\n"
     # console::disp "CDC entry dec=$dec\n"
     # console::disp "CDC entry objType=$objType\n"
     # console::disp "CDC entry detail=$detail \n"

      #--- Mise en forme de ra
      set ra [lindex [split $ra "."] 0]

      #--- Mise en forme de dec
      #--- je remplace les unites par d, m, s
      set dec  [string map { "\�" d "�" d "\'" m "\"" s } $dec ]
      #--- je remplace le quatrieme caractere par "d"
      set dec  [string replace $dec 3 3 "d" ]
      #--- je supprime les diziemes de secondes apres le point decimal
      set dec [lindex [split $dec "."] 0]

      #--- Mise en forme de objName
      if { $objType=="" } {
         #--- si pas d'objet selectionne dans cartes du ciel,
         #--- j'affiche les coordonn�es du centre de la carte
         set ligne1 [lindex $ligneList 1]
         scan $ligne1 "RA: %s DEC:%s" ra dec
         if { $ra== "" || $dec =="" } {
            console::affiche_erreur "$caption(carteducielv2,coord_no_found)\n"
            return
         }
         set objName "centre cdc"
      } else {
         #--- j'extrait les coordonn�es du detail de la ligne2
         set usualName ""
         set ba ""
         set fl ""
         set const ""
         set gsc ""
         set hr ""
         set hd ""
         set bd ""
         set sao ""
         set tyc ""
         set ngc ""
         set pgc ""
         set ugc ""
         set ocl ""
         set lbn ""
         set png ""
         set messier ""
         set planete ""

         set index [string first ";" $detail]
         if { $index >= 0 } {
            set index1 [expr $index +1]
            #--- je cherche le point virgule suivant
            set index2 [string first ";" $detail $index1]
            if { $index2 >= 0 } {
               set index2 [expr $index2 - 1 ]
               set usualName [string trim [string range $detail $index1 $index2 ] ]
            }
         }

         #--- je recherche tous les catalogues cites dans la ligne de detail
         set index [string first "Fl:" $detail]
         if { $index >= 0 } {
            set fl [string trim [string range $detail [expr $index + 3] [expr $index + 6] ] ]
         }
         set index [string first "Ba:" $detail]
         if { $index >= 0 } {
            set ba [string trim [string range $detail [expr $index + 3] [expr $index + 6] ] ]
         }
         set index [string first "const:" $detail]
         if { $index >= 0 } {
            set const [string trim [string range $detail [expr $index + 6] [expr $index + 9] ] ]
         }
         set index [string first "M " $detail]
         if { $index >= 0 } {
            set messier [string trim [string range $detail [expr $index + 2] [expr $index + 5] ] ]
         }
         set index [string first "GSC" $detail]
         if { $index >= 0 } {
            set gsc [string trim [string range $detail $index [expr $index + 12] ] ]
         }
         set index [string first "TYC" $detail]
         if { $index >= 0 } {
            set tyc [string range $detail $index [expr $index + 15 ] ]
         }
         set index [string first "HD" $detail]
         if { $index >= 0 } {
            set hd [string range $detail $index [expr $index + 8 ] ]
         }
         set index [string first "BD" $detail]
         if { $index >= 0 } {
            set bd [string range $detail $index [expr $index + 10 ] ]
         }
         set index [string first "HR" $detail]
         if { $index >= 0 } {
            set hr [string range $detail $index [expr $index + 7 ] ]
         }
         set index [string first "SAO" $detail]
         if { $index >= 0 } {
            set sao [string range $detail $index [expr $index + 9 ] ]
         }
         set index [string first "NGC" $detail]
         if { $index >= 0 } {
            set ngc [string range $detail $index [expr $index + 9 ] ]
         }
         set index [string first "UGC" $detail]
         if { $index >= 0 } {
            set ugc [string range $detail $index [expr $index + 9 ] ]
         }
         set index [string first "PGC" $detail]
         if { $index >= 0 } {
            set pgc [string range $detail $index [expr $index + 8 ] ]
         }
         set index [string first "PNG" $detail]
         if { $index >= 0 } {
            set png [string range $detail $index [expr $index + 13 ] ]
         }
         set index [string first "LBN" $detail]
         if { $index >= 0 } {
            set lbn [string range $detail $index [expr $index + 6 ] ]
         }
         set index [string first "OCL" $detail]
         if { $index >= 0 } {
            set ocl [string range $detail $index [expr $index + 6 ] ]
         }
      }

      #--- je choisi la reference et le catalogue en fonction du type de l'objet
      if { $objType=="*" } {
         #--- pour une �toile : nom usuel ou numero d'un catalogue
         #--- intervertir les lignes "if ... elseif " pour changer la priorite des catalogues
         if { $usualName!="" } {
            #--- je retiens d'abord le nom usuel s'il existe
            set objName $usualName
         } elseif { $ba != "" } {
            set objName "$ba $const"
         } elseif { $fl != "" } {
            set objName "$fl $const"
         } elseif { $gsc != "" } {
            set objName "$gsc"
         } elseif { $sao != "" } {
            set objName "SAO $sao"
         } elseif { $hr != "" } {
            set objName "$hr"
         } elseif { $tyc != "" } {
            set objName "$tyc"
         } elseif { $hd != "" } {
            set objName "$hd"
         } elseif { $bd != "" } {
            set objName "$bd"
         }
      } elseif { $objType=="Gb" || $objType=="Gx" || $objType=="Nb" || $objType=="OC" || $objType=="Pl" } {
         #--- pour une galaxie , n�buleuse ou un amas
         #--- intervertir les lignes "if ... elseif " pour changer la priorite des catalogues
         if { $messier!="" } {
            set objName "M$messier"
         } elseif { $ngc != "" } {
            set objName "$ngc"
         } elseif { $ugc != "" } {
            #--- je supprime les espaces entre UGC et le numero de galaxie
            set objName "UGC[string trim [string range $ugc 3 end ] ]"
         } elseif { $pgc != "" } {
            set objName $pgc
         } elseif { $ocl != "" } {
            set objName $ocl
         } elseif { $lbn != "" } {
            set objName $lbn
         } elseif { $png != "" } {
            set objName $png
         }
      } elseif { $objType=="As" } {
         #--- pour un ast�roide, je prends les 17 premiers caracteres
         set objName [string trim [string range $detail 0 17  ] ]
      } elseif { $objType=="P" } {
         #--- pour une planete : je prends le premier mot
         set objName [lindex [split $detail " " ] 0 ]
      } elseif { $objType=="Cm" } {
         #--- pour une comete : je prends jusqu'� la parenthese fermante
         set index [string first ")" $detail]
         set objName [string trim [string range $detail 0 $index ] ]
      } elseif { $objType=="C2" } {
         set objName [string trim [lindex [split $detail "Dim" ] 0 ] ]
         if { [string range $objName 0 2] == "UGC" } {
            #--- Pour le catalogue externe UGC genere sans catgen
            #--- je supprime les espaces entre UGC et le numero de galaxie
            set objName "UGC[string trim [string range $objName 3 end ] ]"
         }
      }

     # console::disp "CDC result ra=$ra\n"
     # console::disp "CDC result dec=$dec\n"
     # console::disp "CDC result objName=$objName\n"

      return [list $ra $dec $objName ]
   }

   #------------------------------------------------------------
   #  getRaDecFov {}
   #     recupere les coordonn�es et la taille du champ affiche dans carteduciel
   #------------------------------------------------------------
   proc getRaDecFov { } {
      global caption

      if { [catch {dde request ciel DdeSkyChart DdeData } result ] } {
         console::affiche_erreur "$caption(carteducielv2,no_connect)\n"
         tk_messageBox -message "$caption(carteducielv2,no_connect)\n $result" -icon info
         return ""
      }

      #--- je decoupe les 5 lignes d'information
      set ligneList [split $result "\n"]

      #--- je s�pare les coordonnees de la ligne 1

      set ligne1 [lindex $ligneList 1]
      set ra  ""
      set dec ""
      set fov ""
      set dummy ""
      scan $ligne1 "RA:%s DEC:%s FOV:%s%\[^\r\]" ra dec fov dummy

      #--- Mise en forme de ra
     # set ra  [string map { "h" " " "m" " " "s" " " } $ra ]
      #--- je supprime les diziemes de secondes apres le point decimal
      set ra [lindex [split $ra "."] 0]
      #--- je rajoute le "s" des secondes
      append ra "s"

      #--- Mise en forme de dec
      #--- je remplace les unites par dms
      set dec  [string map { "\�" "d" "�" "d" "\'" "m" "\"" "s" } $dec ]
      #--- je remplace le quatrieme caractere par un "d"
      set dec  [string replace $dec 3 3 "d" ]
      #--- je supprime les diziemes de secondes apres le point decimal
      set dec [lindex [split $dec "."] 0]
      #--- je rajoute le "s" des secondes
      append dec "s"

      #--- Mise en forme de fov
      #--- je remplace les unites par des espaces
      set fov  [string map { "\�" "d" "�" "d" "\'" "m" "\"" "s" } $fov ]
      #--- je remplace le quatrieme caractere par un "d"
      set fov  [string replace $fov 3 3 "d" ]
      #--- je supprime le signe "+" au debut
      set fov  [string range $fov 1 end ]

     # console::disp "getRaDecFov ligne1=$ligne1 \n"
     # console::disp "getRaDecFov ra=$ra dec=$dec fov=$fov###\n\n"
      return [list $ra $dec $fov]
   }

   #------------------------------------------------------------
   #  sendDDECommand {}
   #     envoie une commande sur la liaison DDE
   #     retourne la reponse fournie par CDC
   #     ou "" si erreur
   #------------------------------------------------------------
   proc sendDDECommand { command } {
      global caption

      #--- encodage de la command  (desactive le codage UTF8)
      set command [encoding convertfrom identity $command]
      #console::disp "carteducielv2::sendDDECommand command=$command \n"
      #--- envoi la command a carteduciel
      set erreur [catch {dde poke ciel DdeSkyChart DdeData $command } result ]
      if { $erreur } {
         #--- si erreur :
         set choix [tk_messageBox -type yesno -icon warning -title "$caption(carteducielv2,attention)" \
            -message "$caption(carteducielv2,option) $caption(carteducielv2,creation)\n\n$caption(carteducielv2,lance)"]
         if { $choix == "yes" } {
            set erreur [launch]
            if { $erreur == "1" } {
               tk_messageBox -type ok -icon error -title "$caption(carteducielv2,attention)" \
                  -message "$caption(carteducielv2,verification)"
               return ""
            }
            #--- nouvelle tentative
            set erreur [catch {dde poke ciel DdeSkyChart DdeData $command } result ]

            if { $erreur == 1 } {
               console::affiche_erreur "$caption(carteducielv2,no_connect)\n"
               tk_messageBox -message "$caption(carteducielv2,no_connect)" -icon info
               set result ""
            }
         } else {
            set result ""
         }
      }
      return $result
   }

   #------------------------------------------------------------
   # launch
   #    Lance le logiciel CarteDuciel V2 pour la creation de cartes de champ
   #
   # return 0 (OK) , 1 (error)
   #------------------------------------------------------------
   proc launch { } {
      global audace caption conf

      #--- Initialisation
      #--- Recherche l'absence de l'entry conf(carteducielv2,binarypath)
      if { [info exists conf(carteducielv2,binarypath)] == 0 } {
         tk_messageBox -type ok -icon error -title "$caption(carteducielv2,attention)" \
            -message "$caption(carteducielv2,verification)"
         return "1"
      }
      #--- Stocke le nom du chemin courant et du programme dans une variable
      set filename $conf(carteducielv2,binarypath)
      #--- Stocke le nom du chemin courant dans une variable
      set pwd0 [pwd]
      #--- Extrait le nom de dossier
      set dirname [file dirname "$conf(carteducielv2,binarypath)"]
      #--- Place temporairement AudeLA dans le dossier de CDC
      cd "$dirname"
      #--- Pr�pare l'ouverture du logiciel
      set a_effectuer "exec \"$conf(carteducielv2,binarypath)\" \"$filename\" &"
      #--- Ouvre le logiciel
      if [catch $a_effectuer input] {
         #--- Affichage du message d'erreur sur la console
         ::console::affiche_erreur "$caption(carteducielv2,rate)\n"
         #--- Ouvre la fenetre de configuration des editeurs
         set conf(confCat) "::carteducielv2"
         ::confCat::run
         #--- Extrait le nom de dossier
         set dirname [file dirname "$conf(carteducielv2,binarypath)"]
         #--- Place temporairement AudeLA dans le dossier de CDC
         cd "$dirname"
         #--- Pr�pare l'ouverture du logiciel
         set a_effectuer "exec \"$conf(carteducielv2,binarypath)\" \"$filename\" &"
         #--- Affichage sur la console
         set filename $conf(carteducielv2,binarypath)
         if [catch $a_effectuer input] {
            set audace(current_edit) $input
         }
      }
      cd "$pwd0"
      #--- J'attends que carteduciel soit completement demarre
      after 2000
      return "0"
   }
}

