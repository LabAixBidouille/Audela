#
# Fichier : aud.tcl
# Description : Fichier principal de l'application Aud'ACE
# Auteur : Denis MARCHAIS
# Date de mise a jour : 21 mars 2006

#--- Passage de TCL/TK 8.3 a 8.4
###tk::unsupported::ExposePrivateCommand *

#--- Chargement du package BWidget
package require BWidget

#--- Chargement d'un package
source audnet.tcl

#--- Ce n'est pas des packages, mais des outils
source notebook.tcl
source mclistbox.tcl
source menu.tcl

#--- Fichiers de audace
source aud1.tcl
source aud2.tcl
source aud3.tcl
source aud4.tcl
source aud5.tcl
source console.tcl
source confeditscript.tcl
source newscript.tcl
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
source astrometry.tcl
source vo_tools.tcl
source sectiongraph.tcl
source polydraw.tcl

namespace eval ::audace {
   variable This

   proc run { { this ".audace" } } {
      variable This
      global audace

      #--- Active le debugger
     ### ramdebugger

      set This $this
      set audace(base) $This

      initEnv
      set visuNo [ createDialog ]
      createMenu 
      initLastEnv $visuNo
      dispClock1
      affiche_Outil_F2

      #::console::disp "::confVisu::create \n"      
      #loadima $audace(rep_images)/m57.fit
      #::confVisu::create
      #loadima $audace(rep_images)/aaa.jpg 2
      
   }

   proc initEnv { } {
      global conf
      global audace
      global confgene
      global caption

      #--- Chargement de la librairie de definition de la commande combit
      if { [ lindex $::tcl_platform(os) 0 ] == "Windows" } {
         catch { load libcombit[ info sharedlibextension ] }
      }
      #--- Dans l'interface Aud'ACE, c'est la premiere fois que l'on appelle une fonction de libaudela.
      #--- Si libaudela n'a pas ete chargee, ca plante ici. D'ou le catch.
      #--- Utilisation de la Console
      set audace(console) "::console"
      set audace(Console) ".console"
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
      #--- Recherche des ports com
      ::audace::Recherche_Ports
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
      uplevel #0 "source \"[ file join $audace(rep_caption) caption.cap ]\""
      uplevel #0 "source \"[ file join $audace(rep_caption) confgene.cap ]\""
      uplevel #0 "source \"[ file join $audace(rep_caption) confgene_en-tete.cap ]\""
      uplevel #0 "source \"[ file join $audace(rep_caption) confgene_touche.cap ]\""
      uplevel #0 "source \"[ file join $audace(rep_caption) confeditscript.cap ]\""
      uplevel #0 "source \"[ file join $audace(rep_caption) astrometry.cap ]\""
      uplevel #0 "source \"[ file join $audace(rep_caption) bifsconv.cap ]\""
      uplevel #0 "source \"[ file join $audace(rep_caption) compute_stellaire.cap ]\"" 
      uplevel #0 "source \"[ file join $audace(rep_caption) divers.cap ]\"" 
      uplevel #0 "source \"[ file join $audace(rep_caption) iris.cap ]\"" 
      uplevel #0 "source \"[ file join $audace(rep_caption) newscript.cap ]\"" 
      uplevel #0 "source \"[ file join $audace(rep_caption) poly.cap ]\"" 
      uplevel #0 "source \"[ file join $audace(rep_caption) filtrage.cap ]\"" 

      #--- Creation de la console
      $audace(console)::create

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

      #---
      set audace(rep_audela) [pwd]

      #--- On utilise les valeurs contenues dans le tableau conf pour l'initialisation
      set confgene(temps,hsysteme)         [ lindex "$caption(audace,temps_heurelegale) $caption(audace,temps_universel)" "$conf(temps,hsysteme)" ]
      set confgene(temps,fushoraire)       $conf(temps,fushoraire)
      set confgene(temps,hhiverete)        [ lindex "$caption(confgene,temps_aucune) $caption(confgene,temps_hiver) $caption(confgene,temps_ete)" "$conf(temps,hhiverete)" ]
      #---
      set confgene(posobs,observateur,gps) $conf(posobs,observateur,gps)
      set audace(posobs,observateur,gps)   $confgene(posobs,observateur,gps)
      set confgene(fichier,compres)        $conf(fichier,compres)
      #---
      set audace(camNo) "0"
   }

   proc Default_exeutils { } {
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
      set repertCourant [pwd]
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
      global tmp

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
      if { ! [ info exists conf(visu_zoom) ] }                 { set conf(visu_zoom)                 "1" }
      if { ! [ info exists conf(visu_palette) ] }              { set conf(visu_palette)              "1" }
      if { ! [ info exists conf(fonction_transfert,param2) ] } { set conf(fonction_transfert,param2) "1" }
      if { ! [ info exists conf(fonction_transfert,param3) ] } { set conf(fonction_transfert,param3) "1" }
      if { ! [ info exists conf(fonction_transfert,param4) ] } { set conf(fonction_transfert,param4) "1" }

      #--- Initialisation des executables
      ::audace::Default_exeutils
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
      if {($ipnum==$ipnumhost)||($ipnum=="")} {
           set ipnum [expr $ipnumhost+10]
           if {$ipnum>255} {
              set ipnum [expr $ipnumhost-10]
           }
      }
      return "${ipmask}.${ipnum}"
   }

