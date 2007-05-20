#
# Fichier : carteducielv3.tcl
# Description : Driver de communication avec "Cartes Du Ciel" (communication TCP)
#    pour afficher la carte du champ des objets selectionnes dans AudeLA
#    Fonctionne avec Windows et Linux
# Auteur : Michel PUJOL
# Mise a jour $Id: carteducielv3.tcl,v 1.12 2007-05-20 09:22:28 robertdelmas Exp $
#

namespace eval carteducielv3 {
   package provide carteducielv3 1.0
   source [ file join [file dirname [info script]] carteducielv3.cap ]

   #------------------------------------------------------------
   #  initPlugin
   #     initialise le plugin
   #------------------------------------------------------------
   proc initPlugin { } {
      #--- Je cree les variables dans conf(...)
      initConf
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

      return "$caption(carteducielv3,titre)"
   }

   #------------------------------------------------------------
   #  getHelp
   #     retourne la documentation du driver
   #
   #  return "nom_driver.htm"
   #------------------------------------------------------------
   proc getHelp { } {
      return "carteducielv3.htm"
   }

   #------------------------------------------------------------
   #  initConf
   #     initialise les parametres dans le tableau conf()
   #
   #  return rien
   #------------------------------------------------------------
   proc initConf { } {
      global conf

      #--- je fixe le nom du fichier executable en fonction de l'OS
      if { $::tcl_platform(os) == "Linux"  } {
         if { ! [ info exists conf(carteducielv3,binaryname) ] } { set conf(carteducielv3,binaryname)    "skychart" }
      } else {
         if { ! [ info exists conf(carteducielv3,binaryname) ] } { set conf(carteducielv3,binaryname)    "cdc.exe" }
      }

      if { ! [ info exists conf(carteducielv3,fixedfovstate) ] } { set conf(carteducielv3,fixedfovstate) "1" }
      if { ! [ info exists conf(carteducielv3,fixedfovvalue) ] } { set conf(carteducielv3,fixedfovvalue) "05d00m00ss" }
      if { ! [ info exists conf(carteducielv3,dirname) ] }       { set conf(carteducielv3,dirname)       "c:/" }
      if { ! [ info exists conf(carteducielv3,binarypath) ] }    { set conf(carteducielv3,binarypath)    " " }
      if { ! [ info exists conf(carteducielv3,localserver) ] }   { set conf(carteducielv3,localserver)   "1" }
      if { ! [ info exists conf(carteducielv3,host) ] }          { set conf(carteducielv3,host)          "127.0.0.1" }
      if { ! [ info exists conf(carteducielv3,port) ] }          { set conf(carteducielv3,port)          "3292" }

      set private(socket) ""
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

      if { ( $widget(dirname) != "" ) && ( $widget(binaryname) != "" ) } {
         #--- Fichier a rechercher
         set fichier_recherche $widget(binaryname)
         #--- Sur les dossiers
         set repertoire $::carteducielv3::widget(dirname)

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
         #--- Gestion du bouton de recherche
         $widget(frm).frame3.recherche configure -relief raised -state normal
         update
         return
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

      set widget(fixedfovstate) "$conf(carteducielv3,fixedfovstate)"
      set widget(fixedfovvalue) "$conf(carteducielv3,fixedfovvalue)"
      set widget(binaryname)    "$conf(carteducielv3,binaryname)"
      set widget(dirname)       "$conf(carteducielv3,dirname)"
      set widget(binarypath)    "$conf(carteducielv3,binarypath)"
      set widget(localserver)   "$conf(carteducielv3,localserver)"
      set widget(cdchost)       "$conf(carteducielv3,host)"
      set widget(cdcport)       "$conf(carteducielv3,port)"

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

      set conf(carteducielv3,fixedfovstate) "$widget(fixedfovstate)"
      set conf(carteducielv3,fixedfovvalue) "$widget(fixedfovvalue)"
      set conf(carteducielv3,binaryname)    "$widget(binaryname)"
      set conf(carteducielv3,dirname)       "$widget(dirname)"
      set conf(carteducielv3,binarypath)    "$widget(binarypath)"
      set conf(carteducielv3,localserver)   "$widget(localserver)"
      set conf(carteducielv3,host)          "$widget(cdchost)"
      set conf(carteducielv3,port)          "$widget(cdcport)"
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
      pack $frm.frame4 -side top -fill both -expand 1

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -side bottom -fill x

      #--- Definition du champ (FOV)
      label $frm.frame1.labFOV -text "$caption(carteducielv3,fov_label)"
      pack $frm.frame1.labFOV -anchor center -side left -padx 10 -pady 10

      checkbutton $frm.frame1.fovState -text "$caption(carteducielv3,fov_state)" \
         -highlightthickness 0 -variable ::carteducielv3::widget(fixedfovstate)
      pack $frm.frame1.fovState -anchor center -side left -padx 10 -pady 5

      label $frm.frame1.labFovValue -text "$caption(carteducielv3,fov_value)"
      pack $frm.frame1.labFovValue -anchor center -side left -padx 10 -pady 10

      entry $frm.frame1.fovValue -textvariable ::carteducielv3::widget(fixedfovvalue) -width 10
      pack $frm.frame1.fovValue -anchor center -side left -padx 10 -pady 5

      #--- Initialisation du chemin du fichier
      label $frm.frame2.labFichier -text "$caption(carteducielv3,fichier)"
      pack $frm.frame2.labFichier -anchor center -side left -padx 10 -pady 10

      entry $frm.frame2.nomFichier -textvariable ::carteducielv3::widget(binaryname) -width 12 -justify center
      pack $frm.frame2.nomFichier -anchor center -side left -padx 10 -pady 5

      label $frm.frame2.labAPartirDe -text "$caption(carteducielv3,a_partir_de)"
      pack $frm.frame2.labAPartirDe -anchor center -side left -padx 10 -pady 10

      entry $frm.frame2.nomDossier -textvariable ::carteducielv3::widget(dirname) -width 20
      pack $frm.frame2.nomDossier -side left -padx 10 -pady 5

      button $frm.frame2.explore -text "$caption(carteducielv3,parcourir)" -width 1 \
         -command {
            set ::carteducielv3::widget(dirname) [ tk_chooseDirectory -title "$caption(carteducielv3,dossier)" \
            -initialdir ".." -parent $::carteducielv3::widget(frm) ]
         }
      pack $frm.frame2.explore -side left -padx 10 -pady 5 -ipady 5

      button $frm.frame3.recherche -text "$caption(carteducielv3,rechercher)" -relief raised -state normal \
         -command { ::carteducielv3::searchFile }
      pack $frm.frame3.recherche -anchor center -side left -padx 10 -pady 7 -ipadx 10 -ipady 5

      entry $frm.frame3.chemin -textvariable ::carteducielv3::widget(binarypath)
      pack $frm.frame3.chemin -anchor center -side left -padx 10 -fill x -expand 1

      button $frm.frame3.explore -text "$caption(carteducielv3,parcourir)" -width 1 \
         -command {
            set ::carteducielv3::widget(binarypath) [ ::tkutil::box_load $::carteducielv3::widget(frm) \
               $::carteducielv3::widget(dirname) $audace(bufNo) "11" ]
         }
      pack $frm.frame3.explore -side right -padx 10 -pady 5 -ipady 5

      #--- Adresse IP du serveur distant
      label $frm.frame4.labcdchost -text "$caption(carteducielv3,cdchost)"
      pack $frm.frame4.labcdchost -anchor center -side left -padx 10 -pady 7

      entry $frm.frame4.cdchost -width 17 -textvariable ::carteducielv3::widget(cdchost)
      pack $frm.frame4.cdchost -anchor center -side left -padx 15 -pady 10

      label $frm.frame4.labcdcport -text "$caption(carteducielv3,cdcport)"
      pack $frm.frame4.labcdcport -anchor center -side left -padx 10 -pady 7

      entry $frm.frame4.cdcport -width 5 -textvariable ::carteducielv3::widget(cdcport)
      pack $frm.frame4.cdcport -anchor center -side left -padx 5 -pady 7

      button $frm.frame4.ping -text "$caption(carteducielv3,testping)" -relief raised -state normal \
         -command {
            global caption
            global confCam

            set res [::ping $::carteducielv3::widget(cdchost) ]
            set res1 [lindex $res 0]
            set res2 [lindex $res 1]
            if {$res1==1} {
               set tres1 "$caption(carteducielv3,appareil_connecte) $::carteducielv3::widget(cdchost)"
            } else {
               set tres1 "$caption(carteducielv3,pas_appareil_connecte) $::carteducielv3::widget(cdchost)"
            }
            set tres2 "$caption(carteducielv3,message_ping)"
            tk_messageBox -message "$tres1.\n$tres2 $res2" -icon info
         }
      pack $frm.frame4.ping -anchor center -side top -pady 7 -ipadx 10 -ipady 5 -expand true

      #--- Site web officiel de Cartes du Ciel
      label $frm.frame5.labSite -text "$caption(carteducielv3,site_web)"
      pack $frm.frame5.labSite -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame5 "$caption(carteducielv3,site_web_ref)" \
         "$caption(carteducielv3,site_web_ref)" ]
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
      set ready 0
      return  $ready
   }

