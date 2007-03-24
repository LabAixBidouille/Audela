#
# Fichier : visio.tcl
# Description : Outil de visionnage d'images fits + gestion des series d'images
# Auteur : Benoit MAUGIS
# Mise a jour $Id: visio.tcl,v 1.7 2007-03-24 15:07:59 robertdelmas Exp $
#

package provide visio 2.6.2

# ========================================================
# === definition du namespace visio pour creer l'outil ===
# ========================================================

namespace eval ::visio {

   # =======================================================================
   # === definition des fonctions de construction automatique de l'outil ===
   # =======================================================================

   global audace conf panneau
   variable This

   #--- chargement du fichier d'internationalisation
   source [file join $audace(rep_plugin) tool visio visio.cap]

   proc init { { in "" } } {
      createPanel $in.visio
   }

   proc createPanel { this } {
      variable This
      global audace caption panneau

      set This $this
      set panneau(menu_name,visio) $caption(visio,titre)

      #--- Modifier ici l'adresse du lecteur amovible par defaut
      #--- (pour un lecteur disquette, la variable vaut A:)
      set panneau(visio,lecteur_amovible) "A:"

      #--- Modifier ici la capacite (en octets) du lecteur amovible par defaut
      #--- (pour une disquette, 1457664 octets)
      set panneau(visio,capacite_lecteur_amovible) 1457664

      #---
      set panneau(visio,repertoire) $audace(rep_images)
      set panneau(visio,nb_repertoires) 0
      set panneau(visio,nom_generique) ""
      set panneau(visio,nb_nom_generiques) 0
      set panneau(visio,index) ""
      set panneau(visio,new_serie) ""
      set panneau(visio,quelle_serie) "1"

      #--- Extensions prises en charge
      #--- Liste des extensions FITS prises en charge (independemment de $conf(extension,defaut)
      set panneau(visio,ext,fits) [list ".fit" ".fits"]
      #--- Liste des types de compression FITS pris en charge
      switch $::tcl_platform(os) {
         "Linux" {
            set panneau(visio,ext,fits_comp) [list "" ".gz" ".bz2"]
         }
         default {
            set panneau(visio,ext,fits_comp) [list "" ".gz"]
         }
      }
      #--- Liste des extensions de fichiers autres que FITS pris en charge
      switch $::tcl_platform(os) {
         "Linux" {
            set panneau(visio,ext,nofits) [list ".gif" ".GIF" ".bmp" ".BMP" ".jpg" ".JPG" ".jpeg" ".JPEG" ".png" ".PNG" ".ps" ".eps" ".EPS" ".tif" ".TIF" ".tiff" ".TIFF" ".xbm" ".XBM" ".xpm" ".XPM"]
         }
         default {
            set panneau(visio,ext,nofits) [list ".gif" ".bmp" ".jpg" ".jpeg" ".png" ".ps" ".eps" ".tif" ".tiff" ".xbm" ".xpm"]
         }
      }
      visioBuildIF $This

      #--- Affichage de l'onglet par defaut (serie)
      set panneau(visio,onglet) serie

      pack $This.onglet.serie -side top -fill x -pady 3 -ipady 3
  
      $This.onglet.chg config -text $caption(visio,modeserie)
   }

   proc startTool { visuNo } {
      variable This

      visio::upd_repertoires

      pack $This -side left -fill y

   }

   proc stopTool { visuNo } {
      variable This

      pack forget $This
   }

   # ==================================================================
   # === definition des fonctions generales a executer dans l'outil ===
   # ==================================================================

   #--- Procedure de rafraichissement de la liste des sous-repertoires
   proc upd_repertoires { } {
      global audace caption conf panneau

      #--- On efface la liste des sous-repertoires
      for {set k 1} {$k<=$panneau(visio,nb_repertoires)} {incr k} {
         $panneau(visio,menu_repertoires) delete 0
      }

      #--- Creation de la liste des sous-repertoires
      #--- ...et en premier le repertoire parent !
      $panneau(visio,menu_repertoires) add command -label "..            " \
         -command "visio::MAJ_repertoire \"[file dirname $panneau(visio,repertoire)]\""

      set repertoires [lsort [liste_sousreps -rep $panneau(visio,repertoire)]]
      set panneau(visio,nb_repertoires) [expr [llength $repertoires]+1]
      #--- On ajoute les sous-repertoires
      foreach repertoire $repertoires {
         $panneau(visio,menu_repertoires) add command -label $repertoire \
            -command "visio::MAJ_repertoire \"[file join $panneau(visio,repertoire) $repertoire]\""
      }

      #...ainsi que le repertoire images Aud'ACE, si on n'est pas deja dedans
      if {$audace(rep_images) != $panneau(visio,repertoire)} {
         $panneau(visio,menu_repertoires) add command -label "$caption(visio,rep_images_audace)" \
            -command "visio::MAJ_repertoire \"$audace(rep_images)\""
         incr panneau(visio,nb_repertoires)
      }

      #--- on remet a jour la liste des noms generiques
      #--- la serie par defaut est la premiere venue
      set prem_serie [visio::upd_nom_generiques]
      visio::MAJ_nom_generique "[lindex $prem_serie 0]" "[lindex $prem_serie 1]"

   }

