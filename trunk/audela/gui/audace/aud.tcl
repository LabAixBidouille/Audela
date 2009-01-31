#
# Fichier : aud.tcl
# Description : Fichier principal de l'application Aud'ACE
# Auteur : Denis MARCHAIS
# Mise a jour $Id: aud.tcl,v 1.95 2009-01-31 08:42:37 robertdelmas Exp $

#--- Chargement du package BWidget
package require BWidget

#--- Chargement de script d'utilitaires
source menu.tcl

#--- Fichiers de audace
source aud_menu_1.tcl
source aud_menu_2.tcl
source aud_menu_3.tcl
source aud_menu_4.tcl
source aud_menu_5.tcl
source aud_menu_6.tcl
source aud_menu_7.tcl
source aud_menu_8.tcl
source aud_proc.tcl
source console.tcl
source confgene.tcl
source surchaud.tcl
source planetography.tcl
source ftp.tcl
source bifsconv.tcl
source compute_stellaire.tcl
source divers.tcl
source iris.tcl
source poly.tcl
source filtrage.tcl
source mauclaire.tcl
source help.tcl
source vo_tools.tcl
source sectiongraph.tcl
source polydraw.tcl
source ros.tcl
source socket_tools.tcl
source gcn_tools.tcl

namespace eval ::audace {

   proc run { { this ".audace" } } {
      variable This
      global audace

      set This $this
      set audace(base) $This

      initEnv
      set visuNo [ createDialog ]
      createMenu

      initLastEnv $visuNo
      dispClock1
      affiche_Outil_F2
   }

   proc initEnv { } {
      global conf
      global audace
      global confgene
      global caption

      #--- Utilisation de la Console
      set audace(Console) ".console"
      #--- Initialisation de la variable de fermeture
      set audace(quitterEnCours) "0"
      #--- Initialisation de variables pour la fenetre Editeurs...
      set confgene(EditScript,error_script) "1"
      set confgene(EditScript,error_pdf)    "1"
      set confgene(EditScript,error_htm)    "1"
      set confgene(EditScript,error_viewer) "1"
      #--- On retourne dans le repertoire principal
      cd ..
      set audace(rep_gui)    "[pwd]"
      set audace(rep_audela) "[pwd]"
      #--- Repertoire d'installation
      set audace(rep_install) [ file normalize [ file join $audace(rep_audela) .. ] ]
      #--- Chargement de la configuration (config.ini)
      Recup_Config
      #--- Chargement du repertoire des images
      if { [ info exists conf(rep_images) ] } {
         if { [ file exists "$conf(rep_images)" ] } {
            set audace(rep_images) "$conf(rep_images)"
         } else {
            set audace(rep_images) [ file join $audace(rep_install) images ]
            set conf(rep_images)   [ file join $audace(rep_install) images ]
         }
      } else {
         set audace(rep_images) [ file join $audace(rep_install) images ]
         set conf(rep_images)   [ file join $audace(rep_install) images ]
      }
      #--- Chargement du repertoire des scripts
      if { [ info exists conf(rep_scripts) ] } {
         if { [ file exists "$conf(rep_scripts)" ] } {
            set audace(rep_scripts) "$conf(rep_scripts)"
         } else {
            set audace(rep_scripts) [ file join $audace(rep_audela) audace scripts ]
            set conf(rep_scripts)   [ file join $audace(rep_audela) audace scripts ]
         }
      } else {
         set audace(rep_scripts) [ file join $audace(rep_audela) audace scripts ]
         set conf(rep_scripts)   [ file join $audace(rep_audela) audace scripts ]
      }
      #--- Chargement du repertoire des catalogues
      if { [ info exists conf(rep_catalogues) ] } {
         if { [ file exists "$conf(rep_catalogues)" ] } {
            set audace(rep_catalogues) "$conf(rep_catalogues)"
         } else {
            set audace(rep_catalogues) [ file join $audace(rep_audela) audace catalogues ]
            set conf(rep_catalogues)   [ file join $audace(rep_audela) audace catalogues ]
         }
      } else {
         set audace(rep_catalogues) [ file join $audace(rep_audela) audace catalogues ]
         set conf(rep_catalogues)   [ file join $audace(rep_audela) audace catalogues ]
      }

      #--- Repertoire des plugins
      set audace(rep_plugin) [ file join $audace(rep_audela) audace plugin ]

      #--- Repertoire des captions
      set audace(rep_caption) [ file join $audace(rep_audela) audace caption ]

      #--- Repertoire de la documentaion au format html
      set audace(rep_doc_html) [ file join $audace(rep_audela) audace doc_html ]

      #--- Repertoire de la documentaion au format pdf
      set audace(rep_doc_pdf) [ file join $audace(rep_audela) audace doc_pdf ]

      #--- Chargement des legendes et textes pour differentes langues
      source [ file join $audace(rep_caption) caption.cap ]
      source [ file join $audace(rep_caption) aud_menu_1.cap ]
      source [ file join $audace(rep_caption) aud_menu_2.cap ]
      source [ file join $audace(rep_caption) aud_menu_3.cap ]
      source [ file join $audace(rep_caption) aud_menu_4.cap ]
      source [ file join $audace(rep_caption) aud_menu_5.cap ]
      source [ file join $audace(rep_caption) aud_menu_6.cap ]
      source [ file join $audace(rep_caption) aud_menu_7.cap ]
      source [ file join $audace(rep_caption) aud_menu_8.cap ]
      source [ file join $audace(rep_caption) confgene.cap ]
      source [ file join $audace(rep_caption) confgene_en-tete.cap ]
      source [ file join $audace(rep_caption) confgene_touche.cap ]
      source [ file join $audace(rep_caption) bifsconv.cap ]
      source [ file join $audace(rep_caption) compute_stellaire.cap ]
      source [ file join $audace(rep_caption) divers.cap ]
      source [ file join $audace(rep_caption) iris.cap ]
      source [ file join $audace(rep_caption) filtrage.cap ]
      source [ file join $audace(rep_caption) poly.cap ]

      #--- Creation de la console
      ::console::create

      #--- Chargement des sources externes
      uplevel #0 "source \"[ file join $audace(rep_audela) audace confcolor.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_audela) audace conffont.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_audela) audace tkutil.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_audela) audace select.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_audela) audace camera.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_audela) audace telescope.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_audela) audace focus.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_audela) audace crosshair.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_audela) audace carte.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_audela) audace conflink.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_audela) audace confeqt.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_audela) audace confcam.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_audela) audace confcat.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_audela) audace confoptic.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_audela) audace confpad.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_audela) audace conftel.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_audela) audace catagoto.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_audela) audace plotxy.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_audela) audace movie.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_audela) audace confvisu.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_audela) audace sextractor.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_audela) audace fullscreen.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_audela) audace keyword.tcl ]\""

      #---
      set audace(rep_audela) "[pwd]"

      #--- On utilise les valeurs contenues dans le tableau conf pour l'initialisation
      set confgene(temps,hsysteme)         [ lindex "$caption(audace,temps_heurelegale) $caption(audace,temps_universel)" "$conf(temps,hsysteme)" ]
      set confgene(temps,fushoraire)       $conf(temps,fushoraire)
      set confgene(temps,hhiverete)        [ lindex "$caption(confgene,temps_aucune) $caption(confgene,temps_hiver) $caption(confgene,temps_ete)" "$conf(temps,hhiverete)" ]
      #---
      set confgene(posobs,observateur,gps) $conf(posobs,observateur,gps)
      set audace(posobs,observateur,gps)   $confgene(posobs,observateur,gps)
      set confgene(fichier,compres)        $conf(fichier,compres)
   }

