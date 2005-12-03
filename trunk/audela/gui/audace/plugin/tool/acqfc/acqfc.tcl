#
# Fichier : acqfc.tcl
# Description : Outil d'acquisition
# Auteur : Francois Cochard
# Date de mise a jour : 19 novembre 2005
#

package provide acqfc 2.1

#==============================================================
#   Declaration du namespace AcqFC
#==============================================================

namespace eval ::AcqFC {
   variable This
   variable fichier_log
   variable parametres
   variable numero_version
   global audace

   source [ file join $audace(rep_plugin) tool acqfc acqfc.cap ]

   #--- Numero de la version du logiciel
   set numero_version "2.3"

#***** Procedure DemarrageAcqFC ********************************
   proc DemarrageAcqFC { } {
      variable fichier_log
      variable log_id
      variable numero_version
      global panneau audace caption

      #--- Gestion du fichier de log
      #--- Creation du nom de fichier log
      set nom_generique "acqfc"
      #--- Heure a partir de laquelle on passe sur un nouveau fichier de log...
      set heure_nouveau_fichier "12"
      set heure_courante [lindex [split $audace(tu,format,hmsint) h] 0]
      if { $heure_courante < $heure_nouveau_fichier } {
         #--- Si avant l'heure de changement... Je prends la date de la veille
         set formatdate [clock format [expr {[clock seconds] - 86400}] -format "%Y-%m-%d"]
      } else {
         #--- Sinon, je prends la date du jour
         set formatdate [clock format [clock seconds] -format "%Y-%m-%d"]
      }
      set file_log ""
      set fichier_log [ file join $audace(rep_images) [ append $file_log $nom_generique $formatdate ".log" ] ]

      #--- Ouverture
      if { [ catch { open $fichier_log a } log_id ] } {
         Message console $caption(acqfc,pbouvfichcons)
         tk_messageBox -title $caption(acqfc,pb) -type ok \
            -message $caption(acqfc,pbouvfich)
         #--- Note importante : Je detecte si j'ai un pb a l'ouverture du fichier, mais je ne sais pas traiter ce cas :
         #--- Il faudrait interdire l'ouverture du panneau, mais le processus  est deja lance a ce stade...
         #--- Tout ce que je fais, c'est inviter l'utilisateur a changer d'outil !
      } else {
         #--- En-tete du fichier
         Message log $caption(acqfc,ouvsess) $numero_version
         set date [clock format [clock seconds] -format "%A %d %B %Y"]
         set heure $audace(tu,format,hmsint)
         Message log $caption(acqfc,affheure) $date $heure
         #--- Definition du binding pour declencher l'acquisition (ou l'arret) par Echap.
         bind all <Key-Escape> { set panneau(AcqFC,go_stop) "stop" ; ::AcqFC::GoStop }
      }
   }
#***** Fin de la procedure DemarrageAcqFC **********************

#***** Procedure ArretAcqFC ************************************
   proc ArretAcqFC { } {
      global caption
      global audace
      variable log_id

      #--- Fermeture du fichier de log
      if { [ info exists log_id ] } {
         set heure $audace(tu,format,hmsint)
         #--- Je m'assure que le fichier se termine correctement, en particulier pour le cas ou il y
         #--- a eu un probleme a l'ouverture (c'est un peu une rustine...)
         if { [ catch { Message log $caption(acqfc,finsess) $heure } bug ] } {
            Message console $caption(acqfc,pbfermfichcons)
         } else {
            close $log_id
            unset log_id
         }
      }
      #--- Desactivation du binding pour declencher l'acquisition (ou l'arret) par Echap.
      bind all <Key-Escape> { }
   }
#***** Fin de la procedure ArretAcqFC **************************

#***** Procedure Init ******************************************
   proc Init { { in "" } } {
      createPanel $in.acqFC
   }
#***** Fin de la procedure Init ********************************

#***** Procedure createPanel ***********************************
   proc createPanel { this } {
      variable This
      variable parametres
      global audace panneau caption

      set This $this
      #--- Largeur de l'outil en fonction de l'OS
      if { $::tcl_platform(os) == "Linux" } {
         set panneau(AcqFC,largeur_outil) "130"
      } elseif { $::tcl_platform(os) == "Darwin" } {
         set panneau(AcqFC,largeur_outil) "130"
      } else {
         set panneau(AcqFC,largeur_outil) "101"
      }
      #---
      set panneau(menu_name,AcqFC) "$caption(acqfc,menu)"

      #--- Recuperation de la derniere configuration de prise de vue
      ::AcqFC::Chargement_Var

      #--- Chargement du package tkimgvideo (video pour les webcams sous Windows uniquement)
      if { $::tcl_platform(os) != "Linux" } {
         set result [ catch { package require tkimgvideo } msg ]
         if { $result == "1" } {
            console::affiche_erreur "$caption(acqfc,no_package)\n"
         }
      }

      #--- Initialisation de variables
      set panneau(AcqFC,simulation)            "0"
      set panneau(AcqFC,simulation_deja_faite) "0"
      set panneau(AcqFC,attente_pose)          "0"
      set panneau(AcqFC,pose_en_cours)         "0"

      #--- Entrer ici les valeurs de temps de pose a afficher dans le menu "pose"
      set panneau(AcqFC,temps_pose) {0 0.1 0.3 0.5 1 2 3 5 10 15 20 30 60 90 120 180 300 600}
      #--- Valeur par defaut du temps de pose : 1s
      if { ! [ info exists panneau(AcqFC,pose) ] } {
         set panneau(AcqFC,pose) "$parametres(acqFC,pose)"
      }

      #--- Valeur par defaut du binning
      if { ! [ info exists panneau(AcqFC,bin) ] } {
         set panneau(AcqFC,bin) "$parametres(acqFC,bin)"
      }

      #--- Entrer ici les valeurs pour l'obturateur a afficher dans le menu "obt"
      set panneau(AcqFC,obt,0) $caption(acqfc,ouv)
      set panneau(AcqFC,obt,1) $caption(acqfc,ferme)
      set panneau(AcqFC,obt,2) $caption(acqfc,auto)
      #--- Obturateur par defaut : Synchro
      if { ! [ info exists panneau(AcqFC,obt) ] } {
         set panneau(AcqFC,obt) "$parametres(acqFC,obt)"
      }

      #--- Liste des modes disponibles
      set panneau(AcqFC,list_mode) [ list $caption(acqfc,uneimage) $caption(acqfc,serie) $caption(acqfc,continu) \
         $caption(acqfc,continu_1) $caption(acqfc,continu_2) $caption(acqfc,video) $caption(acqfc,video_1) ]

      #--- Initialisation des modes
      set panneau(AcqFC,mode,1) "$This.mode.une"
      set panneau(AcqFC,mode,2) "$This.mode.serie"
      set panneau(AcqFC,mode,3) "$This.mode.continu"
      set panneau(AcqFC,mode,4) "$This.mode.serie_1"
      set panneau(AcqFC,mode,5) "$This.mode.continu_1"
      set panneau(AcqFC,mode,6) "$This.mode.video"
      set panneau(AcqFC,mode,7) "$This.mode.video_1"
      #--- Mode par defaut : Une image
      if { ! [ info exists panneau(AcqFC,mode) ] } {
         set panneau(AcqFC,mode) "$parametres(acqFC,mode)"
      }

      #--- Initialisation d'autres variables
      set panneau(AcqFC,go_stop)          "go"
      set panneau(AcqFC,index)            "1"
      set panneau(AcqFC,nom_image)        ""
      set panneau(AcqFC,indexer)          "0"
      set panneau(AcqFC,enregistrer)      "1"
      set panneau(AcqFC,nb_images)        "1"

      #--- Initialisation de variables pour l'acquisition video fenetree
      set panneau(AcqFC,fenetre)          "0"
      set panneau(AcqFC,largeur)          "-"
      set panneau(AcqFC,hauteur)          "-"
      set panneau(AcqFC,x1)               "-"
      set panneau(AcqFC,y1)               "-"
      set panneau(AcqFC,x2)               "-"
      set panneau(AcqFC,y2)               "-"

      #--- Initialisation de variables pour l'autoguidage
      set panneau(AcqFC,autoguidage)      "0"
      set panneau(AcqFC,x0)               "0"
      set panneau(AcqFC,y0)               "0"
      set panneau(AcqFC,x)                "0"
      set panneau(AcqFC,y)                "0"
      set panneau(AcqFC,ecart_x)          "-"
      set panneau(AcqFC,ecart_y)          "-"

      #--- Initialisation de variables pour la mesure de l'autoguidage
      set panneau(AcqFC,nom_fichier_ep) ""

      #--- Initialisation pour le mode video
      set panneau(AcqFC,showvideopreview) "0"
      set panneau(AcqFC,ratelist)  {5 10 15 20 25 30}
      set panneau(AcqFC,status)    "                              "
      #--- Frequence images par defaut : 5 images/sec.
      if { ! [ info exists panneau(AcqFC,rate) ] } {
         set panneau(AcqFC,rate) "$parametres(acqFC,rate)"
      }
      #--- Duree du film par defaut : 10s
      if { ! [ info exists panneau(AcqFC,lg_film) ] } {
         set panneau(AcqFC,lg_film) "$parametres(acqFC,lg_film)"
      }

      set panneau(AcqFC,dim_zone) $parametres(acqFC,dim_zone)

      if { ! [ info exists panneau(AcqFC,telecharge_mode) ] } {
         set panneau(AcqFC,telecharge_mode) "$parametres(acqFC,telecharge_mode)"
      }
      
      AcqFCBuildIF $This

      #--- Traitement du bouton Configuration pour la camera DigiCam
      if { ( $panneau(AcqFC,mode) == "1" ) || ( $panneau(AcqFC,mode) == "6" ) || ( $panneau(AcqFC,mode) == "7" ) } {
         $This.obt.digicam configure -state disabled
      } else {
         $This.obt.digicam configure -state normal
      }

      ::place $panneau(AcqFC,mode,$panneau(AcqFC,mode)) -x 0 -y 24 -width [ expr $panneau(AcqFC,largeur_outil) - 14 ] \
         -height 112 -anchor nw
   }
#***** Fin de la procedure createPanel *************************

#***** Procedure Adapt_Panneau_AcqFC ***************************
   proc Adapt_Panneau_AcqFC { { a "" } { b "" } { c "" } } {
      variable This
      global conf
      global confCam
      global audace
      global panneau

      #---
      if { $conf(camera) == "digicam" } {
         set panneau(AcqFC,telecharge_mode) "1"
      }
      #---
      if { $conf(camera) == "webcam" } {
         #--- C'est une WebCam
         if { $conf(webcam,longuepose) == "0" } {
            #--- Cas d'une WebCam standard
            uplevel #0 pack forget $This.pose.but
            uplevel #0 pack forget $This.pose.lab
            uplevel #0 pack forget $This.pose.entr
            uplevel #0 pack forget $This.bin.but
            uplevel #0 pack forget $This.bin.lab
            uplevel #0 pack $This.bin.conf -side left -fill x -expand true
            uplevel #0 pack forget $This.obt.but
            uplevel #0 pack forget $This.obt.lab
            uplevel #0 pack $This.obt.format -side left -fill x -expand true
            uplevel #0 pack forget $This.obt.digicam
         } else {
            #--- Cas d'une WebCam Longue Pose
            uplevel #0 pack $This.pose.but -side left
            uplevel #0 pack $This.pose.lab -side right -fill y
            uplevel #0 pack $This.pose.entr -side left -fill both -expand true
            uplevel #0 pack forget $This.bin.but
            uplevel #0 pack forget $This.bin.lab
            uplevel #0 pack $This.bin.conf -side left -fill x -expand true
            uplevel #0 pack forget $This.obt.but
            uplevel #0 pack forget $This.obt.lab
            uplevel #0 pack $This.obt.format -side left -fill x -expand true
            uplevel #0 pack forget $This.obt.digicam
         }
      } elseif { $conf(camera) == "digicam" } {
         #--- C'est une DigiCam (APN)
         uplevel #0 pack $This.pose.but -side left
         uplevel #0 pack $This.pose.lab -side right -fill y
         uplevel #0 pack $This.pose.entr -side left -fill both -expand true
         uplevel #0 pack $This.bin.but -side left
         uplevel #0 pack $This.bin.lab -side left -fill both -expand true
         uplevel #0 pack forget $This.bin.conf
         uplevel #0 pack forget $This.obt.but
         uplevel #0 pack forget $This.obt.lab
         uplevel #0 pack forget $This.obt.format
         uplevel #0 pack $This.obt.digicam -side left -fill x -expand true
      } else {
         #--- Ce n'est pas une WebCam, ni une DigiCam (APN)
         uplevel #0 pack $This.pose.but -side left
         uplevel #0 pack $This.pose.lab -side right -fill y
         uplevel #0 pack $This.pose.entr -side left -fill both -expand true
         uplevel #0 pack $This.bin.but -side left
         uplevel #0 pack $This.bin.lab -side left -fill both -expand true
         uplevel #0 pack forget $This.bin.conf
         uplevel #0 pack $This.obt.but -side left -fill x -expand true
         uplevel #0 pack $This.obt.lab -side left -fill both -expand true
         uplevel #0 pack forget $This.obt.format
         uplevel #0 pack forget $This.obt.digicam
      }
      if { $confCam(camera,connect) == "1" } {
         uplevel #0 $This.obt.but configure -state normal
      } else {
         uplevel #0 $This.obt.but configure -state disabled
      }
      if { ( $conf(camera) == "audine" ) || ( ( $conf(camera) == "hisis" ) && ( $conf(hisis,modele) != "11" ) ) || \
         ( $conf(camera) == "sbig" ) || ( $conf(camera) == "audinet" ) || ( $conf(camera) == "ethernaude" ) || \
         ( $conf(camera) == "andor" ) } {
         uplevel #0 pack forget $This.obt.lab
         if { ! [ info exists conf($conf(camera),foncobtu) ] } {
            set conf($conf(camera),foncobtu) "2"
         } else {
            if { $conf($conf(camera),foncobtu) == "0" } {
               set panneau(AcqFC,obt) "0"
            } elseif { $conf($conf(camera),foncobtu) == "1" } {
               set panneau(AcqFC,obt) "1"
            } elseif { $conf($conf(camera),foncobtu) == "2" } {
               set panneau(AcqFC,obt) "2"
            }
         }
         uplevel #0 $This.obt.lab configure -text $panneau(AcqFC,obt,$panneau(AcqFC,obt))
         uplevel #0 pack $This.obt.lab -side left -fill both -expand true
      } else {
         uplevel #0 pack forget $This.obt.but
         uplevel #0 pack forget $This.obt.lab
      }
      #---
      $This.bin.but.menu delete 0 20
      foreach valbin $audace(list_binning) {
         $This.bin.but.menu add radiobutton -label "$valbin" \
            -indicatoron "1" \
            -value "$valbin" \
            -variable panneau(AcqFC,bin) \
            -command { }
      }
      #---
      if { [ lsearch $audace(list_binning) $panneau(AcqFC,bin) ] == "-1" } {
         if { [ llength $audace(list_binning) ] >= "2" } {
            set panneau(AcqFC,bin) [ lindex $audace(list_binning) 1 ]
         } else {
            set panneau(AcqFC,bin) [ lindex $audace(list_binning) 0 ]
         }
      }
   }
#***** Fin de la procedure Adapt_Panneau_AcqFC *****************

#***** Procedure Chargement_Var ********************************
   proc Chargement_Var { } {
      variable parametres
      global audace

      #--- Ouverture du fichier de parametres
      set fichier [ file join $audace(rep_plugin) tool acqfc acqfc.ini ]
      if { [ file exists $fichier ] } {
         source $fichier
      }
      if { ! [ info exists parametres(acqFC,pose) ] }            { set parametres(acqFC,pose)            "5" }   ; #--- Temps de pose : 5s
      if { ! [ info exists parametres(acqFC,bin) ] }             { set parametres(acqFC,bin)             "2x2" } ; #--- Binning : 2x2
      if { ! [ info exists parametres(acqFC,obt) ] }             { set parametres(acqFC,obt)             "2" }   ; #--- Obturateur : Synchro
      if { ! [ info exists parametres(acqFC,mode) ] }            { set parametres(acqFC,mode)            "1" }   ; #--- Mode : Une image
      if { ! [ info exists parametres(acqFC,lg_film) ] }         { set parametres(acqFC,lg_film)         "10" }  ; #--- Duree de la video : 10s
      if { ! [ info exists parametres(acqFC,rate) ] }            { set parametres(acqFC,rate)            "5" }   ; #--- Images/sec. : 5
      if { ! [ info exists parametres(acqFC,dim_zone) ] }        { set parametres(acqFC,dim_zone)        "40" }  ; #--- Dim. zone autoguidage : 40 pixels
      if { ! [ info exists parametres(acqFC,telecharge_mode) ] } { set parametres(acqFC,telecharge_mode) "2" }   ; #--- Mode de telechargement
   }
#***** Fin de la procedure Chargement_Var **********************

#***** Procedure Enregistrement_Var ****************************
   proc Enregistrement_Var { } {
      variable parametres
      global audace
      global panneau

      #---
      set panneau(AcqFC,mode)               [ expr [ lsearch "$panneau(AcqFC,list_mode)" "$panneau(AcqFC,mode_en_cours)" ] + 1 ]
      #---
      set parametres(acqFC,pose)            $panneau(AcqFC,pose)
      set parametres(acqFC,bin)             $panneau(AcqFC,bin)
      set parametres(acqFC,obt)             $panneau(AcqFC,obt)
      set parametres(acqFC,mode)            $panneau(AcqFC,mode)
      set parametres(acqFC,lg_film)         $panneau(AcqFC,lg_film)
      set parametres(acqFC,rate)            $panneau(AcqFC,rate)
      set parametres(acqFC,telecharge_mode) $panneau(AcqFC,telecharge_mode)

      #--- Sauvegarde des parametres
      catch {
         set nom_fichier [ file join $audace(rep_plugin) tool acqfc acqfc.ini ]
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
#***** Fin de la procedure Enregistrement_Var ******************

#***** Procedure pack ******************************************
   proc pack { } {
      variable This
      global unpackFunction
      global conf
      global confCam
      global panneau

      #--- Creation des fenetres auxiliaires si necessaire
      if { $panneau(AcqFC,mode) == "4" } {
         ::AcqFC::Intervalle_continu_1
      } elseif { $panneau(AcqFC,mode) == "5" } {
         ::AcqFC::Intervalle_continu_2    
      } elseif { $panneau(AcqFC,mode) == "6" } {
         ::AcqFC::selectVideoMode   
      } elseif { $panneau(AcqFC,mode) == "7" } {
         ::AcqFC::selectVideoMode   
      }

      trace variable ::conf(webcam,longuepose) w ::AcqFC::Adapt_Panneau_AcqFC
      trace variable ::conf(camera) w ::AcqFC::Adapt_Panneau_AcqFC
      trace variable ::conf(audine,foncobtu) w ::AcqFC::Adapt_Panneau_AcqFC
      trace variable ::confCam(camera,connect) w ::AcqFC::Adapt_Panneau_AcqFC
      set panneau(AcqFC,session_ouverture) "1"
      set unpackFunction ::AcqFC::unpack
      set a_executer "pack $This -anchor center -expand 0 -fill y -side left"
      uplevel #0 $a_executer
      ::AcqFC::Adapt_Panneau_AcqFC
   }
#***** Fin de la procedure pack ********************************

#***** Procedure unpack ****************************************
   proc unpack { } {
      variable This
      global conf
      global audace
      global confCam
      global panneau

      #--- Sauvegarde de la configuration de prise de vue
      ::AcqFC::Enregistrement_Var

      #--- Destruction des fenetres auxiliaires et sauvegarde de leurs positions si elles existent
      ::AcqFC::recup_position

      if { [ ::cam::list ] != "" && $panneau(AcqFC,showvideopreview) == "1" } {
         stopVideoPreview
      }

      trace vdelete ::conf(webcam,longuepose) w ::AcqFC::Adapt_Panneau_AcqFC
      trace vdelete ::conf(camera) w ::AcqFC::Adapt_Panneau_AcqFC
      trace vdelete ::conf(audine,foncobtu) w ::AcqFC::Adapt_Panneau_AcqFC
      trace vdelete ::confCam(camera,connect) w ::AcqFC::Adapt_Panneau_AcqFC
      ArretAcqFC
      set a_executer "pack forget $This"
      uplevel #0 $a_executer
   }
#***** Fin de la procedure unpack ******************************

#***** Procedure de changement du mode d'acquisition ***********
   proc ChangeMode { } {
      variable This
      global panneau

      ::place forget $panneau(AcqFC,mode,$panneau(AcqFC,mode))
      
      if { $panneau(AcqFC,showvideopreview) == "1" } {
         catch { stopVideoPreview }
      }
      set panneau(AcqFC,mode) [ expr [ lsearch "$panneau(AcqFC,list_mode)" "$panneau(AcqFC,mode_en_cours)" ] + 1 ]
      if { $panneau(AcqFC,mode) == "1" } {
         ::AcqFC::recup_position
         ::AcqFC::recup_position_telecharge
         $This.obt.digicam configure -state normal
      } elseif { $panneau(AcqFC,mode) == "2" } {
         ::AcqFC::recup_position
         $This.obt.digicam configure -state normal
      } elseif { $panneau(AcqFC,mode) == "3" } {
         ::AcqFC::recup_position
         $This.obt.digicam configure -state normal
      } elseif { $panneau(AcqFC,mode) == "4" } {
         ::AcqFC::Intervalle_continu_1
         $This.obt.digicam configure -state normal
      } elseif { $panneau(AcqFC,mode) == "5" } {
         ::AcqFC::Intervalle_continu_2
         $This.obt.digicam configure -state normal
      } elseif { $panneau(AcqFC,mode) == "6" } {
         set panneau(AcqFC,fenetre)     "0"
         set panneau(AcqFC,autoguidage) "0"
         ::AcqFC::selectVideoMode
         ::AcqFC::recup_position_telecharge
         $This.obt.digicam configure -state disabled
      } elseif { $panneau(AcqFC,mode) == "7" } {
         set panneau(AcqFC,fenetre)     "0"
         ::AcqFC::selectVideoMode
         ::AcqFC::recup_position_telecharge
         $This.obt.digicam configure -state disabled
      }
      ::place $panneau(AcqFC,mode,$panneau(AcqFC,mode)) -x 0 -y 24 -width [ expr $panneau(AcqFC,largeur_outil) - 14 ] \
         -height 112 -anchor nw
   }
#***** Fin de la procedure de changement du mode d'acquisition *

#***** Procedure de changement de l'obturateur *****************
   proc ChangeObt { } {
      global panneau conf audace caption frmm
      variable This

      if { [ ::cam::list ] != "" } {
         if { ($conf(camera) == "audine") || ( ($conf(camera) == "hisis") && ( $conf(hisis,modele) != "11" ) ) || \
            ($conf(camera) == "sbig") || ($conf(camera) == "audinet") || ($conf(camera) == "ethernaude") || \
            ($conf(camera) == "andor") } {
            #--- conf(xxxxxx,foncobtu) est la variable utilisee par confCam. Cela permet que la modif de la
            #--- position de l'obturateur ici soit prise en compte par le menu de config de la camera.
            incr panneau(AcqFC,obt)
            if { $panneau(AcqFC,obt) == "3" } {
               set panneau(AcqFC,obt) "0"
            }
            $This.obt.lab config -text $panneau(AcqFC,obt,$panneau(AcqFC,obt))
            if { $conf(camera) == "audine" } {
               set conf(audine,foncobtu) $panneau(AcqFC,obt)
               catch { set frm $frmm(Camera1) }
            } elseif { ($conf(camera) == "hisis") && ( $conf(hisis,modele) != "11" ) } {
               set conf(hisis,foncobtu) $panneau(AcqFC,obt)
               catch { set frm $frmm(Camera2) }
            } elseif { $conf(camera) == "sbig" } {
               set conf(sbig,foncobtu) $panneau(AcqFC,obt)
               catch { set frm $frmm(Camera3) }
            } elseif { $conf(camera) == "audinet" } {
               set conf(audinet,foncobtu) $panneau(AcqFC,obt)
               catch { set frm $frmm(Camera8) }
            } elseif { $conf(camera) == "ethernaude" } {
               set conf(ethernaude,foncobtu) $panneau(AcqFC,obt)
               catch { set frm $frmm(Camera9) }
            } elseif { $conf(camera) == "andor" } {
               set conf(andor,foncobtu) $panneau(AcqFC,obt)
               catch { set frm $frmm(Camera13) }
            }
            switch -exact -- $panneau(AcqFC,obt) {
               0  {
                  catch { $frm.foncobtu configure -value $caption(acqfc,obtu_ouvert) }
                  cam$audace(camNo) shutter "opened"
               }
               1  {
                  catch { $frm.foncobtu configure -value $caption(acqfc,obtu_ferme) }
                  cam$audace(camNo) shutter "closed"
               }
               2  {
                  catch { $frm.foncobtu configure -value $caption(acqfc,obtu_synchro) }
                  cam$audace(camNo) shutter "synchro"
               }
            }
         } else {
            tk_messageBox -title $caption(acqfc,pb) -type ok \
               -message $caption(acqfc,onlycam+obt)
         }
      }
   }
#***** Fin de la procedure de changement de l'obturateur *******

#***** Procedure de test de validite d'un entier *****************
#--- Cette procedure (copiee de Methking) verifie que la chaine passee en argument decrit bien un entier.
#--- Elle retourne 1 si c'est la cas, et 0 si ce n'est pas un entier.
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
#***** Fin de la procedure de test de validite d'une entier *******

#***** Procedure de test de validite d'une chaine de caracteres *******
#--- Cette procedure verifie que la chaine passee en argument ne contient que des caracteres valides.
#--- Elle retourne 1 si c'est la cas, et 0 si ce n'est pas valable.
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
#***** Fin de la procedure de test de validite d'une chaine de caracteres *******

#***** Procedure de test de validite d'un nombre reel *****************
#--- Cette procedure (inspiree de Methking) verifie que la chaine passee en argument decrit bien un reel.
#--- Elle retourne 1 si c'est la cas, et 0 si ce n'est pas un reel.
   proc TestReel { valeur } {
      set test 1
      for { set i 0 } { $i < [string length $valeur] } { incr i } {
         set a [string index $valeur $i]
         if { ![string match {[0-9.]} $a] } {
            set test 0
         }
      }
      return $test
   }
#***** Fin de la procedure de test de validite d'un nombre reel *******

#***** Procedure Go/Stop (appui sur le bouton Go/Stop) *********
   proc GoStop { } {
      global panneau audace caption conf
      variable This

      #--- Ouverture du fichier historique
      if { $panneau(AcqFC,session_ouverture) == "1" } {
          DemarrageAcqFC
          set panneau(AcqFC,session_ouverture) "0"
      }

      #--- Enregistrement de l'extension des fichiers
      set ext [buf$audace(bufNo) extension]

      switch $panneau(AcqFC,go_stop) {
         go {
            #--- Desactive le bouton Go, pour eviter un double appui
            $This.go_stop.but configure -state disabled

            #------ Tests generaux d'integrite de la requete -------------------------

            set integre oui
            #--- Teste si une camera est bien selectionnee
            if { [ ::cam::list ] == "" } {
               ::audace::menustate disabled
               set choix [ tk_messageBox -title $caption(acqfc,pb) -type ok \
                  -message $caption(acqfc,selcam) ]
               set integre non
               if { $choix == "ok" } {
                  #--- Ouverture de la fenetre de selection des cameras
                  ::confCam::run 
                  tkwait window $audace(base).confCam
               }
               ::audace::menustate normal
            }
            #--- Le temps de pose existe-t-il ?
            if { $panneau(AcqFC,pose) == "" } {
               tk_messageBox -title $caption(acqfc,pb) -type ok \
                  -message $caption(acqfc,saistps)
               set integre non
            }
            #--- Le champ "temps de pose" est-il bien un reel positif ?
            if { [ TestReel $panneau(AcqFC,pose) ] == "0" } {
               tk_messageBox -title $caption(acqfc,pb) -type ok \
                  -message $caption(acqfc,Tpsinv)
               set integre non
            }

            #--- Tests d'integrite specifiques a chaque mode d'acquisition
            if { $integre == "oui" } {
               #--- Branchement selon le mode de prise de vue
               switch $panneau(AcqFC,mode) {
                  1  {
                     #--- Mode une image
                     if { $panneau(AcqFC,indexer) == "1" } {
                        #--- Verifie que l'index existe
                        if { $panneau(AcqFC,index) == "" } {
                           tk_messageBox -title $caption(acqfc,pb) -type ok \
                               -message $caption(acqfc,saisind)
                           set integre non
                        }
                        #--- Verifie que l'index est valide (entier positif)
                        if { [ TestEntier $panneau(AcqFC,index) ] == "0" } {
                           tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,indinv)
                           set integre non
                        }
                     }
                     #--- Pas de decalage du telescope
                     set panneau(DlgShift,buttonShift) "0"
                  }
                  2  {
                     #--- Mode serie
                     #--- Verifier qu'il y a bien un nom de fichier
                     if { $panneau(AcqFC,nom_image) == "" } {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,donnomfich)
                        set integre non
                     }
                     #--- Verifier que le nom de fichier n'a pas d'espace
                     if { [ llength $panneau(AcqFC,nom_image) ] > "1" } {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,nomblanc)
                        set integre non
                     }
                     #--- Verifie que le nom de fichier ne contient pas de caracteres interdits
                     if { [ TestChaine $panneau(AcqFC,nom_image) ] == "0" } {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,mauvcar)
                        set integre non
                     }
                     #--- Verifie que le nombre de poses est valide (nombre entier)
                     if { [ TestEntier $panneau(AcqFC,nb_images) ] == "0" } {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,nbinv)
                        set integre non
                     }
                     #--- Verifie que l'index existe
                     if { $panneau(AcqFC,index) == "" } {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                            -message $caption(acqfc,saisind)
                        set integre non
                     }
                     #--- Verifie que l'index est valide (entier positif)
                     if { [ TestEntier $panneau(AcqFC,index) ] == "0" } {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,indinv)
                        set integre non
                     }
                     #--- Envoie un warning si l'index n'est pas a 1
                     if { $panneau(AcqFC,index) != "1" } {
                        set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                           -message $caption(acqfc,indpasun)]
                        if { $confirmation == "no" } {
                           set integre non
                        }
                     }
                     #--- Verifie que le nom des fichiers n'existe pas deja...
                     set nom $panneau(AcqFC,nom_image)
                     #--- Pour eviter un nom de fichier qui commence par un blanc
                     set nom [lindex $nom 0]
                     append nom $panneau(AcqFC,index) $ext
                     if { [ file exists [ file join $audace(rep_images) $nom ] ] == "1" } {
                        #--- Dans ce cas, le fichier existe deja...
                        set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                           -message $caption(acqfc,fichdeja)]
                        if { $confirmation == "no" } {
                           set integre non
                        }
                     }
                     #--- Teste si un telescope est bien selectionnee si l'option decalage est selectionnee
                     if { $panneau(DlgShift,buttonShift) == "1" } {
                        if { [ ::tel::list ] == "" } {
                           ::audace::menustate disabled
                           set choix [ tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,seltel) ]
                           set integre non
                           if { $choix == "ok" } {
                              #--- Ouverture de la fenetre de selection des cameras
                              ::confTel::run 
                              tkwait window $audace(base).confTel
                           }
                           ::audace::menustate normal
                        }
                     }
                  }
                  3  {
                     #--- Mode continu
                     #--- Les tests ne sont necessaires que si l'enregistrement est demande
                     if { $panneau(AcqFC,enregistrer) == "1" } {
                        #--- Verifier qu'il y a bien un nom de fichier
                        if { $panneau(AcqFC,nom_image) == "" } {
                           tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,donnomfich)
                           set integre non
                        }
                        #--- Verifier que le nom de fichier n'a pas d'espace
                        if { [ llength $panneau(AcqFC,nom_image) ] > "1" } {
                           tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,nomblanc)
                           set integre non
                        }
                        #--- Verifie que le nom de fichier ne contient pas de caracteres interdits
                        if { [ TestChaine $panneau(AcqFC,nom_image) ] == "0" } {
                           tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,mauvcar)
                           set integre non
                        }
                        #--- Verifie que l'index existe
                        if { $panneau(AcqFC,index) == "" } {
                           tk_messageBox -title $caption(acqfc,pb) -type ok \
                               -message $caption(acqfc,saisind)
                           set integre non
                        }
                        #--- Verifie que l'index est valide (entier positif)
                        if { [ TestEntier $panneau(AcqFC,index) ] == "0" } {
                           tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,indinv)
                           set integre non
                        }
                        #--- Envoie un warning si l'index n'est pas a 1
                        if { $panneau(AcqFC,index) != "1" } {
                           set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                              -message $caption(acqfc,indpasun)]
                           if { $confirmation == "no" } {
                              set integre non
                           }
                        }
                        #--- Verifie que le nom des fichiers n'existe pas deja...
                        set nom $panneau(AcqFC,nom_image)
                        #--- Pour eviter un nom de fichier qui commence par un blanc
                        set nom [lindex $nom 0]
                        append nom $panneau(AcqFC,index) $ext
                        if { [ file exists [ file join $audace(rep_images) $nom ] ] == "1" } {
                           #--- Dans ce cas, le fichier existe deja...
                           set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                              -message $caption(acqfc,fichdeja)]
                           if { $confirmation == "no" } {
                              set integre non
                           }
                        }
                     }
                     #--- Teste si un telescope est bien selectionnee si l'option decalage est selectionnee
                     if { $panneau(DlgShift,buttonShift) == "1" } {
                        if { [ ::tel::list ] == "" } {
                           ::audace::menustate disabled
                           set choix [ tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,seltel) ]
                           set integre non
                           if { $choix == "ok" } {
                              #--- Ouverture de la fenetre de selection des cameras
                              ::confTel::run 
                              tkwait window $audace(base).confTel
                           }
                           ::audace::menustate normal
                        }
                     }
                  }
                  4  {
                     #--- Mode series d'images en continu avec intervalle entre chaque serie
                     #--- Verifier qu'il y a bien un nom de fichier
                     if { $panneau(AcqFC,nom_image) == "" } {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,donnomfich)
                        set integre non
                     }
                     #--- Verifier que le nom de fichier n'a pas d'espace
                     if { [ llength $panneau(AcqFC,nom_image) ] > "1" } {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,nomblanc)
                        set integre non
                     }
                     #--- Verifie que le nom de fichier ne contient pas de caracteres interdits
                     if { [ TestChaine $panneau(AcqFC,nom_image) ] == "0" } {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,mauvcar)
                        set integre non
                     }
                     #--- Verifie que le nombre de poses est valide (nombre entier)
                     if { [ TestEntier $panneau(AcqFC,nb_images) ] == "0"} {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,nbinv)
                        set integre non
                     }
                     #--- Verifie que l'index existe
                     if { $panneau(AcqFC,index) == "" } {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                            -message $caption(acqfc,saisind)
                        set integre non
                     }
                     #--- Verifie que l'index est valide (entier positif)
                     if { [ TestEntier $panneau(AcqFC,index) ] == "0" } {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,indinv)
                        set integre non
                     }
                     #--- Envoie un warning si l'index n'est pas a 1
                     if { $panneau(AcqFC,index) != "1" } {
                        set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                           -message $caption(acqfc,indpasun)]
                        if { $confirmation == "no" } {
                           set integre non
                        }
                     }
                     #--- Verifie que la simulation a ete lancee
                     if { $panneau(AcqFC,intervalle) == "....." } {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,interinv_2)
                        set integre non
                     #--- Verifie que l'intervalle est valide (entier positif)
                     } elseif { [ TestEntier $panneau(AcqFC,intervalle_1) ] == "0" } {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,interinv)
                        set integre non
                     #--- Verifie que l'intervalle est superieur a celui calcule par la simulation
                     } elseif { ( $panneau(AcqFC,intervalle) > $panneau(AcqFC,intervalle_1) ) && \
                       ( $panneau(AcqFC,intervalle) != "xxx" ) } {
                           tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,interinv_1)
                           set integre non
                     }
                     #--- Verifie que le nom des fichiers n'existe pas deja...
                     set nom $panneau(AcqFC,nom_image)
                     #--- Pour eviter un nom de fichier qui commence par un blanc
                     set nom [lindex $nom 0]
                     append nom $panneau(AcqFC,index) $ext
                     if { [ file exists [ file join $audace(rep_images) $nom ] ] == "1" } {
                        #--- Dans ce cas, le fichier existe deja...
                        set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                           -message $caption(acqfc,fichdeja)]
                        if { $confirmation == "no" } {
                           set integre non
                        }
                     }
                     #--- Teste si un telescope est bien selectionnee si l'option decalage est selectionnee
                     if { $panneau(DlgShift,buttonShift) == "1" } {
                        if { [ ::tel::list ] == "" } {
                           ::audace::menustate disabled
                           set choix [ tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,seltel) ]
                           set integre non
                           if { $choix == "ok" } {
                              #--- Ouverture de la fenetre de selection des cameras
                              ::confTel::run 
                              tkwait window $audace(base).confTel
                           }
                           ::audace::menustate normal
                        }
                     }
                  }
                  5  {
                     #--- Mode continu avec intervalle entre chaque image
                     #--- Les tests ne sont necessaires que si l'enregistrement est demande
                     if { $panneau(AcqFC,enregistrer) == "1" } {
                        #--- Verifier qu'il y a bien un nom de fichier
                        if { $panneau(AcqFC,nom_image) == "" } {
                           tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,donnomfich)
                           set integre non
                        }
                        #--- Verifier que le nom de fichier n'a pas d'espace
                        if { [ llength $panneau(AcqFC,nom_image) ] > "1" } {
                           tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,nomblanc)
                           set integre non
                        }
                        #--- Verifie que le nom de fichier ne contient pas de caracteres interdits
                        if { [ TestChaine $panneau(AcqFC,nom_image) ] == "0" } {
                           tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,mauvcar)
                           set integre non
                        }
                        #--- Verifie que l'index existe
                        if { $panneau(AcqFC,index) == "" } {
                           tk_messageBox -title $caption(acqfc,pb) -type ok \
                               -message $caption(acqfc,saisind)
                           set integre non
                        }
                        #--- Verifie que l'index est valide (entier positif)
                        if { [ TestEntier $panneau(AcqFC,index) ] == "0" } {
                           tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,indinv)
                           set integre non
                        }
                        #--- Envoie un warning si l'index n'est pas a 1
                        if { $panneau(AcqFC,index) != "1" } {
                           set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                              -message $caption(acqfc,indpasun)]
                           if { $confirmation == "no" } {
                              set integre non
                           }
                        }
                        #--- Verifie que la simulation a ete lancee
                        if { $panneau(AcqFC,intervalle) == "....." } {
                           tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,interinv_2)
                           set integre non
                        #--- Verifie que l'intervalle est valide (entier positif)
                        } elseif { [ TestEntier $panneau(AcqFC,intervalle_2) ] == "0" } {
                           tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,interinv)
                           set integre non
                        #--- Verifie que l'intervalle est superieur a celui calcule par la simulation
                        } elseif { ( $panneau(AcqFC,intervalle) > $panneau(AcqFC,intervalle_2) ) && \
                          ( $panneau(AcqFC,intervalle) != "xxx" ) } {
                              tk_messageBox -title $caption(acqfc,pb) -type ok \
                                 -message $caption(acqfc,interinv_1)
                              set integre non
                        }
                        #--- Verifie que le nom des fichiers n'existe pas deja...
                        set nom $panneau(AcqFC,nom_image)
                        #--- Pour eviter un nom de fichier qui commence par un blanc
                        set nom [lindex $nom 0]
                        append nom $panneau(AcqFC,index) $ext
                        if { [ file exists [ file join $audace(rep_images) $nom ] ] == "1" } {
                           #--- Dans ce cas, le fichier existe deja...
                           set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                              -message $caption(acqfc,fichdeja)]
                           if { $confirmation == "no" } {
                              set integre non
                           }
                        }
                     } else {
                        #--- Verifie que la simulation a ete lancee
                        if { $panneau(AcqFC,intervalle) == "....." } {
                           tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,interinv_2)
                           set integre non
                        #--- Verifie que l'intervalle est valide (entier positif)
                        } elseif { [ TestEntier $panneau(AcqFC,intervalle_2) ] == "0" } {
                           tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,interinv)
                           set integre non
                        #--- Verifie que l'intervalle est superieur a celui calcule par la simulation
                        } elseif { ( $panneau(AcqFC,intervalle) > $panneau(AcqFC,intervalle_2) ) && \
                          ( $panneau(AcqFC,intervalle) != "xxx" ) } {
                              tk_messageBox -title $caption(acqfc,pb) -type ok \
                                 -message $caption(acqfc,interinv_1)
                              set integre non
                        }
                     }
                     #--- Teste si un telescope est bien selectionnee si l'option decalage est selectionnee
                     if { $panneau(DlgShift,buttonShift) == "1" } {
                        if { [ ::tel::list ] == "" } {
                           ::audace::menustate disabled
                           set choix [ tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,seltel) ]
                           set integre non
                           if { $choix == "ok" } {
                              #--- Ouverture de la fenetre de selection des cameras
                              ::confTel::run 
                              tkwait window $audace(base).confTel
                           }
                           ::audace::menustate normal
                        }
                     }
                  }
                  6  {
                     #--- Mode video
                     #--- Verifier qu'il s'agit bien d'une webcam
                     if { $conf(camera) != "webcam" } {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message "$caption(acqfc,pb_camera1) $conf(camera) $caption(acqfc,pb_camera2)" 
                        set integre non   
                     }
                     #--- Verifier qu'il y a bien un nom de fichier
                     if { $panneau(AcqFC,nom_image) == "" } {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,donnomfich)
                        set integre non
                     }
                     #--- Verifier que le nom de fichier n'a pas d'espace
                     if { [ llength $panneau(AcqFC,nom_image) ] > "1" } {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,nomblanc)
                        set integre non
                     }
                     #--- Verifie que le nom de fichier ne contient pas de caracteres interdits
                     if { [ TestChaine $panneau(AcqFC,nom_image) ] == "0" } {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,mauvcar)
                        set integre non
                     }
                     if { $panneau(AcqFC,indexer) == "1" } {
                        #--- Verifie que l'index existe
                        if { $panneau(AcqFC,index) == "" } {
                           tk_messageBox -title $caption(acqfc,pb) -type ok \
                               -message $caption(acqfc,saisind)
                           set integre non
                        }
                        #--- Verifie que l'index est valide (entier positif)
                        if { [ TestEntier $panneau(AcqFC,index) ] == "0" } {
                           tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,indinv)
                           set integre non
                        }
                        #--- Envoie un warning si l'index n'est pas a 1
                        if { $panneau(AcqFC,index) != "1" } {
                           set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                              -message $caption(acqfc,indpasun)]
                           if { $confirmation == "no" } {
                              set integre non
                           }
                        }
                     }
                     #--- Verifie que le nom des fichiers n'existe pas deja...
                     set nom $panneau(AcqFC,nom_image)
                     #--- Pour eviter un nom de fichier qui commence par un blanc
                     set nom [lindex $nom 0]
                     append nom $panneau(AcqFC,index) $ext
                     if { [ file exists [ file join $audace(rep_images) $nom ] ] == "1" } {
                        #--- Dans ce cas, le fichier existe deja...
                        set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                           -message $caption(acqfc,fichdeja)]
                        if { $confirmation == "no" } {
                           set integre non
                        }
                     }
                  }
                  7  {
                     #--- Mode video avec intervalle entre chaque video
                     #--- Verifier qu'il s'agit bien d'une webcam
                     if { $conf(camera) != "webcam" } {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message "$caption(acqfc,pb_camera1) $conf(camera) $caption(acqfc,pb_camera2)" 
                        set integre non   
                     }
                     #--- Verifier qu'il y a bien un nom de fichier
                     if { $panneau(AcqFC,nom_image) == "" } {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,donnomfich)
                        set integre non
                     }
                     #--- Verifier que le nom de fichier n'a pas d'espace
                     if { [ llength $panneau(AcqFC,nom_image) ] > "1" } {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,nomblanc)
                        set integre non
                     }
                     #--- Verifie que le nom de fichier ne contient pas de caracteres interdits
                     if { [ TestChaine $panneau(AcqFC,nom_image) ] == "0" } {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,mauvcar)
                        set integre non
                     }
                     #--- Verifie que l'index existe
                     if { $panneau(AcqFC,index) == "" } {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                            -message $caption(acqfc,saisind)
                        set integre non
                     }
                     #--- Verifie que l'index est valide (entier positif)
                     if { [ TestEntier $panneau(AcqFC,index) ] == "0" } {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,indinv)
                        set integre non
                     }
                     #--- Envoie un warning si l'index n'est pas a 1
                     if { $panneau(AcqFC,index) != "1" } {
                        set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                           -message $caption(acqfc,indpasun)]
                        if { $confirmation == "no" } {
                           set integre non
                        }
                     }
                     #--- Verifie que l'intervalle est valide (entier positif)
                     if { [ TestEntier $panneau(AcqFC,intervalle_video) ] == "0" } {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,interinv)
                        set integre non
                     #--- Verifie que l'intervalle est superieur a la duree du film
                     } elseif { $panneau(AcqFC,lg_film) > $panneau(AcqFC,intervalle_video) } {
                        tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,interinv_3)
                        set integre non
                     }
                     #--- Verifie que le nom des fichiers n'existe pas deja...
                     set nom $panneau(AcqFC,nom_image)
                     #--- Pour eviter un nom de fichier qui commence par un blanc
                     set nom [lindex $nom 0]
                     append nom $panneau(AcqFC,index) $ext
                     if { [ file exists [ file join $audace(rep_images) $nom ] ] == "1" } {
                        #--- Dans ce cas, le fichier existe deja...
                        set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                           -message $caption(acqfc,fichdeja)]
                        if { $confirmation == "no" } {
                           set integre non
                        }
                     }
                  }
               }
            }
            #------ Fin des tests d'integrite de la requete ----------------------------

            #--- Apres les tests d'integrite, je reactive le bouton "GO"
            $This.go_stop.but configure -state normal
            #--- Apres tous les tests d'integrite, je peux maintenant lancer les acquisitions
            if { $integre == "oui" } {
               #--- Modification du bouton, pour eviter un second lancement
               set panneau(AcqFC,go_stop) stop
               $This.go_stop.but configure -text $caption(acqfc,stop)
               #--- Verouille tous les boutons et champs de texte pendant les acquisitions
               $This.pose.but configure -state disabled
               $This.pose.entr configure -state disabled
               $This.bin.but configure -state disabled
               $This.obt.but configure -state disabled
               $This.mode.but configure -state disabled
               #--- Desactive toute demande d'arret
               set panneau(AcqFC,demande_arret) "0"
               #--- Pose en cours
               set panneau(AcqFC,pose_en_cours) "1"
               #--- Cas particulier du passage WebCam LP en WebCam normale pour inhiber la barre progression
               if { ( $conf(camera) == "webcam" ) && ( $conf(webcam,longuepose) == "0" ) } {
                  set panneau(AcqFC,pose) "1"
               }
               #--- Branchement selon le mode de prise de vue
               switch $panneau(AcqFC,mode) {
                  1  {
                     #--- Mode une image
                     #--- Verouille les boutons du mode "une image"
                     $This.mode.une.nom.entr configure -state disabled
                     $This.mode.une.index.case configure -state disabled
                     $This.mode.une.index.entr configure -state disabled
                     $This.mode.une.index.but configure -state disabled
                     $This.mode.une.sauve configure -state disabled
                     set heure $audace(tu,format,hmsint)
                     Message consolog $caption(acqfc,acquneim) \
                        $panneau(AcqFC,pose) $panneau(AcqFC,bin) $heure
                     acq $panneau(AcqFC,pose) $panneau(AcqFC,bin)
                     #--- Deverouille les boutons du mode "une image"
                     $This.mode.une.nom.entr configure -state normal
                     $This.mode.une.index.case configure -state normal
                     $This.mode.une.index.entr configure -state normal
                     $This.mode.une.index.but configure -state normal
                     $This.mode.une.sauve configure -state normal
                     #--- Pose en cours
                     set panneau(AcqFC,pose_en_cours) "0"
                  }
                  2  {
                     #--- Mode serie
                     #--- Verouille les boutons du mode "serie"
                     $This.mode.serie.nom.entr configure -state disabled
                     $This.mode.serie.nb.entr configure -state disabled
                     $This.mode.serie.index.entr configure -state disabled
                     $This.mode.serie.index.but configure -state disabled
                     set heure $audace(tu,format,hmsint)
                     if { $panneau(AcqFC,simulation) == "1" } {
                        Message consolog $caption(acqfc,lance_simu)
                     } 
                     Message consolog $caption(acqfc,lanceserie) \
                        $panneau(AcqFC,nb_images) $heure
                     Message consolog $caption(acqfc,nomgen) $panneau(AcqFC,nom_image) \
                        $panneau(AcqFC,pose) $panneau(AcqFC,bin) $panneau(AcqFC,index)
                     #--- Debut de la premiere pose
                     if { $panneau(AcqFC,simulation) == "1" } {
                        set panneau(AcqFC,debut) [ clock second ]
                     } 
                     for { set i 1 } { ( $i <= $panneau(AcqFC,nb_images) ) && ( $panneau(AcqFC,demande_arret) == "0" ) } { incr i } {
                        acq $panneau(AcqFC,pose) $panneau(AcqFC,bin)
                        #--- Je dois encore sauvegarder l'image
                        $This.status.lab configure -text $caption(acqfc,enreg)
                        set nom $panneau(AcqFC,nom_image)
                        #--- Pour eviter un nom de fichier qui commence par un blanc
                        set nom [lindex $nom 0]
                        if { $panneau(AcqFC,simulation) == "0" } {
                           #--- Verifie que le nom du fichier n'existe pas deja...
                           set nom1 "$nom"
                           append nom1 $panneau(AcqFC,index) $ext
                           if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
                              #--- Dans ce cas, le fichier existe deja...
                              set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                                 -message $caption(acqfc,fichdeja)]
                              if { $confirmation == "no" } {
                                 break
                              }
                           }
                           #--- Sauvegarde de l'image
                           saveima [append nom $panneau(AcqFC,index)]
                           set heure $audace(tu,format,hmsint)
                           Message consolog $caption(acqfc,enrim) $heure $nom
                        }
                        incr panneau(AcqFC,index)
                        $This.status.lab configure -text ""
                        if { $panneau(AcqFC,simulation) == "0" } {
                           if { $i != "$panneau(AcqFC,nb_images)" } {
                              #--- Deplacement du telescope
                              ::DlgShift::Decalage_Telescope
                           }
                        } elseif { $panneau(AcqFC,simulation) == "1" } {
                           #--- Deplacement du telescope
                           ::DlgShift::Decalage_Telescope
                        }
                     }
                     #--- Fin de la derniere pose et intervalle mini entre 2 poses ou 2 series
                     if { $panneau(AcqFC,simulation) == "1" } {
                        set panneau(AcqFC,fin) [ clock second ]
                        set panneau(AcqFC,intervalle) [ expr $panneau(AcqFC,fin) - $panneau(AcqFC,debut) ]
                        Message consolog $caption(acqfc,fin_simu)
                     } 
                     #--- Cas particulier des cameras DigiCam
                     if { $panneau(AcqFC,telecharge_mode) == "3" } {
                        #--- Chargement de la derniere image
                        set result [ catch { cam$::audace(camNo) loadlastimage} msg ]
                        if { $result == "1" } {
                           ::console::disp "::AcqFC::GoStop loadlastimage $msg \n"
                        } else { 
                           ::console::disp "::AcqFC::GoStop loadlastimage OK \n"
                        }
                        #--- Retournement de l'image
                        set cam $conf(camera)
                        if { $conf($cam,mirx) == "1" } {
                          $buffer mirrorx
                        }
                        if { $conf($cam,miry) == "1" } {
                           $buffer mirrory
                        }
                        #--- Visualisation de l'image
                        image delete image0
                        image create photo image0
                        ::audace::autovisu visu$audace(visuNo)
                     }
                     #--- Deverouille les boutons du mode "serie"
                     $This.mode.serie.nom.entr configure -state normal
                     $This.mode.serie.nb.entr configure -state normal
                     $This.mode.serie.index.entr configure -state normal
                     $This.mode.serie.index.but configure -state normal
                     #--- Pose en cours
                     set panneau(AcqFC,pose_en_cours) "0"
                  }
                  3  {
                     #--- Mode continu
                     #--- Verouille les boutons du mode "continu"
                     $This.mode.continu.sauve.case configure -state disabled
                     $This.mode.continu.nom.entr configure -state disabled
                     $This.mode.continu.index.entr configure -state disabled
                     $This.mode.continu.index.but configure -state disabled
                     set heure $audace(tu,format,hmsint)
                     Message consolog $caption(acqfc,lancecont) $panneau(AcqFC,pose) $panneau(AcqFC,bin) $heure
                     if { $panneau(AcqFC,enregistrer) == "1" } {
                        Message consolog $caption(acqfc,enregen) \
                          $panneau(AcqFC,nom_image)
                     } else {
                        Message consolog $caption(acqfc,sansenr)
                     }
                     while { ( $panneau(AcqFC,demande_arret) == "0" ) && ( $panneau(AcqFC,mode) == "3" ) } {
                        acq $panneau(AcqFC,pose) $panneau(AcqFC,bin)
                        #--- Je dois encore sauvegarder l'image
                        if { $panneau(AcqFC,enregistrer) == "1" } {
                           $This.status.lab configure -text $caption(acqfc,enreg)
                           set nom $panneau(AcqFC,nom_image)
                           #--- Pour eviter un nom de fichier qui commence par un blanc
                           set nom [lindex $nom 0]
                           if { $panneau(AcqFC,demande_arret) == "0" } {
                              #--- Verifie que le nom du fichier n'existe pas deja...
                              set nom1 "$nom"
                              append nom1 $panneau(AcqFC,index) $ext
                              if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
                                 #--- Dans ce cas, le fichier existe deja...
                                 set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                                    -message $caption(acqfc,fichdeja)]
                                 if { $confirmation == "no" } {
                                    break
                                 }
                              }
                              #--- Sauvegarde de l'image
                              saveima [append nom $panneau(AcqFC,index)]
                           } else {
                              set panneau(AcqFC,index) [ expr $panneau(AcqFC,index) - 1 ]
                           }
                           incr panneau(AcqFC,index)
                           $This.status.lab configure -text ""
                           set heure $audace(tu,format,hmsint)
                           if { $panneau(AcqFC,demande_arret) == "0" } {
                              Message consolog $caption(acqfc,enrim) $heure $nom
                           }
                        }
                        #--- Deplacement du telescope
                        ::DlgShift::Decalage_Telescope
                     }
                     #--- Cas particulier des cameras DigiCam
                     if { $panneau(AcqFC,telecharge_mode) == "3" } {
                        #--- Chargement de la derniere image
                        set result [ catch { cam$::audace(camNo) loadlastimage} msg ]
                        if { $result == "1" } {
                           ::console::disp "::AcqFC::GoStop loadlastimage $msg \n"
                        } else { 
                           ::console::disp "::AcqFC::GoStop loadlastimage OK \n"
                        }
                        #--- Retournement de l'image
                        set cam $conf(camera)
                        if { $conf($cam,mirx) == "1" } {
                          $buffer mirrorx
                        }
                        if { $conf($cam,miry) == "1" } {
                           $buffer mirrory
                        }
                        #--- Visualisation de l'image
                        image delete image0
                        image create photo image0
                        ::audace::autovisu visu$audace(visuNo)
                     }
                     #--- Deverouille les boutons du mode "continu"
                     $This.mode.continu.sauve.case configure -state normal
                     $This.mode.continu.nom.entr configure -state normal
                     $This.mode.continu.index.entr configure -state normal
                     $This.mode.continu.index.but configure -state normal
                     #--- Pose en cours
                     set panneau(AcqFC,pose_en_cours) "0"
                  }
                  4  {
                     #--- Mode series d'images en continu avec intervalle entre chaque serie
                     #--- Verouille les boutons du mode "continu 1"
                     $This.mode.serie_1.nom.entr configure -state disabled
                     $This.mode.serie_1.nb.entr configure -state disabled
                     $This.mode.serie_1.index.entr configure -state disabled
                     $This.mode.serie_1.index.but configure -state disabled
                     set heure $audace(tu,format,hmsint)
                     Message consolog $caption(acqfc,lanceserie_int) \
                        $panneau(AcqFC,nb_images) $panneau(AcqFC,intervalle_1) $heure
                     Message consolog $caption(acqfc,nomgen) $panneau(AcqFC,nom_image) \
                        $panneau(AcqFC,pose) $panneau(AcqFC,bin) $panneau(AcqFC,index)
                     while { ( $panneau(AcqFC,demande_arret) == "0" ) && ( $panneau(AcqFC,mode) == "4" ) } {
                        set panneau(AcqFC,deb_im) [ clock second ]
                        for { set i 1 } { ( $i <= $panneau(AcqFC,nb_images) ) && ( $panneau(AcqFC,demande_arret) == "0" ) } { incr i } {
                           acq $panneau(AcqFC,pose) $panneau(AcqFC,bin)
                           #--- Je dois encore sauvegarder l'image
                           $This.status.lab configure -text $caption(acqfc,enreg)
                           set nom $panneau(AcqFC,nom_image)
                           #--- Pour eviter un nom de fichier qui commence par un blanc
                           set nom [lindex $nom 0]
                           #--- Verifie que le nom du fichier n'existe pas deja...
                           set nom1 "$nom"
                           append nom1 $panneau(AcqFC,index) $ext
                           if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
                              #--- Dans ce cas, le fichier existe deja...
                              set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                                 -message $caption(acqfc,fichdeja)]
                              if { $confirmation == "no" } {
                                 break
                              }
                           }
                           #--- Sauvegarde de l'image
                           saveima [append nom $panneau(AcqFC,index)]
                           incr panneau(AcqFC,index)
                           $This.status.lab configure -text ""
                           set heure $audace(tu,format,hmsint)
                           Message consolog $caption(acqfc,enrim) $heure $nom
                           #--- Deplacement du telescope
                           ::DlgShift::Decalage_Telescope
                        }
                        set panneau(AcqFC,attente_pose) "1"
                        set panneau(AcqFC,fin_im) [ clock second ]
                        set panneau(AcqFC,intervalle_im_1) [ expr $panneau(AcqFC,fin_im) - $panneau(AcqFC,deb_im) ]
                        while { ( $panneau(AcqFC,demande_arret) == "0" ) && ( $panneau(AcqFC,intervalle_im_1) <= $panneau(AcqFC,intervalle_1) ) } {
                           after 500
                           set panneau(AcqFC,fin_im) [ clock second ]
                           set panneau(AcqFC,intervalle_im_1) [ expr $panneau(AcqFC,fin_im) - $panneau(AcqFC,deb_im) + 1 ]
                           set t [ expr $panneau(AcqFC,intervalle_1) - $panneau(AcqFC,intervalle_im_1) ]
                           ::AcqFC::Avancement_pose $t
                        }
                        set panneau(AcqFC,attente_pose) "0"
                     }
                     #--- Cas particulier des cameras DigiCam
                     if { $panneau(AcqFC,telecharge_mode) == "3" } {
                        #--- Chargement de la derniere image
                        set result [ catch { cam$::audace(camNo) loadlastimage} msg ]
                        if { $result == "1" } {
                           ::console::disp "::AcqFC::GoStop loadlastimage $msg \n"
                        } else { 
                           ::console::disp "::AcqFC::GoStop loadlastimage OK \n"
                        }
                        #--- Retournement de l'image
                        set cam $conf(camera)
                        if { $conf($cam,mirx) == "1" } {
                          $buffer mirrorx
                        }
                        if { $conf($cam,miry) == "1" } {
                           $buffer mirrory
                        }
                        #--- Visualisation de l'image
                        image delete image0
                        image create photo image0
                        ::audace::autovisu visu$audace(visuNo)
                     }
                     #--- Deverouille les boutons du mode "continu 1"
                     $This.mode.serie_1.nom.entr configure -state normal
                     $This.mode.serie_1.nb.entr configure -state normal
                     $This.mode.serie_1.index.entr configure -state normal
                     $This.mode.serie_1.index.but configure -state normal
                     #--- Pose en cours
                     set panneau(AcqFC,pose_en_cours) "0"
                  }
                  5  {
                     #--- Mode continu avec intervalle entre chaque image
                     #--- Verouille les boutons du mode "continu 2"
                     $This.mode.continu_1.sauve.case configure -state disabled
                     $This.mode.continu_1.nom.entr configure -state disabled
                     $This.mode.continu_1.index.entr configure -state disabled
                     $This.mode.continu_1.index.but configure -state disabled
                     set heure $audace(tu,format,hmsint)
                     Message consolog $caption(acqfc,lancecont_int) $panneau(AcqFC,intervalle_2) \
                        $panneau(AcqFC,pose) $panneau(AcqFC,bin) $heure
                     if { $panneau(AcqFC,enregistrer) == "1" } {
                        Message consolog $caption(acqfc,enregen) \
                          $panneau(AcqFC,nom_image)
                     } else {
                        Message consolog $caption(acqfc,sansenr)
                     }
                     while { ( $panneau(AcqFC,demande_arret) == "0" ) && ( $panneau(AcqFC,mode) == "5" ) } {
                        set panneau(AcqFC,deb_im) [ clock second ]
                        acq $panneau(AcqFC,pose) $panneau(AcqFC,bin)
                        #--- Je dois encore sauvegarder l'image
                        if { $panneau(AcqFC,enregistrer) == "1" } {
                           $This.status.lab configure -text $caption(acqfc,enreg)
                           set nom $panneau(AcqFC,nom_image)
                           #--- Pour eviter un nom de fichier qui commence par un blanc
                           set nom [lindex $nom 0]
                           if { $panneau(AcqFC,demande_arret) == "0" } {
                              #--- Verifie que le nom du fichier n'existe pas deja...
                              set nom1 "$nom"
                              append nom1 $panneau(AcqFC,index) $ext
                              if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
                                 #--- Dans ce cas, le fichier existe deja...
                                 set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                                    -message $caption(acqfc,fichdeja)]
                                 if { $confirmation == "no" } {
                                    break
                                 }
                              }
                              #--- Sauvegarde de l'image
                              saveima [append nom $panneau(AcqFC,index)]
                           } else {
                              set panneau(AcqFC,index) [ expr $panneau(AcqFC,index) - 1 ]
                           }
                           incr panneau(AcqFC,index)
                           $This.status.lab configure -text ""
                           set heure $audace(tu,format,hmsint)
                           if { $panneau(AcqFC,demande_arret) == "0" } {
                              Message consolog $caption(acqfc,enrim) $heure $nom
                           }
                        }
                        #--- Deplacement du telescope
                        ::DlgShift::Decalage_Telescope
                        set panneau(AcqFC,attente_pose) "1"
                        set panneau(AcqFC,fin_im) [ clock second ]
                        set panneau(AcqFC,intervalle_im_2) [ expr $panneau(AcqFC,fin_im) - $panneau(AcqFC,deb_im) ]
                        while { ( $panneau(AcqFC,demande_arret) == "0" ) && ( $panneau(AcqFC,intervalle_im_2) <= $panneau(AcqFC,intervalle_2) ) } {
                           after 500
                           set panneau(AcqFC,fin_im) [ clock second ]
                           set panneau(AcqFC,intervalle_im_2) [ expr $panneau(AcqFC,fin_im) - $panneau(AcqFC,deb_im) + 1 ]
                           set t [ expr $panneau(AcqFC,intervalle_2) - $panneau(AcqFC,intervalle_im_2) ]
                           ::AcqFC::Avancement_pose $t
                        }
                        set panneau(AcqFC,attente_pose) "0"
                     }
                     set heure $audace(tu,format,hmsint)
                     Message consolog $caption(acqfc,arrcont) $heure
                     if { $panneau(AcqFC,enregistrer) == "1" } { 
                        set panneau(AcqFC,index) [ expr $panneau(AcqFC,index) - 1 ]
                        Message consolog $caption(acqfc,dersauve) [append nom $panneau(AcqFC,index)]
                        set panneau(AcqFC,index) [ expr $panneau(AcqFC,index) + 1 ]
                     }
                     #--- Cas particulier des cameras DigiCam
                     if { $panneau(AcqFC,telecharge_mode) == "3" } {
                        #--- Chargement de la derniere image
                        set result [ catch { cam$::audace(camNo) loadlastimage} msg ]
                        if { $result == "1" } {
                           ::console::disp "::AcqFC::GoStop loadlastimage $msg \n"
                        } else { 
                           ::console::disp "::AcqFC::GoStop loadlastimage OK \n"
                        }
                        #--- Retournement de l'image
                        set cam $conf(camera)
                        if { $conf($cam,mirx) == "1" } {
                          $buffer mirrorx
                        }
                        if { $conf($cam,miry) == "1" } {
                           $buffer mirrory
                        }
                        #--- Visualisation de l'image
                        image delete image0
                        image create photo image0
                        ::audace::autovisu visu$audace(visuNo)
                     }
                     #--- Deverouille les boutons du mode "continu 2"
                     $This.mode.continu_1.sauve.case configure -state normal
                     $This.mode.continu_1.nom.entr configure -state normal
                     $This.mode.continu_1.index.entr configure -state normal
                     $This.mode.continu_1.index.but configure -state normal
                     #--- Pose en cours
                     set panneau(AcqFC,pose_en_cours) "0"
                  }
                  6  {
                     #--- Mode video
                     #--- Verouille les boutons du mode "video"
                     $This.mode.video.nom.entr configure -state disabled
                     $This.mode.video.index.case configure -state disabled
                     $This.mode.video.index.entr configure -state disabled
                     $This.mode.video.index.but configure -state disabled
                     $This.mode.video.show.case configure -state disabled
                     set heure $audace(tu,format,hmsint)
                     Message consolog $caption(acqfc,acqvideo) \
                        $panneau(AcqFC,lg_film) $panneau(AcqFC,rate) $heure
                     set nom $panneau(AcqFC,nom_image)                     
                     #--- Pour eviter un nom de fichier qui commence par un blanc
                     set nom [lindex $nom 0]
                     if { $panneau(AcqFC,indexer) == "1" } {
                        set nom [append nom $panneau(AcqFC,index)]
                     }
                     set nom_rep [ file join $audace(rep_images) "$nom.avi" ]
                     #--- Verifie que le nom du fichier n'existe pas deja...
                     if { [ file exists $nom_rep ] == "1" } {
                        #--- Dans ce cas, le fichier existe deja...
                        set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                           -message $caption(acqfc,fichdeja)]
                        if { $confirmation == "no" } {
                           break
                        }
                     }
                     #--- Je declare la variable qui sera mise a jour par le driver avec le decompte des frames
                     cam$audace(camNo) setvideostatusvariable panneau(AcqFC,status)               
                     set result [ catch { cam$audace(camNo) startvideocapture "$nom_rep" "$panneau(AcqFC,lg_film)" "$panneau(AcqFC,rate)" "1" } msg ]
                     if { $result == "1" } {
                        #--- En cas d'erreur, j'affiche un message d'erreur
                        #--- Et je passe a la suite sans attendre
                        ::console::affiche_resultat "$caption(acqfc,start_capture_error) $msg \n"
                     } else {
                        #--- Attente de la fin de la pose (fin normale ou interruption)
                        vwait status_cam$audace(camNo)
                     }
                     if { $panneau(AcqFC,indexer) == "1" } {
                        incr panneau(AcqFC,index)
                     }
                     set heure $audace(tu,format,hmsint)
                     Message consolog $caption(acqfc,enrim_video) $heure $nom
                     #--- Deverouille les boutons du mode "video"
                     $This.mode.video.nom.entr configure -state normal
                     $This.mode.video.index.case configure -state normal
                     $This.mode.video.index.entr configure -state normal
                     $This.mode.video.index.but configure -state normal
                     $This.mode.video.show.case configure -state normal
                     #--- Pose en cours
                     set panneau(AcqFC,pose_en_cours) "0"
                  }
                  7  {
                     #--- Mode video avec intervalle entre chaque video
                     #--- Verouille les boutons du mode "video"
                     $This.mode.video_1.nom.entr configure -state disabled
                     $This.mode.video_1.index.entr configure -state disabled
                     $This.mode.video_1.index.but configure -state disabled
                     $This.mode.video_1.show.case configure -state disabled
                     set heure $audace(tu,format,hmsint)
                     Message consolog $caption(acqfc,acqvideo_cont) $panneau(AcqFC,intervalle_video) \
                        $panneau(AcqFC,lg_film) $panneau(AcqFC,rate) $heure
                     while { ( $panneau(AcqFC,demande_arret) == "0" ) && ( $panneau(AcqFC,mode) == "7" ) } {
                        set panneau(AcqFC,deb_video) [ clock second ]
                        set nom $panneau(AcqFC,nom_image)
                        #--- Pour eviter un nom de fichier qui commence par un blanc
                        set nom [lindex $nom 0]
                        set nom [append nom $panneau(AcqFC,index)]
                        set nom_rep [ file join $audace(rep_images) "$nom.avi" ]
                        #--- Verifie que le nom du fichier n'existe pas deja...
                        if { [ file exists $nom_rep ] == "1" } {
                           #--- Dans ce cas, le fichier existe deja...
                           set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                              -message $caption(acqfc,fichdeja)]
                           if { $confirmation == "no" } {
                              break
                           }
                        }
                        #--- J'autorise le bouton "STOP"
                        $This.go_stop.but configure -state normal
                        #--- Je declare la variable qui sera mise a jour par le driver avec le decompte des frames
                        cam$audace(camNo) setvideostatusvariable panneau(AcqFC,status)               
                        set result [ catch { cam$audace(camNo) startvideocapture "$nom_rep" "$panneau(AcqFC,lg_film)" "$panneau(AcqFC,rate)" "1" } msg ]
                        if { $result == "1" } {
                           ::console::affiche_resultat "$caption(acqfc,start_capture_error) $msg \n"
                        } else {
                           #--- Attente de la fin de la pose (fin normale ou interruption)
                           vwait status_cam$audace(camNo)
                           #--- Je desactive le bouton "STOP"
                           $This.go_stop.but configure -state disabled
                        }
                        incr panneau(AcqFC,index)
                        set heure $audace(tu,format,hmsint)
                        Message consolog $caption(acqfc,enrim_video) $heure $nom
                        #--- Deplacement du telescope
                        ::DlgShift::Decalage_Telescope
                        set panneau(AcqFC,attente_pose) "1"
                        set panneau(AcqFC,fin_video) [ clock second ]
                        set panneau(AcqFC,intervalle_film) [ expr $panneau(AcqFC,fin_video) - $panneau(AcqFC,deb_video) ]
                        while { ( $panneau(AcqFC,demande_arret) == "0" ) && ( $panneau(AcqFC,intervalle_film) <= $panneau(AcqFC,intervalle_video) ) } {
                           after 500
                           set panneau(AcqFC,fin_video) [ clock second ]
                           set panneau(AcqFC,intervalle_film) [ expr $panneau(AcqFC,fin_video) - $panneau(AcqFC,deb_video) + 1 ]
                           set t [ expr $panneau(AcqFC,intervalle_video) - $panneau(AcqFC,intervalle_film) ]
                           ::AcqFC::Avancement_pose $t
                        }
                        set panneau(AcqFC,attente_pose) "0"
                     }
                     set heure $audace(tu,format,hmsint)
                     console::affiche_saut "\n"
                     Message consolog $caption(acqfc,arrcont) $heure
                     Message consolog $caption(acqfc,dersauve_video) $nom
                     #--- Deverouille les boutons du mode "video"
                     $This.mode.video_1.nom.entr configure -state normal
                     $This.mode.video_1.index.entr configure -state normal
                     $This.mode.video_1.index.but configure -state normal
                     $This.mode.video_1.show.case configure -state normal
                     #--- Pose en cours
                     set panneau(AcqFC,pose_en_cours) "0"
                  }
               }
               #--- Deverouille tous les boutons et champs de texte pendant les acquisitions
               $This.pose.but configure -state normal
               $This.pose.entr configure -state normal
               $This.bin.but configure -state normal
               $This.obt.but configure -state normal
               $This.mode.but configure -state normal
               #--- Je restitue l'affichage du bouton "GO"
               set panneau(AcqFC,go_stop) go
               $This.go_stop.but configure -text $caption(acqfc,GO)
               #--- J'autorise le bouton "GO"
               $This.go_stop.but configure -state normal
            }
         }
         stop {
            #--- Je desactive le bouton "STOP"
            $This.go_stop.but configure -state disabled
            #--- J'arrete l'acquisition
            ArretImage
            switch $panneau(AcqFC,mode) {
               1  {
                  #--- Mode une image
                     #--- Message suite a l'arret
                     set heure $audace(tu,format,hmsint)
                     if { $panneau(AcqFC,pose_en_cours) == "1" } {
                        console::affiche_saut "\n"
                        Message consolog $caption(acqfc,arrprem) $heure
                        Message consolog $caption(acqfc,lg_pose_arret) [ lindex [ buf$audace(bufNo) getkwd EXPOSURE ] 1 ]
                     }
                     #--- Deverouille les boutons du mode "une image"
                     $This.mode.une.nom.entr configure -state normal
                     $This.mode.une.index.case configure -state normal
                     $This.mode.une.index.entr configure -state normal
                     $This.mode.une.index.but configure -state normal
                     $This.mode.une.sauve configure -state normal
               }
               2  {
                  #--- Mode serie
                     #--- Message suite a l'arret
                     set heure $audace(tu,format,hmsint)
                     if { $panneau(AcqFC,pose_en_cours) == "1" } {
                        console::affiche_saut "\n"
                        Message consolog $caption(acqfc,arrprem) $heure
                     }
                     #--- Deverouille les boutons du mode "serie"
                     $This.mode.serie.nom.entr configure -state normal
                     $This.mode.serie.nb.entr configure -state normal
                     $This.mode.serie.index.entr configure -state normal
                     $This.mode.serie.index.but configure -state normal
               }
               3  {
                  #--- Mode continu
                     #--- Message suite a l'arret
                     set heure $audace(tu,format,hmsint)
                     if { $panneau(AcqFC,pose_en_cours) == "1" } {
                        console::affiche_saut "\n"
                        Message consolog $caption(acqfc,arrprem) $heure
                        if { $panneau(AcqFC,enregistrer) == "1" } {
                           set index [ expr $panneau(AcqFC,index) - 1 ]
                           set nom [lindex $panneau(AcqFC,nom_image) 0]
                           Message consolog $caption(acqfc,dersauve) [append nom $index]
                        } else {
                           Message consolog $caption(acqfc,lg_pose_arret) [ lindex [ buf$audace(bufNo) getkwd EXPOSURE ] 1 ]
                        }
                     }
                     #--- Deverouille les boutons du mode "continu"
                     $This.mode.continu.sauve.case configure -state normal
                     $This.mode.continu.nom.entr configure -state normal
                     $This.mode.continu.index.entr configure -state normal
                     $This.mode.continu.index.but configure -state normal
               }
               4  {
                  #--- Mode series d'images en continu avec intervalle entre chaque serie
                     #--- Message suite a l'arret
                     set heure $audace(tu,format,hmsint)
                     if { $panneau(AcqFC,pose_en_cours) == "1" } {
                        console::affiche_saut "\n"
                        Message consolog $caption(acqfc,arrprem) $heure
                        set i $panneau(AcqFC,nb_images)
                     }
                     #--- Deverouille les boutons du mode "continu 1"
                     $This.mode.serie_1.nom.entr configure -state normal
                     $This.mode.serie_1.nb.entr configure -state normal
                     $This.mode.serie_1.index.entr configure -state normal
                     $This.mode.serie_1.index.but configure -state normal
               }
               5  {
                  #--- Mode continu avec intervalle entre chaque image
                     #--- Message suite a l'arret
                     set heure $audace(tu,format,hmsint)
                     if { $panneau(AcqFC,pose_en_cours) == "1" } {
                        console::affiche_saut "\n"
                        if { $panneau(AcqFC,enregistrer) == "0" } {
                           Message consolog $caption(acqfc,lg_pose_arret) [ lindex [ buf$audace(bufNo) getkwd EXPOSURE ] 1 ]
                        }
                     }
                     #--- Deverouille les boutons du mode "continu 2"
                     $This.mode.continu_1.sauve.case configure -state normal
                     $This.mode.continu_1.nom.entr configure -state normal
                     $This.mode.continu_1.index.entr configure -state normal
                     $This.mode.continu_1.index.but configure -state normal
               }
               6  {
                  #--- Mode video
                     #--- J'arrete la capture video
                     catch { cam$audace(camNo) stopvideocapture }
                     #--- Message suite a l'arret
                     set heure $audace(tu,format,hmsint)
                     if { $panneau(AcqFC,pose_en_cours) == "1" } {
                        console::affiche_saut "\n"
                        Message consolog $caption(acqfc,arrprem) $heure
                     }
                     #--- Deverouille les boutons du mode "video"
                     $This.mode.video.nom.entr configure -state normal
                     $This.mode.video.index.case configure -state normal
                     $This.mode.video.index.entr configure -state normal
                     $This.mode.video.index.but configure -state normal
                     $This.mode.video.show.case configure -state normal
               }
               7  {
                  #--- Mode video avec intervalle entre chaque video
                     #--- J'arrete la capture video
                     catch { cam$audace(camNo) stopvideocapture }
                     #--- Message suite a l'arret
                     set heure $audace(tu,format,hmsint)
                     if { $panneau(AcqFC,pose_en_cours) == "1" } {
                        console::affiche_saut "\n"
                        Message consolog $caption(acqfc,arrprem) $heure
                     }
                     #--- Deverouille les boutons du mode "video 1"
                     $This.mode.video_1.nom.entr configure -state normal
                     $This.mode.video_1.index.entr configure -state normal
                     $This.mode.video_1.index.but configure -state normal
                     $This.mode.video_1.show.case configure -state normal
               }
            }
            #--- Deverouille tous les boutons et champs de texte pendant les acquisitions
            $This.pose.but configure -state normal
            $This.pose.entr configure -state normal
            $This.bin.but configure -state normal
            $This.obt.but configure -state normal
            $This.mode.but configure -state normal
            #--- Je restitue l'affichage du bouton "GO"
            set panneau(AcqFC,go_stop) go
            $This.go_stop.but configure -text $caption(acqfc,GO)
            #--- J'autorise le bouton "GO"
            $This.go_stop.but configure -state normal
            #--- Effacement de la barre de progression quand la pose est terminee
            destroy $audace(base).progress
            #--- Affichage du status
            $This.status.lab configure -text ""
            update
            #--- Pose en cours
            set panneau(AcqFC,pose_en_cours) "0"
         }
      }
   }