   #==============================================================
   # Fonctions specifiques du driver de la categorie "catalog"
   #==============================================================

   #------------------------------------------------------------
   # gotoObject
   # Affiche la carte de champ de l'objet choisi
   #  parametres :
   #     nom_objet :    nom de l'objet (ex: "NGC7000")
   #     ad :           ascension droite   (ex: "16h41m42s")
   #     dec :          declinaison     (ex: "+36d28m00s")
   #     zoom_objet :   champ 1 � 10
   #     avant_plan :   1=mettre la carte au premier plan 0=ne pas mettre au premier plan
   #------------------------------------------------------------
   proc gotoObject { nom_objet ad dec zoom_objet avant_plan } {
      set result "0"
     # console::disp "::carteducielv3::gotoObject $nom_objet, $ad, $dec, $zoom_objet, $avant_plan, \n"
      if { $nom_objet != "#etoile#" && $nom_objet != "" } {
         selectObject $nom_objet
      } else {
         moveCoord $ad $dec
      }
   }

   #------------------------------------------------------------
   #  moveCoord radec
   #     centre la fenetre de carteduciel sur les coordonnees passes en parametre
   #     et fixe le champ de diametre fov
   #     envoie a carteducciel  "MOVE RA: xxhxxmxxs.00s DEC:xxdxx'xx" FOV:xxdxx'xx"
   #
   #  return 0 (OK) , 1(error)
   #------------------------------------------------------------
   proc moveCoord { ra dec } {
      global conf

      #--- je fixe la taille du champ de la carte
      if { $conf(carteducielv3,fixedfovstate) != 0 } {
         #--- j'utilise le champ fixe
         set fov $conf(carteducielv3,fixedfovvalue)
         #--- je remplace les unites par des espaces
         if { [ sendRequest "SETFOV $fov" ] != "OK!" } {
            return 1
         }
      }

      set command "SETRA RA:$ra"
      if { [ sendRequest $command ] != "OK!" } {
         return 1
      }

      set command "SETDEC DEC:$dec"
      if { [ sendRequest $command ] != "OK!" } {
         return 1
      }

      if { [ sendRequest "REDRAW" ] != "OK!" } {
         return 1
      }

      return 0
   }

