#
# Fichier : guide.tcl
# Description : Plugin de communication avec "guide"
# Auteur : Robert DELMAS
# Mise à jour $Id$
#

namespace eval guide {
   package provide guide 2.0
   source [ file join [file dirname [info script]] guide.cap ]

   #------------------------------------------------------------
   # install
   #    installe le plugin et la dll
   #------------------------------------------------------------
   proc install { } {
      if { $::tcl_platform(platform) == "windows" } {
         #--- je deplace libgs.dll dans le repertoire audela/bin
         set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::guide::getPluginType]] "guide" "libgs.dll"]
         if { [ file exists $sourceFileName ] } {
            ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
         }
         #--- j'affiche le message de fin de mise a jour du plugin
         ::audace::appendUpdateMessage [ format $::caption(guide,installNewVersion) $sourceFileName [package version guide] ]
      }
   }

   #------------------------------------------------------------
   #  initPlugin
   #     initialise le plugin
   #------------------------------------------------------------
   proc initPlugin { } {
      #--- Je charge les variables d'environnement
      initConf
   }

   #------------------------------------------------------------
   #  getPluginProperty
   #     retourne la valeur de la propriete
   #
   # parametre :
   #    propertyName : nom de la propriete
   # return : valeur de la propriete ou "" si la propriete n'existe pas
   #------------------------------------------------------------
   proc getPluginProperty { propertyName } {

   }

   #------------------------------------------------------------
   #  getPluginTitle
   #     retourne le label du plugin dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(guide,titre)"
   }

   #------------------------------------------------------------
   #  getPluginHelp
   #     retourne la documentation du plugin
   #
   #  return "nom_plugin.htm"
   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "guide.htm"
   }

   #------------------------------------------------------------
   #  getPluginType
   #     retourne le type de plugin
   #------------------------------------------------------------
   proc getPluginType { } {
      return "chart"
   }

   #------------------------------------------------------------
   #  getPluginOS
   #     retourne le ou les OS de fonctionnement du plugin
   #------------------------------------------------------------
   proc getPluginOS { } {
      return [ list Windows ]
   }

   #------------------------------------------------------------
   #  initConf
   #     initialise les parametres dans le tableau conf()
   #
   #  return rien
   #------------------------------------------------------------
   proc initConf { } {
      global conf

      if { $::tcl_platform(os) == "Linux" } {
         if { ! [ info exists conf(guide,binarypath) ] } { set conf(guide,binarypath) [ file join / usr bin ] }
      } else {
         if { ! [ info exists conf(guide,binarypath) ] } { set conf(guide,binarypath) "$::env(ProgramFiles)" }
      }

      return
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

      set widget(binarypath) "$conf(guide,binarypath)"
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

      set conf(guide,binarypath) "$widget(binarypath)"
   }

   #------------------------------------------------------------
   #  fillConfigPage
   #     fenetre de configuration du plugin
   #
   #  return rien
   #------------------------------------------------------------
   proc fillConfigPage { frm } {
      variable widget
      global audace caption

      #--- Je memorise la reference de la frame
      set widget(frm) $frm

      #--- J'initialise les valeurs
      confToWidget

      #--- Recherche manuelle de l'executable de Guide
      frame $frm.frame1 -borderwidth 0 -relief raised

         label $frm.frame1.recherche -text "$caption(guide,rechercher)"
         pack $frm.frame1.recherche -anchor center -side left  -padx 10 -pady 7 -ipadx 10 -ipady 5

         entry $frm.frame1.chemin -textvariable ::guide::widget(binarypath)
         pack $frm.frame1.chemin -anchor center -side left -padx 10 -fill x -expand 1

         button $frm.frame1.explore -text "$caption(guide,parcourir)" -width 1 \
            -command "::guide::searchFile"
         pack $frm.frame1.explore -side right -padx 10 -pady 5 -ipady 5

      pack $frm.frame1 -side top -fill x

      #--- Site web officiel de Guide
      frame $frm.frame2 -borderwidth 0 -relief raised

         label $frm.frame2.labSite -text "$caption(guide,site_web)"
         pack $frm.frame2.labSite -side top -fill x -pady 2

         set labelName [ ::confCat::createUrlLabel $frm.frame2 "$caption(guide,site_web_ref)" \
            "$caption(guide,site_web_ref)" ]
         pack $labelName -side top -fill x -pady 2

      pack $frm.frame2 -side bottom -fill x

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
      #--- Chargement de la librairie Guide pour Windows seulement
      if { [ lindex $::tcl_platform(os) 0 ] == "Windows" } {
         catch { load libgs.dll }
      }
      return
   }

   #------------------------------------------------------------
   #  deletePluginInstance
   #     suppprime l'instance du plugin
   #
   #  return rien
   #------------------------------------------------------------
   proc deletePluginInstance { } {
      #--- Rien a faire pour Guide
      return
   }

   #------------------------------------------------------------
   #  isReady
   #     informe de l'etat de fonctionnement du plugin
   #
   #  return 0 (ready), 1 (not ready)
   #------------------------------------------------------------
   proc isReady { } {
      #--- Je teste si la librairie libgs.dll est chargee
      set erreur [ catch { gs_version } result ]
      if { $erreur != "0" || $result == "" } {
         #--- La librairie libgs.dll est chargee
         set ready 1
      } else {
         set ready 0
      }
      return $ready
   }

   #------------------------------------------------------------
   #  searchFile
   #     lancement de la recherche du fichier executable de Guide
   #
   #  return rien
   #------------------------------------------------------------
   proc searchFile { } {
      variable widget

      set widget(binarypath) [ ::tkutil::box_load $widget(frm) $widget(binarypath) $::audace(bufNo) "11" ]
      if { $widget(binarypath) == "" } {
         set widget(binarypath) $::conf(guide,binarypath)
      }
   }

   #==============================================================
   # Fonctions specifiques du plugin de la categorie "catalog"
   #==============================================================

   #------------------------------------------------------------
   #  gotoObject
   #  Affiche la carte de champ de l'objet choisi avec GUIDE sous Window seulement
   #  parametres :
   #     nom_objet :    nom de l'objet     (ex: "NGC7000")
   #     ad :           ascension droite   (ex: "16h41m42s")
   #     dec :          declinaison        (ex: "+36d28m00s")
   #     zoom_objet :   champ de 1 a 10
   #     avant_plan :   1 = mettre la carte au premier plan, 0 = ne pas mettre au premier plan
   #------------------------------------------------------------
   proc gotoObject { nom_objet ad dec zoom_objet avant_plan } {
      global caption conf

      set result "0"

      #--- Je mets en forme dec pour GUIDE
      #--- Je remplace les unites d, m, s par \° \' \"
      set dec [ string map { m "\'" s "\"" } $dec ]
      #---
     # console::disp "::guide::gotoObject $nom_objet, $ad, $dec, $zoom_objet, $avant_plan, \n"
      #--- Version de Guide utilisee
      set useVersionGuide [ string toupper [ file rootname [ file tail $conf(guide,binarypath) ] ] ]
      #---
      if { [ gs_guide version ] == "$useVersionGuide" } {
         if { $avant_plan == "1" } {
            set gs_guide show
         } else {
            gs_guide hide
         }
         gs_guide refresh
         gs_guide zoom $zoom_objet
         if { $nom_objet != "#etoile#" && $nom_objet != "" } {
            gs_guide objet $nom_objet
         } else {
            gs_guide coord $ad $dec "J2000.0"
         }
      } else {
         set choix [ tk_messageBox -type yesno -icon warning -title "$caption(guide,attention)" \
            -message "$caption(guide,option) $caption(guide,creation)\n\n$caption(guide,non)\n\n$caption(guide,lance)" ]
         if { $choix == "yes" } {
            set erreur [ launch ]
            if { $erreur != "1" } {
               if { [ gs_guide version ] == "$useVersionGuide" } {
                  if { $avant_plan == "1" } {
                     gs_guide show
                  } else {
                     gs_guide hide
                  }
                  gs_guide refresh
                  gs_guide zoom $zoom_objet
                  if { $nom_objet != "#etoile#" && $nom_objet != "" } {
                     gs_guide objet $nom_objet
                  } else {
                     gs_guide coord $ad $dec "J2000.0"
                  }
               } else {
                  set choix [ tk_messageBox -type ok -icon warning -title "$caption(guide,attention)" \
                     -message "$caption(guide,verification)" ]
                  set result "1"
               }
            }
         } elseif { $choix == "no" } {
            set result "1"
         }
      }
      return $result
   }

   #------------------------------------------------------------
   #  launch
   #    Lance le logiciel GUIDE pour la creation de cartes de champ
   #
   # return 0 (OK), 1 (error)
   #------------------------------------------------------------
   proc launch { } {
      global audace caption conf

      #--- Initialisation
      #--- Recherche l'absence de l'entry conf(guide,binarypath)
      if { [ info exists conf(guide,binarypath) ] == "0" } {
         tk_messageBox -type ok -icon error -title "$caption(guide,attention)" \
            -message "$caption(guide,verification)"
         return "1"
      }
      #--- Stocke le nom du chemin courant et du programme dans une variable
      set filename $conf(guide,binarypath)
      #--- Stocke le nom du chemin courant dans une variable
      set pwd0 [ pwd ]
      #--- Extrait le nom du repertoire
      set dirname [ file dirname "$conf(guide,binarypath)" ]
      #--- Place temporairement AudeLA dans le dossier de Guide
      cd "$dirname"
      #--- Prepare l'ouverture du logiciel
      set a_effectuer "exec \"$filename\" &"
      #--- Ouvre le logiciel
      if [ catch $a_effectuer input ] {
         #--- Affichage du message d'erreur sur la console
         ::console::affiche_erreur "$caption(guide,rate)\n"
         ::console::affiche_saut "\n"
         #--- Ouvre la fenetre de configuration des cartes
         ::confCat::run "guide"
      }
      #--- Ramene AudeLA dans son repertoire
      cd "$pwd0"
      #--- J'attends que Guide soit completement demarre
      after 2000
      return "0"
   }
}

