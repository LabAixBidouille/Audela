#
# Fichier : acqfc.tcl
# Description : Outil d'acquisition
# Auteur : Francois Cochard
# Mise a jour $Id: acqfc.tcl,v 1.60 2008-05-23 07:14:39 robertdelmas Exp $
#

#==============================================================
#   Declaration du namespace acqfc
#==============================================================

namespace eval ::acqfc {
   package provide acqfc 3.0
   package require audela 1.4.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] acqfc.cap ]

#***** Procedure createPluginInstance***************************
   proc createPluginInstance { { in "" } { visuNo 1 } } {
      variable parametres
      global audace caption conf panneau

      #--- Chargement des fichiers auxiliaires
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqfc acqfcSetup.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool acqfc dlgshift.tcl ]\""

      #---
      set panneau(acqfc,$visuNo,base) "$in"
      set panneau(acqfc,$visuNo,This) "$in.acqfc"

      set panneau(acqfc,$visuNo,camItem) [::confVisu::getCamItem $visuNo]
      set panneau(acqfc,$visuNo,camNo)   [::confCam::getCamNo $panneau(acqfc,$visuNo,camItem)]

      #--- Recuperation de la derniere configuration de l'outil
      ::acqfc::Chargement_Var $visuNo

      #--- Initialisation des variables de la boite de configuration
      ::acqfcSetup::confToWidget $visuNo

      #--- Initialisation de la variable conf()
      if { ! [info exists conf(acqfc,avancement,position)] } { set conf(acqfc,avancement,position) "+120+315" }

      #--- Initialisation de variables
      set panneau(acqfc,$visuNo,simulation)            "0"
      set panneau(acqfc,$visuNo,simulation_deja_faite) "0"
      set panneau(acqfc,$visuNo,attente_pose)          "0"
      set panneau(acqfc,$visuNo,pose_en_cours)         "0"
      set panneau(acqfc,$visuNo,avancement,position)   "$conf(acqfc,avancement,position)"

      #--- Entrer ici les valeurs de temps de pose a afficher dans le menu "pose"
      set panneau(acqfc,$visuNo,temps_pose) { 0 0.1 0.3 0.5 1 2 3 5 10 15 20 30 60 90 120 180 300 600 }
      #--- Valeur par defaut du temps de pose
      if { ! [ info exists panneau(acqfc,$visuNo,pose) ] } {
         set panneau(acqfc,$visuNo,pose) "$parametres(acqfc,$visuNo,pose)"
      }

      #--- Valeur par defaut du binning
      if { ! [ info exists panneau(acqfc,$visuNo,bin) ] } {
         set panneau(acqfc,$visuNo,bin) "$parametres(acqfc,$visuNo,bin)"
      }

      #--- Entrer ici les valeurs pour l'obturateur a afficher dans le menu "obt"
      set panneau(acqfc,$visuNo,obt,0) "$caption(acqfc,ouv)"
      set panneau(acqfc,$visuNo,obt,1) "$caption(acqfc,ferme)"
      set panneau(acqfc,$visuNo,obt,2) "$caption(acqfc,auto)"
      #--- Obturateur par defaut : Synchro
      if { ! [ info exists panneau(acqfc,$visuNo,obt) ] } {
         set panneau(acqfc,$visuNo,obt) "$parametres(acqfc,$visuNo,obt)"
      }

      #--- Liste des modes disponibles
      set panneau(acqfc,$visuNo,list_mode) [ list $caption(acqfc,uneimage) $caption(acqfc,serie) $caption(acqfc,continu) \
         $caption(acqfc,continu_1) $caption(acqfc,continu_2) ]

      #--- Initialisation des modes
      set panneau(acqfc,$visuNo,mode,1) "$panneau(acqfc,$visuNo,This).mode.une"
      set panneau(acqfc,$visuNo,mode,2) "$panneau(acqfc,$visuNo,This).mode.serie"
      set panneau(acqfc,$visuNo,mode,3) "$panneau(acqfc,$visuNo,This).mode.continu"
      set panneau(acqfc,$visuNo,mode,4) "$panneau(acqfc,$visuNo,This).mode.serie_1"
      set panneau(acqfc,$visuNo,mode,5) "$panneau(acqfc,$visuNo,This).mode.continu_1"
      #--- Mode par defaut : Une image
      if { ! [ info exists panneau(acqfc,$visuNo,mode) ] } {
         set panneau(acqfc,$visuNo,mode) "$parametres(acqfc,$visuNo,mode)"
      }

      #--- Initialisation d'autres variables
      set panneau(acqfc,$visuNo,go_stop)           "go"
      set panneau(acqfc,$visuNo,index)             "1"
      set panneau(acqfc,$visuNo,nom_image)         ""
      set panneau(acqfc,$visuNo,extension)         "$conf(extension,defaut)"
      set panneau(acqfc,$visuNo,indexer)           "0"
      set panneau(acqfc,$visuNo,nb_images)         "1"
      set panneau(acqfc,$visuNo,session_ouverture) "1"
      set panneau(acqfc,$visuNo,avancement_acq)    "$parametres(acqfc,$visuNo,avancement_acq)"
      set panneau(acqfc,$visuNo,enregistrer)       "$parametres(acqfc,$visuNo,enregistrer)"

      #--- Mise en place de l'interface graphique
      acqfcBuildIF $visuNo

      #--- Traitement du bouton Configuration pour la camera APN (DSLR)
      $panneau(acqfc,$visuNo,This).obt.dslr configure -state normal

      pack $panneau(acqfc,$visuNo,mode,$panneau(acqfc,$visuNo,mode)) -anchor nw -fill x

      #--- Surveillance de la connexion d'une camera
      ::confVisu::addCameraListener $visuNo "::acqfc::Adapt_Panneau_AcqFC $visuNo"
      #--- Surveillance de l'ajout ou de la suppression d'une extension
      trace add variable ::conf(list_extension) write ::acqfc::Init_list_extension

   }
#***** Fin de la procedure createPluginInstance*****************

   #------------------------------------------------------------
   #  deletePluginInstance
   #     suppprime l'instance du plugin
   #------------------------------------------------------------
   proc deletePluginInstance { visuNo } {
      global conf panneau

      #--- Je desactive la surveillance de la connexion d'une camera
      ::confVisu::removeCameraListener $visuNo "::acqfc::Adapt_Panneau_AcqFC $visuNo"
      #--- Je desactive la surveillance de l'ajout ou de la suppression d'une extension
      trace remove variable ::conf(list_extension) write ::acqfc::Init_list_extension

      #---
      set conf(acqfc,avancement,position) $panneau(acqfc,$visuNo,avancement,position)

      #---
      destroy $panneau(acqfc,$visuNo,This)
      destroy $panneau(acqfc,$visuNo,This).pose.but.menu
      destroy $panneau(acqfc,$visuNo,This).bin.but.menu
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
         function  { return "acquisition" }
         multivisu { return 1 }
         display   { return "panel" }
      }
   }

   #------------------------------------------------------------
   #  getPluginTitle
   #     retourne le titre du plugin dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(acqfc,titre)"
   }

   #------------------------------------------------------------
   #  getPluginHelp
   #     retourne le nom du fichier d'aide principal
   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "acqfc.htm"
   }

   #------------------------------------------------------------
   #  getPluginType
   #     retourne le type de plugin
   #------------------------------------------------------------
   proc getPluginType { } {
      return "tool"
   }

   #------------------------------------------------------------
   #  getPluginDirectory
   #     retourne le type de plugin
   #------------------------------------------------------------
   proc getPluginDirectory { } {
      return "acqfc"
   }

   #------------------------------------------------------------
   #  getPluginOS
   #     retourne le ou les OS de fonctionnement du plugin
   #------------------------------------------------------------
   proc getPluginOS { } {
      return [ list Windows Linux Darwin ]
   }

   #------------------------------------------------------------
   #  initPlugin
   #     initialise le plugin
   #------------------------------------------------------------
   proc initPlugin { tkbase } {

   }

#***** Procedure DemarrageAcqFC ********************************
   proc DemarrageAcqFC { visuNo } {
      global audace caption panneau

      #--- Gestion du fichier de log
      #--- Creation du nom de fichier log
      set nom_generique "acqfc-visu$visuNo-"
      #--- Heure a partir de laquelle on passe sur un nouveau fichier de log
      set heure_nouveau_fichier "12"
      set heure_courante [lindex [split $audace(tu,format,hmsint) h] 0]
      if { $heure_courante < $heure_nouveau_fichier } {
         #--- Si avant l'heure de changement, je prends la date de la veille
         set formatdate [clock format [expr {[clock seconds] - 86400}] -format "%Y-%m-%d"]
      } else {
         #--- Sinon, je prends la date du jour
         set formatdate [clock format [clock seconds] -format "%Y-%m-%d"]
      }
      set file_log ""
      set ::acqfc::fichier_log [ file join $audace(rep_images) [ append $file_log $nom_generique $formatdate ".log" ] ]

      #--- Ouverture
      if { [ catch { open $::acqfc::fichier_log a } ::acqfc::log_id($visuNo) ] } {
         Message $visuNo console $caption(acqfc,pbouvfichcons)
         tk_messageBox -title $caption(acqfc,pb) -type ok \
            -message $caption(acqfc,pbouvfich)
         #--- Note importante : Je detecte si j'ai un pb a l'ouverture du fichier, mais je ne sais pas traiter ce cas :
         #--- Il faudrait interdire l'ouverture du panneau, mais le processus est deja lance a ce stade...
         #--- Tout ce que je fais, c'est inviter l'utilisateur a changer d'outil !
      } else {
         #--- En-tete du fichier
         Message $visuNo log $caption(acqfc,ouvsess) [ package version acqfc ]
         set date [clock format [clock seconds] -format "%A %d %B %Y"]
         set heure $audace(tu,format,hmsint)
         Message $visuNo consolog $caption(acqfc,affheure) $date $heure
         #--- Definition du binding pour declencher l'acquisition (ou l'arret) par Echap.
         bind all <Key-Escape> "::acqfc::GoStop $visuNo"
      }
   }
#***** Fin de la procedure DemarrageAcqFC **********************

#***** Procedure ArretAcqFC ************************************
   proc ArretAcqFC { visuNo } {
      global audace caption panneau

      #--- Fermeture du fichier de log
      if { [ info exists ::acqfc::log_id($visuNo) ] } {
         set heure $audace(tu,format,hmsint)
         #--- Je m'assure que le fichier se termine correctement, en particulier pour le cas ou il y
         #--- a eu un probleme a l'ouverture (c'est un peu une rustine...)
         if { [ catch { Message $visuNo log $caption(acqfc,finsess) $heure } bug ] } {
            Message $visuNo console $caption(acqfc,pbfermfichcons)
         } else {
            close $::acqfc::log_id($visuNo)
            unset ::acqfc::log_id($visuNo)
         }
      }
      #--- Re-initialisation de la session
      set panneau(acqfc,$visuNo,session_ouverture) "1"
      #--- Desactivation du binding pour declencher l'acquisition (ou l'arret) par Echap.
      bind all <Key-Escape> { }
   }
#***** Fin de la procedure ArretAcqFC **************************

#***** Procedure Init_list_extension ***************************
   proc Init_list_extension { { a "" } { b "" } { c "" } { visuNo 1 } } {
      variable This
      global conf panneau

      #--- Mise a jour de la liste des extensions disponibles pour le mode "Une seule image"
      $panneau(acqfc,$visuNo,This).mode.une.nom.extension.menu delete 0 20
      foreach extension $conf(list_extension) {
         $panneau(acqfc,$visuNo,This).mode.une.nom.extension.menu add radiobutton -label "$extension" \
            -indicatoron "1" \
            -value "$extension" \
            -variable panneau(acqfc,$visuNo,extension) \
            -command " "
      }
      #--- Mise a jour de la liste des extensions disponibles pour le mode "Serie d'images"
      $panneau(acqfc,$visuNo,This).mode.serie.nom.extension.menu delete 0 20
      foreach extension $conf(list_extension) {
         $panneau(acqfc,$visuNo,This).mode.serie.nom.extension.menu add radiobutton -label "$extension" \
            -indicatoron "1" \
            -value "$extension" \
            -variable panneau(acqfc,$visuNo,extension) \
            -command " "
      }
      #--- Mise a jour de la liste des extensions disponibles pour le mode "Continu"
      $panneau(acqfc,$visuNo,This).mode.continu.nom.extension.menu delete 0 20
      foreach extension $conf(list_extension) {
         $panneau(acqfc,$visuNo,This).mode.continu.nom.extension.menu add radiobutton -label "$extension" \
            -indicatoron "1" \
            -value "$extension" \
            -variable panneau(acqfc,$visuNo,extension) \
            -command " "
      }
      #--- Mise a jour de la liste des extensions disponibles pour le mode "Series d'images en continu avec intervalle entre chaque serie"
      $panneau(acqfc,$visuNo,This).mode.serie_1.nom.extension.menu delete 0 20
      foreach extension $conf(list_extension) {
         $panneau(acqfc,$visuNo,This).mode.serie_1.nom.extension.menu add radiobutton -label "$extension" \
            -indicatoron "1" \
            -value "$extension" \
            -variable panneau(acqfc,$visuNo,extension) \
            -command " "
      }
      #--- Mise a jour de la liste des extensions disponibles pour le mode "Continu avec intervalle entre chaque image"
      $panneau(acqfc,$visuNo,This).mode.continu_1.nom.extension.menu delete 0 20
      foreach extension $conf(list_extension) {
         $panneau(acqfc,$visuNo,This).mode.continu_1.nom.extension.menu add radiobutton -label "$extension" \
            -indicatoron "1" \
            -value "$extension" \
            -variable panneau(acqfc,$visuNo,extension) \
            -command " "
      }
   }
#***** Fin de la procedure Init_list_extension *****************