#***** Fin de la procedure Go/Stop *****************************

#***** Procedure de lancement d'acquisition ********************
   proc acq { exptime binning } {
      global audace conf panneau caption
      variable This

      #--- Petits raccourcis
      set camera cam$audace(camNo)
      set buffer buf$audace(bufNo)

      #--- Affichage du status
      $This.status.lab configure -text $caption(acqfc,raz)
      update

      #--- Si je fais un offset (pose de 0s) alors l'obturateur reste ferme
      if { $exptime == "0" } {
            $camera shutter "closed"
      }

      #--- Initialisation du fenetrage
      catch {
         set n1n2 [ $camera nbcells ]
         $camera window [ list 1 1 [ lindex $n1n2 0 ] [ lindex $n1n2 1 ] ]
      }

      #--- La commande exptime permet de fixer le temps de pose de l'image
      $camera exptime $exptime

      #--- La commande bin permet de fixer le binning
      $camera bin [list [string range $binning 0 0] [string range $binning 2 2]]

      if { $exptime <= "1" } {
         $This.status.lab configure -text $caption(acqfc,lect)
         update
      }

      #--- J'autorise le bouton "STOP"
      $This.go_stop.but configure -state normal

      #--- Declenchement l'acquisition
      $camera acq

      #--- Alarme sonore de fin de pose
      ::camera::alarme_sonore $exptime

      #--- Appel du timer
      if { $exptime > "1" } {
         ::camera::dispTime_2 $camera $This.status.lab "::AcqFC::Avancement_pose"
      } else {
         if { $exptime != "0" } {
            ::AcqFC::Avancement_pose "1"
         }
      }

      #--- Chargement de l'image precedente (si telecharge_mode = 3 et si mode = serie, continu, continu 1 ou continu 2)         
      if { $panneau(AcqFC,telecharge_mode) == "3" && $panneau(AcqFC,mode) >= "1" && $panneau(AcqFC,mode) <= "5" } {
         after 10 {
            set result [ catch { cam$::audace(camNo) loadlastimage } msg ]
            if { $result == "1" } {
               ::console::disp "::AcqFC::acq loadlastimage $msg \n"
            } else { 
               ::console::disp "::AcqFC::acq loadlastimage OK \n"
            }
         }
      }

      #--- Attente de la fin de la pose
      vwait status_$camera

      #--- Je retablis le choix du fonctionnement de l'obturateur
      if { $exptime == "0" } {
         switch -exact -- $panneau(AcqFC,obt) {
            0  {
               $camera shutter "opened"
            }
            1  {
               $camera shutter "closed"
            }
            2  {
               $camera shutter "synchro"
            }
         }
      }

      #--- Je desactive le bouton "STOP"
      $This.go_stop.but configure -state disabled

      #--- Affichage du status
      $This.status.lab configure -text ""
      update

      #--- Retournement de l'image
      set cam $conf(camera)
      if { $conf($cam,mirx) == "1" } {
        $buffer mirrorx
      }
      if { $conf($cam,miry) == "1" } {
         $buffer mirrory
      }
      #--- Visualisation de l'image
      image delete image0
      image create photo image0
      ::audace::autovisu visu$audace(visuNo)

      #--- Effacement de la barre de progression quand la pose est terminee
      destroy $audace(base).progress

      wm title $audace(base) "$caption(acqfc,acquisition) $exptime s"
   }