   #--- Procedure de rafraichissement de la liste des noms generiques
   proc upd_nom_generiques { } {
      global audace conf panneau

      #--- On efface la liste des noms generiques
      for {set k 1} {$k<=$panneau(visio,nb_nom_generiques)} {incr k} {
         $panneau(visio,menu_nom_generique) delete 0
      }

      #--- On place dans la variable "extensions" la liste des extensions images
      #--- prises en charge
      set extensions ""
      if {[lsearch $panneau(visio,ext,fits) $conf(extension,defaut)] == -1} {
         foreach compression $panneau(visio,ext,fits_comp) {
            lappend extensions $conf(extension,defaut)$compression
         }
      }
      foreach extension $panneau(visio,ext,fits) {
         foreach compression $panneau(visio,ext,fits_comp) {
            lappend extensions $extension$compression
         }
      }
      foreach extension $panneau(visio,ext,nofits) {
         lappend extensions $extension
      }

      #--- Creation de la liste des series du repertoire courant
      set series ""
      foreach extension $extensions {
         foreach serie [lsort [liste_series -rep $panneau(visio,repertoire) -ext $extension]] {
            lappend series [list $serie $extension]
         }
      }
      set panneau(visio,nb_nom_generiques) [llength $series]

      foreach serie $series {
         $panneau(visio,menu_nom_generique) add radiobutton -label "[lindex $serie 0]*[lindex $serie 1]" \
            -command "visio::MAJ_nom_generique \"[lindex $serie 0]\" [lindex $serie 1]"
      }
      if {[llength $series] > 0} {
         return [list [lindex [lindex $series 0] 0] [lindex [lindex $series 0] 1]]
      } else {
         return [list "" ""]
      }
   }

   #--- Procedure de MAJ du repertoire
   proc MAJ_repertoire { repertoire } {
      variable This
      global panneau

      set panneau(visio,repertoire) $repertoire
      $This.panneau.repertoire config -text $panneau(visio,repertoire)

      visio::upd_repertoires
   }

   #--- Procedure de MAJ du nom generique
   proc MAJ_nom_generique { nom_generique extension } {
      variable This
      global conf panneau

      set panneau(visio,nom_generique) $nom_generique

      $This.panneau.nom_generique config -text $panneau(visio,nom_generique)
      set panneau(visio,index) [lindex [lsort -ascii [liste_index "$nom_generique" -rep "$panneau(visio,repertoire)" -ext $extension]] 0]

      set panneau(visio,extension) $extension
      visio::upd_nom_generiques
   }

   #--- Procedure de changement d'onglet
   proc ChangeOnglet { } {
      variable This
      global audace caption panneau

      #--- Effacement de l'ancien onglet
      ::pack forget $This.onglet.$panneau(visio,onglet)

      switch -exact -- $panneau(visio,onglet) {
         serie {set panneau(visio,onglet) zip}
         zip {set panneau(visio,onglet) serie}
      }

      #--- Affichage du nouvel onglet
      pack $This.onglet.$panneau(visio,onglet) -side top -fill x
      $This.onglet.chg config -text $caption(visio,$panneau(visio,onglet))
   }

   proc desactive_boutons { } {
      variable This

      $This.panneau.nom_generique configure -state disabled
      $This.panneau.goind.index configure -state disabled
      $This.panneau.depl_serie.1.1 configure -state disabled
      $This.panneau.depl_serie.1.2 configure -state disabled
      $This.panneau.goind.2 configure -state disabled
      $This.panneau.depl_serie.3.1 configure -state disabled
      $This.panneau.depl_serie.3.2 configure -state disabled
      $This.suppr.suppr_fichier configure -state disabled
      $This.onglet.serie.renommer configure -state disabled
      $This.onglet.serie.suppr_lacunes configure -state disabled
      $This.onglet.serie.suppr_serie configure -state disabled
      $This.onglet.zip.save_toA configure -state disabled
      $This.onglet.zip.copie_fromA configure -state disabled
   }

   proc active_boutons { } {
      variable This

      $This.panneau.nom_generique configure -state normal
      $This.panneau.goind.index configure -state normal
      $This.panneau.depl_serie.1.1 configure -state normal
      $This.panneau.depl_serie.1.2 configure -state normal
      $This.panneau.goind.2 configure -state normal
      $This.panneau.depl_serie.3.1 configure -state normal
      $This.panneau.depl_serie.3.2 configure -state normal
      $This.suppr.suppr_fichier configure -state normal
      $This.onglet.serie.renommer configure -state normal
      $This.onglet.serie.suppr_lacunes configure -state normal
      $This.onglet.serie.suppr_serie configure -state normal
      $This.onglet.zip.save_toA configure -state normal
      $This.onglet.zip.copie_fromA configure -state normal
   }

   proc RAZ { } {
      global audace caption panneau

      buf$audace(bufNo) clear
      #--- Changement seuil haut (barre de seuils + label)
      $audace(base).fra1.sca1 set 0
      $audace(base).fra1.lab1 configure -text 0
      #--- Changement seuil bas (barre de seuils + label)
      $audace(base).fra1.sca2 set 0
      $audace(base).fra1.lab2 configure -text 0
      set audace(picture,w) 0
      set audace(picture,h) 0
      $audace(hCanvas) configure -scrollregion [list 0 0 $audace(picture,w) $audace(picture,h)]
      ::audace::autovisu $audace(visuNo)
      #--- MAJ en-tete audace
      wm title $audace(base) "$caption(visio,audace) (visu1)"
      #--- MAJ index du fichier
      set panneau(visio,nom_generique) ""
      set panneau(visio,index) ""
      #--- MAJ fichiers
      visio::upd_repertoires
   }

   proc seriego { } {
      global audace caption conf panneau

      set fichier [file join $panneau(visio,repertoire) $panneau(visio,nom_generique)$panneau(visio,index)$panneau(visio,extension)]

      if {[file exist $fichier]==1} {
         #--- Chargement du fichier dans le buffer audace avec visu auto
         charge $fichier
         #--- MAJ en-tete audace
         wm title $audace(base) "$caption(visio,audace) (visu1) - $fichier"
      }
   }