   proc defaultExeUtils { } {
      global conf

      if { $::tcl_platform(os) == "Linux" } {
         set path [ file join / usr bin ]
      } else {
         set defaultpath [ file join C: "Program Files" ]
         catch {
            set testpath "$::env(ProgramFiles)"
            set kend [expr [string length $testpath]-1]
            for {set k 0} {$k<=$kend} {incr k} {
               set car [string index "$testpath" $k]
               if {$car=="\\"} {
                  set testpath [string replace "$testpath" $k $k /]
               }
            }
            set defaultpath "$testpath"
         }
         set path "$defaultpath"
         set drive [ lindex [ file split "$path" ] 0 ]
      }
      if { ! [ info exists conf(editnotice_pdf) ] } {
         if { $::tcl_platform(os) == "Linux" } {
            set conf(editnotice_pdf) [ file join ${path} acroread ]
            if { ! [ file exist $conf(editnotice_pdf) ] } {
               set conf(editnotice_pdf) [ file join ${path} xpdf ]
            }
         } else {
            set defaultname [ file join ${path} Adobe "Acrobat 4.0" Reader AcroRd32.exe ]
            for { set k 10 } { $k > 1 } { incr k -1 } {
               set testname [ file join ${path} Adobe "Acrobat ${k}.0" Reader AcroRd32.exe ]
               if { [ file executable "$testname" ] == "1" } {
                  set defaultname "$testname"
                  break;
               }
            }
            set conf(editnotice_pdf) "$defaultname"
         }
      }
      if { ! [ info exists conf(editscript) ] } {
         if { $::tcl_platform(os) == "Linux" } {
            set conf(editscript) [ file join ${path} kedit ]
            if { ! [ file exist $conf(editscript) ] } {
               set conf(editscript) [ file join ${path} emacs ]
            }
         } else {
            set conf(editscript) "write"
         }
      }
      if { ! [ info exists conf(editsite_htm) ] } {
         if { $::tcl_platform(os) == "Linux" } {
            set conf(editsite_htm) [ file join ${path} netscape ]
            if { ! [ file exist $conf(editsite_htm) ] } {
               set conf(editsite_htm) [ file join ${path} mozilla ]
            }
         } else {
            set defaultname [ file join ${path} "Internet Explorer" Iexplore.exe ]
            set testnames [ list [ file join ${path} Netscape Netscape Netscp.exe ] \
            [ file join ${path} Netscape Communicator Program Netscape.exe ] ]
            foreach testname $testnames {
               if { [ file executable "$testname" ] == "1" } {
                  set defaultname "$testname"
                  break;
               }
            }
            set conf(editsite_htm) "$defaultname"
         }
      }
      if { ! [ info exists conf(edit_viewer) ] } {
         if { $::tcl_platform(os) == "Linux" } {
            set conf(edit_viewer) ""
            if { ! [ file exist $conf(edit_viewer) ] } {
               set conf(edit_viewer) ""
            }
         } else {
            set defaultname ""
            set testnames [ list [ file join ${path} "ACD Systems" "ACDSee" ACDSee.exe ] \
            [ file join ${path} IrfanView i_view32.exe ] [ file join ${path} XnView xnview.exe ] ]
            foreach testname $testnames {
               if { [ file executable "$testname" ] == "1" } {
                  set defaultname "$testname"
                  break;
               }
            }
            set conf(edit_viewer) "$defaultname"
         }
      }
   }

   #
   # ::audace::repertPresent { repertoire }
   # Recherche des repertoires existants
   #
   proc repertPresent { repertoire } {
      set listrepertPresent [ lsort [ glob -nocomplain -type d -dir $repertoire * ] ]
      set nbre_repert [ llength $listrepertPresent ]
      return [ list $listrepertPresent $nbre_repert ]
   }

   #
   # ::audace::fichierPresent { fichier repertoire }
   # Recherche d'un fichier dans un repertoire donnee
   #
   proc fichierPresent { fichier repertoire } {
      set repertCourant "[pwd]"
      if { [ catch { cd $repertoire } erreur ] } {
         puts stderr $erreur
         return
      }
      set contenuRepert [ glob -nocomplain * ]
      if { [ lsearch -exact $contenuRepert $fichier ] != "-1" } {
         set resultat "1"
      } else {
         set resultat "0"
      }
      cd $repertCourant
      return $resultat
   }