#***** Fin de la procedure de lancement d'acquisition **********

#***** Procedure d'apercu en mode video ************************
   proc startVideoPreview { } {
      global audace
      global conf
      global panneau
      global caption

      if { [ ::cam::list ] == "" } {
         ::confCam::run 
         tkwait window $audace(base).confCam
         #--- Je decoche la checkbox
         set panneau(AcqFC,showvideopreview) "0"
         #--- Je decoche le fenetrage et l'autoguidage
         if { $panneau(AcqFC,fenetre) == "1" } {
            set panneau(AcqFC,fenetre) "0"
            ::AcqFC::optionWindowedFenster
         }
         #--- J'arrete l'autoguidage s'il est actif
         if { $panneau(AcqFC,autoguidage) == "1" } {
            set panneau(AcqFC,autoguidage) "0"
            ::AcqFC::optionGuidingFenster
         }
         #---
         return 1
      } elseif { ( $conf(camera) != "webcam" ) && ( $conf(camera) != "apn" ) } {
         tk_messageBox -title $caption(acqfc,pb) -type ok \
            -message $caption(acqfc,no_video_mode)
         #--- Je decoche la checkbox
         set panneau(AcqFC,showvideopreview) "0"
         #--- Je decoche le fenetrage et l'autoguidage
         if { $panneau(AcqFC,fenetre) == "1" } {
            set panneau(AcqFC,fenetre) "0"
            ::AcqFC::optionWindowedFenster
         }
         #--- J'arrete l'autoguidage s'il est actif
         if { $panneau(AcqFC,autoguidage) == "1" } {
            set panneau(AcqFC,autoguidage) "0"
            ::AcqFC::optionGuidingFenster
         }
         #---
         return 1
      }

      #--- Je supprime l'image precedente
      image delete image0   
      buf$audace(bufNo) clear
      #--- Je cree une image de type video
      image create video image0       
      #--- Je connecte la sortie de la camera a l'image            
      set result [ catch { cam$audace(camNo) startvideoview 0 } msg ]
      if { $result == "1" } {
         tk_messageBox -title $caption(acqfc,pb) -type ok \
            -message "$caption(acqfc,error) $msg"
         #--- Je decoche la checkbox
         set panneau(AcqFC,showvideopreview) "0"
         #--- Je decoche le fenetrage et l'autoguidage
         if { $panneau(AcqFC,fenetre) == "1" } {
            set panneau(AcqFC,fenetre) "0"
            ::AcqFC::optionWindowedFenster
         }
         #--- J'arrete l'autoguidage s'il est actif
         if { $panneau(AcqFC,autoguidage) == "1" } {
            set panneau(AcqFC,autoguidage) "0"
            ::AcqFC::optionGuidingFenster
         }
         #---
         return 1
      } 
      #--- Je positionne le zoom
      image0 configure -scale $conf(visu_zoom)
      #--- Je positionne les scrollbars
      set audace(picture,w) [expr [lindex [cam$audace(camNo) nbpix ] 0] * $conf(visu_zoom) ]
      set audace(picture,h) [expr [lindex [cam$audace(camNo) nbpix ] 1] * $conf(visu_zoom) ]
      $audace(hCanvas) configure -scrollregion [list 0 0 $audace(picture,w) $audace(picture,h) ]
      #--- Je positionne le reticule
      ::Crosshair::redrawCrosshair     
      set panneau(AcqFC,showvideopreview) "1" 
      return 0
   }
