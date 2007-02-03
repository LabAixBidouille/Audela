#
# Fichier : bermasaude.tcl
# Description : Gere la roue a filtres de Laurent BERNASCONI et Robert DELMAS
# Auteur : Robert DELMAS et Michel PUJOL
# Mise a jour $Id: bermasaude.tcl,v 1.11 2007-02-03 18:17:13 robertdelmas Exp $
#

package provide bermasaude 1.0

#
# Procedures generiques obligatoires (pour configurer tous les drivers camera, telescope, equipement) :
#     init              : Initialise le namespace (appelee pendant le chargement de ce source)
#     getLabel          : Retourne le nom affichable du plugin
#     getHelp           : Retourne la documentation htm associee
#     getStartFlag      : Retourne l'indicateur de lancement au démarrage
#     getPluginType     : Retourne le type de plugin
#     fillConfigPage    : Affiche la fenetre de configuration de ce driver
#     createPlugin      : Cree une instance du plugin
#     deletePlugin      : Arrete une instance du plugin et libere les ressources occupees
#     configurePlugin   : Configure le plugin
#     isReady           : Informe de l'etat de fonctionnement du driver
#


# Procedures specifiques a ce driver :
#     Representation_roue_a_filtres : Representation graphique de la roue a filtres
#     choix_nom_bouton              : Choix du nom des boutons (couleur des filtres)
#     choix_couleur                 : Choix des couleurs des filtres
#     filtre_init                   : Initialisation de la roue a filtres
#     cmd_roue_filtres              : Commande la roue a filtres
#     filtre_1                      : Positionne le filtre n°1 sur le chemin optique
#     filtre_2                      : Positionne le filtre n°2 sur le chemin optique
#     filtre_3                      : Positionne le filtre n°3 sur le chemin optique
#     filtre_4                      : Positionne le filtre n°4 sur le chemin optique
#     filtre_5                      : Positionne le filtre n°5 sur le chemin optique
#     connectBerMasAude             : Permet de rendre actifs ou inactifs les boutons
#
#     bermasaude_create             : Creation de la liaison serie
#     bermasaude_delete             : Fermeture de la liaison serie
#     bermasaude_reset              : Reset de l'electronique de la roue a filtres
#     bermasaude_v_firmware         : Retourne la version du firmware
#     bermasaude_etat_roue          : Retourne l'etat de la roue (0 a l'arret - 1 en rotation)
#     bermasaude_nbr_filtres        : Retourne le nombre de filtres de la roue
#     bermasaude_aller_a            : Permet d'aller au filtre n
#     bermasaude_position           : Retourne la position du filtre sur le chemin optique
#

namespace eval bermasaude {

   #==============================================================
   # Procedures generiques de configuration des drivers
   #==============================================================

   #------------------------------------------------------------
   #  init (est lance automatiquement au chargement de ce fichier tcl)
   #     initialise le driver
   #
   #  return namespace name
   #------------------------------------------------------------
   proc init { } {
      global audace bermasaude conf

      #--- Initialisation
      set bermasaude(connect) "0"
      set bermasaude(attente) "50"

      #--- Charge le fichier caption
      source [ file join $audace(rep_plugin) equipment bermasaude bermasaude.cap ]

      #--- Cree les variables dans conf(...) si elles n'existent pas
      if { ! [ info exists conf(bermasaude,port) ] }  { set conf(bermasaude,port)  "" }
      if { ! [ info exists conf(bermasaude,combi) ] } { set conf(bermasaude,combi) "0" }
      if { ! [ info exists conf(bermasaude,start) ] } { set conf(bermasaude,start) "0" }

      return [namespace current]
   }

   #------------------------------------------------------------
   #  getPluginType
   #     retourne le type de driver
   #
   #  return "equipment"
   #------------------------------------------------------------
   proc getPluginType { } {
      return "equipment"
   }