#***** Procedure Adapt_Panneau_AcqFC ***************************
   proc Adapt_Panneau_AcqFC { visuNo args } {
      global audace conf panneau

      set panneau(acqfc,$visuNo,camItem) [::confVisu::getCamItem $visuNo]
      set panneau(acqfc,$visuNo,camNo)   [::confCam::getCamNo $panneau(acqfc,$visuNo,camItem)]

      #---
      set camNo $panneau(acqfc,$visuNo,camNo)
      if { $camNo == "0" } {
         #--- La camera n'a pas ete encore selectionnee
         set camProduct ""
      } else {
         set camProduct [ cam$camNo product ]
      }
      #---
      if { "$camProduct" == "webcam" } {
         #--- C'est une WebCam
         if { [ confCam::getPluginProperty [ ::confVisu::getCamItem $visuNo ] longExposure ] == "0" } {
            #--- Cas d'une WebCam standard
            pack forget $panneau(acqfc,$visuNo,This).pose.but
            pack forget $panneau(acqfc,$visuNo,This).pose.lab
            pack forget $panneau(acqfc,$visuNo,This).pose.entr
            pack forget $panneau(acqfc,$visuNo,This).bin.but
            pack forget $panneau(acqfc,$visuNo,This).bin.lab
            pack $panneau(acqfc,$visuNo,This).pose.conf -fill x -expand true -ipady 3
            pack forget $panneau(acqfc,$visuNo,This).obt.but
            pack forget $panneau(acqfc,$visuNo,This).obt.lab
            pack forget $panneau(acqfc,$visuNo,This).obt.lab1
            pack forget $panneau(acqfc,$visuNo,This).obt.dslr
         } else {
            #--- Cas d'une WebCam Longue Pose
            pack $panneau(acqfc,$visuNo,This).pose.but -side left
            pack $panneau(acqfc,$visuNo,This).pose.lab -side right
            pack $panneau(acqfc,$visuNo,This).pose.entr -side left
            pack forget $panneau(acqfc,$visuNo,This).bin.but
            pack forget $panneau(acqfc,$visuNo,This).bin.lab
            pack forget $panneau(acqfc,$visuNo,This).pose.conf
            pack forget $panneau(acqfc,$visuNo,This).obt.but
            pack forget $panneau(acqfc,$visuNo,This).obt.lab
            pack forget $panneau(acqfc,$visuNo,This).obt.lab1
            pack forget $panneau(acqfc,$visuNo,This).obt.dslr
         }
      } elseif { "$camProduct" == "dslr" } {
         #--- C'est une APN (DSLR)
         pack $panneau(acqfc,$visuNo,This).pose.but -side left
         pack $panneau(acqfc,$visuNo,This).pose.lab -side right
         pack $panneau(acqfc,$visuNo,This).pose.entr -side left
         pack $panneau(acqfc,$visuNo,This).bin.but -side left
         pack $panneau(acqfc,$visuNo,This).bin.lab -side left
         pack forget $panneau(acqfc,$visuNo,This).pose.conf
         pack forget $panneau(acqfc,$visuNo,This).obt.but
         pack forget $panneau(acqfc,$visuNo,This).obt.lab
         pack forget $panneau(acqfc,$visuNo,This).obt.lab1
         pack $panneau(acqfc,$visuNo,This).obt.dslr -fill x -expand true -ipady 3
      } else {
         #--- Ce n'est pas une WebCam, ni une APN (DSLR)
         pack $panneau(acqfc,$visuNo,This).pose.but -side left
         pack $panneau(acqfc,$visuNo,This).pose.lab -side right
         pack $panneau(acqfc,$visuNo,This).pose.entr -side left
         pack $panneau(acqfc,$visuNo,This).bin.but -side left
         pack $panneau(acqfc,$visuNo,This).bin.lab -side left
         pack forget $panneau(acqfc,$visuNo,This).pose.conf
         pack $panneau(acqfc,$visuNo,This).obt.but -side left -ipady 3
         pack $panneau(acqfc,$visuNo,This).obt.lab -side left -fill x -expand true -ipady 3
         pack forget $panneau(acqfc,$visuNo,This).obt.lab1
         pack forget $panneau(acqfc,$visuNo,This).obt.dslr
      }

      if { [ ::confCam::getPluginProperty [ ::confVisu::getCamItem $visuNo ] hasShutter ] == "1" } {
         pack forget $panneau(acqfc,$visuNo,This).obt.lab
         if { ! [ info exists conf($camProduct,foncobtu) ] } {
            set conf($camProduct,foncobtu) "2"
         } else {
            if { $conf($camProduct,foncobtu) == "0" } {
               set panneau(acqfc,$visuNo,obt) "0"
            } elseif { $conf($camProduct,foncobtu) == "1" } {
               set panneau(acqfc,$visuNo,obt) "1"
            } elseif { $conf($camProduct,foncobtu) == "2" } {
               set panneau(acqfc,$visuNo,obt) "2"
            }
         }
         $panneau(acqfc,$visuNo,This).obt.lab configure -text $panneau(acqfc,$visuNo,obt,$panneau(acqfc,$visuNo,obt))
         pack $panneau(acqfc,$visuNo,This).obt.lab -fill both -expand true -ipady 3
      } else {
         pack forget $panneau(acqfc,$visuNo,This).obt.but
         pack forget $panneau(acqfc,$visuNo,This).obt.lab
         if { ( "$camProduct" != "webcam" ) && ( "$camProduct" != "dslr" ) } {
            pack $panneau(acqfc,$visuNo,This).obt.lab1 -side top -ipady 3
         }
      }
      #---
      $panneau(acqfc,$visuNo,This).bin.but.menu delete 0 20
      set list_binning [ ::confCam::getPluginProperty [ ::confVisu::getCamItem $visuNo ] binningList ]
      foreach valbin $list_binning {
         $panneau(acqfc,$visuNo,This).bin.but.menu add radiobutton -label "$valbin" \
            -indicatoron "1" \
            -value "$valbin" \
            -variable panneau(acqfc,$visuNo,bin) \
            -command " "
      }
      #---
      if { [ lsearch $list_binning $panneau(acqfc,$visuNo,bin) ] == "-1" } {
         if { [ llength $list_binning ] >= "2" } {
            set panneau(acqfc,$visuNo,bin) [ lindex $list_binning 1 ]
         } else {
            set panneau(acqfc,$visuNo,bin) [ lindex $list_binning 0 ]
         }
      }
   }
#***** Fin de la procedure Adapt_Panneau_AcqFC *****************

#***** Procedure Chargement_Var ********************************
   proc Chargement_Var { visuNo } {
      variable parametres
      global audace

      #--- Ouverture du fichier de parametres
      set fichier [ file join $audace(rep_plugin) tool acqfc acqfc.ini ]
      if { [ file exists $fichier ] } {
         source $fichier
      }

      #--- Creation des variables si elles n'existent pas
      if { ! [ info exists parametres(acqfc,$visuNo,pose) ] }           { set parametres(acqfc,$visuNo,pose)        "5" }   ; #--- Temps de pose : 5s
      if { ! [ info exists parametres(acqfc,$visuNo,bin) ] }            { set parametres(acqfc,$visuNo,bin)         "2x2" } ; #--- Binning : 2x2
      if { ! [ info exists parametres(acqfc,$visuNo,obt) ] }            { set parametres(acqfc,$visuNo,obt)         "2" }   ; #--- Obturateur : Synchro
      if { ! [ info exists parametres(acqfc,$visuNo,mode) ] }           { set parametres(acqfc,$visuNo,mode)        "1" }   ; #--- Mode : Une image
      if { ! [ info exists parametres(acqfc,$visuNo,avancement_acq) ] } {
         if { $visuNo == "1" } {
            set parametres(acqfc,$visuNo,avancement_acq) "1" ; #--- Barre de progression de la pose : Oui
         } else {
            set parametres(acqfc,$visuNo,avancement_acq) "0" ; #--- Barre de progression de la pose : Non
         }
      }
      if { ! [ info exists parametres(acqfc,$visuNo,enregistrer) ] }    { set parametres(acqfc,$visuNo,enregistrer) "1" }   ; #--- Sauvegarde des images : Oui

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      ::acqfcSetup::initToConf $visuNo
   }
#***** Fin de la procedure Chargement_Var **********************

