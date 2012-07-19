#
# Fichier : acqfc.tcl
# Description : Outil d'acquisition
# Auteur : Francois Cochard
# Mise a jour $Id: acqfc.tcl,v 1.49 2007-06-16 10:43:53 robertdelmas Exp $
#

#==============================================================
#   Declaration du namespace AcqFC
#==============================================================

namespace eval ::AcqFC {
   package provide acqfc 2.1

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
      set panneau(AcqFC,$visuNo,base) "$in"
      set panneau(AcqFC,$visuNo,This) "$in.acqFC"

      set panneau(AcqFC,$visuNo,camItem) [::confVisu::getCamItem $visuNo]
      set panneau(AcqFC,$visuNo,camNo)   [::confCam::getCamNo $panneau(AcqFC,$visuNo,camItem)]

      #--- Recuperation de la derniere configuration de prise de vue
      ::AcqFC::Chargement_Var $visuNo

      #--- Initialisation de la variable conf()
      if { ! [info exists conf(acqfc,avancement,position)] } { set conf(acqfc,avancement,position) "+120+315" }

      #--- Initialisation de variables
      set panneau(AcqFC,$visuNo,simulation)            "0"
      set panneau(AcqFC,$visuNo,simulation_deja_faite) "0"
      set panneau(AcqFC,$visuNo,attente_pose)          "0"
      set panneau(AcqFC,$visuNo,pose_en_cours)         "0"
      set panneau(AcqFC,$visuNo,avancement,position)   $conf(acqfc,avancement,position)
      if { $visuNo == "1" } {
         set panneau(AcqFC,$visuNo,avancement_acq)     "1"
      } else {
         set panneau(AcqFC,$visuNo,avancement_acq)     "0"
      }

      #--- Entrer ici les valeurs de temps de pose a afficher dans le menu "pose"
      set panneau(AcqFC,$visuNo,temps_pose) {0 0.1 0.3 0.5 1 2 3 5 10 15 20 30 60 90 120 180 300 600}
      #--- Valeur par defaut du temps de pose
      if { ! [ info exists panneau(AcqFC,$visuNo,pose) ] } {
         set panneau(AcqFC,$visuNo,pose) "$parametres(acqFC,$visuNo,pose)"
      }

      #--- Valeur par defaut du binning
      if { ! [ info exists panneau(AcqFC,$visuNo,bin) ] } {
         set panneau(AcqFC,$visuNo,bin) "$parametres(acqFC,$visuNo,bin)"
      }

      #--- Entrer ici les valeurs pour l'obturateur a afficher dans le menu "obt"
      set panneau(AcqFC,$visuNo,obt,0) $caption(acqfc,ouv)
      set panneau(AcqFC,$visuNo,obt,1) $caption(acqfc,ferme)
      set panneau(AcqFC,$visuNo,obt,2) $caption(acqfc,auto)
      #--- Obturateur par defaut : Synchro
      if { ! [ info exists panneau(AcqFC,$visuNo,obt) ] } {
         set panneau(AcqFC,$visuNo,obt) "$parametres(acqFC,$visuNo,obt)"
      }

      #--- Liste des modes disponibles
      set panneau(AcqFC,$visuNo,list_mode) [ list $caption(acqfc,uneimage) $caption(acqfc,serie) $caption(acqfc,continu) \
         $caption(acqfc,continu_1) $caption(acqfc,continu_2) $caption(acqfc,video) $caption(acqfc,video_1) ]

      #--- Initialisation des modes
      set panneau(AcqFC,$visuNo,mode,1) "$panneau(AcqFC,$visuNo,This).mode.une"
      set panneau(AcqFC,$visuNo,mode,2) "$panneau(AcqFC,$visuNo,This).mode.serie"
      set panneau(AcqFC,$visuNo,mode,3) "$panneau(AcqFC,$visuNo,This).mode.continu"
      set panneau(AcqFC,$visuNo,mode,4) "$panneau(AcqFC,$visuNo,This).mode.serie_1"
      set panneau(AcqFC,$visuNo,mode,5) "$panneau(AcqFC,$visuNo,This).mode.continu_1"
      set panneau(AcqFC,$visuNo,mode,6) "$panneau(AcqFC,$visuNo,This).mode.video"
      set panneau(AcqFC,$visuNo,mode,7) "$panneau(AcqFC,$visuNo,This).mode.video_1"
      #--- Mode par defaut : Une image
      if { ! [ info exists panneau(AcqFC,$visuNo,mode) ] } {
         set panneau(AcqFC,$visuNo,mode) "$parametres(acqFC,$visuNo,mode)"
      }

      #--- Initialisation d'autres variables
      set panneau(AcqFC,$visuNo,go_stop)           "go"
      set panneau(AcqFC,$visuNo,index)             "1"
      set panneau(AcqFC,$visuNo,nom_image)         ""
      set panneau(AcqFC,$visuNo,extension)         "$conf(extension,defaut)"
      set panneau(AcqFC,$visuNo,indexer)           "0"
      set panneau(AcqFC,$visuNo,enregistrer)       "1"
      set panneau(AcqFC,$visuNo,nb_images)         "1"
      set panneau(AcqFC,$visuNo,session_ouverture) "1"

      #--- Initialisation de variables pour l'acquisition video fenetree
      set panneau(AcqFC,$visuNo,fenetre)           "0"
      set panneau(AcqFC,$visuNo,largeur)           ""
      set panneau(AcqFC,$visuNo,hauteur)           ""
      set panneau(AcqFC,$visuNo,x1)                "$parametres(acqFC,$visuNo,x1)"
      set panneau(AcqFC,$visuNo,y1)                "$parametres(acqFC,$visuNo,y1)"
      set panneau(AcqFC,$visuNo,x2)                "$parametres(acqFC,$visuNo,x2)"
      set panneau(AcqFC,$visuNo,y2)                "$parametres(acqFC,$visuNo,y2)"

      #--- Initialisation pour le mode video
      set panneau(AcqFC,$visuNo,showvideopreview) "0"
      set panneau(AcqFC,$visuNo,ratelist)  {5 10 15 20 25 30}
      set panneau(AcqFC,$visuNo,status)    "                              "
      #--- Frequence images par defaut : 5 images/sec.
      if { ! [ info exists panneau(AcqFC,$visuNo,rate) ] } {
         set panneau(AcqFC,$visuNo,rate) "$parametres(acqFC,$visuNo,rate)"
      }
      #--- Duree du film par defaut : 10s
      if { ! [ info exists panneau(AcqFC,$visuNo,lg_film) ] } {
         set panneau(AcqFC,$visuNo,lg_film) "$parametres(acqFC,$visuNo,lg_film)"
      }

      #--- Mise en place de l'interface graphique
      AcqFCBuildIF $visuNo

      #--- Traitement du bouton Configuration pour la camera APN (DSLR)
      if { ( $panneau(AcqFC,$visuNo,mode) == "6" ) || ( $panneau(AcqFC,$visuNo,mode) == "7" ) } {
         $panneau(AcqFC,$visuNo,This).obt.dslr configure -state disabled
      } else {
         $panneau(AcqFC,$visuNo,This).obt.dslr configure -state normal
      }

      pack $panneau(AcqFC,$visuNo,mode,$panneau(AcqFC,$visuNo,mode)) -anchor nw -fill x

      #--- Surveillance de la connexion d'une camera
      ::confVisu::addCameraListener $visuNo "::AcqFC::Adapt_Panneau_AcqFC $visuNo"
      #--- Surveillance de l'ajout ou de la suppression d'une extension
      trace add variable ::conf(list_extension) write ::AcqFC::Init_list_extension

   }