   #------------------------------------------------------------
   #  getLabel
   #     retourne le label du driver
   #
   #  return "Titre de l'onglet (dans la langue de l'utilisateur)"
   #------------------------------------------------------------
   proc getLabel { } {
      global caption

      return "$caption(bermasaude,titre)"
   }

   #------------------------------------------------------------
   #  getHelp
   #     retourne la documentation du driver
   #
   #  return "nom_driver.htm"
   #------------------------------------------------------------
   proc getHelp { } {
      return "bermasaude.htm"
   }

   #------------------------------------------------------------
   #  getStartFlag
   #     retourne l'indicateur de lancement au démarrage de Audela
   #
   #  return 0 ou 1
   #------------------------------------------------------------
   proc getStartFlag { } {
      return $::conf(bermasaude,start)
   }

   #------------------------------------------------------------
   #  fillConfigPage
   #     fenetre de configuration du driver
   #
   #  return nothing
   #------------------------------------------------------------
   proc fillConfigPage { frm } {
      variable widget
      global audace bermasaude caption color zone conf

      #--- Copie de conf(...) dans la variable widget
      set widget(port)  $conf(bermasaude,port)
      set widget(combi) [ lindex "$caption(bermasaude,bermasaude_bvri) $caption(bermasaude,bermasaude_cmj)" \
         $conf(bermasaude,combi) ]
      #--- Prise en compte des liaisons
      set widget(list_connexion) [::confLink::getLinkLabels { "serialport" } ]

      #--- Je memorise la reference de la frame
      set widget(frm) $frm

      #--- Choix des couleurs
      choix_couleur

      #--- Choix du nom des boutons (couleur des filtres)
      choix_nom_bouton

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill x

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side top -fill both -expand 1

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -side bottom -fill x
      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -in $frm.frame2 -side left -fill both -expand 1

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -in $frm.frame2 -side left -fill both -expand 1

      #--- Definition du port
      label $frm.lab1 -text "$caption(bermasaude,port)"
      pack $frm.lab1 -in $frm.frame1 -anchor center -side left -padx 20 -pady 10

      #--- Je verifie le contenu de la liste
      if { [ llength $widget(list_connexion) ] > 0 } {
         #--- Si la liste n'est pas vide,
         #--- je verifie que la valeur par defaut existe dans la liste
         if { [ lsearch -exact $widget(list_connexion) $::bermasaude::widget(port) ] == -1 } {
            #--- Si la valeur par defaut n'existe pas dans la liste,
            #--- je la remplace par le premier item de la liste
            set ::bermasaude::widget(port) [ lindex $widget(list_connexion) 0 ]
         }
      } else {
         #--- Si la liste est vide, on continue quand meme
      }

      #--- Bouton de configuration des ports et liaisons
      button $frm.configure -text "$caption(bermasaude,configurer)" -relief raised \
         -command {
            ::confLink::run ::bermasaude::widget(port) { serialport } \
               "- $caption(bermasaude,controle) - $caption(bermasaude,titre)"
         }
      pack $frm.configure -in $frm.frame1 -anchor n -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

      #--- Choix du port ou de la liaison
      ComboBox $frm.port \
         -width 7          \
         -height [ llength $widget(list_connexion) ] \
         -relief sunken    \
         -borderwidth 1    \
         -textvariable ::bermasaude::widget(port) \
         -editable 0       \
         -values $widget(list_connexion)
      pack $frm.port -in $frm.frame1 -anchor center -side left -padx 10 -pady 10

      #--- Definition de la combinaison des filtres
      set list_combobox [ list $caption(bermasaude,bermasaude_bvri) $caption(bermasaude,bermasaude_cmj) ]
      ComboBox $frm.combi \
         -width 5          \
         -height [ llength $list_combobox ]  \
         -relief sunken    \
         -borderwidth 1    \
         -textvariable ::bermasaude::widget(combi) \
         -editable 0       \
         -values $list_combobox
      pack $frm.combi -in $frm.frame1 -anchor center -side right -padx 20 -pady 10

      label $frm.lab2 -text "$caption(bermasaude,bermasaude_combinaison)"
      pack $frm.lab2 -in $frm.frame1 -anchor center -side right -padx 10 -pady 10

      #--- Representation de la roue a filtres
      frame $frm.frame6 -borderwidth 0 -relief raised
         #--- Creation d'un canvas pour affichage de cette representation
         canvas $frm.frame6.image2a_color_invariant -width 180 -height 180 -highlightthickness 0
         pack $frm.frame6.image2a_color_invariant
         set zone(image2a) $frm.frame6.image2a_color_invariant
      pack $frm.frame6 -in $frm.frame5 -anchor center -fill both -expand 1

      #--- Affichage de la representation
      Representation_roue_a_filtres

      #--- Les boutons de commande
      if { $bermasaude(connect) == "1" } {
         button $frm.but_1 -text "$bermasaude(caption_position_1)" -width 10 -relief raised -state normal \
            -command { ::bermasaude::filtre_1 }
         pack $frm.but_1 -in $frm.frame4 -anchor center -side top -padx 30 -pady 5 -ipady 5 -fill x -expand 1
         button $frm.but_2 -text "$bermasaude(caption_position_2)" -width 10 -relief raised -state normal \
            -command { ::bermasaude::filtre_2 }
         pack $frm.but_2 -in $frm.frame4 -anchor center -side top -padx 30 -pady 5 -ipady 5 -fill x -expand 1
         button $frm.but_3 -text "$bermasaude(caption_position_3)" -width 10 -relief raised -state normal \
            -command { ::bermasaude::filtre_3 }
         pack $frm.but_3 -in $frm.frame4 -anchor center -side top -padx 30 -pady 5 -ipady 5 -fill x -expand 1
         button $frm.but_4 -text "$bermasaude(caption_position_4)" -width 10 -relief raised -state normal \
            -command { ::bermasaude::filtre_4 }
         pack $frm.but_4 -in $frm.frame4 -anchor center -side top -padx 30 -pady 5 -ipady 5 -fill x -expand 1
         button $frm.but_5 -text "$bermasaude(caption_position_5)" -width 10 -relief raised -state normal \
            -command { ::bermasaude::filtre_5 }
         pack $frm.but_5 -in $frm.frame4 -anchor center -side top -padx 30 -pady 5 -ipady 5 -fill x -expand 1
         #--- Representation de la couleur du filtre
         $zone(image2a) create oval 65 105 115 155 -fill $bermasaude(color_filtre) -tags cadres -width 2.0
      } else {
         button $frm.but_1 -text "$bermasaude(caption_position_1)" -width 10 -relief raised -state disabled
         pack $frm.but_1 -in $frm.frame4 -anchor center -side top -padx 30 -pady 2 -ipady 5 -fill x -expand 1
         button $frm.but_2 -text "$bermasaude(caption_position_2)" -width 10 -relief raised -state disabled
         pack $frm.but_2 -in $frm.frame4 -anchor center -side top -padx 30 -pady 2 -ipady 5 -fill x -expand 1
         button $frm.but_3 -text "$bermasaude(caption_position_3)" -width 10 -relief raised -state disabled
         pack $frm.but_3 -in $frm.frame4 -anchor center -side top -padx 30 -pady 2 -ipady 5 -fill x -expand 1
         button $frm.but_4 -text "$bermasaude(caption_position_4)" -width 10 -relief raised -state disabled
         pack $frm.but_4 -in $frm.frame4 -anchor center -side top -padx 30 -pady 2 -ipady 5 -fill x -expand 1
         button $frm.but_5 -text "$bermasaude(caption_position_5)" -width 10 -relief raised -state disabled
         pack $frm.but_5 -in $frm.frame4 -anchor center -side top -padx 30 -pady 2 -ipady 5 -fill x -expand 1
      }

      #--- Site web officiel de la roue a filtres BerMasAude
      label $frm.lab103 -text "$caption(bermasaude,site_web_ref)"
      pack $frm.lab103 -in $frm.frame3 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(bermasaude,site_bermasaude)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame3 -side top -fill x -pady 2

      #--- frame checkbutton creer au demarrage
      frame $frm.start -borderwidth 0 -relief flat
         checkbutton $frm.start.chk -text "$caption(bermasaude,creer_au_demarrage)" \
            -highlightthickness 0 -variable conf(bermasaude,start)
         pack $frm.start.chk -side top -padx 3 -pady 3 -fill x
      pack $frm.start -in $frm.frame3 -side bottom -fill x

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $frm.labURL <ButtonPress-1> {
         set filename "$caption(bermasaude,site_bermasaude)"
         ::audace::Lance_Site_htm $filename
      }
      bind $frm.labURL <Enter> {
         $::bermasaude::widget(frm).labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
         $::bermasaude::widget(frm).labURL configure -fg $color(blue)
      }
   }

