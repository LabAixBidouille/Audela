#
# Fichier : guide.tcl
# Description : Driver de communication avec "guide"
# Auteur : Robert DELMAS
# Mise a jour $Id: guide.tcl,v 1.4 2006-06-20 18:31:54 robertdelmas Exp $
#

package provide guide 1.0

#
# Procedures generiques de configuration (obligatoires pour tous les drivers camera, telescope, equipement,...)
#     init              : initialise le namespace (appelee pendant le chargement de ce source)
#     getLabel          : retourne le nom affichable du driver
#     getHelp           : retourne la documentation htm associee
#     getDriverType     : retourne le type de driver (pour classer le driver dans le menu principal)
#     initConf          : initialise les parametres de configuration s'il n'existe pas dans le tableau conf()
#     fillConfigPage    : affiche la fenetre de configuration de ce driver
#     confToWidget      : copie le tableau conf() dans les variables des widgets
#     widgetToConf      : copie les variables des widgets dans le tableau conf()
#     configureDriver   : configure le driver
#     stopDriver        : arrete le driver
#     isReady           : informe de l'etat de fonctionnement du driver
#
# Procedures specifiques a ce driver :
#     gotoObject        : affiche la carte de champ de l'objet
#     launch            : lance GUIDE
#    
namespace eval guide {
   global audace

   #==============================================================
   # Fonctions generiques de gestion des drivers
   #==============================================================

   #------------------------------------------------------------
   #  init
   #     initialise le driver
   #  
   #  return namespace name
   #------------------------------------------------------------
   proc init { } {
      global audace

      if { $::tcl_platform(os) == "Linux" } {
         #--- guide ne fonctionne pas sous Linux
         #--- Je retourne une chaine vide pour que ce driver n'apparaisse pas dans le fenetre de configuration
         return ""
      } else {
         #--- Je charge les variables d'environnement
         initConf   
         #--- Charge le fichier caption
         uplevel #0 "source \"[ file join $audace(rep_plugin) chart guide guide.cap ]\" "
         return [ namespace current ]
      }
   }

   #------------------------------------------------------------
   #  getDriverType 
   #     retourne le type de driver
   #  
   #  return "catalog"
   #------------------------------------------------------------
   proc getDriverType { } {
      return "catalog"
   }

   #------------------------------------------------------------
   #  getLabel
   #     retourne le label du driver
   #  
   #  return "Titre de l'onglet (dans la langue de l'utilisateur)"
   #------------------------------------------------------------
   proc getLabel { } {
      global caption

      return "$caption(guide,titre)"
   }

   #------------------------------------------------------------
   #  getHelp
   #     retourne la documentation du driver
   #  
   #  return "nom_driver.htm"
   #------------------------------------------------------------
   proc getHelp { } {

      return "guide.htm"
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
      if { ! [ info exists conf(guide,dirname) ] }    { set conf(guide,dirname)    "" }
      if { ! [ info exists conf(guide,binarypath) ] } { set conf(guide,binarypath) " " }

      return
   }