   proc serie-1 { } {
      global audace caption panneau

      if {[file exist [file join $panneau(visio,repertoire) $panneau(visio,nom_generique)$panneau(visio,index)$panneau(visio,extension)]]==1} {
         #--- On ne continue que si l'index courant est entier. Au passage on elimine ainsi le cas d'un fichier courant non indexe
         if {[TestEntier $panneau(visio,index)]==1} {
            #--- Desactive les boutons
            visio::desactive_boutons
            set index_serie [lsort [liste_index $panneau(visio,nom_generique) -rep $panneau(visio,repertoire) -ext $panneau(visio,extension)]]
            #--- Si possible on trie par ordre croissant (sauf dans le cas d'indexation 01, 02 .... par ex.)
            if [catch [set index_serie [lsort -ascii $index_serie]]] {}
            set place_fichier [lsearch -exact $index_serie $panneau(visio,index)]
            if {$place_fichier>0} {
               set panneau(visio,index) [lindex $index_serie [expr $place_fichier-1]]
               set fichier [file join $panneau(visio,repertoire) $panneau(visio,nom_generique)$panneau(visio,index)$panneau(visio,extension)]
               #--- Chargement du fichier dans le buffer audace avec visu auto
               charge $fichier
               #--- MAJ en-tete audace
               wm title $audace(base) "$caption(visio,audace) (visu1) - $fichier"
               set panneau(visio,refresh) 1
            }
            #--- Reactive les boutons
            visio::active_boutons
         }
      }
   }

   proc serie-- { } {
      global audace caption panneau

      if {$panneau(visio,index)!=1} {
         if {[file exist [file join $panneau(visio,repertoire) $panneau(visio,nom_generique)$panneau(visio,index)$panneau(visio,extension)]]==1} {
            #--- On ne continue que si l'index courant est entier. Au passage on elimine ainsi le cas d'un fichier courant non indexe
            if {[TestEntier $panneau(visio,index)]==1} {
               #--- Desactive les boutons
               visio::desactive_boutons

               set index_serie [lsort [liste_index $panneau(visio,nom_generique) -rep $panneau(visio,repertoire) -ext $panneau(visio,extension)]]
               #--- Si possible on trie par ordre croissant (sauf dans le cas d'indexation 01, 02 .... par ex.)
               if [catch [set index_serie [lsort -ascii $index_serie]]] {}
               #--- On n'affiche un nouveau fichier que si l'on n'est pas deja au debut
               if {$panneau(visio,index)!=[lindex $index_serie 0]} {
                  set panneau(visio,index) [lindex $index_serie 0]
                  set fichier [file join $panneau(visio,repertoire) $panneau(visio,nom_generique)$panneau(visio,index)$panneau(visio,extension)]
                  #--- Chargement du fichier dans le buffer audace avec visu auto
                  charge $fichier
                  #--- MAJ en-tete audace
                  wm title $audace(base) "$caption(visio,audace) (visu1) - $fichier"
                  set panneau(visio,refresh) 1
               }
               #--- Reactive les boutons
               visio::active_boutons
            }
         }
      }
   }

   proc serie+1 { } {
      global audace caption panneau

      if {[file exist [file join $panneau(visio,repertoire) $panneau(visio,nom_generique)$panneau(visio,index)$panneau(visio,extension)]]==1} {
      #--- On ne continue que si l'index courant est entier. Au passage on elimine ainsi le cas d'un fichier courant non indexe
         if {[TestEntier $panneau(visio,index)]==1} {
            #--- Desactive les boutons
            ::visio::desactive_boutons
            set index_serie [lsort [liste_index $panneau(visio,nom_generique) -rep $panneau(visio,repertoire) -ext $panneau(visio,extension)]]
            #--- Si possible on trie par ordre croissant (sauf dans le cas d'indexation 01, 02 .... par ex.)
            if [catch [set index_serie [lsort -ascii $index_serie]]] {}
            set place_fichier [lsearch -exact $index_serie $panneau(visio,index)]
            if {$place_fichier<[expr [llength $index_serie]-1]} {
               set panneau(visio,index) [lindex $index_serie [expr $place_fichier+1]]
               set fichier [file join $panneau(visio,repertoire) $panneau(visio,nom_generique)$panneau(visio,index)$panneau(visio,extension)]
               #--- Chargement du fichier dans le buffer audace avec visu auto
               charge $fichier
               #--- MAJ en-tete audace
               wm title $audace(base) "$caption(visio,audace) (visu1) - $fichier"
               set panneau(visio,refresh) 1
            }
            #--- Reactive les boutons
            ::visio::active_boutons
         }
      }
   }

   proc serie++ { } {
      global audace caption panneau

      if {[file exist [file join $panneau(visio,repertoire) $panneau(visio,nom_generique)$panneau(visio,index)$panneau(visio,extension)]]==1} {
         #--- On ne continue que si l'index courant est entier. Au passage on elimine ainsi le cas d'un fichier courant non indexe
         if {[TestEntier $panneau(visio,index)]==1} {
            #--- Desactive les boutons
            visio::desactive_boutons
            set index_serie [lsort [liste_index $panneau(visio,nom_generique) -rep $panneau(visio,repertoire) -ext $panneau(visio,extension)]]
            #--- Si possible on trie par ordre croissant (sauf dans le cas d'indexation 01, 02 .... par ex.)
            if [catch [set index_serie [lsort -ascii $index_serie]]] {}
            set index_dernier [lindex $index_serie [expr [llength $index_serie]-1]]
            #--- On n'affiche un nouveau fichier que si l'on n'est pas deja a la fin
            if {$panneau(visio,index)!=$index_dernier} {
               set panneau(visio,index) $index_dernier
               set fichier [file join $panneau(visio,repertoire) $panneau(visio,nom_generique)$panneau(visio,index)$panneau(visio,extension)]
               #--- Chargement du fichier dans le buffer audace avec visu auto
               charge $fichier
               #--- MAJ en-tete audace
               wm title $audace(base) "$caption(visio,audace) (visu1) - $fichier"
               set panneau(visio,refresh) 1
            }
            #--- Reactive les boutons
            visio::active_boutons
         }
      }
   }