#***** Fin de la procedure d'apercu en mode video ******************

#***** Procedure fin d'apercu en mode video ************************
   proc stopVideoPreview { } {
      global audace
      global conf
      global panneau
      
      #--- J'arrete l'aquisition fenetree si elle est active
      if { $panneau(AcqFC,fenetre) == "1" } {
      #   ::AcqFC::stopVideoCrop
         set panneau(AcqFC,fenetre) "0"
         ::AcqFC::optionWindowedFenster
      }
      #--- J'arrete l'autoguidage s'il est actif
      if { $panneau(AcqFC,autoguidage) == "1" } {
         ::AcqFC::stopGuiding
         set panneau(AcqFC,autoguidage) "0"
         ::AcqFC::optionGuidingFenster
      }

      if { [ info exists audace(camNo) ] && ( ( $conf(camera) == "webcam" ) || ( $conf(camera) == "apn" ) ) } {
         #--- Arret de la visualisation video
         cam$audace(camNo) stopvideoview
         image delete image0
         #--- Je cree une image photo "normale"
         image create photo image0
         #--- Je positionne les scrollbars
         set audace(picture,w) 0
         set audace(picture,h) 0
         $audace(hCanvas) configure -scrollregion [list 0 0 $audace(picture,w) $audace(picture,h) ]
         #--- Je positionne le reticule
         ::Crosshair::redrawCrosshair
         set panneau(AcqFC,showvideopreview) "0"
      }
   }