   #------------------------------------------------------------
   # Representation_roue_a_filtres
   #    Representation graphique de la roue a filtres
   #------------------------------------------------------------
   proc Representation_roue_a_filtres { } {
      global audace zone

      #--- Affichage de la representation
      if { [ winfo exists $audace(base).confeqt ] } {
         $zone(image2a) create arc 10 10 170 170 -outline $audace(color,textColor) -tags cadres -width 2.0 \
            -start 90 -extent -270 -style arc
         $zone(image2a) create line 10 10 90 10 -fill $audace(color,textColor) -tags cadres -width 2.0
         $zone(image2a) create line 10 10 10 90 -fill $audace(color,textColor) -tags cadres -width 2.0
         $zone(image2a) create oval 65 105 115 155 -outline $audace(color,textColor) -tags cadres -width 2.0
         $zone(image2a) configure -bg $audace(color,backColor)
      }
   }

   #------------------------------------------------------------
   #  configurePlugin
   #     configure le plugin
   #
   #  return nothing
   #------------------------------------------------------------
   proc configurePlugin { } {
      variable widget
      global caption conf

      #--- Memorise la configuration de la roue a filtres BerMasAude dans le tableau conf(bermasaude,...)
      set conf(bermasaude,port)  $widget(port)
      set conf(bermasaude,combi) [ lsearch "$caption(bermasaude,bermasaude_bvri) $caption(bermasaude,bermasaude_cmj)" \
         "$widget(combi)" ]
   }