#***** Fin de la procedure createPluginInstance*****************

   #------------------------------------------------------------
   #  deletePluginInstance
   #     suppprime l'instance du plugin
   #------------------------------------------------------------
   proc deletePluginInstance { visuNo } {
      global conf panneau

      #--- Je desactive la surveillance de la connexion d'une camera
      ::confVisu::removeCameraListener $visuNo "::AcqFC::Adapt_Panneau_AcqFC $visuNo"
      #--- Je desactive la surveillance de l'ajout ou de la suppression d'une extension
      trace remove variable ::conf(list_extension) write ::AcqFC::Init_list_extension

      #---
      set conf(acqfc,avancement,position) $panneau(AcqFC,$visuNo,avancement,position)

      #---
      destroy $panneau(AcqFC,$visuNo,This)
      destroy $panneau(AcqFC,$visuNo,base).status_video.pose.but.menu
      destroy $panneau(AcqFC,$visuNo,base).status_video.rate.cb.menu
      destroy $panneau(AcqFC,$visuNo,This).pose.but.menu
      destroy $panneau(AcqFC,$visuNo,This).bin.but.menu

      #---
      ArretAcqFC $visuNo
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
   #  getPluginType
   #     retourne le type de plugin
   #------------------------------------------------------------
   proc getPluginType { } {
      return "tool"
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
      set ::AcqFC::fichier_log [ file join $audace(rep_images) [ append $file_log $nom_generique $formatdate ".log" ] ]

      #--- Ouverture
      if { [ catch { open $::AcqFC::fichier_log a } ::AcqFC::log_id ] } {
         Message $visuNo console $caption(acqfc,pbouvfichcons)
         tk_messageBox -title $caption(acqfc,pb) -type ok \
            -message $caption(acqfc,pbouvfich)
         #--- Note importante : Je detecte si j'ai un pb a l'ouverture du fichier, mais je ne sais pas traiter ce cas :
         #--- Il faudrait interdire l'ouverture du panneau, mais le processus est deja lance a ce stade...
         #--- Tout ce que je fais, c'est inviter l'utilisateur a changer d'outil !
      } else {
         #--- En-tete du fichier
         Message $visuNo log $caption(acqfc,ouvsess)
         set date [clock format [clock seconds] -format "%A %d %B %Y"]
         set heure $audace(tu,format,hmsint)
         Message $visuNo console $caption(acqfc,affheure) $date $heure
         #--- Definition du binding pour declencher l'acquisition (ou l'arret) par Echap.
         bind all <Key-Escape> "::AcqFC::GoStop $visuNo"
      }
   }
#***** Fin de la procedure DemarrageAcqFC **********************

#***** Procedure ArretAcqFC ************************************
   proc ArretAcqFC { visuNo } {
      global audace caption panneau

      #--- Fermeture du fichier de log
      if { [ info exists ::AcqFC::log_id ] } {
         set heure $audace(tu,format,hmsint)
         #--- Je m'assure que le fichier se termine correctement, en particulier pour le cas ou il y
         #--- a eu un probleme a l'ouverture (c'est un peu une rustine...)
         if { [ catch { Message $visuNo log $caption(acqfc,finsess) $heure } bug ] } {
            Message $visuNo console $caption(acqfc,pbfermfichcons)
         } else {
            close $::AcqFC::log_id
            unset ::AcqFC::log_id
         }
      }
      #--- Re-initialisation de la session
      set panneau(AcqFC,$visuNo,session_ouverture) "1"
      #--- Desactivation du binding pour declencher l'acquisition (ou l'arret) par Echap.
      bind all <Key-Escape> { }
   }
#***** Fin de la procedure ArretAcqFC **************************

#***** Procedure Init_list_extension ***************************
   proc Init_list_extension { { a "" } { b "" } { c "" } { visuNo 1 } } {
      variable This
      global conf panneau

      #--- Mise a jour de la liste des extensions disponibles pour le mode "Une seule image"
      $panneau(AcqFC,$visuNo,This).mode.une.nom.extension.menu delete 0 20
      foreach extension $conf(list_extension) {
         $panneau(AcqFC,$visuNo,This).mode.une.nom.extension.menu add radiobutton -label "$extension" \
            -indicatoron "1" \
            -value "$extension" \
            -variable panneau(AcqFC,$visuNo,extension) \
            -command " "
      }
      #--- Mise a jour de la liste des extensions disponibles pour le mode "Serie d'images"
      $panneau(AcqFC,$visuNo,This).mode.serie.nom.extension.menu delete 0 20
      foreach extension $conf(list_extension) {
         $panneau(AcqFC,$visuNo,This).mode.serie.nom.extension.menu add radiobutton -label "$extension" \
            -indicatoron "1" \
            -value "$extension" \
            -variable panneau(AcqFC,$visuNo,extension) \
            -command " "
      }
      #--- Mise a jour de la liste des extensions disponibles pour le mode "Continu"
      $panneau(AcqFC,$visuNo,This).mode.continu.nom.extension.menu delete 0 20
      foreach extension $conf(list_extension) {
         $panneau(AcqFC,$visuNo,This).mode.continu.nom.extension.menu add radiobutton -label "$extension" \
            -indicatoron "1" \
            -value "$extension" \
            -variable panneau(AcqFC,$visuNo,extension) \
            -command " "
      }
      #--- Mise a jour de la liste des extensions disponibles pour le mode "Series d'images en continu avec intervalle entre chaque serie"
      $panneau(AcqFC,$visuNo,This).mode.serie_1.nom.extension.menu delete 0 20
      foreach extension $conf(list_extension) {
         $panneau(AcqFC,$visuNo,This).mode.serie_1.nom.extension.menu add radiobutton -label "$extension" \
            -indicatoron "1" \
            -value "$extension" \
            -variable panneau(AcqFC,$visuNo,extension) \
            -command " "
      }
      #--- Mise a jour de la liste des extensions disponibles pour le mode "Continu avec intervalle entre chaque image"
      $panneau(AcqFC,$visuNo,This).mode.continu_1.nom.extension.menu delete 0 20
      foreach extension $conf(list_extension) {
         $panneau(AcqFC,$visuNo,This).mode.continu_1.nom.extension.menu add radiobutton -label "$extension" \
            -indicatoron "1" \
            -value "$extension" \
            -variable panneau(AcqFC,$visuNo,extension) \
            -command " "
      }
   }
#***** Fin de la procedure Init_list_extension *****************

#***** Procedure Adapt_Panneau_AcqFC ***************************
   proc Adapt_Panneau_AcqFC { visuNo { a "" } { b "" } { c "" } } {
      global audace conf panneau

      set panneau(AcqFC,$visuNo,camItem) [::confVisu::getCamItem $visuNo]
      set panneau(AcqFC,$visuNo,camNo)   [::confCam::getCamNo $panneau(AcqFC,$visuNo,camItem)]

      #--- Decoche le checkbutton Apercu des modes Video
      set panneau(AcqFC,$visuNo,showvideopreview) "0"
      #---
      set camNo [ ::confVisu::getCamNo $visuNo ]
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
            pack forget $panneau(AcqFC,$visuNo,This).pose.but
            pack forget $panneau(AcqFC,$visuNo,This).pose.lab
            pack forget $panneau(AcqFC,$visuNo,This).pose.entr
            pack forget $panneau(AcqFC,$visuNo,This).bin.but
            pack forget $panneau(AcqFC,$visuNo,This).bin.lab
            pack $panneau(AcqFC,$visuNo,This).pose.conf -fill x -expand true -ipady 3
            pack forget $panneau(AcqFC,$visuNo,This).obt.but
            pack forget $panneau(AcqFC,$visuNo,This).obt.lab
            pack forget $panneau(AcqFC,$visuNo,This).obt.lab1
            pack forget $panneau(AcqFC,$visuNo,This).obt.dslr
         } else {
            #--- Cas d'une WebCam Longue Pose
            pack $panneau(AcqFC,$visuNo,This).pose.but -side left
            pack $panneau(AcqFC,$visuNo,This).pose.lab -side right
            pack $panneau(AcqFC,$visuNo,This).pose.entr -side left
            pack forget $panneau(AcqFC,$visuNo,This).bin.but
            pack forget $panneau(AcqFC,$visuNo,This).bin.lab
            pack forget $panneau(AcqFC,$visuNo,This).pose.conf
            pack forget $panneau(AcqFC,$visuNo,This).obt.but
            pack forget $panneau(AcqFC,$visuNo,This).obt.lab
            pack forget $panneau(AcqFC,$visuNo,This).obt.lab1
            pack forget $panneau(AcqFC,$visuNo,This).obt.dslr
         }
      } elseif { "$camProduct" == "dslr" } {
         #--- C'est une APN (DSLR)
         pack $panneau(AcqFC,$visuNo,This).pose.but -side left
         pack $panneau(AcqFC,$visuNo,This).pose.lab -side right
         pack $panneau(AcqFC,$visuNo,This).pose.entr -side left
         pack $panneau(AcqFC,$visuNo,This).bin.but -side left
         pack $panneau(AcqFC,$visuNo,This).bin.lab -side left
         pack forget $panneau(AcqFC,$visuNo,This).pose.conf
         pack forget $panneau(AcqFC,$visuNo,This).obt.but
         pack forget $panneau(AcqFC,$visuNo,This).obt.lab
         pack forget $panneau(AcqFC,$visuNo,This).obt.lab1
         pack $panneau(AcqFC,$visuNo,This).obt.dslr -fill x -expand true -ipady 3
      } else {
         #--- Ce n'est pas une WebCam, ni une APN (DSLR)
         pack $panneau(AcqFC,$visuNo,This).pose.but -side left
         pack $panneau(AcqFC,$visuNo,This).pose.lab -side right
         pack $panneau(AcqFC,$visuNo,This).pose.entr -side left
         pack $panneau(AcqFC,$visuNo,This).bin.but -side left
         pack $panneau(AcqFC,$visuNo,This).bin.lab -side left
         pack forget $panneau(AcqFC,$visuNo,This).pose.conf
         pack $panneau(AcqFC,$visuNo,This).obt.but -side left -ipady 3
         pack $panneau(AcqFC,$visuNo,This).obt.lab -side left -fill x -expand true -ipady 3
         pack forget $panneau(AcqFC,$visuNo,This).obt.lab1
         pack forget $panneau(AcqFC,$visuNo,This).obt.dslr
      }

      if { [ ::confCam::getPluginProperty [ ::confVisu::getCamItem $visuNo ] hasShutter ] == "1" } {
         pack forget $panneau(AcqFC,$visuNo,This).obt.lab
         if { ! [ info exists conf($camProduct,foncobtu) ] } {
            set conf($camProduct,foncobtu) "2"
         } else {
            if { $conf($camProduct,foncobtu) == "0" } {
               set panneau(AcqFC,$visuNo,obt) "0"
            } elseif { $conf($camProduct,foncobtu) == "1" } {
               set panneau(AcqFC,$visuNo,obt) "1"
            } elseif { $conf($camProduct,foncobtu) == "2" } {
               set panneau(AcqFC,$visuNo,obt) "2"
            }
         }
         $panneau(AcqFC,$visuNo,This).obt.lab configure -text $panneau(AcqFC,$visuNo,obt,$panneau(AcqFC,$visuNo,obt))
         pack $panneau(AcqFC,$visuNo,This).obt.lab -fill both -expand true -ipady 3
      } else {
         pack forget $panneau(AcqFC,$visuNo,This).obt.but
         pack forget $panneau(AcqFC,$visuNo,This).obt.lab
         if { ( "$camProduct" != "webcam" ) && ( "$camProduct" != "dslr" ) } {
            pack $panneau(AcqFC,$visuNo,This).obt.lab1 -side top -ipady 3
         }
      }
      #---
      $panneau(AcqFC,$visuNo,This).bin.but.menu delete 0 20
      set list_binning [ ::confCam::getPluginProperty [ ::confVisu::getCamItem $visuNo ] binningList ]
      foreach valbin $list_binning {
         $panneau(AcqFC,$visuNo,This).bin.but.menu add radiobutton -label "$valbin" \
            -indicatoron "1" \
            -value "$valbin" \
            -variable panneau(AcqFC,$visuNo,bin) \
            -command " "
      }
      #---
      if { [ lsearch $list_binning $panneau(AcqFC,$visuNo,bin) ] == "-1" } {
         if { [ llength $list_binning ] >= "2" } {
            set panneau(AcqFC,$visuNo,bin) [ lindex $list_binning 1 ]
         } else {
            set panneau(AcqFC,$visuNo,bin) [ lindex $list_binning 0 ]
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
      if { ! [ info exists parametres(acqFC,$visuNo,pose) ] }    { set parametres(acqFC,$visuNo,pose)    "5" }   ; #--- Temps de pose : 5s
      if { ! [ info exists parametres(acqFC,$visuNo,bin) ] }     { set parametres(acqFC,$visuNo,bin)     "2x2" } ; #--- Binning : 2x2
      if { ! [ info exists parametres(acqFC,$visuNo,obt) ] }     { set parametres(acqFC,$visuNo,obt)     "2" }   ; #--- Obturateur : Synchro
      if { ! [ info exists parametres(acqFC,$visuNo,mode) ] }    { set parametres(acqFC,$visuNo,mode)    "1" }   ; #--- Mode : Une image
      if { ! [ info exists parametres(acqFC,$visuNo,lg_film) ] } { set parametres(acqFC,$visuNo,lg_film) "10" }  ; #--- Duree de la video : 10s
      if { ! [ info exists parametres(acqFC,$visuNo,rate) ] }    { set parametres(acqFC,$visuNo,rate)    "5" }   ; #--- Images/sec. : 5
      if { ! [ info exists parametres(acqFC,$visuNo,x1) ] }      { set parametres(acqFC,$visuNo,x1)      "100" } ; #--- Video fenetree : x1
      if { ! [ info exists parametres(acqFC,$visuNo,y1) ] }      { set parametres(acqFC,$visuNo,y1)      "100" } ; #--- Video fenetree : y1
      if { ! [ info exists parametres(acqFC,$visuNo,x2) ] }      { set parametres(acqFC,$visuNo,x2)      "350" } ; #--- Video fenetree : x2
      if { ! [ info exists parametres(acqFC,$visuNo,y2) ] }      { set parametres(acqFC,$visuNo,y2)      "250" } ; #--- Video fenetree : y2

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      ::acqfcSetup::initToConf $visuNo
   }
#***** Fin de la procedure Chargement_Var **********************

#***** Procedure Enregistrement_Var ****************************
   proc Enregistrement_Var { visuNo } {
      variable parametres
      global audace panneau

      #---
      set panneau(AcqFC,$visuNo,mode)       [ expr [ lsearch "$panneau(AcqFC,$visuNo,list_mode)" "$panneau(AcqFC,$visuNo,mode_en_cours)" ] + 1 ]
      #---
      set parametres(acqFC,$visuNo,pose)    $panneau(AcqFC,$visuNo,pose)
      set parametres(acqFC,$visuNo,bin)     $panneau(AcqFC,$visuNo,bin)
      set parametres(acqFC,$visuNo,obt)     $panneau(AcqFC,$visuNo,obt)
      set parametres(acqFC,$visuNo,mode)    $panneau(AcqFC,$visuNo,mode)
      set parametres(acqFC,$visuNo,lg_film) $panneau(AcqFC,$visuNo,lg_film)
      set parametres(acqFC,$visuNo,rate)    $panneau(AcqFC,$visuNo,rate)
      set parametres(acqFC,$visuNo,x1)      $panneau(AcqFC,$visuNo,x1)
      set parametres(acqFC,$visuNo,y1)      $panneau(AcqFC,$visuNo,y1)
      set parametres(acqFC,$visuNo,x2)      $panneau(AcqFC,$visuNo,x2)
      set parametres(acqFC,$visuNo,y2)      $panneau(AcqFC,$visuNo,y2)
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

      #--- Initialisation des variables de la boite de configuration
      ::acqfcSetup::confToWidget $visuNo

      #--- Creation des fenetres auxiliaires si necessaire
      if { $panneau(AcqFC,$visuNo,mode) == "4" } {
         ::AcqFC::Intervalle_continu_1 $visuNo
      } elseif { $panneau(AcqFC,$visuNo,mode) == "5" } {
         ::AcqFC::Intervalle_continu_2 $visuNo
      } elseif { $panneau(AcqFC,$visuNo,mode) == "6" } {
         ::AcqFC::selectVideoMode $visuNo
      } elseif { $panneau(AcqFC,$visuNo,mode) == "7" } {
         ::AcqFC::selectVideoMode $visuNo
      }

      pack $panneau(AcqFC,$visuNo,This) -side left -fill y
      ::AcqFC::Adapt_Panneau_AcqFC $visuNo
   }
#***** Fin de la procedure startTool ***************************

#***** Procedure stopTool **************************************
   proc stopTool { { visuNo 1 } } {
      global audace conf panneau

      #--- Sauvegarde de la configuration de prise de vue
      ::AcqFC::Enregistrement_Var $visuNo

      #--- Destruction des fenetres auxiliaires et sauvegarde de leurs positions si elles existent
      ::AcqFC::recup_position $visuNo

      if { [ ::confVisu::getCamera $visuNo ] != "" && $panneau(AcqFC,$visuNo,showvideopreview) == "1" } {
         stopVideoPreview $visuNo
      }

      ArretAcqFC $visuNo
      pack forget $panneau(AcqFC,$visuNo,This)
   }
#***** Fin de la procedure stopTool ****************************

#***** Procedure de changement du mode d'acquisition ***********
   proc ChangeMode { visuNo } {
      global panneau

      pack forget $panneau(AcqFC,$visuNo,mode,$panneau(AcqFC,$visuNo,mode)) -anchor nw -fill x

      if { $panneau(AcqFC,$visuNo,showvideopreview) == "1" } {
         catch { stopVideoPreview $visuNo }
      }
      set panneau(AcqFC,$visuNo,mode) [ expr [ lsearch "$panneau(AcqFC,$visuNo,list_mode)" "$panneau(AcqFC,$visuNo,mode_en_cours)" ] + 1 ]
      if { $panneau(AcqFC,$visuNo,mode) == "1" } {
         ::AcqFC::recup_position $visuNo
         $panneau(AcqFC,$visuNo,This).obt.dslr configure -state normal
      } elseif { $panneau(AcqFC,$visuNo,mode) == "2" } {
         ::AcqFC::recup_position $visuNo
         $panneau(AcqFC,$visuNo,This).obt.dslr configure -state normal
      } elseif { $panneau(AcqFC,$visuNo,mode) == "3" } {
         ::AcqFC::recup_position $visuNo
         $panneau(AcqFC,$visuNo,This).obt.dslr configure -state normal
      } elseif { $panneau(AcqFC,$visuNo,mode) == "4" } {
         ::AcqFC::Intervalle_continu_1 $visuNo
         $panneau(AcqFC,$visuNo,This).obt.dslr configure -state normal
      } elseif { $panneau(AcqFC,$visuNo,mode) == "5" } {
         ::AcqFC::Intervalle_continu_2 $visuNo
         $panneau(AcqFC,$visuNo,This).obt.dslr configure -state normal
      } elseif { $panneau(AcqFC,$visuNo,mode) == "6" } {
         set panneau(AcqFC,$visuNo,fenetre) "0"
         ::AcqFC::selectVideoMode $visuNo
         $panneau(AcqFC,$visuNo,This).obt.dslr configure -state disabled
      } elseif { $panneau(AcqFC,$visuNo,mode) == "7" } {
         set panneau(AcqFC,$visuNo,fenetre) "0"
         ::AcqFC::selectVideoMode $visuNo
         $panneau(AcqFC,$visuNo,This).obt.dslr configure -state disabled
      }
      pack $panneau(AcqFC,$visuNo,mode,$panneau(AcqFC,$visuNo,mode)) -anchor nw -fill x
   }
#***** Fin de la procedure de changement du mode d'acquisition *

#***** Procedure de changement de l'obturateur *****************
   proc ChangeObt { visuNo } {
      global audace caption conf confCam panneau

      #---
      set camNo [ ::confVisu::getCamNo $visuNo ]
      set result [::confCam::setShutter $camNo $panneau(AcqFC,$visuNo,obt) ]
      if { $result != -1 } {
         set panneau(AcqFC,$visuNo,obt) $result
         $panneau(AcqFC,$visuNo,This).obt.lab configure -text $panneau(AcqFC,$visuNo,obt,$panneau(AcqFC,$visuNo,obt))
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

      #--- Ouverture du fichier historique
      if { $panneau(AcqFC,$visuNo,session_ouverture) == "1" } {
         DemarrageAcqFC $visuNo
         set panneau(AcqFC,$visuNo,session_ouverture) "0"
      }

      #--- Recopie de l'extension des fichiers image
      set ext $panneau(AcqFC,$visuNo,extension)

      switch $panneau(AcqFC,$visuNo,go_stop) {
        go {
           #--- Desactive le bouton Go, pour eviter un double appui
           $panneau(AcqFC,$visuNo,This).go_stop.but configure -state disabled

           #------ Tests generaux d'integrite de la requete -------------------------

           set integre oui
           #--- Teste si une camera est bien selectionnee
           if { [ ::confVisu::getCamera $visuNo ] == "" } {
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
           if { $panneau(AcqFC,$visuNo,pose) == "" } {
              tk_messageBox -title $caption(acqfc,pb) -type ok \
                 -message $caption(acqfc,saistps)
              set integre non
           }
           #--- Le champ "temps de pose" est-il bien un reel positif ?
           if { [ TestReel $panneau(AcqFC,$visuNo,pose) ] == "0" } {
              tk_messageBox -title $caption(acqfc,pb) -type ok \
                 -message $caption(acqfc,Tpsinv)
              set integre non
           }

           #--- Tests d'integrite specifiques a chaque mode d'acquisition
           if { $integre == "oui" } {
              #--- Branchement selon le mode de prise de vue
              switch $panneau(AcqFC,$visuNo,mode) {
                 1  {
                    #--- Mode une image
                    if { $panneau(AcqFC,$visuNo,indexer) == "1" } {
                       #--- Verifie que l'index existe
                       if { $panneau(AcqFC,$visuNo,index) == "" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,saisind)
                          set integre non
                       }
                       #--- Verifie que l'index est valide (entier positif)
                       if { [ TestEntier $panneau(AcqFC,$visuNo,index) ] == "0" } {
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
                    if { $panneau(AcqFC,$visuNo,nom_image) == "" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,donnomfich)
                       set integre non
                    }
                    #--- Verifier que le nom de fichier n'a pas d'espace
                    if { [ llength $panneau(AcqFC,$visuNo,nom_image) ] > "1" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,nomblanc)
                       set integre non
                    }
                    #--- Verifie que le nom de fichier ne contient pas de caracteres interdits
                    if { [ TestChaine $panneau(AcqFC,$visuNo,nom_image) ] == "0" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,mauvcar)
                       set integre non
                    }
                    #--- Verifie que le nombre de poses est valide (nombre entier)
                    if { [ TestEntier $panneau(AcqFC,$visuNo,nb_images) ] == "0" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,nbinv)
                       set integre non
                    }
                    #--- Verifie que l'index existe
                    if { $panneau(AcqFC,$visuNo,index) == "" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,saisind)
                       set integre non
                    }
                    #--- Verifie que l'index est valide (entier positif)
                    if { [ TestEntier $panneau(AcqFC,$visuNo,index) ] == "0" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,indinv)
                       set integre non
                    }
                    #--- Envoie un warning si l'index n'est pas a 1
                    if { $panneau(AcqFC,$visuNo,index) != "1" } {
                       set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                          -message $caption(acqfc,indpasun)]
                       if { $confirmation == "no" } {
                          set integre non
                       }
                    }
                    #--- Verifie que le nom des fichiers n'existe pas deja...
                    set nom $panneau(AcqFC,$visuNo,nom_image)
                    #--- Pour eviter un nom de fichier qui commence par un blanc
                    set nom [lindex $nom 0]
                    append nom $panneau(AcqFC,$visuNo,index) $ext
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
                    if { $panneau(AcqFC,$visuNo,enregistrer) == "1" } {
                       #--- Verifier qu'il y a bien un nom de fichier
                       if { $panneau(AcqFC,$visuNo,nom_image) == "" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,donnomfich)
                          set integre non
                       }
                       #--- Verifier que le nom de fichier n'a pas d'espace
                       if { [ llength $panneau(AcqFC,$visuNo,nom_image) ] > "1" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,nomblanc)
                          set integre non
                       }
                       #--- Verifie que le nom de fichier ne contient pas de caracteres interdits
                       if { [ TestChaine $panneau(AcqFC,$visuNo,nom_image) ] == "0" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,mauvcar)
                          set integre non
                       }
                       #--- Verifie que l'index existe
                       if { $panneau(AcqFC,$visuNo,index) == "" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,saisind)
                          set integre non
                       }
                       #--- Verifie que l'index est valide (entier positif)
                       if { [ TestEntier $panneau(AcqFC,$visuNo,index) ] == "0" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,indinv)
                          set integre non
                       }
                       #--- Envoie un warning si l'index n'est pas a 1
                       if { $panneau(AcqFC,$visuNo,index) != "1" } {
                          set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                             -message $caption(acqfc,indpasun)]
                          if { $confirmation == "no" } {
                             set integre non
                          }
                       }
                       #--- Verifie que le nom des fichiers n'existe pas deja...
                       set nom $panneau(AcqFC,$visuNo,nom_image)
                       #--- Pour eviter un nom de fichier qui commence par un blanc
                       set nom [lindex $nom 0]
                       append nom $panneau(AcqFC,$visuNo,index) $ext
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
                    if { $panneau(AcqFC,$visuNo,nom_image) == "" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,donnomfich)
                       set integre non
                    }
                    #--- Verifier que le nom de fichier n'a pas d'espace
                    if { [ llength $panneau(AcqFC,$visuNo,nom_image) ] > "1" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,nomblanc)
                       set integre non
                    }
                    #--- Verifie que le nom de fichier ne contient pas de caracteres interdits
                    if { [ TestChaine $panneau(AcqFC,$visuNo,nom_image) ] == "0" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,mauvcar)
                       set integre non
                    }
                    #--- Verifie que le nombre de poses est valide (nombre entier)
                    if { [ TestEntier $panneau(AcqFC,$visuNo,nb_images) ] == "0"} {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,nbinv)
                       set integre non
                    }
                    #--- Verifie que l'index existe
                    if { $panneau(AcqFC,$visuNo,index) == "" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,saisind)
                       set integre non
                    }
                    #--- Verifie que l'index est valide (entier positif)
                    if { [ TestEntier $panneau(AcqFC,$visuNo,index) ] == "0" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,indinv)
                       set integre non
                    }
                    #--- Envoie un warning si l'index n'est pas a 1
                    if { $panneau(AcqFC,$visuNo,index) != "1" } {
                       set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                          -message $caption(acqfc,indpasun)]
                       if { $confirmation == "no" } {
                          set integre non
                       }
                    }
                    #--- Verifie que la simulation a ete lancee
                    if { $panneau(AcqFC,$visuNo,intervalle) == "....." } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,interinv_2)
                       set integre non
                    #--- Verifie que l'intervalle est valide (entier positif)
                    } elseif { [ TestEntier $panneau(AcqFC,$visuNo,intervalle_1) ] == "0" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,interinv)
                       set integre non
                    #--- Verifie que l'intervalle est superieur a celui calcule par la simulation
                    } elseif { ( $panneau(AcqFC,$visuNo,intervalle) > $panneau(AcqFC,$visuNo,intervalle_1) ) && \
                      ( $panneau(AcqFC,$visuNo,intervalle) != "xxx" ) } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,interinv_1)
                          set integre non
                    }
                    #--- Verifie que le nom des fichiers n'existe pas deja...
                    set nom $panneau(AcqFC,$visuNo,nom_image)
                    #--- Pour eviter un nom de fichier qui commence par un blanc
                    set nom [lindex $nom 0]
                    append nom $panneau(AcqFC,$visuNo,index) $ext
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
                    if { $panneau(AcqFC,$visuNo,enregistrer) == "1" } {
                       #--- Verifier qu'il y a bien un nom de fichier
                       if { $panneau(AcqFC,$visuNo,nom_image) == "" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,donnomfich)
                          set integre non
                       }
                       #--- Verifier que le nom de fichier n'a pas d'espace
                       if { [ llength $panneau(AcqFC,$visuNo,nom_image) ] > "1" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,nomblanc)
                          set integre non
                       }
                       #--- Verifie que le nom de fichier ne contient pas de caracteres interdits
                       if { [ TestChaine $panneau(AcqFC,$visuNo,nom_image) ] == "0" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,mauvcar)
                          set integre non
                       }
                       #--- Verifie que l'index existe
                       if { $panneau(AcqFC,$visuNo,index) == "" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,saisind)
                          set integre non
                       }
                       #--- Verifie que l'index est valide (entier positif)
                       if { [ TestEntier $panneau(AcqFC,$visuNo,index) ] == "0" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,indinv)
                          set integre non
                       }
                       #--- Envoie un warning si l'index n'est pas a 1
                       if { $panneau(AcqFC,$visuNo,index) != "1" } {
                          set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                             -message $caption(acqfc,indpasun)]
                          if { $confirmation == "no" } {
                             set integre non
                          }
                       }
                       #--- Verifie que la simulation a ete lancee
                       if { $panneau(AcqFC,$visuNo,intervalle) == "....." } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,interinv_2)
                          set integre non
                       #--- Verifie que l'intervalle est valide (entier positif)
                       } elseif { [ TestEntier $panneau(AcqFC,$visuNo,intervalle_2) ] == "0" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,interinv)
                          set integre non
                       #--- Verifie que l'intervalle est superieur a celui calcule par la simulation
                       } elseif { ( $panneau(AcqFC,$visuNo,intervalle) > $panneau(AcqFC,$visuNo,intervalle_2) ) && \
                         ( $panneau(AcqFC,$visuNo,intervalle) != "xxx" ) } {
                             tk_messageBox -title $caption(acqfc,pb) -type ok \
                                -message $caption(acqfc,interinv_1)
                             set integre non
                       }
                       #--- Verifie que le nom des fichiers n'existe pas deja...
                       set nom $panneau(AcqFC,$visuNo,nom_image)
                       #--- Pour eviter un nom de fichier qui commence par un blanc
                       set nom [lindex $nom 0]
                       append nom $panneau(AcqFC,$visuNo,index) $ext
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
                       if { $panneau(AcqFC,$visuNo,intervalle) == "....." } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,interinv_2)
                          set integre non
                       #--- Verifie que l'intervalle est valide (entier positif)
                       } elseif { [ TestEntier $panneau(AcqFC,$visuNo,intervalle_2) ] == "0" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,interinv)
                          set integre non
                       #--- Verifie que l'intervalle est superieur a celui calcule par la simulation
                       } elseif { ( $panneau(AcqFC,$visuNo,intervalle) > $panneau(AcqFC,$visuNo,intervalle_2) ) && \
                         ( $panneau(AcqFC,$visuNo,intervalle) != "xxx" ) } {
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
                    #--- Verifier qu'il s'agit bien d'une WebCam
                    if { [ ::confVisu::getProduct $visuNo ] != "webcam" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message "$caption(acqfc,pb_camera1) [ ::confVisu::getProduct $visuNo ] $caption(acqfc,pb_camera2)"
                       set integre non
                    }
                    #--- Verifier qu'il y a bien un nom de fichier
                    if { $panneau(AcqFC,$visuNo,nom_image) == "" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,donnomfich)
                       set integre non
                    }
                    #--- Verifier que le nom de fichier n'a pas d'espace
                    if { [ llength $panneau(AcqFC,$visuNo,nom_image) ] > "1" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,nomblanc)
                       set integre non
                    }
                    #--- Verifie que le nom de fichier ne contient pas de caracteres interdits
                    if { [ TestChaine $panneau(AcqFC,$visuNo,nom_image) ] == "0" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,mauvcar)
                       set integre non
                    }
                    if { $panneau(AcqFC,$visuNo,indexer) == "1" } {
                       #--- Verifie que l'index existe
                       if { $panneau(AcqFC,$visuNo,index) == "" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                              -message $caption(acqfc,saisind)
                          set integre non
                       }
                       #--- Verifie que l'index est valide (entier positif)
                       if { [ TestEntier $panneau(AcqFC,$visuNo,index) ] == "0" } {
                          tk_messageBox -title $caption(acqfc,pb) -type ok \
                             -message $caption(acqfc,indinv)
                          set integre non
                       }
                       #--- Envoie un warning si l'index n'est pas a 1
                       if { $panneau(AcqFC,$visuNo,index) != "1" } {
                          set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                             -message $caption(acqfc,indpasun)]
                          if { $confirmation == "no" } {
                             set integre non
                          }
                       }
                    }
                    #--- Verifie que le nom des fichiers n'existe pas deja...
                    set nom $panneau(AcqFC,$visuNo,nom_image)
                    #--- Pour eviter un nom de fichier qui commence par un blanc
                    set nom [lindex $nom 0]
                    append nom $panneau(AcqFC,$visuNo,index) ".avi"
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
                    #--- Verifier qu'il s'agit bien d'une WebCam
                    if { [ ::confVisu::getProduct $visuNo ] != "webcam" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message "$caption(acqfc,pb_camera1) [ ::confVisu::getProduct $visuNo ] $caption(acqfc,pb_camera2)"
                       set integre non
                    }
                    #--- Verifier qu'il y a bien un nom de fichier
                    if { $panneau(AcqFC,$visuNo,nom_image) == "" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,donnomfich)
                       set integre non
                    }
                    #--- Verifier que le nom de fichier n'a pas d'espace
                    if { [ llength $panneau(AcqFC,$visuNo,nom_image) ] > "1" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,nomblanc)
                       set integre non
                    }
                    #--- Verifie que le nom de fichier ne contient pas de caracteres interdits
                    if { [ TestChaine $panneau(AcqFC,$visuNo,nom_image) ] == "0" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,mauvcar)
                       set integre non
                    }
                    #--- Verifie que l'index existe
                    if { $panneau(AcqFC,$visuNo,index) == "" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                           -message $caption(acqfc,saisind)
                       set integre non
                    }
                    #--- Verifie que l'index est valide (entier positif)
                    if { [ TestEntier $panneau(AcqFC,$visuNo,index) ] == "0" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,indinv)
                       set integre non
                    }
                    #--- Envoie un warning si l'index n'est pas a 1
                    if { $panneau(AcqFC,$visuNo,index) != "1" } {
                       set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                          -message $caption(acqfc,indpasun)]
                       if { $confirmation == "no" } {
                          set integre non
                       }
                    }
                    #--- Verifie que l'intervalle est valide (entier positif)
                    if { [ TestEntier $panneau(AcqFC,$visuNo,intervalle_video) ] == "0" } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,interinv)
                       set integre non
                    #--- Verifie que l'intervalle est superieur a la duree du film
                    } elseif { $panneau(AcqFC,$visuNo,lg_film) > $panneau(AcqFC,$visuNo,intervalle_video) } {
                       tk_messageBox -title $caption(acqfc,pb) -type ok \
                          -message $caption(acqfc,interinv_3)
                       set integre non
                    }
                    #--- Verifie que le nom des fichiers n'existe pas deja...
                    set nom $panneau(AcqFC,$visuNo,nom_image)
                    #--- Pour eviter un nom de fichier qui commence par un blanc
                    set nom [lindex $nom 0]
                    append nom $panneau(AcqFC,$visuNo,index) ".avi"
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
           $panneau(AcqFC,$visuNo,This).go_stop.but configure -state normal
           #--- Apres tous les tests d'integrite, je peux maintenant lancer les acquisitions
           if { $integre == "oui" } {
              #--- Modification du bouton, pour eviter un second lancement
              set panneau(AcqFC,$visuNo,go_stop) stop
              $panneau(AcqFC,$visuNo,This).go_stop.but configure -text $caption(acqfc,stop)
              #--- Verouille tous les boutons et champs de texte pendant les acquisitions
              $panneau(AcqFC,$visuNo,This).pose.but configure -state disabled
              $panneau(AcqFC,$visuNo,This).pose.entr configure -state disabled
              $panneau(AcqFC,$visuNo,This).bin.but configure -state disabled
              $panneau(AcqFC,$visuNo,This).obt.but configure -state disabled
              $panneau(AcqFC,$visuNo,This).mode.but configure -state disabled
              #--- Desactive toute demande d'arret
              set panneau(AcqFC,$visuNo,demande_arret) "0"
              #--- Pose en cours
              set panneau(AcqFC,$visuNo,pose_en_cours) "1"
              #--- Cas particulier du passage WebCam LP en WebCam normale pour inhiber la barre progression
              set camNo [ ::confVisu::getCamNo $visuNo ]
              if { ( [ ::confVisu::getProduct $visuNo ] == "webcam" ) && ( [ confCam::getPluginProperty [ ::confVisu::getCamItem $visuNo ] longExposure ] == "0" ) } {
                 set panneau(AcqFC,$visuNo,pose) "0"
              }
              #--- Branchement selon le mode de prise de vue
              switch $panneau(AcqFC,$visuNo,mode) {
                 1  {
                    #--- Mode une image
                    #--- Verouille les boutons du mode "une image"
                    $panneau(AcqFC,$visuNo,This).mode.une.nom.entr configure -state disabled
                    $panneau(AcqFC,$visuNo,This).mode.une.index.case configure -state disabled
                    $panneau(AcqFC,$visuNo,This).mode.une.index.entr configure -state disabled
                    $panneau(AcqFC,$visuNo,This).mode.une.index.but configure -state disabled
                    $panneau(AcqFC,$visuNo,This).mode.une.sauve configure -state disabled
                    set heure $audace(tu,format,hmsint)
                    Message $visuNo consolog $caption(acqfc,acquneim) \
                       $panneau(AcqFC,$visuNo,pose) $panneau(AcqFC,$visuNo,bin) $heure
                    acq $visuNo $panneau(AcqFC,$visuNo,pose) $panneau(AcqFC,$visuNo,bin)
                    #--- Deverouille les boutons du mode "une image"
                    $panneau(AcqFC,$visuNo,This).mode.une.nom.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.une.index.case configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.une.index.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.une.index.but configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.une.sauve configure -state normal
                    #--- Pose en cours
                    set panneau(AcqFC,$visuNo,pose_en_cours) "0"
                 }
                 2  {
                    #--- Mode serie
                    #--- Verouille les boutons du mode "serie"
                    $panneau(AcqFC,$visuNo,This).mode.serie.nom.entr configure -state disabled
                    $panneau(AcqFC,$visuNo,This).mode.serie.nb.entr configure -state disabled
                    $panneau(AcqFC,$visuNo,This).mode.serie.index.entr configure -state disabled
                    $panneau(AcqFC,$visuNo,This).mode.serie.index.but configure -state disabled
                    set heure $audace(tu,format,hmsint)
                    if { $panneau(AcqFC,$visuNo,simulation) == "1" } {
                       Message $visuNo consolog $caption(acqfc,lance_simu)
                    }
                    Message $visuNo consolog $caption(acqfc,lanceserie) \
                       $panneau(AcqFC,$visuNo,nb_images) $heure
                    Message $visuNo consolog $caption(acqfc,nomgen) $panneau(AcqFC,$visuNo,nom_image) \
                       $panneau(AcqFC,$visuNo,pose) $panneau(AcqFC,$visuNo,bin) $panneau(AcqFC,$visuNo,index)
                    #--- Debut de la premiere pose
                    if { $panneau(AcqFC,$visuNo,simulation) == "1" } {
                       set panneau(AcqFC,$visuNo,debut) [ clock second ]
                    }
                    for { set i 1 } { ( $i <= $panneau(AcqFC,$visuNo,nb_images) ) && ( $panneau(AcqFC,$visuNo,demande_arret) == "0" ) } { incr i } {
                       acq $visuNo $panneau(AcqFC,$visuNo,pose) $panneau(AcqFC,$visuNo,bin)
                       #--- Je dois encore sauvegarder l'image
                       $panneau(AcqFC,$visuNo,This).status.lab configure -text $caption(acqfc,enreg)
                       set nom $panneau(AcqFC,$visuNo,nom_image)
                       #--- Pour eviter un nom de fichier qui commence par un blanc
                       set nom [lindex $nom 0]
                       if { $panneau(AcqFC,$visuNo,simulation) == "0" } {
                          #--- Verifie que le nom du fichier n'existe pas deja...
                          set nom1 "$nom"
                          append nom1 $panneau(AcqFC,$visuNo,index) $ext
                          if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
                             #--- Dans ce cas, le fichier existe deja...
                             set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                                -message $caption(acqfc,fichdeja)]
                             if { $confirmation == "no" } {
                                break
                             }
                          }
                          #--- Sauvegarde de l'image
                          saveima [append nom $panneau(AcqFC,$visuNo,index)$panneau(AcqFC,$visuNo,extension)] $visuNo
                          set heure $audace(tu,format,hmsint)
                          Message $visuNo consolog $caption(acqfc,enrim) $heure $nom
                       }
                       incr panneau(AcqFC,$visuNo,index)
                       $panneau(AcqFC,$visuNo,This).status.lab configure -text ""
                       if { $panneau(AcqFC,$visuNo,simulation) == "0" } {
                          if { $i != "$panneau(AcqFC,$visuNo,nb_images)" } {
                             #--- Deplacement du telescope
                             ::DlgShift::Decalage_Telescope
                          }
                       } elseif { $panneau(AcqFC,$visuNo,simulation) == "1" } {
                          #--- Deplacement du telescope
                          ::DlgShift::Decalage_Telescope
                       }
                    }
                    #--- Fin de la derniere pose et intervalle mini entre 2 poses ou 2 series
                    if { $panneau(AcqFC,$visuNo,simulation) == "1" } {
                       set panneau(AcqFC,$visuNo,fin) [ clock second ]
                       set panneau(AcqFC,$visuNo,intervalle) [ expr $panneau(AcqFC,$visuNo,fin) - $panneau(AcqFC,$visuNo,debut) ]
                       Message $visuNo consolog $caption(acqfc,fin_simu)
                    }
                    #--- Cas particulier des cameras APN (DSLR)
                    if { $conf(dslr,telecharge_mode) == "3" } {
                       #--- Chargement de la derniere image
                       set result [ catch { cam[ ::confVisu::getCamNo $visuNo ] loadlastimage } msg ]
                       if { $result == "1" } {
                          ::console::disp "::AcqFC::GoStop loadlastimage $msg \n"
                       } else {
                          ::console::disp "::AcqFC::GoStop loadlastimage OK \n"
                       }
                       #--- Visualisation de l'image
                       ::audace::autovisu $visuNo
                    }
                    #--- Deverouille les boutons du mode "serie"
                    $panneau(AcqFC,$visuNo,This).mode.serie.nom.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.serie.nb.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.serie.index.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.serie.index.but configure -state normal
                    #--- Pose en cours
                    set panneau(AcqFC,$visuNo,pose_en_cours) "0"
                 }
                 3  {
                    #--- Mode continu
                    #--- Verouille les boutons du mode "continu"
                    $panneau(AcqFC,$visuNo,This).mode.continu.sauve.case configure -state disabled
                    $panneau(AcqFC,$visuNo,This).mode.continu.nom.entr configure -state disabled
                    $panneau(AcqFC,$visuNo,This).mode.continu.index.entr configure -state disabled
                    $panneau(AcqFC,$visuNo,This).mode.continu.index.but configure -state disabled
                    set heure $audace(tu,format,hmsint)
                    Message $visuNo consolog $caption(acqfc,lancecont) $panneau(AcqFC,$visuNo,pose) $panneau(AcqFC,$visuNo,bin) $heure
                    if { $panneau(AcqFC,$visuNo,enregistrer) == "1" } {
                       Message $visuNo consolog $caption(acqfc,enregen) \
                         $panneau(AcqFC,$visuNo,nom_image)
                    } else {
                       Message $visuNo consolog $caption(acqfc,sansenr)
                    }
                    while { ( $panneau(AcqFC,$visuNo,demande_arret) == "0" ) && ( $panneau(AcqFC,$visuNo,mode) == "3" ) } {
                       acq $visuNo $panneau(AcqFC,$visuNo,pose) $panneau(AcqFC,$visuNo,bin)
                       #--- Je dois encore sauvegarder l'image
                       if { $panneau(AcqFC,$visuNo,enregistrer) == "1" } {
                          $panneau(AcqFC,$visuNo,This).status.lab configure -text $caption(acqfc,enreg)
                          set nom $panneau(AcqFC,$visuNo,nom_image)
                          #--- Pour eviter un nom de fichier qui commence par un blanc
                          set nom [lindex $nom 0]
                          if { $panneau(AcqFC,$visuNo,demande_arret) == "0" } {
                             #--- Verifie que le nom du fichier n'existe pas deja...
                             set nom1 "$nom"
                             append nom1 $panneau(AcqFC,$visuNo,index) $ext
                             if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
                                #--- Dans ce cas, le fichier existe deja...
                                set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                                   -message $caption(acqfc,fichdeja)]
                                if { $confirmation == "no" } {
                                   break
                                }
                             }
                             #--- Sauvegarde de l'image
                             saveima [append nom $panneau(AcqFC,$visuNo,index)$panneau(AcqFC,$visuNo,extension)] $visuNo
                          } else {
                             set panneau(AcqFC,$visuNo,index) [ expr $panneau(AcqFC,$visuNo,index) - 1 ]
                          }
                          incr panneau(AcqFC,$visuNo,index)
                          $panneau(AcqFC,$visuNo,This).status.lab configure -text ""
                          set heure $audace(tu,format,hmsint)
                          if { $panneau(AcqFC,$visuNo,demande_arret) == "0" } {
                             Message $visuNo consolog $caption(acqfc,enrim) $heure $nom
                          }
                       }
                       #--- Deplacement du telescope
                       ::DlgShift::Decalage_Telescope
                    }
                    #--- Cas particulier des cameras APN (DSLR)
                    if { $conf(dslr,telecharge_mode) == "3" } {
                       #--- Chargement de la derniere image
                       set result [ catch { cam[ ::confVisu::getCamNo $visuNo ] loadlastimage } msg ]
                       if { $result == "1" } {
                          ::console::disp "::AcqFC::GoStop loadlastimage $msg \n"
                       } else {
                          ::console::disp "::AcqFC::GoStop loadlastimage OK \n"
                       }
                       #--- Visualisation de l'image
                       ::audace::autovisu $visuNo
                    }
                    #--- Deverouille les boutons du mode "continu"
                    $panneau(AcqFC,$visuNo,This).mode.continu.sauve.case configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.continu.nom.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.continu.index.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.continu.index.but configure -state normal
                    #--- Pose en cours
                    set panneau(AcqFC,$visuNo,pose_en_cours) "0"
                 }
                 4  {
                    #--- Mode series d'images en continu avec intervalle entre chaque serie
                    #--- Verouille les boutons du mode "continu 1"
                    $panneau(AcqFC,$visuNo,This).mode.serie_1.nom.entr configure -state disabled
                    $panneau(AcqFC,$visuNo,This).mode.serie_1.nb.entr configure -state disabled
                    $panneau(AcqFC,$visuNo,This).mode.serie_1.index.entr configure -state disabled
                    $panneau(AcqFC,$visuNo,This).mode.serie_1.index.but configure -state disabled
                    set heure $audace(tu,format,hmsint)
                    Message $visuNo consolog $caption(acqfc,lanceserie_int) \
                       $panneau(AcqFC,$visuNo,nb_images) $panneau(AcqFC,$visuNo,intervalle_1) $heure
                    Message $visuNo consolog $caption(acqfc,nomgen) $panneau(AcqFC,$visuNo,nom_image) \
                       $panneau(AcqFC,$visuNo,pose) $panneau(AcqFC,$visuNo,bin) $panneau(AcqFC,$visuNo,index)
                    while { ( $panneau(AcqFC,$visuNo,demande_arret) == "0" ) && ( $panneau(AcqFC,$visuNo,mode) == "4" ) } {
                       set panneau(AcqFC,$visuNo,deb_im) [ clock second ]
                       for { set i 1 } { ( $i <= $panneau(AcqFC,$visuNo,nb_images) ) && ( $panneau(AcqFC,$visuNo,demande_arret) == "0" ) } { incr i } {
                          acq $visuNo $panneau(AcqFC,$visuNo,pose) $panneau(AcqFC,$visuNo,bin)
                          #--- Je dois encore sauvegarder l'image
                          $panneau(AcqFC,$visuNo,This).status.lab configure -text $caption(acqfc,enreg)
                          set nom $panneau(AcqFC,$visuNo,nom_image)
                          #--- Pour eviter un nom de fichier qui commence par un blanc
                          set nom [lindex $nom 0]
                          #--- Verifie que le nom du fichier n'existe pas deja...
                          set nom1 "$nom"
                          append nom1 $panneau(AcqFC,$visuNo,index) $ext
                          if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
                             #--- Dans ce cas, le fichier existe deja...
                             set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                                -message $caption(acqfc,fichdeja)]
                             if { $confirmation == "no" } {
                                break
                             }
                          }
                          #--- Sauvegarde de l'image
                          saveima [append nom $panneau(AcqFC,$visuNo,index)$panneau(AcqFC,$visuNo,extension)] $visuNo
                          incr panneau(AcqFC,$visuNo,index)
                          $panneau(AcqFC,$visuNo,This).status.lab configure -text ""
                          set heure $audace(tu,format,hmsint)
                          Message $visuNo consolog $caption(acqfc,enrim) $heure $nom
                          #--- Deplacement du telescope
                          ::DlgShift::Decalage_Telescope
                       }
                       set panneau(AcqFC,$visuNo,attente_pose) "1"
                       set panneau(AcqFC,$visuNo,fin_im) [ clock second ]
                       set panneau(AcqFC,$visuNo,intervalle_im_1) [ expr $panneau(AcqFC,$visuNo,fin_im) - $panneau(AcqFC,$visuNo,deb_im) ]
                       while { ( $panneau(AcqFC,$visuNo,demande_arret) == "0" ) && ( $panneau(AcqFC,$visuNo,intervalle_im_1) <= $panneau(AcqFC,$visuNo,intervalle_1) ) } {
                          after 500
                          set panneau(AcqFC,$visuNo,fin_im) [ clock second ]
                          set panneau(AcqFC,$visuNo,intervalle_im_1) [ expr $panneau(AcqFC,$visuNo,fin_im) - $panneau(AcqFC,$visuNo,deb_im) + 1 ]
                          set t [ expr $panneau(AcqFC,$visuNo,intervalle_1) - $panneau(AcqFC,$visuNo,intervalle_im_1) ]
                          ::AcqFC::Avancement_pose $visuNo $t
                       }
                       set panneau(AcqFC,$visuNo,attente_pose) "0"
                    }
                    #--- Cas particulier des cameras APN (DSLR)
                    if { $conf(dslr,telecharge_mode) == "3" } {
                       #--- Chargement de la derniere image
                       set result [ catch { cam[ ::confVisu::getCamNo $visuNo ] loadlastimage } msg ]
                       if { $result == "1" } {
                          ::console::disp "::AcqFC::GoStop loadlastimage $msg \n"
                       } else {
                          ::console::disp "::AcqFC::GoStop loadlastimage OK \n"
                       }
                       #--- Visualisation de l'image
                       ::audace::autovisu $visuNo
                    }
                    #--- Deverouille les boutons du mode "continu 1"
                    $panneau(AcqFC,$visuNo,This).mode.serie_1.nom.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.serie_1.nb.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.serie_1.index.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.serie_1.index.but configure -state normal
                    #--- Pose en cours
                    set panneau(AcqFC,$visuNo,pose_en_cours) "0"
                 }
                 5  {
                    #--- Mode continu avec intervalle entre chaque image
                    #--- Verouille les boutons du mode "continu 2"
                    $panneau(AcqFC,$visuNo,This).mode.continu_1.sauve.case configure -state disabled
                    $panneau(AcqFC,$visuNo,This).mode.continu_1.nom.entr configure -state disabled
                    $panneau(AcqFC,$visuNo,This).mode.continu_1.index.entr configure -state disabled
                    $panneau(AcqFC,$visuNo,This).mode.continu_1.index.but configure -state disabled
                    set heure $audace(tu,format,hmsint)
                    Message $visuNo consolog $caption(acqfc,lancecont_int) $panneau(AcqFC,$visuNo,intervalle_2) \
                       $panneau(AcqFC,$visuNo,pose) $panneau(AcqFC,$visuNo,bin) $heure
                    if { $panneau(AcqFC,$visuNo,enregistrer) == "1" } {
                       Message $visuNo consolog $caption(acqfc,enregen) \
                         $panneau(AcqFC,$visuNo,nom_image)
                    } else {
                       Message $visuNo consolog $caption(acqfc,sansenr)
                    }
                    while { ( $panneau(AcqFC,$visuNo,demande_arret) == "0" ) && ( $panneau(AcqFC,$visuNo,mode) == "5" ) } {
                       set panneau(AcqFC,$visuNo,deb_im) [ clock second ]
                       acq $visuNo $panneau(AcqFC,$visuNo,pose) $panneau(AcqFC,$visuNo,bin)
                       #--- Je dois encore sauvegarder l'image
                       if { $panneau(AcqFC,$visuNo,enregistrer) == "1" } {
                          $panneau(AcqFC,$visuNo,This).status.lab configure -text $caption(acqfc,enreg)
                          set nom $panneau(AcqFC,$visuNo,nom_image)
                          #--- Pour eviter un nom de fichier qui commence par un blanc
                          set nom [lindex $nom 0]
                          if { $panneau(AcqFC,$visuNo,demande_arret) == "0" } {
                             #--- Verifie que le nom du fichier n'existe pas deja...
                             set nom1 "$nom"
                             append nom1 $panneau(AcqFC,$visuNo,index) $ext
                             if { [ file exists [ file join $audace(rep_images) $nom1 ] ] == "1" } {
                                #--- Dans ce cas, le fichier existe deja...
                                set confirmation [tk_messageBox -title $caption(acqfc,conf) -type yesno \
                                   -message $caption(acqfc,fichdeja)]
                                if { $confirmation == "no" } {
                                   break
                                }
                             }
                             #--- Sauvegarde de l'image
                             saveima [append nom $panneau(AcqFC,$visuNo,index)$panneau(AcqFC,$visuNo,extension)] $visuNo
                          } else {
                             set panneau(AcqFC,$visuNo,index) [ expr $panneau(AcqFC,$visuNo,index) - 1 ]
                          }
                          incr panneau(AcqFC,$visuNo,index)
                          $panneau(AcqFC,$visuNo,This).status.lab configure -text ""
                          set heure $audace(tu,format,hmsint)
                          if { $panneau(AcqFC,$visuNo,demande_arret) == "0" } {
                             Message $visuNo consolog $caption(acqfc,enrim) $heure $nom
                          }
                       }
                       #--- Deplacement du telescope
                       ::DlgShift::Decalage_Telescope
                       set panneau(AcqFC,$visuNo,attente_pose) "1"
                       set panneau(AcqFC,$visuNo,fin_im) [ clock second ]
                       set panneau(AcqFC,$visuNo,intervalle_im_2) [ expr $panneau(AcqFC,$visuNo,fin_im) - $panneau(AcqFC,$visuNo,deb_im) ]
                       while { ( $panneau(AcqFC,$visuNo,demande_arret) == "0" ) && ( $panneau(AcqFC,$visuNo,intervalle_im_2) <= $panneau(AcqFC,$visuNo,intervalle_2) ) } {
                          after 500
                          set panneau(AcqFC,$visuNo,fin_im) [ clock second ]
                          set panneau(AcqFC,$visuNo,intervalle_im_2) [ expr $panneau(AcqFC,$visuNo,fin_im) - $panneau(AcqFC,$visuNo,deb_im) + 1 ]
                          set t [ expr $panneau(AcqFC,$visuNo,intervalle_2) - $panneau(AcqFC,$visuNo,intervalle_im_2) ]
                          ::AcqFC::Avancement_pose $visuNo $t
                       }
                       set panneau(AcqFC,$visuNo,attente_pose) "0"
                    }
                    set heure $audace(tu,format,hmsint)
                    Message $visuNo consolog $caption(acqfc,arrcont) $heure
                    if { $panneau(AcqFC,$visuNo,enregistrer) == "1" } {
                       set panneau(AcqFC,$visuNo,index) [ expr $panneau(AcqFC,$visuNo,index) - 1 ]
                       Message $visuNo consolog $caption(acqfc,dersauve) [append nom $panneau(AcqFC,$visuNo,index)]
                       set panneau(AcqFC,$visuNo,index) [ expr $panneau(AcqFC,$visuNo,index) + 1 ]
                    }
                    #--- Cas particulier des cameras APN (DSLR)
                    if { $conf(dslr,telecharge_mode) == "3" } {
                       #--- Chargement de la derniere image
                       set result [ catch { cam[ ::confVisu::getCamNo $visuNo ] loadlastimage } msg ]
                       if { $result == "1" } {
                          ::console::disp "::AcqFC::GoStop loadlastimage $msg \n"
                       } else {
                          ::console::disp "::AcqFC::GoStop loadlastimage OK \n"
                       }
                       #--- Visualisation de l'image
                       ::audace::autovisu $visuNo
                    }
                    #--- Deverouille les boutons du mode "continu 2"
                    $panneau(AcqFC,$visuNo,This).mode.continu_1.sauve.case configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.continu_1.nom.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.continu_1.index.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.continu_1.index.but configure -state normal
                    #--- Pose en cours
                    set panneau(AcqFC,$visuNo,pose_en_cours) "0"
                 }
                 6  {
                    #--- Mode video
                    #--- Verouille les boutons du mode "video"
                    $panneau(AcqFC,$visuNo,This).mode.video.nom.entr configure -state disabled
                    $panneau(AcqFC,$visuNo,This).mode.video.index.case configure -state disabled
                    $panneau(AcqFC,$visuNo,This).mode.video.index.entr configure -state disabled
                    $panneau(AcqFC,$visuNo,This).mode.video.index.but configure -state disabled
                    $panneau(AcqFC,$visuNo,This).mode.video.show.case configure -state disabled
                    set heure $audace(tu,format,hmsint)
                    Message $visuNo consolog $caption(acqfc,acqvideo) \
                       $panneau(AcqFC,$visuNo,lg_film) $panneau(AcqFC,$visuNo,rate) $heure
                    set nom $panneau(AcqFC,$visuNo,nom_image)
                    #--- Pour eviter un nom de fichier qui commence par un blanc
                    set nom [lindex $nom 0]
                    if { $panneau(AcqFC,$visuNo,indexer) == "1" } {
                       set nom [append nom $panneau(AcqFC,$visuNo,index)]
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
                    #--- Je positionne la fenetre video
                    if { $panneau(AcqFC,$visuNo,fenetre) == "1" } {
                       cam[ ::confVisu::getCamNo $visuNo ] setvideocroprect $panneau(AcqFC,$visuNo,x1) \
                          $panneau(AcqFC,$visuNo,y1) $panneau(AcqFC,$visuNo,x2) $panneau(AcqFC,$visuNo,y2)
                    }
                    #--- Je declare la variable qui sera mise a jour par le driver avec le decompte des frames
                    cam[ ::confVisu::getCamNo $visuNo ] setvideostatusvariable panneau(AcqFC,$visuNo,status)
                    set result [ catch { cam[ ::confVisu::getCamNo $visuNo ] startvideocapture "$nom_rep" "$panneau(AcqFC,$visuNo,lg_film)" "$panneau(AcqFC,$visuNo,rate)" "1" } msg ]
                    if { $result == "1" } {
                       #--- En cas d'erreur, j'affiche un message d'erreur
                       #--- Et je passe a la suite sans attendre
                       ::console::affiche_resultat "$caption(acqfc,start_capture_error) $msg \n"
                    } else {
                       #--- J'attends la fin de l'acquisition
                       #--- Remarque : La commande [set $xxx] permet de recuperer le contenu d'une variable
                       set statusVariableName "::status_cam[ ::confVisu::getCamNo $visuNo ]"
                       if { [set $statusVariableName] == "exp" } {
                          vwait status_cam[ ::confVisu::getCamNo $visuNo ]
                       }
                    }
                    if { $panneau(AcqFC,$visuNo,indexer) == "1" } {
                       incr panneau(AcqFC,$visuNo,index)
                    }
                    set heure $audace(tu,format,hmsint)
                    Message $visuNo consolog $caption(acqfc,enrim_video) $heure $nom
                    #--- Deverouille les boutons du mode "video"
                    $panneau(AcqFC,$visuNo,This).mode.video.nom.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.video.index.case configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.video.index.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.video.index.but configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.video.show.case configure -state normal
                    #--- Pose en cours
                    set panneau(AcqFC,$visuNo,pose_en_cours) "0"
                 }
                 7  {
                    #--- Mode video avec intervalle entre chaque video
                    #--- Verouille les boutons du mode "video"
                    $panneau(AcqFC,$visuNo,This).mode.video_1.nom.entr configure -state disabled
                    $panneau(AcqFC,$visuNo,This).mode.video_1.index.entr configure -state disabled
                    $panneau(AcqFC,$visuNo,This).mode.video_1.index.but configure -state disabled
                    $panneau(AcqFC,$visuNo,This).mode.video_1.show.case configure -state disabled
                    set heure $audace(tu,format,hmsint)
                    Message $visuNo consolog $caption(acqfc,acqvideo_cont) $panneau(AcqFC,$visuNo,intervalle_video) \
                       $panneau(AcqFC,$visuNo,lg_film) $panneau(AcqFC,$visuNo,rate) $heure
                    while { ( $panneau(AcqFC,$visuNo,demande_arret) == "0" ) && ( $panneau(AcqFC,$visuNo,mode) == "7" ) } {
                       set panneau(AcqFC,$visuNo,deb_video) [ clock second ]
                       set nom $panneau(AcqFC,$visuNo,nom_image)
                       #--- Pour eviter un nom de fichier qui commence par un blanc
                       set nom [lindex $nom 0]
                       set nom [append nom $panneau(AcqFC,$visuNo,index)]
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
                       $panneau(AcqFC,$visuNo,This).go_stop.but configure -state normal
                       #--- Je positionne la fenetre video
                       if { $panneau(AcqFC,$visuNo,fenetre) == "1" } {
                          cam[ ::confVisu::getCamNo $visuNo ] setvideocroprect $panneau(AcqFC,$visuNo,x1) \
                             $panneau(AcqFC,$visuNo,y1) $panneau(AcqFC,$visuNo,x2) $panneau(AcqFC,$visuNo,y2)
                       }
                       #--- Je declare la variable qui sera mise a jour par le driver avec le decompte des frames
                       cam[ ::confVisu::getCamNo $visuNo ] setvideostatusvariable panneau(AcqFC,$visuNo,status)
                       set result [ catch { cam[ ::confVisu::getCamNo $visuNo ] startvideocapture "$nom_rep" "$panneau(AcqFC,$visuNo,lg_film)" "$panneau(AcqFC,$visuNo,rate)" "1" } msg ]
                       if { $result == "1" } {
                          ::console::affiche_resultat "$caption(acqfc,start_capture_error) $msg \n"
                       } else {
                          #--- J'attends la fin de l'acquisition
                          #--- Remarque : La commande [set $xxx] permet de recuperer le contenu d'une variable
                          set statusVariableName "::status_cam[ ::confVisu::getCamNo $visuNo ]"
                          if { [set $statusVariableName] == "exp" } {
                             vwait status_cam[ ::confVisu::getCamNo $visuNo ]
                          }
                          #--- Je desactive le bouton "STOP"
                          $panneau(AcqFC,$visuNo,This).go_stop.but configure -state disabled
                       }
                       incr panneau(AcqFC,$visuNo,index)
                       set heure $audace(tu,format,hmsint)
                       Message $visuNo consolog $caption(acqfc,enrim_video) $heure $nom
                       #--- Deplacement du telescope
                       ::DlgShift::Decalage_Telescope
                       set panneau(AcqFC,$visuNo,attente_pose) "1"
                       set panneau(AcqFC,$visuNo,fin_video) [ clock second ]
                       set panneau(AcqFC,$visuNo,intervalle_film) [ expr $panneau(AcqFC,$visuNo,fin_video) - $panneau(AcqFC,$visuNo,deb_video) ]
                       while { ( $panneau(AcqFC,$visuNo,demande_arret) == "0" ) && ( $panneau(AcqFC,$visuNo,intervalle_film) <= $panneau(AcqFC,$visuNo,intervalle_video) ) } {
                          after 500
                          set panneau(AcqFC,$visuNo,fin_video) [ clock second ]
                          set panneau(AcqFC,$visuNo,intervalle_film) [ expr $panneau(AcqFC,$visuNo,fin_video) - $panneau(AcqFC,$visuNo,deb_video) + 1 ]
                          set t [ expr $panneau(AcqFC,$visuNo,intervalle_video) - $panneau(AcqFC,$visuNo,intervalle_film) ]
                          ::AcqFC::Avancement_pose $visuNo $t
                       }
                       set panneau(AcqFC,$visuNo,attente_pose) "0"
                    }
                    set heure $audace(tu,format,hmsint)
                    console::affiche_saut "\n"
                    Message $visuNo consolog $caption(acqfc,arrcont) $heure
                    Message $visuNo consolog $caption(acqfc,dersauve_video) $nom
                    #--- Deverouille les boutons du mode "video"
                    $panneau(AcqFC,$visuNo,This).mode.video_1.nom.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.video_1.index.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.video_1.index.but configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.video_1.show.case configure -state normal
                    #--- Pose en cours
                    set panneau(AcqFC,$visuNo,pose_en_cours) "0"
                 }
              }
              #--- Deverouille tous les boutons et champs de texte pendant les acquisitions
              $panneau(AcqFC,$visuNo,This).pose.but configure -state normal
              $panneau(AcqFC,$visuNo,This).pose.entr configure -state normal
              $panneau(AcqFC,$visuNo,This).bin.but configure -state normal
              $panneau(AcqFC,$visuNo,This).obt.but configure -state normal
              $panneau(AcqFC,$visuNo,This).mode.but configure -state normal
              #--- Je restitue l'affichage du bouton "GO"
              set panneau(AcqFC,$visuNo,go_stop) go
              $panneau(AcqFC,$visuNo,This).go_stop.but configure -text $caption(acqfc,GO)
              #--- J'autorise le bouton "GO"
              $panneau(AcqFC,$visuNo,This).go_stop.but configure -state normal
           }
        }
        stop {
           #--- Je desactive le bouton "STOP"
           $panneau(AcqFC,$visuNo,This).go_stop.but configure -state disabled
           #--- J'arrete l'acquisition
           ArretImage $visuNo
           switch $panneau(AcqFC,$visuNo,mode) {
              1  {
                 #--- Mode une image
                    #--- Message suite a l'arret
                    set heure $audace(tu,format,hmsint)
                    if { $panneau(AcqFC,$visuNo,pose_en_cours) == "1" } {
                       console::affiche_saut "\n"
                       Message $visuNo consolog $caption(acqfc,arrprem) $heure
                       Message $visuNo consolog $caption(acqfc,lg_pose_arret) [ lindex [ buf[ ::confVisu::getBufNo $visuNo ] getkwd EXPOSURE ] 1 ]
                    }
                    #--- Deverouille les boutons du mode "une image"
                    $panneau(AcqFC,$visuNo,This).mode.une.nom.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.une.index.case configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.une.index.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.une.index.but configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.une.sauve configure -state normal
              }
              2  {
                 #--- Mode serie
                    #--- Message suite a l'arret
                    set heure $audace(tu,format,hmsint)
                    if { $panneau(AcqFC,$visuNo,pose_en_cours) == "1" } {
                       console::affiche_saut "\n"
                       Message $visuNo consolog $caption(acqfc,arrprem) $heure
                    }
                    #--- Deverouille les boutons du mode "serie"
                    $panneau(AcqFC,$visuNo,This).mode.serie.nom.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.serie.nb.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.serie.index.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.serie.index.but configure -state normal
              }
              3  {
                 #--- Mode continu
                    #--- Message suite a l'arret
                    set heure $audace(tu,format,hmsint)
                    if { $panneau(AcqFC,$visuNo,pose_en_cours) == "1" } {
                       console::affiche_saut "\n"
                       Message $visuNo consolog $caption(acqfc,arrprem) $heure
                       if { $panneau(AcqFC,$visuNo,enregistrer) == "1" } {
                          set index [ expr $panneau(AcqFC,$visuNo,index) - 1 ]
                          set nom [lindex $panneau(AcqFC,$visuNo,nom_image) 0]
                          Message $visuNo consolog $caption(acqfc,dersauve) [append nom $index]
                       } else {
                          Message $visuNo consolog $caption(acqfc,lg_pose_arret) [ lindex [ buf[ ::confVisu::getBufNo $visuNo ] getkwd EXPOSURE ] 1 ]
                       }
                    }
                    #--- Deverouille les boutons du mode "continu"
                    $panneau(AcqFC,$visuNo,This).mode.continu.sauve.case configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.continu.nom.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.continu.index.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.continu.index.but configure -state normal
              }
              4  {
                 #--- Mode series d'images en continu avec intervalle entre chaque serie
                    #--- Message suite a l'arret
                    set heure $audace(tu,format,hmsint)
                    if { $panneau(AcqFC,$visuNo,pose_en_cours) == "1" } {
                       console::affiche_saut "\n"
                       Message $visuNo consolog $caption(acqfc,arrprem) $heure
                       set i $panneau(AcqFC,$visuNo,nb_images)
                    }
                    #--- Deverouille les boutons du mode "continu 1"
                    $panneau(AcqFC,$visuNo,This).mode.serie_1.nom.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.serie_1.nb.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.serie_1.index.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.serie_1.index.but configure -state normal
              }
              5  {
                 #--- Mode continu avec intervalle entre chaque image
                    #--- Message suite a l'arret
                    set heure $audace(tu,format,hmsint)
                    if { $panneau(AcqFC,$visuNo,pose_en_cours) == "1" } {
                       console::affiche_saut "\n"
                       if { $panneau(AcqFC,$visuNo,enregistrer) == "0" } {
                          Message $visuNo consolog $caption(acqfc,lg_pose_arret) [ lindex [ buf[ ::confVisu::getBufNo $visuNo ] getkwd EXPOSURE ] 1 ]
                       }
                    }
                    #--- Deverouille les boutons du mode "continu 2"
                    $panneau(AcqFC,$visuNo,This).mode.continu_1.sauve.case configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.continu_1.nom.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.continu_1.index.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.continu_1.index.but configure -state normal
              }
              6  {
                 #--- Mode video
                    #--- Message suite a l'arret
                    set heure $audace(tu,format,hmsint)
                    if { $panneau(AcqFC,$visuNo,pose_en_cours) == "1" } {
                       console::affiche_saut "\n"
                       Message $visuNo consolog $caption(acqfc,arrprem) $heure
                    }
                    #--- Deverouille les boutons du mode "video"
                    $panneau(AcqFC,$visuNo,This).mode.video.nom.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.video.index.case configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.video.index.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.video.index.but configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.video.show.case configure -state normal
              }
              7  {
                 #--- Mode video avec intervalle entre chaque video
                    #--- Message suite a l'arret
                    set heure $audace(tu,format,hmsint)
                    if { $panneau(AcqFC,$visuNo,pose_en_cours) == "1" } {
                       console::affiche_saut "\n"
                       Message $visuNo consolog $caption(acqfc,arrprem) $heure
                    }
                    #--- Deverouille les boutons du mode "video 1"
                    $panneau(AcqFC,$visuNo,This).mode.video_1.nom.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.video_1.index.entr configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.video_1.index.but configure -state normal
                    $panneau(AcqFC,$visuNo,This).mode.video_1.show.case configure -state normal
              }
           }
           #--- Deverouille tous les boutons et champs de texte pendant les acquisitions
           $panneau(AcqFC,$visuNo,This).pose.but configure -state normal
           $panneau(AcqFC,$visuNo,This).pose.entr configure -state normal
           $panneau(AcqFC,$visuNo,This).bin.but configure -state normal
           $panneau(AcqFC,$visuNo,This).obt.but configure -state normal
           $panneau(AcqFC,$visuNo,This).mode.but configure -state normal
           #--- Je restitue l'affichage du bouton "GO"
           set panneau(AcqFC,$visuNo,go_stop) go
           $panneau(AcqFC,$visuNo,This).go_stop.but configure -text $caption(acqfc,GO)
           #--- J'autorise le bouton "GO"
           $panneau(AcqFC,$visuNo,This).go_stop.but configure -state normal
           #--- Effacement de la barre de progression quand la pose est terminee
           destroy $panneau(AcqFC,$visuNo,base).progress
           #--- Affichage du status
           $panneau(AcqFC,$visuNo,This).status.lab configure -text ""
           update
           #--- Pose en cours
           set panneau(AcqFC,$visuNo,pose_en_cours) "0"
        }
      }
   }