#***** Fin de la procedure fin d'apercu en mode video **************

#***** Procedure d'affichage d'une barre de progression ********
#--- Cette routine permet d'afficher une barre de progression qui simule l'avancement de la pose
   proc Avancement_pose { { t } } {
      variable This
      global conf audace caption panneau color

      #--- Recuperation de la position de la fenetre
      ::AcqFC::recup_position_1

      #--- Initialisation de la barre de progression
      set cpt "100"

      #--- Initialisation de la position de la fenetre
      if { ! [ info exists conf(acqfc,avancement,position) ] } { set conf(acqfc,avancement,position) "+120+315" }

      #---
      if { [ winfo exists $audace(base).progress ] != "1" } {
         toplevel $audace(base).progress
         wm transient $audace(base).progress $audace(base)
         wm resizable $audace(base).progress 0 0
         wm title $audace(base).progress "$caption(acqfc,en_cours)"
         wm geometry $audace(base).progress $conf(acqfc,avancement,position)

         #--- Cree le widget et le label du temps ecoule
         label $audace(base).progress.lab_status -text "" -font $audace(font,arial_12_b) -justify center
         uplevel #0 { pack $audace(base).progress.lab_status -side top -fill x -expand true -pady 5 }

         #---
         if { $panneau(AcqFC,attente_pose) == "0" } {
            if { $panneau(AcqFC,demande_arret) == "1" && $panneau(AcqFC,mode) != "2" && $panneau(AcqFC,mode) != "4" } {
               $audace(base).progress.lab_status configure -text $caption(acqfc,lect)
            } else {
               if { $t <= "0" } {
                  destroy $audace(base).progress
               } elseif { $t > "1" } {
                  $audace(base).progress.lab_status configure -text "[ expr $t-1 ] $caption(acqfc,sec) /\
                     [ format "%d" [ expr int( [ cam$audace(camNo) exptime ] ) ] ] $caption(acqfc,sec)"
                  set cpt [ expr ( $t-1 ) * 100 / [ expr int( [ cam$audace(camNo) exptime ] ) ] ]
                  set cpt [ expr 100 - $cpt ]
               } else {
                  $audace(base).progress.lab_status configure -text "$caption(acqfc,lect)"
              }
            }
         } else {
            if { $panneau(AcqFC,demande_arret) == "0" } {
               if { $t < "0" } {
                  destroy $audace(base).progress
               } else {
                  if { $panneau(AcqFC,mode) == "4" } {
                     $audace(base).progress.lab_status configure -text "$caption(acqfc,attente) [ expr $t + 1 ]\
                        $caption(acqfc,sec) / $panneau(AcqFC,intervalle_1) $caption(acqfc,sec)"
                     set cpt [expr $t*100 / $panneau(AcqFC,intervalle_1) ]
                  } elseif { $panneau(AcqFC,mode) == "5" } {
                     $audace(base).progress.lab_status configure -text "$caption(acqfc,attente) [ expr $t + 1 ]\
                        $caption(acqfc,sec) / $panneau(AcqFC,intervalle_2) $caption(acqfc,sec)"
                     set cpt [expr $t*100 / $panneau(AcqFC,intervalle_2) ]
                  } elseif { $panneau(AcqFC,mode) == "7" } {
                     $audace(base).progress.lab_status configure -text "$caption(acqfc,attente) [ expr $t + 1 ]\
                        $caption(acqfc,sec) / $panneau(AcqFC,intervalle_video) $caption(acqfc,sec)"
                     set cpt [expr $t*100 / $panneau(AcqFC,intervalle_video) ]
                  }
                  set cpt [expr 100 - $cpt]
               }
            }
         }

         catch {
            #--- Cree le widget pour la barre de progression
            frame $audace(base).progress.cadre -width 200 -height 30 -borderwidth 2 -relief groove
            uplevel #0 { pack $audace(base).progress.cadre -in $audace(base).progress -side top \
               -anchor center -fill x -expand true -padx 8 -pady 8 }

            #--- Affiche de la barre de progression
            frame $audace(base).progress.cadre.barre_color_invariant -height 26 -bg $color(blue)
            place $audace(base).progress.cadre.barre_color_invariant -in $audace(base).progress.cadre -x 0 -y 0 \
               -relwidth [ expr $cpt / 100.0 ]
            update
         }
      } else {
         #---
         if { $panneau(AcqFC,attente_pose) == "0" } {
            if { $panneau(AcqFC,demande_arret) == "1" && $panneau(AcqFC,mode) != "2" && $panneau(AcqFC,mode) != "4" } {
               $audace(base).progress.lab_status configure -text $caption(acqfc,lect)
            } else {
               if { $t <= "0" } {
                  destroy $audace(base).progress
               } elseif { $t > "1" } {
                  $audace(base).progress.lab_status configure -text "[ expr $t-1 ] $caption(acqfc,sec) /\
                     [ format "%d" [ expr int( [ cam$audace(camNo) exptime ] ) ] ] $caption(acqfc,sec)"
                  set cpt [ expr ( $t-1 ) * 100 / [ expr int( [ cam$audace(camNo) exptime ] ) ] ]
                  set cpt [ expr 100 - $cpt ]
               } else {
                  $audace(base).progress.lab_status configure -text "$caption(acqfc,lect)"
               }
            }
         } else {
            if { $panneau(AcqFC,demande_arret) == "0" } {
               if { $t < "0" } {
                  destroy $audace(base).progress
               } else {
                  if { $panneau(AcqFC,mode) == "4" } {
                     $audace(base).progress.lab_status configure -text "$caption(acqfc,attente) [ expr $t + 1 ]\
                        $caption(acqfc,sec) / $panneau(AcqFC,intervalle_1) $caption(acqfc,sec)"
                     set cpt [expr $t*100 / $panneau(AcqFC,intervalle_1) ]
                  } elseif { $panneau(AcqFC,mode) == "5" } {
                     $audace(base).progress.lab_status configure -text "$caption(acqfc,attente) [ expr $t + 1 ]\
                        $caption(acqfc,sec) / $panneau(AcqFC,intervalle_2) $caption(acqfc,sec)"
                     set cpt [expr $t*100 / $panneau(AcqFC,intervalle_2) ]
                  } elseif { $panneau(AcqFC,mode) == "7" } {
                     $audace(base).progress.lab_status configure -text "$caption(acqfc,attente) [ expr $t + 1 ]\
                        $caption(acqfc,sec) / $panneau(AcqFC,intervalle_video) $caption(acqfc,sec)"
                     set cpt [expr $t*100 / $panneau(AcqFC,intervalle_video) ]
                  }
                  set cpt [expr 100 - $cpt]
               }
            }
         }

         catch {
            #--- Affiche de la barre de progression
            place $audace(base).progress.cadre.barre_color_invariant -in $audace(base).progress.cadre -x 0 -y 0 \
               -relwidth [ expr $cpt / 100.0 ]
            update
         }
      }

      #--- Mise a jour dynamique des couleurs
      if  [ winfo exists $audace(base).progress ] {
         if { $t > "0" } {
            #--- La nouvelle fenetre est active
            focus $audace(base).progress
         }
         ::confColor::applyColor $audace(base).progress
      }
   }
#***** Fin de la procedure d'avancement de la pose *************

#***** Procedure d'arret de l'acquisition **********************
   proc ArretImage { } {
      global audace panneau
      variable This

      #--- Positionne un indicateur de demande d'arret
      set panneau(AcqFC,demande_arret) "1"
      #--- Force la numerisation pour l'indicateur d'avancement de la pose
      if { ( $panneau(AcqFC,mode) != "2" ) && ( $panneau(AcqFC,mode) != "4" ) && ( $panneau(AcqFC,mode) != "6" ) && \
         ( $panneau(AcqFC,mode) != "7" ) } {
         ::AcqFC::Avancement_pose "1"
      }

      #--- On annule la sonnerie
      catch { after cancel $audace(after,bell,id) }
      #--- Annulation de l'alarme de fin de pose
      catch { after cancel bell }
      #--- Arret de la pose
      if { ( $panneau(AcqFC,mode) == "1" )
         || ( $panneau(AcqFC,mode) == "3" )
         || ( $panneau(AcqFC,mode) == "5" ) } {
         catch { cam$audace(camNo) stop }
         after 200
      } elseif { $panneau(AcqFC,mode) == "6" } {
         catch { cam$audace(camNo) stopvideocapture }
      } elseif { $panneau(AcqFC,mode) == "7" } {
         catch { cam$audace(camNo) stopvideocapture }
      }
   }
#***** Fin de la procedure d'arret de l'acquisition ************

#***** Procedure de sauvegarde de l'image **********************
#--- Procedure lancee par appui sur le bouton "enregistrer", uniquement dans le mode "Une image"
   proc SauveUneImage { } {
      variable This
      global panneau caption audace

      #--- Enregistrement de l'extension des fichiers
      set ext [ buf$audace(bufNo) extension ]

      #--- Test d'integrite de la requete

      #--- Verifie qu'une image est bien presente...

      #--- Verifier qu'il y a bien un nom de fichier
      if { $panneau(AcqFC,nom_image) == "" } {
         tk_messageBox -title $caption(acqfc,pb) -type ok \
            -message $caption(acqfc,donnomfich)
         return
      }
      #--- Verifie que le nom de fichier n'a pas d'espace
      if { [ llength $panneau(AcqFC,nom_image) ] > "1" } {
         tk_messageBox -title $caption(acqfc,pb) -type ok \
            -message $caption(acqfc,nomblanc)
         return
      }
      #--- Verifie que le nom de fichier ne contient pas de caracteres interdits
      if { [ AcqFC::TestChaine $panneau(AcqFC,nom_image) ] == "0" } {
         tk_messageBox -title $caption(acqfc,pb) -type ok \
            -message $caption(acqfc,mauvcar)
         return
      }
      #--- Si la case index est cochee, verifier qu'il y a bien un index
      if { $panneau(AcqFC,indexer) == "1" } {
         #--- Verifie que l'index existe
         if { $panneau(AcqFC,index) == "" } {
            tk_messageBox -title $caption(acqfc,pb) -type ok \
                  -message $caption(acqfc,saisind)
            return
         }
         #--- Verifier que l'index est bien un nombre entier
         if { [ AcqFC::TestEntier $panneau(AcqFC,index) ] == "0" } {
            tk_messageBox -title $caption(acqfc,pb) -type ok \
               -message $caption(acqfc,indinv)
            return
         }
      }

      #--- Affichage du status
      $This.status.lab configure -text $caption(acqfc,enreg)
      update

      #--- Generation du nom de fichier
      set nom $panneau(AcqFC,nom_image)
      #--- Pour eviter un nom de fichier qui commence par un blanc
      set nom [lindex $nom 0]
      if { $panneau(AcqFC,indexer) == "1" } {
         append nom $panneau(AcqFC,index)
      }

      #--- Verifie que le nom du fichier n'existe pas deja...
      set nom1 "$nom"
      append nom1 $ext
      if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
         #--- Dans ce cas, le fichier existe deja...
         set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
            -message $caption(acqfc,fichdeja)]
         if { $confirmation == "no" } {
            return
         }
      }

      #--- Incremente l'index
      if { $panneau(AcqFC,indexer) == "1" } {
         incr panneau(AcqFC,index)
      }

      #--- Indication de l'enregistrement dans le fichier log
      set heure $audace(tu,format,hmsint)
      Message consolog $caption(acqfc,demsauv) $heure
      Message consolog $caption(acqfc,imsauvnom) $nom $ext

      #--- Sauvegarde de l'image
      saveima $nom

      #--- Effacement du status
      $This.status.lab configure -text ""
   }
#***** Fin de la procedure de sauvegarde de l'image *************

#***** Procedure d'affichage des messages ************************
#--- Cette procedure est recopiee de Methking.tcl, elle permet l'affichage de differents
#--- messages (dans la console, le fichier log, etc.)
   proc Message { niveau args } {
      global caption
      global conf

      switch -exact -- $niveau {
         console {
            ::console::disp [eval [concat {format} $args]]
            update idletasks
         }
         log {
            set temps [clock format [clock seconds] -format %H:%M:%S]
            append temps " "
            catch { puts -nonewline $::AcqFC::log_id [eval [concat {format} $args]] }
            #--- Force l'ecriture immediate sur le disque
            flush $::AcqFC::log_id
         }
         consolog {
            if { [ info exists conf(messages_console_acqfc) ] == "0" } {
               set conf(messages_console_acqfc) "1"
            }
            if { $conf(messages_console_acqfc) == "1" } {
               ::console::disp [eval [concat {format} $args]]
               update idletasks
            }
            set temps [clock format [clock seconds] -format %H:%M:%S]
            append temps " "
            catch { puts -nonewline $::AcqFC::log_id [eval [concat {format} $args]] }
            #--- Force l'ecriture immediate sur le disque
            flush $::AcqFC::log_id
            }
         default {
            set b [ list "%s\n" $caption(acqfc,pbmesserr) ]
            ::console::disp [ eval [ concat {format} $b ] ]
            update idletasks
         }
      }
   }
#***** Fin de la procedure d'affichage des messages ***************

#***** Bouton pour le decalage du telescope ***********************
# cmdShiftConfig{}
#    affiche la fenetre de configuration pour modifier les parametres 
#    de deplacement du telescope entre 2 acquisitions d'une serie         
#------------------------------------------------------------------
   proc cmdShiftConfig { } {
      global audace

      set shiftConfig [ ::DlgShift::run "$audace(base).dlgShift" ]
      return
   }
#***** Fin du bouton pour le decalage du telescope *****************

#***** Fenetre de configuration du telechargement d'images APN *****
   proc Telecharge_image { } {
      global conf
      global audace
      global caption
      global panneau

      #--- Initialisation de la position de la fenetre
      if { ! [ info exists conf(acqfc,telecharge,position) ] } { set conf(acqfc,telecharge,position) "+120+140" }

      #---
      if { [ winfo exists $audace(base).telecharge_image ] } {
         wm withdraw $audace(base).telecharge_image
         wm deiconify $audace(base).telecharge_image
         focus $audace(base).telecharge_image
         return
      }

      #--- Creation de la fenetre
      toplevel $audace(base).telecharge_image
      wm transient $audace(base).telecharge_image $audace(base)
      wm resizable $audace(base).telecharge_image 0 0
      wm title $audace(base).telecharge_image "$caption(acqfc,telecharger)"
      wm geometry $audace(base).telecharge_image $conf(acqfc,telecharge,position)
      wm protocol $audace(base).telecharge_image WM_DELETE_WINDOW {
         ::AcqFC::recup_position_telecharge
      }

      radiobutton $audace(base).telecharge_image.rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(acqfc,pas_telecharger)" -value 1 -variable panneau(AcqFC,telecharge_mode) -state normal \
         -command ::AcqFC::ChangerSelectionTelechargementAPN
      uplevel #0 { pack $audace(base).telecharge_image.rad1 -anchor w -expand 1 -fill none \
         -side top -padx 30 -pady 5 }
      radiobutton $audace(base).telecharge_image.rad2 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(acqfc,immediat)" -value 2 -variable panneau(AcqFC,telecharge_mode) -state normal \
         -command ::AcqFC::ChangerSelectionTelechargementAPN
      uplevel #0 { pack $audace(base).telecharge_image.rad2 -anchor w -expand 1 -fill none \
         -side top -padx 30 -pady 5 }
      radiobutton $audace(base).telecharge_image.rad3 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(acqfc,acq_suivante)" -value 3 -variable panneau(AcqFC,telecharge_mode) -state normal \
         -command ::AcqFC::ChangerSelectionTelechargementAPN
      uplevel #0 { pack $audace(base).telecharge_image.rad3 -anchor w -expand 1 -fill none \
         -side top -padx 30 -pady 5 }

      #--- New message window is on
      focus $audace(base).telecharge_image

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).telecharge_image
   }
#***** Fin fenetre de configuration du telechargement d'images APN *******************

#***** Gestion du telechargement d'images APN ****************************************
   proc ChangerSelectionTelechargementAPN { }  {
      global audace
      global panneau

      catch {
         switch -exact -- $panneau(AcqFC,telecharge_mode) {
            1  {
               #--- Ne pas telecharger
               cam$audace(camNo) autoload 0
            }
            2  {
               #--- Telechargement immediat
               cam$audace(camNo) autoload 1
            }
            3  {
               #--- Telechargement pendant la pose suivante
               cam$audace(camNo) autoload 0
            }
         }
         ::console::disp "panneau(AcqFC,telecharge_mode)=$panneau(AcqFC,telecharge_mode) cam$audace(camNo) autoload=[cam$audace(camNo) autoload] \n"
      }
   }        
#***** Fin gestion du telechargement d'images APN ************************************

#***** Fenetre de configuration series d'images a intervalle regulier en continu *****
   proc Intervalle_continu_1 { } {
      global conf
      global audace
      global caption
      global panneau

      set panneau(AcqFC,intervalle)            "....."
      set panneau(AcqFC,simulation_deja_faite) "0"

      ::AcqFC::recup_position

      #--- Initialisation de la position de la fenetre
      if { ! [ info exists conf(acqfc,continu1,position) ] } { set conf(acqfc,continu1,position) "+120+260" }

      #--- Creation de la fenetre Continu 1
      toplevel $audace(base).intervalle_continu_1
      wm transient $audace(base).intervalle_continu_1 $audace(base)
      wm resizable $audace(base).intervalle_continu_1 0 0
      wm title $audace(base).intervalle_continu_1 "$caption(acqfc,continu_1)"
      wm geometry $audace(base).intervalle_continu_1 $conf(acqfc,continu1,position)
      wm protocol $audace(base).intervalle_continu_1 WM_DELETE_WINDOW {
         set panneau(AcqFC,mode_en_cours) "$caption(acqfc,continu)"
         ::AcqFC::ChangeMode
      }

      #--- Create the message
      label $audace(base).intervalle_continu_1.lab1 -text "$caption(acqfc,titre_1)" -font $audace(font,arial_10_b)
      uplevel #0 { pack $audace(base).intervalle_continu_1.lab1 -padx 20 -pady 5 }
      frame $audace(base).intervalle_continu_1.a
         label $audace(base).intervalle_continu_1.a.lab2 -text "$caption(acqfc,intervalle_1)"
         uplevel #0 { pack $audace(base).intervalle_continu_1.a.lab2 -anchor center -expand 1 -fill none -side left \
            -padx 10 -pady 5 }
         entry $audace(base).intervalle_continu_1.a.ent1 -width 5 -font $audace(font,arial_10_b) -relief groove \
            -textvariable panneau(AcqFC,intervalle_1) -justify center
         uplevel #0 { pack $audace(base).intervalle_continu_1.a.ent1 -anchor center -expand 1 -fill none -side left \
            -padx 10 }
      uplevel #0 { pack $audace(base).intervalle_continu_1.a -padx 10 -pady 5 }
      frame $audace(base).intervalle_continu_1.b
         checkbutton $audace(base).intervalle_continu_1.b.check_simu -text "$caption(acqfc,simu_deja_faite)" \
            -variable panneau(AcqFC,simulation_deja_faite) -command {
               if { $panneau(AcqFC,simulation_deja_faite) == "1" } {
                  set panneau(AcqFC,intervalle) "xxx"
                  set simu1 "$caption(acqfc,int_mini_serie) $panneau(AcqFC,intervalle) $caption(acqfc,sec)"
                  $audace(base).intervalle_continu_1.lab3 configure -text "$simu1"
                  focus $audace(base).intervalle_continu_1.a.ent1
               } else {
                  set panneau(AcqFC,intervalle) "....."
                  set simu1 "$caption(acqfc,int_mini_serie) $panneau(AcqFC,intervalle) $caption(acqfc,sec)"
                  $audace(base).intervalle_continu_1.lab3 configure -text "$simu1"
                  focus $audace(base).intervalle_continu_1.but1
               }
            }
         uplevel #0 { pack $audace(base).intervalle_continu_1.b.check_simu -anchor w -expand 1 -fill none \
            -side left -padx 10 -pady 5 }
      uplevel #0 { pack $audace(base).intervalle_continu_1.b -side bottom -anchor w -padx 10 -pady 5 }
      button $audace(base).intervalle_continu_1.but1 -text "$caption(acqfc,simulation)" \
         -command {
            set panneau(AcqFC,intervalle) "....."
            set simu1 "$caption(acqfc,int_mini_serie) $panneau(AcqFC,intervalle) $caption(acqfc,sec)"
            $audace(base).intervalle_continu_1.lab3 configure -text "$simu1"
            set panneau(AcqFC,simulation) "1" ; set panneau(AcqFC,mode) "2"
            set index $panneau(AcqFC,index) ; set nombre $panneau(AcqFC,nb_images)
            ::AcqFC::GoStop
            set panneau(AcqFC,simulation) "0" ; set panneau(AcqFC,mode) "4"
            set panneau(AcqFC,index) $index ; set panneau(AcqFC,nb_images) $nombre
            set simu1 "$caption(acqfc,int_mini_serie) $panneau(AcqFC,intervalle) $caption(acqfc,sec)"
            $audace(base).intervalle_continu_1.lab3 configure -text "$simu1"
         }
      uplevel #0 { pack $audace(base).intervalle_continu_1.but1 -anchor center -expand 1 -fill none -side left \
        -ipadx 5 -ipady 3 -padx 10 -pady 5 }
      set simu1 "$caption(acqfc,int_mini_serie) $panneau(AcqFC,intervalle) $caption(acqfc,sec)"
      label $audace(base).intervalle_continu_1.lab3 -text "$simu1"
      uplevel #0 { pack $audace(base).intervalle_continu_1.lab3 -anchor center -expand 1 -fill none -side left -padx 10 }

      #--- New message window is on
      focus $audace(base).intervalle_continu_1

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).intervalle_continu_1
   }