   #------------------------------------------------------------
   #  Recherche_Fichier
   #     lancement de la recherche du fichier executable de guide
   #  
   #  return rien
   #------------------------------------------------------------
   proc Recherche_Fichier { } {
      variable widget

      if { ( $widget(dirname) != "" ) && ( $widget(fichier_recherche) != "" ) } {
         #--- Fichier a rechercher
         set fichier_recherche $widget(fichier_recherche)
         #--- Sur les dossiers
         set repertoire $::guide::widget(dirname)

         #--- Gestion du bouton de recherche
         $widget(frm).recherche configure -relief groove -state disabled
         #--- La variable widget(binarypath) existe deja
         set repertoire_1 [ string trimright "$widget(binarypath)" "$fichier_recherche" ]
         set repertoire_2 [ glob -nocomplain -type f -dir "$repertoire_1" "$fichier_recherche" ]
         set repertoire_2 [ string trimleft $repertoire_2 "{" ]
         set repertoire_2 [ string trimright $repertoire_2 "}" ]  
         if { "$widget(binarypath)" != "$repertoire_2" || "$widget(binarypath)" == "" } {
            #--- Non, elle a change -> Recherche de la nouvelle variable widget(binarypath) si elle existe
            set repertoire [ ::audace::fichier_partPresent "$fichier_recherche" "$repertoire" ]
            set repertoire [ glob -nocomplain -type f -dir "$repertoire" "$fichier_recherche" ]
            set repertoire [ string trimleft $repertoire "{" ]
            set repertoire [ string trimright $repertoire "}" ]
            if { $repertoire == "" } {
               set repertoire " "
            }
            set widget(binarypath) "$repertoire"
         } else {
            #--- Il n'y a rien a faire
         }

         if { $widget(binarypath) == " " } {
            set widget(fichier_recherche) [ string tolower $widget(fichier_recherche) ]
            ::guide::Recherche_Fichier
         } else {
            #--- Gestion du bouton de recherche
            $widget(frm).recherche configure -relief raised -state normal
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
   #     fenetre de configuration du driver
   #  
   #  return rien
   #------------------------------------------------------------
   proc fillConfigPage { frm } {
      variable widget
      global audace
      global caption
      global color

      #--- Je memorise la reference de la frame 
      set widget(frm) $frm
      
      #--- J'initialise les valeurs 
      confToWidget

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill x

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side top -fill x

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -side top -fill both -expand 1

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -side bottom -fill x

      #--- Initialisation du chemin du fichier
      label $frm.frame1.labFichier -text "$caption(guide,fichier)"
      pack $frm.frame1.labFichier -in $frm.frame1 -anchor center -side left -padx 10 -pady 10

      entry $frm.frame1.nomFichier -textvariable ::guide::widget(fichier_recherche) -width 12 -justify center
      pack $frm.frame1.nomFichier -in $frm.frame1 -anchor center -side left -padx 10 -pady 5

      label $frm.frame1.labA_partir_de -text "$caption(guide,a_partir_de)"
      pack $frm.frame1.labA_partir_de -in $frm.frame1 -anchor center -side left -padx 10 -pady 10

      button $frm.frame1.explore -text "$caption(guide,parcourir)" -width 1 \
         -command {
            set ::guide::widget(dirname) [ tk_chooseDirectory -title "$caption(guide,dossier)" \
            -initialdir .. -parent $audace(base).confCat ]
         }
      pack $frm.frame1.explore -side left -padx 10 -pady 5 -ipady 5

      entry $frm.frame1.nomDossier -textvariable ::guide::widget(dirname) -width 15
      pack $frm.frame1.nomDossier -side left -padx 10 -pady 5

      button $frm.recherche -text "$caption(guide,rechercher)" -relief raised -state normal \
         -command { ::guide::Recherche_Fichier }
      pack $frm.recherche -in $frm.frame2 -anchor center -side left -pady 7 -ipadx 10 -ipady 5 -expand true

      entry $frm.chemin -textvariable ::guide::widget(binarypath) -width 55 -state disabled
      pack $frm.chemin -in $frm.frame2 -anchor center -side right -padx 10

      #--- Site web officiel de guide
      label $frm.labSite -text "$caption(guide,site_web)"
      pack $frm.labSite -in $frm.frame4 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(guide,site_web_ref)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame4 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $frm.labURL <ButtonPress-1> {
         set filename "$caption(guide,site_web_ref)"
         ::audace::Lance_Site_htm $filename
      }
      bind $frm.labURL <Enter> {
         set frm $guide::widget(frm)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
         set frm $guide::widget(frm)
         $frm.labURL configure -fg $color(blue)
      }

   }

   #------------------------------------------------------------
   #  configureDriver
   #     configure le driver
   #  
   #  return rien
   #------------------------------------------------------------
   proc configureDriver { } {

      #--- Chargement de la librairie guide pour Windows seulement
      if { [ lindex $::tcl_platform(os) 0 ] == "Windows" } {
         catch { load libgs.dll }
      }
      return
   }

   #------------------------------------------------------------
   #  stopDriver
   #     arrete le driver
   #  
   #  return rien
   #------------------------------------------------------------
   proc stopDriver { } {

      #--- Rien a faire pour guide
      return
   }

   #------------------------------------------------------------
   #  isReady
   #     informe de l'etat de fonctionnement du driver
   #  
   #  return 0 (ready) , 1 (not ready)
   #------------------------------------------------------------
   proc isReady { } {

      #--- Je teste si la librairie libgs.dll est chargee
      set erreur [ catch { gs_version } result ]
      if { $erreur != "0"  || $result == "" } {
         #--- La librairie libgs.dll est chargee
         set ready 1
      } else {
         set ready 0
      }
      return $ready
   }

   #==============================================================
   # Fonctions specifiques du driver de la categorie "catalog"
   #==============================================================

   #------------------------------------------------------------
   # gotoObject
   # Affiche la carte de champ de l'objet choisi avec GUIDE sous Window seulement
   #  parametres :
   #     nom_objet :    nom de l'objet     (ex: "NGC7000")
   #     ad :           ascension droite   (ex: "16h41m42s")
   #     dec :          declinaison        (ex: "+36d28m00s")
   #     zoom_objet :   champ 1 � 10
   #     avant_plan :   1=mettre la carte au premier plan 0=ne pas mettre au premier plan
   #------------------------------------------------------------
   proc gotoObject { nom_objet ad dec zoom_objet avant_plan } {
      global caption
      
      set result "0"
      
      #--- Je mets en forme dec pour GUIDE
      #--- Je remplace les unites d, m, s par \� \' \"
      set dec [ string map { m "\'" s "\"" } $dec ]

      #console::disp "::guide::gotoObject $nom_objet, $ad, $dec, $zoom_objet, $avant_plan, \n"

      set num [ catch {
         if { $avant_plan == "1" } { gs_guide show } else { gs_guide hide }
            gs_guide refresh
            gs_guide zoom $zoom_objet
            if { $nom_objet != "#etoile#" && $nom_objet != "" } {
               gs_guide objet $nom_objet
            } else {
               gs_guide coord $ad $dec { J2000 }
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
                     gs_guide coord $ad $dec { J2000 }
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
   # return 0 (OK) , 1 (error)
   #------------------------------------------------------------
   proc launch { } {
      global audace
      global conf
      global caption

      console::disp "::guide::launch debut \n"

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
      #--- Place temporairement AudeLA dans le dossier de guide
      cd "$dirname"
      #--- Pr�pare l'ouverture du logiciel
      set a_effectuer "exec \"$conf(guide,binarypath)\" \"$filename\" &"
      #--- Ouvre le logiciel
      if [ catch $a_effectuer input ] {
         #--- Affichage du message d'erreur sur la console
         $audace(console)::affiche_erreur "$caption(guide,rate)\n"
         #--- Ouvre la fenetre de configuration des editeurs
         set conf(confCat) "::guide"
         ::confCat::run
         #--- Extrait le nom de dossier
         set dirname [ file dirname "$conf(guide,binarypath)" ]
         #--- Place temporairement AudeLA dans le dossier de guide
         cd "$dirname"
         #--- Pr�pare l'ouverture du logiciel
         set a_effectuer "exec \"$conf(guide,binarypath)\" \"$filename\" &"
         #--- Affichage sur la console
         set filename $conf(guide,binarypath)
         ::console::affiche_saut "\n"
         ::console::disp $filename
         ::console::affiche_saut "\n"
         if [ catch $a_effectuer input ] {
            set audace(current_edit) $input
         }
         cd "$pwd0"
      } else {
         #--- Affichage sur la console
         ::console::affiche_saut "\n"
         ::console::disp $filename
         ::console::affiche_saut "\n"
         set audace(current_edit) $input
         $audace(console)::affiche_resultat "$caption(guide,gagne)\n"
         cd "$pwd0"
      }
      return "0"

   }

}

::guide::init