   proc suppr_fichier { } {
      global audace caption panneau

      set oldfichier [file join $panneau(visio,repertoire) $panneau(visio,nom_generique)$panneau(visio,index)$panneau(visio,extension)]
      if {[file exist $oldfichier]==1} {
         #--- Desactive les boutons
         visio::desactive_boutons
         set panneau(visio,refresh) 0
         #--- Si le fichier fait partie d'une serie, on tente d'afficher un parent proche
         if {[TestEntier $panneau(visio,index)]==1} {
            #--- D'abord le fichier qui succede au plus pres
            visio::serie+1
            #--- Si ca n'a pas marche on affiche le fichier qui precede au plus pres
            if {$panneau(visio,refresh)==0} {::visio::serie-1}
         }
         #--- Si toujours au point mort : RAZ du buffer courant
         if {$panneau(visio,refresh)==0} {
            visio::RAZ
         }
         #--- Enfin on supprime l'ex-fichier courant
         file delete $oldfichier
         #--- Reactive les boutons
         visio::active_boutons
      }
   }

   proc suppr_lacunes { } {
      global audace caption panneau

      if {[file exist [file join $panneau(visio,repertoire) $panneau(visio,nom_generique)$panneau(visio,index)$panneau(visio,extension)]]==1} {
         #--- Desactive les boutons
         visio::desactive_boutons

         #--- Renumerote la serie courante
         renumerote $panneau(visio,nom_generique) -rep $panneau(visio,repertoire) -ext $panneau(visio,extension)

         #--- Affichage du premier fichier de la serie

         set index_serie [lsort [liste_index $panneau(visio,nom_generique) -rep $panneau(visio,repertoire) -ext $panneau(visio,extension)]]
         #--- Si possible on trie par ordre croissant (sauf dans le cas d'indexation 01, 02 .... par ex.)
         if [catch [set index_serie [lsort -ascii $index_serie]]] {}
         set panneau(visio,index) [lindex $index_serie 0]
         seriego

         #--- Reactive les boutons
         visio::active_boutons
      }
   }

   proc renommer { } {
      global audace panneau

      #--- On commence par effacer la fenetre precedente
      destroy $audace(base).fenrenommer
      #--- On ne continue que si le nom propose est different du nom courant
      if {$panneau(visio,nom_generique)!=$panneau(visio,new_serie)} {
         #--- Desactive les boutons
         visio::desactive_boutons

         #--- On cherche si le nom de la serie courante existe deja.
         set index_newserie [liste_index $panneau(visio,new_serie) -rep $panneau(visio,repertoire) -ext $panneau(visio,extension)]
         set index_oldserie [lsort -ascii [liste_index $panneau(visio,nom_generique) -rep $panneau(visio,repertoire) -ext $panneau(visio,extension)]]
         #--- 1er cas : le nom de la serie courante n'existe pas. On renomme sans se poser de questions
         if {[llength $index_newserie]==0} {
            renomme $panneau(visio,nom_generique) $panneau(visio,new_serie) -rep $panneau(visio,repertoire) -ext $panneau(visio,extension)
            #--- Actualisation du nom generique
            set panneau(visio,nom_generique) $panneau(visio,new_serie)
            MAJ_nom_generique $panneau(visio,nom_generique) $panneau(visio,extension)
            #--- Actualisation
            visio::seriego
         } else {
            #--- 2nd cas : le nom de la serie courante existe deja. Il va donc falloir reindexer
            #--- les deux series et les concatener

            #--- On demande confirmation avant de continuer
            set panneau(visio,attente_renommer) 0
            CreeFenConfirmRenom
            vwait panneau(visio,attente_renommer)
            destroy $audace(base).fenconfirmrenom

            if {$panneau(visio,attente_renommer)==1} {
               #--- Si c'est OK on continue
               renomme $panneau(visio,nom_generique) $panneau(visio,new_serie) -rep $panneau(visio,repertoire) -ext $panneau(visio,extension)
            }

            #--- Actualisation
            set panneau(visio,nom_generique) $panneau(visio,new_serie)
            MAJ_nom_generique $panneau(visio,nom_generique) $panneau(visio,extension)
            set panneau(visio,index) [lindex $index_newserie 0]
            set panneau(visio,new_serie) ""
            visio::serie--
         }
      }
      #--- Reactive les boutons
      visio::active_boutons
   }

   proc supprime_serie { } {
      global audace panneau

      #--- On commence par effacer la fenetre de confirmation
      destroy $audace(base).fenconfirmsuppr
      if {[file exist [file join $panneau(visio,repertoire) $panneau(visio,nom_generique)$panneau(visio,index)$panneau(visio,extension)]]==1} {
         #--- 1er cas : le fichier est dans une serie non indexee. Il n'y a alors que ce fichier a supprimer
         if {[TestEntier $panneau(visio,index)]==0} {
            visio::suppr_fichier
         } else {
            #--- 2nd cas : on est dans une serie indexee
            suppr_serie $panneau(visio,nom_generique) -rep $panneau(visio,repertoire) -ext $panneau(visio,extension)
         }

         #--- RAZ du buffer courant.
         visio::RAZ
      }

      MAJ_nom_generique [lindex [liste_series -rep $panneau(visio,repertoire)] 0] $panneau(visio,extension)
   }