#***** Fin fenetre de configuration series d'images a intervalle regulier en continu *****

#***** Fenetre de configuration images a intervalle regulier en continu ******************
   proc Intervalle_continu_2 { } {
      global conf
      global audace
      global caption
      global panneau

      set panneau(AcqFC,intervalle) "....."

      ::AcqFC::recup_position

      #--- Initialisation de la position de la fenetre
      if { ! [ info exists conf(acqfc,continu2,position) ] } { set conf(acqfc,continu2,position) "+120+260" }

      #--- Creation de la fenetre Continu 2
      toplevel $audace(base).intervalle_continu_2
      wm transient $audace(base).intervalle_continu_2 $audace(base)
      wm resizable $audace(base).intervalle_continu_2 0 0
      wm title $audace(base).intervalle_continu_2 "$caption(acqfc,continu_2)"
      wm geometry $audace(base).intervalle_continu_2 $conf(acqfc,continu2,position)
      wm protocol $audace(base).intervalle_continu_2 WM_DELETE_WINDOW {
         set panneau(AcqFC,mode_en_cours) "$caption(acqfc,continu)"
         ::AcqFC::ChangeMode
      }

      #--- Create the message
      label $audace(base).intervalle_continu_2.lab1 -text "$caption(acqfc,titre_2)" -font $audace(font,arial_10_b)
      uplevel #0 { pack $audace(base).intervalle_continu_2.lab1 -padx 10 -pady 5 }
      frame $audace(base).intervalle_continu_2.a
         label $audace(base).intervalle_continu_2.a.lab2 -text "$caption(acqfc,intervalle_2)"
         uplevel #0 { pack $audace(base).intervalle_continu_2.a.lab2 -anchor center -expand 1 -fill none -side left \
            -padx 10 -pady 5 }
         entry $audace(base).intervalle_continu_2.a.ent1 -width 5 -font $audace(font,arial_10_b) -relief groove \
            -textvariable panneau(AcqFC,intervalle_2) -justify center
         uplevel #0 { pack $audace(base).intervalle_continu_2.a.ent1 -anchor center -expand 1 -fill none -side left \
            -padx 10 }
      uplevel #0 { pack $audace(base).intervalle_continu_2.a -padx 10 -pady 5 }
      frame $audace(base).intervalle_continu_2.b
         checkbutton $audace(base).intervalle_continu_2.b.check_simu -text "$caption(acqfc,simu_deja_faite)" \
            -variable panneau(AcqFC,simulation_deja_faite) -command {
               if { $panneau(AcqFC,simulation_deja_faite) == "1" } {
                  set panneau(AcqFC,intervalle) "xxx"
                  set simu2 "$caption(acqfc,int_mini_image) $panneau(AcqFC,intervalle) $caption(acqfc,sec)"
                  $audace(base).intervalle_continu_2.lab3 configure -text "$simu2"
                  focus $audace(base).intervalle_continu_2.a.ent1
               } else {
                  set panneau(AcqFC,intervalle) "....."
                  set simu2 "$caption(acqfc,int_mini_image) $panneau(AcqFC,intervalle) $caption(acqfc,sec)"
                  $audace(base).intervalle_continu_2.lab3 configure -text "$simu2"
                  focus $audace(base).intervalle_continu_2.but1
               }
            }
         uplevel #0 { pack $audace(base).intervalle_continu_2.b.check_simu -anchor w -expand 1 -fill none \
            -side left -padx 10 -pady 5 }
      uplevel #0 { pack $audace(base).intervalle_continu_2.b -side bottom -anchor w -padx 10 -pady 5 }
      button $audace(base).intervalle_continu_2.but1 -text "$caption(acqfc,simulation)" \
         -command {
            set panneau(AcqFC,intervalle) "....."
            set simu2 "$caption(acqfc,int_mini_image) $panneau(AcqFC,intervalle) $caption(acqfc,sec)"
            $audace(base).intervalle_continu_2.lab3 configure -text "$simu2"
            set panneau(AcqFC,simulation) "1" ; set panneau(AcqFC,mode) "2"
            set index $panneau(AcqFC,index)
            set panneau(AcqFC,nb_images) "1"
            ::AcqFC::GoStop
            set panneau(AcqFC,simulation) "0" ; set panneau(AcqFC,mode) "5"
            set panneau(AcqFC,index) $index
            set simu2 "$caption(acqfc,int_mini_image) $panneau(AcqFC,intervalle) $caption(acqfc,sec)"
            $audace(base).intervalle_continu_2.lab3 configure -text "$simu2"
         }
      uplevel #0 { pack $audace(base).intervalle_continu_2.but1 -anchor center -expand 1 -fill none -side left \
         -ipadx 5 -ipady 3 -padx 10 -pady 5 }
      set simu2 "$caption(acqfc,int_mini_image) $panneau(AcqFC,intervalle) $caption(acqfc,sec)"
      label $audace(base).intervalle_continu_2.lab3 -text "$simu2"
      uplevel #0 { pack $audace(base).intervalle_continu_2.lab3 -anchor center -expand 1 -fill none -side left -padx 10 }

      #--- New message window is on
      focus $audace(base).intervalle_continu_2

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).intervalle_continu_2
   }
#***** Fin fenetre de configuration images a intervalle regulier en continu **************

#***** Fenetre de configuration video ****************************************************
   proc selectVideoMode { } {
      global conf
      global audace
      global caption
      global panneau

      ::AcqFC::recup_position

      #--- Initialisation de la position de la fenetre
      if { ! [ info exists conf(acqfc,video,position) ] } { set conf(acqfc,video,position) "+120+260" }

      #--- Creation de la fenetre Video
      toplevel $audace(base).status_video
      wm transient $audace(base).status_video $audace(base)
      wm resizable $audace(base).status_video 1 1
      wm title $audace(base).status_video "$caption(acqfc,capture_video)"
      wm geometry $audace(base).status_video $conf(acqfc,video,position)
      wm protocol $audace(base).status_video WM_DELETE_WINDOW {
         if { $panneau(AcqFC,mode) == "7" } {
            set panneau(AcqFC,mode_en_cours) "$caption(acqfc,video)"
            ::AcqFC::ChangeMode
         } elseif { $panneau(AcqFC,mode) == "6" } {
            set panneau(AcqFC,mode_en_cours) "$caption(acqfc,uneimage)"
            ::AcqFC::ChangeMode
         }
      }

      #--- Trame de l'intervalle entre les video
      if { $panneau(AcqFC,mode) == "7" } {
         label $audace(base).status_video.lab1 -text "$caption(acqfc,titre_3)" -font $audace(font,arial_10_b)
         uplevel #0 { pack $audace(base).status_video.lab1 -padx 10 -pady 5 }
         frame $audace(base).status_video.a
            label $audace(base).status_video.a.lab2 -text "$caption(acqfc,intervalle_video)"
            uplevel #0 { pack $audace(base).status_video.a.lab2 -anchor center -expand 1 -fill none -side left \
               -padx 10 -pady 5 }
            entry $audace(base).status_video.a.ent1 -width 5 -font $audace(font,arial_10_b) -relief groove \
               -textvariable panneau(AcqFC,intervalle_video) -justify center
            uplevel #0 { pack $audace(base).status_video.a.ent1 -anchor center -expand 1 -fill none -side left -padx 10 }
         uplevel #0 { pack $audace(base).status_video.a -padx 10 -pady 5 }
      }

      #--- Trame de la duree du film
      frame $audace(base).status_video.pose -borderwidth 2
         menubutton $audace(base).status_video.pose.but -text $caption(acqfc,lg_film) \
            -menu $audace(base).status_video.pose.but.menu -relief raised
         uplevel #0 { pack $audace(base).status_video.pose.but -side left -ipadx 5 -ipady 0 }
         set m [ menu $audace(base).status_video.pose.but.menu -tearoff 0 ]
         foreach temps $panneau(AcqFC,temps_pose) {
            $m add radiobutton -label "$temps" \
               -indicatoron "1" \
               -value "$temps" \
               -variable panneau(AcqFC,lg_film) \
               -command { }
         }
         entry $audace(base).status_video.pose.entr -width 5 -font $audace(font,arial_10_b) -relief groove \
           -textvariable panneau(AcqFC,lg_film) -justify center
         uplevel #0 { pack $audace(base).status_video.pose.entr -side left -fill x -expand 0 }
         label $audace(base).status_video.pose.lab -text $caption(acqfc,sec)
         uplevel #0 { pack $audace(base).status_video.pose.lab -side left -anchor w -fill x -pady 0 -ipadx 5 -ipady 0 }
      uplevel #0 { pack $audace(base).status_video.pose -anchor center -side top -pady 0 -ipadx 0 -ipady 0 -expand true }

      #--- Nombre d'images/seconde
      frame $audace(base).status_video.rate -borderwidth 2
         menubutton $audace(base).status_video.rate.cb -text $caption(acqfc,rate) \
            -menu $audace(base).status_video.rate.cb.menu -relief raised
         uplevel #0 { pack $audace(base).status_video.rate.cb -side left -ipadx 5 -ipady 0 }
         set m [ menu $audace(base).status_video.rate.cb.menu -tearoff 0 ]
         foreach rate $panneau(AcqFC,ratelist) {
            $m add radiobutton -label "$rate" \
               -indicatoron "1" \
               -value "$rate" \
               -variable panneau(AcqFC,rate) \
               -command { }
         }
         entry $audace(base).status_video.rate.entr -width 5 -font $audace(font,arial_10_b) -relief groove \
            -textvariable panneau(AcqFC,rate) -justify center
         uplevel #0 { pack $audace(base).status_video.rate.entr -side left -fill x -expand 0 }
         label $audace(base).status_video.rate.unite -text $caption(acqfc,rate_unite)
         uplevel #0 { pack $audace(base).status_video.rate.unite -anchor center -expand 0 -fill x -side left \
            -ipadx 5 -ipady 0 }
      uplevel #0 { pack $audace(base).status_video.rate -anchor center -side top -pady 0 -ipadx 0 -ipady 0 -expand true }

      #--- Label affichant le status de la camera en mode video
      frame $audace(base).status_video.status -borderwidth 2 -relief ridge
         label $audace(base).status_video.status.label -textvariable panneau(AcqFC,status) -font $audace(font,arial_8_b) \
            -wraplength 150 -height 4 -pady 0
         uplevel #0 { pack $audace(base).status_video.status.label -anchor center -expand 0 -fill x -side top }
      uplevel #0 { pack $audace(base).status_video.status -anchor center -fill y -pady 0 -ipadx 5 -ipady 0 }

      #--- Frame pour l'acquisition fenetree
      frame $audace(base).status_video.fenetrer -borderwidth 2 -relief ridge

         frame $audace(base).status_video.fenetrer.check -borderwidth 0 -relief ridge
            checkbutton $audace(base).status_video.fenetrer.check.case -pady 0 \
               -text "$caption(acqfc,acquisition_fenetree)" -variable panneau(AcqFC,fenetre) \
               -command {
                  if { $panneau(AcqFC,fenetre) == "1" } {
                     ::AcqFC::optionWindowedFenster
                     ::AcqFC::startWindowedFenster
                  } else {
                     ::AcqFC::optionWindowedFenster
                     ::AcqFC::stopWindowedFenster
                  }
               }
            uplevel #0 { pack $audace(base).status_video.fenetrer.check.case -anchor w -expand 0 -side top }
         uplevel #0 { pack $audace(base).status_video.fenetrer.check -anchor w -expand 0 -fill x -side top }

         label $audace(base).status_video.fenetrer.check.msg -text "$caption(acqfc,acq_fen_msg)"
        # uplevel #0 { pack $audace(base).status_video.fenetrer.check.msg -anchor w -expand 0 -side top -ipadx 15 -ipady 0 }
         frame $audace(base).status_video.fenetrer.left1 -borderwidth 0 -relief ridge
            label $audace(base).status_video.fenetrer.left1.largeur -text "$caption(acqfc,largeur_hauteur)"
            uplevel #0 { pack $audace(base).status_video.fenetrer.left1.largeur -anchor w -expand 0 \
               -side top -ipadx 15 -ipady 0 }
            label $audace(base).status_video.fenetrer.left1.x1 -text "$caption(acqfc,coord_x1_y1)"
            uplevel #0 { pack $audace(base).status_video.fenetrer.left1.x1 -anchor w -expand 0 \
               -side top -ipadx 15 -ipady 0 }
            label $audace(base).status_video.fenetrer.left1.x2 -text "$caption(acqfc,coord_x2_y2)"
            uplevel #0 { pack $audace(base).status_video.fenetrer.left1.x2 -anchor w -expand 0 \
               -side top -ipadx 15 -ipady 0 }
        # uplevel #0 { pack $audace(base).status_video.fenetrer.left1 -anchor w -expand 0 -fill x -side left }
         frame $audace(base).status_video.fenetrer.right -borderwidth 0 -relief ridge
            label $audace(base).status_video.fenetrer.right.hauteur -textvariable panneau(AcqFC,largeur)
            uplevel #0 { pack $audace(base).status_video.fenetrer.right.hauteur -anchor center -expand 0 -fill x \
               -side top -ipadx 10 -ipady 0 }
            label $audace(base).status_video.fenetrer.right.y1 -textvariable panneau(AcqFC,x1)
            uplevel #0 { pack $audace(base).status_video.fenetrer.right.y1 -anchor center -expand 0 -fill x \
               -side top -ipadx 10 -ipady 0 }
            label $audace(base).status_video.fenetrer.right.y2 -textvariable panneau(AcqFC,x1)
            uplevel #0 { pack $audace(base).status_video.fenetrer.right.y2 -anchor center -expand 0 -fill x \
               -side top -ipadx 10 -ipady 0 }
        # uplevel #0 { pack $audace(base).status_video.fenetrer.right -anchor w -expand 0 -fill x -side left }
         frame $audace(base).status_video.fenetrer.right1 -borderwidth 0 -relief ridge
            label $audace(base).status_video.fenetrer.right1.hauteur -textvariable panneau(AcqFC,hauteur)
            uplevel #0 { pack $audace(base).status_video.fenetrer.right1.hauteur -anchor center -expand 0 -fill x \
               -side top -ipadx 10 -ipady 0 }
            label $audace(base).status_video.fenetrer.right1.y1 -textvariable panneau(AcqFC,x2)
            uplevel #0 { pack $audace(base).status_video.fenetrer.right1.y1 -anchor center -expand 0 -fill x \
               -side top -ipadx 10 -ipady 0 }
            label $audace(base).status_video.fenetrer.right1.y2 -textvariable panneau(AcqFC,x2)
            uplevel #0 { pack $audace(base).status_video.fenetrer.right1.y2 -anchor center -expand 0 -fill x \
               -side top -ipadx 10 -ipady 0 }
        # uplevel #0 { pack $audace(base).status_video.fenetrer.right1 -anchor w -expand 0 -fill x -side left }

      uplevel #0 { pack $audace(base).status_video.fenetrer -anchor center -fill both -pady 0 -ipadx 5 -ipady 0 }

     # #--- Frame pour l'autoguidage
     # if { $panneau(AcqFC,mode) != "7" } {
     #    frame $audace(base).status_video.autoguidage -borderwidth 2 -relief ridge

     #       frame $audace(base).status_video.autoguidage.check -borderwidth 0 -relief ridge
     #          checkbutton $audace(base).status_video.autoguidage.check.case -pady 0 -text "$caption(acqfc,autoguidage)" \
     #             -variable panneau(AcqFC,autoguidage) \
     #             -command {
     #                if { $panneau(AcqFC,autoguidage) == "1" } {
     #                   ::AcqFC::optionGuidingFenster
     #                   ::AcqFC::startGuiding
     #                } else {
     #                   ::AcqFC::optionGuidingFenster
     #                   ::AcqFC::stopGuiding
     #                }
     #             }
     #          uplevel #0 { pack $audace(base).status_video.autoguidage.check.case -anchor w -expand 0 -fill x -side left }
     #       uplevel #0 { pack $audace(base).status_video.autoguidage.check -anchor w -expand 0 -fill x -side top }

     #       frame $audace(base).status_video.autoguidage.check1 -borderwidth 0 -relief ridge
     #          checkbutton $audace(base).status_video.autoguidage.check1.moteur_ok -padx 15 -pady 0 \
     #             -text "$caption(acqfc,ctrl_moteurs)" -variable panneau(AcqFC,moteur_ok) -command {  }
     #          uplevel #0 { pack $audace(base).status_video.autoguidage.check1.moteur_ok -anchor w -expand 0 -side top }
     #          button $audace(base).status_video.autoguidage.check1.but_config -text "$caption(acqfc,config_guidage)" \
     #             -command { ::AcqFC::run_config_autoguidage }
     #          uplevel #0 { pack $audace(base).status_video.autoguidage.check1.but_config -anchor center -expand 1 \
     #             -fill none -side left -ipadx 5 -ipady 3 -padx 10 -pady 5 }
     #      # uplevel #0 { pack $audace(base).status_video.autoguidage.check1 -anchor w -expand 0 -fill x -side bottom }
     #       frame $audace(base).status_video.autoguidage.left -borderwidth 0 -relief ridge
     #          label $audace(base).status_video.autoguidage.left.label_x0 -text "$caption(acqfc,coord_origine)"
     #          uplevel #0 { pack $audace(base).status_video.autoguidage.left.label_x0 -anchor w -expand 0 \
     #             -side top -ipadx 15 -ipady 0 }
     #          label $audace(base).status_video.autoguidage.left.label_x -text "$caption(acqfc,coord_etoile)"
     #          uplevel #0 { pack $audace(base).status_video.autoguidage.left.label_x -anchor w -expand 0 \
     #             -side top -ipadx 15 -ipady 0 }
     #          label $audace(base).status_video.autoguidage.left.label_ecart \
     #             -text "$caption(acqfc,ecart_origine_etoile)"
     #          uplevel #0 { pack $audace(base).status_video.autoguidage.left.label_ecart -anchor w -expand 0 \
     #             -side top -ipadx 15 -ipady 0 }
     #      # uplevel #0 { pack $audace(base).status_video.autoguidage.left -anchor w -expand 0 -fill x -side left }
     #       frame $audace(base).status_video.autoguidage.right -borderwidth 0 -relief ridge
     #          label $audace(base).status_video.autoguidage.right.x0 -textvariable panneau(AcqFC,x0)
     #          uplevel #0 { pack $audace(base).status_video.autoguidage.right.x0 -anchor w -expand 0 -fill x \
     #             -side top -ipadx 10 -ipady 0 }
     #          label $audace(base).status_video.autoguidage.right.x -textvariable panneau(AcqFC,x)
     #          uplevel #0 { pack $audace(base).status_video.autoguidage.right.x -anchor w -expand 0 -fill x \
     #             -side top -ipadx 10 -ipady 0 }
     #          label $audace(base).status_video.autoguidage.right.ecart_x -textvariable panneau(AcqFC,ecart_x)
     #          uplevel #0 { pack $audace(base).status_video.autoguidage.right.ecart_x -anchor w -expand 0 -fill x \
     #             -side top -ipadx 10 -ipady 0 }
     #      # uplevel #0 { pack $audace(base).status_video.autoguidage.right -anchor w -expand 0 -fill x -side left }
     #       frame $audace(base).status_video.autoguidage.right1 -borderwidth 0 -relief ridge
     #          label $audace(base).status_video.autoguidage.right1.y0 -textvariable panneau(AcqFC,y0)
     #          uplevel #0 { pack $audace(base).status_video.autoguidage.right1.y0 -anchor w -expand 0 -fill x \
     #             -side top -ipadx 10 -ipady 0 }
     #          label $audace(base).status_video.autoguidage.right1.y -textvariable panneau(AcqFC,y)
     #          uplevel #0 { pack $audace(base).status_video.autoguidage.right1.y -anchor w -expand 0 -fill x \
     #             -side top -ipadx 10 -ipady 0 }
     #          label $audace(base).status_video.autoguidage.right1.ecart_y -textvariable panneau(AcqFC,ecart_y)
     #          uplevel #0 { pack $audace(base).status_video.autoguidage.right1.ecart_y -anchor w -expand 0 -fill x \
     #             -side top -ipadx 10 -ipady 0 }
     #      # uplevel #0 { pack $audace(base).status_video.autoguidage.right1 -anchor w -expand 0 -fill x -side left }

     #    uplevel #0 { pack $audace(base).status_video.autoguidage -anchor center -fill both -pady 0 -ipadx 5 -ipady 0 }
     # }

      #--- New message window is on
      focus $audace(base).status_video

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).status_video
   }