   #------------------------------------------------------------
   #  createPlugin
   #     configure la roue a filtre
   #
   #  return nothing
   #------------------------------------------------------------
   proc createPlugin { } {
      variable widget
      global audace bermasaude caption conf ttybermasaude

      #--- Affichage d'un message d'alerte si necessaire
     ### ::confEqt::Connect_Equipement

      #--- Inhibe les menus
      ::audace::menustate disabled

      #--- Ferme le port comx de communication de la roue a filtres BerMasAude
      catch {
         ::bermasaude::bermasaude_delete $ttybermasaude
         unset ttybermasaude
      }

      switch -exact -- $conf(confEqt) {
         bermasaude {
            #--- Ouvre le port comx de communication de la roue a filtres BerMasAude
            set ttybermasaude [ ::bermasaude::bermasaude_create $conf(bermasaude,port) ]
            if { [ ::bermasaude::bermasaude_etat_roue $ttybermasaude ] == "0" } {
               ::bermasaude::bermasaude_reset $ttybermasaude
               #--- Attente de l'arret en rotation de la roue a filtres
               after 1000
               while { [ ::bermasaude::bermasaude_etat_roue $ttybermasaude ] == "1" } {
                  after 1000
               }
               console::affiche_erreur "$caption(bermasaude,bermasaude_port)\
                  $caption(bermasaude,caractere_2points) $conf(bermasaude,port)\n"
               console::affiche_erreur "$caption(bermasaude,bermasaude_combinaison)\
                  $caption(bermasaude,caractere_2points) [ lindex "$caption(bermasaude,bermasaude_bvri) \
                  $caption(bermasaude,bermasaude_cmj)" $conf(bermasaude,combi) ]\n"
               #--- Demande et affiche la version du logiciel du microcontroleur
               set v_firmware [ ::bermasaude::bermasaude_v_firmware $ttybermasaude ]
               console::affiche_erreur "$caption(bermasaude,bermasaude_version_micro) $v_firmware\n"
               #--- Demande et affiche le nombre de filtres de la roue
               set nbr_filtres [ ::bermasaude::bermasaude_nbr_filtres $ttybermasaude ]
               console::affiche_erreur "$caption(bermasaude,bermasaude_nbr_filtres_1)\
                  $nbr_filtres $caption(bermasaude,bermasaude_nbr_filtres_2)\n\n"
               set bermasaude(connect) "1"
               #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par l'equipement)
               set linkNo [::confLink::create $conf(bermasaude,port) "$conf(confEqt)" "control" ""]
            } else {
               set bermasaude(connect) "0"
            }
            #--- Gestion des boutons actifs/inactifs
            connectBerMasAude
         }
      }

      #--- Effacement du message d'alerte s'il existe
      if [ winfo exists $audace(base).connectEquipement ] {
         destroy $audace(base).connectEquipement
      }

      #--- Restaure les menus
      ::audace::menustate normal
   }