   proc createDialog { } {
      variable This
      global conf
      global audace
      global caption

      #---
      toplevel $This -class 1
      wm geometry $This 631x453+0+0
      wm maxsize $This [winfo screenwidth .] [winfo screenheight .]
      wm minsize $This 631 453
      wm resizable $This 1 1
      wm deiconify $This

      #--- Je cree la visu de la fenetre principale
      set visuNo [::confVisu::create $audace(base)]
        
      #---
      wm title $This "$caption(audace,titre) (visu$visuNo)"
      wm protocol $This WM_DELETE_WINDOW " ::audace::quitter "
      update

      #--- Creation des variables audace dependant de la visu
      set audace(visuNo)  $visuNo
      set audace(bufNo)   [visu$visuNo buf]
      set audace(imageNo) [visu$visuNo image]
      set audace(hCanvas) $::confVisu::private($visuNo,hCanvas)

      #--- Chargement des differents outils
      foreach fichier [ glob [ file join audace plugin tool * pkgIndex.tcl ] ] {
         uplevel #0 "source $fichier"
         set nom [ file tail [ file dirname "$fichier" ] ]
         package require $nom
         $audace(console)::affiche_prompt "# $fichier [ package present $nom ] \n"
      }
      $audace(console)::disp "\n"

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

      Menu           $visuNo "$caption(audace,menu,fichier)"
      Menu_Command   $visuNo "$caption(audace,menu,fichier)" "$caption(audace,menu,charger)..." \
         "::audace::charger $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,fichier)" "$caption(audace,menu,enregistrer)" \
         "::audace::enregistrer $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,fichier)" "$caption(audace,menu,enregistrer_sous)..." \
         "::audace::enregistrer_sous $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,fichier)" "$caption(audace,menu,copyjpeg)..." "::audace::copyjpeg"

      Menu_Separator $visuNo "$caption(audace,menu,fichier)"
      Menu_Command   $visuNo "$caption(audace,menu,fichier)" "$caption(audace,menu,entete)" "::audace::header $visuNo"
      Menu_Separator $visuNo "$caption(audace,menu,fichier)"
      Menu_Command   $visuNo "$caption(audace,menu,fichier)" "$caption(audace,menu,select)..." ::selectWindow::run
      Menu_Separator $visuNo "$caption(audace,menu,fichier)"
      Menu_Command   $visuNo "$caption(audace,menu,fichier)" "$caption(audace,menu,nouveau_script)..." ::audace::newScript
      Menu_Command   $visuNo "$caption(audace,menu,fichier)" "$caption(audace,menu,editer_script)..." ::audace::editScript
      Menu_Command   $visuNo "$caption(audace,menu,fichier)" "$caption(audace,menu,lancer_script)..." ::audace::runScript
      Menu_Separator $visuNo "$caption(audace,menu,fichier)"
      Menu_Command   $visuNo  "$caption(audace,menu,fichier)" "$caption(audace,menu,quitter)" "::audace::quitter"

      Menu           $visuNo "$caption(audace,menu,affichage)"
      Menu_Command   $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,nouvelle_visu)" ::confVisu::create
      Menu_Separator $visuNo "$caption(audace,menu,affichage)"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,palette_grise)" \
              "1" "conf(visu_palette)" "::audace::MAJ_palette $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,palette_inverse)" \
              "2" "conf(visu_palette)" "::audace::MAJ_palette $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,palette_iris)" \
              "3" "conf(visu_palette)" "::audace::MAJ_palette $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,affichage)" "$caption(audace,menu,palette_arc_en_ciel)" \
              "5" "conf(visu_palette)" "::audace::MAJ_palette $visuNo"
      Menu_Separator $visuNo "$caption(audace,menu,affichage)"
      Menu_Cascade $visuNo "$caption(audace,menu,affichage)" "$caption(fcttransfert,titre)" 
      Menu_Command_Radiobutton $visuNo "$caption(fcttransfert,titre)" "$caption(fcttransfert,lin)" "1" \
              "conf(fonction_transfert,visu$visuNo,mode)" "::audace::fonction_transfert $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(fcttransfert,titre)" "$caption(fcttransfert,log)" "2" \
              "conf(fonction_transfert,visu$visuNo,mode)" "::audace::fonction_transfert $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(fcttransfert,titre)" "$caption(fcttransfert,exp)" "3" \
              "conf(fonction_transfert,visu$visuNo,mode)" "::audace::fonction_transfert $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(fcttransfert,titre)" "$caption(fcttransfert,arc)" "4" \
              "conf(fonction_transfert,visu$visuNo,mode)" "::audace::fonction_transfert $visuNo"
      Menu_Separator $visuNo "$caption(audace,menu,affichage)"
      Menu_Command $visuNo "$caption(audace,menu,affichage)" "$caption(seuils,titre)..." \
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
            if { [ winfo exists $audace(base).select_color ] } { \
               destroy $audace(base).select_color \
               ::confColor::run $visuNo\
            } \
         "
      Menu_Separator $visuNo "$caption(audace,menu,affichage)"
      Menu_Command   $visuNo "$caption(audace,menu,affichage)" "[::Crosshair::getLabel]..." \
              "::confGenerique::run $audace(base).confCrossHair ::Crosshair $visuNo"

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
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,window1)" {
              if { [ buf$audace(bufNo) imageready ] == "1" } {
                 "window"
                 ::audace::autovisu $audace(visuNo)
              }
           }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,scale)..." \
         { ::traiteImage::run "$caption(audace,menu,scale)" "$audace(base).traiteImage" }
      Menu_Separator $visuNo "$caption(audace,menu,pretraite)"
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,offset)..." \
         { ::traiteImage::run "$caption(audace,menu,offset)" "$audace(base).traiteImage" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,mult_cte)..." \
         { ::traiteImage::run "$caption(audace,menu,mult_cte)" "$audace(base).traiteImage" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,noffset)..." \
         { ::traiteImage::run "$caption(audace,menu,noffset)" "$audace(base).traiteImage" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,ngain)..." \
         { ::traiteImage::run "$caption(audace,menu,ngain)" "$audace(base).traiteImage" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,addition)..." \
         { ::traiteImage::run "$caption(audace,menu,addition)" "$audace(base).traiteImage" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,soust)..." \
         { ::traiteImage::run "$caption(audace,menu,soust)" "$audace(base).traiteImage" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,division)..." \
         { ::traiteImage::run "$caption(audace,menu,division)" "$audace(base).traiteImage" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,subsky)..." \
         { ::traiteImage::run "$caption(audace,menu,subsky)" "$audace(base).traiteImage" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,clip)..." \
         { ::traiteImage::run "$caption(audace,menu,clip)" "$audace(base).traiteImage" }
      Menu_Separator $visuNo "$caption(audace,menu,pretraite)"
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,run,median)..." \
         { ::traiteWindow::run "$caption(audace,run,median)" "$audace(base).traiteWindow" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,image,somme)..." \
         { ::traiteWindow::run "$caption(audace,image,somme)" "$audace(base).traiteWindow" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,image,moyenne)..." \
         { ::traiteWindow::run "$caption(audace,image,moyenne)" "$audace(base).traiteWindow" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,image,ecart_type)..." \
         { ::traiteWindow::run "$caption(audace,image,ecart_type)" "$audace(base).traiteWindow" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,offset)..." \
         { ::traiteWindow::run "$caption(audace,menu,offset)" "$audace(base).traiteWindow" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,noffset)..." \
         { ::traiteWindow::run "$caption(audace,menu,noffset)" "$audace(base).traiteWindow" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,ngain)..." \
         { ::traiteWindow::run "$caption(audace,menu,ngain)" "$audace(base).traiteWindow" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,addition)..." \
         { ::traiteWindow::run "$caption(audace,menu,addition)" "$audace(base).traiteWindow" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,soust)..." \
         { ::traiteWindow::run "$caption(audace,menu,soust)" "$audace(base).traiteWindow" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,menu,division)..." \
         { ::traiteWindow::run "$caption(audace,menu,division)" "$audace(base).traiteWindow" }
      Menu_Command   $visuNo "$caption(audace,menu,pretraite)" "$caption(audace,optimisation,noir)..." \
         { ::traiteWindow::run "$caption(audace,optimisation,noir)" "$audace(base).traiteWindow" }

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
      Menu_Command   $visuNo "$caption(audace,menu,analyse)" "$caption(audace,menu,astrometry)..." ::astrometry::create
      Menu_Command   $visuNo "$caption(audace,menu,analyse)" "$caption(audace,menu,carte_champ)..." \
         { ::mapWindow::run "$audace(base).mapWindow" }
      Menu_Command   $visuNo "$caption(audace,menu,analyse)" "$caption(audace,menu,carte)" \
         { ::carte::showMapFromBuffer buf$audace(bufNo) }

      Menu           $visuNo "$caption(audace,menu,outils)"
      Menu_Command   $visuNo "$caption(audace,menu,outils)" "$caption(audace,menu,pas_outil)" { ::audace::pas_Outil }
      Menu_Separator $visuNo "$caption(audace,menu,outils)"
      #--- Affichage des outils du menu Outils
      ::audace::affiche_Outil $visuNo
      Menu_Separator $visuNo "$caption(audace,menu,outils)"
      Menu_Command   $visuNo "$caption(audace,menu,outils)" "$caption(confgene,choix_outils)..." \
         { ::confChoixOutil::run "$audace(base).confChoixOutil" }

      Menu           $visuNo "$caption(audace,menu,configuration)"
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,general)..." \
         { ::confGeneral::run "$audace(base).confGeneral" }
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,cwd)..." \
         { ::cwdWindow::run "$audace(base).cwdWindow" }
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,editeur)..." \
         { ::confEditScript::run "$audace(base).confEditScript" }
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(confgene,temps)..." \
         { ::confTemps::run "$audace(base).confTemps" }
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(confgene,position)..." \
         { ::confPosObs::run "$audace(base).confPosObs" }
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(confgene,fichier_image)..." \
         { ::confFichierIma::run "$audace(base).confFichierIma" }
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(confgene,alarme)..." \
         { ::confAlarmeFinPose::run "$audace(base).confAlarmeFinPose" }
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(confgene,tempo_scan)..." \
         { ::confTempoScan::run "$audace(base).confTempoScan" }
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(confgene,messages_console)..." \
         { ::confMessages_Console::run "$audace(base).confMessages_Console" }
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(confgene,type_fenetre)..." \
         { ::confTypeFenetre::run "$audace(base).confTypeFenetre" }
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,apparence)..." \
         "::confColor::run $visuNo"
      Menu_Separator $visuNo "$caption(audace,menu,configuration)"
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,camera)..." ::confCam::run
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,monture)..." ::confTel::run
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,liaison)..." ::confLink::run
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,optique)..." \
         "::confGenerique::run $audace(base).confOptic ::confOptic $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,equipement)..." ::confEqt::run
      Menu_Separator $visuNo "$caption(audace,menu,configuration)"
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,raquette)..." ::confPad::run
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,carte)..." ::confCat::run
      Menu_Separator $visuNo "$caption(audace,menu,configuration)"
      Menu_Command   $visuNo "$caption(audace,menu,configuration)" "$caption(audace,menu,sauve_config)" \
         " ::audace::enregistrerConfiguration $visuNo "

      Menu           $visuNo "$caption(audace,menu,aide)"
      Menu_Command   $visuNo "$caption(audace,menu,aide)" "$caption(audace,menu,sommaire)" ::audace::showMain
      Menu_Command   $visuNo "$caption(audace,menu,aide)" "$caption(audace,menu,fonctions)" ::audace::showFunctions
      Menu_Cascade   $visuNo "$caption(audace,menu,aide)" "$caption(audace,menu,site_audela)"
      Menu_Command   $visuNo "$caption(audace,menu,site_audela)" "$caption(audace,menu,site_internet)" {
         set filename "$caption(en-tete,a_propos_de_site)" ; ::audace::Lance_Site_htm $filename }
      Menu_Command   $visuNo "$caption(audace,menu,site_audela)" "$caption(audace,menu,site_dd)..." ::audace::editSiteWebAudeLA
      Menu_Command   $visuNo "$caption(audace,menu,aide)" "$caption(audace,menu,notice_pdf)..." ::audace::editNotice_pdf
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
      global confgene
      global tmp
      
      #--- Mise a jour des couleurs des interfaces
      ::confColor::applyColor $audace(base)
      ::confColor::applyColor $audace(Console)

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

      #--- Affichage des ports com disponibles
      if { [ llength $audace(list_com) ] != "0" } {
              $audace(console)::affiche_resultat "$caption(audace,port_com_dispo) $audace(list_com) \n\n"
      } else {
              $audace(console)::affiche_resultat "$caption(audace,port_com_dispo) $caption(audace,pas_port) \n\n"
      }

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

      #--- Prise en compte de la palette prealablement choisie
      ::audace::MAJ_palette $visuNo

      #--- Configure PortTalk
      if { $::tcl_platform(os) == "Windows NT" } {
         set res [ catch { set result [ porttalk open all ] } msg ]
         set no_administrator "PortTalk: You do not have rights to access"
         if { ( $res == "1" ) && ( [ file exists "[ file join $audace(rep_install) bin allowio.txt ]" ] == "0" ) } {
            if { [ string range $msg 0 41 ] != "$no_administrator" } {
               $audace(console)::affiche_erreur "$msg\n\n$caption(audace,porttalk_erreur)\n"
            } else {
               $audace(console)::affiche_erreur "$msg\n"
            }
            set base ".allowio"
            toplevel $base 
            wm geometry $base +50+100
            wm resizable $base 0 0
            wm deiconify $base
            wm title $base "$caption(audace,porttalk,titre)"
            if { [ string range $msg 0 41 ] != "$no_administrator" } {
               message $base.msg -text "$msg\n\n$caption(audace,porttalk_erreur)\n" -font 6 -justify center -width 460
            } else {
               message $base.msg -text "$msg\n" -font 6 -justify center -width 460
            }
            pack $base.msg -in $base -anchor center -side top -fill x -padx 0 -pady 0 -expand 0
            frame $base.frame1
               set saveallowio "0"
               checkbutton $base.frame1.check1 -variable saveallowio
               pack $base.frame1.check1 -anchor w -side left -fill x -padx 1 -pady 1 -expand 1
               label $base.frame1.lab1 -text "$caption(audace,porttalk,message)" -font 6
               pack $base.frame1.lab1 -anchor w -side left -fill x -padx 1 -pady 1 -expand 1
            pack $base.frame1 -in $base -anchor center -side top -fill none -padx 0 -pady 0 -expand 0
            button $base.but1 -text "$caption(conf,ok)" \
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
               $audace(console)::affiche_prompt "$caption(audace,porttalk) $result\n\n"
            }
         }
      }

      #--- Connexion au demarrage des cameras
      if { $conf(camera,A,start) == "1" } {
         if { $conf(confLink,start) == "1" } {
            ::confLink::configureDriver
         }
         ::confCam::configureCamera "A"
      }
      if { $conf(camera,B,start) == "1" } {
         ::confCam::configureCamera "B"
      }
      if { $conf(camera,C,start) == "1" } {
         ::confCam::configureCamera "C"
      }

      #--- Connexion au demarrage du telescope
      if { $conf(telescope,start) == "1" } {
         if { $conf(confLink,start) == "1" } {
            ::confLink::configureDriver
         }
         ::confTel::configureTelescope
      }

      #--- Connexion au demarrage du driver de la raquette
      if { $conf(confPad,start) == "1" } {
         ::confPad::configureDriver
      }

      #--- Connexion au demarrage de l'equipement
      if { $conf(confEqt,start) == "1" } {
         ::confEqt::configureDriver
      }

      #--- Connexion au demarrage du driver de carte
      if { $conf(confCat,start) == "1" } {
         ::confCat::configureDriver
      }
   }

   proc Recherche_Ports { } {
      global audace
      global caption

      #--- Suivant l'OS
      if { $::tcl_platform(os) == "Linux" } {
         set port_com "/dev/ttyS"
         set port_com_usb "/dev/ttyUSB"
         set kk "0"
         set kd "2"
      } else {
         set port_com "com"
         set kk "1"
         set kd "3"
      }

      #--- Recherche des ports com
      set comlist              ""
      set comlist_usb          ""
      set audace(list_com)     ""

      for { set k $kk } { $k < 20 } { incr k } {
         if { $k != "$kd" } {
            set errnum [ catch { open $port_com$k r+ } msg ]
            if { $errnum == "0" } {
               lappend comlist $k
               close $msg
            }
         }
      }
      set long_com [ llength $comlist ]

      for { set k 0 } { $k < $long_com } { incr k } {
         lappend audace(list_com) "$port_com[ lindex $comlist $k ]"
      }

      if { $::tcl_platform(os) == "Linux" } {
         for { set k $kk } { $k < 20 } { incr k } {
            set errnum [ catch { open $port_com_usb$k r+ } msg ]
            if { $errnum == "0" } {
               lappend comlist_usb $k
               close $msg
            }
         }
         set long_com_usb [ llength $comlist_usb ]

         for { set k 0 } { $k < $long_com_usb } { incr k } {
            lappend audace(list_com) "$port_com_usb[ lindex $comlist_usb $k ]"
         }
      }
   }

   #
   # ::audace::affiche_Outil 
   # Fonction qui permet d'afficher les outils dans le menu Outils
   #
   proc affiche_Outil { visuNo } {
      global audace
      global panneau
      global caption
      global confgene
      global conf

      set confgene(Choix_Outil,nbre) "0"
      set i "0"
      set liste ""
      foreach m [array names panneau menu_name,*] {
         lappend liste [list "$panneau($m) " $m]
      }
      foreach m [lsort $liste] {
         set m [lindex $m 1]
         set i [expr $i + 1]
         #--- Initialisation des variables indispensable ici
         if { ! [ info exists conf(panneau,n$i) ] }   { set conf(panneau,n$i)  "1" }
         if { ! [ info exists conf(raccourci,n$i) ] } { set conf(raccourci,n$i) "" }
         #---
         set confgene(Choix_Outil,nbre) [ expr $confgene(Choix_Outil,nbre) + 1 ]
         set confgene(Choix_Outil,n$confgene(Choix_Outil,nbre)) $conf(panneau,n$confgene(Choix_Outil,nbre))
         if { $confgene(Choix_Outil,n$confgene(Choix_Outil,nbre)) == "1" } {
            if { [scan "$m" "menu_name,%s" ns] == "1" } {
               Menu_Command $visuNo "$caption(audace,menu,outils)" "$panneau($m)" "::confVisu::selectTool $visuNo ::$ns"
               if { $conf(raccourci,n$i) != "" } {
                  set raccourci(n$i) $conf(raccourci,n$i)
                  if { [string range $raccourci(n$i) 0 3] == "Alt+" } {
                     set raccourci(n$i) "Alt-[string tolower [string range $raccourci(n$i) 4 4]]"
                  } elseif { [string range $raccourci(n$i) 0 4] == "Ctrl+" } {
                     set raccourci(n$i) "Control-[string tolower [string range $raccourci(n$i) 5 5]]"
                  }
                  #---
                  lappend audace(list_raccourcis) [ list $conf(raccourci,n$i) ]
                  lappend audace(list_ns_raccourcis) [ list $ns ]
                  #---
                  Menu_Bind $visuNo $audace(base) <$raccourci(n$i)> "$caption(audace,menu,outils)" "$panneau($m)" "$conf(raccourci,n$i)"
                            bind $audace(Console) <$raccourci(n$i)> "focus $audace(base) ; ::confVisu::selectTool $visuNo ::$ns"
               }
            }
         }
      }
   }

   #
   # ::audace::affiche_Outil_F2
   # Affiche automatiquement au demarrage l'outil ayant F2 pour raccourci
   #
   proc affiche_Outil_F2 { } {
      global conf
      global panneau
      global audace

      #---
      set i "0"
      set liste ""
      foreach m [array names panneau menu_name,*] {
         lappend liste [list "$panneau($m) " $m]
      }
      foreach m [lsort $liste] {
         set m [lindex $m 1]
         set i [expr $i + 1]
         if { $conf(raccourci,n$i) != "" } {
            set raccourci(n$i) $conf(raccourci,n$i)
            if { $raccourci(n$i) == "F2" } {
               if { [scan "$m" "menu_name,%s" ns] == "1" } {
                  #--- Lancement automatique de l'outil ayant le raccourci F2
                  ::confVisu::selectTool $audace(visuNo) ::$ns
               }
            }
         }
      }
   }

   #
   # ::audace::pas_Outil
   # Efface l'interface de l'outil si elle est affichee dans la visu principale
   #
   proc pas_Outil { } {
      global audace

      ::confVisu::stopTool $audace(visuNo)
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
      variable This
      global audace
      global caption
      global conf
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
      variable This
      global audace
      global caption
      global conf
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

   proc enregistrer { visuNo } {
      global audace

      menustate disabled
      save_cursor
      all_cursor watch
      set errnum [ catch { saveima $::confVisu::private($visuNo,lastFileName) $visuNo } msg ]
      if { $errnum == "1" } {
         tk_messageBox -message "$msg" -icon error
      }
      restore_cursor
      menustate normal
   }

   proc enregistrer_sous { visuNo } {
      menustate disabled
      save_cursor
      all_cursor watch
      set errnum [ catch { saveima ? $visuNo } msg ]
      if { $errnum == "1" } {
         tk_messageBox -message "$msg" -icon error
      }
      restore_cursor
      menustate normal
   }

   proc charger { visuNo } {
      menustate disabled
      save_cursor
      all_cursor watch
      set errnum [ catch { loadima ? $visuNo } msg ]
      if { $errnum == "1" } {
         tk_messageBox -message "$msg" -icon error
      }
      restore_cursor
      menustate normal
   }

   proc copyjpeg { } {
      global audace

      menustate disabled
      save_cursor
      all_cursor watch
      #---
      set bufNo [ visu$audace(visuNo) buf ]
      #--- On sort immediatement s'il n'y a pas d'image dans le buffer
      if { [ buf$bufNo imageready ] == "0" } {
         restore_cursor
         menustate normal
         return
      }
      #---
      set errnum [ catch { sauve_jpeg ? } msg ]
      if { $errnum == "1" } {
         tk_messageBox -message "$msg" -icon error
      }
      restore_cursor
      menustate normal
   }

   #------------------------------------------------------------
   #  autovisu
   #     rafraichit l'affichage
   #------------------------------------------------------------

   proc autovisu { visuNo { force "-no" } { fileName "" } } {
      ::confVisu::autovisu $visuNo $force $fileName
   }

   #------------------------------------------------------------
   # fonction_transfert
   #    Procédure d'affichage de la fenêtre "fonctions de transfert"
   #------------------------------------------------------------
   proc fonction_transfert { visuNo } {
      global audace caption conf tmp

      #--- Fenetre de base
      set base $::confVisu::private($visuNo,This)

      #---
      if { ! [ info exists conf(fonction_transfert,visu$visuNo,position) ] } \
         { set conf(fonction_transfert,visu$visuNo,position) "+0+0" }
      #---
      if { ! [ info exists conf(fonction_transfert,visu$visuNo,mode) ] } \
         { set conf(fonction_transfert,visu$visuNo,mode) "1" }

      #---
      if { [ winfo exists $base.fonction_transfert ] == "0" } {
         #--- Création de la fenêtre
         toplevel $base.fonction_transfert
         wm geometry $base.fonction_transfert $conf(fonction_transfert,visu$visuNo,position)
         wm title $base.fonction_transfert "$caption(fcttransfert,titre) (visu$visuNo)"
         wm transient $base.fonction_transfert [ winfo parent $base.fonction_transfert ] 
         wm protocol $base.fonction_transfert WM_DELETE_WINDOW " ::audace::fonction_transfertquit $visuNo "

         #--- Enregistrement des réglages courants
         set tmp(fonction_transfert,visu$visuNo,mode) $conf(fonction_transfert,visu$visuNo,mode)
         set tmp(fonction_transfert,param2) $conf(fonction_transfert,param2)
         set tmp(fonction_transfert,param3) $conf(fonction_transfert,param3)
         set tmp(fonction_transfert,param4) $conf(fonction_transfert,param4)

         #--- Sous-trame réglage fonction de transfert
         frame $base.fonction_transfert.regl
         pack $base.fonction_transfert.regl -expand true

         frame $base.fonction_transfert.regl.1
         pack $base.fonction_transfert.regl.1 -fill x
         radiobutton $base.fonction_transfert.regl.1.but -variable conf(fonction_transfert,visu$visuNo,mode) \
            -text $caption(fcttransfert,lin) -value 1
         pack $base.fonction_transfert.regl.1.but -side left
         frame $base.fonction_transfert.regl.2
         pack $base.fonction_transfert.regl.2 -fill x      
         radiobutton $base.fonction_transfert.regl.2.but -variable conf(fonction_transfert,visu$visuNo,mode) \
            -text $caption(fcttransfert,log) -value 2
         pack $base.fonction_transfert.regl.2.but -side left
         entry $base.fonction_transfert.regl.2.ent -textvariable conf(fonction_transfert,param2) \
            -font $audace(font,arial_8_b) -width 4 -justify center
         pack $base.fonction_transfert.regl.2.ent -side right
         frame $base.fonction_transfert.regl.3
         pack $base.fonction_transfert.regl.3 -fill x
         radiobutton $base.fonction_transfert.regl.3.but -variable conf(fonction_transfert,visu$visuNo,mode) \
            -text $caption(fcttransfert,exp) -value 3
         pack $base.fonction_transfert.regl.3.but -side left      
         entry $base.fonction_transfert.regl.3.ent -textvariable conf(fonction_transfert,param3) \
            -font $audace(font,arial_8_b) -width 4 -justify center
         pack $base.fonction_transfert.regl.3.ent -side right
         frame $base.fonction_transfert.regl.4
         pack $base.fonction_transfert.regl.4 -fill x
         radiobutton $base.fonction_transfert.regl.4.but -variable conf(fonction_transfert,visu$visuNo,mode) \
            -text $caption(fcttransfert,arc) -value 4
         pack $base.fonction_transfert.regl.4.but -side left      
         entry $base.fonction_transfert.regl.4.ent -textvariable conf(fonction_transfert,param4) \
            -font $audace(font,arial_8_b) -width 4 -justify center
         pack $base.fonction_transfert.regl.4.ent -side right
         button $base.fonction_transfert.regl.aide -command ::audace::fonction_transfertaide \
            -text $caption(conf,aide) -width 8
         pack $base.fonction_transfert.regl.aide -expand true -padx 10 -pady 10

         #--- Sous-trame boutons OK, prévisu & quitter
         frame $base.fonction_transfert.buttons
         pack $base.fonction_transfert.buttons
         button $base.fonction_transfert.buttons.ok -command " ::audace::fonction_transfertok $visuNo " \
            -text $caption(conf,ok)
         pack $base.fonction_transfert.buttons.ok -side left -expand true -padx 14 -pady 10 -ipadx 10
         button $base.fonction_transfert.buttons.previsu -command " ::audace::MAJ_palette $visuNo " \
            -text $caption(conf,previsu)
         pack $base.fonction_transfert.buttons.previsu -side left -expand true -padx 14 -pady 10 -ipadx 10
         button $base.fonction_transfert.buttons.quit -command " ::audace::fonction_transfertquit $visuNo " \
            -text $caption(conf,quitter)
         pack $base.fonction_transfert.buttons.quit -side left -expand true -padx 14 -pady 10 -ipadx 10

         #--- Focus
         focus $base.fonction_transfert

         #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
         bind $base.fonction_transfert <Key-F1> { $audace(console)::GiveFocus }

         #--- Mise a jour dynamique des couleurs
         ::confColor::applyColor $base.fonction_transfert
      } else {
         focus $base.fonction_transfert
      }
   }

   proc fonction_transfertok { visuNo } {
      global audace conf tmp

      #--- Fenetre de base
      set base $::confVisu::private($visuNo,This)
      #---
      set tmp(fonction_transfert,visu$visuNo,mode) $conf(fonction_transfert,visu$visuNo,mode)
      #--- Récupération de la position de la fenêtre de réglages
      fonction_transfert_recup_position $visuNo
      #---
      destroy $base.fonction_transfert
      ::audace::MAJ_palette $visuNo
   }

   proc fonction_transfertquit { visuNo } {
      global conf tmp

      #--- On récupère les anciens paramètres
      set conf(fonction_transfert,visu$visuNo,mode) $tmp(fonction_transfert,visu$visuNo,mode)
      set conf(fonction_transfert,param2) $tmp(fonction_transfert,param2)
      set conf(fonction_transfert,param3) $tmp(fonction_transfert,param3)
      set conf(fonction_transfert,param4) $tmp(fonction_transfert,param4)
      fonction_transfertok $visuNo
   }

   proc fonction_transfert_recup_position { visuNo } {
      global audace conf

      #--- Fenetre de base
      set base $::confVisu::private($visuNo,This)
      #---
      set fonction_transfert(visu$visuNo,geometry) [ wm geometry $base.fonction_transfert ]
      set deb [ expr 1 + [ string first + $fonction_transfert(visu$visuNo,geometry) ] ]
      set fin [ string length $fonction_transfert(visu$visuNo,geometry) ]
      set conf(fonction_transfert,visu$visuNo,position) "+[string range $fonction_transfert(visu$visuNo,geometry) $deb $fin]"
   }

   #--- Procédure d'affichage de la fenêtre "aide pour réglage de la fonction de transfert"
   proc fonction_transfertaide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,affichage)" "1020transfert.htm"
   }

   #--- Procédure de création dynamique de la palette en fonction de la fonction de transfert
   proc MAJ_palette { visuNo } {
      global audace conf tmp

      #--- On récupère le nom du fichier palette "de base"
      switch $conf(visu_palette) {
         1 { set fichier_palette_in [ file join $audace(rep_audela) audace palette gray ] }
         2 { set fichier_palette_in [ file join $audace(rep_audela) audace palette inv ] }
         3 { set fichier_palette_in [ file join $audace(rep_audela) audace palette iris ] }
         5 { set fichier_palette_in [ file join $audace(rep_audela) audace palette rainbow ] }
      }

      switch $conf(fonction_transfert,visu$visuNo,mode) {
         1 {
            #--- Fonction de transfert linéaire : pas besoin de créer une palette
            visu$visuNo paldir [file dirname $fichier_palette_in]
            visu$visuNo pal [file tail $fichier_palette_in]         }
         2 {
            #--- Fonction de transfert log
            if { $conf(fonction_transfert,param2) == 0 } {
               #--- On est ramené au cas linéaire
                 visu$visuNo pal $fichier_palette_in
            } else {
               set conf(fonction_transfert,param2) [expr abs($conf(fonction_transfert,param2))]
               #--- On détermine quelle partie de la courbe log on utilise (abcisses [a b])
               #--- (celle au dessus de la droite d'équation y=x-1-param)
               set dicho 0.5
               set a 0.5
               while {$dicho>0.001} {
                  if {[expr log($a)]>[expr $a-1-$conf(fonction_transfert,param2)]} {
                     set a [expr $a-$dicho/2]
                  } else {
                     set a [expr $a+$dicho/2]
                  }
                  set dicho [expr $dicho/2]
               }

               set dicho $conf(fonction_transfert,param2)
               set b [expr $conf(fonction_transfert,param2)+1]
               while {$dicho>0.001} {
                  if {[expr log($b)]>[expr $b-1-$conf(fonction_transfert,param2)]} {
                     set b [expr $b+$dicho/2]
                  } else {
                     set b [expr $b+$dicho/2]
                  }
                  set dicho [expr $dicho/2]
               }

               set Ya [expr log($a)]
               set Yb [expr log($b)]
               set deltax [expr $b-$a]
               set deltaY [expr $Yb-$Ya]

               #--- Ouverture des fichiers de palette
               set palette_in [open ${fichier_palette_in}.pal r]
               set palette_ex [open ${tmp(fichier_palette)}.pal w]

               set k_in 0
               #--- Ecriture du fichier de palette sortant
               for {set k_ex 0} {$k_ex<256} {incr k_ex} {
                  set valeur [expr abs((log($a+1.*$k_ex*$deltax/255)-$Ya)*255/$deltaY)]

                  #--- Si $valeur n'est pas entier, il faut interpoler entre les entiers juste au
                  #--- dessous et juste au dessus de $valeur
                  #--- Même s'il est entier, ça marche aussi
                  while {$k_in<$valeur} {
                     incr k_in
                     set entree-1_in [gets $palette_in]
                  }

                  if {[expr $k_in -1] < $valeur} {
                     #--- Test de sécurité : on ne continue que si $k_in < 255
                     if {$k_in < 255 } {
                        if { [ info exist entree_in ] } {
                           set entree-1_in $entree_in
                        }
                        set entree_in [gets $palette_in]
                        incr k_in
                     }
                  }

                  if { ! [info exist entree-1_in]} {
                     set entree-1_in $entree_in
                  }
                  puts $palette_ex [list [expr ($valeur-int($valeur))*[lindex ${entree-1_in} 0]+(1-$valeur+int($valeur))*[lindex $entree_in 0]] [expr ($valeur-int($valeur))*[lindex ${entree-1_in} 1]+(1-$valeur+int($valeur))*[lindex $entree_in 1]] [expr ($valeur-int($valeur))*[lindex ${entree-1_in} 2]+(1-$valeur+int($valeur))*[lindex $entree_in 2]]]
               }

               close $palette_in
               close $palette_ex

               visu$visuNo paldir [file dirname $tmp(fichier_palette)]
               visu$visuNo pal [file tail $tmp(fichier_palette)]
            }
         }
         3 {
            #--- Fonction de transfert exp
            if { $conf(fonction_transfert,param3) == 0 } {
               #--- On est ramené au cas linéaire
               visu$visuNo pal $fichier_palette
            } else {
               set conf(fonction_transfert,param3) [expr abs($conf(fonction_transfert,param3))]

               #--- On détermine quelle partie de la courbe exp on utilise (abcisses [a b])
               #--- (celle au dessus de la droite d'équation y=x+1+paramètre_exp)
               set dicho [expr $conf(fonction_transfert,param3)+1]
               set a [expr -$conf(fonction_transfert,param3)-1]
               while {$dicho>0.001} {
                  if {[expr exp($a)]>[expr $a+1+$conf(fonction_transfert,param3)]} {
                     set a [expr $a+$dicho/2]
                  } else {
                     set a [expr $a-$dicho/2]
                  }
                  set dicho [expr $dicho/2]
               }
               set dicho [expr $conf(fonction_transfert,param3)+1]
               set b [expr $conf(fonction_transfert,param3)+1]
               while {$dicho>0.001} {
                  if {[expr exp($b)]>[expr $b+1+$conf(fonction_transfert,param3)]} {
                     set b [expr $b-$dicho/2]
                  } else {
                     set b [expr $b+$dicho/2]
                  }
                  set dicho [expr $dicho/2]
               }

               set Ya [expr exp($a)]
               set Yb [expr exp($b)]
               set deltax [expr $b-$a]
               set deltaY [expr $Yb-$Ya]

               #--- Ouverture des fichiers de palette
               set palette_in [open ${fichier_palette_in}.pal r]
               set palette_ex [open ${tmp(fichier_palette)}.pal w]

               set k_in 0
               #--- Ecriture du fichier de palette sortant
               for {set k_ex 0} {$k_ex<256} {incr k_ex} {
                  set valeur [expr abs((exp($a+1.*$k_ex*$deltax/255)-$Ya)*255/$deltaY)]

                  #--- Si $valeur n'est pas entier, il faut interpoler entre les entiers juste au
                  #--- dessous et juste au dessus de $valeur
                  #--- Même s'il est entier, ça marche aussi
                  while {$k_in<$valeur} {
                     incr k_in
                     set entree-1_in [gets $palette_in]
                  }

                  if {[expr $k_in -1] < $valeur} {
                     #--- Test de sécurité : on ne continue que si $k_in < 255
                     if {$k_in < 255 } {
                        if {[info exist entree_in]} {
                           set entree-1_in $entree_in
                        }
                        set entree_in [gets $palette_in]
                        incr k_in
                     }
                  }

                  if { ! [ info exist entree-1_in ] } {
                     set entree-1_in $entree_in
                  }
                  puts $palette_ex [list [expr ($valeur-int($valeur))*[lindex ${entree-1_in} 0]+(1-$valeur+int($valeur))*[lindex $entree_in 0]] [expr ($valeur-int($valeur))*[lindex ${entree-1_in} 1]+(1-$valeur+int($valeur))*[lindex $entree_in 1]] [expr ($valeur-int($valeur))*[lindex ${entree-1_in} 2]+(1-$valeur+int($valeur))*[lindex $entree_in 2]]]
               }

               close $palette_in
               close $palette_ex

               visu$visuNo paldir [file dirname $tmp(fichier_palette)]
               visu$visuNo pal [file tail $tmp(fichier_palette)]
            }
         }    
         4 {
            #--- Fonction de transfert arctangente / sigmoïde
            if {$conf(fonction_transfert,param4)==0} {
               #--- On est ramené au cas linéaire
               visu$visuNo pal $fichier_palette
            } else {
               set f [open $tmp(fichier_palette) w]
               set conf(fonction_transfert,param4) [expr abs($conf(fonction_transfert,param4))]

               #--- On détermine quelle partie de la courbe exp on utilise (abcisses [a b])
               #--- (celle coupant la droite d'équation y=x/(1+paramètre_arc))
               set dicho [expr $conf(fonction_transfert,param4)+1]
               set a [expr -$conf(fonction_transfert,param4)-1]
               while {$dicho>0.001} {
                  if { [expr atan($a)]>[expr 1.*$a/(1+$conf(fonction_transfert,param4))] } {
                     set a [expr $a+$dicho/2]
                  } else {
                     set a [expr $a-$dicho/2]
                  }
                  set dicho [expr $dicho/2]
               }

               set dicho [expr $conf(fonction_transfert,param4)+1]
               set b [expr $conf(fonction_transfert,param4)+1]
               while {$dicho>0.001} {
                  if { [expr atan($b)]>[expr 1.*$b+1+$conf(fonction_transfert,param4)] } {
                     set b [expr $b-$dicho/2]
                  } else {
                     set b [expr $b+$dicho/2]
                  }
                  set dicho [expr $dicho/2]
               }

               set Ya [expr atan($a)]
               set Yb [expr atan($b)]
               set deltax [expr $b-$a]
               set deltaY [expr $Yb-$Ya]

               #--- Ouverture des fichiers de palette
               set palette_in [open ${fichier_palette_in}.pal r]
               set palette_ex [open ${tmp(fichier_palette)}.pal w]

               set k_in 0
               #--- Ecriture du fichier de palette sortant
               for {set k_ex 0} {$k_ex<256} {incr k_ex} {
                  set valeur [expr abs((atan($a+1.*$k_ex*$deltax/255)-$Ya)*255/$deltaY)]

                  #--- Si $valeur n'est pas entier, il faut interpoler entre les entiers juste au
                  #--- dessous et juste au dessus de $valeur
                  #--- Même s'il est entier, ça marche aussi
                  while {$k_in<$valeur} {
                     incr k_in
                     set entree-1_in [gets $palette_in]
                  }

                  if { [expr $k_in -1] < $valeur } {
                     #--- Test de sécurité : on ne continue que si $k_in < 255
                     if { $k_in < 255 } {
                        if { [info exist entree_in] } {
                           set entree-1_in $entree_in
                        }
                        set entree_in [gets $palette_in]
                        incr k_in
                  }
               }

               if { ! [info exist entree-1_in] } {
                  set entree-1_in $entree_in
               }
               puts $palette_ex [list [expr ($valeur-int($valeur))*[lindex ${entree-1_in} 0]+(1-$valeur+int($valeur))*[lindex $entree_in 0]] [expr ($valeur-int($valeur))*[lindex ${entree-1_in} 1]+(1-$valeur+int($valeur))*[lindex $entree_in 1]] [expr ($valeur-int($valeur))*[lindex ${entree-1_in} 2]+(1-$valeur+int($valeur))*[lindex $entree_in 2]]]
            }

            close $palette_in
            close $palette_ex

            visu$visuNo paldir [file dirname $tmp(fichier_palette)]
            visu$visuNo pal [file tail $tmp(fichier_palette)]
            }
         }
      }
   }

   #
   # ::audace::newScript
   # Edition d'un script ou d'un fichier : Demande en premier le fichier et ouvre l'editeur choisi dans les reglages
   #
   proc newScript { } {
      global conf
      global audace
      global caption

      menustate disabled
      set result [::newScript::run ""]
      if { [lindex $result 0] == 1 } {
         set filename [lindex $result 1]
         if { [string compare $filename ""] } {
            #--- Creation du fichier
            set fid [open $filename w]
            close $fid
            #--- Ouverture de ce fichier
            set a_effectuer "exec \"$conf(editscript)\" \"$filename\" &"
            if {[catch $a_effectuer msg]} {
               $audace(console)::affiche_erreur "$caption(impossible,ouvrir,fichier) $msg\n"
            }
         }
      }
      menustate normal
   }

   #
   # ::audace::editScript
   # Edition d'un script ou d'un fichier : Demande en premier le fichier et ouvre l'editeur choisi dans les reglages
   # Il faut avoir choisi un editeur (notepad sous windows, sous linux : kwrite, xemacs, nedit, dtpad, etc.)
   #
   proc editScript { } {
      global audace
      global conf
      global confgene
      global caption

      #--- Fenetre parent
      set fenetre "$audace(base)"
      #--- Ouvre la fenetre de choix des scripts
      set filename [ ::tkutil::box_load $fenetre $audace(rep_scripts) $audace(bufNo) "2" ]
      #---
      set confgene(EditScript,error_script) "1"
      set confgene(EditScript,error_pdf)    "1"
      set confgene(EditScript,error_htm)    "1"
      set confgene(EditScript,error_viewer) "1"
      if [string compare $filename ""] {
         set a_effectuer "exec \"$conf(editscript)\" \"$filename\" &"
         if [catch $a_effectuer input] {
           # $audace(console)::affiche_erreur "$caption(audace,console,rate)\n"
            set confgene(EditScript,error_script) "0"
            ::confEditScript::run "$audace(base).confEditScript"
            set a_effectuer "exec \"$conf(editscript)\" \"$filename\" &"
            $audace(console)::affiche_saut "\n"
            $audace(console)::disp $filename
            $audace(console)::affiche_saut "\n"
            if [catch $a_effectuer input] {
               set audace(current_edit) $input
            }
         } else {
            $audace(console)::affiche_saut "\n"
              $audace(console)::disp $filename
            $audace(console)::affiche_saut "\n"
            set audace(current_edit) $input
           # $audace(console)::affiche_erreur "$caption(audace,console,gagne)\n"
         }
      } else {
        # $audace(console)::affiche_erreur "$caption(audace,console,annule)\n"
      }
   }

   #
   # ::audace::runScript
   # Execute un script en demandant le nom du fichier par un explorateur
   #
   proc runScript { } {
      global audace
      global caption
      global errorInfo

      #--- Fenetre parent
      set fenetre "$audace(base)"
      #--- Ouvre la fenetre de choix des scripts
      set filename [ ::tkutil::box_load $fenetre $audace(rep_scripts) $audace(bufNo) "3" ]
      #---
      if [string compare $filename ""] {
         $audace(console)::affiche_saut "\n"
         $audace(console)::affiche_erreur "\n"
         $audace(console)::affiche_erreur "$caption(prog,erreur,script) $filename\n"
         $audace(console)::affiche_erreur "\n"
         if {[catch {uplevel source \"$filename\"} m]} {
            $audace(console)::affiche_erreur "$caption(audace,boite,erreur) $caption(caractere,2points) $m\n";
            set m2 $errorInfo
            $audace(console)::affiche_erreur "$m2\n";
         } else {
            $audace(console)::affiche_erreur "\n"
         }
         $audace(console)::affiche_erreur "$caption(termine,erreur,script)\n"
         $audace(console)::affiche_erreur "\n"
      }
   }

   #
   # ::audace::editNotice_pdf
   # Edition d'une notice au format .pdf
   # Il faut avoir Acrobate Reader sur le micro
   #
   proc editNotice_pdf { } {
      global audace
      global caption

      #--- Fenetre parent
      set fenetre "$audace(base)"
      #--- Repertoire d'initialisation
      set rep_init $audace(rep_doc_pdf)
      #--- Ouvre la fenetre de choix des notices
      set filename [ ::tkutil::box_load $fenetre $rep_init $audace(bufNo) "4" ]
      #---
      ::audace::Lance_Notice_pdf $filename
   }

   #
   # ::audace::Lance_Notice_pdf
   # Lance l'editeur de documents pdf
   #
   proc Lance_Notice_pdf { filename } {
      global audace
      global conf
      global confgene
      global caption

      menustate disabled
      set confgene(EditScript,error_script) "1"
      set confgene(EditScript,error_pdf)    "1"
      set confgene(EditScript,error_htm)    "1"
      set confgene(EditScript,error_viewer) "1"
      if [string compare $filename ""] {
         set a_effectuer "exec \"$conf(editnotice_pdf)\" \"$filename\" &"
         if [catch $a_effectuer input] {
           # $audace(console)::affiche_erreur "$caption(audace,console,rate)\n"
            set confgene(EditScript,error_pdf) "0"
            ::confEditScript::run "$audace(base).confEditScript"
            set a_effectuer "exec \"$conf(editnotice_pdf)\" \"$filename\" &"
            if [catch $a_effectuer input] {
               set audace(current_edit) $input
            }
         } else {
            set audace(current_edit) $input
           # $audace(console)::affiche_erreur "$caption(audace,console,gagne)\n"
         }
      } else {
        # $audace(console)::affiche_erreur "$caption(audace,console,annule)\n"
      }
      menustate normal
   }

   #
   # ::audace::editSiteWebAudeLA
   # Connexion au site web d'AudeLA
   # Il faut avoir un navigateur web sur le micro
   #
   proc editSiteWebAudeLA { } {
      global audace
      global caption

      #--- Fenetre parent
      set fenetre "$audace(base)"
      #--- Repertoire d'initialisation
      set rep_init [ file join $audace(rep_doc_html) web_site ]
      #--- Ouvre la fenetre de choix des pages html
      set filename [ ::tkutil::box_load_html $fenetre $rep_init $audace(bufNo) "1" ]
      #---
      if { $filename != "file:" } {      
         ::audace::Lance_Site_htm "$filename"
      }
   }

   #
   # ::audace::listfuncs
   # Edition des fonctions du site Web local
   # Il faut avoir un navigateur web sur le micro et les fichiers html dans le repertoire doc_html
   #
   proc listfuncs { } {
      global audace

      set filename "[ file join file:///$audace(rep_doc_html) french 02programmation interfa5c.htm ]"
      ::audace::Lance_Site_htm "$filename"
   }

   #
   # ::audace::Lance_Site_htm
   # Lance le navigation web
   #
   proc Lance_Site_htm { filename } {
      global audace
      global conf
      global confgene
      global caption

      menustate disabled
      set confgene(EditScript,error_script) "1"
      set confgene(EditScript,error_pdf)    "1"
      set confgene(EditScript,error_htm)    "1"
      set confgene(EditScript,error_viewer) "1"
      regsub -all " " "$filename" "\%20" filename
      if [string compare $filename ""] {
         set a_effectuer "exec \"$conf(editsite_htm)\" \"$filename\" &"
         if [catch $a_effectuer input] {
           # $audace(console)::affiche_erreur "$caption(audace,console,rate)\n"
            set confgene(EditScript,error_htm) "0"
            ::confEditScript::run "$audace(base).confEditScript"
            set a_effectuer "exec \"$conf(editsite_htm)\" \"$filename\" &"
            if [catch $a_effectuer input] {
               set audace(current_edit) $input
            }
         } else {
            set audace(current_edit) $input
           # $audace(console)::affiche_erreur "$caption(audace,console,gagne)\n"
         }
      } else {
        # $audace(console)::affiche_erreur "$caption(audace,console,annule)\n"
      }
      menustate normal
   }

   #
   # ::audace::Lance_viewer_images_apn
   # Lance le viewer pour visualiser les images d'un APN
   #
   proc Lance_viewer_images_apn { filename } {
      global audace
      global conf
      global confgene
      global caption

      menustate disabled
      set confgene(EditScript,error_script) "1"
      set confgene(EditScript,error_pdf)    "1"
      set confgene(EditScript,error_htm)    "1"
      set confgene(EditScript,error_viewer) "1"
      regsub -all " " "$filename" "\%20" filename
      if [string compare $filename ""] {
         set a_effectuer "exec \"$conf(edit_viewer)\" \"$filename\" &"
         if [catch $a_effectuer input] {
           # $audace(console)::affiche_erreur "$caption(audace,console,rate)\n"
            set confgene(EditScript,error_viewer) "0"
            ::confEditScript::run "$audace(base).confEditScript"
            set a_effectuer "exec \"$conf(edit_viewer)\" \"$filename\" &"
            if [catch $a_effectuer input] {
               set audace(current_edit) $input
            }
         } else {
            set audace(current_edit) $input
           # $audace(console)::affiche_erreur "$caption(audace,console,gagne)\n"
         }
      } else {
        # $audace(console)::affiche_erreur "$caption(audace,console,annule)\n"
      }
      menustate normal
   }

   #
   # ::audace::Histo
   # Visualisation de l'histogramme de l'image
   #
   proc Histo { visuNo } {
      global audace
      global caption

      #---
      set bufNo [ visu$visuNo buf ]

      if { [ buf$bufNo imageready ] == "1" } {
         buf$bufNo imaseries "CUTS lofrac=0.01 hifrac=0.99 hicut=SH locut=SB keytype=FLOAT"
         set mini [ lindex [ buf$bufNo getkwd SB ] 1 ]
         set maxi [ lindex [ buf$bufNo getkwd SH ] 1 ]
         set r [ buf$bufNo histo 50 $mini $maxi ]
         ::plotxy::figure 1
         ::plotxy::plot [ lindex $r 1 ]  [ lindex $r 0 ]
         ::plotxy::xlabel "$caption(audace,histo,adu)"
         ::plotxy::ylabel "$caption(audace,histo,nbpix)"
         ::plotxy::title "$caption(audace,histo,titre) (visu$visuNo)"
      }
   }

   #
   # ::audace::enregistrerConfiguration
   # Demande la confirmation pour enregistrer la configuration
   #
   proc enregistrerConfiguration { visuNo } {
      global audace caption conf

      #---
      menustate disabled
      #--- Positions des fenetres
      set conf(audace,visu$visuNo,wmgeometry) "[wm geometry $audace(base)]"
      set conf(console,wmgeometry) "[wm geometry $audace(Console)]"
      if {[winfo exists $audace(base).tjrsvisible]==1} {
         set conf(ouranos,wmgeometry) "[wm geometry $audace(base).tjrsvisible]"
      }

      #---
      if { $::tcl_platform(os) == "Linux" } {
         set filename [ file join ~ .audela config.ini ]
         set filebak [ file join ~ .audela config.bak ]
      } else {
         set filename [ file join $audace(rep_audela) audace config.ini ]
         set filebak [ file join $audace(rep_audela) audace config.bak ]
      }
      set filename2 $filename
      catch {
         file copy -force $filename $filebak
      }
      array set file_conf [ini_getArrayFromFile $filename]

      if {[ini_fileNeedWritten file_conf conf]} {
         set choice [ tk_messageBox -message "$caption(sur,enregistrer,config7)" \
            -title "$caption(sur,enregistrer,config3)" -icon question -type yesno ]
         if { $choice == "yes" } {
            #--- Enregistrer la configuration
            array set theconf [ini_merge file_conf conf]
            ini_writeIniFile $filename2 theconf
         } elseif {$choice=="no"} {
            #--- Pas d'enregistrement
            $audace(console)::affiche_resultat "$caption(sur,enregistrer,config5)\n\n"
         }
      } else {
         #--- Pas d'enregistrement
         $audace(console)::affiche_resultat "$caption(sur,enregistrer,config5)\n\n"
      }
      #---
      menustate normal
      #---
      focus $audace(base)
   }

   #
   # ::audace::quitter
   # Demande la confirmation pour quitter
   #
   proc quitter { } {
      global conf
      global audace
      global caption
      global tmp

      #--- Si le tutorial EthernAude est affiche, je le ferme en premier avant de quitter
      if { [ winfo exist .main ] } {
         if { [ winfo exist .second ] } {
            destroy .second
         }
         destroy .main
      }
      #---
      menustate disabled
      wm protocol $audace(base) WM_DELETE_WINDOW ::audace::rien
      wm protocol $audace(Console) WM_DELETE_WINDOW ::audace::rien
      #--- Positions des fenetres
      set conf(audace,visu1,wmgeometry) "[wm geometry $audace(base)]"
      set conf(console,wmgeometry) "[wm geometry $audace(Console)]"
      if {[winfo exists $audace(base).tjrsvisible]==1} {
         set conf(ouranos,wmgeometry) "[wm geometry $audace(base).tjrsvisible]"
      }
      #--- Arrete le plugin liaison
      ::confLink::stopDriver
      #--- Arrete les plugins camera
      ::confCam::stopDriver
      #--- Arrete le plugin monture
      ### ::confTel::stopDriver
      #--- Arrete le plugin equipement
      ::confEqt::stopDriver
      #--- Arrete le plugin raquette
      ::confPad::stopDriver
      #--- Arrete le plugin carte
      ::confCat::stopDriver
      #--- Arrete les visu sauf la visu1
      foreach visuNo [visu::list] {
         if { $visuNo != "1"  } {
            ::confVisu::close $visuNo
         }
      }

      if { $::tcl_platform(os) == "Linux" } {
         set filename [ file join ~ .audela config.ini ]
         set filebak [ file join ~ .audela config.bak ]
      } else {
         set filename [ file join $audace(rep_audela) audace config.ini ]
         set filebak [ file join $audace(rep_audela) audace config.bak ]
      }
      set filename2 $filename
      catch {
         file copy -force $filename $filebak
      }
      array set file_conf [ini_getArrayFromFile $filename]

      #--- Suppression des fichiers temporaires 'fonction_transfert.pal' et 'fonction_transfert_x.pal'
      if { [ lindex [ decomp $tmp(fichier_palette).pal ] 2 ] != "" } {
         #--- Cas des fichiers temporaires 'fonction_transfert_x.pal'
         set index_final [ lindex [ decomp $tmp(fichier_palette).pal ] 2 ]
         for { set index "1" } { $index <= $index_final } { incr index } {
            file delete [ file join [ lindex [ decomp $tmp(fichier_palette).pal ] 0 ] [ lindex [ decomp $tmp(fichier_palette).pal ] 1 ]$index[ lindex [ decomp $tmp(fichier_palette).pal ] 3 ] ]
            file delete [ file join [ lindex [ decomp $tmp(fichier_palette).pal ] 0 ] [ string trimright [ lindex [ decomp $tmp(fichier_palette).pal ] 1 ] "_" ][ lindex [ decomp $tmp(fichier_palette).pal ] 3 ] ]
         }
      } else {
         #--- Cas du fichier temporaire 'fonction_transfert.pal'
         file delete [ file join [ lindex [ decomp $tmp(fichier_palette).pal ] 0 ] [ lindex [ decomp $tmp(fichier_palette).pal ] 1 ][ lindex [ decomp $tmp(fichier_palette).pal ] 2 ][ lindex [ decomp $tmp(fichier_palette).pal ] 3 ] ]
      }

      if {[ini_fileNeedWritten file_conf conf]} {
         set old_focus [focus]
         set choice [tk_messageBox -message "$caption(sur,enregistrer,config1)\n$caption(sur,enregistrer,config2)" \
            -title "$caption(sur,enregistrer,config3)" -icon question -type yesnocancel]
         if {$choice=="yes"} {
            #--- Enregistrer la configuration
            array set theconf [ini_merge file_conf conf]
            ini_writeIniFile $filename2 theconf
            ::confVisu::stopTool $audace(visuNo)
            ::audace::shutdown_devices
            exit
         } elseif {$choice=="no"} {
            #--- Pas d'enregistrement
            wm protocol $audace(base) WM_DELETE_WINDOW " ::audace::quitter "
            wm protocol $audace(Console) WM_DELETE_WINDOW " ::audace::quitter "
            ::confVisu::stopTool $audace(visuNo)
            ::audace::shutdown_devices
            exit
         } else {
            wm protocol $audace(base) WM_DELETE_WINDOW " ::audace::quitter "
            wm protocol $audace(Console) WM_DELETE_WINDOW " ::audace::quitter "
         }
         focus $old_focus
      } else {
         set choice [tk_messageBox -type yesno -icon warning -title "$caption(attention,enregistrer,config)" \
            -message "$caption(audace,prog,quitter)"]
         if {$choice=="yes"} {
            ::confVisu::stopTool $audace(visuNo)
            ::audace::shutdown_devices
            exit
         }
         $audace(console)::affiche_resultat "$caption(sur,enregistrer,config5)\n\n"
         wm protocol $audace(base) WM_DELETE_WINDOW " ::audace::quitter "
         wm protocol $audace(Console) WM_DELETE_WINDOW " ::audace::quitter "
      }
      #---
      menustate normal
      focus $audace(base)
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
      global audace

      ::confVisu::cursor $curs
   }

   proc bg { coul } {
      global audace

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
   # ::audace::getBox
   # Retourne la boite de selection a la souris
   #
   proc getBox { } {
      return [ ::confVisu::getBox 1 ]
   }

   proc header { visuNo } {
      global audace caption color

      #---
      set base [ ::confVisu::getBase $visuNo ]
      #---
      set i 0
      if [winfo exists $base.header] {
         destroy $base.header
      }
      toplevel $base.header
      wm transient $base.header $base
      if { [ buf[ ::confVisu::getBufNo $visuNo ] imageready ] == "1" } {
         wm minsize $base.header 632 303
      }
      wm resizable $base.header 0 1
      wm title $base.header "$caption(audace,menu,entete) (visu$visuNo)"
      set posx_header [ lindex [ split [ wm geometry $base ] "+" ] 1 ]
      set posy_header [ lindex [ split [ wm geometry $base ] "+" ] 2 ]
      wm geometry $base.header +[ expr $posx_header + 3 ]+[ expr $posy_header + 75 ]

      if { [ buf[ ::confVisu::getBufNo $visuNo ] imageready ] == "1" } {
         Scrolled_Text $base.header.slb -width 87 -font $audace(font,en_tete_1) -height 20
         pack $base.header.slb -fill y -expand true
         $base.header.slb.list tag configure keyw -foreground $color(blue)   -font $audace(font,en_tete_2)
         $base.header.slb.list tag configure egal -foreground $color(black)  -font $audace(font,en_tete_2)
         $base.header.slb.list tag configure valu -foreground $color(red)    -font $audace(font,en_tete_2)
         $base.header.slb.list tag configure comm -foreground $color(green1) -font $audace(font,en_tete_2)
         $base.header.slb.list tag configure unit -foreground $color(orange) -font $audace(font,en_tete_2)
         foreach kwd [ lsort -dictionary [ buf[ ::confVisu::getBufNo $visuNo ] getkwds ] ] {
            set liste [ buf[ ::confVisu::getBufNo $visuNo ] getkwd $kwd ]
            set koff 0
            if {[llength $liste]>5} {
               #--- Detourne un bug eventuel des mots longs (ne devrait jamais arriver !)
               set koff [expr [llength $liste]-5]
            }
            set keyword "$kwd"
            if {[string length $keyword]<=8} {
               set keyword "[format "%8s" $keyword]"
            }
            $base.header.slb.list insert end "$keyword " keyw
            $base.header.slb.list insert end "= " egal
            $base.header.slb.list insert end "[lindex $liste [expr $koff+1]] " valu
            $base.header.slb.list insert end "[lindex $liste [expr $koff+3]] " comm
            $base.header.slb.list insert end "[lindex $liste [expr $koff+4]]\n" unit
         }
      } else {
         label $base.header.l -text "$caption(audace,header,noimage)"
         pack $base.header.l -padx 20 -pady 10
      }
      update

      #--- Focus
      focus $base.header

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $base.header <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $base.header
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
      global audace

      upvar $f_a file_array
      upvar $m_a mem_array

      set file_names [array names file_array]
      set mem_names [array names mem_array]
      foreach a $mem_names {
         if {[lsearch -exact $file_names $a]==-1} {
           # $audace(console)::affiche_erreur "$a not in file\n"
            return 1
         } else {
            if {[string compare [array get file_array $a] [array get mem_array $a]]!=0} {
              # $audace(console)::affiche_erreur "$a different between file and mem : \"[array get file_array $a]\" \"[array get mem_array $a]\"\n"
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
      global audace

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
      catch {
         set fid [open $filename w]
         puts $fid "global conf"
         #foreach {a b} [array get file_array] {
         #   puts $fid "set conf($a) \"$b\""
         #}
         foreach a [lsort -dictionary [array names file_array]] {
            puts $fid "set conf($a) \"[lindex [array get file_array $a] 1]\""
         }
         close $fid
      }
   }

   proc writeIniFile { } {
      global audace
      global conf
      global caption

      if { $::tcl_platform(os) == "Linux" } {
         set filename [ file join ~ .audela config.ini ]
         set filebak [ file join ~ .audela config.bak ]
      } else {
         set filename [ file join $audace(rep_audela) audace config.ini ]
         set filebak [ file join $audace(rep_audela) audace config.bak ]
      }
      set filename2 $filename
      catch {
         file copy -force $filename $filebak
      }
      array set file_conf [ ini_getArrayFromFile $filename ]
      if { [ ini_fileNeedWritten file_conf conf ] } {
         set old_focus [focus]
         set choice [ tk_messageBox -message "$caption(sur,enregistrer,config1)" \
            -title "$caption(sur,enregistrer,config3)" -icon question -type yesno ]
         if {$choice=="yes"} {
            array set theconf [ini_merge file_conf conf]
            ini_writeIniFile $filename2 theconf
            $audace(console)::affiche_resultat "$caption(sur,enregistrer,config4)\n"
         } else {
            $audace(console)::affiche_resultat "caption(sur,enregistrer,config6)\n"
         }
         focus $old_focus
      } else {
         $audace(console)::affiche_resultat "caption(sur,enregistrer,config5)\n\n"
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
      variable private
      global audace
      
      ::confVisu::visuDynamix $audace(visuNo) $max $min 
   }      

}
############# fin du namespace audace #############################################

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
   global audace

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
   if {$offset != 0.0 || $size != 1.0 } {
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
            if {[winfo toplevel $w] == $w || $cursor != ""} {
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
#  getVisuNo
#     retourne le numero de visu associe un element tk 
#
#    le numero de visu se trouve dans l'attribut "class" 
#    de la toplevel .audace ou .visu
#  exemple :
#    [getVisuNo  .audace.menubar.menu.windowseuil] 
#      => retourne "1"  
#------------------------------------------------------------
proc getVisuNo { tkpath } {
   return [winfo class [winfo toplevel $tkpath ]]
}

#------------------------------------------------------------
#  ramdebugger
#     active le debugger "ramdebugger"
#
#     le Ramdebugger doit être installé dans le répertoire
#      audace/lib/RamDebugger
#------------------------------------------------------------
proc ramdebugger { } {
   global audace 
   
   if { [info exists audace(rep_install) ] } {
      lappend ::auto_path "$audace(rep_install)/lib/RamDebugger/addons"
   } else {
      lappend ::auto_path "[pwd]/../../lib/RamDebugger/addons"
   }
   package require commR
   comm::register audela 1
   comm::register audela 1
   comm::register audela 1
}

#
#--- Execute en premier au demarrage
#

#--- On cache la fenetre mere
wm focusmodel . passive
wm withdraw .

::audace::run
focus -force $audace(Console)
$audace(console)::GiveFocus