#***** Fin fenetre de configuration video ****************************************************

#***** Procedure d'ouverture des options de fenetrage ****************************************
   proc optionWindowedFenster { } {
      global panneau

      if { $panneau(AcqFC,fenetre) == "0" } {
         #--- Sans le fenetrage
         uplevel #0 { pack forget $audace(base).status_video.fenetrer.check.msg }
         uplevel #0 { pack forget $audace(base).status_video.fenetrer.left1 }
         uplevel #0 { pack forget $audace(base).status_video.fenetrer.right }
         uplevel #0 { pack forget $audace(base).status_video.fenetrer.right1 }
      } else {
         #--- Avec le fenetrage
         uplevel #0 { pack $audace(base).status_video.fenetrer.check.msg -anchor w -expand 0 -side top -ipadx 15 -ipady 0 }
         uplevel #0 { pack $audace(base).status_video.fenetrer.left1 -anchor w -expand 0 -fill x -side left }
         uplevel #0 { pack $audace(base).status_video.fenetrer.right -anchor w -expand 0 -fill x -side left }
         uplevel #0 { pack $audace(base).status_video.fenetrer.right1 -anchor w -expand 0 -fill x -side left }
      }
   }
#***** Fin de la procedure d'ouverture des options de fenetrage ******************************

#***** Procedure d'ouverture des options de l'autoguidage ************************************
   proc optionGuidingFenster { } {
      global panneau

      if { $panneau(AcqFC,autoguidage) == "0" } {
         #--- Sans le fenetrage
         uplevel #0 { pack forget $audace(base).status_video.autoguidage.check1 }
         uplevel #0 { pack forget $audace(base).status_video.autoguidage.left }
         uplevel #0 { pack forget $audace(base).status_video.autoguidage.right }
         uplevel #0 { pack forget $audace(base).status_video.autoguidage.right1 }
      } else {
         #--- Avec le fenetrage
         uplevel #0 { pack $audace(base).status_video.autoguidage.check1 -anchor w -expand 0 -fill x -side bottom }
         uplevel #0 { pack $audace(base).status_video.autoguidage.left -anchor w -expand 0 -fill x -side left }
         uplevel #0 { pack $audace(base).status_video.autoguidage.right -anchor w -expand 0 -fill x -side left }
         uplevel #0 { pack $audace(base).status_video.autoguidage.right1 -anchor w -expand 0 -fill x -side left }
      }
   }
#***** Fin de la procedure d'ouverture des options de l'autoguidage **************************

#***** Procedure de demarrage du fenetrage video *********************************************
   proc startWindowedFenster { } {
      global audace
      global caption
      global conf
      global panneau

      #--- Active le mode preview
      if { $panneau(AcqFC,showvideopreview) == "0" } {
         set result [ ::AcqFC::startVideoPreview ]
      } else {
         set result "0"
      }
      #---
      if { $result == "0" } {
         if { [ info exists audace(camNo) ] && ( ( $conf(camera) == "webcam" ) || ( $conf(camera) == "apn" ) ) } {
           ### cam$audace(camNo) startvideoguiding
           ### setGuidingTargetSize
           ### cam$audace(camNo) setvideoguidingcallback ::AcqFC::onStartStop ::AcqFC::onChangeOrigin ::AcqFC::onChangePoint
         } elseif { [ info exists audace(camNo) ] && ( ( $conf(camera) != "webcam" ) || ( $conf(camera) != "apn" ) ) } {
            tk_messageBox -title $caption(acqfc,pb) -type ok \
               -message $caption(acqfc,no_video_mode)
            #--- Je decoche la checkbox
            set panneau(AcqFC,showvideopreview) "0"
            #--- Je decoche le fenetrage et l'autoguidage
            if { $panneau(AcqFC,fenetre) == "1" } {
               set panneau(AcqFC,fenetre) "0"
               ::AcqFC::optionWindowedFenster
            }
            #--- J'arrete l'autoguidage s'il est actif
            if { $panneau(AcqFC,autoguidage) == "1" } {
               set panneau(AcqFC,autoguidage) "0"
               ::AcqFC::optionGuidingFenster
            }
         } else {
            ::confCam::run 
            tkwait window $audace(base).confCam         
         }
      } else {
         set panneau(AcqFC,fenetre) "0"
      }
   }
#***** Fin de la procedure de demarrage du fenetrage video ***********************************

#***** Procedure d'arret du fenetrage video **************************************************
   proc stopWindowedFenster { } {
      global audace
      global conf

      if { [ info exists audace(camNo) ] && ( ( $conf(camera) == "webcam" ) || ( $conf(camera) == "apn" ) ) } {
     ### cam$::audace(camNo) stopvideoguiding
      }
   }
#***** Fin de la procedure d'arret du fenetrage video ****************************************

#***** Fenetre de configuration de l'autoguidage *********************************************
   #
   # AcqFC::run_config_autoguidage
   # Cree la fenetre de configuration de l'autoguidage
   #
   proc run_config_autoguidage { } {
      global audace

      ::AcqFC::createDialog_config_autoguidage
      tkwait visibility $audace(base).config_autoguidage
   }

   #
   # AcqFC::ok_config_autoguidage
   # Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
   # et fermer la fenetre de configuration de l'autoguidage
   #
   proc ok_config_autoguidage { } {
      ::AcqFC::appliquer_config_autoguidage
      ::AcqFC::fermer_config_autoguidage
   }

   #
   # AcqFC::appliquer_config_autoguidage
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc appliquer_config_autoguidage { } {
      ::AcqFC::widgetToConf_config_autoguidage
      ::AcqFC::setGuidingTargetSize  
   }

   #
   # AcqFC::fermer_config_autoguidage
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer_config_autoguidage { } {
      global audace

      destroy $audace(base).config_autoguidage
   }

   proc createDialog_config_autoguidage { } {
      global conf
      global audace
      global caption
      global panneau

      #--- initConf
      if { ! [ info exists conf(autoguidage,dim_zone) ] } { set conf(autoguidage,dim_zone) "20" }

      #--- confToWidget
      set panneau(AcqFC,dim_zone) $conf(autoguidage,dim_zone)

      #---
      if { [ winfo exists $audace(base).config_autoguidage ] } {
         wm withdraw $audace(base).config_autoguidage
         wm deiconify $audace(base).config_autoguidage
         focus $audace(base).config_autoguidage.but_ok 
         return
      }

      #--- Cree la fenetre de niveau le plus haut 
      toplevel $audace(base).config_autoguidage -class Toplevel
      wm transient $audace(base).config_autoguidage $audace(base).status_video
      wm title $audace(base).config_autoguidage $caption(acqfc,config_guidage)
      set posx_config_autoguidage [ lindex [ split [ wm geometry $audace(base).status_video ] "+" ] 1 ]
      set posy_config_autoguidage [ lindex [ split [ wm geometry $audace(base).status_video ] "+" ] 2 ]
      wm geometry $audace(base).config_autoguidage +[ expr $posx_config_autoguidage - 110 ]+[ expr $posy_config_autoguidage + 70 ]
      wm resizable $audace(base).config_autoguidage 0 0

      #--- Creation des differents frames
      frame $audace(base).config_autoguidage.frame1 -borderwidth 1 -relief raised
      uplevel #0 { pack $audace(base).config_autoguidage.frame1 -side top -fill both -expand 1 }

      frame $audace(base).config_autoguidage.frame2 -borderwidth 1 -relief raised
      uplevel #0 { pack $audace(base).config_autoguidage.frame2 -side top -fill x }

      frame $audace(base).config_autoguidage.frame3 -borderwidth 0 -relief raised
      uplevel #0 { pack $audace(base).config_autoguidage.frame3 -in $audace(base).config_autoguidage.frame1 \
         -side top -fill both -expand 1 }

      #--- Cree la zone a renseigner pour la dimension de la zone de capture de l'etoile
      label $audace(base).config_autoguidage.lab1 -text "$caption(acqfc,dim_zone_capture)"
	uplevel #0 { pack $audace(base).config_autoguidage.lab1 -in $audace(base).config_autoguidage.frame3 \
         -anchor w -side left -padx 10 -pady 3 }

      entry $audace(base).config_autoguidage.dim_zone -width 4 -font $audace(font,arial_10_b) -relief groove \
         -textvariable panneau(AcqFC,dim_zone) -justify center
	uplevel #0 { pack $audace(base).config_autoguidage.dim_zone -in $audace(base).config_autoguidage.frame3 \
         -anchor w -side left -padx 0 -pady 2 }

      label $audace(base).config_autoguidage.lab2 -text "$caption(acqfc,dim_zone_unite)"
	uplevel #0 { pack $audace(base).config_autoguidage.lab2 -in $audace(base).config_autoguidage.frame3 \
         -anchor w -side left -padx 0 -pady 3 }

      #--- Cree le bouton 'OK'
      button $audace(base).config_autoguidage.but_ok -text "$caption(confgene,ok)" -width 7 -borderwidth 2 \
         -command { ::AcqFC::ok_config_autoguidage }
      if { $conf(ok+appliquer)=="1" } {
         uplevel #0 { pack $audace(base).config_autoguidage.but_ok -in $audace(base).config_autoguidage.frame2 \
            -side left -anchor w -padx 3 -pady 3 -ipady 5 }
      }

      #--- Cree le bouton 'Appliquer'
      button $audace(base).config_autoguidage.but_appliquer -text "$caption(confgene,appliquer)" -width 8 -borderwidth 2 \
         -command { ::AcqFC::appliquer_config_autoguidage }
      uplevel #0 { pack $audace(base).config_autoguidage.but_appliquer -in $audace(base).config_autoguidage.frame2 \
         -side left -anchor w -padx 3 -pady 3 -ipady 5 }

      #--- Cree le bouton 'Fermer'
      button $audace(base).config_autoguidage.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
         -command { ::AcqFC::fermer_config_autoguidage }
      uplevel #0 { pack $audace(base).config_autoguidage.but_fermer -in $audace(base).config_autoguidage.frame2 \
         -side right -anchor w -padx 3 -pady 3 -ipady 5 }

      #--- La fenetre est active
      focus $audace(base).config_autoguidage

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).config_autoguidage
   }

   #
   # AcqFC::widgetToConf_config_autoguidage
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf_config_autoguidage { } {
      global conf
      global panneau

      set conf(autoguidage,dim_zone) $panneau(AcqFC,dim_zone)
   }
#***** Fin fenetre de configuration de l'autoguidage *****************************************

#***** Procedure de demarrage de l'autoguidage ***********************************************
   proc startGuiding {  } {
      global audace
      global caption
      global conf
      global panneau

      #--- Active le mode preview
      if { $panneau(AcqFC,showvideopreview) == "0" } {
         set result [ ::AcqFC::startVideoPreview ]
      } else {
         set result "0"
      }
      #---
      if { $result == "0" } {
         if { [ info exists audace(camNo) ] && ( ( $conf(camera) == "webcam" ) || ( $conf(camera) == "apn" ) ) } {
            cam$audace(camNo) startvideoguiding
            setGuidingTargetSize
            cam$audace(camNo) setvideoguidingcallback ::AcqFC::onStartStop ::AcqFC::onChangeOrigin ::AcqFC::onChangePoint
         } elseif { [ info exists audace(camNo) ] && ( ( $conf(camera) != "webcam" ) || ( $conf(camera) != "apn" ) ) } {
            tk_messageBox -title $caption(acqfc,pb) -type ok \
               -message $caption(acqfc,no_video_mode)
            #--- Je decoche la checkbox
            set panneau(AcqFC,showvideopreview) "0"
            #--- Je decoche le fenetrage et l'autoguidage
            if { $panneau(AcqFC,fenetre) == "1" } {
               set panneau(AcqFC,fenetre) "0"
               ::AcqFC::optionWindowedFenster
            }
            #--- J'arrete l'autoguidage s'il est actif
            if { $panneau(AcqFC,autoguidage) == "1" } {
               set panneau(AcqFC,autoguidage) "0"
               ::AcqFC::optionGuidingFenster
            }
         } else {
           ::confCam::run 
            tkwait window $audace(base).confCam         
         }
      } else {
         set panneau(AcqFC,autoguidage) "0"
      }
   }
#***** Fin de la procedure de demarrage de l'autoguidage *************************************

#***** Procedure d'arret de l'autoguidage ****************************************************
   proc stopGuiding { } {
      global audace
      global conf

      if { [ info exists audace(camNo) ] && ( ( $conf(camera) == "webcam" ) || ( $conf(camera) == "apn" ) ) } {
         cam$::audace(camNo) stopvideoguiding
      }
   }
#***** Fin de la procedure d'arret de l'autoguidage ******************************************

#***** Procedure de modification de la taille de la zone de guidage **************************
   proc setGuidingTargetSize { } {
      global audace
      global panneau

      if { [ info exists audace(camNo) ] } {
         cam$::audace(camNo) setvideoguidingtargetsize $::panneau(AcqFC,dim_zone)
      }
   }
#***** Fin de la procedure de modification de la taille de la zone de guidage ****************

#***** Procedure definissant les coordonnees origines ****************************************
   proc onChangeOrigin { xorig yorig } {
      global panneau

      set panneau(AcqFC,x0) "$xorig"
      set panneau(AcqFC,y0) "$yorig"
   }
#***** Fin de la procedure definissant les coordonnees origines ******************************

#***** Procedure definissant les coordonnees courantes ***************************************
   proc onChangePoint { x y alpha delta } {
      global panneau

      set panneau(AcqFC,x) "$x"
      set panneau(AcqFC,y) "$y"
      #---
      set panneau(AcqFC,ecart_x) [ expr $panneau(AcqFC,x) - $panneau(AcqFC,x0) ]
      set panneau(AcqFC,ecart_y) [ expr $panneau(AcqFC,y) - $panneau(AcqFC,y0) ]
   }
#***** Fin de la procedure definissant les coordonnees courantes *****************************

########################
   proc onStartStop { etat } {

   }
########################

#***** Enregistrement de la position des fenetres Continu (1), Continu (2), Video et Video (1) ********
   proc recup_position { } {
      global audace
      global conf

      #--- Cas de la fenetre Continu (1)
      if [ winfo exists $audace(base).intervalle_continu_1 ] {
         #--- Determination de la position de la fenetre
         set geometry [ wm geometry $audace(base).intervalle_continu_1 ]
         set deb [ expr 1 + [ string first + $geometry ] ]
         set fin [ string length $geometry ]
         set conf(acqfc,continu1,position) "+[ string range $geometry $deb $fin ]"
         #--- Fermeture de la fenetre
         destroy $audace(base).intervalle_continu_1
      }
      #--- Cas de la fenetre Continu (2)
      if [ winfo exists $audace(base).intervalle_continu_2 ] {
         #--- Determination de la position de la fenetre
         set geometry [ wm geometry $audace(base).intervalle_continu_2 ]
         set deb [ expr 1 + [ string first + $geometry ] ]
         set fin [ string length $geometry ]
         set conf(acqfc,continu2,position) "+[ string range $geometry $deb $fin ]"
         #--- Fermeture de la fenetre
         destroy $audace(base).intervalle_continu_2
      }
      #--- Cas de la fenetre Video et Video (1)
      if [ winfo exists $audace(base).status_video ] {
         #--- Determination de la position de la fenetre
         set geometry [ wm geometry $audace(base).status_video ]
         set deb [ expr 1 + [ string first + $geometry ] ]
         set fin [ string length $geometry ]
         set conf(acqfc,video,position) "+[ string range $geometry $deb $fin ]"
         #--- Fermeture de la fenetre
         destroy $audace(base).status_video
      }
   }
#***** Fin enregistrement de la position des fenetres Continu (1), Continu (2), Video et Video (1) ****

#***** Enregistrement de la position de la fenetre Configuration DigiCalm *****************************
   proc recup_position_telecharge { } {
      global audace
      global conf

      #--- Cas de la fenetre Configuration DigiCam
      if [ winfo exists $audace(base).telecharge_image ] {
         #--- Determination de la position de la fenetre
         set geometry [ wm geometry $audace(base).telecharge_image ]
         set deb [ expr 1 + [ string first + $geometry ] ]
         set fin [ string length $geometry ]
         set conf(acqfc,telecharge,position) "+[ string range $geometry $deb $fin ]"
         #--- Fermeture de la fenetre
         destroy $audace(base).telecharge_image
      }
   }
#***** Fin enregistrement de la position de la fenetre Configuration DigiCalm *************************

#***** Enregistrement de la position de la fenetre Avancement ********
   proc recup_position_1 { } {
      global audace conf

      #--- Cas de la fenetre Avancement
      if [ winfo exists $audace(base).progress ] {
         #--- Determination de la position de la fenetre
         set geometry [ wm geometry $audace(base).progress ]
         set deb [ expr 1 + [ string first + $geometry ] ]
         set fin [ string length $geometry ]
         set conf(acqfc,avancement,position) "+[ string range $geometry $deb $fin ]"
      }
   }
#***** Fin enregistrement de la position de la fenetre Avancement ****

}
#==============================================================
#   Fin de la declaration du namespace AcqFC
#==============================================================