   #
   # ::audace::fichier_partPresent { fichier_recherche repertoire }
   # Recherche d'un fichier particulier sur le disque dur dans une arborescence de 5 niveaux maxi
   #
   proc fichier_partPresent { fichier_recherche repertoire } {
      set a [ ::audace::fichierPresent "$fichier_recherche" "$repertoire" ]
      if { $a == "1" } {
         #--- Rien
      } else {
         set recherche1 [ ::audace::repertPresent "$repertoire" ]
         set listrepertPresent1 [ lindex $recherche1 0 ]
         set nbre_repert1 [ lindex $recherche1 1 ]
         for { set i1 0 } { $i1 < $nbre_repert1 } { incr i1 1 } {
            if { $a == "Fin" } {
               break
            }
            set repertoire [ lindex $listrepertPresent1 $i1 ]
            set a [ ::audace::fichierPresent "$fichier_recherche" "$repertoire" ]
            if { $a == "1" } {
               set a "Fin"
               break
            } else {
               set recherche2 [ ::audace::repertPresent "$repertoire" ]
               set listrepertPresent2 [ lindex $recherche2 0 ]
               set nbre_repert2 [ lindex $recherche2 1 ]
               for { set i2 0 } { $i2 < $nbre_repert2 } { incr i2 1 } {
                  if { $a == "Fin" } {
                     break
                  }
                  set repertoire [ lindex $listrepertPresent2 $i2 ]
                  set a [ ::audace::fichierPresent "$fichier_recherche" "$repertoire" ]
                  if { $a == "1" } {
                     set a "Fin"
                     break
                  } else {
                     set recherche3 [ ::audace::repertPresent "$repertoire" ]
                     set listrepertPresent3 [ lindex $recherche3 0 ]
                     set nbre_repert3 [ lindex $recherche3 1 ]
                     for { set i3 0 } { $i3 < $nbre_repert3 } { incr i3 1 } {
                        if { $a == "Fin" } {
                           break
                        }
                        set repertoire [ lindex $listrepertPresent3 $i3 ]
                        set a [ ::audace::fichierPresent "$fichier_recherche" "$repertoire" ]
                        if { $a == "1" } {
                           set a "Fin"
                           break
                        } else {
                           set recherche4 [ ::audace::repertPresent "$repertoire" ]
                           set listrepertPresent4 [ lindex $recherche4 0 ]
                           set nbre_repert4 [ lindex $recherche4 1 ]
                           for { set i4 0 } { $i4 < $nbre_repert4 } { incr i4 1 } {
                              if { $a == "Fin" } {
                                 break
                              }
                              set repertoire [ lindex $listrepertPresent4 $i4 ]
                              set a [ ::audace::fichierPresent "$fichier_recherche" "$repertoire" ]
                              if { $a == "1" } {
                                 set a "Fin"
                                 break
                              } else {
                                 set recherche5 [ ::audace::repertPresent "$repertoire" ]
                                 set listrepertPresent5 [ lindex $recherche5 0 ]
                                 set nbre_repert5 [ lindex $recherche5 1 ]
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      return $repertoire
   }

   proc Recup_Config { { visuNo 1 } } {
      global conf
      global audace

      #--- Initialisation
      if {[info exists conf]} {unset conf}

      #--- Ouverture du fichier de paramètres
      if { $::tcl_platform(os) == "Linux" } {
         set fichier [ file join ~ .audela config.ini ]
         #--- Si le dossier ~/.audela n'existe pas, on le cree
         if { ! [ file exist [ file join ~ .audela ] ] } {
            file mkdir [ file join ~ .audela ]
         }
      } else {
         set fichier [ file join audace config.ini ]
      }
      if { [ file exists $fichier ] } { uplevel #0 "source $fichier" }

      #--- Initialisation de la liste des binnings si aucune camera n'est connectee
      set audace(list_binning) { 1x1 2x2 3x3 4x4 5x5 6x6 }

      #--- Initialisation indispensable ici de certaines variables de configuration
      ::seuilWindow::initConf
      ::confFichierIma::initConf
      ::confTemps::initConf
      ::confPosObs::initConf
      ::confTypeFenetre::initConf

      #--- Initialisation de variables de configuration
      if { ! [ info exists conf(fonction_transfert,param2) ] } { set conf(fonction_transfert,param2) "1" }
      if { ! [ info exists conf(fonction_transfert,param3) ] } { set conf(fonction_transfert,param3) "1" }
      if { ! [ info exists conf(fonction_transfert,param4) ] } { set conf(fonction_transfert,param4) "1" }

      #--- Initialisation de variables relatives aux palettes
      if { ! [ info exists conf(visu_palette,visu$visuNo,mode) ] } \
         { set conf(visu_palette,visu$visuNo,mode)           "1" }

      #--- Initialisation de variables relatives aux fonctions de transfert
      if { ! [ info exists conf(fonction_transfert,visu$visuNo,position) ] } \
         { set conf(fonction_transfert,visu$visuNo,position) "+0+0" }
      if { ! [ info exists conf(fonction_transfert,visu$visuNo,mode) ] } \
         { set conf(fonction_transfert,visu$visuNo,mode)     "1" }

      #--- Initialisation des executables
      ::audace::defaultExeUtils
   }

   proc verifip { ipinit } {
      #--- IP local
      set ip [lindex [hostaddress] 0]
      set ipmaskhost "[lindex $ip 0].[lindex $ip 1].[lindex $ip 2]"
      set ipnumhost  "[lindex $ip 3]"
      #--- IP device
      set ip [split $ipinit "."]
      set ipmask "[lindex $ip 0].[lindex $ip 1].[lindex $ip 2]"
      set ipnum  "[lindex $ip 3]"
      if {$ipmask!=$ipmaskhost} {
         set ipmask $ipmaskhost
      }
      if { ( $ipnum == $ipnumhost ) || ( $ipnum == "" ) } {
         set ipnum [expr $ipnumhost+10]
         if {$ipnum>255} {
            set ipnum [expr $ipnumhost-10]
         }
      }
      return "${ipmask}.${ipnum}"
   }

   proc createDialog { } {
      variable This
      global audace
      global caption

      #---
      toplevel $This
      wm geometry $This 631x453+0+0
      wm maxsize $This [winfo screenwidth .] [winfo screenheight .]
      wm minsize $This 631 453
      wm resizable $This 1 1
      wm deiconify $This

      #--- Je cree la visu de la fenetre principale
      set visuNo [ ::confVisu::create $audace(base) ]

      #---
      wm title $This "$caption(audace,titre) (visu$visuNo)"
      wm protocol $This WM_DELETE_WINDOW " ::audace::quitter "
      update

      #--- Creation des variables audace dependant de la visu
      set audace(visuNo)  $visuNo
      set audace(bufNo)   [visu$visuNo buf]
      set audace(imageNo) [visu$visuNo image]
      set audace(hCanvas) $::confVisu::private($visuNo,hCanvas)

      #--- J'ajoute le repertoire des outils dans le chemin
      lappend ::auto_path [file join $audace(rep_plugin) tool]

      #--- Je recherche les fichiers tool/*/pkgIndex.tcl
      set filelist [glob -nocomplain -type f -join "$audace(rep_plugin)" tool * pkgIndex.tcl ]
      #--- Chargement des differents outils
      foreach pkgIndexFileName $filelist {
         if { [::audace::getPluginInfo $pkgIndexFileName pluginInfo] == 0 } {
            #--- je charge le plugin
            set catchResult [catch { package require $pluginInfo(name)} ]
            if { $catchResult == 1 } {
               #--- j'affiche l'erreur dans la console
               ::console::affiche_erreur "$::errorInfo\n"
            } else {
               foreach os $pluginInfo(os) {
                  if { $os == [ lindex $::tcl_platform(os) 0 ] } {
                     #--- j'execute la procedure initPlugin si elle existe
                     if { [info procs $pluginInfo(namespace)::initPlugin] != "" } {
                        $pluginInfo(namespace)::initPlugin $audace(base)
                     }
                     set ::panneau(menu_name,[ string trimleft $pluginInfo(namespace) "::" ]) $pluginInfo(title)
                     ::console::affiche_prompt "#Outil : $pluginInfo(title) v$pluginInfo(version)\n"
                  }
               }
            }
         } else {
            ::console::affiche_erreur "Error loading tool $pkgIndexFileName \n$::errorInfo\n\n"
         }
      }
      ::console::disp "\n"
      return $visuNo
   }

   proc createMenu { } {
      variable This
      global audace
      global conf
      global caption

      set visuNo $audace(visuNo)
      set bufNo [ visu$visuNo buf ]
      Menu_Setup $visuNo $This.menubar

      set ::confVisu::private($visuNo,menu) "$This.menubar"

      Menu           $visuNo "$caption(audace,menu,fichier)"
      Menu_Command   $visuNo "$caption(audace,menu,fichier)" "$caption(audace,menu,charger)..." \
         "::audace::charger $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,fichier)" "$caption(audace,menu,enregistrer)" \
         "::audace::enregistrer $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,fichier)" "$caption(audace,menu,enregistrer_sous)..." \
         "::audace::enregistrer_sous $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,fichier)" "$caption(audace,menu,copyjpeg)..." \
         "::audace::copyjpeg $visuNo"

      Menu_Separator $visuNo "$caption(audace,menu,fichier)"
      Menu_Command   $visuNo "$caption(audace,menu,fichier)" "$caption(audace,menu,entete)" "::keyword::header $visuNo"
      Menu_Separator $visuNo "$caption(audace,menu,fichier)"
      Menu_Command   $visuNo "$caption(audace,menu,fichier)" "$caption(audace,menu,select)..." ::selectWindow::run
      Menu_Separator $visuNo "$caption(audace,menu,fichier)"
      Menu_Command   $visuNo "$caption(audace,menu,fichier)" "$caption(audace,menu,nouveau_script)..." ::audace::newScript
      Menu_Command   $visuNo "$caption(audace,menu,fichier)" "$caption(audace,menu,editer_script)..." ::audace::editScript
      Menu_Command   $visuNo "$caption(audace,menu,fichier)" "$caption(audace,menu,lancer_script)..." ::audace::runScript
      Menu_Separator $visuNo "$caption(audace,menu,fichier)"
      Menu_Command   $visuNo "$caption(audace,menu,fichier)" "$caption(audace,menu,quitter)" ::audace::quitter

      Menu           $visuNo "$caption(audace,menu,affichage)"
      Menu_Command   $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,nouvelle_visu)" ::confVisu::create
      Menu_Separator $visuNo "$caption(audace,menu,affichage)"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,palette_grise)" \
              "1" "conf(visu_palette,visu$visuNo,mode)" "::audace::MAJ_palette $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,palette_inverse)" \
              "2" "conf(visu_palette,visu$visuNo,mode)" "::audace::MAJ_palette $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,palette_iris)" \
              "3" "conf(visu_palette,visu$visuNo,mode)" "::audace::MAJ_palette $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,palette_arc_en_ciel)" \
              "4" "conf(visu_palette,visu$visuNo,mode)" "::audace::MAJ_palette $visuNo"
      Menu_Separator $visuNo "$caption(audace,menu,affichage)"
      Menu_Cascade $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,fcttransfert_titre)"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,fcttransfert_titre)" "$caption(audace,menu,fcttransfert_lin)" \
              "1" "conf(fonction_transfert,visu$visuNo,mode)" "::audace::fonction_transfert $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,fcttransfert_titre)" "$caption(audace,menu,fcttransfert_log)" \
              "2" "conf(fonction_transfert,visu$visuNo,mode)" "::audace::fonction_transfert $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,fcttransfert_titre)" "$caption(audace,menu,fcttransfert_exp)" \
              "3" "conf(fonction_transfert,visu$visuNo,mode)" "::audace::fonction_transfert $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,fcttransfert_titre)" "$caption(audace,menu,fcttransfert_arc)" \
              "4" "conf(fonction_transfert,visu$visuNo,mode)" "::audace::fonction_transfert $visuNo"
      Menu_Separator $visuNo "$caption(audace,menu,affichage)"
      Menu_Command $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,seuils)..." \
              "::seuilWindow::run $This $visuNo"
      Menu_Separator $visuNo "$caption(audace,menu,affichage)"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" \
              "$caption(audace,menu,zoom) $caption(audace,menu,zoom_0.125)" "0.125" \
              "::confVisu::private($visuNo,zoom)" "::confVisu::setZoom $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" \
              "$caption(audace,menu,zoom) $caption(audace,menu,zoom_0.25)" "0.25" \
              "::confVisu::private($visuNo,zoom)" "::confVisu::setZoom $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" \
              "$caption(audace,menu,zoom) $caption(audace,menu,zoom_0.5)" "0.5" \
              "::confVisu::private($visuNo,zoom)" "::confVisu::setZoom $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" \
              "$caption(audace,menu,zoom) $caption(audace,menu,zoom_1)" "1" \
              "::confVisu::private($visuNo,zoom)" "::confVisu::setZoom $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" \
              "$caption(audace,menu,zoom) $caption(audace,menu,zoom_2)" "2" \
              "::confVisu::private($visuNo,zoom)" "::confVisu::setZoom $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" \
              "$caption(audace,menu,zoom) $caption(audace,menu,zoom_4)" "4" \
              "::confVisu::private($visuNo,zoom)" "::confVisu::setZoom $visuNo"
      Menu_Separator $visuNo "$caption(audace,menu,affichage)"
      Menu_Check $visuNo "$caption(audace,menu,affichage)" \
              "$caption(audace,menu,plein_ecran)" \
              "::confVisu::private($visuNo,fullscreen)" "::confVisu::setFullScreen $visuNo"
      Menu_Separator $visuNo "$caption(audace,menu,affichage)"
      Menu_Check   $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,miroir_x)" \
              "::confVisu::private($visuNo,mirror_x)" "::confVisu::setMirrorX $visuNo"
      Menu_Check   $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,miroir_y)" \
              "::confVisu::private($visuNo,mirror_y)" "::confVisu::setMirrorY $visuNo"
      Menu_Check   $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,window)" \
              "::confVisu::private($visuNo,window)" "::confVisu::setWindow $visuNo"
      Menu_Separator $visuNo "$caption(audace,menu,affichage)"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" \
         "$caption(audace,menu,vision_nocturne)" "1" "conf(confcolor,menu_night_vision)" \
         "::confColor::switchDayNight ; \
            if { [ winfo exists $audace(base).selectColor ] } { \
               destroy $audace(base).selectColor \
               ::confColor::run $visuNo\
            } \
         "
      Menu_Separator $visuNo "$caption(audace,menu,affichage)"
      Menu_Command   $visuNo "$caption(audace,menu,affichage)" "[ ::Crosshair::getLabel ]..." "::Crosshair::run $visuNo"

      Menu           $visuNo "$caption(audace,menu,pretraite)"
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,miroir_x)" {
              if { [ buf$audace(bufNo) imageready ] == "1" } {
                 buf$audace(bufNo) mirrorx
                 ::audace::autovisu $audace(visuNo)
              }
           }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,miroir_y)" {
              if { [ buf$audace(bufNo) imageready ] == "1" } {
                 buf$audace(bufNo) mirrory
                 ::audace::autovisu $audace(visuNo)
              }
           }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,miroir_xy)" {
              if { [ buf$audace(bufNo) imageready ] == "1" } {
                 buf$audace(bufNo) imaseries "invert xy"
                 ::audace::autovisu $audace(visuNo)
              }
           }
      Menu_Separator $visuNo "$caption(audace,menu,pretraite)"
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,r+v+b2rvb)..." \
         { ::traiteImage::run "r+v+b2rvb" "$audace(base).traiteImage" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,rvb2r+v+b)..." \
         { ::traiteImage::run "rvb2r+v+b" "$audace(base).traiteImage" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,cfa2rvb)..." \
         { ::traiteImage::run "cfa2rvb" "$audace(base).traiteImage" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,balance_rvb)..." \
         { ::traiteImage::run "balance_rvb" "$audace(base).traiteImage" }
      Menu_Separator $visuNo "$caption(audace,menu,pretraite)"
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,window1)..."\
         { ::pretraitement::run "multi_recadrer" "$audace(base).pretraitement" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,scale)..." \
         { ::pretraitement::run "multi_reechantillonner" "$audace(base).pretraitement" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,offset)..." \
         { ::pretraitement::run "multi_ajouter_cte" "$audace(base).pretraitement" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,mult_cte)..." \
         { ::pretraitement::run "multi_multiplier_cte" "$audace(base).pretraitement" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,clip)..." \
         { ::pretraitement::run "multi_ecreter" "$audace(base).pretraitement" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,subsky)..." \
         { ::pretraitement::run "multi_soust_fond_ciel" "$audace(base).pretraitement" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,noffset)..." \
         { ::pretraitement::run "multi_norm_fond" "$audace(base).pretraitement" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,ngain)..." \
         { ::pretraitement::run "multi_norm_eclai" "$audace(base).pretraitement" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,addition)..." \
         { ::pretraitement::run "multi_addition" "$audace(base).pretraitement" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,soust)..." \
         { ::pretraitement::run "multi_soustraction" "$audace(base).pretraitement" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,division)..." \
         { ::pretraitement::run "multi_division" "$audace(base).pretraitement" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,opt_noir)..." \
         { ::pretraitement::run "multi_opt_noir" "$audace(base).pretraitement" }
      Menu_Separator $visuNo "$caption(audace,menu,pretraite)"
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,mediane)..." \
         { ::traiteWindow::run "serie_mediane" "$audace(base).traiteWindow" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,somme)..." \
         { ::traiteWindow::run "serie_somme" "$audace(base).traiteWindow" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,moyenne)..." \
         { ::traiteWindow::run "serie_moyenne" "$audace(base).traiteWindow" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,ecart_type)..." \
         { ::traiteWindow::run "serie_ecart_type" "$audace(base).traiteWindow" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,recentrer)..." \
         { ::traiteWindow::run "serie_recentrer" "$audace(base).traiteWindow" }
      Menu_Separator $visuNo "$caption(audace,menu,pretraite)"
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,faire_offset)..." \
         { ::faireImageRef::run "faire_offset" "$audace(base).faireImageRef" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,faire_dark)..." \
         { ::faireImageRef::run "faire_dark" "$audace(base).faireImageRef" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,faire_flat_field)..." \
         { ::faireImageRef::run "faire_flat_field" "$audace(base).faireImageRef" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,pretraite)..." \
         { ::faireImageRef::run "pretraitement" "$audace(base).faireImageRef" }

      Menu           $visuNo "$caption(audace,menu,traitement)"
      Menu_Command   $visuNo "$caption(audace,menu,traitement)" "$caption(audace,menu,masque_flou)..." \
         { ::traiteFilters::run "$caption(audace,menu,masque_flou)" "$audace(base).traiteFilters" }
      Menu_Command   $visuNo "$caption(audace,menu,traitement)" "$caption(audace,menu,filtre_passe-bas)..." \
         { ::traiteFilters::run "$caption(audace,menu,filtre_passe-bas)" "$audace(base).traiteFilters" }
      Menu_Command   $visuNo "$caption(audace,menu,traitement)" "$caption(audace,menu,filtre_passe-haut)..." \
         { ::traiteFilters::run "$caption(audace,menu,filtre_passe-haut)" "$audace(base).traiteFilters" }
      Menu_Command   $visuNo "$caption(audace,menu,traitement)" "$caption(audace,menu,filtre_median)..." \
         { ::traiteFilters::run "$caption(audace,menu,filtre_median)" "$audace(base).traiteFilters" }
      Menu_Command   $visuNo "$caption(audace,menu,traitement)" "$caption(audace,menu,filtre_minimum)..." \
         { ::traiteFilters::run "$caption(audace,menu,filtre_minimum)" "$audace(base).traiteFilters" }
      Menu_Command   $visuNo "$caption(audace,menu,traitement)" "$caption(audace,menu,filtre_maximum)..." \
         { ::traiteFilters::run "$caption(audace,menu,filtre_maximum)" "$audace(base).traiteFilters" }
      Menu_Command   $visuNo "$caption(audace,menu,traitement)" "$caption(audace,menu,filtre_gaussien)..." \
         { ::traiteFilters::run "$caption(audace,menu,filtre_gaussien)" "$audace(base).traiteFilters" }
      Menu_Command   $visuNo "$caption(audace,menu,traitement)" "$caption(audace,menu,ond_morlet)..." \
         { ::traiteFilters::run "$caption(audace,menu,ond_morlet)" "$audace(base).traiteFilters" }
      Menu_Command   $visuNo "$caption(audace,menu,traitement)" "$caption(audace,menu,ond_mexicain)..." \
         { ::traiteFilters::run "$caption(audace,menu,ond_mexicain)" "$audace(base).traiteFilters" }
      Menu_Command   $visuNo "$caption(audace,menu,traitement)" "$caption(audace,menu,log)..." \
         { ::traiteFilters::run "$caption(audace,menu,log)" "$audace(base).traiteFilters" }

      Menu           $visuNo "$caption(audace,menu,analyse)"
      Menu_Command   $visuNo "$caption(audace,menu,analyse)" "$caption(audace,menu,histo)" "::audace::Histo $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,analyse)" "$caption(audace,menu,coupe)" "::sectiongraph::init $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,analyse)" "$caption(audace,menu,statwin)" "statwin $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,analyse)" "$caption(audace,menu,fwhm)" "fwhm $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,analyse)" "$caption(audace,menu,fitgauss)" "fitgauss $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,analyse)" "$caption(audace,menu,centro)" "center $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,analyse)" "$caption(audace,menu,phot)" "photom $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,analyse)" "$caption(audace,menu,subfitgauss)" "subfitgauss $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,analyse)" "$caption(audace,menu,scar)" "scar $visuNo"
      Menu_Separator $visuNo "$caption(audace,menu,analyse)"
      #--- Affichage des outils du menu deroulant Analyse
      ::audace::afficheOutilsAnalyse $visuNo
      Menu_Separator $visuNo "$caption(audace,menu,analyse)"
      Menu_Command   $visuNo "$caption(audace,menu,analyse)" "$caption(audace,menu,carte)" \
         { ::carte::showMapFromBuffer buf$audace(bufNo) }

      Menu           $visuNo "$caption(audace,menu,outils)"
      Menu_Command   $visuNo "$caption(audace,menu,outils)" "$caption(audace,menu,choix_outils)..." \
         { ::confChoixOutil::run "$audace(base).confChoixOutil" }
      Menu_Separator $visuNo "$caption(audace,menu,outils)"
      Menu_Command   $visuNo "$caption(audace,menu,outils)" "$caption(audace,menu,pas_outil)" { ::audace::pas_Outil }
      Menu_Separator $visuNo "$caption(audace,menu,outils)"
      #--- Affichage des outils du menu deroulant Outils
      ::audace::affiche_Outil $visuNo

      Menu           $visuNo "$caption(audace,menu,configuration)"
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,langue)..." \
         { ::confLangue::run "$audace(base).confLangue" }
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,repertoire)..." \
         { ::cwdWindow::run "$audace(base).cwdWindow" }
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,editeur)..." \
         { ::confEditScript::run "$audace(base).confEditScript" }
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,temps)..." \
         { ::confTemps::run "$audace(base).confTemps" }
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,position)..." \
         { ::confPosObs::run "$audace(base).confPosObs" }
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,fichier_image)..." \
         { ::confFichierIma::run "$audace(base).confFichierIma" }
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,alarme)..." \
         { ::confAlarmeFinPose::run "$audace(base).confAlarmeFinPose" }
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,type_fenetre)..." \
         { ::confTypeFenetre::run "$audace(base).confTypeFenetre" }
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,apparence)..." \
         "::confColor::run $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,police)..." \
         "::confFont::run $visuNo"
      Menu_Separator $visuNo "$caption(audace,menu,configuration)"
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,camera)..." \
         "::confCam::run"
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,monture)..." \
         "::confTel::run"
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,liaison)..." \
         "::confLink::run"
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,optique)..." \
         "::confOptic::run $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,equipement)..." \
         "::confEqt::run"
      Menu_Separator $visuNo "$caption(audace,menu,configuration)"
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,raquette)..." \
         "::confPad::run"
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,carte)..." \
         "::confCat::run"
      Menu_Separator $visuNo "$caption(audace,menu,configuration)"
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,sauve_config)" \
         "::audace::enregistrerConfiguration $visuNo"

      Menu           $visuNo "$caption(audace,menu,aide)"
      Menu_Command   $visuNo "$caption(audace,menu,aide)" "$caption(audace,menu,sommaire)" \
         ::audace::showMain
      Menu_Command   $visuNo "$caption(audace,menu,aide)" "$caption(audace,menu,fonctions)" \
         ::audace::showFunctions
      Menu_Command   $visuNo "$caption(audace,menu,aide)" "$caption(audace,menu,tutorial)" \
         { exec "[ file join $::audela_start_dir audela.exe ]" --file tutorial.tcl & }
      Menu_Cascade   $visuNo "$caption(audace,menu,aide)" "$caption(audace,menu,site_audela)"
      Menu_Command   $visuNo "$caption(audace,menu,site_audela)" "$caption(audace,menu,site_internet)" {
         set filename "$caption(en-tete,a_propos_de_site)" ; ::audace::Lance_Site_htm $filename }
      Menu_Command   $visuNo "$caption(audace,menu,site_audela)" "$caption(audace,menu,site_dd)..." \
         ::audace::editSiteWebAudeLA
      Menu_Command   $visuNo "$caption(audace,menu,aide)" "$caption(audace,menu,notice_pdf)..." \
         ::audace::editNotice_pdf
      Menu_Command   $visuNo "$caption(audace,menu,aide)" "$caption(audace,menu,a_propos_de)" \
         { ::confVersion::run "$audace(base).confVersion" }

      #--- Exemple d'association d'une touche du clavier avec une option d'un menu deroulant ou un outil
      Menu_Bind $visuNo $This <Control-o> "$caption(audace,menu,fichier)" "$caption(audace,menu,charger)..." \
         "$caption(touche,controle,O)"
      bind $audace(Console) <Control-o> " focus $audace(base) ; ::audace::charger $visuNo "
      Menu_Bind $visuNo $This <Control-s> "$caption(audace,menu,fichier)" "$caption(audace,menu,enregistrer)" \
         "$caption(touche,controle,S)"
      bind $audace(Console) <Control-s> " focus $audace(base) ; ::audace::enregistrer "
      Menu_Bind $visuNo $This <Control-q> "$caption(audace,menu,fichier)" "$caption(audace,menu,quitter)" \
         "$caption(touche,controle,Q)"
      bind $audace(Console) <Control-q> " focus $audace(base) ; ::audace::quitter "
      Menu_Bind $visuNo $This <F12>       "$caption(audace,menu,outils)" "$caption(audace,menu,pas_outil)" \
         "$caption(touche,F12)"
      bind $audace(Console) <F12> " focus $audace(base) ; ::audace::pas_Outil "
   }

   proc initLastEnv { visuNo } {
      variable This
      global audace
      global conf
      global caption
      global tmp

      #--- Mise a jour des couleurs des interfaces
      ::confColor::applyColor $audace(base)
      ::confColor::applyColor $audace(Console)

      #--- Prise en compte des dimensions et des positions des fenetres
      if { [ info exists conf(audace,visu$visuNo,wmgeometry) ] == "1" } {
         wm geometry $This $conf(audace,visu$visuNo,wmgeometry)
      } else {
         wm geometry $This 631x453+0+0
      }
      if { [ info exists conf(console,wmgeometry) ] == "1" } {
         wm geometry $audace(Console) $conf(console,wmgeometry)
      } else {
         wm geometry $audace(Console) 360x200+220+180
      }
      update

      #--- Définition d'un fichier palette temporaire, modifiable dynamiquement
      #--- On stocke le nom de ce fichier dans tmp(fichier_palette)
      #--- Attention : On stocke le nom du fichier sans l'extension .pal
      if { ! [ info exist tmp(fichier_palette) ] } {
         switch $::tcl_platform(os) {
            Linux {
               #--- Si le dossier /tmp/.audela n'existe pas, on le cree avec les permissions d'écriture pour tout le monde
               if {[file exist [file join /tmp .audela]]=="0"} {
                  file mkdir [file join /tmp .audela]
                  exec chmod a+w [file join /tmp .audela]
               }
               set tmp(fichier_palette) [ file rootname [ cree_fichier -nom_base fonction_transfert -rep [ file join /tmp .audela ] -ext .pal ] ]
            }
            default {
               set tmp(fichier_palette) [ file rootname [ cree_fichier -nom_base fonction_transfert -rep [ file join $audace(rep_audela) audace palette ] -ext .pal ] ]
            }
         }
      }

      #--- Configure PortTalk
      if { $::tcl_platform(os) == "Windows NT" } {
         set res [ catch { set result [ porttalk open all ] } msg ]
         set no_administrator "PortTalk: You do not have rights to access"
         if { ( $res == "1" ) && ( [ file exists "[ file join $audace(rep_install) bin allowio.txt ]" ] == "0" ) } {
            if { [ string range $msg 0 41 ] != "$no_administrator" } {
               ::console::affiche_erreur "$msg\n\n$caption(audace,porttalk_msg_erreur)\n"
            } else {
               ::console::affiche_erreur "$msg\n"
            }
            set base ".allowio"
            toplevel $base
            wm geometry $base +50+100
            wm resizable $base 0 0
            wm deiconify $base
            wm title $base "$caption(audace,porttalk_erreur)"
            if { [ string range $msg 0 41 ] != "$no_administrator" } {
               message $base.msg -text "$msg\n\n$caption(audace,porttalk_msg_erreur)\n" -justify center -width 350
            } else {
               message $base.msg -text "$msg\n" -justify center -width 350
            }
            pack $base.msg -in $base -anchor center -side top -fill x -padx 0 -pady 0 -expand 0
            frame $base.frame1
               set saveallowio "0"
               checkbutton $base.frame1.check1 -variable saveallowio
               pack $base.frame1.check1 -anchor w -side left -fill x -padx 1 -pady 1 -expand 1
               label $base.frame1.lab1 -text "$caption(audace,porttalk_message)"
               pack $base.frame1.lab1 -anchor w -side left -fill x -padx 1 -pady 1 -expand 1
            pack $base.frame1 -in $base -anchor center -side top -fill none -padx 0 -pady 0 -expand 0
            button $base.but1 -text "$caption(audace,ok)" \
               -command {
                  if { $saveallowio == "1" } {
                     set f [ open "[ file join $audace(rep_install) bin allowio.txt ]" w ]
                     close $f
                  }
                  destroy .allowio
               }
            pack $base.but1 -in $base -anchor center -side top -padx 5 -pady 5 -ipadx 10 -ipady 5
            focus -force $base
            tkwait window $base
         } else {
            catch {
               ::console::affiche_prompt "$caption(audace,porttalk_titre) $result\n\n"
            }
         }
      }

      #--- Connexion au demarrage des cameras
      ::confCam::startPlugin

      #--- Connexion au demarrage de la monture
      ::confTel::startPlugin

      #--- Connexion au demarrage des equipements
      ::confEqt::startPlugin

      #--- Connexion au demarrage de la carte
      ::confCat::startPlugin
   }

   #
   # ::audace::GiveFocus_AudACE
   # Donne le focus a la fenetre principale Aud'ACE
   #
   proc GiveFocus_AudACE { } {
      variable This

      switch -- [ wm state $This ] {
         normal { raise $This }
         iconic { wm deiconify $This }
      }
      focus $This
   }

   #
   # ::audace::dispClock1
   # Fonction qui calcule et met a jour TU et TSL
   # Cette fonction se re-appelle au bout d'une seconde
   #
   proc dispClock1 { } {
      global audace
      global caption
      global confgene

      #--- Systeme d'heure utilise
      set time1 [::audace::date_sys2ut now]
      set time1sec [lindex $time1 5]
      set time2 [format "%02dh %02dm %02ds" [lindex $time1 3] [lindex $time1 4] [expr int($time1sec)]]
      set audace(tu,format,hmsint) $time2
      #--- Preparation affichage heure TSL
      set tsl [mc_date2lst [::audace::date_sys2ut now] $confgene(posobs,observateur,gps)]
      set audace(tsl) $tsl
      set tslsec [lindex $tsl 2]
      set tsl_hms [format "%02dh %02dm %02ds" [lindex $tsl 0] [lindex $tsl 1] [expr int($tslsec)]]
      set audace(tsl,format,hmsint) $tsl_hms
      #--- Formatage heure TSL pour un pointage au zenith
      set tsl_zenith [format "%02dh%02dm%02d" [lindex $tsl 0] [lindex $tsl 1] [expr int($tslsec)]]
      set audace(tsl,format,zenith) $tsl_zenith
      #--- Formatage et affichage de la date et de l'heure TU dans l'interface Aude'ACE
      set audace(tu_date,format,dmy) [format "%02d/%02d/%2s" [lindex $time1 2] [lindex $time1 1] [string range [lindex $time1 0] 2 3]]
      set audace(tu,format,dmyhmsint) [format "%02d/%02d/%2s %02d:%02d:%02.0f $caption(audace,temps_universel)" [lindex $time1 2] [lindex $time1 1] [string range [lindex $time1 0] 2 3] [lindex $time1 3] [lindex $time1 4] [expr int($time1sec)]]
      after 1000 ::audace::dispClock1
   }

   proc date_sys2ut { { date now } } {
      global caption
      global confgene

      #--- Systeme d'heure utilise
      set fushoraire $confgene(temps,fushoraire)
      if { $fushoraire=="-3:30" } {
         set fushoraire "-3.5"
      } elseif { $fushoraire=="3:30" } {
         set fushoraire "3.5"
      } elseif { $fushoraire=="4:30" } {
         set fushoraire "4.5"
      } elseif { $fushoraire=="5:30" } {
         set fushoraire "5.5"
      } elseif { $fushoraire=="9:30" } {
         set fushoraire "9.5"
      }
      #--- Preparation affichage heure TU
      if { $confgene(temps,hsysteme) != "$caption(audace,temps_heurelegale)" } {
         set fushoraire "0"
         set deltahhiverete "0"
      } else {
         if { $confgene(temps,hhiverete) != "$caption(confgene,temps_ete)" } {
            set deltahhiverete "0"
         } else {
            set deltahhiverete "1"
         }
      }
      set decalage [expr ($fushoraire + $deltahhiverete)]
      set jjnow [mc_date2jd $date]
      set jjnowlocal [expr $jjnow - $decalage/24.]
      set time1 [mc_date2ymdhms $jjnowlocal]
      return $time1
   }

   #------------------------------------------------------------
   #  autovisu
   #     rafraichit l'affichage
   #------------------------------------------------------------
   proc autovisu { { visuNo "1" } { force "-no" } } {
      ::confVisu::autovisu $visuNo $force
   }

   #
   # ::audace::lanceViewerImages
   # Lance le viewer pour visualiser les images d'un APN CoolPix
   #
   proc lanceViewerImages { filename } {
      global audace
      global conf
      global confgene
      global caption

      menustate disabled
      set confgene(EditScript,error_script) "1"
      set confgene(EditScript,error_pdf)    "1"
      set confgene(EditScript,error_htm)    "1"
      set confgene(EditScript,error_viewer) "1"

      if [ string compare $filename "" ] {
         set a_effectuer "exec \"$conf(edit_viewer)\" \"$filename\" &"
         if [ catch $a_effectuer msg ] {
            #--- Vous devez choisir un viewer d'images
            ::console::affiche_erreur "$caption(audace,console_rate) \n"
            ::console::affiche_erreur "$msg \n\n"
            set confgene(EditScript,error_viewer) "0"
            ::confEditScript::run "$audace(base).confEditScript"
            set a_effectuer "exec \"$conf(edit_viewer)\" \"$filename\" &"
            if [ catch $a_effectuer msg ] {
               ::console::affiche_erreur "$caption(audace,console_rate) \n"
               ::console::affiche_erreur "$msg \n\n"
            } else {
               #--- Tout est OK : Ouverture du fichier
               ::console::affiche_erreur "$caption(audace,console_gagne) \n\n"
            }
         } else {
            #--- Tout est OK : Ouverture du fichier
            ::console::affiche_erreur "$caption(audace,console_gagne) \n\n"
         }
      } else {
         #--- Il n'y a pas de fichier a ouvrir
         ::console::affiche_erreur "$caption(audace,console_annule) \n\n"
      }
      menustate normal
   }

   proc shutdown_devices { } {
      #--- On coupe proprement les devices
      set camlist [::cam::list]
      foreach cam $camlist {
         ::cam::delete $cam
      }
      set tellist [::tel::list]
      foreach tel $tellist {
         ::tel::delete $tel
      }
      #--- Arret des fonctions lancees par l'outil "remotectrl"
      catch { wiz_del_client }
      catch { wiz_del_server }
   }

   proc rien { } {
      #--- Sert a bloquer l'affichage multiple de la fenêtre Quitter
   }

   proc menustate { state } {
      global audace

      foreach menu [winfo children $audace(base).menubar] {
         set imax [$menu index end]
         for {set i 0} {$i <= $imax} {incr i} {
            catch {$menu entryconfigure $i -state $state}
         }
      }
   }

   proc cursor { curs } {
      ::confVisu::cursor $curs
   }

   proc bg { coul } {
      ::confVisu::bg $coul
   }

   # ::audace::screen2Canvas coord
   # Transforme des coordonnees ecran en coordonnees canvas. L'argument est une liste de deux entiers,
   # et retourne également une liste de deux entiers
   #
   proc screen2Canvas { coord } {
      global audace

      return [ ::confVisu::screen2Canvas $audace(visuNo) $coord ]
   }

   # ::audace::canvas2Picture coord {stick left}
   # Transforme des coordonnees canvas en coordonnees image. L'argument est une liste de deux entiers,
   # et retourne également une liste de deux entiers.
   # Les coordonnees canvas commencent a 0,0 dans le coin superieur gauche de l'image.
   # Les coordonnees image  commencent a 1,1 dans le coin inferieur gauche de l'image.
   # En passant un argument <> de left pour stick, calcule les coordonnees par arrondi superieur.
   #
   proc canvas2Picture { coord { stick left } } {
      global audace

      return [ ::confVisu::canvas2Picture $audace(visuNo) $coord $stick ]
   }

   #
   # ::audace::picture2Canvas coord
   # Transforme des coordonnees image en coordonnees canvas. L'argument est une liste de deux entiers,
   # et retourne également une liste de deux entiers
   #
   proc picture2Canvas { coord } {
      global audace

      return [ ::confVisu::picture2Canvas $audace(visuNo) $coord ]
   }

   #
   # Determination des elements qui sont dans le fichier de configuration et pas en memoire
   #
   proc ini_onlyInFile { f_a m_a } {
      upvar $f_a file_array
      upvar $m_a mem_array
      set file_names [array names file_array]
      set mem_names [array names mem_array]
      set onlyInFile {}
      foreach a $file_names {
         if {[lsearch -exact $mem_names $a]==-1} {
            lappend onlyInFile $a
         }
      }
      return $onlyInFile
   }

   #
   # f_a : tableau de configuration dans le fichier
   # m_a : tableau de configuration en memoire
   # Renvoie 1 si il faut reecrire le fichier de configuration
   #
   proc ini_fileNeedWritten { f_a m_a } {
      #---
      upvar $f_a file_array
      upvar $m_a mem_array
      #---
      set file_names [array names file_array]
      set mem_names [array names mem_array]
      foreach a $mem_names {
         if {[lsearch -exact $file_names $a]==-1} {
           # ::console::affiche_erreur "$a not in file\n"
            return 1
         } else {
            if {[string compare [array get file_array $a] [array get mem_array $a]]!=0} {
              # ::console::affiche_erreur "$a different between file and mem : \"[array get file_array $a]\" \"[array get mem_array $a]\"\n"
               return 1;
            }
         }
      }
      return 0
   }

   #
   # filename : nom du fichier
   # f_a : tableau de configuration dans le fichier
   # m_a : tableau de configuration en memoire
   #
   proc ini_merge { f_a m_a } {
      upvar $f_a file_array
      upvar $m_a mem_array
      array set merge_array [array get mem_array]
      foreach a [ini_onlyInFile file_array mem_array] {
         set merge_array($a) "$file_array($a)"
      }
      return [array get merge_array]
   }

   #
   # filename : nom du fichier
   #
   proc ini_getArrayFromFile { filename } {
      global conf

      set tempinterp [interp create]
      catch {interp eval $tempinterp "source \"$filename\""} m
      array set file_conf [interp eval $tempinterp "array get conf"]
      interp delete $tempinterp
      return [array get file_conf]
   }

   #
   # filename : nom du fichier
   # f_a : tableau de configuration dans le fichier
   #
   proc ini_writeIniFile { filename f_a } {
      upvar $f_a file_array
      if {[catch {
         set fid [open $filename w]
         puts $fid "global conf"
         #foreach {a b} [array get file_array] {
         #   puts $fid "set conf($a) \"$b\""
         #}
         foreach a [lsort -dictionary [array names file_array]] {
            puts $fid "set conf($a) \"[lindex [array get file_array $a] 1]\""
         }
         close $fid
      } erreur ]} {
        tk_messageBox -icon error -message $erreur -type ok
      }
   }

   proc writeIniFile { } {
      global audace
      global conf
      global caption

      if { $::tcl_platform(os) == "Linux" } {
         set filename [ file join ~ .audela config.ini ]
         set filebak  [ file join ~ .audela config.bak ]
      } else {
         set filename [ file join $audace(rep_audela) audace config.ini ]
         set filebak  [ file join $audace(rep_audela) audace config.bak ]
      }
      set filename2 $filename
      catch {
         file copy -force $filename $filebak
      }
      array set file_conf [ ini_getArrayFromFile $filename ]
      if { [ ini_fileNeedWritten file_conf conf ] } {
         set old_focus [focus]
         set choice [ tk_messageBox -message "$caption(audace,enregistrer_config1)" \
            -title "$caption(audace,enregistrer_config2)" -icon question -type yesno ]
         if {$choice=="yes"} {
            array set theconf [ini_merge file_conf conf]
            ini_writeIniFile $filename2 theconf
            ::console::affiche_resultat "$caption(audace,enregistrer_config3)\n"
         } else {
            ::console::affiche_resultat "caption(audace,enregistrer_config5)\n"
         }
         focus $old_focus
      } else {
         ::console::affiche_resultat "caption(audace,enregistrer_config4)\n\n"
      }
   }

   #------------------------------------------------------------
   #  visuDynamix
   #      appelle ::confVisu::visuDynamix
   #      avec la visu par defaut numero 1
   #
   #    procedure a supprimer quand plus aucun programme de l'utilisera
   #------------------------------------------------------------
   proc visuDynamix { max min } {
      global audace

      ::confVisu::visuDynamix $audace(visuNo) $max $min
   }

   #------------------------------------------------------------
   #  getPluginInfo
   #    retourne les informations sur un plugin dans le tableau passe en parametre
   #      pluginInfo(name)      nom du plugin
   #      pluginInfo(version)   version du plugin
   #      pluginInfo(command)   commande pour charger le plugin
   #      pluginInfo(namespace) namespace principal du plugin
   #      pluginInfo(title)     titre du plugin dans la langue de l'utilisateur
   #      pluginInfo(type)      type du plugin
   #      pluginInfo(os)        os compatible avec le plugin
   #
   # parametres :
   #    pkgIndexFileName : nom complet du fichier pkgIndex.tcl (avec le repertoire)
   #    pluginInfo : tableau (array) des informations sur le plugin rempli par cette procedure
   # return :
   #     0 si pas d'erreur, le resultat est dans le tableau donne en parametre
   #    -1 si une erreur, le libelle de l'erreur est dans ::::errorInfo
   #
   # Exemple d'utilisation
   #    ::audace::getPluginInfo "$audace(rep_plugin)/equipment/focuserjmi/pkgIndex.tcl" pluginInfo
   #    retourne dans pluginInfo :
   #       pluginInfo(name)     = focuserjmi
   #       pluginInfo(version)  = 1.0
   #       pluginInfo(command)  = source c:/audela/gui/audace/plugin/equipment/focuserjmi/focuserjmi.tcl
   #       pluginInfo(namespace)= focuserjmi
   #       pluginInfo(title)    = Focaliseur JMI
   #       pluginInfo(type)     = focuser
   #       pluginInfo(os)       = Windows Linux Darwin
   #------------------------------------------------------------
   proc getPluginInfo { pkgIndexFileName pluginInfo } {
      upvar $pluginInfo pinfo

      #--- je cree un interpreteur temporaire pour charger le package sans pertuber AudeLA
      set interpTemp [interp create -safe ]
      set catchResult [ catch {
         #--- j'autorise les commandes source et file pour pouvoir charger le plugin dans l'interpreteur temporaire
         interp expose $interpTemp source
         interp expose $interpTemp file
         #--- je transfere des variables globales a l'interpreteur temporaire
         $interpTemp eval [ list set langage $::langage ]
         $interpTemp eval [ list set pkgIndexFileName "$pkgIndexFileName" ]

         #--- je teste le plugin dans l'interpreteur temporaire
         $interpTemp eval {
            proc processUnknownRequiredPackage { packageName packageVersion } {
               if { $packageName == "audela" } {
                  set ::audelaRequiredVersion $packageVersion
               }
            }
            global caption
            set caption(test) ""
            set audelaRequiredVersion ""

            set dir "[file dirname $pkgIndexFileName]"
            source  "$pkgIndexFileName"
            #--- je recupere le nom du plugin
            set pluginName [lindex [package names ] 0]
            #--- je recupere la version du plugin
            set pluginVersion [package versions $pluginName]
            #--- je recupere la version de AudeLA requise par le plugin
            package unknown processUnknownRequiredPackage
            set sourceFile [package ifneeded $pluginName $pluginVersion]
            catch { eval "$sourceFile" }
            if { $audelaRequiredVersion != "" } {
               package provide "audela" "$audelaRequiredVersion"
               eval "$sourceFile"
            }
            #--- je recupere le namespace principal du plugin
            set pluginNamespace [lindex [namespace children ::] 0]
            #--- je recupere le type du plugin
            if { [info commands $pluginNamespace\::getPluginType] != "" } {
               set pluginType [$pluginNamespace\::getPluginType]
            } else {
               set pluginType ""
            }
            #--- je recupere le titre du plugin dans la langue de l'utilisateur
            if { [info commands $pluginNamespace\::getPluginTitle] != "" } {
               set pluginTitle [$pluginNamespace\::getPluginTitle]
            } else {
               set pluginTitle "$pluginNamespace"
            }
           #--- je recupere le ou les OS supporte(s) par le plugin
            if { [info commands $pluginNamespace\::getPluginOS] != "" } {
               set pluginOS [$pluginNamespace\::getPluginOS]
            } else {
               set pluginOS [ list Windows Linux Darwin ]
            }
         }

         #--- je recupere les informations du plugin
         set pinfo(name)          [$interpTemp eval { set pluginName } ]
         set pinfo(version)       [$interpTemp eval { set pluginVersion } ]
         set pinfo(command)       [$interpTemp eval { set sourceFile } ]
         set pinfo(audelaVersion) [$interpTemp eval { set audelaRequiredVersion } ]
         set pinfo(type)          [$interpTemp eval { set pluginType } ]
         set pinfo(title)         [$interpTemp eval { set pluginTitle } ]
         set pinfo(os)            [$interpTemp eval { set pluginOS } ]
         set namespaceList2 [$interpTemp eval { set pluginNamespace } ]
         if { [llength $namespaceList2 ] > 0 } {
            set pinfo(namespace) [lindex $namespaceList2 0]
         } else {
            error "Namespace not found in plugin $pinfo(name)"
         }
      } ]
      #--- je supprime l'interpreteur temporaire
      interp delete $interpTemp
      #--- je retourne -1 s'il y a eu une erreur
      if { $catchResult == 1 } {
         return "-1"
      } else {
         return "0"
      }
   }

   #------------------------------------------------------------
   #  getPluginTypeDirectory
   #    retourne le repertoire du plugin en fonction de son type
   #    Actuellement les types de plugins sont dans un repertoire
   #    dont le nom est identique au type, sauf le type "focuser"
   #    ou "spectroscope" qui est dans le repertoire "equipement"
   #------------------------------------------------------------
   proc getPluginTypeDirectory { pluginType } {
      if { $pluginType == "focuser" } {
         set typeDirectory "equipment"
      } elseif { $pluginType == "spectroscope" } {
         set typeDirectory "equipment"
      } else {
         set typeDirectory $pluginType
      }
      return $typeDirectory
   }

}