   #------------------------------------------------------------
   #  selectObject
   #     selectionne un objet dans CarteDuCiel
   #
   #  return "0" (OK) , "1"(error)
   #------------------------------------------------------------
   proc selectObject { objectName } {
      global conf

      #--- je fixe la taille du champ de la carte
      if { $conf(carteducielv3,fixedfovstate) == 1 } {
         #--- j'utilise le champ fixe
         set fov $conf(carteducielv3,fixedfovvalue)
         if { [ sendRequest "SETFOV $fov" ] != "OK!" } {
            return 1
         }
      }

      #--- j'envoie la requete vers carteducielv3
      if { [ sendRequest "search $objectName" ] == "Not found!" } {
         return 1
      }

      return 0
   }

   #------------------------------------------------------------
   #  getSelectedObject {}
   #     recupere les coordonn�es et le nom de l'objet selectionne dans CarteDuCiel
   #
   #  return [list $ra $dec $objName ]
   #     $ra : right ascension  (ex: "16h41m42")
   #     $dec : declinaison     (ex: "+36d28m00")
   #     $objName: object name  (ex: "M 13")
   #
   #     ou  ""  si erreur
   #
   #
   #  Remarque : Si aucun objet n'est selectionne dans CarteDuCiel,
   #  alors getSelectedObject retourne les coordonn�es du centre de la carte
   #
   #  Description de l'interface Audela / CarteDuCiel
   #  -------------------------------------
   #  Requete TCP envoyee a CarteDuCiel :
   #     puts socket "GETMSGBOX"
   #  Reponse DDE retournee par CarteDuCiel :
   #     ligne : position du centre et champ de vision de la carte
   #
   #  exemple de reponse :
   #     ligne : 14h15m39.70s +19�10'57.0"   * HR 5340 HD124897 Fl: 16 Ba:Alp  const:Boo mV:-0.04 b-v: 1.23 sp:  K1.5IIIFe-0.5      pm:-1.093 -1.998 ;ARCTURUS; Haris-el-sema
   #
   #     Les coordonn�es et le nom de l'objet sont extraits de la ligne 2
   #     Le autres lignes ne sont pas utilisees.
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
   #       SI existe un point virgule dans $detail ALORS
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
   #     SI $objType = "As" ALORS
   #       $objName = 17 premiers caracteres de $detail
   #     FINSI
   #
   #     SI $objType = "Cm"  ALORS
   #       $objName = debut de detail jusqu'a la premiere parenthese fermante ")"
   #     FINSI
   #
   #     SI $objType = "P" ALORS
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
   #  le nom retenu depend de l'ordre des SI $catName=... SINON ..
   #  Si vous preferez retenir en priorit� le nom de l'objet d'un autre catalogue
   #  il suffit de changer l'ordre des SI $catName=... SINON ..
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