   #------------------------------------------------------------
   #  deletePlugin
   #     arrete le plugin et libere les ressources occupees
   #
   #  return nothing
   #------------------------------------------------------------
   proc deletePlugin { } {

   }

   #------------------------------------------------------------
   #  isReady
   #     informe de l'etat de fonctionnement du driver
   #
   #  return 0 (ready) , 1 (not ready)
   #------------------------------------------------------------
   proc isReady { } {
      return 0
   }

   #==============================================================
   # Procedures specifiques du driver
   #==============================================================

   #------------------------------------------------------------
   # connectBerMasAude
   #    Permet de rendre actifs ou inactifs les boutons 'Position 1', 'Position 2', 'Position 3',
   #    'Position 4' et 'Position 5' quand on passe d'un onglet 'Equipement' a un autre en evitant
   #    les erreurs dues a un appui 'curieux' sur ces boutons
   #------------------------------------------------------------
   proc connectBerMasAude { } {
      variable widget
      global bermasaude

      #--- Initialisation du graphisme de la roue a filtres
      filtre_init

      catch {
         set frm $widget(frm)
         if { $bermasaude(connect) == "1" } {
            $frm.but_1 configure -text "$bermasaude(caption_position_1)" -width 10 -relief raised -state normal \
               -command { ::bermasaude::filtre_1 }
            $frm.but_2 configure -text "$bermasaude(caption_position_2)" -width 10 -relief raised -state normal \
               -command { ::bermasaude::filtre_2 }
            $frm.but_3 configure -text "$bermasaude(caption_position_3)" -width 10 -relief raised -state normal \
               -command { ::bermasaude::filtre_3 }
            $frm.but_4 configure -text "$bermasaude(caption_position_4)" -width 10 -relief raised -state normal \
               -command { ::bermasaude::filtre_4 }
            $frm.but_5 configure -text "$bermasaude(caption_position_5)" -width 10 -relief raised -state normal \
               -command { ::bermasaude::filtre_5 }
         } else {
            $frm.but_1 configure -text "$bermasaude(caption_position_1)" -width 10 -relief raised -state disabled
            $frm.but_2 configure -text "$bermasaude(caption_position_2)" -width 10 -relief raised -state disabled
            $frm.but_3 configure -text "$bermasaude(caption_position_3)" -width 10 -relief raised -state disabled
            $frm.but_4 configure -text "$bermasaude(caption_position_4)" -width 10 -relief raised -state disabled
            $frm.but_5 configure -text "$bermasaude(caption_position_5)" -width 10 -relief raised -state disabled
         }
      }
   }

