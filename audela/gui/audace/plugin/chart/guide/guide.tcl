#
# Fichier : guide.tcl
# Description : Plugin de communication avec "guide"
# Auteur : Robert DELMAS
# Mise a jour $Id: guide.tcl,v 1.21 2007-12-04 20:47:00 robertdelmas Exp $
#

namespace eval guide {
   package provide guide 1.1
   package require audela 1.4.0
   source [ file join [file dirname [info script]] guide.cap ]

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
      switch $propertyName {

      }
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

      if { ! [ info exists conf(guide,exec) ] }       { set conf(guide,exec)       "GUIDE8.EXE" }
      if { ! [ info exists conf(guide,dirname) ] }    { set conf(guide,dirname)    "c:/" }
      if { ! [ info exists conf(guide,binarypath) ] } { set conf(guide,binarypath) " " }

      return
   }

   #------------------------------------------------------------
   #  searchFile
   #     lancement de la recherche du fichier executable de Guide
   #
   #  return rien
   #------------------------------------------------------------
   proc searchFile { } {
      variable widget

      if { ( $widget(dirname) != "" ) && ( $widget(fichier_recherche) != "" ) } {
         #--- Fichier a rechercher
         set fichier_recherche $widget(fichier_recherche)
         #--- Sur les dossiers
         set repertoire $::guide::widget(dirname)

         #--- Gestion du bouton de recherche
         $widget(frm).frame2.recherche configure -relief groove -state disabled
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
            ::guide::searchFile
         } else {
            #--- Gestion du bouton de recherche
            $widget(frm).frame2.recherche configure -relief raised -state normal
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

      set widget(fichier_recherche) "$conf(guide,exec)"
      set widget(dirname)           "$conf(guide,dirname)"
      set widget(binarypath)        "$conf(guide,binarypath)"
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

      set conf(guide,exec)       "$widget(fichier_recherche)"
      set conf(guide,dirname)    "$widget(dirname)"
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

      #--- Fichier a rechercher a partir d'un repertoire donne
      frame $frm.frame1 -borderwidth 0 -relief raised

         label $frm.frame1.labFichier -text "$caption(guide,fichier)"
         pack $frm.frame1.labFichier -anchor center -side left -padx 10 -pady 10

         entry $frm.frame1.nomFichier -textvariable ::guide::widget(fichier_recherche) -width 12 -justify center
         pack $frm.frame1.nomFichier -anchor center -side left -padx 10 -pady 5

         label $frm.frame1.labAPartirDe -text "$caption(guide,a_partir_de)"
         pack $frm.frame1.labAPartirDe -anchor center -side left -padx 10 -pady 10

         entry $frm.frame1.nomDossier -textvariable ::guide::widget(dirname) -width 20
         pack $frm.frame1.nomDossier -side left -padx 10 -pady 5

         button $frm.frame1.explore -text "$caption(guide,parcourir)" -width 1 \
            -command {
               set ::guide::widget(dirname) [ tk_chooseDirectory -title "$caption(guide,dossier)" \
               -initialdir .. -parent $::guide::widget(frm) ]
            }
         pack $frm.frame1.explore -side left -padx 10 -pady 5 -ipady 5

      pack $frm.frame1 -side top -fill x

      #--- Recherche automatique ou manuelle du chemin pour l'executable de Guide
      frame $frm.frame2 -borderwidth 0 -relief raised

         button $frm.frame2.recherche -text "$caption(guide,rechercher)" -relief raised -state normal \
            -command { ::guide::searchFile }
         pack $frm.frame2.recherche -anchor center -side left  -padx 10 -pady 7 -ipadx 10 -ipady 5

         entry $frm.frame2.chemin -textvariable ::guide::widget(binarypath)
         pack $frm.frame2.chemin -anchor center -side left -padx 10 -fill x -expand 1

         button $frm.frame2.explore -text "$caption(guide,parcourir)" -width 1 \
            -command {
               set ::guide::widget(binarypath) [ ::tkutil::box_load $::guide::widget(frm) \
                  $::guide::widget(dirname) $audace(bufNo) "11" ]
            }
         pack $frm.frame2.explore -side right -padx 10 -pady 5 -ipady 5

      pack $frm.frame2 -side top -fill x

      #--- Site web officiel de Guide
      frame $frm.frame3 -borderwidth 0 -relief raised

         label $frm.frame3.labSite -text "$caption(guide,site_web)"
         pack $frm.frame3.labSite -side top -fill x -pady 2

         set labelName [ ::confCat::createUrlLabel $frm.frame3 "$caption(guide,site_web_ref)" \
            "$caption(guide,site_web_ref)" ]
         pack $labelName -side top -fill x -pady 2

      pack $frm.frame3 -side bottom -fill x

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

   #==============================================================
   # Fonctions specifiques du plugin de la categorie "catalog"
   #==============================================================

   #------------------------------------------------------------
   # gotoObject
   # Affiche la carte de champ de l'objet choisi avec GUIDE sous Window seulement
   #  parametres :
   #     nom_objet :    nom de l'objet     (ex: "NGC7000")
   #     ad :           ascension droite   (ex: "16h41m42s")
   #     dec :          declinaison        (ex: "+36d28m00s")
   #     zoom_objet :   champ de 1 a 10
   #     avant_plan :   1 = mettre la carte au premier plan, 0 = ne pas mettre au premier plan
   #------------------------------------------------------------
   proc gotoObject { nom_objet ad dec zoom_objet avant_plan } {
      global caption

      set result "0"

      #--- Je mets en forme dec pour GUIDE
      #--- Je remplace les unites d, m, s par \° \' \"
      set dec [ string map { m "\'" s "\"" } $dec ]

     # console::disp "::guide::gotoObject $nom_objet, $ad, $dec, $zoom_objet, $avant_plan, \n"

      set num [ catch {
         if { $avant_plan == "1" } { gs_guide show } else { gs_guide hide }
            gs_guide refresh
            gs_guide zoom $zoom_objet
            if { $nom_objet != "#etoile#" && $nom_objet != "" } {
               gs_guide objet $nom_objet
            } else {
               gs_guide coord $ad $dec "J2000.0"
            }
         } msg ]

      if { $msg == "1" } {
         set choix [ tk_messageBox -type yesno -icon warning -title "$caption(guide,attention)" \
            -message "$caption(guide,option) $caption(guide,creation)\n\n$caption(guide,non)\n\n$caption(guide,lance)" ]
         if { $choix == "yes" } {
            set erreur [ launch ]
            if { $erreur != "1" } {
               after 2000
               set num [ catch {
               if { $avant_plan == "1" } { gs_guide show } else { gs_guide hide } ;
                  gs_guide refresh ;
                  gs_guide zoom $zoom_objet ;
                  if { $nom_objet != "#etoile#" } {
                     gs_guide objet $nom_objet
                  } else {
                     gs_guide coord $ad $dec "J2000.0"
                  }
               } msg ]
               if { $msg == "1" } {
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
   # launch
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
      #--- Extrait le nom de dossier
      set dirname [ file dirname "$conf(guide,binarypath)" ]
      #--- Place temporairement AudeLA dans le dossier de Guide
      cd "$dirname"
      #--- Prepare l'ouverture du logiciel
      set a_effectuer "exec \"$conf(guide,binarypath)\" \"$filename\" &"
      #--- Ouvre le logiciel
      if [ catch $a_effectuer input ] {
         #--- Affichage du message d'erreur sur la console
         ::console::affiche_erreur "$caption(guide,rate)\n"
         ::console::affiche_saut "\n"
         #--- Ouvre la fenetre de configuration des editeurs
         set conf(confCat) "::guide"
         ::confCat::run
         #--- Extrait le nom de dossier
         set dirname [ file dirname "$conf(guide,binarypath)" ]
         #--- Place temporairement AudeLA dans le dossier de Guide
         cd "$dirname"
         #--- Prepare l'ouverture du logiciel
         set a_effectuer "exec \"$conf(guide,binarypath)\" \"$filename\" &"
         #--- Affichage sur la console
         set filename $conf(guide,binarypath)
         ::console::disp $filename
         ::console::affiche_saut "\n"
         if [ catch $a_effectuer input ] {
            set audace(current_edit) $input
         }
      } else {
         #--- Affichage sur la console
         ::console::disp $filename
         ::console::affiche_saut "\n"
         set audace(current_edit) $input
         ::console::affiche_resultat "$caption(guide,gagne)\n"
         ::console::affiche_saut "\n"
      }
      cd "$pwd0"
      #--- J'attends que Guide soit completement demarre
      after 2000
      return "0"
   }
}