#***** Procedure Enregistrement_Var ****************************
   proc Enregistrement_Var { visuNo } {
      variable parametres
      global audace panneau

      #---
      set panneau(acqfc,$visuNo,mode)              [ expr [ lsearch "$panneau(acqfc,$visuNo,list_mode)" "$panneau(acqfc,$visuNo,mode_en_cours)" ] + 1 ]
      #---
      set parametres(acqfc,$visuNo,pose)           $panneau(acqfc,$visuNo,pose)
      set parametres(acqfc,$visuNo,bin)            $panneau(acqfc,$visuNo,bin)
      set parametres(acqfc,$visuNo,obt)            $panneau(acqfc,$visuNo,obt)
      set parametres(acqfc,$visuNo,mode)           $panneau(acqfc,$visuNo,mode)
      set parametres(acqfc,$visuNo,avancement_acq) $panneau(acqfc,$visuNo,avancement_acq)
      set parametres(acqfc,$visuNo,enregistrer)    $panneau(acqfc,$visuNo,enregistrer)
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

#***** Procedure startTool *************************************
   proc startTool { { visuNo 1 } } {
      global conf panneau

      #--- Creation des fenetres auxiliaires si necessaire
      if { $panneau(acqfc,$visuNo,mode) == "4" } {
         ::acqfc::Intervalle_continu_1 $visuNo
      } elseif { $panneau(acqfc,$visuNo,mode) == "5" } {
         ::acqfc::Intervalle_continu_2 $visuNo
      }

      pack $panneau(acqfc,$visuNo,This) -side left -fill y
      ::acqfc::Adapt_Panneau_AcqFC $visuNo
   }
#***** Fin de la procedure startTool ***************************

#***** Procedure stopTool **************************************
   proc stopTool { { visuNo 1 } } {
      global audace conf panneau

      #--- Sauvegarde de la configuration de prise de vue
      ::acqfc::Enregistrement_Var $visuNo

      #--- Destruction des fenetres auxiliaires et sauvegarde de leurs positions si elles existent
      ::acqfc::recup_position $visuNo

      ArretAcqFC $visuNo
      pack forget $panneau(acqfc,$visuNo,This)
   }
#***** Fin de la procedure stopTool ****************************

#***** Procedure de changement du mode d'acquisition ***********
   proc ChangeMode { visuNo } {
      global panneau

      pack forget $panneau(acqfc,$visuNo,mode,$panneau(acqfc,$visuNo,mode)) -anchor nw -fill x

      set panneau(acqfc,$visuNo,mode) [ expr [ lsearch "$panneau(acqfc,$visuNo,list_mode)" "$panneau(acqfc,$visuNo,mode_en_cours)" ] + 1 ]
      if { $panneau(acqfc,$visuNo,mode) == "1" } {
         ::acqfc::recup_position $visuNo
         $panneau(acqfc,$visuNo,This).obt.dslr configure -state normal
      } elseif { $panneau(acqfc,$visuNo,mode) == "2" } {
         ::acqfc::recup_position $visuNo
         $panneau(acqfc,$visuNo,This).obt.dslr configure -state normal
      } elseif { $panneau(acqfc,$visuNo,mode) == "3" } {
         ::acqfc::recup_position $visuNo
         $panneau(acqfc,$visuNo,This).obt.dslr configure -state normal
      } elseif { $panneau(acqfc,$visuNo,mode) == "4" } {
         ::acqfc::Intervalle_continu_1 $visuNo
         $panneau(acqfc,$visuNo,This).obt.dslr configure -state normal
      } elseif { $panneau(acqfc,$visuNo,mode) == "5" } {
         ::acqfc::Intervalle_continu_2 $visuNo
         $panneau(acqfc,$visuNo,This).obt.dslr configure -state normal
      }
      pack $panneau(acqfc,$visuNo,mode,$panneau(acqfc,$visuNo,mode)) -anchor nw -fill x
   }
#***** Fin de la procedure de changement du mode d'acquisition *

#***** Procedure de changement de l'obturateur *****************
   proc ChangeObt { visuNo } {
      global audace caption conf panneau

      #---
      set camItem [ ::confVisu::getCamItem $visuNo ]
      set result [::confCam::setShutter $camItem $panneau(acqfc,$visuNo,obt) ]
      if { $result != -1 } {
         set panneau(acqfc,$visuNo,obt) $result
         $panneau(acqfc,$visuNo,This).obt.lab configure -text $panneau(acqfc,$visuNo,obt,$panneau(acqfc,$visuNo,obt))
      }
   }
#***** Fin de la procedure de changement de l'obturateur *******

#***** Procedure de test de validite d'un entier *****************
#--- Cette procedure (copiee de methking.tcl) verifie que la chaine passee en argument decrit bien un entier.
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
#--- Cette procedure (inspiree de methking.tcl) verifie que la chaine passee en argument decrit bien un reel.
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
   proc GoStop { visuNo } {
      global audace caption conf panneau

      set camItem [::confVisu::getCamItem $visuNo]

      #--- Ouverture du fichier historique
      if { $panneau(acqfc,$visuNo,save_file_log) == "1" } {
         if { $panneau(acqfc,$visuNo,session_ouverture) == "1" } {
            DemarrageAcqFC $visuNo
            set panneau(acqfc,$visuNo,session_ouverture) "0"
         }
      }

      #--- Recopie de l'extension des fichiers image
      set ext $panneau(acqfc,$visuNo,extension)

      switch $panneau(acqfc,$visuNo,go_stop) {
        go {
           #--- Desactive le bouton Go, pour eviter un double appui
           $panneau(acqfc,$visuNo,This).go_stop.but configure -state disabled

           #------ Tests generaux de l'integrite de la requete
           set integre oui

           #--- Tester si une camera est bien selectionnee
           if { [ ::confVisu::getCamItem $visuNo ] == "" } {
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
           if { $panneau(acqfc,$visuNo,pose) == "" } {
              tk_messageBox -title $caption(acqfc,pb) -type ok \
                 -message $caption(acqfc,saistps)
              set integre non
           }
           #--- Le champ "temps de pose" est-il bien un reel positif ?
           if { [ TestReel $panneau(acqfc,$visuNo,pose) ] == "0" } {
              tk_messageBox -title $caption(acqfc,pb) -type ok \
                 -message $caption(acqfc,Tpsinv)
              set integre non
           }

           #--- Tests d'integrite specifiques a chaque mode d'acquisition
           if { $integre == "oui" } {
              #--- Branchement selon le mode de prise de vue
              switch $panneau(acqfc,$visuNo,mode) {
                 1  {
                    #--- Mode une image
                    if { $panneau(acqfc,$visuNo,indexer) == "1" } {
                       #--- Verifie que l'index existe
                       if { $panneau(acqfc,$visuNo,index) == "" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,saisind)
                          set integre non
                       }
                       #--- Verifier que l'index est valide (entier positif)
                       if { [ TestEntier $panneau(acqfc,$visuNo,index) ] == "0" } {
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
                    if { $panneau(acqfc,$visuNo,nom_image) == "" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,donnomfich)
                       set integre non
                    }
                    #--- Verifier que le nom de fichier n'a pas d'espace
                    if { [ llength $panneau(acqfc,$visuNo,nom_image) ] > "1" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,nomblanc)
                       set integre non
                    }
                    #--- Verifier que le nom de fichier ne contient pas de caracteres interdits
                    if { [ TestChaine $panneau(acqfc,$visuNo,nom_image) ] == "0" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,mauvcar)
                       set integre non
                    }
                    #--- Verifier que le nombre de poses est valide (nombre entier)
                    if { [ TestEntier $panneau(acqfc,$visuNo,nb_images) ] == "0" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,nbinv)
                       set integre non
                    }
                    #--- Verifier que l'index existe
                    if { $panneau(acqfc,$visuNo,index) == "" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,saisind)
                       set integre non
                    }
                    #--- Verifier que l'index est valide (entier positif)
                    if { [ TestEntier $panneau(acqfc,$visuNo,index) ] == "0" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,indinv)
                       set integre non
                    }
                    #--- Envoyer un warning si l'index n'est pas a 1
                    if { $panneau(acqfc,$visuNo,index) != "1" } {
                       set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                          -message $caption(acqfc,indpasun)]
                       if { $confirmation == "no" } {
                          set integre non
                       }
                    }
                    #--- Verifier que le nom des fichiers n'existe pas
                    set nom $panneau(acqfc,$visuNo,nom_image)
                    #--- Pour eviter un nom de fichier qui commence par un blanc
                    set nom [lindex $nom 0]
                    append nom $panneau(acqfc,$visuNo,index) $ext
                    if { [ file exists [ file join $audace(rep_images) $nom ] ] == "1" } {
                       #--- Dans ce cas, le fichier existe deja
                       set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                          -message $caption(acqfc,fichdeja)]
                       if { $confirmation == "no" } {
                          set integre non
                       }
                    }
                    #--- Tester si un telescope est bien selectionnee si l'option decalage est selectionnee
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
                    if { $panneau(acqfc,$visuNo,enregistrer) == "1" } {
                       #--- Verifier qu'il y a bien un nom de fichier
                       if { $panneau(acqfc,$visuNo,nom_image) == "" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,donnomfich)
                          set integre non
                       }
                       #--- Verifier que le nom de fichier n'a pas d'espace
                       if { [ llength $panneau(acqfc,$visuNo,nom_image) ] > "1" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,nomblanc)
                          set integre non
                       }
                       #--- Verifier que le nom de fichier ne contient pas de caracteres interdits
                       if { [ TestChaine $panneau(acqfc,$visuNo,nom_image) ] == "0" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,mauvcar)
                          set integre non
                       }
                       #--- Verifier que l'index existe
                       if { $panneau(acqfc,$visuNo,index) == "" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,saisind)
                          set integre non
                       }
                       #--- Verifier que l'index est valide (entier positif)
                       if { [ TestEntier $panneau(acqfc,$visuNo,index) ] == "0" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,indinv)
                          set integre non
                       }
                       #--- Envoyer un warning si l'index n'est pas a 1
                       if { $panneau(acqfc,$visuNo,index) != "1" } {
                          set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                             -message $caption(acqfc,indpasun)]
                          if { $confirmation == "no" } {
                             set integre non
                          }
                       }
                       #--- Verifier que le nom des fichiers n'existe pas
                       set nom $panneau(acqfc,$visuNo,nom_image)
                       #--- Pour eviter un nom de fichier qui commence par un blanc
                       set nom [lindex $nom 0]
                       append nom $panneau(acqfc,$visuNo,index) $ext
                       if { [ file exists [ file join $audace(rep_images) $nom ] ] == "1" } {
                          #--- Dans ce cas, le fichier existe deja
                          set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                             -message $caption(acqfc,fichdeja)]
                          if { $confirmation == "no" } {
                             set integre non
                          }
                       }
                    }
                    #--- Tester si un telescope est bien selectionnee si l'option decalage est selectionnee
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
                    if { $panneau(acqfc,$visuNo,nom_image) == "" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,donnomfich)
                       set integre non
                    }
                    #--- Verifier que le nom de fichier n'a pas d'espace
                    if { [ llength $panneau(acqfc,$visuNo,nom_image) ] > "1" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,nomblanc)
                       set integre non
                    }
                    #--- Verifier que le nom de fichier ne contient pas de caracteres interdits
                    if { [ TestChaine $panneau(acqfc,$visuNo,nom_image) ] == "0" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,mauvcar)
                       set integre non
                    }
                    #--- Verifier que le nombre de poses est valide (nombre entier)
                    if { [ TestEntier $panneau(acqfc,$visuNo,nb_images) ] == "0"} {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,nbinv)
                       set integre non
                    }
                    #--- Verifier que l'index existe
                    if { $panneau(acqfc,$visuNo,index) == "" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,saisind)
                       set integre non
                    }
                    #--- Verifier que l'index est valide (entier positif)
                    if { [ TestEntier $panneau(acqfc,$visuNo,index) ] == "0" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,indinv)
                       set integre non
                    }
                    #--- Envoyer un warning si l'index n'est pas a 1
                    if { $panneau(acqfc,$visuNo,index) != "1" } {
                       set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                          -message $caption(acqfc,indpasun)]
                       if { $confirmation == "no" } {
                          set integre non
                       }
                    }
                    #--- Verifier que la simulation a ete lancee
                    if { $panneau(acqfc,$visuNo,intervalle) == "....." } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,interinv_2)
                       set integre non
                    #--- Verifier que l'intervalle est valide (entier positif)
                    } elseif { [ TestEntier $panneau(acqfc,$visuNo,intervalle_1) ] == "0" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,interinv)
                       set integre non
                    #--- Verifier que l'intervalle est superieur a celui calcule par la simulation
                    } elseif { ( $panneau(acqfc,$visuNo,intervalle) > $panneau(acqfc,$visuNo,intervalle_1) ) && \
                      ( $panneau(acqfc,$visuNo,intervalle) != "xxx" ) } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,interinv_1)
                          set integre non
                    }
                    #--- Verifier que le nom des fichiers n'existe pas
                    set nom $panneau(acqfc,$visuNo,nom_image)
                    #--- Pour eviter un nom de fichier qui commence par un blanc
                    set nom [lindex $nom 0]
                    append nom $panneau(acqfc,$visuNo,index) $ext
                    if { [ file exists [ file join $audace(rep_images) $nom ] ] == "1" } {
                       #--- Dans ce cas, le fichier existe deja
                       set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                          -message $caption(acqfc,fichdeja)]
                       if { $confirmation == "no" } {
                          set integre non
                       }
                    }
                    #--- Tester si un telescope est bien selectionnee si l'option decalage est selectionnee
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
                    if { $panneau(acqfc,$visuNo,enregistrer) == "1" } {
                       #--- Verifier qu'il y a bien un nom de fichier
                       if { $panneau(acqfc,$visuNo,nom_image) == "" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,donnomfich)
                          set integre non
                       }
                       #--- Verifier que le nom de fichier n'a pas d'espace
                       if { [ llength $panneau(acqfc,$visuNo,nom_image) ] > "1" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,nomblanc)
                          set integre non
                       }
                       #--- Verifier que le nom de fichier ne contient pas de caracteres interdits
                       if { [ TestChaine $panneau(acqfc,$visuNo,nom_image) ] == "0" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,mauvcar)
                          set integre non
                       }
                       #--- Verifier que l'index existe
                       if { $panneau(acqfc,$visuNo,index) == "" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,saisind)
                          set integre non
                       }
                       #--- Verifier que l'index est valide (entier positif)
                       if { [ TestEntier $panneau(acqfc,$visuNo,index) ] == "0" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,indinv)
                          set integre non
                       }
                       #--- Envoyer un warning si l'index n'est pas a 1
                       if { $panneau(acqfc,$visuNo,index) != "1" } {
                          set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                             -message $caption(acqfc,indpasun)]
                          if { $confirmation == "no" } {
                             set integre non
                          }
                       }
                       #--- Verifier que la simulation a ete lancee
                       if { $panneau(acqfc,$visuNo,intervalle) == "....." } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,interinv_2)
                          set integre non
                       #--- Verifier que l'intervalle est valide (entier positif)
                       } elseif { [ TestEntier $panneau(acqfc,$visuNo,intervalle_2) ] == "0" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,interinv)
                          set integre non
                       #--- Verifier que l'intervalle est superieur a celui calcule par la simulation
                       } elseif { ( $panneau(acqfc,$visuNo,intervalle) > $panneau(acqfc,$visuNo,intervalle_2) ) && \
                         ( $panneau(acqfc,$visuNo,intervalle) != "xxx" ) } {
                             tk_messageBox -title $caption(acqfc,pb) -type ok \
                                -message $caption(acqfc,interinv_1)
                             set integre non
                       }
                       #--- Verifier que le nom des fichiers n'existe pas deja
                       set nom $panneau(acqfc,$visuNo,nom_image)
                       #--- Pour eviter un nom de fichier qui commence par un blanc
                       set nom [lindex $nom 0]
                       append nom $panneau(acqfc,$visuNo,index) $ext
                       if { [ file exists [ file join $audace(rep_images) $nom ] ] == "1" } {
                          #--- Dans ce cas, le fichier existe deja
                          set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                             -message $caption(acqfc,fichdeja)]
                          if { $confirmation == "no" } {
                             set integre non
                          }
                       }
                    } else {
                       #--- Verifier que la simulation a ete lancee
                       if { $panneau(acqfc,$visuNo,intervalle) == "....." } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,interinv_2)
                          set integre non
                       #--- Verifier que l'intervalle est valide (entier positif)
                       } elseif { [ TestEntier $panneau(acqfc,$visuNo,intervalle_2) ] == "0" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,interinv)
                          set integre non
                       #--- Verifier que l'intervalle est superieur a celui calcule par la simulation
                       } elseif { ( $panneau(acqfc,$visuNo,intervalle) > $panneau(acqfc,$visuNo,intervalle_2) ) && \
                         ( $panneau(acqfc,$visuNo,intervalle) != "xxx" ) } {
                             tk_messageBox -title $caption(acqfc,pb) -type ok \
                                -message $caption(acqfc,interinv_1)
                             set integre non
                       }
                    }
                    #--- Tester si un telescope est bien selectionnee si l'option decalage est selectionnee
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
              }
           }
           #------ Fin des tests de l'integrite de la requete

           #--- Apres les tests d'integrite, je reactive le bouton "GO"
           $panneau(acqfc,$visuNo,This).go_stop.but configure -state normal
           #--- Apres tous les tests d'integrite, je peux maintenant lancer les acquisitions
           if { $integre == "oui" } {
              #--- Modification du bouton, pour eviter un second lancement
              set panneau(acqfc,$visuNo,go_stop) stop
              $panneau(acqfc,$visuNo,This).go_stop.but configure -text $caption(acqfc,stop)
              #--- Verrouille tous les boutons et champs de texte pendant les acquisitions
              $panneau(acqfc,$visuNo,This).pose.but configure -state disabled
              $panneau(acqfc,$visuNo,This).pose.entr configure -state disabled
              $panneau(acqfc,$visuNo,This).bin.but configure -state disabled
              $panneau(acqfc,$visuNo,This).obt.but configure -state disabled
              $panneau(acqfc,$visuNo,This).mode.but configure -state disabled
              #--- Desactive toute demande d'arret
              set panneau(acqfc,$visuNo,demande_arret) "0"
              #--- Pose en cours
              set panneau(acqfc,$visuNo,pose_en_cours) "1"
              #--- Cas particulier du passage WebCam LP en WebCam normale pour inhiber la barre progression
              set camNo $panneau(acqfc,$visuNo,camNo)
              if { ( [::confCam::getPluginProperty $camItem "hasVideo"] == 1 ) && ( [ confCam::getPluginProperty [ ::confVisu::getCamItem $visuNo ] longExposure ] == "0" ) } {
                 set panneau(acqfc,$visuNo,pose) "0"
              }
              #--- Branchement selon le mode de prise de vue
              switch $panneau(acqfc,$visuNo,mode) {
                 1  {
                    #--- Mode une image
                    #--- Verrouille les boutons du mode "une image"
                    $panneau(acqfc,$visuNo,This).mode.une.nom.entr configure -state disabled
                    $panneau(acqfc,$visuNo,This).mode.une.index.case configure -state disabled
                    $panneau(acqfc,$visuNo,This).mode.une.index.entr configure -state disabled
                    $panneau(acqfc,$visuNo,This).mode.une.index.but configure -state disabled
                    $panneau(acqfc,$visuNo,This).mode.une.sauve configure -state disabled
                    set heure $audace(tu,format,hmsint)
                    Message $visuNo consolog $caption(acqfc,acquneim) \
                       $panneau(acqfc,$visuNo,pose) $panneau(acqfc,$visuNo,bin) $heure
                    acq $visuNo $panneau(acqfc,$visuNo,pose) $panneau(acqfc,$visuNo,bin)
                    #--- Deverrouille les boutons du mode "une image"
                    $panneau(acqfc,$visuNo,This).mode.une.nom.entr configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.une.index.case configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.une.index.entr configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.une.index.but configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.une.sauve configure -state normal
                    #--- Pose en cours
                    set panneau(acqfc,$visuNo,pose_en_cours) "0"
                 }
                 2  {
                    #--- Mode serie
                    #--- Verrouille les boutons du mode "serie"
                    $panneau(acqfc,$visuNo,This).mode.serie.nom.entr configure -state disabled
                    $panneau(acqfc,$visuNo,This).mode.serie.nb.entr configure -state disabled
                    $panneau(acqfc,$visuNo,This).mode.serie.index.entr configure -state disabled
                    $panneau(acqfc,$visuNo,This).mode.serie.index.but configure -state disabled
                    set heure $audace(tu,format,hmsint)
                    if { $panneau(acqfc,$visuNo,simulation) == "1" } {
                       Message $visuNo consolog $caption(acqfc,lance_simu)
                    }
                    Message $visuNo consolog $caption(acqfc,lanceserie) \
                       $panneau(acqfc,$visuNo,nb_images) $heure
                    Message $visuNo consolog $caption(acqfc,nomgen) $panneau(acqfc,$visuNo,nom_image) \
                       $panneau(acqfc,$visuNo,pose) $panneau(acqfc,$visuNo,bin) $panneau(acqfc,$visuNo,index)
                    #--- Debut de la premiere pose
                    if { $panneau(acqfc,$visuNo,simulation) == "1" } {
                       set panneau(acqfc,$visuNo,debut) [ clock second ]
                    }
                    for { set i 1 } { ( $i <= $panneau(acqfc,$visuNo,nb_images) ) && ( $panneau(acqfc,$visuNo,demande_arret) == "0" ) } { incr i } {
                       acq $visuNo $panneau(acqfc,$visuNo,pose) $panneau(acqfc,$visuNo,bin)
                       #--- Je dois encore sauvegarder l'image
                       $panneau(acqfc,$visuNo,This).status.lab configure -text $caption(acqfc,enreg)
                       set nom $panneau(acqfc,$visuNo,nom_image)
                       #--- Pour eviter un nom de fichier qui commence par un blanc
                       set nom [lindex $nom 0]
                       if { $panneau(acqfc,$visuNo,simulation) == "0" } {
                          #--- Verifie que le nom du fichier n'existe pas
                          set nom1 "$nom"
                          append nom1 $panneau(acqfc,$visuNo,index) $ext
                          if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
                             #--- Dans ce cas, le fichier existe deja
                             set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                                -message $caption(acqfc,fichdeja)]
                             if { $confirmation == "no" } {
                                break
                             }
                          }
                          #--- Sauvegarde de l'image
                          saveima [append nom $panneau(acqfc,$visuNo,index)$panneau(acqfc,$visuNo,extension)] $visuNo
                          set heure $audace(tu,format,hmsint)
                          Message $visuNo consolog $caption(acqfc,enrim) $heure $nom
                       }
                       incr panneau(acqfc,$visuNo,index)
                       $panneau(acqfc,$visuNo,This).status.lab configure -text ""
                       if { $panneau(acqfc,$visuNo,simulation) == "0" } {
                          if { $i != "$panneau(acqfc,$visuNo,nb_images)" } {
                             #--- Deplacement du telescope
                             ::DlgShift::Decalage_Telescope
                          }
                       } elseif { $panneau(acqfc,$visuNo,simulation) == "1" } {
                          #--- Deplacement du telescope
                          ::DlgShift::Decalage_Telescope
                       }
                    }
                    #--- Fin de la derniere pose et intervalle mini entre 2 poses ou 2 series
                    if { $panneau(acqfc,$visuNo,simulation) == "1" } {
                       set panneau(acqfc,$visuNo,fin) [ clock second ]
                       set panneau(acqfc,$visuNo,intervalle) [ expr $panneau(acqfc,$visuNo,fin) - $panneau(acqfc,$visuNo,debut) ]
                       Message $visuNo consolog $caption(acqfc,fin_simu)
                    }
                    #--- Cas particulier des cameras APN (DSLR)
                    if { $conf(dslr,telecharge_mode) == "3" } {
                       #--- Chargement de la derniere image
                       set result [ catch { cam$panneau(acqfc,$visuNo,camNo) loadlastimage } msg ]
                       if { $result == "1" } {
                          ::console::disp "::acqfc::GoStop loadlastimage $msg \n"
                       } else {
                          ::console::disp "::acqfc::GoStop loadlastimage OK \n"
                       }
                       #--- Visualisation de l'image
                       ::audace::autovisu $visuNo
                    }
                    #--- Deverrouille les boutons du mode "serie"
                    $panneau(acqfc,$visuNo,This).mode.serie.nom.entr configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.serie.nb.entr configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.serie.index.entr configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.serie.index.but configure -state normal
                    #--- Pose en cours
                    set panneau(acqfc,$visuNo,pose_en_cours) "0"
                 }
                 3  {
                    #--- Mode continu
                    #--- Verrouille les boutons du mode "continu"
                    $panneau(acqfc,$visuNo,This).mode.continu.sauve.case configure -state disabled
                    $panneau(acqfc,$visuNo,This).mode.continu.nom.entr configure -state disabled
                    $panneau(acqfc,$visuNo,This).mode.continu.index.entr configure -state disabled
                    $panneau(acqfc,$visuNo,This).mode.continu.index.but configure -state disabled
                    set heure $audace(tu,format,hmsint)
                    Message $visuNo consolog $caption(acqfc,lancecont) $panneau(acqfc,$visuNo,pose) $panneau(acqfc,$visuNo,bin) $heure
                    if { $panneau(acqfc,$visuNo,enregistrer) == "1" } {
                       Message $visuNo consolog $caption(acqfc,enregen) \
                         $panneau(acqfc,$visuNo,nom_image)
                    } else {
                       Message $visuNo consolog $caption(acqfc,sansenr)
                    }
                    while { ( $panneau(acqfc,$visuNo,demande_arret) == "0" ) && ( $panneau(acqfc,$visuNo,mode) == "3" ) } {
                       acq $visuNo $panneau(acqfc,$visuNo,pose) $panneau(acqfc,$visuNo,bin)
                       #--- Je dois encore sauvegarder l'image
                       if { $panneau(acqfc,$visuNo,enregistrer) == "1" } {
                          $panneau(acqfc,$visuNo,This).status.lab configure -text $caption(acqfc,enreg)
                          set nom $panneau(acqfc,$visuNo,nom_image)
                          #--- Pour eviter un nom de fichier qui commence par un blanc
                          set nom [lindex $nom 0]
                          if { $panneau(acqfc,$visuNo,demande_arret) == "0" } {
                             #--- Verifie que le nom du fichier n'existe pas
                             set nom1 "$nom"
                             append nom1 $panneau(acqfc,$visuNo,index) $ext
                             if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
                                #--- Dans ce cas, le fichier existe deja
                                set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                                   -message $caption(acqfc,fichdeja)]
                                if { $confirmation == "no" } {
                                   break
                                }
                             }
                             #--- Sauvegarde de l'image
                             saveima [append nom $panneau(acqfc,$visuNo,index)$panneau(acqfc,$visuNo,extension)] $visuNo
                          } else {
                             set panneau(acqfc,$visuNo,index) [ expr $panneau(acqfc,$visuNo,index) - 1 ]
                          }
                          incr panneau(acqfc,$visuNo,index)
                          $panneau(acqfc,$visuNo,This).status.lab configure -text ""
                          set heure $audace(tu,format,hmsint)
                          if { $panneau(acqfc,$visuNo,demande_arret) == "0" } {
                             Message $visuNo consolog $caption(acqfc,enrim) $heure $nom
                          }
                       }
                       #--- Deplacement du telescope
                       ::DlgShift::Decalage_Telescope
                    }
                    #--- Cas particulier des cameras APN (DSLR)
                    if { $conf(dslr,telecharge_mode) == "3" } {
                       #--- Chargement de la derniere image
                       set result [ catch { cam$panneau(acqfc,$visuNo,camNo) loadlastimage } msg ]
                       if { $result == "1" } {
                          ::console::disp "::acqfc::GoStop loadlastimage $msg \n"
                       } else {
                          ::console::disp "::acqfc::GoStop loadlastimage OK \n"
                       }
                       #--- Visualisation de l'image
                       ::audace::autovisu $visuNo
                    }
                    #--- Deverrouille les boutons du mode "continu"
                    $panneau(acqfc,$visuNo,This).mode.continu.sauve.case configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.continu.nom.entr configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.continu.index.entr configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.continu.index.but configure -state normal
                    #--- Pose en cours
                    set panneau(acqfc,$visuNo,pose_en_cours) "0"
                 }
                 4  {
                    #--- Mode series d'images en continu avec intervalle entre chaque serie
                    #--- Verrouille les boutons du mode "continu 1"
                    $panneau(acqfc,$visuNo,This).mode.serie_1.nom.entr configure -state disabled
                    $panneau(acqfc,$visuNo,This).mode.serie_1.nb.entr configure -state disabled
                    $panneau(acqfc,$visuNo,This).mode.serie_1.index.entr configure -state disabled
                    $panneau(acqfc,$visuNo,This).mode.serie_1.index.but configure -state disabled
                    set heure $audace(tu,format,hmsint)
                    Message $visuNo consolog $caption(acqfc,lanceserie_int) \
                       $panneau(acqfc,$visuNo,nb_images) $panneau(acqfc,$visuNo,intervalle_1) $heure
                    Message $visuNo consolog $caption(acqfc,nomgen) $panneau(acqfc,$visuNo,nom_image) \
                       $panneau(acqfc,$visuNo,pose) $panneau(acqfc,$visuNo,bin) $panneau(acqfc,$visuNo,index)
                    while { ( $panneau(acqfc,$visuNo,demande_arret) == "0" ) && ( $panneau(acqfc,$visuNo,mode) == "4" ) } {
                       set panneau(acqfc,$visuNo,deb_im) [ clock second ]
                       for { set i 1 } { ( $i <= $panneau(acqfc,$visuNo,nb_images) ) && ( $panneau(acqfc,$visuNo,demande_arret) == "0" ) } { incr i } {
                          acq $visuNo $panneau(acqfc,$visuNo,pose) $panneau(acqfc,$visuNo,bin)
                          #--- Je dois encore sauvegarder l'image
                          $panneau(acqfc,$visuNo,This).status.lab configure -text $caption(acqfc,enreg)
                          set nom $panneau(acqfc,$visuNo,nom_image)
                          #--- Pour eviter un nom de fichier qui commence par un blanc
                          set nom [lindex $nom 0]
                          #--- Verifie que le nom du fichier n'existe pas
                          set nom1 "$nom"
                          append nom1 $panneau(acqfc,$visuNo,index) $ext
                          if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
                             #--- Dans ce cas, le fichier existe deja
                             set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                                -message $caption(acqfc,fichdeja)]
                             if { $confirmation == "no" } {
                                break
                             }
                          }
                          #--- Sauvegarde de l'image
                          saveima [append nom $panneau(acqfc,$visuNo,index)$panneau(acqfc,$visuNo,extension)] $visuNo
                          incr panneau(acqfc,$visuNo,index)
                          $panneau(acqfc,$visuNo,This).status.lab configure -text ""
                          set heure $audace(tu,format,hmsint)
                          Message $visuNo consolog $caption(acqfc,enrim) $heure $nom
                          #--- Deplacement du telescope
                          ::DlgShift::Decalage_Telescope
                       }
                       set panneau(acqfc,$visuNo,attente_pose) "1"
                       set panneau(acqfc,$visuNo,fin_im) [ clock second ]
                       set panneau(acqfc,$visuNo,intervalle_im_1) [ expr $panneau(acqfc,$visuNo,fin_im) - $panneau(acqfc,$visuNo,deb_im) ]
                       while { ( $panneau(acqfc,$visuNo,demande_arret) == "0" ) && ( $panneau(acqfc,$visuNo,intervalle_im_1) <= $panneau(acqfc,$visuNo,intervalle_1) ) } {
                          after 500
                          set panneau(acqfc,$visuNo,fin_im) [ clock second ]
                          set panneau(acqfc,$visuNo,intervalle_im_1) [ expr $panneau(acqfc,$visuNo,fin_im) - $panneau(acqfc,$visuNo,deb_im) + 1 ]
                          set t [ expr $panneau(acqfc,$visuNo,intervalle_1) - $panneau(acqfc,$visuNo,intervalle_im_1) ]
                          ::acqfc::Avancement_pose $visuNo $t
                       }
                       set panneau(acqfc,$visuNo,attente_pose) "0"
                    }
                    #--- Cas particulier des cameras APN (DSLR)
                    if { $conf(dslr,telecharge_mode) == "3" } {
                       #--- Chargement de la derniere image
                       set result [ catch { cam$panneau(acqfc,$visuNo,camNo) loadlastimage } msg ]
                       if { $result == "1" } {
                          ::console::disp "::acqfc::GoStop loadlastimage $msg \n"
                       } else {
                          ::console::disp "::acqfc::GoStop loadlastimage OK \n"
                       }
                       #--- Visualisation de l'image
                       ::audace::autovisu $visuNo
                    }
                    #--- Deverrouille les boutons du mode "continu 1"
                    $panneau(acqfc,$visuNo,This).mode.serie_1.nom.entr configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.serie_1.nb.entr configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.serie_1.index.entr configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.serie_1.index.but configure -state normal
                    #--- Pose en cours
                    set panneau(acqfc,$visuNo,pose_en_cours) "0"
                 }
                 5  {
                    #--- Mode continu avec intervalle entre chaque image
                    #--- Verrouille les boutons du mode "continu 2"
                    $panneau(acqfc,$visuNo,This).mode.continu_1.sauve.case configure -state disabled
                    $panneau(acqfc,$visuNo,This).mode.continu_1.nom.entr configure -state disabled
                    $panneau(acqfc,$visuNo,This).mode.continu_1.index.entr configure -state disabled
                    $panneau(acqfc,$visuNo,This).mode.continu_1.index.but configure -state disabled
                    set heure $audace(tu,format,hmsint)
                    Message $visuNo consolog $caption(acqfc,lancecont_int) $panneau(acqfc,$visuNo,intervalle_2) \
                       $panneau(acqfc,$visuNo,pose) $panneau(acqfc,$visuNo,bin) $heure
                    if { $panneau(acqfc,$visuNo,enregistrer) == "1" } {
                       Message $visuNo consolog $caption(acqfc,enregen) \
                         $panneau(acqfc,$visuNo,nom_image)
                    } else {
                       Message $visuNo consolog $caption(acqfc,sansenr)
                    }
                    while { ( $panneau(acqfc,$visuNo,demande_arret) == "0" ) && ( $panneau(acqfc,$visuNo,mode) == "5" ) } {
                       set panneau(acqfc,$visuNo,deb_im) [ clock second ]
                       acq $visuNo $panneau(acqfc,$visuNo,pose) $panneau(acqfc,$visuNo,bin)
                       #--- Je dois encore sauvegarder l'image
                       if { $panneau(acqfc,$visuNo,enregistrer) == "1" } {
                          $panneau(acqfc,$visuNo,This).status.lab configure -text $caption(acqfc,enreg)
                          set nom $panneau(acqfc,$visuNo,nom_image)
                          #--- Pour eviter un nom de fichier qui commence par un blanc
                          set nom [lindex $nom 0]
                          if { $panneau(acqfc,$visuNo,demande_arret) == "0" } {
                             #--- Verifie que le nom du fichier n'existe pas
                             set nom1 "$nom"
                             append nom1 $panneau(acqfc,$visuNo,index) $ext
                             if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
                                #--- Dans ce cas, le fichier existe deja
                                set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                                   -message $caption(acqfc,fichdeja)]
                                if { $confirmation == "no" } {
                                   break
                                }
                             }
                             #--- Sauvegarde de l'image
                             saveima [append nom $panneau(acqfc,$visuNo,index)$panneau(acqfc,$visuNo,extension)] $visuNo
                          } else {
                             set panneau(acqfc,$visuNo,index) [ expr $panneau(acqfc,$visuNo,index) - 1 ]
                          }
                          incr panneau(acqfc,$visuNo,index)
                          $panneau(acqfc,$visuNo,This).status.lab configure -text ""
                          set heure $audace(tu,format,hmsint)
                          if { $panneau(acqfc,$visuNo,demande_arret) == "0" } {
                             Message $visuNo consolog $caption(acqfc,enrim) $heure $nom
                          }
                       }
                       #--- Deplacement du telescope
                       ::DlgShift::Decalage_Telescope
                       set panneau(acqfc,$visuNo,attente_pose) "1"
                       set panneau(acqfc,$visuNo,fin_im) [ clock second ]
                       set panneau(acqfc,$visuNo,intervalle_im_2) [ expr $panneau(acqfc,$visuNo,fin_im) - $panneau(acqfc,$visuNo,deb_im) ]
                       while { ( $panneau(acqfc,$visuNo,demande_arret) == "0" ) && ( $panneau(acqfc,$visuNo,intervalle_im_2) <= $panneau(acqfc,$visuNo,intervalle_2) ) } {
                          after 500
                          set panneau(acqfc,$visuNo,fin_im) [ clock second ]
                          set panneau(acqfc,$visuNo,intervalle_im_2) [ expr $panneau(acqfc,$visuNo,fin_im) - $panneau(acqfc,$visuNo,deb_im) + 1 ]
                          set t [ expr $panneau(acqfc,$visuNo,intervalle_2) - $panneau(acqfc,$visuNo,intervalle_im_2) ]
                          ::acqfc::Avancement_pose $visuNo $t
                       }
                       set panneau(acqfc,$visuNo,attente_pose) "0"
                    }
                    set heure $audace(tu,format,hmsint)
                    Message $visuNo consolog $caption(acqfc,arrcont) $heure
                    if { $panneau(acqfc,$visuNo,enregistrer) == "1" } {
                       set panneau(acqfc,$visuNo,index) [ expr $panneau(acqfc,$visuNo,index) - 1 ]
                       Message $visuNo consolog $caption(acqfc,dersauve) [append nom $panneau(acqfc,$visuNo,index)]
                       set panneau(acqfc,$visuNo,index) [ expr $panneau(acqfc,$visuNo,index) + 1 ]
                    }
                    #--- Cas particulier des cameras APN (DSLR)
                    if { $conf(dslr,telecharge_mode) == "3" } {
                       #--- Chargement de la derniere image
                       set result [ catch { cam$panneau(acqfc,$visuNo,camNo) loadlastimage } msg ]
                       if { $result == "1" } {
                          ::console::disp "::acqfc::GoStop loadlastimage $msg \n"
                       } else {
                          ::console::disp "::acqfc::GoStop loadlastimage OK \n"
                       }
                       #--- Visualisation de l'image
                       ::audace::autovisu $visuNo
                    }
                    #--- Deverrouille les boutons du mode "continu 2"
                    $panneau(acqfc,$visuNo,This).mode.continu_1.sauve.case configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.continu_1.nom.entr configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.continu_1.index.entr configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.continu_1.index.but configure -state normal
                    #--- Pose en cours
                    set panneau(acqfc,$visuNo,pose_en_cours) "0"
                 }
              }
              #--- Deverrouille tous les boutons et champs de texte pendant les acquisitions
              $panneau(acqfc,$visuNo,This).pose.but configure -state normal
              $panneau(acqfc,$visuNo,This).pose.entr configure -state normal
              $panneau(acqfc,$visuNo,This).bin.but configure -state normal
              $panneau(acqfc,$visuNo,This).obt.but configure -state normal
              $panneau(acqfc,$visuNo,This).mode.but configure -state normal
              #--- Je restitue l'affichage du bouton "GO"
              set panneau(acqfc,$visuNo,go_stop) go
              $panneau(acqfc,$visuNo,This).go_stop.but configure -text $caption(acqfc,GO)
              #--- J'autorise le bouton "GO"
              $panneau(acqfc,$visuNo,This).go_stop.but configure -state normal
           }
        }
        stop {
           #--- Je desactive le bouton "STOP"
           $panneau(acqfc,$visuNo,This).go_stop.but configure -state disabled
           #--- J'arrete l'acquisition
           ArretImage $visuNo
           switch $panneau(acqfc,$visuNo,mode) {
              1  {
                 #--- Mode une image
                    #--- Message suite a l'arret
                    set heure $audace(tu,format,hmsint)
                    if { $panneau(acqfc,$visuNo,pose_en_cours) == "1" } {
                       console::affiche_saut "\n"
                       Message $visuNo consolog $caption(acqfc,arrprem) $heure
                       Message $visuNo consolog $caption(acqfc,lg_pose_arret) [ lindex [ buf[ ::confVisu::getBufNo $visuNo ] getkwd EXPOSURE ] 1 ]
                    }
                    #--- Deverrouille les boutons du mode "une image"
                    $panneau(acqfc,$visuNo,This).mode.une.nom.entr configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.une.index.case configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.une.index.entr configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.une.index.but configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.une.sauve configure -state normal
              }
              2  {
                 #--- Mode serie
                    #--- Message suite a l'arret
                    set heure $audace(tu,format,hmsint)
                    if { $panneau(acqfc,$visuNo,pose_en_cours) == "1" } {
                       console::affiche_saut "\n"
                       Message $visuNo consolog $caption(acqfc,arrprem) $heure
                    }
                    #--- Deverrouille les boutons du mode "serie"
                    $panneau(acqfc,$visuNo,This).mode.serie.nom.entr configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.serie.nb.entr configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.serie.index.entr configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.serie.index.but configure -state normal
              }
              3  {
                 #--- Mode continu
                    #--- Message suite a l'arret
                    set heure $audace(tu,format,hmsint)
                    if { $panneau(acqfc,$visuNo,pose_en_cours) == "1" } {
                       console::affiche_saut "\n"
                       Message $visuNo consolog $caption(acqfc,arrprem) $heure
                       if { $panneau(acqfc,$visuNo,enregistrer) == "1" } {
                          set index [ expr $panneau(acqfc,$visuNo,index) - 1 ]
                          set nom [lindex $panneau(acqfc,$visuNo,nom_image) 0]
                          Message $visuNo consolog $caption(acqfc,dersauve) [append nom $index]
                       } else {
                          Message $visuNo consolog $caption(acqfc,lg_pose_arret) [ lindex [ buf[ ::confVisu::getBufNo $visuNo ] getkwd EXPOSURE ] 1 ]
                       }
                    }
                    #--- Deverrouille les boutons du mode "continu"
                    $panneau(acqfc,$visuNo,This).mode.continu.sauve.case configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.continu.nom.entr configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.continu.index.entr configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.continu.index.but configure -state normal
              }
              4  {
                 #--- Mode series d'images en continu avec intervalle entre chaque serie
                    #--- Message suite a l'arret
                    set heure $audace(tu,format,hmsint)
                    if { $panneau(acqfc,$visuNo,pose_en_cours) == "1" } {
                       console::affiche_saut "\n"
                       Message $visuNo consolog $caption(acqfc,arrprem) $heure
                       set i $panneau(acqfc,$visuNo,nb_images)
                    }
                    #--- Deverrouille les boutons du mode "continu 1"
                    $panneau(acqfc,$visuNo,This).mode.serie_1.nom.entr configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.serie_1.nb.entr configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.serie_1.index.entr configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.serie_1.index.but configure -state normal
              }
              5  {
                 #--- Mode continu avec intervalle entre chaque image
                    #--- Message suite a l'arret
                    set heure $audace(tu,format,hmsint)
                    if { $panneau(acqfc,$visuNo,pose_en_cours) == "1" } {
                       console::affiche_saut "\n"
                       if { $panneau(acqfc,$visuNo,enregistrer) == "0" } {
                          Message $visuNo consolog $caption(acqfc,lg_pose_arret) [ lindex [ buf[ ::confVisu::getBufNo $visuNo ] getkwd EXPOSURE ] 1 ]
                       }
                    }
                    #--- Deverrouille les boutons du mode "continu 2"
                    $panneau(acqfc,$visuNo,This).mode.continu_1.sauve.case configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.continu_1.nom.entr configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.continu_1.index.entr configure -state normal
                    $panneau(acqfc,$visuNo,This).mode.continu_1.index.but configure -state normal
              }
           }
           #--- Deverrouille tous les boutons et champs de texte pendant les acquisitions
           $panneau(acqfc,$visuNo,This).pose.but configure -state normal
           $panneau(acqfc,$visuNo,This).pose.entr configure -state normal
           $panneau(acqfc,$visuNo,This).bin.but configure -state normal
           $panneau(acqfc,$visuNo,This).obt.but configure -state normal
           $panneau(acqfc,$visuNo,This).mode.but configure -state normal
           #--- Je restitue l'affichage du bouton "GO"
           set panneau(acqfc,$visuNo,go_stop) go
           $panneau(acqfc,$visuNo,This).go_stop.but configure -text $caption(acqfc,GO)
           #--- J'autorise le bouton "GO"
           $panneau(acqfc,$visuNo,This).go_stop.but configure -state normal
           #--- Effacement de la barre de progression quand la pose est terminee
           destroy $panneau(acqfc,$visuNo,base).progress
           #--- Affichage du status
           $panneau(acqfc,$visuNo,This).status.lab configure -text ""
           update
           #--- Pose en cours
           set panneau(acqfc,$visuNo,pose_en_cours) "0"
        }
      }
   }