proc AcqFCBuildIF { This } {
   global audace panneau caption confCam

   #--- Lancement des options
   source [ file join $audace(rep_plugin) tool acqfc dlgshift.tcl ]

   #--- Trame du panneau
   frame $This -height 50 -width $panneau(AcqFC,largeur_outil) -borderwidth 2 -relief groove

   #--- Trame du titre du panneau
   frame $This.titre -borderwidth 2 -relief groove
      Button $This.titre.but -borderwidth 1 -text $caption(acqfc,titre) \
         -command {
            ::audace::showHelpPlugin tool acqfc acqfc.htm
         }
      pack $This.titre.but -side top -fill x -in $This.titre
      DynamicHelp::add $This.titre.but -text $caption(acqfc,help_titre)
   place $This.titre -x 0 -y 0 -width [ expr $panneau(AcqFC,largeur_outil) - 4 ] -height 26 -anchor nw

   #--- Trame du temps de pose
   frame $This.pose -borderwidth 2 -relief ridge
      menubutton $This.pose.but -text $caption(acqfc,pose) -menu $This.pose.but.menu -relief raised
      pack $This.pose.but -side left
      set m [ menu $This.pose.but.menu -tearoff 0 ]
      foreach temps $panneau(AcqFC,temps_pose) {
         $m add radiobutton -label "$temps" \
            -indicatoron "1" \
            -value "$temps" \
            -variable panneau(AcqFC,pose) \
            -command { }
      }
      label $This.pose.lab -text $caption(acqfc,sec)
      pack $This.pose.lab -side right -fill y
      entry $This.pose.entr -width 2 -font $audace(font,arial_10_b)  -relief groove \
        -textvariable panneau(AcqFC,pose) -justify center
      pack $This.pose.entr -side left -fill both -expand true
   place $This.pose -x 0 -y 27 -width [ expr $panneau(AcqFC,largeur_outil) - 4 ] -height 24 -anchor nw

   #--- Trame du binning
   frame $This.bin -borderwidth 2 -relief ridge
      menubutton $This.bin.but -text $caption(acqfc,bin) -menu $This.bin.but.menu -relief raised
      pack $This.bin.but -side left
      set m [ menu $This.bin.but.menu -tearoff 0 ]
      foreach valbin $audace(list_binning) {
         $m add radiobutton -label "$valbin" \
            -indicatoron "1" \
            -value "$valbin" \
            -variable panneau(AcqFC,bin) \
            -command { }
      }
      entry $This.bin.lab -width 2 -font $audace(font,arial_10_b)  -relief groove \
        -textvariable panneau(AcqFC,bin) -justify center -state disabled
      pack $This.bin.lab -side left -fill both -expand true
   place $This.bin -x 0 -y 51 -width [ expr $panneau(AcqFC,largeur_outil) - 4 ] -height 24 -anchor nw

   #--- Bouton de configuration de la WebCam en lieu et place du widget binning
   button $This.bin.conf -text $caption(acqfc,config) \
      -command {
         set result [ catch { after 10 "cam$audace(camNo) videosource" } ]
         if { $result == "1" } {
            if { [ ::cam::list ] == "" } {
               ::audace::menustate disabled
               set choix [ tk_messageBox -title $caption(acqfc,pb) -type ok \
                  -message $caption(acqfc,selcam) ]
               set integre non
               if { $choix == "ok" } {
                  #--- Ouverture de la fenetre de selection des cameras
                  ::confCam::run 
                  tkwait window $audace(base).confCam
               }
               ::audace::menustate normal
            }
         }
      } 
   pack $This.bin.conf -side left -fill x -expand true

   #--- Trame de l'obturateur
   frame $This.obt -borderwidth 2 -relief ridge
      if { $confCam(camera,connect) == "0" } {
         button $This.obt.but -text $caption(acqfc,obt) -command {::AcqFC::ChangeObt} -state disabled
      } else {
         button $This.obt.but -text $caption(acqfc,obt) -command {::AcqFC::ChangeObt} -state normal
      }
      pack $This.obt.but -side left -fill x -expand true
      label $This.obt.lab -text $panneau(AcqFC,obt,$panneau(AcqFC,obt)) -width 6 \
         -font $audace(font,arial_10_b) -relief groove
      pack $This.obt.lab -side left -fill both -expand true
   place $This.obt -x 0 -y 75 -width [ expr $panneau(AcqFC,largeur_outil) - 4 ] -height 24 -anchor nw

   #--- Bouton du choix du format de l'image de la WebCam en lieu et place du widget obturateur
   button $This.obt.format -text $caption(acqfc,format) \
      -command { 
         set result [ catch { cam$audace(camNo) videoformat } ]
         if { $result == "1" } {
            if { [ ::cam::list ] == "" } {
               ::audace::menustate disabled
               set choix [ tk_messageBox -title $caption(acqfc,pb) -type ok \
                  -message $caption(acqfc,selcam) ]
               set integre non
               if { $choix == "ok" } {
                  #--- Ouverture de la fenetre de selection des cameras
                  ::confCam::run 
                  tkwait window $audace(base).confCam
               }
               ::audace::menustate normal
            }
         }
         if { $panneau(AcqFC,mode) == "6" } {
            #--- En mode video , il faut redimmensionner le canvas immediatement
            #--- Je positionne les scrollbar
            set audace(picture,w) [lindex [cam$audace(camNo) nbpix ] 0]
            set audace(picture,h) [lindex [cam$audace(camNo) nbpix ] 1]
            $audace(hCanvas) configure -scrollregion [list 0 0 $audace(picture,w) $audace(picture,h) ]
         }
      }
   pack $This.obt.format -side left -fill x -expand true

   #--- Bouton du choix du telechargement de l'image de l'APN en lieu et place du widget obturateur
   button $This.obt.digicam -text $caption(acqfc,config) -state normal \
      -command {
         if { ( $panneau(AcqFC,mode) == "2" ) || ( $panneau(AcqFC,mode) == "3" ) || ( $panneau(AcqFC,mode) == "4" ) || \
            ( $panneau(AcqFC,mode) == "5" ) } {
            ::AcqFC::Telecharge_image
         }
      }
   pack $This.obt.digicam -side left -fill x -expand true

   #--- Trame du Status
   frame $This.status -borderwidth 2 -relief ridge
      label $This.status.lab -text "" -font $audace(font,arial_10_b) -relief ridge -justify center -width 2
      pack $This.status.lab -side top -fill x -expand true -pady 1
   place $This.status -x 0 -y 99 -width [ expr $panneau(AcqFC,largeur_outil) - 4 ] -height 28 -anchor nw

   #--- Trame du bouton Go/Stop
   frame $This.go_stop -borderwidth 2 -relief ridge
      Button $This.go_stop.but -text $caption(acqfc,GO) \
         -font $audace(font,arial_12_b) -borderwidth 3 -command ::AcqFC::GoStop
      pack $This.go_stop.but -fill both -padx 0 -pady 0 -expand true
   place $This.go_stop -x 0 -y 127 -width [ expr $panneau(AcqFC,largeur_outil) - 4 ] -height 58 -anchor nw

   #--- Trame du mode d'acquisition
   set panneau(AcqFC,mode_en_cours) [ lindex $panneau(AcqFC,list_mode) [ expr $panneau(AcqFC,mode) - 1 ] ]
   frame $This.mode -borderwidth 5 -relief ridge
      ComboBox $This.mode.but \
         -font $audace(font,arial_10_b) \
         -height [llength $panneau(AcqFC,list_mode)] \
         -relief raised    \
         -borderwidth 1    \
         -editable 0       \
         -takefocus 1      \
         -justify center   \
         -textvariable panneau(AcqFC,mode_en_cours) \
         -values $panneau(AcqFC,list_mode) \
         -modifycmd { ::AcqFC::ChangeMode }
      
      place $This.mode.but -x 0 -y 0 -width [ expr $panneau(AcqFC,largeur_outil) - 14 ] -height 24 -anchor nw
      
      #--- Definition du sous-panneau "Mode : Une seule image"
      frame $This.mode.une -borderwidth 0
         frame $This.mode.une.nom -relief ridge -borderwidth 2
            label $This.mode.une.nom.but -text $caption(acqfc,nom) -pady 0
            pack $This.mode.une.nom.but -fill x -side top
            entry $This.mode.une.nom.entr -width 10 -textvariable panneau(AcqFC,nom_image) \
               -font $audace(font,arial_10_b) -relief groove
            pack $This.mode.une.nom.entr -fill x -side top
         place $This.mode.une.nom -x 0 -y 0 -width [ expr $panneau(AcqFC,largeur_outil) - 14 ] -height 42 -anchor nw
         frame $This.mode.une.index -relief ridge -borderwidth 2
            checkbutton $This.mode.une.index.case -pady 0 -text $caption(acqfc,index) -variable panneau(AcqFC,indexer)
            place $This.mode.une.index.case -x 0 -y 0 -width [ expr $panneau(AcqFC,largeur_outil) - 18 ] -height 18 \
               -anchor nw
            entry $This.mode.une.index.entr -width 3 -textvariable panneau(AcqFC,index) \
               -font $audace(font,arial_10_b) -relief groove -justify center
            place $This.mode.une.index.entr -x 0 -y 18 -width [ expr $panneau(AcqFC,largeur_outil) - 38 ] -height 24 \
               -anchor nw
            button $This.mode.une.index.but -text "1" -command {set panneau(AcqFC,index) 1}
            place $This.mode.une.index.but -x [ expr $panneau(AcqFC,largeur_outil) - 38 ] -y 18 -width 20 -height 24 \
               -anchor nw
         place $This.mode.une.index -x 0 -y 42 -width [ expr $panneau(AcqFC,largeur_outil) - 14 ] -height 46 -anchor nw
         button $This.mode.une.sauve -text $caption(acqfc,sauvegde) -command ::AcqFC::SauveUneImage
         place $This.mode.une.sauve -x 0 -y 88 -width [ expr $panneau(AcqFC,largeur_outil) - 14 ] -height 24 -anchor nw

      #--- Definition du sous-panneau "Mode : Serie d'images"
      frame $This.mode.serie
         frame $This.mode.serie.nom -relief ridge -borderwidth 2
            label $This.mode.serie.nom.but -text $caption(acqfc,nom) -pady 0
            pack $This.mode.serie.nom.but -fill x
            entry $This.mode.serie.nom.entr -width 10 -textvariable panneau(AcqFC,nom_image) \
               -font $audace(font,arial_10_b) -relief groove
            pack $This.mode.serie.nom.entr -fill x
         place $This.mode.serie.nom -x 0 -y 0 -width [ expr $panneau(AcqFC,largeur_outil) - 14 ] -height 42 -anchor nw
         frame $This.mode.serie.nb -relief ridge -borderwidth 2
            label $This.mode.serie.nb.but -text $caption(acqfc,nombre) -pady 0
            pack $This.mode.serie.nb.but -side left -fill y
            entry $This.mode.serie.nb.entr -width 3 -textvariable panneau(AcqFC,nb_images) \
               -font $audace(font,arial_10_b) -relief groove -justify center
            pack $This.mode.serie.nb.entr -side left -fill x -expand true
         place $This.mode.serie.nb -x 0 -y 42 -width [ expr $panneau(AcqFC,largeur_outil) - 14 ] -height 24 -anchor nw
         frame $This.mode.serie.index -relief ridge -borderwidth 2
            label $This.mode.serie.index.lab -text $caption(acqfc,index) -pady 0
            place $This.mode.serie.index.lab -x 0 -y 0 -width [ expr $panneau(AcqFC,largeur_outil) - 18 ] -height 18 \
               -anchor nw
            entry $This.mode.serie.index.entr -width 3 -textvariable panneau(AcqFC,index) \
               -font $audace(font,arial_10_b) -relief groove -justify center
            place $This.mode.serie.index.entr -x 0 -y 18 -width [ expr $panneau(AcqFC,largeur_outil) - 38 ] -height 24 \
               -anchor nw
            button $This.mode.serie.index.but -text "1" -command {set panneau(AcqFC,index) 1}
            place $This.mode.serie.index.but -x [ expr $panneau(AcqFC,largeur_outil) - 38 ] -y 18 -width 20 -height 24 \
               -anchor nw
         place $This.mode.serie.index -x 0 -y 66 -width [ expr $panneau(AcqFC,largeur_outil) - 14 ] -height 46 -anchor nw

      #--- Definition du sous-panneau "Mode : Continu"
      frame $This.mode.continu
         frame $This.mode.continu.sauve -relief ridge -borderwidth 2
            checkbutton $This.mode.continu.sauve.case -text $caption(acqfc,enregistrer) \
               -variable panneau(AcqFC,enregistrer)
            pack $This.mode.continu.sauve.case -side left -fill x  -expand true
         place $This.mode.continu.sauve -x 0 -y 0  -width [ expr $panneau(AcqFC,largeur_outil) - 14 ] -height 24 \
            -anchor nw
         frame $This.mode.continu.nom -relief ridge -borderwidth 2
            label $This.mode.continu.nom.but -text $caption(acqfc,nom) -pady 0
            pack $This.mode.continu.nom.but -fill x
            entry $This.mode.continu.nom.entr -width 10 -textvariable panneau(AcqFC,nom_image) \
               -font $audace(font,arial_10_b) -relief groove
            pack $This.mode.continu.nom.entr -fill x
         place $This.mode.continu.nom -x 0 -y 24 -width [ expr $panneau(AcqFC,largeur_outil) - 14 ] -height 42 -anchor nw
         frame $This.mode.continu.index -relief ridge -borderwidth 2
            label $This.mode.continu.index.lab -text $caption(acqfc,index) -pady 0
            place $This.mode.continu.index.lab -x 0 -y 0 -width [ expr $panneau(AcqFC,largeur_outil) - 18 ] -height 18 \
               -anchor nw
            entry $This.mode.continu.index.entr -width 3 -textvariable panneau(AcqFC,index) \
               -font $audace(font,arial_10_b) -relief groove -justify center
            place $This.mode.continu.index.entr -x 0 -y 18 -width [ expr $panneau(AcqFC,largeur_outil) - 38 ] -height 24 \
               -anchor nw
            button $This.mode.continu.index.but -text "1" -command {set panneau(AcqFC,index) 1}
            place $This.mode.continu.index.but -x [ expr $panneau(AcqFC,largeur_outil) - 38 ] -y 18 -width 20 -height 24 \
               -anchor nw
         place $This.mode.continu.index -x 0 -y 66 -width [ expr $panneau(AcqFC,largeur_outil) - 14 ] -height 46 \
            -anchor nw

      #--- Definition du sous-panneau "Mode : Series d'images en continu avec intervalle entre chaque serie"
      frame $This.mode.serie_1
         frame $This.mode.serie_1.nom -relief ridge -borderwidth 2
            label $This.mode.serie_1.nom.but -text $caption(acqfc,nom) -pady 0
            pack $This.mode.serie_1.nom.but -fill x
            entry $This.mode.serie_1.nom.entr -width 10 -textvariable panneau(AcqFC,nom_image) \
               -font $audace(font,arial_10_b) -relief groove
            pack $This.mode.serie_1.nom.entr -fill x
         place $This.mode.serie_1.nom -x 0 -y 0 -width [ expr $panneau(AcqFC,largeur_outil) - 14 ] -height 42 -anchor nw
         frame $This.mode.serie_1.nb -relief ridge -borderwidth 2
            label $This.mode.serie_1.nb.but -text $caption(acqfc,nombre) -pady 0
            pack $This.mode.serie_1.nb.but -side left -fill y
            entry $This.mode.serie_1.nb.entr -width 3 -textvariable panneau(AcqFC,nb_images) \
               -font $audace(font,arial_10_b) -relief groove -justify center
            pack $This.mode.serie_1.nb.entr -side left -fill x -expand true
         place $This.mode.serie_1.nb -x 0 -y 42 -width [ expr $panneau(AcqFC,largeur_outil) - 14 ] -height 24 -anchor nw
         frame $This.mode.serie_1.index -relief ridge -borderwidth 2
            label $This.mode.serie_1.index.lab -text $caption(acqfc,index) -pady 0
            place $This.mode.serie_1.index.lab -x 0 -y 0 -width [ expr $panneau(AcqFC,largeur_outil) - 18 ] -height 18 \
               -anchor nw
            entry $This.mode.serie_1.index.entr -width 3 -textvariable panneau(AcqFC,index) \
               -font $audace(font,arial_10_b) -relief groove -justify center
            place $This.mode.serie_1.index.entr -x 0 -y 18 -width [ expr $panneau(AcqFC,largeur_outil) - 38 ] -height 24 \
               -anchor nw
            button $This.mode.serie_1.index.but -text "1" -command {set panneau(AcqFC,index) 1}
            place $This.mode.serie_1.index.but -x [ expr $panneau(AcqFC,largeur_outil) - 38 ] -y 18 -width 20 -height 24 \
               -anchor nw
         place $This.mode.serie_1.index -x 0 -y 66 -width [ expr $panneau(AcqFC,largeur_outil) - 14 ] -height 46 \
            -anchor nw

      #--- Definition du sous-panneau "Mode : Continu avec intervalle entre chaque image"
      frame $This.mode.continu_1
         frame $This.mode.continu_1.sauve -relief ridge -borderwidth 2
            checkbutton $This.mode.continu_1.sauve.case -text $caption(acqfc,enregistrer) \
               -variable panneau(AcqFC,enregistrer)
            pack $This.mode.continu_1.sauve.case -side left -fill x  -expand true
         place $This.mode.continu_1.sauve -x 0 -y 0 -width [ expr $panneau(AcqFC,largeur_outil) - 14 ] -height 24 \
            -anchor nw
         frame $This.mode.continu_1.nom -relief ridge -borderwidth 2
            label $This.mode.continu_1.nom.but -text $caption(acqfc,nom) -pady 0
            pack $This.mode.continu_1.nom.but -fill x
            entry $This.mode.continu_1.nom.entr -width 10 -textvariable panneau(AcqFC,nom_image) \
               -font $audace(font,arial_10_b) -relief groove
            pack $This.mode.continu_1.nom.entr -fill x
         place $This.mode.continu_1.nom -x 0 -y 24 -width [ expr $panneau(AcqFC,largeur_outil) - 14 ] -height 42 \
            -anchor nw
         frame $This.mode.continu_1.index -relief ridge -borderwidth 2
            label $This.mode.continu_1.index.lab -text $caption(acqfc,index) -pady 0
            place $This.mode.continu_1.index.lab -x 0 -y 0 -width [ expr $panneau(AcqFC,largeur_outil) - 18 ] -height 18 \
               -anchor nw
            entry $This.mode.continu_1.index.entr -width 3 -textvariable panneau(AcqFC,index) \
               -font $audace(font,arial_10_b) -relief groove -justify center
            place $This.mode.continu_1.index.entr -x 0 -y 18 -width [ expr $panneau(AcqFC,largeur_outil) - 38 ] \
               -height 24 -anchor nw
            button $This.mode.continu_1.index.but -text "1" -command {set panneau(AcqFC,index) 1}
            place $This.mode.continu_1.index.but -x [ expr $panneau(AcqFC,largeur_outil) - 38 ] -y 18 -width 20 \
               -height 24 -anchor nw
         place $This.mode.continu_1.index -x 0 -y 66 -width [ expr $panneau(AcqFC,largeur_outil) - 14 ] -height 46 \
            -anchor nw

      #--- Definition du sous-panneau "Mode : Video"
      frame $This.mode.video -borderwidth 0
         frame $This.mode.video.nom -relief ridge -borderwidth 2
            label $This.mode.video.nom.but -text $caption(acqfc,nom) -pady 0
            pack $This.mode.video.nom.but -fill x -side top
            entry $This.mode.video.nom.entr -width 10 -textvariable panneau(AcqFC,nom_image) \
               -font $audace(font,arial_10_b) -relief groove
            pack $This.mode.video.nom.entr -fill x -side top
         place $This.mode.video.nom -x 0 -y 0 -width [ expr $panneau(AcqFC,largeur_outil) - 14 ] -height 42 -anchor nw
         frame $This.mode.video.index -relief ridge -borderwidth 2
            checkbutton $This.mode.video.index.case -pady 0 -text $caption(acqfc,index)\
               -variable panneau(AcqFC,indexer)
            place $This.mode.video.index.case -x 0 -y 0 -width [ expr $panneau(AcqFC,largeur_outil) - 18 ] -height 18 \
               -anchor nw
            entry $This.mode.video.index.entr -width 3 -textvariable panneau(AcqFC,index) \
               -font $audace(font,arial_10_b) -relief groove -justify center
            place $This.mode.video.index.entr -x 0 -y 18 -width [ expr $panneau(AcqFC,largeur_outil) - 38 ] -height 24 \
               -anchor nw
            button $This.mode.video.index.but -text "1" -command {set panneau(AcqFC,index) 1}
            place $This.mode.video.index.but -x [ expr $panneau(AcqFC,largeur_outil) - 38 ] -y 18 -width 20 -height 24 \
               -anchor nw
         place $This.mode.video.index -x 0 -y 42 -width [ expr $panneau(AcqFC,largeur_outil) - 14 ] -height 46 -anchor nw
         frame $This.mode.video.show -relief ridge -borderwidth 2
            checkbutton $This.mode.video.show.case -text $caption(acqfc,show_video) \
               -variable panneau(AcqFC,showvideopreview) \
               -command {    
                  if { $::panneau(AcqFC,showvideopreview) == 1 } {
                     ::AcqFC::startVideoPreview 
                  } else {
                     ::AcqFC::stopVideoPreview 
                  }
               }
            pack $This.mode.video.show.case -side left -fill x -expand true
         place $This.mode.video.show -x 0 -y 88 -width [ expr $panneau(AcqFC,largeur_outil) - 14 ] -height 24 -anchor nw

      #--- Definition du sous-panneau "Mode : Video avec intervalle entre chaque video"
      frame $This.mode.video_1 -borderwidth 0
         frame $This.mode.video_1.nom -relief ridge -borderwidth 2
            label $This.mode.video_1.nom.but -text $caption(acqfc,nom) -pady 0
            pack $This.mode.video_1.nom.but -fill x -side top
            entry $This.mode.video_1.nom.entr -width 10 -textvariable panneau(AcqFC,nom_image) \
               -font $audace(font,arial_10_b) -relief groove
            pack $This.mode.video_1.nom.entr -fill x -side top
         place $This.mode.video_1.nom -x 0 -y 0 -width [ expr $panneau(AcqFC,largeur_outil) - 14 ] -height 42 -anchor nw
         frame $This.mode.video_1.index -relief ridge -borderwidth 2
            label $This.mode.video_1.index.lab -text $caption(acqfc,index) -pady 0
            place $This.mode.video_1.index.lab -x 0 -y 0 -width [ expr $panneau(AcqFC,largeur_outil) - 18 ] -height 18 \
               -anchor nw
            entry $This.mode.video_1.index.entr -width 3 -textvariable panneau(AcqFC,index) \
               -font $audace(font,arial_10_b) -relief groove -justify center
            place $This.mode.video_1.index.entr -x 0 -y 18 -width [ expr $panneau(AcqFC,largeur_outil) - 38 ] -height 24 \
               -anchor nw
            button $This.mode.video_1.index.but -text "1" -command {set panneau(AcqFC,index) 1}
            place $This.mode.video_1.index.but -x [ expr $panneau(AcqFC,largeur_outil) - 38 ] -y 18 -width 20 -height 24 \
               -anchor nw
         place $This.mode.video_1.index -x 0 -y 42 -width [ expr $panneau(AcqFC,largeur_outil) - 14 ] -height 46 \
            -anchor nw
         frame $This.mode.video_1.show -relief ridge -borderwidth 2
            checkbutton $This.mode.video_1.show.case -text $caption(acqfc,show_video) \
               -variable panneau(AcqFC,showvideopreview) \
               -command { 
                  if { $panneau(AcqFC,showvideopreview) == 1 } {
                     ::AcqFC::startVideoPreview 
                  } else {
                     ::AcqFC::stopVideoPreview 
                  }
               }
            pack $This.mode.video_1.show.case -side left -fill x -expand true
         place $This.mode.video_1.show -x 0 -y 88 -width [ expr $panneau(AcqFC,largeur_outil) - 14 ] -height 24 -anchor nw
      place $This.mode -x 0 -y 185 -width [ expr $panneau(AcqFC,largeur_outil) - 4 ] -height 146 -anchor nw

      #--- Frame petit decalage
      frame $This.shift -borderwidth 2 -relief ridge
         #--- Checkbutton petit deplacement
         checkbutton $This.shift.buttonShift -highlightthickness 0 -variable panneau(DlgShift,buttonShift)
         place $This.shift.buttonShift -x 0 -y 3 
         #--- Bouton configuration petit deplacement
         button $This.shift.buttonShiftConfig -text "$caption(acqfc,buttonShiftConfig)" \
            -command { ::AcqFC::cmdShiftConfig }
         place $This.shift.buttonShiftConfig -x 24 -y 0 -width [ expr $panneau(AcqFC,largeur_outil) - 32 ] -height 25 \
            -anchor nw
      place $This.shift -x 0 -y 331 -width [ expr $panneau(AcqFC,largeur_outil) - 4 ] -height 71 -anchor nw

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

::AcqFC::Init $audace(base)

#---------------------------------------------------------------------------------------------
# Fin du fichier acqfc.tcl
#---------------------------------------------------------------------------------------------