########################## Fin du namespace audace ##########################

# Scrolled_Canvas
# Cree un canvas scrollable, ainsi que les deux scrollbars pour le bouger
# Ref : Brent Welsh, Practical Programming in TCL/TK, rev.2, page 392
#
proc Scrolled_Canvas { c args } {
   frame $c
   eval {canvas $c.canvas \
      -xscrollcommand [list $c.xscroll set] \
      -yscrollcommand [list $c.yscroll set] \
      -highlightthickness 0 \
      -borderwidth 0} $args
   scrollbar $c.xscroll -orient horizontal -command [list $c.canvas xview]
   scrollbar $c.yscroll -orient vertical -command [list $c.canvas yview]
   grid $c.canvas $c.yscroll -sticky news
   grid $c.xscroll -sticky ew
   grid rowconfigure $c 0 -weight 1
   grid columnconfigure $c 0 -weight 1
   return $c.canvas
}

proc Scrolled_Text { f args } {
   frame $f
   text $f.list -xscrollcommand [list Scroll_Set $f.xscroll [list grid $f.xscroll -row 1 -column 0 -sticky we]] \
                -yscrollcommand [list Scroll_Set $f.yscroll [list grid $f.yscroll -row 0 -column 1 -sticky ns]]
   eval {$f.list configure} $args
   scrollbar $f.xscroll -orient horizontal -command [list $f.list xview]
   scrollbar $f.yscroll -orient vertical -command [list $f.list yview]
   grid $f.list -sticky news
   grid rowconfigure $f 0 -weight 1
   grid columnconfigure $f 0 -weight 1
   return $f.list
}