   #------------------------------------------------------------
   # choix_couleur
   #    Choix des couleurs des filtres
   #------------------------------------------------------------
   proc choix_couleur { } {
      global audace conf

      #--- Ouverture du fichier de parametrage des positions de la roue avec les couleurs des filtres
      if { $conf(bermasaude,combi) == "0" } {
         set fichier [ file join $audace(rep_plugin) equipment bermasaude bermasaude_bvri.tcl ]
      } elseif { $conf(bermasaude,combi) == "1" } {
         set fichier [ file join $audace(rep_plugin) equipment bermasaude bermasaude_cmj.tcl ]
      }

      #--- Lancement du script
      if { [ file exists $fichier ] } {
         source $fichier
      }
   }

   #------------------------------------------------------------
   # choix_nom_bouton
   #    Choix du nom des boutons (couleur des filtres)
   #------------------------------------------------------------
   proc choix_nom_bouton { } {
      global bermasaude caption color

      for { set i 1 } { $i <= 5 } { incr i } {
         if { $bermasaude(color_filtre_$i) == "$color(white)" } {
            set bermasaude(caption_position_$i) $caption(bermasaude,bermasaude_vide)
         } elseif { $bermasaude(color_filtre_$i) == "$color(blue)" } {
            set bermasaude(caption_position_$i) $caption(bermasaude,bermasaude_bleu)
         } elseif { $bermasaude(color_filtre_$i) == "$color(green)" } {
            set bermasaude(caption_position_$i) $caption(bermasaude,bermasaude_vert)
         } elseif { $bermasaude(color_filtre_$i) == "$color(red)" } {
            set bermasaude(caption_position_$i) $caption(bermasaude,bermasaude_rouge)
         } elseif { $bermasaude(color_filtre_$i) == "$color(infra-red)" } {
            set bermasaude(caption_position_$i) $caption(bermasaude,bermasaude_infrarouge)
         } elseif { $bermasaude(color_filtre_$i) == "$color(cyan)" } {
            set bermasaude(caption_position_$i) $caption(bermasaude,bermasaude_cyan)
         } elseif { $bermasaude(color_filtre_$i) == "$color(magenta)" } {
            set bermasaude(caption_position_$i) $caption(bermasaude,bermasaude_magenta)
         } elseif { $bermasaude(color_filtre_$i) == "$color(yellow)" } {
            set bermasaude(caption_position_$i) $caption(bermasaude,bermasaude_jaune)
         }
      }
   }

   #------------------------------------------------------------
   # filtre_init
   #    Initialisation de la roue a filtres
   #------------------------------------------------------------
   proc filtre_init { } {
      global audace bermasaude caption ttybermasaude zone

      #--- Choix des couleurs
      choix_couleur

      #--- Choix du nom des boutons (couleur des filtres)
      choix_nom_bouton

      #--- Initialisation des variables
      set bermasaude(position) "1"
      set bermasaude(color_filtre) $bermasaude(color_filtre_1)

      catch {
         #--- Representation de l'absence de filtre (blanc --> rien sur le chemin optique)
         $zone(image2a) create oval 65 105 115 155 -outline $audace(color,textColor) -fill $bermasaude(color_filtre) \
            -tags cadres -width 2.0
         #--- Demande la position courante de la roue a filtres
         while { [ ::bermasaude::bermasaude_etat_roue $ttybermasaude ] == "1" } {
            after 1000
         }
         set num_filtre_position [ ::bermasaude::bermasaude_position $ttybermasaude ]
         ::console::affiche_resultat "$caption(bermasaude,bermasaude_filtre_arrive_1)\
            $bermasaude(caption_position_$num_filtre_position) $caption(bermasaude,bermasaude_filtre_arrive_2)\n\n"
         bell
      }
   }