   proc clear_disket { } {
      global panneau

      set corbeille [glob -nocomplain [file join $panneau(visio,lecteur_amovible) *]]
      foreach fichier $corbeille {file delete $fichier}
   }

   proc saveserie_toA { } {
      global audace conf panneau

      #--- On ne continue que s'il y a une disquette dans le lecteur
      if {[file exist $panneau(visio,lecteur_amovible)]==1} {
      #--- On ferme la fenetre de lancement
      destroy $audace(base).feninidisket
      #--- Desactive les boutons
      visio::desactive_boutons
      #--- Supprime les fichiers existants sur la disquette
      visio::clear_disket
      #--- Creation du buffer temporaire
      set num_buf_tmp [buf::create]
      set index_serie [lsort [liste_index $panneau(visio,nom_generique) -rep $panneau(visio,repertoire) -ext $panneau(visio,extension)]]
      #--- Si possible on trie par ordre croissant (sauf dans le cas d'indexation 01, 02 .... par ex.)
      if [catch [set index_serie [lsort -ascii $index_serie]]] {}
         set bits_utilises 0
         set panneau(visio,disquetteNo) 1
         foreach index $index_serie {
            buf$num_buf_tmp load [file join $panneau(visio,repertoire) $panneau(visio,nom_generique)$index$panneau(visio,extension)]
            buf$num_buf_tmp save [file join $panneau(visio,repertoire) tmp$conf(extension,defaut)]
            gzip [file join $panneau(visio,repertoire) tmp$conf(extension,defaut)]
            incr bits_utilises [file size [file join $panneau(visio,repertoire) tmp$conf(extension,defaut).gz]]
            if {$bits_utilises>$panneau(visio,capacite_lecteur_amovible)} {
               set panneau(visio,attente) 1
               set bits_utilises [file size [file join $panneau(visio,repertoire) tmp$conf(extension,defaut).gz]]
               ::CreeFenFullDisket
               #--- On attend la reponse de l'utilisateur
               vwait panneau(visio,attente)
               #--- On sort de la boucle si l'utilisateur le souhaite
               if {$panneau(visio,attente)==2} {
                  file delete [file join $panneau(visio,repertoire) tmp$conf(extension,defaut).gz]
                  break
               }
               #--- ...sinon on formate la nouvelle disquette et on continue la sauvegarde
               ::visio::clear_disket
               incr panneau(visio,disquetteNo)
            }
            file rename [file join $panneau(visio,repertoire) tmp$conf(extension,defaut).gz] [file join $panneau(visio,lecteur_amovible) $panneau(visio,nom_generique)$index$conf(extension,defaut).gz]
         }
         #--- Suppression du buffer temporaire
         buf::delete $num_buf_tmp
         #--- Reactive les boutons
         ::visio::active_boutons
      }
   }

   proc save_continue { } {
      global audace panneau

      #--- On ne continue que s'il y a une disquette dans le lecteur
      if {[file exist $panneau(visio,lecteur_amovible)]==1} {
         set panneau(visio,attente) 0
         #--- On ferme la fenetre
         destroy $audace(base).fenfulldisket
      }
   }

   proc save_stop { } {
      global audace panneau

      set panneau(visio,attente) 2
      #--- On ferme la fenetre
      destroy $audace(base).fenfulldisket
   }

   proc saverep_toA { } {
      global audace conf panneau

      #--- On ne continue que s'il y a une disquette dans le lecteur
      if {[file exist $panneau(visio,lecteur_amovible)]==1} {
         #--- On ferme la fenetre de lancement
         destroy $audace(base).feninidisket
         #--- Desactive les boutons
         ::visio::desactive_boutons
         #--- Supprime les fichiers existants sur la disquette
         ::visio::clear_disket
         #--- Creation du buffer temporaire
         set num_buf_tmp [buf::create]
         set rep_courant_nogz [lsort -increasing [glob -nocomplain [file join $panneau(visio,repertoire) *$conf(extension,defaut)]]]
         set rep_courant_gz [lsort -increasing [glob -nocomplain [file join $panneau(visio,repertoire) *$conf(extension,defaut).gz]]]
         set rep_courant [lsort -increasing [concat $rep_courant_nogz $rep_courant_gz]]
         set bits_utilises 0
         set panneau(visio,disquetteNo) 1
         foreach fichier $rep_courant {
            buf$num_buf_tmp load $fichier
            buf$num_buf_tmp save [file join $panneau(visio,repertoire) tmp$conf(extension,defaut)]
            gzip [file join $panneau(visio,repertoire) tmp$conf(extension,defaut)]
            incr bits_utilises [file size [file join $panneau(visio,repertoire) tmp$conf(extension,defaut).gz]]
            if {$bits_utilises>$panneau(visio,capacite_lecteur_amovible)} {
               set panneau(visio,attente) 1
               set bits_utilises [file size [file join $panneau(visio,repertoire) tmp$conf(extension,defaut).gz]]
               ::CreeFenFullDisket
               #--- On attend la reponse de l'utilisateur
               vwait panneau(visio,attente)
               #--- On sort de la boucle si l'utilisateur le souhaite
               if {$panneau(visio,attente)==2} {
                  file delete [file join $panneau(visio,repertoire) tmp$conf(extension,defaut).gz]
                  break
               }
               #--- ...sinon on formate la nouvelle disquette et on continue la sauvegarde
               ::visio::clear_disket
               incr panneau(visio,disquetteNo)
            }
            set decomp [decomp $fichier]
            set nom_fichier [lindex $decomp 1][lindex $decomp 2]
            file rename [file join $panneau(visio,repertoire) tmp$conf(extension,defaut).gz] [file join $panneau(visio,lecteur_amovible) $nom_fichier$conf(extension,defaut).gz]
         }
         #--- Suppression du buffer temporaire
         buf::delete $num_buf_tmp
         #--- Reactive les boutons
         ::visio::active_boutons
      }
   }