proc Scrolled_Listbox { f args } {
   frame $f
   listbox $f.list -xscrollcommand [list Scroll_Set $f.xscroll [list grid $f.xscroll -row 1 -column 0 -sticky we]] \
                   -yscrollcommand [list Scroll_Set $f.yscroll [list grid $f.yscroll -row 0 -column 1 -sticky ns]]
   eval {$f.list configure} $args
   scrollbar $f.xscroll -orient horizontal -command [list $f.list xview]
   scrollbar $f.yscroll -orient vertical -command [list $f.list yview]
   grid $f.list -sticky news
   grid rowconfigure $f 0 -weight 1
   grid columnconfigure $f 0 -weight 1
   return $f.list
}

proc Scroll_Set { scrollbar geoCmd offset size } {
   if { $offset != 0.0 || $size != 1.0 } {
      eval $geoCmd
   }
   $scrollbar set $offset $size
}

proc save_cursor { } {
   global audace
   global busy

   set busy [ list "$audace(base)" "$audace(Console)" ]
   set window_list $busy
   while {$window_list != ""} {
      set next {}
      foreach w $window_list {
         catch {
            #--- Le catch permet de traiter le cas des fenetres qui n'ont pas l'option -cursor
            #--- en les ignorant (exemple BWidget)
            set cursor [lindex [$w configure -cursor] 4]
            if { [ winfo toplevel $w ] == $w || $cursor != "" } {
               lappend busy [list $w $cursor]
            }
         }
         set next [concat $next [winfo children $w]]
      }
      set window_list $next
   }
}