#***** Fin de la procedure Go/Stop *****************************

#***** Procedure de lancement d'acquisition ********************
   proc acq { visuNo exptime binning } {
      global audace caption conf panneau

      #--- Petits raccourcis
      set camNo     $panneau(acqfc,$visuNo,camNo)
      set buffer buf[ ::confVisu::getBufNo $visuNo ]

      #--- Affichage du status
      $panneau(acqfc,$visuNo,This).status.lab configure -text $caption(acqfc,raz)
      update

      #--- Si je fais un offset (pose de 0s) alors l'obturateur reste ferme
      if { $exptime == "0" } {
         cam$camNo shutter "closed"
      }

      #--- Cas des petites poses : Force l'affichage de l'avancement de la pose avec le statut Lecture du CCD
      if { $exptime >= "0" && $exptime < "2" } {
         ::acqfc::Avancement_pose $visuNo "1"
      }

      #--- Initialisation du fenetrage
      catch {
         set n1n2 [ cam$camNo nbcells ]
         cam$camNo window [ list 1 1 [ lindex $n1n2 0 ] [ lindex $n1n2 1 ] ]
      }

      #--- La commande exptime permet de fixer le temps de pose de l'image
      cam$camNo exptime $exptime

      if { [::confCam::getPluginProperty $panneau(acqfc,$visuNo,camItem) hasBinning] == "1" } {
         #--- je selectionne le binning
         cam$camNo bin [list [string range $binning 0 0] [string range $binning 2 2]]
      }

      if { [::confCam::getPluginProperty $panneau(acqfc,$visuNo,camItem) hasFormat] == "1" } {
         #--- je selectionne la qualite
         cam$camNo quality $binning
      }

      if { $exptime <= "1" } {
         $panneau(acqfc,$visuNo,This).status.lab configure -text $caption(acqfc,lect)
         update
      }
      #--- J'autorise le bouton "STOP"
      $panneau(acqfc,$visuNo,This).go_stop.but configure -state normal
      #--- Declenchement l'acquisition
      set result [catch { cam$camNo acq } msg ]
      if { $result == 0 } {
         #--- Alarme sonore de fin de pose
         ::camera::alarme_sonore $exptime
         #--- Appel du timer
         if { $exptime >= "2" } {
            ::camera::dispTime_2 cam$camNo $panneau(acqfc,$visuNo,This).status.lab "::acqfc::Avancement_pose" $visuNo
         }
         #--- Chargement de l'image precedente (si telecharge_mode = 3 et si mode = serie, continu, continu 1 ou continu 2)
         if { $conf(dslr,telecharge_mode) == "3" && $panneau(acqfc,$visuNo,mode) >= "1" && $panneau(acqfc,$visuNo,mode) <= "5" } {
            after 10 ::acqfc::loadLastImage $visuNo $camNo
         }
         #--- J'attends la fin de l'acquisition
         #--- Remarque : La commande [set $xxx] permet de recuperer le contenu d'une variable
         set statusVariableName "::status_cam$camNo"
         if { [set $statusVariableName] == "exp" } {
            vwait status_cam$camNo
         }
         #--- j'affiche un message s'il y a eu une erreur pendant l'acquisition
         set msg [cam$camNo lasterror]
         if { $msg != "" } {
            tk_messageBox -title $caption(acqfc,attention) -icon error -message $msg
         }
      } else {
         tk_messageBox -title $caption(acqfc,attention) -icon error -message $msg
      }

      #--- Je retablis le choix du fonctionnement de l'obturateur
      if { $exptime == "0" } {
         switch -exact -- $panneau(acqfc,$visuNo,obt) {
            0  {
               cam$camNo shutter "opened"
            }
            1  {
               cam$camNo shutter "closed"
            }
            2  {
               cam$camNo shutter "synchro"
            }
         }
      }

      #--- Je desactive le bouton "STOP"
      $panneau(acqfc,$visuNo,This).go_stop.but configure -state disabled

      #--- Affichage du status
      $panneau(acqfc,$visuNo,This).status.lab configure -text ""
      update

      #--- Rajoute des mots clefs dans l'en-tete FITS
      foreach keyword [ ::keyword::getCheckedKeywords $visuNo ] {
         $buffer setkwd $keyword
      }

      #--- Visualisation de l'image si on n'est pas en chargement differe
      if { $conf(dslr,telecharge_mode) != "3" || [ cam$camNo product ] != "dslr" } {
         if { $conf(dslr,telecharge_mode) == "1" && [ cam$camNo product ] == "dslr" } {
            #-- raz du buffer si le telechargement est desactive
            $buffer clear
         }
         ::audace::autovisu $visuNo
      }

      #--- Effacement de la barre de progression quand la pose est terminee
      destroy $panneau(acqfc,$visuNo,base).progress

      wm title $panneau(acqfc,$visuNo,base) "$caption(acqfc,acquisition) $exptime s"
   }