   #------------------------------------------------------------
   # filtre_1
   #    Positionne le filtre n°1 sur le chemin optique
   #------------------------------------------------------------
   proc filtre_1 { } {
      global bermasaude

      #--- Initialisation des variables
      set bermasaude(position) "1"
      set bermasaude(color_filtre) $bermasaude(color_filtre_1)

      #--- Commande de la roue a filtres
      cmd_roue_filtres
   }

   #------------------------------------------------------------
   # filtre_2
   #    Positionne le filtre n°2 sur le chemin optique
   #------------------------------------------------------------
   proc filtre_2 { } {
      global bermasaude

      #--- Initialisation des variables
      set bermasaude(position) "2"
      set bermasaude(color_filtre) $bermasaude(color_filtre_2)

      #--- Commande de la roue a filtres
      cmd_roue_filtres
   }

   #------------------------------------------------------------
   # filtre_3
   #    Positionne le filtre n°3 sur le chemin optique
   #------------------------------------------------------------
   proc filtre_3 { } {
      global bermasaude

      #--- Initialisation des variables
      set bermasaude(position) "3"
      set bermasaude(color_filtre) $bermasaude(color_filtre_3)

      #--- Commande de la roue a filtres
      cmd_roue_filtres
   }

   #------------------------------------------------------------
   # filtre_4
   #    Positionne le filtre n°4 sur le chemin optique
   #------------------------------------------------------------
   proc filtre_4 { } {
      global bermasaude

      #--- Initialisation des variables
      set bermasaude(position) "4"
      set bermasaude(color_filtre) $bermasaude(color_filtre_4)

      #--- Commande de la roue a filtres
      cmd_roue_filtres
   }

   #------------------------------------------------------------
   # filtre_5
   #    Positionne le filtre n°5 sur le chemin optique
   #------------------------------------------------------------
   proc filtre_5 { } {
      global bermasaude

      #--- Initialisation des variables
      set bermasaude(position) "5"
      set bermasaude(color_filtre) $bermasaude(color_filtre_5)

      #--- Commande de la roue a filtres
      cmd_roue_filtres
   }

   #------------------------------------------------------------
   # cmd_roue_filtres
   #    Commande la roue a filtres
   #------------------------------------------------------------
   proc cmd_roue_filtres { } {
      variable widget
      global audace bermasaude caption ttybermasaude zone

      #--- Gestion des boutons actifs/inactifs
      for { set i 1 } { $i <= 5 } { incr i } {
         $widget(frm).but_$i configure -state disabled
      }
      $widget(frm).but_$bermasaude(position) configure -relief groove

      #--- Representation de la couleur du filtre
      $zone(image2a) create oval 65 105 115 155 -outline $audace(color,textColor) -fill $bermasaude(color_filtre) \
         -tags cadres -width 2.0

      catch {
         #--- Demande la position courante de la roue a filtres
         set num_filtre_position [ ::bermasaude::bermasaude_position $ttybermasaude ]
         ::console::affiche_resultat "$caption(bermasaude,bermasaude_filtre_depart_1)\
            $bermasaude(caption_position_$num_filtre_position) $caption(bermasaude,bermasaude_filtre_depart_2)\n"

         #--- Envoi l'ordre a la roue a filtres
         ::console::affiche_resultat "$caption(bermasaude,bermasaude_filtre_encours_1)\
            $bermasaude(caption_position_$bermasaude(position)) $caption(bermasaude,bermasaude_filtre_encours_2)\n"
         set num_filtre_arrive [ ::bermasaude::bermasaude_aller_a $ttybermasaude [ list $bermasaude(position) ] ]

         #--- Affichage de la position de destination
         while { [ ::bermasaude::bermasaude_etat_roue $ttybermasaude ] == "1" } {
            after 1000
         }
         set num_filtre_position_arrivee [ ::bermasaude::bermasaude_position $ttybermasaude ]
         ::console::affiche_erreur "$caption(bermasaude,bermasaude_filtre_arrive_1)\
            $bermasaude(caption_position_$num_filtre_position_arrivee)\
            $caption(bermasaude,bermasaude_filtre_arrive_2)\n\n"
         bell
      }

      #--- Gestion des boutons actifs/inactifs
      $widget(frm).but_$bermasaude(position) configure -relief raised
      for {set i 1} {$i <= 5} {incr i} {
         $widget(frm).but_$i configure -state normal
      }
   }

#------------------------------------------------------------
# Procedures du driver de la roue a filtres (BerMasAude)
#------------------------------------------------------------