   proc copie_fromA { } {
      variable This
      global audace conf panneau

      #--- Desactive le bouton copie_fromA
      $This.onglet.zip.copie_fromA configure -state disabled
      set panier [glob -nocomplain [file join $panneau(visio,lecteur_amovible) *$conf(extension,defaut).gz]]
      set i [expr [string length $panneau(visio,lecteur_amovible)]+1]
      #--- Creation du buffer temporaire
      set num_buf_tmp [buf::create]
      foreach fichier $panier {
         buf$num_buf_tmp load $fichier
         set fichier [file tail $fichier]
         set j [expr [string length $fichier]-[string length $conf(extension,defaut)]-3-1]
         set nom_fichier [string range $fichier 0 $j]
         buf$num_buf_tmp save [file join $panneau(visio,repertoire) $nom_fichier$conf(extension,defaut)]
      }
      #--- Suppression du buffer temporaire
      buf::delete $num_buf_tmp
      #--- Reactive le bouton copie_fromA
      $This.onglet.zip.copie_fromA configure -state normal
   }

}

# ==============================
# === fin du namespace visio ===
# ==============================

proc visioBuildIF { This } {

# ============================
# === graphisme de l'outil ===
# ============================

   global audace caption panneau

#--- Trame du panneau

   frame $This -borderwidth 2 -relief groove

   #--- Trame du titre panneau
   frame $This.titre -borderwidth 2 -relief groove
   pack $This.titre -side top -fill x

   Button $This.titre.but -borderwidth 1 -text $caption(visio,titre) \
      -command {
         ::audace::showHelpPlugin tool visio visio.htm
      }
   pack $This.titre.but -in $This.titre -anchor center -expand 1 -fill both -side top -ipadx 5
   DynamicHelp::add $This.titre.but -text $caption(visio,help_titre)

   #--- Trame principale
   frame $This.panneau -relief groove -borderwidth 1
   pack $This.panneau -side top -fill x

      #--- Repertoire
      menubutton $This.panneau.repertoire -text $panneau(visio,repertoire) \
         -relief raised -menu $This.panneau.repertoire.menu -anchor e -width 14
      pack $This.panneau.repertoire -fill none
      set panneau(visio,menu_repertoires) [menu $This.panneau.repertoire.menu -tearoff 0]

      #--- Nom generique
      menubutton $This.panneau.nom_generique -text $panneau(visio,nom_generique) \
         -relief raised -menu $This.panneau.nom_generique.menu -width 14
      pack $This.panneau.nom_generique -fill none
      set panneau(visio,menu_nom_generique) [menu $This.panneau.nom_generique.menu -tearoff 0]

      #--- Sous-trame Go / index
      frame $This.panneau.goind
      pack $This.panneau.goind -expand true

         #--- Bouton Go
         button $This.panneau.goind.2 -text $caption(visio,charger) -width 2 -font $audace(font,arial_10_b) \
            -command ::visio::seriego
         pack $This.panneau.goind.2 -expand true -side left -pady 8

         #--- Index
         entry $This.panneau.goind.index -font $audace(font,arial_10_b) \
            -textvariable panneau(visio,index) -relief groove -width 8 -justify center
         pack $This.panneau.goind.index -expand true -side right

      #--- Sous-trame de deplacement dans une serie
      frame $This.panneau.depl_serie
      pack $This.panneau.depl_serie -fill x -expand true
   
         frame $This.panneau.depl_serie.1
         pack $This.panneau.depl_serie.1 -side left -fill x -expand true
         button $This.panneau.depl_serie.1.1 -text $caption(visio,arr1) -width 2 \
            -font $audace(font,arial_10_b) -command ::visio::serie-1
         pack $This.panneau.depl_serie.1.1 -fill x
         button $This.panneau.depl_serie.1.2 -text $caption(visio,arr-) -width 2 \
            -font $audace(font,arial_10_b) -command ::visio::serie--
         pack $This.panneau.depl_serie.1.2 -fill x

         frame $This.panneau.depl_serie.3
         pack $This.panneau.depl_serie.3 -side right -fill x -expand true
         button $This.panneau.depl_serie.3.1 -text $caption(visio,avt1) -width 2 \
            -font $audace(font,arial_10_b) -command ::visio::serie+1
         pack $This.panneau.depl_serie.3.1 -fill x
         button $This.panneau.depl_serie.3.2 -text $caption(visio,avt+) -width 2 \
            -font $audace(font,arial_10_b) -command ::visio::serie++
         pack $This.panneau.depl_serie.3.2 -fill x

   #---Trame bouton de suppression de l'image
   frame $This.suppr -relief groove -borderwidth 1
   pack $This.suppr -side top -fill x

      button $This.suppr.suppr_fichier -text $caption(visio,suppr_fichier) \
         -command ::visio::suppr_fichier
      pack $This.suppr.suppr_fichier -fill x -expand true -pady 1

   #--- Trame des sous-commandes
   frame $This.onglet -relief groove -borderwidth 1
   pack $This.onglet -side top -fill x

   #--- Bouton de changement d'onglet
   button $This.onglet.chg -text $caption(visio,serie) \
      -command ::visio::ChangeOnglet -font $audace(font,arial_10_b) -borderwidth 0
   pack $This.onglet.chg -side top -fill x -pady 2 -ipady 2

   #---Trame de gestion et de reorganisation des fichiers
   frame $This.onglet.serie -relief groove -borderwidth 1
   pack $This.onglet.serie -side top -fill x -pady 3 -ipady 3

      #--- Bouton de suppression des lacunes d'une serie (reindexer serie)
      button $This.onglet.serie.suppr_lacunes -text $caption(visio,suppr_lacunes) \
         -command ::visio::suppr_lacunes
      pack $This.onglet.serie.suppr_lacunes  -fill both -expand true

      #--- Bouton pour renommer une serie
      button $This.onglet.serie.renommer -text $caption(visio,renommer) \
         -command ::CreeFenRenommer
      pack $This.onglet.serie.renommer -fill both -expand true

      #--- Bouton de suppression d'une serie d'images
      button $This.onglet.serie.suppr_serie -text $caption(visio,suppr_serie) \
         -command CreeFenConfirmSuppr
      pack $This.onglet.serie.suppr_serie -fill both -expand true

   #--- Trame de gestion des fichiers compresses
   frame $This.onglet.zip -relief groove -borderwidth 1

      #--- Bouton de sauvegarde sur disquettes
      button $This.onglet.zip.save_toA -text $caption(visio,save_toA) \
         -command ::CreeFenIniDisket
      pack $This.onglet.zip.save_toA -fill both -expand true

      #--- Bouton de copie de fichiers compresses depuis une disquette
      button $This.onglet.zip.copie_fromA -text $caption(visio,copie_fromA) \
         -command ::visio::copie_fromA
      pack $This.onglet.zip.copie_fromA -fill both -expand true

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

#################################################################################

#---Procedure d'affichage de la fenetre initialisation copie sur disquettes
proc CreeFenIniDisket { } {
   global audace caption infos panneau

   if {[winfo exists $audace(base).feninidisket] == 0} {
      #--- Creation de la fenetre
      toplevel $audace(base).feninidisket
      wm geometry $audace(base).feninidisket 530x130+120+120
      wm title $audace(base).feninidisket $caption(visio,feninidisket)

      #--- Textes d'avertissement
      label $audace(base).feninidisket.lab1 -text $caption(visio,init1)
      pack $audace(base).feninidisket.lab1 -expand true
      label $audace(base).feninidisket.lab2 -text $caption(visio,achtung)
      pack $audace(base).feninidisket.lab2 -expand true

      #--- Sous-trame pour boutons
      frame $audace(base).feninidisket.but
      pack $audace(base).feninidisket.but -expand true -fill both

      #--- Sous-sous-trame pour boutons de sauvegarde
      frame $audace(base).feninidisket.but.save
      pack $audace(base).feninidisket.but.save -fill both -side left -expand true

         #--- Bouton "Sauver la serie en cours"
         button $audace(base).feninidisket.but.save.1  -command ::visio::saveserie_toA -text $caption(visio,saveserie_toA)
         pack $audace(base).feninidisket.but.save.1 -expand true -fill both
         #--- Bouton "Sauver le repertoire en cours"
         button $audace(base).feninidisket.but.save.2  -command ::visio::saverep_toA -text $caption(visio,saverep_toA)
         pack $audace(base).feninidisket.but.save.2 -expand true -fill both

      #--- Bouton "Quitter"
      button $audace(base).feninidisket.but.quit -command {destroy $audace(base).feninidisket} -text $caption(visio,quitter)
      pack $audace(base).feninidisket.but.quit -expand true -fill both -side right

      #--- Focus
      focus $audace(base).feninidisket

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).feninidisket

   } else {focus $audace(base).feninidisket}
}