#***** Fin de la procedure de lancement d'acquisition **********

#***** Procedure chargement differe d'image pour APN (DSLR) ****
   proc loadLastImage { visuNo camNo } {
      set result [ catch { cam$camNo loadlastimage } msg ]
      if { $result == "1" } {
         ::console::disp "::acqfc::acq loadlastimage camNo$camNo error=$msg \n"
      } else {
         ::console::disp "::acqfc::acq loadlastimage visuNo$visuNo OK \n"
         ::confVisu::autovisu $visuNo
      }
   }
#***** Fin de la procedure chargement differe d'image **********

#***** Procedure d'affichage d'une barre de progression ********
   proc Avancement_pose { visuNo { t } } {
      global audace caption color conf panneau

      if { $panneau(acqfc,$visuNo,avancement_acq) == "1" } {
         #--- Recuperation de la position de la fenetre
         ::acqfc::recup_position_1 $visuNo

         #--- Initialisation de la barre de progression
         set cpt "100"

         #---
         if { [ winfo exists $panneau(acqfc,$visuNo,base).progress ] != "1" } {
            toplevel $panneau(acqfc,$visuNo,base).progress
            wm transient $panneau(acqfc,$visuNo,base).progress $panneau(acqfc,$visuNo,base)
            wm resizable $panneau(acqfc,$visuNo,base).progress 0 0
            wm title $panneau(acqfc,$visuNo,base).progress "$caption(acqfc,en_cours)"
            wm geometry $panneau(acqfc,$visuNo,base).progress $panneau(acqfc,$visuNo,avancement,position)

            #--- Cree le widget et le label du temps ecoule
            label $panneau(acqfc,$visuNo,base).progress.lab_status -text "" -font $audace(font,arial_12_b) -justify center
            pack $panneau(acqfc,$visuNo,base).progress.lab_status -side top -fill x -expand true -pady 5

            #---
            if { $panneau(acqfc,$visuNo,attente_pose) == "0" } {
               if { $panneau(acqfc,$visuNo,demande_arret) == "1" && $panneau(acqfc,$visuNo,mode) != "2" && $panneau(acqfc,$visuNo,mode) != "4" } {
                  $panneau(acqfc,$visuNo,base).progress.lab_status configure -text $caption(acqfc,lect)
               } else {
                  if { $t <= "0" } {
                     destroy $panneau(acqfc,$visuNo,base).progress
                  } elseif { $t > "1" } {
                     $panneau(acqfc,$visuNo,base).progress.lab_status configure -text "[ expr $t-1 ] $caption(acqfc,sec) /\
                        [ format "%d" [ expr int( [ cam$panneau(acqfc,$visuNo,camNo) exptime ] ) ] ] $caption(acqfc,sec)"
                     set cpt [ expr ( $t-1 ) * 100 / [ expr int( [ cam$panneau(acqfc,$visuNo,camNo) exptime ] ) ] ]
                     set cpt [ expr 100 - $cpt ]
                  } else {
                     $panneau(acqfc,$visuNo,base).progress.lab_status configure -text "$caption(acqfc,lect)"
                 }
               }
            } else {
               if { $panneau(acqfc,$visuNo,demande_arret) == "0" } {
                  if { $t < "0" } {
                     destroy $panneau(acqfc,$visuNo,base).progress
                  } else {
                     if { $panneau(acqfc,$visuNo,mode) == "4" } {
                        $panneau(acqfc,$visuNo,base).progress.lab_status configure -text "$caption(acqfc,attente) [ expr $t + 1 ]\
                           $caption(acqfc,sec) / $panneau(acqfc,$visuNo,intervalle_1) $caption(acqfc,sec)"
                        set cpt [expr $t*100 / $panneau(acqfc,$visuNo,intervalle_1) ]
                     } elseif { $panneau(acqfc,$visuNo,mode) == "5" } {
                        $panneau(acqfc,$visuNo,base).progress.lab_status configure -text "$caption(acqfc,attente) [ expr $t + 1 ]\
                           $caption(acqfc,sec) / $panneau(acqfc,$visuNo,intervalle_2) $caption(acqfc,sec)"
                        set cpt [expr $t*100 / $panneau(acqfc,$visuNo,intervalle_2) ]
                     }
                     set cpt [expr 100 - $cpt]
                  }
               }
            }

            catch {
               #--- Cree le widget pour la barre de progression
               frame $panneau(acqfc,$visuNo,base).progress.cadre -width 200 -height 30 -borderwidth 2 -relief groove
               pack $panneau(acqfc,$visuNo,base).progress.cadre -in $panneau(acqfc,$visuNo,base).progress -side top \
                  -anchor center -fill x -expand true -padx 8 -pady 8

               #--- Affiche de la barre de progression
               frame $panneau(acqfc,$visuNo,base).progress.cadre.barre_color_invariant -height 26 -bg $color(blue)
               place $panneau(acqfc,$visuNo,base).progress.cadre.barre_color_invariant -in $panneau(acqfc,$visuNo,base).progress.cadre -x 0 -y 0 \
                  -relwidth [ expr $cpt / 100.0 ]
               update
            }
         } else {
            #---
            if { $panneau(acqfc,$visuNo,attente_pose) == "0" } {
               if { $panneau(acqfc,$visuNo,demande_arret) == "1" && $panneau(acqfc,$visuNo,mode) != "2" && $panneau(acqfc,$visuNo,mode) != "4" } {
                  $panneau(acqfc,$visuNo,base).progress.lab_status configure -text $caption(acqfc,lect)
               } else {
                  if { $t <= "0" } {
                     destroy $panneau(acqfc,$visuNo,base).progress
                  } elseif { $t > "1" } {
                     $panneau(acqfc,$visuNo,base).progress.lab_status configure -text "[ expr $t-1 ] $caption(acqfc,sec) /\
                        [ format "%d" [ expr int( [ cam$panneau(acqfc,$visuNo,camNo) exptime ] ) ] ] $caption(acqfc,sec)"
                     set cpt [ expr ( $t-1 ) * 100 / [ expr int( [ cam$panneau(acqfc,$visuNo,camNo) exptime ] ) ] ]
                     set cpt [ expr 100 - $cpt ]
                  } else {
                     $panneau(acqfc,$visuNo,base).progress.lab_status configure -text "$caption(acqfc,lect)"
                  }
               }
            } else {
               if { $panneau(acqfc,$visuNo,demande_arret) == "0" } {
                  if { $t < "0" } {
                     destroy $panneau(acqfc,$visuNo,base).progress
                  } else {
                     if { $panneau(acqfc,$visuNo,mode) == "4" } {
                        $panneau(acqfc,$visuNo,base).progress.lab_status configure -text "$caption(acqfc,attente) [ expr $t + 1 ]\
                           $caption(acqfc,sec) / $panneau(acqfc,$visuNo,intervalle_1) $caption(acqfc,sec)"
                        set cpt [expr $t*100 / $panneau(acqfc,$visuNo,intervalle_1) ]
                     } elseif { $panneau(acqfc,$visuNo,mode) == "5" } {
                        $panneau(acqfc,$visuNo,base).progress.lab_status configure -text "$caption(acqfc,attente) [ expr $t + 1 ]\
                           $caption(acqfc,sec) / $panneau(acqfc,$visuNo,intervalle_2) $caption(acqfc,sec)"
                        set cpt [expr $t*100 / $panneau(acqfc,$visuNo,intervalle_2) ]
                     }
                     set cpt [expr 100 - $cpt]
                  }
               }
            }

            catch {
               #--- Affiche de la barre de progression
               place $panneau(acqfc,$visuNo,base).progress.cadre.barre_color_invariant -in $panneau(acqfc,$visuNo,base).progress.cadre -x 0 -y 0 \
                  -relwidth [ expr $cpt / 100.0 ]
               update
            }
         }

         #--- Mise a jour dynamique des couleurs
         if [ winfo exists $panneau(acqfc,$visuNo,base).progress ] {
            ::confColor::applyColor $panneau(acqfc,$visuNo,base).progress
         }
      } else {
         return
      }
   }
#***** Fin de la procedure d'avancement de la pose *************

#***** Procedure d'arret de l'acquisition **********************
   proc ArretImage { visuNo } {
      global audace panneau

      #--- Positionne un indicateur de demande d'arret
      set panneau(acqfc,$visuNo,demande_arret) "1"
      #--- Force la numerisation pour l'indicateur d'avancement de la pose
      if { ( $panneau(acqfc,$visuNo,mode) != "2" ) && ( $panneau(acqfc,$visuNo,mode) != "4" ) } {
         ::acqfc::Avancement_pose $visuNo "1"
      }

      #--- On annule la sonnerie
      catch { after cancel $audace(after,bell,id) }
      #--- Annulation de l'alarme de fin de pose
      catch { after cancel bell }

      #--- Arret de la pose (image)
      if { ( $panneau(acqfc,$visuNo,mode) == "1" )
         || ( $panneau(acqfc,$visuNo,mode) == "3" )
         || ( $panneau(acqfc,$visuNo,mode) == "5" ) } {
         #--- J'arrete la capture de l'image
         catch { cam$panneau(acqfc,$visuNo,camNo) stop }
         after 200
      }
   }