#***** Fin de la procedure Go/Stop *****************************

#***** Procedure de lancement d'acquisition ********************
   proc acq { visuNo exptime binning } {
      global audace caption conf panneau

      #--- Petits raccourcis
      set camNo     [ ::confVisu::getCamNo $visuNo ]
      set buffer buf[ ::confVisu::getBufNo $visuNo ]

      #--- Affichage du status
      $panneau(AcqFC,$visuNo,This).status.lab configure -text $caption(acqfc,raz)
      update

      #--- Si je fais un offset (pose de 0s) alors l'obturateur reste ferme
      if { $exptime == "0" } {
         cam$camNo shutter "closed"
      }

      #--- Cas des petites poses : Force l'affichage de l'avancement de la pose avec le statut Lecture du CCD
      if { $exptime >= "0" && $exptime < "2" } {
         ::AcqFC::Avancement_pose $visuNo "1"
      }

      #--- Initialisation du fenetrage
      catch {
         set n1n2 [ cam$camNo nbcells ]
         cam$camNo window [ list 1 1 [ lindex $n1n2 0 ] [ lindex $n1n2 1 ] ]
      }

      #--- La commande exptime permet de fixer le temps de pose de l'image
      cam$camNo exptime $exptime

      if { [::confCam::getPluginProperty $panneau(AcqFC,$visuNo,camItem) hasBinning] == "1" } {
         #--- je selectionne le binning
         cam$camNo bin [list [string range $binning 0 0] [string range $binning 2 2]]
      }

      if { [::confCam::getPluginProperty $panneau(AcqFC,$visuNo,camItem) hasFormat] == "1" } {
         #--- je selectionne la qualite
         cam$camNo quality $binning
      }

      if { $exptime <= "1" } {
         $panneau(AcqFC,$visuNo,This).status.lab configure -text $caption(acqfc,lect)
         update
      }
      #--- J'autorise le bouton "STOP"
      $panneau(AcqFC,$visuNo,This).go_stop.but configure -state normal
      #--- Declenchement l'acquisition
      set result [catch { cam$camNo acq } msg ]
      if { $result == 0 } {
         #--- Alarme sonore de fin de pose
         ::camera::alarme_sonore $exptime
         #--- Appel du timer
         if { $exptime >= "2" } {
            ::camera::dispTime_2 cam$camNo $panneau(AcqFC,$visuNo,This).status.lab "::AcqFC::Avancement_pose" $visuNo
         }
         #--- Chargement de l'image precedente (si telecharge_mode = 3 et si mode = serie, continu, continu 1 ou continu 2)
         if { $conf(dslr,telecharge_mode) == "3" && $panneau(AcqFC,$visuNo,mode) >= "1" && $panneau(AcqFC,$visuNo,mode) <= "5" } {
            after 10 ::AcqFC::loadLastImage $visuNo $camNo
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
         switch -exact -- $panneau(AcqFC,$visuNo,obt) {
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
      $panneau(AcqFC,$visuNo,This).go_stop.but configure -state disabled

      #--- Affichage du status
      $panneau(AcqFC,$visuNo,This).status.lab configure -text ""
      update

      #--- Visualisation de l'image si on n'est pas en chargement differe
      if { $conf(dslr,telecharge_mode) != "3" || [ cam$camNo product ] != "dslr" } {
         if { $conf(dslr,telecharge_mode) == "1" && [ cam$camNo product ] == "dslr" } {
            #-- raz du buffer si le telechargement est desactive
            $buffer clear
         }
         ::audace::autovisu $visuNo
      }

      #--- Effacement de la barre de progression quand la pose est terminee
      destroy $panneau(AcqFC,$visuNo,base).progress

      wm title $panneau(AcqFC,$visuNo,base) "$caption(acqfc,acquisition) $exptime s"
   }
#***** Fin de la procedure de lancement d'acquisition **********

#***** Procedure chargement differe d'image pour APN (DSLR) ****
   proc loadLastImage { visuNo camNo } {
      set result [ catch { cam$camNo loadlastimage } msg ]
      if { $result == "1" } {
         ::console::disp "::AcqFC::acq loadlastimage camNo$camNo error=$msg \n"
      } else {
         ::console::disp "::AcqFC::acq loadlastimage visuNo$visuNo OK \n"
         ::confVisu::autovisu $visuNo
      }
   }
#***** Fin de la procedure chargement differe d'image **********

#***** Procedure d'apercu en mode video ************************
   proc changerVideoPreview { visuNo } {
      global panneau

      if { $panneau(AcqFC,$visuNo,showvideopreview) == 1 } {
         ::AcqFC::startVideoPreview $visuNo
      } else {
         ::AcqFC::stopVideoPreview $visuNo
      }
   }

#***** Demarre le mode video************************
# retourne 0 si OK, 1 si erreur
   proc startVideoPreview { visuNo } {
      global audace caption conf panneau

      if { [ ::confVisu::getCamera $visuNo ] == "" } {
         ::confCam::run
         tkwait window $audace(base).confCam
         #--- Je decoche la checkbox
         set panneau(AcqFC,$visuNo,showvideopreview) "0"
         #--- Je decoche le fenetrage
         if { $panneau(AcqFC,$visuNo,fenetre) == "1" } {
            set panneau(AcqFC,$visuNo,fenetre) "0"
            ::AcqFC::optionWindowedFenster $visuNo
         }
         #---
         return 1
      } elseif { [ ::confVisu::getProduct $visuNo ] != "webcam" } {
         tk_messageBox -title $caption(acqfc,pb) -type ok \
            -message $caption(acqfc,no_video_mode)
         #--- Je decoche la checkbox
         set panneau(AcqFC,$visuNo,showvideopreview) "0"
         #--- Je decoche le fenetrage
         if { $panneau(AcqFC,$visuNo,fenetre) == "1" } {
            set panneau(AcqFC,$visuNo,fenetre) "0"
            ::AcqFC::optionWindowedFenster $visuNo
         }
         #---
         return 1
      }

      #--- Je connecte la sortie de la camera a l'image
      set result [::confVisu::setVideo $visuNo 1 ]
      if { $result == "1" } {
        #--- Je decoche la checkbox
        set panneau(AcqFC,$visuNo,showvideopreview) "0"
        #--- Je decoche le fenetrage
        if { $panneau(AcqFC,$visuNo,fenetre) == "1" } {
           set panneau(AcqFC,$visuNo,fenetre) "0"
           ::AcqFC::optionWindowedFenster $visuNo
        }
        #---
        return 1
      }

      set panneau(AcqFC,$visuNo,showvideopreview) "1"
      return 0
   }
#***** Fin de la procedure d'apercu en mode video ******************

#***** Procedure fin d'apercu en mode video ************************
   proc stopVideoPreview { visuNo } {
      global audace conf panneau

      #--- J'arrete l'aquisition fenetree si elle est active
      if { $panneau(AcqFC,$visuNo,fenetre) == "1" } {
         ::AcqFC::stopWindowedFenster $visuNo
         set panneau(AcqFC,$visuNo,fenetre) "0"
         ::AcqFC::optionWindowedFenster $visuNo
      }
      #---
      set camNo [ ::confVisu::getCamNo $visuNo ]
      if { [ ::confCam::getPluginProperty [ ::confVisu::getCamItem $visuNo ] hasVideo ] == "1" } {
         #--- Arret de la visualisation video
         cam$camNo stopvideoview
         ::confVisu::setVideo $visuNo 0
         set panneau(AcqFC,$visuNo,showvideopreview) "0"
      }
   }
#***** Fin de la procedure fin d'apercu en mode video **************

#***** Procedure d'affichage d'une barre de progression ********
#--- Cette routine permet d'afficher une barre de progression qui simule l'avancement de la pose
   proc Avancement_pose { visuNo { t } } {
      global audace caption color conf panneau

      if { $panneau(AcqFC,$visuNo,avancement_acq) == "1" } {
         #--- Recuperation de la position de la fenetre
         ::AcqFC::recup_position_1 $visuNo

         #--- Initialisation de la barre de progression
         set cpt "100"

         #---
         if { [ winfo exists $panneau(AcqFC,$visuNo,base).progress ] != "1" } {
            toplevel $panneau(AcqFC,$visuNo,base).progress
            wm transient $panneau(AcqFC,$visuNo,base).progress $panneau(AcqFC,$visuNo,base)
            wm resizable $panneau(AcqFC,$visuNo,base).progress 0 0
            wm title $panneau(AcqFC,$visuNo,base).progress "$caption(acqfc,en_cours)"
            wm geometry $panneau(AcqFC,$visuNo,base).progress $panneau(AcqFC,$visuNo,avancement,position)

            #--- Cree le widget et le label du temps ecoule
            label $panneau(AcqFC,$visuNo,base).progress.lab_status -text "" -font $audace(font,arial_12_b) -justify center
            pack $panneau(AcqFC,$visuNo,base).progress.lab_status -side top -fill x -expand true -pady 5

            #---
            if { $panneau(AcqFC,$visuNo,attente_pose) == "0" } {
               if { $panneau(AcqFC,$visuNo,demande_arret) == "1" && $panneau(AcqFC,$visuNo,mode) != "2" && $panneau(AcqFC,$visuNo,mode) != "4" } {
                  $panneau(AcqFC,$visuNo,base).progress.lab_status configure -text $caption(acqfc,lect)
               } else {
                  if { $t <= "0" } {
                     destroy $panneau(AcqFC,$visuNo,base).progress
                  } elseif { $t > "1" } {
                     $panneau(AcqFC,$visuNo,base).progress.lab_status configure -text "[ expr $t-1 ] $caption(acqfc,sec) /\
                        [ format "%d" [ expr int( [ cam[ ::confVisu::getCamNo $visuNo ] exptime ] ) ] ] $caption(acqfc,sec)"
                     set cpt [ expr ( $t-1 ) * 100 / [ expr int( [ cam[ ::confVisu::getCamNo $visuNo ] exptime ] ) ] ]
                     set cpt [ expr 100 - $cpt ]
                  } else {
                     $panneau(AcqFC,$visuNo,base).progress.lab_status configure -text "$caption(acqfc,lect)"
                 }
               }
            } else {
               if { $panneau(AcqFC,$visuNo,demande_arret) == "0" } {
                  if { $t < "0" } {
                     destroy $panneau(AcqFC,$visuNo,base).progress
                  } else {
                     if { $panneau(AcqFC,$visuNo,mode) == "4" } {
                        $panneau(AcqFC,$visuNo,base).progress.lab_status configure -text "$caption(acqfc,attente) [ expr $t + 1 ]\
                           $caption(acqfc,sec) / $panneau(AcqFC,$visuNo,intervalle_1) $caption(acqfc,sec)"
                        set cpt [expr $t*100 / $panneau(AcqFC,$visuNo,intervalle_1) ]
                     } elseif { $panneau(AcqFC,$visuNo,mode) == "5" } {
                        $panneau(AcqFC,$visuNo,base).progress.lab_status configure -text "$caption(acqfc,attente) [ expr $t + 1 ]\
                           $caption(acqfc,sec) / $panneau(AcqFC,$visuNo,intervalle_2) $caption(acqfc,sec)"
                        set cpt [expr $t*100 / $panneau(AcqFC,$visuNo,intervalle_2) ]
                     } elseif { $panneau(AcqFC,$visuNo,mode) == "7" } {
                        $panneau(AcqFC,$visuNo,base).progress.lab_status configure -text "$caption(acqfc,attente) [ expr $t + 1 ]\
                           $caption(acqfc,sec) / $panneau(AcqFC,$visuNo,intervalle_video) $caption(acqfc,sec)"
                        set cpt [expr $t*100 / $panneau(AcqFC,$visuNo,intervalle_video) ]
                     }
                     set cpt [expr 100 - $cpt]
                  }
               }
            }

            catch {
               #--- Cree le widget pour la barre de progression
               frame $panneau(AcqFC,$visuNo,base).progress.cadre -width 200 -height 30 -borderwidth 2 -relief groove
               pack $panneau(AcqFC,$visuNo,base).progress.cadre -in $panneau(AcqFC,$visuNo,base).progress -side top \
                  -anchor center -fill x -expand true -padx 8 -pady 8

               #--- Affiche de la barre de progression
               frame $panneau(AcqFC,$visuNo,base).progress.cadre.barre_color_invariant -height 26 -bg $color(blue)
               place $panneau(AcqFC,$visuNo,base).progress.cadre.barre_color_invariant -in $panneau(AcqFC,$visuNo,base).progress.cadre -x 0 -y 0 \
                  -relwidth [ expr $cpt / 100.0 ]
               update
            }
         } else {
            #---
            if { $panneau(AcqFC,$visuNo,attente_pose) == "0" } {
               if { $panneau(AcqFC,$visuNo,demande_arret) == "1" && $panneau(AcqFC,$visuNo,mode) != "2" && $panneau(AcqFC,$visuNo,mode) != "4" } {
                  $panneau(AcqFC,$visuNo,base).progress.lab_status configure -text $caption(acqfc,lect)
               } else {
                  if { $t <= "0" } {
                     destroy $panneau(AcqFC,$visuNo,base).progress
                  } elseif { $t > "1" } {
                     $panneau(AcqFC,$visuNo,base).progress.lab_status configure -text "[ expr $t-1 ] $caption(acqfc,sec) /\
                        [ format "%d" [ expr int( [ cam[ ::confVisu::getCamNo $visuNo ] exptime ] ) ] ] $caption(acqfc,sec)"
                     set cpt [ expr ( $t-1 ) * 100 / [ expr int( [ cam[ ::confVisu::getCamNo $visuNo ] exptime ] ) ] ]
                     set cpt [ expr 100 - $cpt ]
                  } else {
                     $panneau(AcqFC,$visuNo,base).progress.lab_status configure -text "$caption(acqfc,lect)"
                  }
               }
            } else {
               if { $panneau(AcqFC,$visuNo,demande_arret) == "0" } {
                  if { $t < "0" } {
                     destroy $panneau(AcqFC,$visuNo,base).progress
                  } else {
                     if { $panneau(AcqFC,$visuNo,mode) == "4" } {
                        $panneau(AcqFC,$visuNo,base).progress.lab_status configure -text "$caption(acqfc,attente) [ expr $t + 1 ]\
                           $caption(acqfc,sec) / $panneau(AcqFC,$visuNo,intervalle_1) $caption(acqfc,sec)"
                        set cpt [expr $t*100 / $panneau(AcqFC,$visuNo,intervalle_1) ]
                     } elseif { $panneau(AcqFC,$visuNo,mode) == "5" } {
                        $panneau(AcqFC,$visuNo,base).progress.lab_status configure -text "$caption(acqfc,attente) [ expr $t + 1 ]\
                           $caption(acqfc,sec) / $panneau(AcqFC,$visuNo,intervalle_2) $caption(acqfc,sec)"
                        set cpt [expr $t*100 / $panneau(AcqFC,$visuNo,intervalle_2) ]
                     } elseif { $panneau(AcqFC,$visuNo,mode) == "7" } {
                        $panneau(AcqFC,$visuNo,base).progress.lab_status configure -text "$caption(acqfc,attente) [ expr $t + 1 ]\
                           $caption(acqfc,sec) / $panneau(AcqFC,$visuNo,intervalle_video) $caption(acqfc,sec)"
                        set cpt [expr $t*100 / $panneau(AcqFC,$visuNo,intervalle_video) ]
                     }
                     set cpt [expr 100 - $cpt]
                  }
               }
            }

            catch {
               #--- Affiche de la barre de progression
               place $panneau(AcqFC,$visuNo,base).progress.cadre.barre_color_invariant -in $panneau(AcqFC,$visuNo,base).progress.cadre -x 0 -y 0 \
                  -relwidth [ expr $cpt / 100.0 ]
               update
            }
         }

         #--- Mise a jour dynamique des couleurs
         if [ winfo exists $panneau(AcqFC,$visuNo,base).progress ] {
            ::confColor::applyColor $panneau(AcqFC,$visuNo,base).progress
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
      set panneau(AcqFC,$visuNo,demande_arret) "1"
      #--- Force la numerisation pour l'indicateur d'avancement de la pose
      if { ( $panneau(AcqFC,$visuNo,mode) != "2" ) && ( $panneau(AcqFC,$visuNo,mode) != "4" ) && ( $panneau(AcqFC,$visuNo,mode) != "6" ) && \
         ( $panneau(AcqFC,$visuNo,mode) != "7" ) } {
         ::AcqFC::Avancement_pose $visuNo "1"
      }

      #--- On annule la sonnerie
      catch { after cancel $audace(after,bell,id) }
      #--- Annulation de l'alarme de fin de pose
      catch { after cancel bell }

      #--- Arret de la pose (image et video)
      if { ( $panneau(AcqFC,$visuNo,mode) == "1" )
         || ( $panneau(AcqFC,$visuNo,mode) == "3" )
         || ( $panneau(AcqFC,$visuNo,mode) == "5" ) } {
         #--- J'arrete la capture de l'image
         catch { cam[ ::confVisu::getCamNo $visuNo ] stop }
         after 200
      } elseif { ( $panneau(AcqFC,$visuNo,mode) == "6" )
         || ( $panneau(AcqFC,$visuNo,mode) == "7" ) } {
         #--- J'arrete la capture de la video
         catch { cam[ ::confVisu::getCamNo $visuNo ] stopvideocapture }
         #--- Je positionne la fenetre video
         if { $panneau(AcqFC,$visuNo,fenetre) == "1" } {
            cam[ ::confVisu::getCamNo $visuNo ] setvideocroprect $panneau(AcqFC,$visuNo,x1) \
               $panneau(AcqFC,$visuNo,y1) $panneau(AcqFC,$visuNo,x2) $panneau(AcqFC,$visuNo,y2)
         }
      }
   }
#***** Fin de la procedure d'arret de l'acquisition ************

#***** Procedure de sauvegarde de l'image **********************
#--- Procedure lancee par appui sur le bouton "enregistrer", uniquement dans le mode "Une image"
   proc SauveUneImage { visuNo } {
      global audace caption panneau

      #--- Recopie de l'extension des fichiers image
      set ext $panneau(AcqFC,$visuNo,extension)

      #--- Tests d'integrite de la requete

      #--- Verifier qu'il y a bien un nom de fichier
      if { $panneau(AcqFC,$visuNo,nom_image) == "" } {
         tk_messageBox -title $caption(acqfc,pb) -type ok \
            -message $caption(acqfc,donnomfich)
         return
      }
      #--- Verifier que le nom de fichier n'a pas d'espace
      if { [ llength $panneau(AcqFC,$visuNo,nom_image) ] > "1" } {
         tk_messageBox -title $caption(acqfc,pb) -type ok \
            -message $caption(acqfc,nomblanc)
         return
      }
      #--- Verifier que le nom de fichier ne contient pas de caracteres interdits
      if { [ AcqFC::TestChaine $panneau(AcqFC,$visuNo,nom_image) ] == "0" } {
         tk_messageBox -title $caption(acqfc,pb) -type ok \
            -message $caption(acqfc,mauvcar)
         return
      }
      #--- Si la case index est cochee, verifier qu'il y a bien un index
      if { $panneau(AcqFC,$visuNo,indexer) == "1" } {
         #--- Verifier que l'index existe
         if { $panneau(AcqFC,$visuNo,index) == "" } {
            tk_messageBox -title $caption(acqfc,pb) -type ok \
               -message $caption(acqfc,saisind)
            return
         }
         #--- Verifier que l'index est bien un nombre entier
         if { [ AcqFC::TestEntier $panneau(AcqFC,$visuNo,index) ] == "0" } {
            tk_messageBox -title $caption(acqfc,pb) -type ok \
               -message $caption(acqfc,indinv)
            return
         }
      }

      #--- Afficher le status
      $panneau(AcqFC,$visuNo,This).status.lab configure -text $caption(acqfc,enreg)
      update

      #--- Generer le nom du fichier
      set nom $panneau(AcqFC,$visuNo,nom_image)
      #--- Pour eviter un nom de fichier qui commence par un blanc
      set nom [lindex $nom 0]
      if { $panneau(AcqFC,$visuNo,indexer) == "1" } {
         append nom $panneau(AcqFC,$visuNo,index)
      }

      #--- Verifier que le nom du fichier n'existe pas deja
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
      if { $panneau(AcqFC,$visuNo,indexer) == "1" } {
         if { [ buf$bufNo imageready ] != "0" } {
            incr panneau(AcqFC,$visuNo,index)
         } else {
            #--- Effacer le status
            $panneau(AcqFC,$visuNo,This).status.lab configure -text ""
            #--- Sortir immediatement s'il n'y a pas d'image dans le buffer
            return
         }
      } else {
         if { [ buf$bufNo imageready ] == "0" } {
            #--- Effacer le status
            $panneau(AcqFC,$visuNo,This).status.lab configure -text ""
            #--- Sortir immediatement s'il n'y a pas d'image dans le buffer
            return
         }
      }

      #--- Indiquer l'enregistrement dans le fichier log
      set heure $audace(tu,format,hmsint)
      Message $visuNo consolog $caption(acqfc,demsauv) $heure
      Message $visuNo consolog $caption(acqfc,imsauvnom) $nom $ext

      #--- Sauvegarder l'image
      saveima $nom$panneau(AcqFC,$visuNo,extension) $visuNo

      #--- Effacer le status
      $panneau(AcqFC,$visuNo,This).status.lab configure -text ""
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
                puts -nonewline $::AcqFC::log_id [eval [concat {format} $args]]
                #--- Force l'ecriture immediate sur le disque
                flush $::AcqFC::log_id
             }
         }
         consolog {
            if { $panneau(AcqFC,$visuNo,messages) == "1" } {
               ::console::disp [eval [concat {format} $args]]
               update idletasks
            }
            set temps [clock format [clock seconds] -format %H:%M:%S]
            append temps " "
            catch {
                puts -nonewline $::AcqFC::log_id [eval [concat {format} $args]]
                #--- Force l'ecriture immediate sur le disque
                flush $::AcqFC::log_id
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

      set panneau(AcqFC,$visuNo,intervalle)            "....."
      set panneau(AcqFC,$visuNo,simulation_deja_faite) "0"

      ::AcqFC::recup_position $visuNo

      #--- Initialisation de la position de la fenetre
      if { ! [ info exists conf(acqfc,continu1,position) ] } { set conf(acqfc,continu1,position) "+120+260" }

      #--- Creation de la fenetre Continu 1
      toplevel $panneau(AcqFC,$visuNo,base).intervalle_continu_1
      wm transient $panneau(AcqFC,$visuNo,base).intervalle_continu_1 $panneau(AcqFC,$visuNo,base)
      wm resizable $panneau(AcqFC,$visuNo,base).intervalle_continu_1 0 0
      wm title $panneau(AcqFC,$visuNo,base).intervalle_continu_1 "$caption(acqfc,continu_1)"
      wm geometry $panneau(AcqFC,$visuNo,base).intervalle_continu_1 $conf(acqfc,continu1,position)
      wm protocol $panneau(AcqFC,$visuNo,base).intervalle_continu_1 WM_DELETE_WINDOW " \
         set panneau(AcqFC,$visuNo,mode_en_cours) \"$caption(acqfc,continu)\" ; \
         ::AcqFC::ChangeMode $visuNo \
      "

      #--- Create the message
      label $panneau(AcqFC,$visuNo,base).intervalle_continu_1.lab1 -text "$caption(acqfc,titre_1)" -font $audace(font,arial_10_b)
      pack $panneau(AcqFC,$visuNo,base).intervalle_continu_1.lab1 -padx 20 -pady 5
      frame $panneau(AcqFC,$visuNo,base).intervalle_continu_1.a
         label $panneau(AcqFC,$visuNo,base).intervalle_continu_1.a.lab2 -text "$caption(acqfc,intervalle_1)"
         pack $panneau(AcqFC,$visuNo,base).intervalle_continu_1.a.lab2 -anchor center -expand 1 -fill none -side left \
            -padx 10 -pady 5
         entry $panneau(AcqFC,$visuNo,base).intervalle_continu_1.a.ent1 -width 5 -font $audace(font,arial_10_b) -relief groove \
            -textvariable panneau(AcqFC,$visuNo,intervalle_1) -justify center
         pack $panneau(AcqFC,$visuNo,base).intervalle_continu_1.a.ent1 -anchor center -expand 1 -fill none -side left \
            -padx 10
      pack $panneau(AcqFC,$visuNo,base).intervalle_continu_1.a -padx 10 -pady 5
      frame $panneau(AcqFC,$visuNo,base).intervalle_continu_1.b
         checkbutton $panneau(AcqFC,$visuNo,base).intervalle_continu_1.b.check_simu \
            -text "$caption(acqfc,simu_deja_faite)" \
            -variable panneau(AcqFC,$visuNo,simulation_deja_faite) -command "::AcqFC::Simu_deja_faite_1 $visuNo"
        pack $panneau(AcqFC,$visuNo,base).intervalle_continu_1.b.check_simu -anchor w -expand 1 -fill none \
           -side left -padx 10 -pady 5
      pack $panneau(AcqFC,$visuNo,base).intervalle_continu_1.b -side bottom -anchor w -padx 10 -pady 5
      button $panneau(AcqFC,$visuNo,base).intervalle_continu_1.but1 -text "$caption(acqfc,simulation)" \
         -command "::AcqFC::Command_continu_1 $visuNo"
      pack $panneau(AcqFC,$visuNo,base).intervalle_continu_1.but1 -anchor center -expand 1 -fill none -side left \
         -ipadx 5 -ipady 3 -padx 10 -pady 5
      set simu1 "$caption(acqfc,int_mini_serie) $panneau(AcqFC,$visuNo,intervalle) $caption(acqfc,sec)"
      label $panneau(AcqFC,$visuNo,base).intervalle_continu_1.lab3 -text "$simu1"
      pack $panneau(AcqFC,$visuNo,base).intervalle_continu_1.lab3 -anchor center -expand 1 -fill none -side left -padx 10

      #--- New message window is on
      focus $panneau(AcqFC,$visuNo,base).intervalle_continu_1

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $panneau(AcqFC,$visuNo,base).intervalle_continu_1
   }
#***** Fin fenetre de configuration series d'images a intervalle regulier en continu *****

#***** Commande associee au bouton simulation de la fenetre Continu (1) ******************
   proc Command_continu_1 { visuNo } {
      global caption panneau

      set panneau(AcqFC,$visuNo,intervalle) "....."
      set simu1 "$caption(acqfc,int_mini_serie) $panneau(AcqFC,$visuNo,intervalle) $caption(acqfc,sec)"
      $panneau(AcqFC,$visuNo,base).intervalle_continu_1.lab3 configure -text "$simu1"
      set panneau(AcqFC,$visuNo,simulation) "1" ; set panneau(AcqFC,$visuNo,mode) "2"
      set index $panneau(AcqFC,$visuNo,index) ; set nombre $panneau(AcqFC,$visuNo,nb_images)
      ::AcqFC::GoStop $visuNo
      set panneau(AcqFC,$visuNo,simulation) "0" ; set panneau(AcqFC,$visuNo,mode) "4"
      set panneau(AcqFC,$visuNo,index) $index ; set panneau(AcqFC,$visuNo,nb_images) $nombre
      set simu1 "$caption(acqfc,int_mini_serie) $panneau(AcqFC,$visuNo,intervalle) $caption(acqfc,sec)"
      $panneau(AcqFC,$visuNo,base).intervalle_continu_1.lab3 configure -text "$simu1"
   }
#***** Fin de la commande associee au bouton simulation de la fenetre Continu (1) ********

#***** Si une simulation a deja ete faite pour la fenetre Continu (1) ********************
   proc Simu_deja_faite_1 { visuNo } {
      global caption panneau

      if { $panneau(AcqFC,$visuNo,simulation_deja_faite) == "1" } {
         set panneau(AcqFC,$visuNo,intervalle) "xxx"
         $panneau(AcqFC,$visuNo,base).intervalle_continu_1.lab3 configure \
            -text "$caption(acqfc,int_mini_serie) $panneau(AcqFC,$visuNo,intervalle) $caption(acqfc,sec)"
         focus $panneau(AcqFC,$visuNo,base).intervalle_continu_1.a.ent1
      } else {
         set panneau(AcqFC,$visuNo,intervalle) "....."
         $panneau(AcqFC,$visuNo,base).intervalle_continu_1.lab3 configure \
            -text "$caption(acqfc,int_mini_serie) $panneau(AcqFC,$visuNo,intervalle) $caption(acqfc,sec)"
         focus $panneau(AcqFC,$visuNo,base).intervalle_continu_1.but1
      }
   }
#***** Fin de si une simulation a deja ete faite pour la fenetre Continu (1) ********

#***** Fenetre de configuration images a intervalle regulier en continu ******************
   proc Intervalle_continu_2 { visuNo } {
      global audace caption conf panneau

      set panneau(AcqFC,$visuNo,intervalle)            "....."
      set panneau(AcqFC,$visuNo,simulation_deja_faite) "0"

      ::AcqFC::recup_position $visuNo

      #--- Initialisation de la position de la fenetre
      if { ! [ info exists conf(acqfc,continu2,position) ] } { set conf(acqfc,continu2,position) "+120+260" }

      #--- Creation de la fenetre Continu 2
      toplevel $panneau(AcqFC,$visuNo,base).intervalle_continu_2
      wm transient $panneau(AcqFC,$visuNo,base).intervalle_continu_2 $panneau(AcqFC,$visuNo,base)
      wm resizable $panneau(AcqFC,$visuNo,base).intervalle_continu_2 0 0
      wm title $panneau(AcqFC,$visuNo,base).intervalle_continu_2 "$caption(acqfc,continu_2)"
      wm geometry $panneau(AcqFC,$visuNo,base).intervalle_continu_2 $conf(acqfc,continu2,position)
      wm protocol $panneau(AcqFC,$visuNo,base).intervalle_continu_2 WM_DELETE_WINDOW " \
         set panneau(AcqFC,$visuNo,mode_en_cours) \"$caption(acqfc,continu)\" ; \
         ::AcqFC::ChangeMode $visuNo \
      "

      #--- Create the message
      label $panneau(AcqFC,$visuNo,base).intervalle_continu_2.lab1 -text "$caption(acqfc,titre_2)" -font $audace(font,arial_10_b)
      pack $panneau(AcqFC,$visuNo,base).intervalle_continu_2.lab1 -padx 10 -pady 5
      frame $panneau(AcqFC,$visuNo,base).intervalle_continu_2.a
         label $panneau(AcqFC,$visuNo,base).intervalle_continu_2.a.lab2 -text "$caption(acqfc,intervalle_2)"
         pack $panneau(AcqFC,$visuNo,base).intervalle_continu_2.a.lab2 -anchor center -expand 1 -fill none -side left \
            -padx 10 -pady 5
         entry $panneau(AcqFC,$visuNo,base).intervalle_continu_2.a.ent1 -width 5 -font $audace(font,arial_10_b) -relief groove \
            -textvariable panneau(AcqFC,$visuNo,intervalle_2) -justify center
         pack $panneau(AcqFC,$visuNo,base).intervalle_continu_2.a.ent1 -anchor center -expand 1 -fill none -side left \
            -padx 10
      pack $panneau(AcqFC,$visuNo,base).intervalle_continu_2.a -padx 10 -pady 5
      frame $panneau(AcqFC,$visuNo,base).intervalle_continu_2.b
         checkbutton $panneau(AcqFC,$visuNo,base).intervalle_continu_2.b.check_simu \
            -text "$caption(acqfc,simu_deja_faite)" \
            -variable panneau(AcqFC,$visuNo,simulation_deja_faite) -command "::AcqFC::Simu_deja_faite_2 $visuNo"
         pack $panneau(AcqFC,$visuNo,base).intervalle_continu_2.b.check_simu -anchor w -expand 1 -fill none \
            -side left -padx 10 -pady 5
      pack $panneau(AcqFC,$visuNo,base).intervalle_continu_2.b -side bottom -anchor w -padx 10 -pady 5
      button $panneau(AcqFC,$visuNo,base).intervalle_continu_2.but1 -text "$caption(acqfc,simulation)" \
         -command "::AcqFC::Command_continu_2 $visuNo"
      pack $panneau(AcqFC,$visuNo,base).intervalle_continu_2.but1 -anchor center -expand 1 -fill none -side left \
         -ipadx 5 -ipady 3 -padx 10 -pady 5
      set simu2 "$caption(acqfc,int_mini_image) $panneau(AcqFC,$visuNo,intervalle) $caption(acqfc,sec)"
      label $panneau(AcqFC,$visuNo,base).intervalle_continu_2.lab3 -text "$simu2"
      pack $panneau(AcqFC,$visuNo,base).intervalle_continu_2.lab3 -anchor center -expand 1 -fill none -side left -padx 10

      #--- New message window is on
      focus $panneau(AcqFC,$visuNo,base).intervalle_continu_2

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $panneau(AcqFC,$visuNo,base).intervalle_continu_2
   }
#***** Fin fenetre de configuration images a intervalle regulier en continu **************

#***** Commande associee au bouton simulation de la fenetre Continu (2) ******************
   proc Command_continu_2 { visuNo } {
      global caption panneau

      set panneau(AcqFC,$visuNo,intervalle) "....."
      set simu2 "$caption(acqfc,int_mini_image) $panneau(AcqFC,$visuNo,intervalle) $caption(acqfc,sec)"
      $panneau(AcqFC,$visuNo,base).intervalle_continu_2.lab3 configure -text "$simu2"
      set panneau(AcqFC,$visuNo,simulation) "1" ; set panneau(AcqFC,$visuNo,mode) "2"
      set index $panneau(AcqFC,$visuNo,index)
      set panneau(AcqFC,$visuNo,nb_images) "1"
      ::AcqFC::GoStop $visuNo
      set panneau(AcqFC,$visuNo,simulation) "0" ; set panneau(AcqFC,$visuNo,mode) "5"
      set panneau(AcqFC,$visuNo,index) $index
      set simu2 "$caption(acqfc,int_mini_image) $panneau(AcqFC,$visuNo,intervalle) $caption(acqfc,sec)"
      $panneau(AcqFC,$visuNo,base).intervalle_continu_2.lab3 configure -text "$simu2"
   }
#***** Fin de la commande associee au bouton simulation de la fenetre Continu (2) ********

#***** Si une simulation a deja ete faite pour la fenetre Continu (2) ********************
   proc Simu_deja_faite_2 { visuNo } {
      global caption panneau

      if { $panneau(AcqFC,$visuNo,simulation_deja_faite) == "1" } {
         set panneau(AcqFC,$visuNo,intervalle) "xxx" ; \
         $panneau(AcqFC,$visuNo,base).intervalle_continu_2.lab3 configure \
            -text "$caption(acqfc,int_mini_image) $panneau(AcqFC,$visuNo,intervalle) $caption(acqfc,sec)"
         focus $panneau(AcqFC,$visuNo,base).intervalle_continu_2.a.ent1
      } else {
         set panneau(AcqFC,$visuNo,intervalle) "....."
         $panneau(AcqFC,$visuNo,base).intervalle_continu_2.lab3 configure \
            -text "$caption(acqfc,int_mini_image) $panneau(AcqFC,$visuNo,intervalle) $caption(acqfc,sec)"
         focus $panneau(AcqFC,$visuNo,base).intervalle_continu_2.but1
      }
   }
#***** Fin de si une simulation a deja ete faite pour la fenetre Continu (2) ********

#***** Fenetre de configuration video ****************************************************
   proc selectVideoMode { visuNo } {
      global audace caption conf panneau

      ::AcqFC::recup_position $visuNo

      #--- Initialisation de la position de la fenetre
      if { ! [ info exists conf(acqfc,video,position) ] } { set conf(acqfc,video,position) "+120+260" }

      #--- Creation de la fenetre Video
      toplevel $panneau(AcqFC,$visuNo,base).status_video
      wm transient $panneau(AcqFC,$visuNo,base).status_video $panneau(AcqFC,$visuNo,base)
      wm resizable $panneau(AcqFC,$visuNo,base).status_video 1 1
      wm title $panneau(AcqFC,$visuNo,base).status_video "$caption(acqfc,capture_video)"
      wm geometry $panneau(AcqFC,$visuNo,base).status_video $conf(acqfc,video,position)
      wm protocol $panneau(AcqFC,$visuNo,base).status_video WM_DELETE_WINDOW " \
         if { $panneau(AcqFC,$visuNo,mode) == \"7\" } { \
            set panneau(AcqFC,$visuNo,mode_en_cours) \"$caption(acqfc,video)\" ; \
            ::AcqFC::ChangeMode $visuNo \
         } elseif { $panneau(AcqFC,$visuNo,mode) == \"6\" } { \
            set panneau(AcqFC,$visuNo,mode_en_cours) \"$caption(acqfc,uneimage)\" ; \
            ::AcqFC::ChangeMode $visuNo \
         } \
      "

      #--- Trame de l'intervalle entre les video
      if { $panneau(AcqFC,$visuNo,mode) == "7" } {
         label $panneau(AcqFC,$visuNo,base).status_video.lab1 -text "$caption(acqfc,titre_3)" -font $audace(font,arial_10_b)
         pack $panneau(AcqFC,$visuNo,base).status_video.lab1 -padx 10 -pady 5
         frame $panneau(AcqFC,$visuNo,base).status_video.a
            label $panneau(AcqFC,$visuNo,base).status_video.a.lab2 -text "$caption(acqfc,intervalle_video)"
            pack $panneau(AcqFC,$visuNo,base).status_video.a.lab2 -anchor center -expand 1 -fill none -side left \
               -padx 10 -pady 5
            entry $panneau(AcqFC,$visuNo,base).status_video.a.ent1 -width 5 -font $audace(font,arial_10_b) -relief groove \
               -textvariable panneau(AcqFC,$visuNo,intervalle_video) -justify center
            pack $panneau(AcqFC,$visuNo,base).status_video.a.ent1 -anchor center -expand 1 -fill none -side left -padx 10
         pack $panneau(AcqFC,$visuNo,base).status_video.a -padx 10 -pady 5
      }

      #--- Trame de la duree du film
      frame $panneau(AcqFC,$visuNo,base).status_video.pose -borderwidth 2
         menubutton $panneau(AcqFC,$visuNo,base).status_video.pose.but -text $caption(acqfc,lg_film) \
            -menu $panneau(AcqFC,$visuNo,base).status_video.pose.but.menu -relief raised
         pack $panneau(AcqFC,$visuNo,base).status_video.pose.but -side left -ipadx 5 -ipady 0
         set m [ menu $panneau(AcqFC,$visuNo,base).status_video.pose.but.menu -tearoff 0 ]
         foreach temps $panneau(AcqFC,$visuNo,temps_pose) {
            $m add radiobutton -label "$temps" \
               -indicatoron "1" \
               -value "$temps" \
               -variable panneau(AcqFC,$visuNo,lg_film) \
               -command " "
         }
         entry $panneau(AcqFC,$visuNo,base).status_video.pose.entr -width 5 -font $audace(font,arial_10_b) -relief groove \
            -textvariable panneau(AcqFC,$visuNo,lg_film) -justify center
         pack $panneau(AcqFC,$visuNo,base).status_video.pose.entr -side left -fill x -expand 0
         label $panneau(AcqFC,$visuNo,base).status_video.pose.lab -text $caption(acqfc,sec)
         pack $panneau(AcqFC,$visuNo,base).status_video.pose.lab -side left -anchor w -fill x -pady 0 -ipadx 5 -ipady 0
      pack $panneau(AcqFC,$visuNo,base).status_video.pose -anchor center -side top -pady 0 -ipadx 0 -ipady 0 -expand true

      #--- Nombre d'images/seconde
      frame $panneau(AcqFC,$visuNo,base).status_video.rate -borderwidth 2
         menubutton $panneau(AcqFC,$visuNo,base).status_video.rate.cb -text $caption(acqfc,rate) \
            -menu $panneau(AcqFC,$visuNo,base).status_video.rate.cb.menu -relief raised
         pack $panneau(AcqFC,$visuNo,base).status_video.rate.cb -side left -ipadx 5 -ipady 0
         set m [ menu $panneau(AcqFC,$visuNo,base).status_video.rate.cb.menu -tearoff 0 ]
         foreach rate $panneau(AcqFC,$visuNo,ratelist) {
            $m add radiobutton -label "$rate" \
               -indicatoron "1" \
               -value "$rate" \
               -variable panneau(AcqFC,$visuNo,rate) \
               -command " "
         }
         entry $panneau(AcqFC,$visuNo,base).status_video.rate.entr -width 5 -font $audace(font,arial_10_b) -relief groove \
            -textvariable panneau(AcqFC,$visuNo,rate) -justify center
         pack $panneau(AcqFC,$visuNo,base).status_video.rate.entr -side left -fill x -expand 0
         label $panneau(AcqFC,$visuNo,base).status_video.rate.unite -text $caption(acqfc,rate_unite)
         pack $panneau(AcqFC,$visuNo,base).status_video.rate.unite -anchor center -expand 0 -fill x -side left \
            -ipadx 5 -ipady 0
      pack $panneau(AcqFC,$visuNo,base).status_video.rate -anchor center -side top -pady 0 -ipadx 0 -ipady 0 -expand true

      #--- Label affichant le status de la camera en mode video
      frame $panneau(AcqFC,$visuNo,base).status_video.status -borderwidth 2 -relief ridge
         label $panneau(AcqFC,$visuNo,base).status_video.status.label -textvariable panneau(AcqFC,$visuNo,status) -font $audace(font,arial_8_b) \
            -wraplength 150 -height 4 -pady 0
         pack $panneau(AcqFC,$visuNo,base).status_video.status.label -anchor center -expand 0 -fill x -side top
      pack $panneau(AcqFC,$visuNo,base).status_video.status -anchor center -fill y -pady 0 -ipadx 5 -ipady 0

      #--- Frame pour l'acquisition fenetree
      frame $panneau(AcqFC,$visuNo,base).status_video.fenetrer -borderwidth 2 -relief ridge

         frame $panneau(AcqFC,$visuNo,base).status_video.fenetrer.check -borderwidth 0 -relief ridge
            checkbutton $panneau(AcqFC,$visuNo,base).status_video.fenetrer.check.case -pady 0 \
               -text "$caption(acqfc,acquisition_fenetree)" -variable panneau(AcqFC,$visuNo,fenetre) \
               -command "::AcqFC::cmdAcqFenetree $visuNo"
            pack $panneau(AcqFC,$visuNo,base).status_video.fenetrer.check.case -anchor w -expand 0 -side top
         pack $panneau(AcqFC,$visuNo,base).status_video.fenetrer.check -anchor w -expand 0 -fill x -side top

         button $panneau(AcqFC,$visuNo,base).status_video.fenetrer.but_select -borderwidth 1 \
            -text $caption(acqfc,acq_fen_msg) -command "::AcqFC::selectWindowedFenster $visuNo"
         # pack $panneau(AcqFC,$visuNo,base).status_video.fenetrer.but_select -anchor w -expand 0 -fill x -side top
         frame $panneau(AcqFC,$visuNo,base).status_video.fenetrer.left1 -borderwidth 0 -relief ridge
            label $panneau(AcqFC,$visuNo,base).status_video.fenetrer.left1.largeur -text "$caption(acqfc,largeur_hauteur)"
            pack $panneau(AcqFC,$visuNo,base).status_video.fenetrer.left1.largeur -anchor w -expand 0 \
               -side top -ipadx 15 -ipady 0
            label $panneau(AcqFC,$visuNo,base).status_video.fenetrer.left1.x1 -text "$caption(acqfc,coord_x1_y1)"
            pack $panneau(AcqFC,$visuNo,base).status_video.fenetrer.left1.x1 -anchor w -expand 0 \
               -side top -ipadx 15 -ipady 0
            label $panneau(AcqFC,$visuNo,base).status_video.fenetrer.left1.x2 -text "$caption(acqfc,coord_x2_y2)"
            pack $panneau(AcqFC,$visuNo,base).status_video.fenetrer.left1.x2 -anchor w -expand 0 \
               -side top -ipadx 15 -ipady 0
         # pack $panneau(AcqFC,$visuNo,base).status_video.fenetrer.left1 -anchor w -expand 0 -fill x -side left
         frame $panneau(AcqFC,$visuNo,base).status_video.fenetrer.right -borderwidth 0 -relief ridge
            label $panneau(AcqFC,$visuNo,base).status_video.fenetrer.right.hauteur -textvariable panneau(AcqFC,$visuNo,largeur)
            pack $panneau(AcqFC,$visuNo,base).status_video.fenetrer.right.hauteur -anchor center -expand 0 -fill x \
               -side top -ipadx 10 -ipady 0
            label $panneau(AcqFC,$visuNo,base).status_video.fenetrer.right.y1 -textvariable panneau(AcqFC,$visuNo,x1)
            pack $panneau(AcqFC,$visuNo,base).status_video.fenetrer.right.y1 -anchor center -expand 0 -fill x \
               -side top -ipadx 10 -ipady 0
            label $panneau(AcqFC,$visuNo,base).status_video.fenetrer.right.y2 -textvariable panneau(AcqFC,$visuNo,x2)
            pack $panneau(AcqFC,$visuNo,base).status_video.fenetrer.right.y2 -anchor center -expand 0 -fill x \
               -side top -ipadx 10 -ipady 0
         # pack $panneau(AcqFC,$visuNo,base).status_video.fenetrer.right -anchor w -expand 0 -fill x -side left
         frame $panneau(AcqFC,$visuNo,base).status_video.fenetrer.right1 -borderwidth 0 -relief ridge
            label $panneau(AcqFC,$visuNo,base).status_video.fenetrer.right1.hauteur -textvariable panneau(AcqFC,$visuNo,hauteur)
            pack $panneau(AcqFC,$visuNo,base).status_video.fenetrer.right1.hauteur -anchor center -expand 0 -fill x \
               -side top -ipadx 10 -ipady 0
            label $panneau(AcqFC,$visuNo,base).status_video.fenetrer.right1.y1 -textvariable panneau(AcqFC,$visuNo,y1)
            pack $panneau(AcqFC,$visuNo,base).status_video.fenetrer.right1.y1 -anchor center -expand 0 -fill x \
               -side top -ipadx 10 -ipady 0
            label $panneau(AcqFC,$visuNo,base).status_video.fenetrer.right1.y2 -textvariable panneau(AcqFC,$visuNo,y2)
            pack $panneau(AcqFC,$visuNo,base).status_video.fenetrer.right1.y2 -anchor center -expand 0 -fill x \
               -side top -ipadx 10 -ipady 0
         # pack $panneau(AcqFC,$visuNo,base).status_video.fenetrer.right1 -anchor w -expand 0 -fill x -side left

      pack $panneau(AcqFC,$visuNo,base).status_video.fenetrer -anchor center -fill both -pady 0 -ipadx 5 -ipady 0

      #--- New message window is on
      focus $panneau(AcqFC,$visuNo,base).status_video

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $panneau(AcqFC,$visuNo,base).status_video
   }
#***** Fin fenetre de configuration video ****************************************************

#***** Procedure d'ouverture des options de fenetrage ****************************************
   proc optionWindowedFenster { visuNo } {
      global panneau

      if { $panneau(AcqFC,$visuNo,fenetre) == "0" } {
         #--- Sans le fenetrage
         pack forget $panneau(AcqFC,$visuNo,base).status_video.fenetrer.but_select
         pack forget $panneau(AcqFC,$visuNo,base).status_video.fenetrer.left1
         pack forget $panneau(AcqFC,$visuNo,base).status_video.fenetrer.right
         pack forget $panneau(AcqFC,$visuNo,base).status_video.fenetrer.right1
      } else {
         #--- Avec le fenetrage
         pack $panneau(AcqFC,$visuNo,base).status_video.fenetrer.but_select -anchor w -expand 0 -fill x -side top
         pack $panneau(AcqFC,$visuNo,base).status_video.fenetrer.left1 -anchor w -expand 0 -fill x -side left
         pack $panneau(AcqFC,$visuNo,base).status_video.fenetrer.right -anchor w -expand 0 -fill x -side left
         pack $panneau(AcqFC,$visuNo,base).status_video.fenetrer.right1 -anchor w -expand 0 -fill x -side left
      }
   }
#***** Fin de la procedure d'ouverture des options de fenetrage ******************************

#***** Procedure de demarrage du fenetrage video *********************************************
   proc startWindowedFenster { visuNo } {
      global audace caption panneau

      #--- Active le mode preview
      if { $panneau(AcqFC,$visuNo,showvideopreview) == "0" } {
         set result [ ::AcqFC::startVideoPreview $visuNo ]
      } else {
         set result "0"
      }
      #---
      if { $result == "0" } {
         if { [ ::confVisu::getCamera $visuNo ] == "" } {
            ::confCam::run
            tkwait window $audace(base).confCam
            #--- Je decoche la checkbox
            set panneau(AcqFC,$visuNo,showvideopreview) "0"
            #--- Je decoche le fenetrage
            if { $panneau(AcqFC,$visuNo,fenetre) == "1" } {
               set panneau(AcqFC,$visuNo,fenetre) "0"
               ::AcqFC::optionWindowedFenster $visuNo
            }
         } elseif { [ ::confVisu::getProduct $visuNo ] != "webcam" } {
            tk_messageBox -title $caption(acqfc,pb) -type ok \
               -message $caption(acqfc,no_video_mode)
            #--- Je decoche la checkbox
            set panneau(AcqFC,$visuNo,showvideopreview) "0"
            #--- Je decoche le fenetrage
            if { $panneau(AcqFC,$visuNo,fenetre) == "1" } {
               set panneau(AcqFC,$visuNo,fenetre) "0"
               ::AcqFC::optionWindowedFenster $visuNo
            }
         } else {
            #--- Je demarre le mode video fenetree
            cam[ ::confVisu::getCamNo $visuNo ] startvideocrop
         }
      } else {
         set panneau(AcqFC,$visuNo,fenetre) "0"
      }
   }
#***** Fin de la procedure de demarrage du fenetrage video ***********************************

#***** Procedure d'arret du fenetrage video **************************************************
   proc stopWindowedFenster { visuNo } {
      global caption panneau

      #---
      if { [ winfo exists $panneau(AcqFC,$visuNo,base).selectWindowedFenster ] } {
         ::AcqFC::closeWindowedFenster $visuNo
      }
      #---
      if { [ ::confVisu::getCamera $visuNo ] == "" } {
         #--- Je decoche la checkbox
         set panneau(AcqFC,$visuNo,showvideopreview) "0"
         #--- Je decoche le fenetrage
         if { $panneau(AcqFC,$visuNo,fenetre) == "1" } {
            set panneau(AcqFC,$visuNo,fenetre) "0"
            ::AcqFC::optionWindowedFenster $visuNo
         }
      } elseif { [ ::confVisu::getProduct $visuNo ] != "webcam" } {
         #--- Je decoche la checkbox
         set panneau(AcqFC,$visuNo,showvideopreview) "0"
         #--- Je decoche le fenetrage
         if { $panneau(AcqFC,$visuNo,fenetre) == "1" } {
            set panneau(AcqFC,$visuNo,fenetre) "0"
            ::AcqFC::optionWindowedFenster $visuNo
         }
      } else {
         #--- J'arrete le mode video fenetree
         cam[ ::confVisu::getCamNo $visuNo ] stopvideocrop
      }
   }
#***** Fin de la procedure d'arret du fenetrage video ****************************************

#***** Procedure de selection du fenetrage video *********************************************
   proc selectWindowedFenster { visuNo } {
      global audace caption conf panneau zone

      #--- Une camera est connectee
      if { [ ::confVisu::getCamera $visuNo ] == "" } {
         return
      } elseif { [ ::confVisu::getProduct $visuNo ] != "webcam" } {
         return
      }

      #---
      if { [ winfo exists $panneau(AcqFC,$visuNo,base).selectWindowedFenster ] } {
         wm withdraw $panneau(AcqFC,$visuNo,base).selectWindowedFenster
         wm deiconify $panneau(AcqFC,$visuNo,base).selectWindowedFenster
         focus $panneau(AcqFC,$visuNo,base).selectWindowedFenster
         return
      }

      #--- Cree la fenetre $panneau(AcqFC,$visuNo,base).selectWindowedFenster de niveau le plus haut
      toplevel $panneau(AcqFC,$visuNo,base).selectWindowedFenster -class Toplevel
      wm geometry $panneau(AcqFC,$visuNo,base).selectWindowedFenster $conf(acqfc,video,position)
      wm resizable $panneau(AcqFC,$visuNo,base).selectWindowedFenster 0 0
      wm title $panneau(AcqFC,$visuNo,base).selectWindowedFenster $caption(acqfc,acq_fen_msg)

      #--- Creation des differents frames
      frame $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame1 -borderwidth 1 -relief raised
      pack $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame1 -side top -fill both -expand 1

      frame $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame2 -borderwidth 1 -relief raised
      pack $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame2 -side top -fill x

      frame $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame3 -borderwidth 0 -relief raised
      pack $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame3 \
         -in $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame1 -side top -fill both -expand 1

      frame $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame4 -borderwidth 0 -relief raised
      pack $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame4 \
         -in $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame1 -side top -fill both -expand 1

      frame $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame5 -borderwidth 0 -relief raised
      pack $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame5 \
         -in $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame4 -side left -fill both -expand 1

      frame $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame6 -borderwidth 0 -relief raised
      pack $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame6 \
         -in $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame4 -side left -fill both -expand 1

      frame $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame7 -borderwidth 0 -relief raised
      pack $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame7 \
         -in $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame5 -side top -fill both -expand 1

      frame $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame8 -borderwidth 0 -relief raised
      pack $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame8 \
         -in $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame5 -side top -fill both -expand 1

      frame $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame9 -borderwidth 0 -relief raised
      pack $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame9 \
         -in $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame6 -side top -fill both -expand 1

      frame $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame10 -borderwidth 0 -relief raised
      pack $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame10 \
         -in $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame6 -side top -fill both -expand 1

      #--- Rafraichir le nombre de pixels du CCD en x et en y
      button $panneau(AcqFC,$visuNo,base).selectWindowedFenster.but_refresh -text "$caption(acqfc,refresh)" \
         -borderwidth 2 -command "::AcqFC::refreshNumberPixel $visuNo"
      pack $panneau(AcqFC,$visuNo,base).selectWindowedFenster.but_refresh \
         -in $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame3 -side top -anchor center -padx 3 -pady 3 -ipadx 5 -ipady 5

      #--- Creation d'un canvas pour affichage de la fenetre dans la video
      canvas $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame3.image1_color_invariant \
         -width 340 -height 260 -highlightthickness 0
      pack $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame3.image1_color_invariant
      set zone(image1) $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame3.image1_color_invariant

      #--- Representation de la video
      $zone(image1) create line 10 10 10 250 -fill $audace(color,textColor) -tags cadres -width 2.0
      $zone(image1) create line 10 250 330 250 -fill $audace(color,textColor) -tags cadres -width 2.0
      $zone(image1) create line 330 250 330 10 -fill $audace(color,textColor) -tags cadres -width 2.0
      $zone(image1) create line 330 10 10 10 -fill $audace(color,textColor) -tags cadres -width 2.0

      #--- Representation de la fenetre
      $zone(image1) create line 50 80 50 200 -fill $audace(color,drag_rectangle) -tags cadres -width 2.0
      $zone(image1) create line 50 200 250 200 -fill $audace(color,drag_rectangle) -tags cadres -width 2.0
      $zone(image1) create line 250 200 250 80 -fill $audace(color,drag_rectangle) -tags cadres -width 2.0
      $zone(image1) create line 250 80 50 80 -fill $audace(color,drag_rectangle) -tags cadres -width 2.0

      #--- Largeur et hauteur de la video
      ::AcqFC::refreshNumberPixel $visuNo

      #--- Abcisses et ordonnees des 4 coins de la fenetre
      $zone(image1) create text 30 200 -text "(x1,y1)" \
         -justify center -fill $audace(color,drag_rectangle) -tags cadres -font $audace(font,arial_8_b)
      $zone(image1) create text 30 80 -text "(x1,y2)" \
         -justify center -fill $audace(color,drag_rectangle) -tags cadres -font $audace(font,arial_8_b)
      $zone(image1) create text 270 80 -text "(x2,y2)" \
         -justify center -fill $audace(color,drag_rectangle) -tags cadres -font $audace(font,arial_8_b)
      $zone(image1) create text 270 200 -text "(x2,y1)" \
         -justify center -fill $audace(color,drag_rectangle) -tags cadres -font $audace(font,arial_8_b)

      #--- Cree la zone a renseigner pour x1
      label $panneau(AcqFC,$visuNo,base).selectWindowedFenster.lab1 -text "$caption(acqfc,x1)"
      pack $panneau(AcqFC,$visuNo,base).selectWindowedFenster.lab1 \
         -in $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame7 -anchor w -side left -padx 30 -pady 3

      entry $panneau(AcqFC,$visuNo,base).selectWindowedFenster.ent1 -textvariable panneau(AcqFC,$visuNo,x1) \
         -width 6 -justify center
      pack $panneau(AcqFC,$visuNo,base).selectWindowedFenster.ent1 \
         -in $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame7 -anchor w -side left -padx 0 -pady 3

      #--- Cree la zone a renseigner pour y1
      label $panneau(AcqFC,$visuNo,base).selectWindowedFenster.lab2 -text "$caption(acqfc,y1)"
      pack $panneau(AcqFC,$visuNo,base).selectWindowedFenster.lab2 \
         -in $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame8 -anchor w -side left -padx 30 -pady 3

      entry $panneau(AcqFC,$visuNo,base).selectWindowedFenster.ent2 -textvariable panneau(AcqFC,$visuNo,y1) \
         -width 6 -justify center
      pack $panneau(AcqFC,$visuNo,base).selectWindowedFenster.ent2 \
         -in $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame8 -anchor w -side left -padx 0 -pady 3

      #--- Cree la zone a renseigner pour x2
      label $panneau(AcqFC,$visuNo,base).selectWindowedFenster.lab3 -text "$caption(acqfc,x2)"
      pack $panneau(AcqFC,$visuNo,base).selectWindowedFenster.lab3 \
         -in $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame9 -anchor w -side left -padx 10 -pady 3

      entry $panneau(AcqFC,$visuNo,base).selectWindowedFenster.ent3 -textvariable panneau(AcqFC,$visuNo,x2) \
         -width 6 -justify center
      pack $panneau(AcqFC,$visuNo,base).selectWindowedFenster.ent3 \
         -in $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame9 -anchor w -side left -padx 20 -pady 3

      #--- Cree la zone a renseigner pour y2
      label $panneau(AcqFC,$visuNo,base).selectWindowedFenster.lab4 -text "$caption(acqfc,y2)"
      pack $panneau(AcqFC,$visuNo,base).selectWindowedFenster.lab4 \
         -in $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame10 -anchor w -side left -padx 10 -pady 3

      entry $panneau(AcqFC,$visuNo,base).selectWindowedFenster.ent4 -textvariable panneau(AcqFC,$visuNo,y2) \
         -width 6 -justify center
      pack $panneau(AcqFC,$visuNo,base).selectWindowedFenster.ent4 \
         -in $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame10 -anchor w -side left -padx 20 -pady 3

      #--- Cree le bouton 'OK'
      button $panneau(AcqFC,$visuNo,base).selectWindowedFenster.but_ok -text "$caption(acqfc,ok)" -width 7 \
         -borderwidth 2 -command "::AcqFC::setvideocroprectWindowedFenster $visuNo ; ::AcqFC::closeWindowedFenster $visuNo"
      pack $panneau(AcqFC,$visuNo,base).selectWindowedFenster.but_ok \
         -in $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Appliquer'
      button $panneau(AcqFC,$visuNo,base).selectWindowedFenster.but_appliquer -text "$caption(acqfc,appliquer)" -width 7 \
         -borderwidth 2 -command "::AcqFC::setvideocroprectWindowedFenster $visuNo"
      pack $panneau(AcqFC,$visuNo,base).selectWindowedFenster.but_appliquer \
         -in $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Fermer'
      button $panneau(AcqFC,$visuNo,base).selectWindowedFenster.but_fermer -text "$caption(acqfc,fermer)" -width 7 \
         -borderwidth 2 -command "::AcqFC::closeWindowedFenster $visuNo"
      pack $panneau(AcqFC,$visuNo,base).selectWindowedFenster.but_fermer \
         -in $panneau(AcqFC,$visuNo,base).selectWindowedFenster.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $panneau(AcqFC,$visuNo,base).selectWindowedFenster

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $panneau(AcqFC,$visuNo,base).selectWindowedFenster <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $panneau(AcqFC,$visuNo,base).selectWindowedFenster
   }
#***** Fin de la procedure de selection du fenetrage video ***********************************

#***** Procedure de rafraississement du nombre de pixels *************************************
   proc refreshNumberPixel { visuNo } {
      global audace zone

      #--- J'arrete le mode video fenetree
      catch { cam[ ::confVisu::getCamNo $visuNo ] stopvideocrop }

      #--- Largeur et hauteur de l'image
      set largeur [ lindex [ cam[ ::confVisu::getCamNo $visuNo ] nbpix ] 0 ]
      set hauteur [ lindex [ cam[ ::confVisu::getCamNo $visuNo ] nbpix ] 1 ]

      #--- Effacement de la largeur et la hauteur de la video
      $zone(image1) delete label_nb_pixel_x_y

      #--- Largeur et hauteur de la video
      $zone(image1) create text 170 20 -text "$largeur" \
         -justify center -fill $audace(color,textColor) -tags label_nb_pixel_x_y -font $audace(font,arial_8_b)
      $zone(image1) create text 25 130 -text "$hauteur" \
         -justify center -fill $audace(color,textColor) -tags label_nb_pixel_x_y -font $audace(font,arial_8_b)

      #--- Je demarre le mode video fenetree
      catch { cam[ ::confVisu::getCamNo $visuNo ] startvideocrop }
   }
#***** Fin de la procedure de rafraississement du nombre de pixels ***************************

#***** Procedure d'acquisition du fenetrage video ********************************************
   proc setvideocroprectWindowedFenster { visuNo } {
      global panneau

      #--- Largeur et hauteur de l'image
      set largeur [ lindex [ cam[ ::confVisu::getCamNo $visuNo ] nbpix ] 0 ]
      set hauteur [ lindex [ cam[ ::confVisu::getCamNo $visuNo ] nbpix ] 1 ]

      #--- Controle la coordonnee x1
      if { [ TestReel $panneau(AcqFC,$visuNo,x1) ] == "0" } {
         set panneau(AcqFC,$visuNo,x1) "1"
      }
      if { ( $panneau(AcqFC,$visuNo,x1) > $largeur ) || ( $panneau(AcqFC,$visuNo,x1) ) < "1" } {
         set panneau(AcqFC,$visuNo,x1) "1"
      }

      #--- Controle la coordonnee y1
      if { [ TestReel $panneau(AcqFC,$visuNo,y1) ] == "0" } {
         set panneau(AcqFC,$visuNo,y1) "1"
      }
      if { ( $panneau(AcqFC,$visuNo,y1) > $hauteur ) || ( $panneau(AcqFC,$visuNo,y1) ) < "1" } {
         set panneau(AcqFC,$visuNo,y1) "1"
      }

      #--- Controle la coordonnee x2
      if { [ TestReel $panneau(AcqFC,$visuNo,x2) ] == "0" } {
         set panneau(AcqFC,$visuNo,x2) [ expr $largeur - 1 ]
      }
      if { ( $panneau(AcqFC,$visuNo,x2) > $largeur ) || ( $panneau(AcqFC,$visuNo,x2) < "1" ) } {
         set panneau(AcqFC,$visuNo,x2) [ expr $largeur - 1 ]
      }

      #--- Controle la coordonnee y2
      if { [ TestReel $panneau(AcqFC,$visuNo,y2) ] == "0" } {
         set panneau(AcqFC,$visuNo,y2) [ expr $hauteur - 1 ]
      }
      if { ( $panneau(AcqFC,$visuNo,y2) > $hauteur ) || ( $panneau(AcqFC,$visuNo,y2) < "1" ) } {
         set panneau(AcqFC,$visuNo,y2) [ expr $hauteur - 1 ]
      }

      #--- Largeur et hauteur de la fenetre vidieo
      set panneau(AcqFC,$visuNo,largeur) [ expr $panneau(AcqFC,$visuNo,y2) - $panneau(AcqFC,$visuNo,y1) ]
      set panneau(AcqFC,$visuNo,hauteur) [ expr $panneau(AcqFC,$visuNo,x2) - $panneau(AcqFC,$visuNo,x1) ]

      #--- Je positionne la fenetre video
      cam[ ::confVisu::getCamNo $visuNo ] setvideocroprect $panneau(AcqFC,$visuNo,x1) $panneau(AcqFC,$visuNo,y1) \
         $panneau(AcqFC,$visuNo,x2) $panneau(AcqFC,$visuNo,y2)
   }
#***** Fin de la procedure d'acquisition du fenetrage video **********************************

#***** Procedure de fermeture de la fenetre du fenetrage video *******************************
   proc closeWindowedFenster { visuNo } {
      global panneau

      #--- Fermeture de la fenetre
      destroy $panneau(AcqFC,$visuNo,base).selectWindowedFenster
   }
#***** Fin de la procedure de fermeture de la fenetre du fenetrage video *********************

#***** Enregistrement de la position des fenetres Continu (1), Continu (2), Video et Video (1) ********
   proc recup_position { visuNo } {
      global audace conf panneau

      #--- Cas de la fenetre Continu (1)
      if [ winfo exists $panneau(AcqFC,$visuNo,base).intervalle_continu_1 ] {
         #--- Determination de la position de la fenetre
         set geometry [ wm geometry $panneau(AcqFC,$visuNo,base).intervalle_continu_1 ]
         set deb [ expr 1 + [ string first + $geometry ] ]
         set fin [ string length $geometry ]
         set conf(acqfc,continu1,position) "+[ string range $geometry $deb $fin ]"
         #--- Fermeture de la fenetre
         destroy $panneau(AcqFC,$visuNo,base).intervalle_continu_1
      }
      #--- Cas de la fenetre Continu (2)
      if [ winfo exists $panneau(AcqFC,$visuNo,base).intervalle_continu_2 ] {
         #--- Determination de la position de la fenetre
         set geometry [ wm geometry $panneau(AcqFC,$visuNo,base).intervalle_continu_2 ]
         set deb [ expr 1 + [ string first + $geometry ] ]
         set fin [ string length $geometry ]
         set conf(acqfc,continu2,position) "+[ string range $geometry $deb $fin ]"
         #--- Fermeture de la fenetre
         destroy $panneau(AcqFC,$visuNo,base).intervalle_continu_2
      }
      #--- Cas de la fenetre Video et Video (1)
      if [ winfo exists $panneau(AcqFC,$visuNo,base).status_video ] {
         #--- Determination de la position de la fenetre
         set geometry [ wm geometry $panneau(AcqFC,$visuNo,base).status_video ]
         set deb [ expr 1 + [ string first + $geometry ] ]
         set fin [ string length $geometry ]
         set conf(acqfc,video,position) "+[ string range $geometry $deb $fin ]"
         #--- Fermeture de la fenetre
         destroy $panneau(AcqFC,$visuNo,base).status_video
      }
   }
#***** Fin enregistrement de la position des fenetres Continu (1), Continu (2), Video et Video (1) ****

#***** Enregistrement de la position de la fenetre Avancement ********
   proc recup_position_1 { visuNo } {
      global audace conf panneau

      #--- Cas de la fenetre Avancement
      if [ winfo exists $panneau(AcqFC,$visuNo,base).progress ] {
         #--- Determination de la position de la fenetre
         set geometry [ wm geometry $panneau(AcqFC,$visuNo,base).progress ]
         set deb [ expr 1 + [ string first + $geometry ] ]
         set fin [ string length $geometry ]
         set panneau(AcqFC,$visuNo,avancement,position) "+[ string range $geometry $deb $fin ]"
      }
   }
#***** Fin enregistrement de la position de la fenetre Avancement ****

#***** Aquisition fenetree avec une WebCam ***************************
   proc cmdAcqFenetree { visuNo } {
      global panneau

      if { $panneau(AcqFC,$visuNo,fenetre) == "1" } {
         ::AcqFC::optionWindowedFenster $visuNo
         ::AcqFC::startWindowedFenster $visuNo
      } else {
         ::AcqFC::optionWindowedFenster $visuNo
         ::AcqFC::stopWindowedFenster $visuNo
      }
   }
#***** Fin de l'aquisition fenetree avec une WebCam ******************

#***** Affichage de la fenetre de configuration de WebCam ************
   proc webcamConfigure { visuNo } {
      global caption

      set result [::webcam::config::run $visuNo [::confVisu::getCamItem $visuNo]]
      if { $result == "1" } {
         if { [ ::confVisu::getCamera $visuNo ] == "" } {
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

      if { ( $panneau(AcqFC,$visuNo,mode) == "1" ) || ( $panneau(AcqFC,$visuNo,mode) == "2" ) || \
         ( $panneau(AcqFC,$visuNo,mode) == "3" ) || ( $panneau(AcqFC,$visuNo,mode) == "4" ) || \
         ( $panneau(AcqFC,$visuNo,mode) == "5" ) } {
         ::dslr::setLoadParameters $visuNo
      }
   }
#***** Fin de la configuration du telechargement *********************

}
#==============================================================
#   Fin de la declaration du namespace AcqFC
#==============================================================

proc AcqFCBuildIF { visuNo } {
   global audace caption conf panneau

   #--- Determination de la fenetre parente
   if { $visuNo == "1" } {
      set base "$audace(base)"
   } else {
      set base ".visu$visuNo"
   }

   #--- Trame du panneau
   frame $panneau(AcqFC,$visuNo,This) -borderwidth 2 -relief groove

   #--- Trame du titre du panneau
   frame $panneau(AcqFC,$visuNo,This).titre -borderwidth 2 -relief groove
      Button $panneau(AcqFC,$visuNo,This).titre.but -borderwidth 1 -text $caption(acqfc,titre) \
        -command "::audace::showHelpPlugin tool acqfc acqfc.htm"
      pack $panneau(AcqFC,$visuNo,This).titre.but -side top -fill x -in $panneau(AcqFC,$visuNo,This).titre -ipadx 5
      DynamicHelp::add $panneau(AcqFC,$visuNo,This).titre.but -text $caption(acqfc,help_titre)
   pack $panneau(AcqFC,$visuNo,This).titre -side top -fill x

   #--- Trame du bouton de configuration
   frame $panneau(AcqFC,$visuNo,This).config -borderwidth 2 -relief groove
      button $panneau(AcqFC,$visuNo,This).config.but -borderwidth 1 -text $caption(acqfc,configuration) \
        -command "::acqfcSetup::run $visuNo $base.acqfcSetup"
      pack $panneau(AcqFC,$visuNo,This).config.but -side top -fill x -in $panneau(AcqFC,$visuNo,This).config -ipadx 5
   pack $panneau(AcqFC,$visuNo,This).config -side top -fill x

   #--- Trame du temps de pose
   frame $panneau(AcqFC,$visuNo,This).pose -borderwidth 2 -relief ridge
      menubutton $panneau(AcqFC,$visuNo,This).pose.but -text $caption(acqfc,pose) \
         -menu $panneau(AcqFC,$visuNo,This).pose.but.menu -relief raised
      pack $panneau(AcqFC,$visuNo,This).pose.but -side left -fill x -expand true -ipady 1
      set m [ menu $panneau(AcqFC,$visuNo,This).pose.but.menu -tearoff 0 ]
      foreach temps $panneau(AcqFC,$visuNo,temps_pose) {
        $m add radiobutton -label "$temps" \
           -indicatoron "1" \
           -value "$temps" \
           -variable panneau(AcqFC,$visuNo,pose) \
           -command " "
      }
      label $panneau(AcqFC,$visuNo,This).pose.lab -text $caption(acqfc,sec)
      pack $panneau(AcqFC,$visuNo,This).pose.lab -side right -fill x -expand true
      entry $panneau(AcqFC,$visuNo,This).pose.entr -width 6 -font $audace(font,arial_10_b) -relief groove \
        -textvariable panneau(AcqFC,$visuNo,pose) -justify center
      pack $panneau(AcqFC,$visuNo,This).pose.entr -side left -fill both -expand true
   pack $panneau(AcqFC,$visuNo,This).pose -side top -fill x

   #--- Bouton de configuration de la WebCam en lieu et place du widget psoe
   button $panneau(AcqFC,$visuNo,This).pose.conf -text $caption(acqfc,pose) \
      -command "::AcqFC::webcamConfigure $visuNo"
   pack $panneau(AcqFC,$visuNo,This).pose.conf -fill x -expand true -ipady 3

   #--- Trame du binning
   frame $panneau(AcqFC,$visuNo,This).bin -borderwidth 2 -relief ridge
      menubutton $panneau(AcqFC,$visuNo,This).bin.but -text $caption(acqfc,bin) \
         -menu $panneau(AcqFC,$visuNo,This).bin.but.menu -relief raised
      pack $panneau(AcqFC,$visuNo,This).bin.but -side left -fill y -expand true -ipady 1
      set m [ menu $panneau(AcqFC,$visuNo,This).bin.but.menu -tearoff 0 ]
      foreach valbin [ ::confCam::getPluginProperty [ ::confVisu::getCamItem $visuNo ] binningList ] {
        $m add radiobutton -label "$valbin" \
           -indicatoron "1" \
           -value "$valbin" \
           -variable panneau(AcqFC,$visuNo,bin) \
           -command " "
      }
      entry $panneau(AcqFC,$visuNo,This).bin.lab -width 10 -font $audace(font,arial_10_b) -relief groove \
        -textvariable panneau(AcqFC,$visuNo,bin) -justify center -state disabled
      pack $panneau(AcqFC,$visuNo,This).bin.lab -side left -fill both -expand true
   pack $panneau(AcqFC,$visuNo,This).bin -side top -fill x

   #--- Trame de l'obturateur
   frame $panneau(AcqFC,$visuNo,This).obt -borderwidth 2 -relief ridge -width 16
      button $panneau(AcqFC,$visuNo,This).obt.but -text $caption(acqfc,obt) -command "::AcqFC::ChangeObt $visuNo" \
         -state normal
      pack $panneau(AcqFC,$visuNo,This).obt.but -side left -ipady 3
      label $panneau(AcqFC,$visuNo,This).obt.lab -text $panneau(AcqFC,$visuNo,obt,$panneau(AcqFC,$visuNo,obt)) -width 6 \
        -font $audace(font,arial_10_b) -relief groove
      pack $panneau(AcqFC,$visuNo,This).obt.lab -side left -fill x -expand true -ipady 3
      label $panneau(AcqFC,$visuNo,This).obt.lab1 -text "" -font $audace(font,arial_10_b) -relief ridge \
         -justify center -width 16
      pack $panneau(AcqFC,$visuNo,This).obt.lab1 -side top -ipady 3
   pack $panneau(AcqFC,$visuNo,This).obt -side top -fill x

   #--- Bouton du choix du telechargement de l'image de l'APN en lieu et place du widget obturateur
   button $panneau(AcqFC,$visuNo,This).obt.dslr -text $caption(acqfc,config) -state normal \
      -command "::AcqFC::choixTelechargement $visuNo"
   pack $panneau(AcqFC,$visuNo,This).obt.dslr -fill x -expand true

   #--- Trame du Status
   frame $panneau(AcqFC,$visuNo,This).status -borderwidth 2 -relief ridge
      label $panneau(AcqFC,$visuNo,This).status.lab -text "" -font $audace(font,arial_10_b) -relief ridge \
         -justify center -width 16
      pack $panneau(AcqFC,$visuNo,This).status.lab -side top -pady 1
   pack $panneau(AcqFC,$visuNo,This).status -side top

   #--- Trame du bouton Go/Stop
   frame $panneau(AcqFC,$visuNo,This).go_stop -borderwidth 2 -relief ridge
      Button $panneau(AcqFC,$visuNo,This).go_stop.but -text $caption(acqfc,GO) -height 2 \
        -font $audace(font,arial_12_b) -borderwidth 3 -command "::AcqFC::GoStop $visuNo"
      pack $panneau(AcqFC,$visuNo,This).go_stop.but -fill both -padx 0 -pady 0 -expand true
   pack $panneau(AcqFC,$visuNo,This).go_stop -side top -fill x

   #--- Trame du mode d'acquisition
   set panneau(AcqFC,$visuNo,mode_en_cours) [ lindex $panneau(AcqFC,$visuNo,list_mode) [ expr $panneau(AcqFC,$visuNo,mode) - 1 ] ]
   frame $panneau(AcqFC,$visuNo,This).mode -borderwidth 5 -relief ridge
      ComboBox $panneau(AcqFC,$visuNo,This).mode.but \
        -width 15         \
        -font $audace(font,arial_10_n) \
        -height [llength $panneau(AcqFC,$visuNo,list_mode)] \
        -relief raised    \
        -borderwidth 1    \
        -editable 0       \
        -takefocus 1      \
        -justify center   \
        -textvariable panneau(AcqFC,$visuNo,mode_en_cours) \
        -values $panneau(AcqFC,$visuNo,list_mode) \
        -modifycmd "::AcqFC::ChangeMode $visuNo"
      pack $panneau(AcqFC,$visuNo,This).mode.but -side top

      #--- Definition du sous-panneau "Mode : Une seule image"
      frame $panneau(AcqFC,$visuNo,This).mode.une -borderwidth 0
        frame $panneau(AcqFC,$visuNo,This).mode.une.nom -relief ridge -borderwidth 2
           label $panneau(AcqFC,$visuNo,This).mode.une.nom.but -text $caption(acqfc,nom) -pady 0
           pack $panneau(AcqFC,$visuNo,This).mode.une.nom.but -fill x -side top
           entry $panneau(AcqFC,$visuNo,This).mode.une.nom.entr -width 10 -textvariable panneau(AcqFC,$visuNo,nom_image) \
              -font $audace(font,arial_10_b) -relief groove
           pack $panneau(AcqFC,$visuNo,This).mode.une.nom.entr -fill x -side top
           label $panneau(AcqFC,$visuNo,This).mode.une.nom.lab_extension -text $caption(acqfc,extension) -pady 0
           pack $panneau(AcqFC,$visuNo,This).mode.une.nom.lab_extension -fill x -side left
           menubutton $panneau(AcqFC,$visuNo,This).mode.une.nom.extension -textvariable panneau(AcqFC,$visuNo,extension) \
              -menu $panneau(AcqFC,$visuNo,This).mode.une.nom.extension.menu -relief raised
           pack $panneau(AcqFC,$visuNo,This).mode.une.nom.extension -side right -fill x -expand true -ipady 1
           set m [ menu $panneau(AcqFC,$visuNo,This).mode.une.nom.extension.menu -tearoff 0 ]
           foreach extension $conf(list_extension) {
             $m add radiobutton -label "$extension" \
                -indicatoron "1" \
                -value "$extension" \
                -variable panneau(AcqFC,$visuNo,extension) \
                -command " "
           }
        pack $panneau(AcqFC,$visuNo,This).mode.une.nom -side top -fill x
        frame $panneau(AcqFC,$visuNo,This).mode.une.index -relief ridge -borderwidth 2
           checkbutton $panneau(AcqFC,$visuNo,This).mode.une.index.case -pady 0 -text $caption(acqfc,index) -variable panneau(AcqFC,$visuNo,indexer)
           pack $panneau(AcqFC,$visuNo,This).mode.une.index.case -side top -fill x
           entry $panneau(AcqFC,$visuNo,This).mode.une.index.entr -width 3 -textvariable panneau(AcqFC,$visuNo,index) \
              -font $audace(font,arial_10_b) -relief groove -justify center
           pack $panneau(AcqFC,$visuNo,This).mode.une.index.entr -side left -fill x -expand true
           button $panneau(AcqFC,$visuNo,This).mode.une.index.but -text "1" -width 3 \
              -command "set panneau(AcqFC,$visuNo,index) 1"
           pack $panneau(AcqFC,$visuNo,This).mode.une.index.but -side right -fill x
        pack $panneau(AcqFC,$visuNo,This).mode.une.index -side top -fill x
        button $panneau(AcqFC,$visuNo,This).mode.une.sauve -text $caption(acqfc,sauvegde) -command "::AcqFC::SauveUneImage $visuNo"
        pack $panneau(AcqFC,$visuNo,This).mode.une.sauve -side top -fill x

      #--- Definition du sous-panneau "Mode : Serie d'images"
      frame $panneau(AcqFC,$visuNo,This).mode.serie
        frame $panneau(AcqFC,$visuNo,This).mode.serie.nom -relief ridge -borderwidth 2
           label $panneau(AcqFC,$visuNo,This).mode.serie.nom.but -text $caption(acqfc,nom) -pady 0
           pack $panneau(AcqFC,$visuNo,This).mode.serie.nom.but -fill x
           entry $panneau(AcqFC,$visuNo,This).mode.serie.nom.entr -width 10 -textvariable panneau(AcqFC,$visuNo,nom_image) \
              -font $audace(font,arial_10_b) -relief groove
           pack $panneau(AcqFC,$visuNo,This).mode.serie.nom.entr -fill x
           label $panneau(AcqFC,$visuNo,This).mode.serie.nom.lab_extension -text $caption(acqfc,extension) -pady 0
           pack $panneau(AcqFC,$visuNo,This).mode.serie.nom.lab_extension -fill x -side left
           menubutton $panneau(AcqFC,$visuNo,This).mode.serie.nom.extension -textvariable panneau(AcqFC,$visuNo,extension) \
              -menu $panneau(AcqFC,$visuNo,This).mode.serie.nom.extension.menu -relief raised
           pack $panneau(AcqFC,$visuNo,This).mode.serie.nom.extension -side right -fill x -expand true -ipady 1
           set m [ menu $panneau(AcqFC,$visuNo,This).mode.serie.nom.extension.menu -tearoff 0 ]
           foreach extension $conf(list_extension) {
             $m add radiobutton -label "$extension" \
                -indicatoron "1" \
                -value "$extension" \
                -variable panneau(AcqFC,$visuNo,extension) \
                -command " "
           }
        pack $panneau(AcqFC,$visuNo,This).mode.serie.nom -side top -fill x
        frame $panneau(AcqFC,$visuNo,This).mode.serie.nb -relief ridge -borderwidth 2
           label $panneau(AcqFC,$visuNo,This).mode.serie.nb.but -text $caption(acqfc,nombre) -pady 0
           pack $panneau(AcqFC,$visuNo,This).mode.serie.nb.but -side left -fill y
           entry $panneau(AcqFC,$visuNo,This).mode.serie.nb.entr -width 3 -textvariable panneau(AcqFC,$visuNo,nb_images) \
              -font $audace(font,arial_10_b) -relief groove -justify center
           pack $panneau(AcqFC,$visuNo,This).mode.serie.nb.entr -side left -fill x -expand true
        pack $panneau(AcqFC,$visuNo,This).mode.serie.nb -side top -fill x
        frame $panneau(AcqFC,$visuNo,This).mode.serie.index -relief ridge -borderwidth 2
           label $panneau(AcqFC,$visuNo,This).mode.serie.index.lab -text $caption(acqfc,index) -pady 0
           pack $panneau(AcqFC,$visuNo,This).mode.serie.index.lab -side top -fill x
           entry $panneau(AcqFC,$visuNo,This).mode.serie.index.entr -width 3 -textvariable panneau(AcqFC,$visuNo,index) \
              -font $audace(font,arial_10_b) -relief groove -justify center
           pack $panneau(AcqFC,$visuNo,This).mode.serie.index.entr -side left -fill x -expand true
           button $panneau(AcqFC,$visuNo,This).mode.serie.index.but -text "1" -width 3 \
              -command "set panneau(AcqFC,$visuNo,index) 1"
           pack $panneau(AcqFC,$visuNo,This).mode.serie.index.but -side right -fill x
        pack $panneau(AcqFC,$visuNo,This).mode.serie.index -side top -fill x

      #--- Definition du sous-panneau "Mode : Continu"
      frame $panneau(AcqFC,$visuNo,This).mode.continu
        frame $panneau(AcqFC,$visuNo,This).mode.continu.sauve -relief ridge -borderwidth 2
           checkbutton $panneau(AcqFC,$visuNo,This).mode.continu.sauve.case -text $caption(acqfc,enregistrer) \
              -variable panneau(AcqFC,$visuNo,enregistrer)
           pack $panneau(AcqFC,$visuNo,This).mode.continu.sauve.case -side left -fill x  -expand true
        pack $panneau(AcqFC,$visuNo,This).mode.continu.sauve -side top -fill x
        frame $panneau(AcqFC,$visuNo,This).mode.continu.nom -relief ridge -borderwidth 2
           label $panneau(AcqFC,$visuNo,This).mode.continu.nom.but -text $caption(acqfc,nom) -pady 0
           pack $panneau(AcqFC,$visuNo,This).mode.continu.nom.but -fill x
           entry $panneau(AcqFC,$visuNo,This).mode.continu.nom.entr -width 10 -textvariable panneau(AcqFC,$visuNo,nom_image) \
              -font $audace(font,arial_10_b) -relief groove
           pack $panneau(AcqFC,$visuNo,This).mode.continu.nom.entr -fill x
           label $panneau(AcqFC,$visuNo,This).mode.continu.nom.lab_extension -text $caption(acqfc,extension) -pady 0
           pack $panneau(AcqFC,$visuNo,This).mode.continu.nom.lab_extension -fill x -side left
           menubutton $panneau(AcqFC,$visuNo,This).mode.continu.nom.extension -textvariable panneau(AcqFC,$visuNo,extension) \
              -menu $panneau(AcqFC,$visuNo,This).mode.continu.nom.extension.menu -relief raised
           pack $panneau(AcqFC,$visuNo,This).mode.continu.nom.extension -side right -fill x -expand true -ipady 1
           set m [ menu $panneau(AcqFC,$visuNo,This).mode.continu.nom.extension.menu -tearoff 0 ]
           foreach extension $conf(list_extension) {
             $m add radiobutton -label "$extension" \
                -indicatoron "1" \
                -value "$extension" \
                -variable panneau(AcqFC,$visuNo,extension) \
                -command " "
           }
        pack $panneau(AcqFC,$visuNo,This).mode.continu.nom -side top -fill x
        frame $panneau(AcqFC,$visuNo,This).mode.continu.index -relief ridge -borderwidth 2
           label $panneau(AcqFC,$visuNo,This).mode.continu.index.lab -text $caption(acqfc,index) -pady 0
           pack $panneau(AcqFC,$visuNo,This).mode.continu.index.lab -side top -fill x
           entry $panneau(AcqFC,$visuNo,This).mode.continu.index.entr -width 3 -textvariable panneau(AcqFC,$visuNo,index) \
              -font $audace(font,arial_10_b) -relief groove -justify center
           pack $panneau(AcqFC,$visuNo,This).mode.continu.index.entr -side left -fill x -expand true
           button $panneau(AcqFC,$visuNo,This).mode.continu.index.but -text "1" -width 3 \
              -command "set panneau(AcqFC,$visuNo,index) 1"
           pack $panneau(AcqFC,$visuNo,This).mode.continu.index.but -side right -fill x
        pack $panneau(AcqFC,$visuNo,This).mode.continu.index -side top -fill x

      #--- Definition du sous-panneau "Mode : Series d'images en continu avec intervalle entre chaque serie"
      frame $panneau(AcqFC,$visuNo,This).mode.serie_1
        frame $panneau(AcqFC,$visuNo,This).mode.serie_1.nom -relief ridge -borderwidth 2
           label $panneau(AcqFC,$visuNo,This).mode.serie_1.nom.but -text $caption(acqfc,nom) -pady 0
           pack $panneau(AcqFC,$visuNo,This).mode.serie_1.nom.but -fill x
           entry $panneau(AcqFC,$visuNo,This).mode.serie_1.nom.entr -width 10 -textvariable panneau(AcqFC,$visuNo,nom_image) \
              -font $audace(font,arial_10_b) -relief groove
           pack $panneau(AcqFC,$visuNo,This).mode.serie_1.nom.entr -fill x
           label $panneau(AcqFC,$visuNo,This).mode.serie_1.nom.lab_extension -text $caption(acqfc,extension) -pady 0
           pack $panneau(AcqFC,$visuNo,This).mode.serie_1.nom.lab_extension -fill x -side left
           menubutton $panneau(AcqFC,$visuNo,This).mode.serie_1.nom.extension -textvariable panneau(AcqFC,$visuNo,extension) \
              -menu $panneau(AcqFC,$visuNo,This).mode.serie_1.nom.extension.menu -relief raised
           pack $panneau(AcqFC,$visuNo,This).mode.serie_1.nom.extension -side right -fill x -expand true -ipady 1
           set m [ menu $panneau(AcqFC,$visuNo,This).mode.serie_1.nom.extension.menu -tearoff 0 ]
           foreach extension $conf(list_extension) {
             $m add radiobutton -label "$extension" \
                -indicatoron "1" \
                -value "$extension" \
                -variable panneau(AcqFC,$visuNo,extension) \
                -command " "
           }
        pack $panneau(AcqFC,$visuNo,This).mode.serie_1.nom -side top -fill x
        frame $panneau(AcqFC,$visuNo,This).mode.serie_1.nb -relief ridge -borderwidth 2
           label $panneau(AcqFC,$visuNo,This).mode.serie_1.nb.but -text $caption(acqfc,nombre) -pady 0
           pack $panneau(AcqFC,$visuNo,This).mode.serie_1.nb.but -side left -fill y
           entry $panneau(AcqFC,$visuNo,This).mode.serie_1.nb.entr -width 3 -textvariable panneau(AcqFC,$visuNo,nb_images) \
              -font $audace(font,arial_10_b) -relief groove -justify center
           pack $panneau(AcqFC,$visuNo,This).mode.serie_1.nb.entr -side left -fill x -expand true
        pack $panneau(AcqFC,$visuNo,This).mode.serie_1.nb -side top -fill x
        frame $panneau(AcqFC,$visuNo,This).mode.serie_1.index -relief ridge -borderwidth 2
           label $panneau(AcqFC,$visuNo,This).mode.serie_1.index.lab -text $caption(acqfc,index) -pady 0
           pack $panneau(AcqFC,$visuNo,This).mode.serie_1.index.lab -side top -fill x
           entry $panneau(AcqFC,$visuNo,This).mode.serie_1.index.entr -width 3 -textvariable panneau(AcqFC,$visuNo,index) \
              -font $audace(font,arial_10_b) -relief groove -justify center
           pack $panneau(AcqFC,$visuNo,This).mode.serie_1.index.entr -side left -fill x -expand true
           button $panneau(AcqFC,$visuNo,This).mode.serie_1.index.but -text "1" -width 3 \
              -command "set panneau(AcqFC,$visuNo,index) 1"
           pack $panneau(AcqFC,$visuNo,This).mode.serie_1.index.but -side right -fill x
        pack $panneau(AcqFC,$visuNo,This).mode.serie_1.index -side top -fill x

      #--- Definition du sous-panneau "Mode : Continu avec intervalle entre chaque image"
      frame $panneau(AcqFC,$visuNo,This).mode.continu_1
        frame $panneau(AcqFC,$visuNo,This).mode.continu_1.sauve -relief ridge -borderwidth 2
           checkbutton $panneau(AcqFC,$visuNo,This).mode.continu_1.sauve.case -text $caption(acqfc,enregistrer) \
              -variable panneau(AcqFC,$visuNo,enregistrer)
           pack $panneau(AcqFC,$visuNo,This).mode.continu_1.sauve.case -side left -fill x  -expand true
        pack $panneau(AcqFC,$visuNo,This).mode.continu_1.sauve -side top -fill x
        frame $panneau(AcqFC,$visuNo,This).mode.continu_1.nom -relief ridge -borderwidth 2
           label $panneau(AcqFC,$visuNo,This).mode.continu_1.nom.but -text $caption(acqfc,nom) -pady 0
           pack $panneau(AcqFC,$visuNo,This).mode.continu_1.nom.but -fill x
           entry $panneau(AcqFC,$visuNo,This).mode.continu_1.nom.entr -width 10 -textvariable panneau(AcqFC,$visuNo,nom_image) \
              -font $audace(font,arial_10_b) -relief groove
           pack $panneau(AcqFC,$visuNo,This).mode.continu_1.nom.entr -fill x
           label $panneau(AcqFC,$visuNo,This).mode.continu_1.nom.lab_extension -text $caption(acqfc,extension) -pady 0
           pack $panneau(AcqFC,$visuNo,This).mode.continu_1.nom.lab_extension -fill x -side left
           menubutton $panneau(AcqFC,$visuNo,This).mode.continu_1.nom.extension -textvariable panneau(AcqFC,$visuNo,extension) \
              -menu $panneau(AcqFC,$visuNo,This).mode.continu_1.nom.extension.menu -relief raised
           pack $panneau(AcqFC,$visuNo,This).mode.continu_1.nom.extension -side right -fill x -expand true -ipady 1
           set m [ menu $panneau(AcqFC,$visuNo,This).mode.continu_1.nom.extension.menu -tearoff 0 ]
           foreach extension $conf(list_extension) {
             $m add radiobutton -label "$extension" \
                -indicatoron "1" \
                -value "$extension" \
                -variable panneau(AcqFC,$visuNo,extension) \
                -command " "
           }
        pack $panneau(AcqFC,$visuNo,This).mode.continu_1.nom -side top -fill x
        frame $panneau(AcqFC,$visuNo,This).mode.continu_1.index -relief ridge -borderwidth 2
           label $panneau(AcqFC,$visuNo,This).mode.continu_1.index.lab -text $caption(acqfc,index) -pady 0
           pack $panneau(AcqFC,$visuNo,This).mode.continu_1.index.lab -side top -fill x
           entry $panneau(AcqFC,$visuNo,This).mode.continu_1.index.entr -width 3 -textvariable panneau(AcqFC,$visuNo,index) \
              -font $audace(font,arial_10_b) -relief groove -justify center
           pack $panneau(AcqFC,$visuNo,This).mode.continu_1.index.entr -side left -fill x -expand true
           button $panneau(AcqFC,$visuNo,This).mode.continu_1.index.but -text "1" -width 3 \
              -command "set panneau(AcqFC,$visuNo,index) 1"
           pack $panneau(AcqFC,$visuNo,This).mode.continu_1.index.but -side right -fill x
        pack $panneau(AcqFC,$visuNo,This).mode.continu_1.index -side top -fill x

      #--- Definition du sous-panneau "Mode : Video"
      frame $panneau(AcqFC,$visuNo,This).mode.video -borderwidth 0
        frame $panneau(AcqFC,$visuNo,This).mode.video.nom -relief ridge -borderwidth 2
           label $panneau(AcqFC,$visuNo,This).mode.video.nom.but -text $caption(acqfc,nom) -pady 0
           pack $panneau(AcqFC,$visuNo,This).mode.video.nom.but -fill x -side top
           entry $panneau(AcqFC,$visuNo,This).mode.video.nom.entr -width 10 -textvariable panneau(AcqFC,$visuNo,nom_image) \
              -font $audace(font,arial_10_b) -relief groove
           pack $panneau(AcqFC,$visuNo,This).mode.video.nom.entr -fill x -side top
        pack $panneau(AcqFC,$visuNo,This).mode.video.nom -side top -fill x
        frame $panneau(AcqFC,$visuNo,This).mode.video.index -relief ridge -borderwidth 2
           checkbutton $panneau(AcqFC,$visuNo,This).mode.video.index.case -pady 0 -text $caption(acqfc,index)\
              -variable panneau(AcqFC,$visuNo,indexer)
           pack $panneau(AcqFC,$visuNo,This).mode.video.index.case -side top -fill x
           entry $panneau(AcqFC,$visuNo,This).mode.video.index.entr -width 3 -textvariable panneau(AcqFC,$visuNo,index) \
              -font $audace(font,arial_10_b) -relief groove -justify center
           pack $panneau(AcqFC,$visuNo,This).mode.video.index.entr -side left -fill x -expand true
           button $panneau(AcqFC,$visuNo,This).mode.video.index.but -text "1" -width 3 \
              -command "set panneau(AcqFC,$visuNo,index) 1"
           pack $panneau(AcqFC,$visuNo,This).mode.video.index.but -side right -fill x
        pack $panneau(AcqFC,$visuNo,This).mode.video.index -side top -fill x
        frame $panneau(AcqFC,$visuNo,This).mode.video.show -relief ridge -borderwidth 2
           checkbutton $panneau(AcqFC,$visuNo,This).mode.video.show.case -text $caption(acqfc,show_video) \
              -variable panneau(AcqFC,$visuNo,showvideopreview) \
              -command "::AcqFC::changerVideoPreview $visuNo"
           pack $panneau(AcqFC,$visuNo,This).mode.video.show.case -side left -fill x -expand true
        pack $panneau(AcqFC,$visuNo,This).mode.video.show -side top -fill x

      #--- Definition du sous-panneau "Mode : Video avec intervalle entre chaque video"
      frame $panneau(AcqFC,$visuNo,This).mode.video_1 -borderwidth 0
        frame $panneau(AcqFC,$visuNo,This).mode.video_1.nom -relief ridge -borderwidth 2
           label $panneau(AcqFC,$visuNo,This).mode.video_1.nom.but -text $caption(acqfc,nom) -pady 0
           pack $panneau(AcqFC,$visuNo,This).mode.video_1.nom.but -fill x -side top
           entry $panneau(AcqFC,$visuNo,This).mode.video_1.nom.entr -width 10 -textvariable panneau(AcqFC,$visuNo,nom_image) \
              -font $audace(font,arial_10_b) -relief groove
           pack $panneau(AcqFC,$visuNo,This).mode.video_1.nom.entr -fill x -side top
        pack $panneau(AcqFC,$visuNo,This).mode.video_1.nom -side top -fill x
        frame $panneau(AcqFC,$visuNo,This).mode.video_1.index -relief ridge -borderwidth 2
           label $panneau(AcqFC,$visuNo,This).mode.video_1.index.lab -text $caption(acqfc,index) -pady 0
           pack $panneau(AcqFC,$visuNo,This).mode.video_1.index.lab -side top -fill x
           entry $panneau(AcqFC,$visuNo,This).mode.video_1.index.entr -width 3 -textvariable panneau(AcqFC,$visuNo,index) \
              -font $audace(font,arial_10_b) -relief groove -justify center
           pack $panneau(AcqFC,$visuNo,This).mode.video_1.index.entr -side left -fill x -expand true
           button $panneau(AcqFC,$visuNo,This).mode.video_1.index.but -text "1" -width 3 \
              -command "set panneau(AcqFC,$visuNo,index) 1"
           pack $panneau(AcqFC,$visuNo,This).mode.video_1.index.but -side right -fill x
        pack $panneau(AcqFC,$visuNo,This).mode.video_1.index -side top -fill x
        frame $panneau(AcqFC,$visuNo,This).mode.video_1.show -relief ridge -borderwidth 2
           checkbutton $panneau(AcqFC,$visuNo,This).mode.video_1.show.case -text $caption(acqfc,show_video) \
              -variable panneau(AcqFC,$visuNo,showvideopreview) \
              -command "::AcqFC::changerVideoPreview $visuNo"
           pack $panneau(AcqFC,$visuNo,This).mode.video_1.show.case -side left -fill x -expand true
        pack $panneau(AcqFC,$visuNo,This).mode.video_1.show -side top -fill x
     pack $panneau(AcqFC,$visuNo,This).mode -side top -fill x

      #--- Frame pour l'affichage de l'avancement de l'acqusition
      frame $panneau(AcqFC,$visuNo,This).avancement_acq -borderwidth 2 -relief ridge
        #--- Checkbutton petit deplacement
        checkbutton $panneau(AcqFC,$visuNo,This).avancement_acq.check -highlightthickness 0 \
           -text $caption(acqfc,avancement_acq) -variable panneau(AcqFC,$visuNo,avancement_acq)
        pack $panneau(AcqFC,$visuNo,This).avancement_acq.check -side left -fill x
     pack $panneau(AcqFC,$visuNo,This).avancement_acq -side top -fill x

      #--- Frame petit decalage
      frame $panneau(AcqFC,$visuNo,This).shift -borderwidth 2 -relief ridge
        #--- Checkbutton petit deplacement
        checkbutton $panneau(AcqFC,$visuNo,This).shift.buttonShift -highlightthickness 0 -variable panneau(DlgShift,buttonShift)
        pack $panneau(AcqFC,$visuNo,This).shift.buttonShift -side left -fill x
        #--- Bouton configuration petit deplacement
        button $panneau(AcqFC,$visuNo,This).shift.buttonShiftConfig -text "$caption(acqfc,buttonShiftConfig)" \
           -command "::AcqFC::cmdShiftConfig $visuNo"
        pack $panneau(AcqFC,$visuNo,This).shift.buttonShiftConfig -side right -fill x -expand true
     pack $panneau(AcqFC,$visuNo,This).shift -side top -fill x

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $panneau(AcqFC,$visuNo,This)
}