#---Procedure d'affichage de la fenetre "disquette pleine"
proc CreeFenFullDisket { } {
   global audace caption infos panneau

   if {[winfo exists $audace(base).fenfulldisket] == 0} {
      #--- Creation de la fenetre
      toplevel $audace(base).fenfulldisket
      wm geometry $audace(base).fenfulldisket 420x130+170+150
      wm title $audace(base).fenfulldisket "$caption(visio,fenfulldisket)$panneau(visio,disquetteNo)$caption(visio,fenfulldisket1)"

      #--- Textes d'avertissement
      label $audace(base).fenfulldisket.lab1 -text $caption(visio,full1)
      pack $audace(base).fenfulldisket.lab1 -expand true
      label $audace(base).fenfulldisket.lab2 -text $caption(visio,full2)
      pack $audace(base).fenfulldisket.lab2 -expand true
      label $audace(base).fenfulldisket.lab3 -text $caption(visio,achtung)
      pack $audace(base).fenfulldisket.lab3 -expand true

      #--- Sous-trame pour boutons
      frame $audace(base).fenfulldisket.but
      pack $audace(base).fenfulldisket.but -expand true -fill both

      #--- Bouton "Continuer"
      button $audace(base).fenfulldisket.but.1  -command ::visio::save_continue -text $caption(visio,save_continue)
      pack $audace(base).fenfulldisket.but.1 -side left -expand true -fill both
      #--- Bouton "Arreter la sauvegarde"
      button $audace(base).fenfulldisket.but.2 -command ::visio::save_stop -text $caption(visio,save_stop)
      pack $audace(base).fenfulldisket.but.2 -side right -expand true -fill both

      #--- Focus
      focus $audace(base).fenfulldisket

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).fenfulldisket

   } else {focus $audace(base).fenfulldisket}
}