#***** Fin de la procedure d'arret de l'acquisition ************

#***** Procedure de sauvegarde de l'image **********************
#--- Procedure lancee par appui sur le bouton "enregistrer", uniquement dans le mode "Une image"
   proc SauveUneImage { visuNo } {
      global audace caption panneau

      #--- Recopie de l'extension des fichiers image
      set ext $panneau(acqfc,$visuNo,extension)

      #--- Tests d'integrite de la requete

      #--- Verifier qu'il y a bien un nom de fichier
      if { $panneau(acqfc,$visuNo,nom_image) == "" } {
         tk_messageBox -title $caption(acqfc,pb) -type ok \
            -message $caption(acqfc,donnomfich)
         return
      }
      #--- Verifier que le nom de fichier n'a pas d'espace
      if { [ llength $panneau(acqfc,$visuNo,nom_image) ] > "1" } {
         tk_messageBox -title $caption(acqfc,pb) -type ok \
            -message $caption(acqfc,nomblanc)
         return
      }
      #--- Verifier que le nom de fichier ne contient pas de caracteres interdits
      if { [ ::acqfc::TestChaine $panneau(acqfc,$visuNo,nom_image) ] == "0" } {
         tk_messageBox -title $caption(acqfc,pb) -type ok \
            -message $caption(acqfc,mauvcar)
         return
      }
      #--- Si la case index est cochee, verifier qu'il y a bien un index
      if { $panneau(acqfc,$visuNo,indexer) == "1" } {
         #--- Verifier que l'index existe
         if { $panneau(acqfc,$visuNo,index) == "" } {
            tk_messageBox -title $caption(acqfc,pb) -type ok \
               -message $caption(acqfc,saisind)
            return
         }
         #--- Verifier que l'index est bien un nombre entier
         if { [ ::acqfc::TestEntier $panneau(acqfc,$visuNo,index) ] == "0" } {
            tk_messageBox -title $caption(acqfc,pb) -type ok \
               -message $caption(acqfc,indinv)
            return
         }
      }

      #--- Afficher le status
      $panneau(acqfc,$visuNo,This).status.lab configure -text $caption(acqfc,enreg)
      update

      #--- Generer le nom du fichier
      set nom $panneau(acqfc,$visuNo,nom_image)
      #--- Pour eviter un nom de fichier qui commence par un blanc
      set nom [lindex $nom 0]
      if { $panneau(acqfc,$visuNo,indexer) == "1" } {
         append nom $panneau(acqfc,$visuNo,index)
      }

      #--- Verifier que le nom du fichier n'existe pas
      set nom1 "$nom"
      append nom1 $ext
      if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
         #--- Dans ce cas, le fichier existe deja
         set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
            -message $caption(acqfc,fichdeja)]
         if { $confirmation == "no" } {
            return
         }
      }

      #--- Incrementer l'index
      set bufNo [ visu$visuNo buf ]
      if { $panneau(acqfc,$visuNo,indexer) == "1" } {
         if { [ buf$bufNo imageready ] != "0" } {
            incr panneau(acqfc,$visuNo,index)
         } else {
            #--- Effacer le status
            $panneau(acqfc,$visuNo,This).status.lab configure -text ""
            #--- Sortir immediatement s'il n'y a pas d'image dans le buffer
            return
         }
      } else {
         if { [ buf$bufNo imageready ] == "0" } {
            #--- Effacer le status
            $panneau(acqfc,$visuNo,This).status.lab configure -text ""
            #--- Sortir immediatement s'il n'y a pas d'image dans le buffer
            return
         }
      }

      #--- Indiquer l'enregistrement dans le fichier log
      set heure $audace(tu,format,hmsint)
      Message $visuNo consolog $caption(acqfc,demsauv) $heure
      Message $visuNo consolog $caption(acqfc,imsauvnom) $nom $ext

      #--- Sauvegarder l'image
      saveima $nom$panneau(acqfc,$visuNo,extension) $visuNo

      #--- Effacer le status
      $panneau(acqfc,$visuNo,This).status.lab configure -text ""
   }
#***** Fin de la procedure de sauvegarde de l'image *************