    proc bermasaude_create { port } {
       global bermasaude

       #--- Etablit la liaison
       if { $::tcl_platform(platform) == "unix" } {
          set port [ string tolower [ string trim $port ] ]
          set num [ expr [ string index $port 3 ] - 1 ]
          set port /dev/ttyS$num
       }
       set ttybermasaude [ open $port r+ ]
       fconfigure $ttybermasaude -mode "9600,n,8,1" -buffering none -blocking 0
       after [ expr $bermasaude(attente) ]
       return $ttybermasaude
    }

    proc bermasaude_v_firmware { ttybermasaude } {
       global bermasaude

       #--- Retourne la version du logiciel du microcontroleur
       #--- Demande le numero de la version
       puts -nonewline $ttybermasaude "V\r"
       after [ expr $bermasaude(attente) ]
       #--- Lit la version sur le port serie
       set v_firmware [ read $ttybermasaude 11 ]
       after [ expr $bermasaude(attente) ]
       return $v_firmware
    }

    proc bermasaude_reset { ttybermasaude } {
       global bermasaude

       #--- Execute un Reset de la roue a filtres
       puts -nonewline $ttybermasaude "R\r"
       after [ expr $bermasaude(attente) ]
    }

    proc bermasaude_etat_roue { ttybermasaude } {
       global bermasaude

       #--- Retourne l'etat de la roue a filtres
       #--- 1 : Si la roue a filtres est en rotation
       #--- 0 : Si la roue a filtres est a l'arret
       puts -nonewline $ttybermasaude "E\r"
       after [ expr $bermasaude(attente) ]
       #--- Lit la version sur le port serie
       set etat_roue [ read $ttybermasaude 11 ]
       after [ expr $bermasaude(attente) ]
       return $etat_roue
    }

    proc bermasaude_nbr_filtres { ttybermasaude } {
       global bermasaude

       #--- Retourne le nombre de filtres de la roue
       #--- Demande le nombre de filtres
       puts -nonewline $ttybermasaude "n\r"
       after [ expr $bermasaude(attente) ]
       #--- Lit le nombre de filtres sur le port serie
       set nbr_filtres [ read $ttybermasaude 11 ]
       after [ expr $bermasaude(attente) ]
       return $nbr_filtres
    }

    proc bermasaude_aller_a { ttybermasaude num_filtre } {
       global bermasaude

       #--- Positionne le filtre demande sur le faisceau optique
       puts -nonewline $ttybermasaude "$num_filtre\r"
       after [ expr $bermasaude(attente) ]
       #--- Boucle jusqu'au positionnement du filtre destination
       after 1000
       while { [ bermasaude_etat_roue $ttybermasaude ] == "1" } {
          after 1000
       }
       return $num_filtre
    }

    proc bermasaude_position { ttybermasaude } {
       global bermasaude

       #--- Retourne la position courante de la roue
       #--- Demande la position courante
       puts -nonewline $ttybermasaude "f\r"
       after [ expr $bermasaude(attente) ]
       #--- Lit la position courante sur le port serie
       set num_filtre_position [ read $ttybermasaude 11 ]
       after [ expr $bermasaude(attente) ]
       return $num_filtre_position
    }

    proc bermasaude_delete { ttybermasaude } {
       #--- Ferme la liaison
       close $ttybermasaude
    }

}

::bermasaude::init