#---Procedure d'affichage de la fenetre "confirmation de la suppression de la serie courante"
proc CreeFenConfirmSuppr { } {
   global audace caption infos panneau

   if {[winfo exists $audace(base).fenconfirmsuppr] == 0} {
      #--- Creation de la fenetre
      toplevel $audace(base).fenconfirmsuppr
      wm geometry $audace(base).fenconfirmsuppr 380x80+170+150
      wm title $audace(base).fenconfirmsuppr ""

      #--- Textes d'avertissement
      label $audace(base).fenconfirmsuppr.lab -text $caption(visio,confirmsuppr)
      pack $audace(base).fenconfirmsuppr.lab -expand true

      #--- Sous-trame pour boutons
      frame $audace(base).fenconfirmsuppr.but
      pack $audace(base).fenconfirmsuppr.but -expand true -fill both

      #--- Bouton "Oui"
      button $audace(base).fenconfirmsuppr.but.1  -command ::visio::supprime_serie -text $caption(visio,oui)
      pack $audace(base).fenconfirmsuppr.but.1 -side left -expand true -fill both
      #--- Bouton "Non"
      button $audace(base).fenconfirmsuppr.but.2 -command {destroy $audace(base).fenconfirmsuppr} -text $caption(visio,non)
      pack $audace(base).fenconfirmsuppr.but.2 -side right -expand true -fill both

      #--- Focus
      focus $audace(base).fenconfirmsuppr

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).fenconfirmsuppr

   } else {focus $audace(base).fenconfirmsuppr}
}

#---Procedure d'affichage de la fenetre "renommer serie courante"
proc CreeFenRenommer { } {
   global audace caption infos panneau

   if {[winfo exists $audace(base).fenrenommer] == 0} {
      #--- Creation de la fenetre
      toplevel $audace(base).fenrenommer
      wm geometry $audace(base).fenrenommer 270x70+170+150
      wm title $audace(base).fenrenommer $caption(visio,renommer2)

      #--- Vieux nom de serie
      frame $audace(base).fenrenommer.old
      pack $audace(base).fenrenommer.old -expand true -fill x
      label $audace(base).fenrenommer.old.lab -text $caption(visio,oldserie)
      pack $audace(base).fenrenommer.old.lab -side left -expand true
      label $audace(base).fenrenommer.old.ent -textvariable panneau(visio,nom_generique)
      pack $audace(base).fenrenommer.old.ent -side right -expand true -fill x

      #--- Sous-trame nouveau nom de serie
      frame $audace(base).fenrenommer.new
      pack $audace(base).fenrenommer.new -expand true -fill x
      label $audace(base).fenrenommer.new.lab -text $caption(visio,newserie)
      pack $audace(base).fenrenommer.new.lab -side left -expand true
      entry $audace(base).fenrenommer.new.ent -textvariable panneau(visio,new_serie) -justify center
      pack $audace(base).fenrenommer.new.ent -side right -expand true -fill x

      #--- Sous-trame pour boutons
      frame $audace(base).fenrenommer.but
      pack $audace(base).fenrenommer.but -expand true -fill x

      #--- Bouton "Ok"
      button $audace(base).fenrenommer.but.1  -command ::visio::renommer -text $caption(visio,ok)
      pack $audace(base).fenrenommer.but.1 -side left -expand true -fill both
      #--- Bouton "Annuler"
      button $audace(base).fenrenommer.but.2 -command {destroy $audace(base).fenrenommer} -text $caption(visio,annuler)
      pack $audace(base).fenrenommer.but.2 -side right -expand true -fill both

      #--- Focus
      focus $audace(base).fenrenommer

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).fenrenommer

   } else {focus $audace(base).fenrenommer}
}

#---Procedure d'affichage de la fenetre "confirmer renommer la serie courante"
proc CreeFenConfirmRenom { } {
   global audace caption infos panneau

   if {[winfo exists $audace(base).fenconfirmrenom] == 0} {
      #--- Creation de la fenetre
      toplevel $audace(base).fenconfirmrenom
      wm geometry $audace(base).fenconfirmrenom 450x80+170+150
      wm title $audace(base).fenconfirmrenom ""

      #--- Textes d'avertissement
      label $audace(base).fenconfirmrenom.lab -text $caption(visio,confirmrenom)
      pack $audace(base).fenconfirmrenom.lab -expand true -expand true -fill both

      #--- Sous-trame pour boutons
      frame $audace(base).fenconfirmrenom.but
      pack $audace(base).fenconfirmrenom.but -expand true -fill both

      #--- Bouton "Oui"
      button $audace(base).fenconfirmrenom.but.1  -command {set panneau(visio,attente_renommer) 1} -text $caption(visio,oui)
      pack $audace(base).fenconfirmrenom.but.1 -side left -expand true -fill both
      #--- Bouton "Non"
      button $audace(base).fenconfirmrenom.but.2 -command {set panneau(visio,attente_renommer) 0} -text $caption(visio,non)
      pack $audace(base).fenconfirmrenom.but.2 -side right -expand true -fill both

      #--- Focus
      focus $audace(base).fenconfirmrenom

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).fenconfirmrenom

   } else {focus $audace(base).fenconfirmrenom}
}

# =================================
# === initialisation de l'outil ===
# =================================

global audace

::visio::init $audace(base)

########## The end ##########