#***** Procedure d'affichage des messages ************************
#--- Cette procedure est recopiee de methking.tcl, elle permet l'affichage de differents
#--- messages (dans la console, le fichier log, etc.)
   proc Message { visuNo niveau args } {
      global caption panneau

      switch -exact -- $niveau {
         console {
            ::console::disp [eval [concat {format} $args]]
            update idletasks
         }
         log {
            set temps [clock format [clock seconds] -format %H:%M:%S]
            append temps " "
            catch {
               puts -nonewline $::acqfc::log_id($visuNo) [eval [concat {format} $args]]
               #--- Force l'ecriture immediate sur le disque
               flush $::acqfc::log_id($visuNo)
            }
         }
         consolog {
            if { $panneau(acqfc,$visuNo,messages) == "1" } {
               ::console::disp [eval [concat {format} $args]]
               update idletasks
            }
            set temps [clock format [clock seconds] -format %H:%M:%S]
            append temps " "
            catch {
               puts -nonewline $::acqfc::log_id($visuNo) [eval [concat {format} $args]]
               #--- Force l'ecriture immediate sur le disque
               flush $::acqfc::log_id($visuNo)
            }
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
   proc cmdShiftConfig { visuNo } {
      global audace

      set shiftConfig [ ::DlgShift::run "$audace(base).dlgShift" ]
      return
   }
#***** Fin du bouton pour le decalage du telescope *****************

#***** Fenetre de configuration series d'images a intervalle regulier en continu *****
   proc Intervalle_continu_1 { visuNo } {
      global audace caption conf panneau

      set panneau(acqfc,$visuNo,intervalle)            "....."
      set panneau(acqfc,$visuNo,simulation_deja_faite) "0"

      ::acqfc::recup_position $visuNo

      #--- Initialisation de la position de la fenetre
      if { ! [ info exists conf(acqfc,continu1,position) ] } { set conf(acqfc,continu1,position) "+120+260" }

      #--- Creation de la fenetre Continu 1
      toplevel $panneau(acqfc,$visuNo,base).intervalle_continu_1
      wm transient $panneau(acqfc,$visuNo,base).intervalle_continu_1 $panneau(acqfc,$visuNo,base)
      wm resizable $panneau(acqfc,$visuNo,base).intervalle_continu_1 0 0
      wm title $panneau(acqfc,$visuNo,base).intervalle_continu_1 "$caption(acqfc,continu_1)"
      wm geometry $panneau(acqfc,$visuNo,base).intervalle_continu_1 $conf(acqfc,continu1,position)
      wm protocol $panneau(acqfc,$visuNo,base).intervalle_continu_1 WM_DELETE_WINDOW " \
         set panneau(acqfc,$visuNo,mode_en_cours) \"$caption(acqfc,continu_1)\" \
      "

      #--- Create the message
      label $panneau(acqfc,$visuNo,base).intervalle_continu_1.lab1 -text "$caption(acqfc,titre_1)" -font $audace(font,arial_10_b)
      pack $panneau(acqfc,$visuNo,base).intervalle_continu_1.lab1 -padx 20 -pady 5
      frame $panneau(acqfc,$visuNo,base).intervalle_continu_1.a
         label $panneau(acqfc,$visuNo,base).intervalle_continu_1.a.lab2 -text "$caption(acqfc,intervalle_1)"
         pack $panneau(acqfc,$visuNo,base).intervalle_continu_1.a.lab2 -anchor center -expand 1 -fill none -side left \
            -padx 10 -pady 5
         entry $panneau(acqfc,$visuNo,base).intervalle_continu_1.a.ent1 -width 5 -font $audace(font,arial_10_b) -relief groove \
            -textvariable panneau(acqfc,$visuNo,intervalle_1) -justify center
         pack $panneau(acqfc,$visuNo,base).intervalle_continu_1.a.ent1 -anchor center -expand 1 -fill none -side left \
            -padx 10
      pack $panneau(acqfc,$visuNo,base).intervalle_continu_1.a -padx 10 -pady 5
      frame $panneau(acqfc,$visuNo,base).intervalle_continu_1.b
         checkbutton $panneau(acqfc,$visuNo,base).intervalle_continu_1.b.check_simu \
            -text "$caption(acqfc,simu_deja_faite)" \
            -variable panneau(acqfc,$visuNo,simulation_deja_faite) -command "::acqfc::Simu_deja_faite_1 $visuNo"
        pack $panneau(acqfc,$visuNo,base).intervalle_continu_1.b.check_simu -anchor w -expand 1 -fill none \
           -side left -padx 10 -pady 5
      pack $panneau(acqfc,$visuNo,base).intervalle_continu_1.b -side bottom -anchor w -padx 10 -pady 5
      button $panneau(acqfc,$visuNo,base).intervalle_continu_1.but1 -text "$caption(acqfc,simulation)" \
         -command "::acqfc::Command_continu_1 $visuNo"
      pack $panneau(acqfc,$visuNo,base).intervalle_continu_1.but1 -anchor center -expand 1 -fill none -side left \
         -ipadx 5 -ipady 3 -padx 10 -pady 5
      set simu1 "$caption(acqfc,int_mini_serie) $panneau(acqfc,$visuNo,intervalle) $caption(acqfc,sec)"
      label $panneau(acqfc,$visuNo,base).intervalle_continu_1.lab3 -text "$simu1"
      pack $panneau(acqfc,$visuNo,base).intervalle_continu_1.lab3 -anchor center -expand 1 -fill none -side left -padx 10

      #--- New message window is on
      focus $panneau(acqfc,$visuNo,base).intervalle_continu_1

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $panneau(acqfc,$visuNo,base).intervalle_continu_1
   }
#***** Fin fenetre de configuration series d'images a intervalle regulier en continu *****

#***** Commande associee au bouton simulation de la fenetre Continu (1) ******************
   proc Command_continu_1 { visuNo } {
      global caption panneau

      set panneau(acqfc,$visuNo,intervalle) "....."
      set simu1 "$caption(acqfc,int_mini_serie) $panneau(acqfc,$visuNo,intervalle) $caption(acqfc,sec)"
      $panneau(acqfc,$visuNo,base).intervalle_continu_1.lab3 configure -text "$simu1"
      set panneau(acqfc,$visuNo,simulation) "1" ; set panneau(acqfc,$visuNo,mode) "2"
      set index $panneau(acqfc,$visuNo,index) ; set nombre $panneau(acqfc,$visuNo,nb_images)
      ::acqfc::GoStop $visuNo
      set panneau(acqfc,$visuNo,simulation) "0" ; set panneau(acqfc,$visuNo,mode) "4"
      set panneau(acqfc,$visuNo,index) $index ; set panneau(acqfc,$visuNo,nb_images) $nombre
      set simu1 "$caption(acqfc,int_mini_serie) $panneau(acqfc,$visuNo,intervalle) $caption(acqfc,sec)"
      $panneau(acqfc,$visuNo,base).intervalle_continu_1.lab3 configure -text "$simu1"
   }
#***** Fin de la commande associee au bouton simulation de la fenetre Continu (1) ********

#***** Si une simulation a deja ete faite pour la fenetre Continu (1) ********************
   proc Simu_deja_faite_1 { visuNo } {
      global caption panneau

      if { $panneau(acqfc,$visuNo,simulation_deja_faite) == "1" } {
         set panneau(acqfc,$visuNo,intervalle) "xxx"
         $panneau(acqfc,$visuNo,base).intervalle_continu_1.lab3 configure \
            -text "$caption(acqfc,int_mini_serie) $panneau(acqfc,$visuNo,intervalle) $caption(acqfc,sec)"
         focus $panneau(acqfc,$visuNo,base).intervalle_continu_1.a.ent1
      } else {
         set panneau(acqfc,$visuNo,intervalle) "....."
         $panneau(acqfc,$visuNo,base).intervalle_continu_1.lab3 configure \
            -text "$caption(acqfc,int_mini_serie) $panneau(acqfc,$visuNo,intervalle) $caption(acqfc,sec)"
         focus $panneau(acqfc,$visuNo,base).intervalle_continu_1.but1
      }
   }
#***** Fin de si une simulation a deja ete faite pour la fenetre Continu (1) ********

#***** Fenetre de configuration images a intervalle regulier en continu ******************
   proc Intervalle_continu_2 { visuNo } {
      global audace caption conf panneau

      set panneau(acqfc,$visuNo,intervalle)            "....."
      set panneau(acqfc,$visuNo,simulation_deja_faite) "0"

      ::acqfc::recup_position $visuNo

      #--- Initialisation de la position de la fenetre
      if { ! [ info exists conf(acqfc,continu2,position) ] } { set conf(acqfc,continu2,position) "+120+260" }

      #--- Creation de la fenetre Continu 2
      toplevel $panneau(acqfc,$visuNo,base).intervalle_continu_2
      wm transient $panneau(acqfc,$visuNo,base).intervalle_continu_2 $panneau(acqfc,$visuNo,base)
      wm resizable $panneau(acqfc,$visuNo,base).intervalle_continu_2 0 0
      wm title $panneau(acqfc,$visuNo,base).intervalle_continu_2 "$caption(acqfc,continu_2)"
      wm geometry $panneau(acqfc,$visuNo,base).intervalle_continu_2 $conf(acqfc,continu2,position)
      wm protocol $panneau(acqfc,$visuNo,base).intervalle_continu_2 WM_DELETE_WINDOW " \
         set panneau(acqfc,$visuNo,mode_en_cours) \"$caption(acqfc,continu_2)\" \
      "

      #--- Create the message
      label $panneau(acqfc,$visuNo,base).intervalle_continu_2.lab1 -text "$caption(acqfc,titre_2)" -font $audace(font,arial_10_b)
      pack $panneau(acqfc,$visuNo,base).intervalle_continu_2.lab1 -padx 10 -pady 5
      frame $panneau(acqfc,$visuNo,base).intervalle_continu_2.a
         label $panneau(acqfc,$visuNo,base).intervalle_continu_2.a.lab2 -text "$caption(acqfc,intervalle_2)"
         pack $panneau(acqfc,$visuNo,base).intervalle_continu_2.a.lab2 -anchor center -expand 1 -fill none -side left \
            -padx 10 -pady 5
         entry $panneau(acqfc,$visuNo,base).intervalle_continu_2.a.ent1 -width 5 -font $audace(font,arial_10_b) -relief groove \
            -textvariable panneau(acqfc,$visuNo,intervalle_2) -justify center
         pack $panneau(acqfc,$visuNo,base).intervalle_continu_2.a.ent1 -anchor center -expand 1 -fill none -side left \
            -padx 10
      pack $panneau(acqfc,$visuNo,base).intervalle_continu_2.a -padx 10 -pady 5
      frame $panneau(acqfc,$visuNo,base).intervalle_continu_2.b
         checkbutton $panneau(acqfc,$visuNo,base).intervalle_continu_2.b.check_simu \
            -text "$caption(acqfc,simu_deja_faite)" \
            -variable panneau(acqfc,$visuNo,simulation_deja_faite) -command "::acqfc::Simu_deja_faite_2 $visuNo"
         pack $panneau(acqfc,$visuNo,base).intervalle_continu_2.b.check_simu -anchor w -expand 1 -fill none \
            -side left -padx 10 -pady 5
      pack $panneau(acqfc,$visuNo,base).intervalle_continu_2.b -side bottom -anchor w -padx 10 -pady 5
      button $panneau(acqfc,$visuNo,base).intervalle_continu_2.but1 -text "$caption(acqfc,simulation)" \
         -command "::acqfc::Command_continu_2 $visuNo"
      pack $panneau(acqfc,$visuNo,base).intervalle_continu_2.but1 -anchor center -expand 1 -fill none -side left \
         -ipadx 5 -ipady 3 -padx 10 -pady 5
      set simu2 "$caption(acqfc,int_mini_image) $panneau(acqfc,$visuNo,intervalle) $caption(acqfc,sec)"
      label $panneau(acqfc,$visuNo,base).intervalle_continu_2.lab3 -text "$simu2"
      pack $panneau(acqfc,$visuNo,base).intervalle_continu_2.lab3 -anchor center -expand 1 -fill none -side left -padx 10

      #--- New message window is on
      focus $panneau(acqfc,$visuNo,base).intervalle_continu_2

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $panneau(acqfc,$visuNo,base).intervalle_continu_2
   }
#***** Fin fenetre de configuration images a intervalle regulier en continu **************

#***** Commande associee au bouton simulation de la fenetre Continu (2) ******************
   proc Command_continu_2 { visuNo } {
      global caption panneau

      set panneau(acqfc,$visuNo,intervalle) "....."
      set simu2 "$caption(acqfc,int_mini_image) $panneau(acqfc,$visuNo,intervalle) $caption(acqfc,sec)"
      $panneau(acqfc,$visuNo,base).intervalle_continu_2.lab3 configure -text "$simu2"
      set panneau(acqfc,$visuNo,simulation) "1" ; set panneau(acqfc,$visuNo,mode) "2"
      set index $panneau(acqfc,$visuNo,index)
      set panneau(acqfc,$visuNo,nb_images) "1"
      ::acqfc::GoStop $visuNo
      set panneau(acqfc,$visuNo,simulation) "0" ; set panneau(acqfc,$visuNo,mode) "5"
      set panneau(acqfc,$visuNo,index) $index
      set simu2 "$caption(acqfc,int_mini_image) $panneau(acqfc,$visuNo,intervalle) $caption(acqfc,sec)"
      $panneau(acqfc,$visuNo,base).intervalle_continu_2.lab3 configure -text "$simu2"
   }
#***** Fin de la commande associee au bouton simulation de la fenetre Continu (2) ********

#***** Si une simulation a deja ete faite pour la fenetre Continu (2) ********************
   proc Simu_deja_faite_2 { visuNo } {
      global caption panneau

      if { $panneau(acqfc,$visuNo,simulation_deja_faite) == "1" } {
         set panneau(acqfc,$visuNo,intervalle) "xxx" ; \
         $panneau(acqfc,$visuNo,base).intervalle_continu_2.lab3 configure \
            -text "$caption(acqfc,int_mini_image) $panneau(acqfc,$visuNo,intervalle) $caption(acqfc,sec)"
         focus $panneau(acqfc,$visuNo,base).intervalle_continu_2.a.ent1
      } else {
         set panneau(acqfc,$visuNo,intervalle) "....."
         $panneau(acqfc,$visuNo,base).intervalle_continu_2.lab3 configure \
            -text "$caption(acqfc,int_mini_image) $panneau(acqfc,$visuNo,intervalle) $caption(acqfc,sec)"
         focus $panneau(acqfc,$visuNo,base).intervalle_continu_2.but1
      }
   }
#***** Fin de si une simulation a deja ete faite pour la fenetre Continu (2) ********

#***** Enregistrement de la position des fenetres Continu (1) et Continu (2) *****************
   proc recup_position { visuNo } {
      global audace conf panneau

      #--- Cas de la fenetre Continu (1)
      if [ winfo exists $panneau(acqfc,$visuNo,base).intervalle_continu_1 ] {
         #--- Determination de la position de la fenetre
         set geometry [ wm geometry $panneau(acqfc,$visuNo,base).intervalle_continu_1 ]
         set deb [ expr 1 + [ string first + $geometry ] ]
         set fin [ string length $geometry ]
         set conf(acqfc,continu1,position) "+[ string range $geometry $deb $fin ]"
         #--- Fermeture de la fenetre
         destroy $panneau(acqfc,$visuNo,base).intervalle_continu_1
      }
      #--- Cas de la fenetre Continu (2)
      if [ winfo exists $panneau(acqfc,$visuNo,base).intervalle_continu_2 ] {
         #--- Determination de la position de la fenetre
         set geometry [ wm geometry $panneau(acqfc,$visuNo,base).intervalle_continu_2 ]
         set deb [ expr 1 + [ string first + $geometry ] ]
         set fin [ string length $geometry ]
         set conf(acqfc,continu2,position) "+[ string range $geometry $deb $fin ]"
         #--- Fermeture de la fenetre
         destroy $panneau(acqfc,$visuNo,base).intervalle_continu_2
      }
   }
#***** Fin enregistrement de la position des fenetres Continu (1) et Continu (2) *************

#***** Enregistrement de la position de la fenetre Avancement ********
   proc recup_position_1 { visuNo } {
      global audace conf panneau

      #--- Cas de la fenetre Avancement
      if [ winfo exists $panneau(acqfc,$visuNo,base).progress ] {
         #--- Determination de la position de la fenetre
         set geometry [ wm geometry $panneau(acqfc,$visuNo,base).progress ]
         set deb [ expr 1 + [ string first + $geometry ] ]
         set fin [ string length $geometry ]
         set panneau(acqfc,$visuNo,avancement,position) "+[ string range $geometry $deb $fin ]"
      }
   }
#***** Fin enregistrement de la position de la fenetre Avancement ****

#***** Affichage de la fenetre de configuration de WebCam ************
   proc webcamConfigure { visuNo } {
      global caption

      set result [::webcam::config::run $visuNo [::confVisu::getCamItem $visuNo]]
      if { $result == "1" } {
         if { [ ::confVisu::getCamItem $visuNo ] == "" } {
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
#***** Fin de la fenetre de configuration de WebCam ******************

#***** Ouverture de la boite de configuration du telechargement ******
   proc choixTelechargement { visuNo} {
      global panneau

      if { ( $panneau(acqfc,$visuNo,mode) == "1" ) || ( $panneau(acqfc,$visuNo,mode) == "2" ) || \
         ( $panneau(acqfc,$visuNo,mode) == "3" ) || ( $panneau(acqfc,$visuNo,mode) == "4" ) || \
         ( $panneau(acqfc,$visuNo,mode) == "5" ) } {
         ::dslr::setLoadParameters $panneau(acqfc,$visuNo,camItem)
      }
   }
#***** Fin de la configuration du telechargement *********************

}
#==============================================================
#   Fin de la declaration du namespace acqfc
#==============================================================

proc acqfcBuildIF { visuNo } {
   global audace caption conf panneau

   #--- Determination de la fenetre parente
   if { $visuNo == "1" } {
      set base "$audace(base)"
   } else {
      set base ".visu$visuNo"
   }

   #--- Trame du panneau
   frame $panneau(acqfc,$visuNo,This) -borderwidth 2 -relief groove

   #--- Trame du titre du panneau
   frame $panneau(acqfc,$visuNo,This).titre -borderwidth 2 -relief groove
      Button $panneau(acqfc,$visuNo,This).titre.but -borderwidth 1 -text $caption(acqfc,titre) \
         -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::acqfc::getPluginType ] ] \
            [ ::acqfc::getPluginDirectory ] [ ::acqfc::getPluginHelp ]"
      pack $panneau(acqfc,$visuNo,This).titre.but -side top -fill x -in $panneau(acqfc,$visuNo,This).titre -ipadx 5
      DynamicHelp::add $panneau(acqfc,$visuNo,This).titre.but -text $caption(acqfc,help_titre)
   pack $panneau(acqfc,$visuNo,This).titre -side top -fill x

   #--- Trame du bouton de configuration
   frame $panneau(acqfc,$visuNo,This).config -borderwidth 2 -relief groove
      button $panneau(acqfc,$visuNo,This).config.but -borderwidth 1 -text $caption(acqfc,configuration) \
        -command "::acqfcSetup::run $visuNo $base.acqfcSetup"
      pack $panneau(acqfc,$visuNo,This).config.but -side top -fill x -in $panneau(acqfc,$visuNo,This).config -ipadx 5
   pack $panneau(acqfc,$visuNo,This).config -side top -fill x

   #--- Trame du temps de pose
   frame $panneau(acqfc,$visuNo,This).pose -borderwidth 2 -relief ridge
      menubutton $panneau(acqfc,$visuNo,This).pose.but -text $caption(acqfc,pose) \
         -menu $panneau(acqfc,$visuNo,This).pose.but.menu -relief raised
      pack $panneau(acqfc,$visuNo,This).pose.but -side left -fill x -expand true -ipady 1
      set m [ menu $panneau(acqfc,$visuNo,This).pose.but.menu -tearoff 0 ]
      foreach temps $panneau(acqfc,$visuNo,temps_pose) {
        $m add radiobutton -label "$temps" \
           -indicatoron "1" \
           -value "$temps" \
           -variable panneau(acqfc,$visuNo,pose) \
           -command " "
      }
      label $panneau(acqfc,$visuNo,This).pose.lab -text $caption(acqfc,sec)
      pack $panneau(acqfc,$visuNo,This).pose.lab -side right -fill x -expand true
      entry $panneau(acqfc,$visuNo,This).pose.entr -width 6 -font $audace(font,arial_10_b) -relief groove \
        -textvariable panneau(acqfc,$visuNo,pose) -justify center
      pack $panneau(acqfc,$visuNo,This).pose.entr -side left -fill both -expand true
   pack $panneau(acqfc,$visuNo,This).pose -side top -fill x

   #--- Bouton de configuration de la WebCam en lieu et place du widget pose
   button $panneau(acqfc,$visuNo,This).pose.conf -text $caption(acqfc,pose) \
      -command "::acqfc::webcamConfigure $visuNo"
   pack $panneau(acqfc,$visuNo,This).pose.conf -fill x -expand true -ipady 3

   #--- Trame du binning
   frame $panneau(acqfc,$visuNo,This).bin -borderwidth 2 -relief ridge
      menubutton $panneau(acqfc,$visuNo,This).bin.but -text $caption(acqfc,bin) \
         -menu $panneau(acqfc,$visuNo,This).bin.but.menu -relief raised
      pack $panneau(acqfc,$visuNo,This).bin.but -side left -fill y -expand true -ipady 1
      set m [ menu $panneau(acqfc,$visuNo,This).bin.but.menu -tearoff 0 ]
      foreach valbin [ ::confCam::getPluginProperty [ ::confVisu::getCamItem $visuNo ] binningList ] {
        $m add radiobutton -label "$valbin" \
           -indicatoron "1" \
           -value "$valbin" \
           -variable panneau(acqfc,$visuNo,bin) \
           -command " "
      }
      entry $panneau(acqfc,$visuNo,This).bin.lab -width 10 -font $audace(font,arial_10_b) -relief groove \
        -textvariable panneau(acqfc,$visuNo,bin) -justify center -state disabled
      pack $panneau(acqfc,$visuNo,This).bin.lab -side left -fill both -expand true
   pack $panneau(acqfc,$visuNo,This).bin -side top -fill x

   #--- Trame de l'obturateur
   frame $panneau(acqfc,$visuNo,This).obt -borderwidth 2 -relief ridge -width 16
      button $panneau(acqfc,$visuNo,This).obt.but -text $caption(acqfc,obt) -command "::acqfc::ChangeObt $visuNo" \
         -state normal
      pack $panneau(acqfc,$visuNo,This).obt.but -side left -ipady 3
      label $panneau(acqfc,$visuNo,This).obt.lab -text $panneau(acqfc,$visuNo,obt,$panneau(acqfc,$visuNo,obt)) -width 6 \
        -font $audace(font,arial_10_b) -relief groove
      pack $panneau(acqfc,$visuNo,This).obt.lab -side left -fill x -expand true -ipady 3
      label $panneau(acqfc,$visuNo,This).obt.lab1 -text "" -font $audace(font,arial_10_b) -relief ridge \
         -justify center -width 16
      pack $panneau(acqfc,$visuNo,This).obt.lab1 -side top -ipady 3
   pack $panneau(acqfc,$visuNo,This).obt -side top -fill x

   #--- Bouton du choix du telechargement de l'image de l'APN en lieu et place du widget obturateur
   button $panneau(acqfc,$visuNo,This).obt.dslr -text $caption(acqfc,config) -state normal \
      -command "::acqfc::choixTelechargement $visuNo"
   pack $panneau(acqfc,$visuNo,This).obt.dslr -fill x -expand true

   #--- Trame du Status
   frame $panneau(acqfc,$visuNo,This).status -borderwidth 2 -relief ridge
      label $panneau(acqfc,$visuNo,This).status.lab -text "" -font $audace(font,arial_10_b) -relief ridge \
         -justify center -width 16
      pack $panneau(acqfc,$visuNo,This).status.lab -side top -pady 1
   pack $panneau(acqfc,$visuNo,This).status -side top

   #--- Trame du bouton Go/Stop
   frame $panneau(acqfc,$visuNo,This).go_stop -borderwidth 2 -relief ridge
      Button $panneau(acqfc,$visuNo,This).go_stop.but -text $caption(acqfc,GO) -height 2 \
        -font $audace(font,arial_12_b) -borderwidth 3 -command "::acqfc::GoStop $visuNo"
      pack $panneau(acqfc,$visuNo,This).go_stop.but -fill both -padx 0 -pady 0 -expand true
   pack $panneau(acqfc,$visuNo,This).go_stop -side top -fill x

   #--- Trame du mode d'acquisition
   set panneau(acqfc,$visuNo,mode_en_cours) [ lindex $panneau(acqfc,$visuNo,list_mode) [ expr $panneau(acqfc,$visuNo,mode) - 1 ] ]
   frame $panneau(acqfc,$visuNo,This).mode -borderwidth 5 -relief ridge
      ComboBox $panneau(acqfc,$visuNo,This).mode.but \
        -width 15         \
        -font $audace(font,arial_10_n) \
        -height [llength $panneau(acqfc,$visuNo,list_mode)] \
        -relief raised    \
        -borderwidth 1    \
        -editable 0       \
        -takefocus 1      \
        -justify center   \
        -textvariable panneau(acqfc,$visuNo,mode_en_cours) \
        -values $panneau(acqfc,$visuNo,list_mode) \
        -modifycmd "::acqfc::ChangeMode $visuNo"
      pack $panneau(acqfc,$visuNo,This).mode.but -side top

      #--- Definition du sous-panneau "Mode : Une seule image"
      frame $panneau(acqfc,$visuNo,This).mode.une -borderwidth 0
        frame $panneau(acqfc,$visuNo,This).mode.une.nom -relief ridge -borderwidth 2
           label $panneau(acqfc,$visuNo,This).mode.une.nom.but -text $caption(acqfc,nom) -pady 0
           pack $panneau(acqfc,$visuNo,This).mode.une.nom.but -fill x -side top
           entry $panneau(acqfc,$visuNo,This).mode.une.nom.entr -width 10 -textvariable panneau(acqfc,$visuNo,nom_image) \
              -font $audace(font,arial_10_b) -relief groove
           pack $panneau(acqfc,$visuNo,This).mode.une.nom.entr -fill x -side top
           label $panneau(acqfc,$visuNo,This).mode.une.nom.lab_extension -text $caption(acqfc,extension) -pady 0
           pack $panneau(acqfc,$visuNo,This).mode.une.nom.lab_extension -fill x -side left
           menubutton $panneau(acqfc,$visuNo,This).mode.une.nom.extension -textvariable panneau(acqfc,$visuNo,extension) \
              -menu $panneau(acqfc,$visuNo,This).mode.une.nom.extension.menu -relief raised
           pack $panneau(acqfc,$visuNo,This).mode.une.nom.extension -side right -fill x -expand true -ipady 1
           set m [ menu $panneau(acqfc,$visuNo,This).mode.une.nom.extension.menu -tearoff 0 ]
           foreach extension $conf(list_extension) {
             $m add radiobutton -label "$extension" \
                -indicatoron "1" \
                -value "$extension" \
                -variable panneau(acqfc,$visuNo,extension) \
                -command " "
           }
        pack $panneau(acqfc,$visuNo,This).mode.une.nom -side top -fill x
        frame $panneau(acqfc,$visuNo,This).mode.une.index -relief ridge -borderwidth 2
           checkbutton $panneau(acqfc,$visuNo,This).mode.une.index.case -pady 0 -text $caption(acqfc,index) \
              -variable panneau(acqfc,$visuNo,indexer)
           pack $panneau(acqfc,$visuNo,This).mode.une.index.case -side top -fill x
           entry $panneau(acqfc,$visuNo,This).mode.une.index.entr -width 3 -textvariable panneau(acqfc,$visuNo,index) \
              -font $audace(font,arial_10_b) -relief groove -justify center
           pack $panneau(acqfc,$visuNo,This).mode.une.index.entr -side left -fill x -expand true
           button $panneau(acqfc,$visuNo,This).mode.une.index.but -text "1" -width 3 \
              -command "set panneau(acqfc,$visuNo,index) 1"
           pack $panneau(acqfc,$visuNo,This).mode.une.index.but -side right -fill x
        pack $panneau(acqfc,$visuNo,This).mode.une.index -side top -fill x
        button $panneau(acqfc,$visuNo,This).mode.une.sauve -text $caption(acqfc,sauvegde) \
           -command "::acqfc::SauveUneImage $visuNo"
        pack $panneau(acqfc,$visuNo,This).mode.une.sauve -side top -fill x

      #--- Definition du sous-panneau "Mode : Serie d'images"
      frame $panneau(acqfc,$visuNo,This).mode.serie
        frame $panneau(acqfc,$visuNo,This).mode.serie.nom -relief ridge -borderwidth 2
           label $panneau(acqfc,$visuNo,This).mode.serie.nom.but -text $caption(acqfc,nom) -pady 0
           pack $panneau(acqfc,$visuNo,This).mode.serie.nom.but -fill x
           entry $panneau(acqfc,$visuNo,This).mode.serie.nom.entr -width 10 -textvariable panneau(acqfc,$visuNo,nom_image) \
              -font $audace(font,arial_10_b) -relief groove
           pack $panneau(acqfc,$visuNo,This).mode.serie.nom.entr -fill x
           label $panneau(acqfc,$visuNo,This).mode.serie.nom.lab_extension -text $caption(acqfc,extension) -pady 0
           pack $panneau(acqfc,$visuNo,This).mode.serie.nom.lab_extension -fill x -side left
           menubutton $panneau(acqfc,$visuNo,This).mode.serie.nom.extension -textvariable panneau(acqfc,$visuNo,extension) \
              -menu $panneau(acqfc,$visuNo,This).mode.serie.nom.extension.menu -relief raised
           pack $panneau(acqfc,$visuNo,This).mode.serie.nom.extension -side right -fill x -expand true -ipady 1
           set m [ menu $panneau(acqfc,$visuNo,This).mode.serie.nom.extension.menu -tearoff 0 ]
           foreach extension $conf(list_extension) {
             $m add radiobutton -label "$extension" \
                -indicatoron "1" \
                -value "$extension" \
                -variable panneau(acqfc,$visuNo,extension) \
                -command " "
           }
        pack $panneau(acqfc,$visuNo,This).mode.serie.nom -side top -fill x
        frame $panneau(acqfc,$visuNo,This).mode.serie.nb -relief ridge -borderwidth 2
           label $panneau(acqfc,$visuNo,This).mode.serie.nb.but -text $caption(acqfc,nombre) -pady 0
           pack $panneau(acqfc,$visuNo,This).mode.serie.nb.but -side left -fill y
           entry $panneau(acqfc,$visuNo,This).mode.serie.nb.entr -width 3 -textvariable panneau(acqfc,$visuNo,nb_images) \
              -font $audace(font,arial_10_b) -relief groove -justify center
           pack $panneau(acqfc,$visuNo,This).mode.serie.nb.entr -side left -fill x -expand true
        pack $panneau(acqfc,$visuNo,This).mode.serie.nb -side top -fill x
        frame $panneau(acqfc,$visuNo,This).mode.serie.index -relief ridge -borderwidth 2
           label $panneau(acqfc,$visuNo,This).mode.serie.index.lab -text $caption(acqfc,index) -pady 0
           pack $panneau(acqfc,$visuNo,This).mode.serie.index.lab -side top -fill x
           entry $panneau(acqfc,$visuNo,This).mode.serie.index.entr -width 3 -textvariable panneau(acqfc,$visuNo,index) \
              -font $audace(font,arial_10_b) -relief groove -justify center
           pack $panneau(acqfc,$visuNo,This).mode.serie.index.entr -side left -fill x -expand true
           button $panneau(acqfc,$visuNo,This).mode.serie.index.but -text "1" -width 3 \
              -command "set panneau(acqfc,$visuNo,index) 1"
           pack $panneau(acqfc,$visuNo,This).mode.serie.index.but -side right -fill x
        pack $panneau(acqfc,$visuNo,This).mode.serie.index -side top -fill x

      #--- Definition du sous-panneau "Mode : Continu"
      frame $panneau(acqfc,$visuNo,This).mode.continu
        frame $panneau(acqfc,$visuNo,This).mode.continu.sauve -relief ridge -borderwidth 2
           checkbutton $panneau(acqfc,$visuNo,This).mode.continu.sauve.case -text $caption(acqfc,enregistrer) \
              -variable panneau(acqfc,$visuNo,enregistrer)
           pack $panneau(acqfc,$visuNo,This).mode.continu.sauve.case -side left -fill x  -expand true
        pack $panneau(acqfc,$visuNo,This).mode.continu.sauve -side top -fill x
        frame $panneau(acqfc,$visuNo,This).mode.continu.nom -relief ridge -borderwidth 2
           label $panneau(acqfc,$visuNo,This).mode.continu.nom.but -text $caption(acqfc,nom) -pady 0
           pack $panneau(acqfc,$visuNo,This).mode.continu.nom.but -fill x
           entry $panneau(acqfc,$visuNo,This).mode.continu.nom.entr -width 10 -textvariable panneau(acqfc,$visuNo,nom_image) \
              -font $audace(font,arial_10_b) -relief groove
           pack $panneau(acqfc,$visuNo,This).mode.continu.nom.entr -fill x
           label $panneau(acqfc,$visuNo,This).mode.continu.nom.lab_extension -text $caption(acqfc,extension) -pady 0
           pack $panneau(acqfc,$visuNo,This).mode.continu.nom.lab_extension -fill x -side left
           menubutton $panneau(acqfc,$visuNo,This).mode.continu.nom.extension -textvariable panneau(acqfc,$visuNo,extension) \
              -menu $panneau(acqfc,$visuNo,This).mode.continu.nom.extension.menu -relief raised
           pack $panneau(acqfc,$visuNo,This).mode.continu.nom.extension -side right -fill x -expand true -ipady 1
           set m [ menu $panneau(acqfc,$visuNo,This).mode.continu.nom.extension.menu -tearoff 0 ]
           foreach extension $conf(list_extension) {
             $m add radiobutton -label "$extension" \
                -indicatoron "1" \
                -value "$extension" \
                -variable panneau(acqfc,$visuNo,extension) \
                -command " "
           }
        pack $panneau(acqfc,$visuNo,This).mode.continu.nom -side top -fill x
        frame $panneau(acqfc,$visuNo,This).mode.continu.index -relief ridge -borderwidth 2
           label $panneau(acqfc,$visuNo,This).mode.continu.index.lab -text $caption(acqfc,index) -pady 0
           pack $panneau(acqfc,$visuNo,This).mode.continu.index.lab -side top -fill x
           entry $panneau(acqfc,$visuNo,This).mode.continu.index.entr -width 3 -textvariable panneau(acqfc,$visuNo,index) \
              -font $audace(font,arial_10_b) -relief groove -justify center
           pack $panneau(acqfc,$visuNo,This).mode.continu.index.entr -side left -fill x -expand true
           button $panneau(acqfc,$visuNo,This).mode.continu.index.but -text "1" -width 3 \
              -command "set panneau(acqfc,$visuNo,index) 1"
           pack $panneau(acqfc,$visuNo,This).mode.continu.index.but -side right -fill x
        pack $panneau(acqfc,$visuNo,This).mode.continu.index -side top -fill x

      #--- Definition du sous-panneau "Mode : Series d'images en continu avec intervalle entre chaque serie"
      frame $panneau(acqfc,$visuNo,This).mode.serie_1
        frame $panneau(acqfc,$visuNo,This).mode.serie_1.nom -relief ridge -borderwidth 2
           label $panneau(acqfc,$visuNo,This).mode.serie_1.nom.but -text $caption(acqfc,nom) -pady 0
           pack $panneau(acqfc,$visuNo,This).mode.serie_1.nom.but -fill x
           entry $panneau(acqfc,$visuNo,This).mode.serie_1.nom.entr -width 10 -textvariable panneau(acqfc,$visuNo,nom_image) \
              -font $audace(font,arial_10_b) -relief groove
           pack $panneau(acqfc,$visuNo,This).mode.serie_1.nom.entr -fill x
           label $panneau(acqfc,$visuNo,This).mode.serie_1.nom.lab_extension -text $caption(acqfc,extension) -pady 0
           pack $panneau(acqfc,$visuNo,This).mode.serie_1.nom.lab_extension -fill x -side left
           menubutton $panneau(acqfc,$visuNo,This).mode.serie_1.nom.extension -textvariable panneau(acqfc,$visuNo,extension) \
              -menu $panneau(acqfc,$visuNo,This).mode.serie_1.nom.extension.menu -relief raised
           pack $panneau(acqfc,$visuNo,This).mode.serie_1.nom.extension -side right -fill x -expand true -ipady 1
           set m [ menu $panneau(acqfc,$visuNo,This).mode.serie_1.nom.extension.menu -tearoff 0 ]
           foreach extension $conf(list_extension) {
             $m add radiobutton -label "$extension" \
                -indicatoron "1" \
                -value "$extension" \
                -variable panneau(acqfc,$visuNo,extension) \
                -command " "
           }
        pack $panneau(acqfc,$visuNo,This).mode.serie_1.nom -side top -fill x
        frame $panneau(acqfc,$visuNo,This).mode.serie_1.nb -relief ridge -borderwidth 2
           label $panneau(acqfc,$visuNo,This).mode.serie_1.nb.but -text $caption(acqfc,nombre) -pady 0
           pack $panneau(acqfc,$visuNo,This).mode.serie_1.nb.but -side left -fill y
           entry $panneau(acqfc,$visuNo,This).mode.serie_1.nb.entr -width 3 -textvariable panneau(acqfc,$visuNo,nb_images) \
              -font $audace(font,arial_10_b) -relief groove -justify center
           pack $panneau(acqfc,$visuNo,This).mode.serie_1.nb.entr -side left -fill x -expand true
        pack $panneau(acqfc,$visuNo,This).mode.serie_1.nb -side top -fill x
        frame $panneau(acqfc,$visuNo,This).mode.serie_1.index -relief ridge -borderwidth 2
           label $panneau(acqfc,$visuNo,This).mode.serie_1.index.lab -text $caption(acqfc,index) -pady 0
           pack $panneau(acqfc,$visuNo,This).mode.serie_1.index.lab -side top -fill x
           entry $panneau(acqfc,$visuNo,This).mode.serie_1.index.entr -width 3 -textvariable panneau(acqfc,$visuNo,index) \
              -font $audace(font,arial_10_b) -relief groove -justify center
           pack $panneau(acqfc,$visuNo,This).mode.serie_1.index.entr -side left -fill x -expand true
           button $panneau(acqfc,$visuNo,This).mode.serie_1.index.but -text "1" -width 3 \
              -command "set panneau(acqfc,$visuNo,index) 1"
           pack $panneau(acqfc,$visuNo,This).mode.serie_1.index.but -side right -fill x
        pack $panneau(acqfc,$visuNo,This).mode.serie_1.index -side top -fill x

      #--- Definition du sous-panneau "Mode : Continu avec intervalle entre chaque image"
      frame $panneau(acqfc,$visuNo,This).mode.continu_1
        frame $panneau(acqfc,$visuNo,This).mode.continu_1.sauve -relief ridge -borderwidth 2
           checkbutton $panneau(acqfc,$visuNo,This).mode.continu_1.sauve.case -text $caption(acqfc,enregistrer) \
              -variable panneau(acqfc,$visuNo,enregistrer)
           pack $panneau(acqfc,$visuNo,This).mode.continu_1.sauve.case -side left -fill x  -expand true
        pack $panneau(acqfc,$visuNo,This).mode.continu_1.sauve -side top -fill x
        frame $panneau(acqfc,$visuNo,This).mode.continu_1.nom -relief ridge -borderwidth 2
           label $panneau(acqfc,$visuNo,This).mode.continu_1.nom.but -text $caption(acqfc,nom) -pady 0
           pack $panneau(acqfc,$visuNo,This).mode.continu_1.nom.but -fill x
           entry $panneau(acqfc,$visuNo,This).mode.continu_1.nom.entr -width 10 -textvariable panneau(acqfc,$visuNo,nom_image) \
              -font $audace(font,arial_10_b) -relief groove
           pack $panneau(acqfc,$visuNo,This).mode.continu_1.nom.entr -fill x
           label $panneau(acqfc,$visuNo,This).mode.continu_1.nom.lab_extension -text $caption(acqfc,extension) -pady 0
           pack $panneau(acqfc,$visuNo,This).mode.continu_1.nom.lab_extension -fill x -side left
           menubutton $panneau(acqfc,$visuNo,This).mode.continu_1.nom.extension -textvariable panneau(acqfc,$visuNo,extension) \
              -menu $panneau(acqfc,$visuNo,This).mode.continu_1.nom.extension.menu -relief raised
           pack $panneau(acqfc,$visuNo,This).mode.continu_1.nom.extension -side right -fill x -expand true -ipady 1
           set m [ menu $panneau(acqfc,$visuNo,This).mode.continu_1.nom.extension.menu -tearoff 0 ]
           foreach extension $conf(list_extension) {
             $m add radiobutton -label "$extension" \
                -indicatoron "1" \
                -value "$extension" \
                -variable panneau(acqfc,$visuNo,extension) \
                -command " "
           }
        pack $panneau(acqfc,$visuNo,This).mode.continu_1.nom -side top -fill x
        frame $panneau(acqfc,$visuNo,This).mode.continu_1.index -relief ridge -borderwidth 2
           label $panneau(acqfc,$visuNo,This).mode.continu_1.index.lab -text $caption(acqfc,index) -pady 0
           pack $panneau(acqfc,$visuNo,This).mode.continu_1.index.lab -side top -fill x
           entry $panneau(acqfc,$visuNo,This).mode.continu_1.index.entr -width 3 -textvariable panneau(acqfc,$visuNo,index) \
              -font $audace(font,arial_10_b) -relief groove -justify center
           pack $panneau(acqfc,$visuNo,This).mode.continu_1.index.entr -side left -fill x -expand true
           button $panneau(acqfc,$visuNo,This).mode.continu_1.index.but -text "1" -width 3 \
              -command "set panneau(acqfc,$visuNo,index) 1"
           pack $panneau(acqfc,$visuNo,This).mode.continu_1.index.but -side right -fill x
        pack $panneau(acqfc,$visuNo,This).mode.continu_1.index -side top -fill x
     pack $panneau(acqfc,$visuNo,This).mode -side top -fill x

      #--- Frame pour l'affichage de l'avancement de l'acqusition
      frame $panneau(acqfc,$visuNo,This).avancement_acq -borderwidth 2 -relief ridge
        #--- Checkbutton petit deplacement
        checkbutton $panneau(acqfc,$visuNo,This).avancement_acq.check -highlightthickness 0 \
           -text $caption(acqfc,avancement_acq) -variable panneau(acqfc,$visuNo,avancement_acq)
        pack $panneau(acqfc,$visuNo,This).avancement_acq.check -side left -fill x
     pack $panneau(acqfc,$visuNo,This).avancement_acq -side top -fill x

      #--- Frame petit decalage
      frame $panneau(acqfc,$visuNo,This).shift -borderwidth 2 -relief ridge
        #--- Checkbutton petit deplacement
        checkbutton $panneau(acqfc,$visuNo,This).shift.buttonShift -highlightthickness 0 \
           -variable panneau(DlgShift,buttonShift)
        pack $panneau(acqfc,$visuNo,This).shift.buttonShift -side left -fill x
        #--- Bouton configuration petit deplacement
        button $panneau(acqfc,$visuNo,This).shift.buttonShiftConfig -text "$caption(acqfc,buttonShiftConfig)" \
           -command "::acqfc::cmdShiftConfig $visuNo"
        pack $panneau(acqfc,$visuNo,This).shift.buttonShiftConfig -side right -fill x -expand true
     pack $panneau(acqfc,$visuNo,This).shift -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $panneau(acqfc,$visuNo,This)
}