proc all_cursor { curs } {
   global busy

   foreach w $busy {
      catch {[lindex $w 0] config -cursor $curs}
   }
   update
}

proc restore_cursor { } {
   global busy

   foreach w $busy {
      catch {[lindex $w 0] config -cursor [lindex $w 1]}
   }
}

#------------------------------------------------------------
#  startdebug
#     active le debugger "RamDebugger"
#
#     RamDebugger doit être installé dans le répertoire
#     audace/lib/RamDebugger
#------------------------------------------------------------
proc startdebug { } {
   global audace

   #if { [info exists audace(rep_install) ] } {
   #   lappend ::auto_path "$audace(rep_install)/lib/RamDebugger/addons"
   #} else {
   #   lappend ::auto_path "[pwd]/../../lib/RamDebugger/addons"
   #}
   #package require commR
   #comm::register audela 1

   catch {
      #--- Chargement statique de la librairie TK pour RamDebugger
      if { $::tcl_platform(os) == "Linux" } {
         #--- Pour LINUX, il faut inserer le prefixe "lib" devant le nom de la librairie
         load [file join "$::audela_start_dir" libtk8.4.so ]
      } else {
         load [file join "$::audela_start_dir" tk84t.dll ]
      }
   }
   package require RamDebugger
}

#
#--- Execute en premier au demarrage
#

#--- On cache la fenetre mere
wm focusmodel . passive
wm withdraw .


::audace::run
focus -force $audace(Console)
::console::GiveFocus

#--- On charge eventuellement l'image cliquee
if {[info exists audela(img_filename)]==1} {
   if {$audela(img_filename)!=""} {
      loadima $audela(img_filename)
      set audace(rep_images) [file dirname $audela(img_filename)]
   }
}