      set result [ sendRequest "GETMSGBOX" ]
      if { $result == "" } {
         return ""
      }

      #--- je s�pare les coordonnees des autres donn�es
      set ligne $result
      set cr  ""
      set ra  ""
      set dec ""
      set objType ""
      set detail ""
      scan $ligne "%s %s %s %s %\[^\r\] " cr ra dec objType detail

     # console::disp "CDC ----------------\n"
     # console::disp "CDC entry cr=$cr\n"
     # console::disp "CDC entry ra=$ra\n"
     # console::disp "CDC entry dec=$dec\n"
     # console::disp "CDC entry objType=$objType\n"
     # console::disp "CDC entry detail=$detail \n"

      #--- Mise en forme de ra
      set ra [lindex [split $ra "."] 0]

      #--- Mise en forme de dec
      #--- je remplace les unites par d, m, s
      set dec [string map { "\�" d "�" d "\'" m "\"" s } $dec ]
      #--- je remplace le quatrieme caractere par "d"
      set dec [string replace $dec 3 3 "d" ]
      #--- je supprime les diziemes de secondes apres le point decimal
      set dec [lindex [split $dec "."] 0]
      #--- j'ajoute l'unite des secondes
      append dec "s"

      #--- Mise en forme de objName
      if { $objType=="" || $objType=="port:" } {
         console::affiche_erreur "$caption(carteducielv3,no_object_select)\n"
         return ""
      } else {
         #--- j'extrait les coordonn�es du detail de la ligne2
         set usualName ""
         set bsc ""
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

         #--- je recherche tous les catalogues cites dans la ligne de detail
         set index [string first "Common Name:" $detail]
         if { $index >= 0 } {
            set usualName [string trim [string range $detail [expr $index + 12] [string length $detail] ] ]
         }
         set index [string first "BSC" $detail]
         if { $index >= 0 } {
            set bsc [string trim [string range $detail [expr $index + 3] [expr [string first "mV:" $detail $index] -1] ] ]
         }
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
            set messier [string trim [string range $detail [expr $index + 2] [expr $index + 4] ] ]
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
            set ngc [string range $detail $index [expr $index + 8 ] ]
         }
         set index [string first "UGC" $detail]
         if { $index >= 0 } {
            set ugc [string range $detail $index [expr [string first " m" $detail $index] -1] ]
         }
         set index [string first "PGC" $detail]
         if { $index >= 0 } {
            set pgc [string range $detail $index [expr [string first " " $detail $index] -1] ]
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
         } elseif { $bsc != "" } {
            set objName "$bsc"
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
         #--- pour une galaxie, n�buleuse ou un amas
         #--- intervertir les lignes "if ... elseif " pour changer la priorite des catalogues
         if { $messier!="" } {
            set objName "M$messier"
         } elseif { $ngc != "" } {
            set objName "$ngc"
         } elseif { $ugc != "" } {
            # je supprime les espaces entre UGC et le numero de galaxie
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
         #--- pour une comete: je prends jusqu'� la parenthese fermante.
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
   # launch
   #    Lance le logiciel CarteDuciel V3
   #
   # return 0 (OK) , 1 (error)
   #------------------------------------------------------------
   proc launch { } {
      global audace caption conf

      #--- Initialisation
      #--- Recherche l'absence de l'entry conf(carteducielv3,binarypath)
      if { [info exists conf(carteducielv3,binarypath)] == 0 } {
         tk_messageBox -type ok -icon error -title "$caption(carteducielv3,attention)" \
            -message "$caption(carteducielv3,verification)"
         return "1"
      }
      #--- Stocke le nom du chemin courant et du programme dans une variable
      set filename $conf(carteducielv3,binarypath)
      #--- Stocke le nom du chemin courant dans une variable
      set pwd0 [pwd]
      #--- Extrait le nom de dossier
      set dirname [file dirname "$conf(carteducielv3,binarypath)"]
      #--- Place temporairement AudeLA dans le dossier de CDC
      cd "$dirname"
      #--- Pr�pare l'ouverture du logiciel
      set a_effectuer "exec \"$filename\" &"
      #--- Ouvre le logiciel
      if [catch $a_effectuer input] {
         #--- Affichage du message d'erreur sur la console
         ::console::affiche_erreur "$caption(carteducielv3,rate)\n"
         #--- Ouvre la fenetre de configuration des editeurs
         set conf(confCat) "::carteducielv3"
         ::confCat::run
         #--- Extrait le nom de dossier
         set dirname [file dirname "$conf(carteducielv3,binarypath)"]
         #--- Place temporairement AudeLA dans le dossier de CDC
         cd "$dirname"
         #--- Pr�pare l'ouverture du logiciel
         set a_effectuer "exec \"$filename\" &"
         #--- Affichage sur la console
      }
      cd "$pwd0"
      after 2000
      return "0"
   }

   #==============================================================
   # Fonctions comunication avec carteducielv3
   #==============================================================

   #------------------------------------------------------------
   #  sendRequest {}
   #     envoie une commande sur la liaison TCP
   #     retourne la reponse fournie par CDC
   #     ou "" si erreur
   #------------------------------------------------------------
   proc sendRequest { req } {
      variable private
      global caption

      #--- j'ouvre la connexion vers CarteDuCiel
      if { [ openConnection ] == 1 } {
         #--- si erreur :
         set choix [tk_messageBox -type yesno -icon warning -title "$caption(carteducielv3,attention)" \
            -message "$caption(carteducielv3,option) $caption(carteducielv3,creation)\n\n$caption(carteducielv3,lance)"]
         if { $choix == "yes" } {
            set erreur [launch]
            if { $erreur == "1" } {
               tk_messageBox -type ok -icon error -title "$caption(carteducielv3,attention)" \
                  -message "$caption(carteducielv3,verification)"
               return ""
            }
            #--- nouvelle tentative
            if { [ openConnection ] == 1 } {
               console::affiche_erreur "$caption(carteducielv3,no_connect)\n"
               tk_messageBox -message "$caption(carteducielv3,no_connect)" -icon info
               return ""
            }
         } else {
            return ""
         }
      }

      set result ""
      catch {
        # console::disp "sendRequest socket=$private(socket)\n"
        # console::disp "sendRequest REQ= $req\n"
         puts  $private(socket) $req
         flush $private(socket)
         set result [gets $private(socket)]
        # console::disp "sendRequest REP= $result\n"
      }

      #--- je ferme la connexion
      closeConnection
      return $result
   }

   #------------------------------------------------------------
   #  openConnection {}
   #     ouvre la connexion vers CarteDuCiel V3 (socket TCP)
   #
   #  return 0 (OK) , 1(error)
   #------------------------------------------------------------
   proc openConnection { } {
      variable private
      global conf

      set result 1
      catch {
        # console::disp "openConnection host=$conf(carteducielv3,host) port=$conf(carteducielv3,port)\n"

         set private(socket) [socket $conf(carteducielv3,host) $conf(carteducielv3,port)]
        # console::disp "openConnection private(socket)=$private(socket)\n"
         if { [string compare -length 7 $private(socket) "Failed!"] == 0 } {
            set result 1
         } else {
            set response [gets $private(socket)]
           # console::disp "CONNECT= $response\n"
            set result 0
         }

      } msg

      return $result
   }

   #------------------------------------------------------------
   #  closeConnection {}
   #     ferme la liaison TCP
   #
   #  return  : nothing
   #------------------------------------------------------------
   proc closeConnection { } {
      variable private

      puts  $private(socket) "QUIT"
      close $private(socket)
     # console::disp "closeConnection socket=$private(socket)\n"
   }

}

