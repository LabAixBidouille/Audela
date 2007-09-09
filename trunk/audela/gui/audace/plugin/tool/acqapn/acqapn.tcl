#
# Fichier : acqapn.tcl
# Description : Outil d'acquisition pour APN Nikon CoolPix
# Auteur : Raymond ZACHANTKE
# Mise a jour $Id: acqapn.tcl,v 1.22 2007-09-09 19:24:11 robertdelmas Exp $
#

#============================================================
# Declaration du namespace acqapn
#    initialise le namespace
#============================================================
namespace eval ::acqapn {
   package provide acqapn 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] acqapn.cap ]

   #------------------------------------------------------------
   # getPluginTitle
   #    retourne le titre du plugin dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(acqapn,titre,panneau)"
   }

   #------------------------------------------------------------
   #  getPluginHelp
   #     retourne le nom du fichier d'aide principal
   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "acqapn.htm"
   }

   #------------------------------------------------------------
   # getPluginType
   #    retourne le type de plugin
   #------------------------------------------------------------
   proc getPluginType { } {
      return "tool"
   }

   #------------------------------------------------------------
   # getPluginProperty
   #    retourne la valeur de la propriete
   #
   # parametre :
   #    propertyName : nom de la propriete
   # return : valeur de la propriete ou "" si la propriete n'existe pas
   #------------------------------------------------------------
   proc getPluginProperty { propertyName } {
      switch $propertyName {
         function     { return "acquisition" }
         subfunction1 { return "coolpix" }
         display      { return "panel" }
      }
   }

   #------------------------------------------------------------
   # initPlugin
   #    initialise le plugin
   #------------------------------------------------------------
   proc initPlugin { tkbase } {

   }

   #------------------------------------------------------------
   # createPluginInstance
   #    cree une nouvelle instance de l'outil
   #------------------------------------------------------------
   proc createPluginInstance { { in "" } { visuNo 1 } } {
      createPanel $in.acqapn
      #--- Surveillance de la connexion d'une camera
      ::confVisu::addCameraListener 1 "::acqapn::adaptButVideo"
   }

   #------------------------------------------------------------
   # deletePluginInstance
   #    suppprime l'instance du plugin
   #------------------------------------------------------------
   proc deletePluginInstance { visuNo } {
      #--- Je desactive la surveillance de la connexion d'une camera
      ::confVisu::removeCameraListener 1 "::acqapn::adaptButVideo"
   }

   #------------------------------------------------------------
   # adaptButVideo
   #    adapte le bouton video
   #------------------------------------------------------------
   proc adaptButVideo { { a "" } { b "" } { c "" } } {
      variable This
      global caption panneau

      if { $panneau(acqapn,showvideo) == "1" || $panneau(acqapn,showvideo) == "2" } {
         $This.fra5.video configure -text $caption(acqapn,sw_video,no) -state normal
         set panneau(acqapn,showvideo) "0"
      }
   }

   #------------------------------------------------------------
   # createPanel
   #    prepare la creation de la fenetre de l'outil
   #------------------------------------------------------------
   proc createPanel { this } {
      variable This
      variable compteur_erreur
      global audace caption conf confCam panneau

      set This $this
      set compteur_erreur "1"

      #--- Les repertoires specifiques
      set panneau(acqapn,saveconf) [ file join $audace(rep_plugin) tool acqapn saveconf.log ]
      set panneau(acqapn,saverep)  [ file join $audace(rep_plugin) tool acqapn saverep.log ]
      set panneau(acqapn,savecmd)  [ file join $audace(rep_plugin) tool acqapn savecmd.log ]
      set panneau(acqapn,photopc)  [ file join $audace(rep_plugin) tool acqapn photopc.exe ]

      #--- Chargement de la base de donnees des apn
      set fichier [ file join $audace(rep_plugin) tool acqapn apnbase.tcl ]
      if { [ file exists $fichier ] } { source $fichier }
      set fichier [ file join $audace(rep_plugin) tool acqapn apncode.tcl ]
      if { [ file exists $fichier ] } { source $fichier }

      #--- Creation des infos de configuration (config.ini) si elles n'existent pas
      if {![info exists conf(coolpix,adjust)]}       {set conf(coolpix,adjust)       "Standard"}
      if {![info exists conf(coolpix,baud)]}         {set conf(coolpix,baud)         "115200"}
      if {![info exists conf(coolpix,compression)]}  {set conf(coolpix,compression)  "Basic"}
      #--- dzoom multiplie par 10 ??????
      if {![info exists conf(coolpix,dzoom)]}        {set conf(coolpix,dzoom)        "8"}
      if {![info exists conf(coolpix,exposure)]}     {set conf(coolpix,exposure)     "0.0"}
      if {![info exists conf(coolpix,flash)]}        {set conf(coolpix,flash)        "Off"}
      if {![info exists conf(coolpix,focus)]}        {set conf(coolpix,focus)        "Infinity"}
      if {![info exists conf(coolpix,format)]}       {set conf(coolpix,format)       "VGA"}
      if {![info exists conf(coolpix,lens)]}         {set conf(coolpix,lens)         "Telephoto"}
      if {![info exists conf(coolpix,metering)]}     {set conf(coolpix,metering)     "Center"}
      if {![info exists conf(coolpix,mode)]}         {set conf(coolpix,mode)         "Off"}
      if {![info exists conf(coolpix,model)]}        {set conf(coolpix,model)        "Coolpix-5700"}
      if {![info exists conf(coolpix,whitebalance)]} {set conf(coolpix,whitebalance) "Auto"}

      #--- Initialisation des variables affichees dans la fenetre d'info sur l'APN
      foreach var { camera_id serial_number version battery memory_free } { set confCam(coolpix_init,$var) "-" }
      set confCam(coolpix,nb_images) "-"

      #--- Recuperation de la derniere configuration pour la mise a jour des panneaux 'acqapn' et 'infos'
      ::acqapn::SetOptions

      #--- Initialisation des variables concernant les poses et les images
      ::acqapn::InitVar

      #--- Caracteristiques du panneau
      set panneau(acqapn,titre)           "$caption(acqapn,titre,panneau_1)"

      #--- Texte du bouton 'Video'
      set panneau(acqapn,showvideo)       "0"
      if { [ ::confCam::getPluginProperty [ ::confVisu::getCamItem 1 ] hasVideo ] == "1" } { set panneau(acqapn,showvideo) "1" }
      set panneau(acqapn,initstate)       "0"

      #--- Initialisation des radio et checkbutton
      set panneau(acqapn,intervalle_mini) "20"
      set panneau(acqapn,affichage)       "0"
      set panneau(acqapn,mini)            "image"
      set panneau(acqapn,a_effacer)       "last"

      #--- Les variables de l'outil deduites du modele d'APN
      ::acqapn::ConfigPanneau

      #--- Construction de l'interface graphique
      acqapnBuildIF $This
   }

   #------------------------------------------------------------
   # startTool
   #    affiche la fenetre de l'outil
   #------------------------------------------------------------
   proc startTool { visuNo } {
      variable This

      pack $This -side left -fill y
   }

   #------------------------------------------------------------
   # stopTool
   #    masque la fenetre de l'outil
   #------------------------------------------------------------
   proc stopTool { visuNo } {
      variable This

      pack forget $This
   }

   #
   # ::acqapn::SetOptions
   #--- Fonction appelee au demarrage et par le bouton 'Reinitialiser'
   #--- Specifie les variables confCam(coolpix,...) en rappellant les valeurs memorisees dans config.ini
   #
   proc SetOptions { } {
      global conf confCam

      foreach var { baud } { set confCam(coolpix,$var) $conf(coolpix,$var) }
      foreach var { model adjust compression flash focus format lens\
         metering whitebalance exposure mode dzoom } {
         set confCam(coolpix,$var) $conf(coolpix,$var)
      }
      #--- La combinaison format+compression est etablie et verifiee
      ::acqapn::Resolution
   }

   #
   # ::acqapn::SaveOptions
   #--- Fonction appelee par le bouton 'Memoriser'
   #--- Memorise les valeurs de conf(coolpix,...) dans config.ini
   #
   proc SaveOptions { } {
      global conf confCam

      #--- Verification de la validite de la resolution avant la sauvegarde
      ::acqapn::Resolution
      #--- Sauvegarde si resolution valide
      if { $confCam(coolpix,resolution) > "0" } {
         #---Les seules variables de configuration sauvegardees
         foreach var { baud } { set conf(coolpix,$var) $confCam(coolpix,$var) }
         foreach var { model adjust format compression flash focus format lens\
            metering whitebalance exposure mode dzoom} {
            set conf(coolpix,$var) $confCam(coolpix,$var)
         }
      } else {
         ::acqapn::ErrComm 7
      }
   }

   #
   # ::acqapn::EditOptions
   #--- Fonction appelee par le bouton 'Editer'
   #
   proc EditOptions { reglages } {
      global caption confCam

      if { $reglages=="" } {
         ::console::affiche_saut "$caption(acqapn,msg,edition_selection)\n"
      } elseif { $reglages=="_init" } {
         ::console::affiche_saut "$caption(acqapn,msg,edition_init)\n"
      }
      #---Les variables de configuration confCam // conf
      foreach var { lens flash zoom mode format compression focus metering whitebalance adjust exposure } {
         ::console::affiche_saut "$var : $confCam(coolpix$reglages,$var)\n"
      }
      ::console::affiche_saut "\n"
   }

   #
   # ::acqapn::ShowVideo
   #--- Procedure d'apercu en mode video associee au bouton 'Video'
   #--- Au lancement de l'outil le bouton affiche "Video Connecte"
   #--- Lorsque la connexion est etablie le bouton affiche "Video on", un appui sur "Video on" affiche le viseur
   #--- Lorsque l'image est affichee, le bouton affiche "Video off", un appui sur "Video off" supprime le viseur
   #
   proc ShowVideo { } {
      variable This
      global audace caption conf confCam panneau

      if { $panneau(acqapn,showvideo) == "0" } {

         $This.fra5.video configure -text $caption(acqapn,sw_video,no) -state disabled

         #--- Si aucune camera n'est connectee, appelle la boite Configuration de la camera
         if { [ ::cam::list ] == "" } {
            ::confCam::run
            set conf(webcam,A,longuepose) "0"
            ::confCam::select A webcam
            tkwait window $audace(base).confCam

            #--- Message si ce n'est pas un apn ou une webcam
            if { $audace(camNo) != "0" } {
               if { [ ::confCam::getPluginProperty [ ::confVisu::getCamItem 1 ] hasVideo ] == "0" } {
                  ::acqapn::ErrComm 8
                  $This.fra5.video configure -text $caption(acqapn,sw_video,no) -state normal
               } else {
                  set panneau(acqapn,showvideo) "1"
                  $This.fra5.video configure -text $caption(acqapn,sw_video,on) -state normal
               }
            } else {
               $This.fra5.video configure -text $caption(acqapn,sw_video,no) -state normal
            }

         }

      } elseif { $panneau(acqapn,showvideo) == "1" } {

         #--- Active le mode video
         ::confVisu::setVideo $audace(visuNo) "1"

         #--- On prepare l'action suivante
         set panneau(acqapn,showvideo) "2"
         $This.fra5.video configure -text $caption(acqapn,sw_video,off) -state normal

      } elseif { $panneau(acqapn,showvideo) == "2" } {
         ::acqapn::StopPreview
      }
   }

   #
   # ::acqapn::StopPreview
   #--- Procedure pour arreter le mode video associe au bouton 'Video'
   #
   proc StopPreview { } {
      variable This
      global audace caption panneau

      #--- Arret de la visualisation video
      set panneau(acqapn,showvideo) "1"
      if { $audace(camNo) != "0" } {
         cam$audace(camNo) stopvideoview
      }
      $This.fra5.video configure -text $caption(acqapn,sw_video,on)
   }

   #
   # ::acqapn::Query
   #--- Fonction appelee lors de l'appui sur le bouton 'Connecter'
   #
   proc Query { } {
      variable This
      global audace caption confCam panneau

      #--- On stoppe la video
      if { [ ::confCam::getPluginProperty [ ::confVisu::getCamItem 1 ] hasVideo ] == "1" } { ::acqapn::StopPreview }

      #--- Desactivation des boutons 'Connecter' et 'Video'
      $This.fra4.connect configure -text $caption(acqapn,sw,encours) -command { }
      ::acqapn::ConfigEtat disabled

      #--- Recherche du port serie sur lequel la camera repond
      set port [::acqapn::IdCom]
      if { $port!="no port" && $port!="not found" } {
         set panneau(acqapn,cmd_usb) "-l$port:"
         ::console::affiche_erreur "$confCam(coolpix,model) $caption(acqapn,msg,connect) $port\n"
         ::console::affiche_erreur "$caption(acqapn,msg,apn_baud) $confCam(coolpix,baud)\n"
         ::console::affiche_saut "\n"
         ::confVisu::setCamera "$audace(visuNo)" [ ::confVisu::getCamItem 1 ] "$audace(camNo)" "$confCam(coolpix,model)"
      } else {
         $This.fra4.connect configure -text $caption(acqapn,sw_connect,on) -command { ::coolpix::connect }
         if { $port=="not found" } { set msg 1 } else { set msg 2 }
         ::acqapn::ErrComm $msg
         return
      }

      #--- Commandes secretes
      #id "DIAG RAW" ou "NIKON DIGITAL CAMERA"

      #--- Cree le fichier audace\audace\plugin\tool\acqapn\saveconf.log
      catch { set reponse [exec $panneau(acqapn,photopc) -q $panneau(acqapn,cmd_usb) clock -t -f 3\
         -s $confCam(coolpix,baud) autoshut-host 1800 autoshut-field 1800 id  "NIKON DIGITAL CAMERA" query] } msg
      if {![info exists reponse] || ( [info exists reponse] && $msg!="$reponse" ) } {
         ::acqapn::ErrComm $msg
         $This.fra4.connect configure -text $caption(acqapn,sw_connect,on) -command { ::coolpix::connect }
         return $msg
      }

      set fd [open $panneau(acqapn,saveconf) w]
      puts $fd $reponse
      close $fd

      #--- Lit le contenu du fichier et isole les valeurs interessantes
      set fd [open $panneau(acqapn,saveconf) r]
      while { [eof $fd] !="1" } {
         gets $fd file
         ::acqapn::IdentifyParameter $file "Resolution" resolution 0
         ::acqapn::IdentifyParameter $file "Camera I.D." camera_id 0
         ::acqapn::IdentifyParameter $file "Version" version 0
         ::acqapn::IdentifyParameter $file "Serial No." serial_number 0
         ::acqapn::IdentifyParameter $file "Battery" battery 0
         ::acqapn::IdentifyParameter $file "Free memory" memory_free 0
         ::acqapn::IdentifyParameter $file "Operation mode" mode 2
         ::acqapn::IdentifyParameter $file "Flash" flash 2
         ::acqapn::IdentifyParameter $file "Focus mode" focus 2
         ::acqapn::IdentifyParameter $file "Image adjust" adjust 2
         ::acqapn::IdentifyParameter $file "White balance" whitebalance 2
         ::acqapn::IdentifyParameter $file "Metering mode" metering 2
         ::acqapn::IdentifyParameter $file "Digital zoom mode" dzoom 0
         ::acqapn::IdentifyParameter $file "Shutter adjustment" exposure 0
         ::acqapn::IdentifyParameter $file "Effective zoom" zoom 0
      }
      close $fd

      #--- L'APN est connecte et les infos sont disponibles dans la boite
      set panneau(acqapn,initstate) "1"

      #--- Liste des parametres sur la console
      ::acqapn::EditOptions "_init"

      #--- Nouvelle configuration du panneau
      ::acqapn::Photo
      $This.fra4.connect configure -text $caption(acqapn,sw_connect,off) -command { ::coolpix::deconnect }
      $This.fra2.info configure -font $audace(font,arial_8_b)
      ::acqapn::ConfigEtat normal
   }

   #
   # ::acqapn::Off
   #--- Fonction appelee pour quitter et mettre l'APN en mode Off
   #
   proc Off { } {
      variable This
      variable compteur_erreur
      global audace caption confCam panneau

      #--- Connexion par configuration de la camera si deja connecte
      if { [ $This.fra4.connect cget -text ] == "$caption(acqapn,sw_connect,on)" } {
         return
      }

      #--- Modification du bouton 'Connecter' et desactivation du panneau
      $This.fra4.connect configure -text $caption(acqapn,sw,encours) -command { }
      ::acqapn::ConfigEtat disabled

      #--- Remise en etat des parametres
      catch { exec $panneau(acqapn,photopc) -q $panneau(acqapn,cmd_usb) -s $confCam(coolpix,baud) \
         flash $confCam(coolpix_init,flash)\
         dzoom $confCam(coolpix_init,dzoom)\
         resolution $confCam(coolpix_init,resolution)\
         focus $confCam(coolpix_init,focus)\
         adjust $confCam(coolpix_init,adjust)\
         whitebalance $confCam(coolpix_init,whitebalance)\
         metering $confCam(coolpix_init,code_metering)\
         $panneau(coolpix_init,exposurecmd) $confCam(coolpix_init,code_exposure)\
         mode Off
      } msg

      if { $msg!="" } {
         if { $compteur_erreur == "1" } {
            incr compteur_erreur "1"
            ::acqapn::Off
            return
         } else {
            ::acqapn::ErrComm $msg
            $This.fra4.connect configure -text $caption(acqapn,sw_connect,off) -command { ::coolpix::deconnect }
            set compteur_erreur "1"
            return
         }
      } else {
         set compteur_erreur "1"
      }

      #--- Destruction de la fenetre 'Images' et de la la liste des vues
      if [winfo exists $This.avance] { destroy $This.avance }
      destroy $This.fra4.expose
      if [winfo exists $This.fra4.vues] { destroy $This.fra4.vues }
      if [winfo exists $This.fra4.memory] { destroy $This.fra4.memory }
      destroy $This.fra7
      pack $This.fra4 -side top -fill x

      #--- Modification du flag de la liaison serie et reinitialisation des variables liees aux images et poses
      set panneau(acqapn,initstate) "0"
      ::acqapn::InitVar

      #--- Mise a jour des variables et reconfiguration du bouton de la fenetre '+Infos'
      foreach var { camera_id serial_number version battery memory_free } { set confCam(coolpix_init,$var) "-" }
      set confCam(coolpix,nb_images) "-"
      $This.fra2.info configure -font $audace(font,arial_8_n)
      $This.fra4.connect configure -text $caption(acqapn,sw_connect,on) -command { ::coolpix::connect }
      ::acqapn::ConfigEtat normal

      #--- Impression d'un message
      if { $compteur_erreur == "1" } {
         ::console::affiche_erreur "$confCam(coolpix,model) $caption(acqapn,msg,deconnect)\n"
         ::console::affiche_saut "\n"
      }
   }

   #
   # ::acqapn::Expose
   #--- Fonction appelee lors de l'appui sur le bouton 'Go'
   #
   proc Expose { } {
      variable This
      variable compteur_erreur
      global caption confCam panneau

      #--- Mofification du texte du bouton 'Go' et desactivation du panneau
      $This.fra4.expose configure -text $caption(acqapn,sw,encours)
      ::acqapn::ConfigEtat disabled

      #--- Les champs "temps de pose", "nombre de poses", "delai" et "intervalle"
      #--- ont ete verifies a la saisie, on affine les autres parametres
      set confCam(coolpix,code_metering) [::acqapn::Metering $confCam(coolpix,metering)]
      set confCam(coolpix,dzoom) [::acqapn::Dzoom $confCam(coolpix,lens)]
      ::acqapn::Resolution
      if { $confCam(coolpix,resolution) < "0" } {
         $This.fra4.expose configure -text $caption(acqapn,sw,exposer)
         ::acqapn::ConfigEtat normal
         return
      }

      #--- Si la pose est differee on attend le temps necessaire
      while { $panneau(acqapn,delai)!=0 } {
         after 1000
         incr panneau(acqapn,delai) -1
         update
      }
      update

     # if { $panneau(acqapn,duree_pose)!="auto" } { set confCam(coolpix,duree_pose) "Auto" }

      set time_next "ns"
      set intervalle $panneau(acqapn,intervalle)

      while { $panneau(acqapn,nb_poses) > 0 } {
         set msg ""
         catch {
            exec $panneau(acqapn,photopc) -q $panneau(acqapn,cmd_usb) -s $confCam(coolpix,baud)\
            flash $confCam(coolpix,flash)\
            dzoom $confCam(coolpix,dzoom)\
            resolution $confCam(coolpix,resolution)\
            focus $confCam(coolpix,focus)\
            adjust $confCam(coolpix,adjust)\
            whitebalance $confCam(coolpix,whitebalance)\
            metering $confCam(coolpix,code_metering)\
               $panneau(coolpix_init,exposurecmd) $confCam(coolpix,code_exposure)\
            dzoom 1.0X\
            snapshot mode $confCam(coolpix,mode)
         } msg
         #--- le temps apres la prise de vue
         set time_now [clock seconds]
         #--- le temps estime de la prise de vue
         incr time_now -2
         #--- le temps de la prochaine - 10 secondes semblent un temps mini
         set time_next [ expr (1000000*$intervalle+[clock clicks]-11200000) ]
         #---
         if { $msg!="" } {
            if { $compteur_erreur != "1" } {
               incr compteur_erreur "1"
               ::acqapn::Expose
            } else {
               ::acqapn::ErrComm $msg
               $This.fra4.expose configure -text $caption(acqapn,sw,exposer)
               set compteur_erreur "1"
               return
            }
         } else {
            set compteur_erreur "1"
         }

         #--- Si le LCD de l'APN n'est pas deja eteint,
         #--- on l'eteint apres un delai de 1 seconde
         if { $confCam(coolpix,mode)!="Off" } {
            after 1000
            exec $panneau(acqapn,photopc) -q $panneau(acqapn,cmd_usb) -s $confCam(coolpix,baud) mode Off
         }

         #--- Les parametres avec des erreurs : shutter aperture color zoom

         #--- On decremente le nombre de poses qui reste a prendre
         incr panneau(acqapn,nb_poses) -1
         update

         #--- S'il reste au moins une pose a prendre, on reprogramme l'intervalle
         if { $panneau(acqapn,nb_poses)> "0"} {
            set panneau(acqapn,intervalle) [expr ($time_next - [clock clicks])/1000000]
            while { $panneau(acqapn,intervalle) > "0" } {
               after 1000
               incr panneau(acqapn,intervalle) -1
               update
            }
         }
         set panneau(acqapn,intervalle) $intervalle

         #--- Reinitialisation des variables specifiques aux images
         set panneau(acqapn,imagelist)     ""
         set confCam(coolpix,nb_images)    "0"
         #--- Mise a jour de la liste des images
         ::acqapn::MajList
         ::acqapn::ConfigListeVues
         ::console::affiche_saut "# [$This.fra4.vues get] $caption(acqapn,msg,expose)\
         [clock format $time_now -format "%H:%M:%S" -gmt 1 ].\n\n"
         update
      }

      #--- Affichage du bouton 'Memoire'
      if {[winfo exists $This.fra4.memory]=="0" } {
         Button $This.fra4.memory -borderwidth 4 -text $caption(acqapn,label,avance) -command { ::acqapn::Avance }
         pack $audace(base).acqapn.fra4.memory  -in $audace(base).acqapn.fra4 -anchor center -side bottom -fill x
      }

      #--- Reconfiguration du bouton 'Go' et reactivation du panneau
      $This.fra4.expose configure -text $caption(acqapn,sw,exposer)
      pack $This.fra4 -side top -fill x
      set panneau(acqapn,nb_poses) "1"
      ::acqapn::ConfigEtat normal
   }

   #
   # ::acqapn::EraseCard
   #--- Fonction appelee pour effacer une ou plusieurs photos sur la carte memoire
   #
   proc EraseCard { } {
      variable This
      global caption confCam panneau

      #--- Inactivation des panneaux
      $This.avance.efface.erase configure -text $caption(acqapn,sw,encours)
      ::acqapn::ConfigEtat disabled

      catch { exec $panneau(acqapn,photopc) $panneau(acqapn,cmd_usb) -s $confCam(coolpix,baud)\
         erase$panneau(acqapn,a_effacer) } msg

      if { $msg!="eph_open failed" } {
         if { $panneau(acqapn,a_effacer)=="all" || ($panneau(acqapn,a_effacer)=="last" && $confCam(coolpix,nb_images)=="1") } {

            #--- Message sur la console
            ::console::affiche_saut "# $caption(acqapn,msg,carte) $caption(acqapn,msg,effacee)\n\n"

            #--- Destruction des boites annexes
            destroy $This.avance
            destroy $This.fra4.vues
            pack $This.fra4 -side top -fill x

            #--- Reinitialisation des variables specifiques aux images
            set confCam(coolpix,nb_images) "0"
            set panneau(acqapn,imagelist)  ""
            set panneau(acqapn,imagename)  ""
            set panneau(acqapn,selection)  ""

         } elseif { $panneau(acqapn,a_effacer)=="last" && $confCam(coolpix,nb_images)>"1" } {

            #--- Affichage sur la console de la reference de l'image effacee
            ::console::affiche_saut "# $panneau(acqapn,imagename) $caption(acqapn,msg,effacee)\n\n"

            #--- Mise a jour de la liste des poses
            incr confCam(coolpix,nb_images) -1
            set panneau(acqapn,imagelist) [lrange $panneau(acqapn,imagelist) 0 [expr $confCam(coolpix,nb_images)-1]]
            ::acqapn::ConfigListeVues
         }
      } else {
         ::acqapn::ErrComm $msg
      }

      #--- Activation des commandes de l'outil principal
      if [winfo exists $This.avance.efface.erase] { $This.avance.efface.erase configure -text $caption(acqapn,but,effacer) }
      ::acqapn::ConfigEtat normal
   }

   #
   # ::acqapn::DownloadCard
   #--- Fonction appelee pour charger une image a partir de la carte memoire
   #
   proc DownloadCard { } {
      variable This
      global audace caption conf confCam panneau

      #--- Mise a jour du bouton 'Charger' et activation du panneau
      $This.avance.charge.load configure -text $caption(acqapn,sw,encours)
      ::acqapn::ConfigEtat disabled

      if { $confCam(coolpix,nb_images)!="0" && $confCam(coolpix,nb_images)!="-" } {
         cd "$conf(rep_images)"
         catch { exec $panneau(acqapn,photopc) -q $panneau(acqapn,cmd_usb) -s $confCam(coolpix,baud)\
            "$panneau(acqapn,mini)" $panneau(acqapn,selection) "$panneau(acqapn,imagename)" } msg
         if { $msg=="" } {
            #--- Message sur la console
            ::console::affiche_saut "# $caption(acqapn,label,vue) $panneau(acqapn,selection) $panneau(acqapn,imagename) $caption(acqapn,label,chargee)\n\n"
            #--- Affichage
            if { $panneau(acqapn,affichage)=="1" } {
               cd "$audace(rep_audela)"
               loadima [ file join $conf(rep_images) $panneau(acqapn,imagename) ]
            }
         } else {
            ::acqapn::ErrComm $msg
         }
      }

      #--- Mise a jour du bouton 'Charger' et activation du panneau
      $This.avance.charge.load configure -text $caption(acqapn,but,charger)
      ::acqapn::ConfigEtat normal
   }

   #====================== Tests des entrees ===================================================

   #
   # ::acqapn::IdentifyParameter
   #--- Fonction appelee pour identifier la valeur d'un parametre
   #--- Analyse des infos renvoyees par l'APN
   #
   proc IdentifyParameter { file arg var index} {
      global confCam

      set file0 [lindex [split $file ":"] 0]
      set file1 [lindex [split $file ":"] 1]
      if { [string match $file0 $arg]=="1" } {
         set confCam(coolpix_init,$var)  "[lindex $file1 $index]"
         update
         if { $var=="resolution" } {
            ::acqapn::ReverseResolution
         } elseif { $var=="dzoom" } {
            switch -exact $confCam(coolpix_init,dzoom) {
               0 { set confCam(coolpix_init,lens) "Telephoto" ; set confCam(coolpix_init,dzoom) "8" }
               2 { set confCam(coolpix_init,lens) "Wide" }
               4 { set confCam(coolpix_init,lens) "FishEye" }
            }
         } elseif { $var=="exposure" } {
            set confCam(coolpix_init,exposure) [format "%+1.1f" $confCam(coolpix_init,exposure)]
            ::acqapn::Exposure "_init" [expr $confCam(coolpix_init,exposure)/10]
         } elseif { $var=="metering" } {
            set confCam(coolpix_init,code_metering) [::acqapn::Metering $confCam(coolpix_init,metering)]
         } elseif { $var=="adjust" } {
            if { $confCam(coolpix_init,adjust)=="Auto" } { set confCam(coolpix_init,adjust) "Standard" }
         }
      }
   }

   #
   # ::acqapn::VerifNbPoses
   #--- Fonction appelee pour verifier le nombre de poses
   #
   proc VerifNbPoses { } {
      variable This
      global panneau

      set entier [::acqapn::TestEntier $panneau(acqapn,nb_poses)]
      set verif $entier
      if { $entier=="1" } {
         #--- Si le nombre de poses vaut "0" ou "1"
         if { $panneau(acqapn,nb_poses)=="0" || $panneau(acqapn,nb_poses)=="1" } {
            set panneau(acqapn,intervalle) ""
            pack $This.fra4 -side top -fill x
            if { $panneau(acqapn,nb_poses)=="0" } {
               ::acqapn::ErrComm 9
               set panneau(acqapn,nb_poses) "1"
               set verif "-1"
            }
         } else {
            #--- Le nb d'images est > 1
            set panneau(acqapn,intervalle) $panneau(acqapn,intervalle_mini)
             pack $This.fra4 -side top -fill x
            update
         }
      } else {
         set panneau(acqapn,intervalle) ""
         ::acqapn::ErrComm 10
         pack $This.fra4 -side top -fill x
      }
      return $verif
   }

   #
   # ::acqapn::VerifDelai
   #--- Fonction appelee pour verifier l'entree du delai
   #
   proc VerifDelai { } {
      global panneau

      #--- Si le delai n'est pas valide il est remis a "0"
      if { [::acqapn::TestEntier $panneau(acqapn,delai)]=="0" } {
         set panneau(acqapn,delai) "0"
         ::acqapn::ErrComm 10
      }
   }

   #
   # ::acqapn::VerifIntervalle
   #--- Fonction appelee pour capturer l'intervalle entre les poses
   #
   proc VerifIntervalle { } {
      global panneau

      set erreur 0
      #--- En cas d'erreur l'intervalle est remis au minimum
      #--- Test si l'intervalle est un entier positif
      if { [ ::acqapn::TestEntier $panneau(acqapn,intervalle) ] != "1" } {
         ::acqapn::ErrComm 10
         set erreur 1
      } elseif { [expr $panneau(acqapn,intervalle)-$panneau(acqapn,intervalle_mini)] < "0" } {
         #--- Test si l'intervalle est inferieur au seuil mini
         ::acqapn::ErrComm 11
         set erreur 1
      }
      if { $erreur=="1" } { set panneau(acqapn,intervalle) $panneau(acqapn,intervalle_mini) }
   }

   #
   # ::acqapn::TestValeurs
   #--- Cette procedure verifie que le temps de pose est vide, un nombre entier positif ou est une fraction 1/n
   #
   proc TestValeurs { valeur } {
      global confCam

      set confCam(coolpix,duree_pose) ""
      #--- Si aucune valeur n'est saisie, alors 'Auto'
      if { $valeur=="auto" } {
         set confCam(coolpix,duree_pose) Auto
      } elseif { [::acqapn::TestEntier $valeur]=="1" } {
         #--- Si une valeur est saisie, on teste s'il s'agit d'un entier
         set confCam(coolpix,duree_pose) $valeur
      } elseif { [lindex [split $valeur "/"] 0]=="1" \
         && [::acqapn::TestEntier [lindex [split $valeur "/"] 1]]=="1"} {
         #--- S'il s'agit d'une fraction 1/n, le numerateur vaut 1
         #--- On teste si le denominateur est un entier positif
         set confCam(coolpix,duree_pose) $valeur
      } else {
         ::acqapn::ErrComm 6
      }
   }

   #
   # ::acqapn::TestEntier
   #--- Cette procedure (copiee de Methking) verifie que la chaine passee en argument decrit bien un entier
   #--- Elle retourne 1 si c'est la cas, et 0 si ce n'est pas un entier
   #
   proc TestEntier { valeur } {
      set entier 1
      for { set i 0 } { $i < [string length $valeur] } { incr i } {
         set a [string index $valeur $i]
         if { ![string match {[0-9]} $a] } { set entier 0 }
      }
      if { $valeur == "" } { set entier 0 }
      return $entier
   }

   #
   # ::acqapn::ErrComm
   #--- Procedure d'affichage de messages d'erreur
   #
   proc ErrComm { msg } {
      global caption confCam panneau

      switch -exact $msg {
         "eph_open failed" { set message "$confCam(coolpix,model) $caption(acqapn,msg,pas_detecte)$caption(acqapn,msg,conseil)" }
         "1"         { set message "$confCam(coolpix,model) $caption(acqapn,msg,pas_detecte)$caption(acqapn,msg,conseil)" }
         "2"         { set message "$caption(acqapn,port_serie) $caption(acqapn,msg,pas_detecte)" }
         "3"         { set message "$caption(acqapn,msg,no_resolution)" }
         "4"         { set message "$caption(acqapn,msg,new_dzoom) : $confCam(coolpix,dzoom) " }
         "5"         { set message "$caption(acqapn,msg,new_resolution) : $confCam(coolpix_init,resolution)" }
         "6"         { set message "$caption(acqapn,msg,pose)" }
         "7"         { set message "$caption(acqapn,msg,no_save)" }
         "8"         { set message "$caption(acqapn,no_video_mode)" }
         "9"         { set message "$caption(acqapn,msg,no_pose)" }
         "10"        { set message "$caption(acqapn,msg,indinv)" }
         "11"        { set message "$caption(acqapn,help,intervalle1) $panneau(acqapn,intervalle_mini) \
                           $caption(acqapn,help,unites)\n" }
         "12"        { set message "$caption(acqapn,selviewer)" }
         "13"        { set message "$caption(acqapn,msg,no_fichier)" }
         default     { set message $msg }
      }
      tk_messageBox -title $caption(acqapn,titre,pb) -type ok -message $message
      ::acqapn::ConfigEtat normal
   }

#====================== Fonctions de configuration ===================================================

   #
   # ::acqapn::SetComboBoxList
   #--- Fonction appelee pour configurer une combobox et creer sa liste
   #
   proc SetComboBoxList { this variable } {
      global coolpix_base confCam

      set hauteur [llength $coolpix_base($variable)]
      if { $hauteur > "5" } { set hauteur 5 }
      ComboBox $this -relief sunken -borderwidth 1 -width 14 -editable 0 -height $hauteur \
         -values $coolpix_base($variable)

      #--- Affiche l'element selectionne, sinon le premier element de la liste
      if { ![info exists confCam(coolpix,$variable)] } {
         $this setvalue @0
      } else {
         $this configure -text $confCam(coolpix,$variable)
      }

      #--- Mise a jour dynamique de la couleur
      ::confColor::applyColor $this
   }

   #
   # ::acqapn::InitVar
   #--- Initialisation de quelques variables
   #
   proc InitVar {} {
      global panneau

      #--- Reinitialisation des parametres
      set panneau(acqapn,duree_pose) "auto"
      set panneau(acqapn,nb_poses)   "1"
      set panneau(acqapn,intervalle) ""
      set panneau(acqapn,delai)      "0"

      #--- Reconfiguration de la liste des poses
      set panneau(acqapn,imagelist)  ""
      set panneau(acqapn,imagename)  ""
      set panneau(acqapn,selection)  ""
   }

   #
   # ::acqapn::ConfigEtat
   #--- Fonction de configuration des boutons de l'outil
   #
   proc ConfigEtat { etat } {
      variable This

      foreach var { fra4.connect fra4.expose fra4.vues fra4.memory fra5.video\
         fra7.duree fra7.poses fra7.prog fra7.timer } {
         if [winfo exists $This.$var] { $This.$var configure -state $etat }
      }
      if [winfo exists $This.avance] {
         foreach var { efface.erase efface.choix.dernier efface.choix.toutes \
            charge.load charge.nom charge.view charge.mini } {
            $This.avance.$var configure -state $etat
         }
      }
      update
   }

   #
   # ::acqapn::Formats
   #--- Fonction appelee pour lister les formats supportes
   #
   proc Formats { } {
      global coolpix_base confCam

      if { $confCam(coolpix,model) == "Coolpix-990" } {
         #--- Parametres specifiques au Nikon CoolPix 990
         set coolpix_base(format) " MAX XGA VGA 3:2 "
      } else {
         set coolpix_base(format) " VGA XGA SXGA UXGA 3:2 MAX "
      }
      return $coolpix_base(format)
   }

   #
   # ::acqapn::ConfigPanneau
   #--- Fonction appelee pour adapter l'outil a l'APN
   #
   proc ConfigPanneau { } {
      variable This
      global coolpix_base confCam panneau

      set index [lsearch $coolpix_base(model) $confCam(coolpix,model)]
      foreach var { ccd_size pixel_size H_focus L_focus } {
         set panneau(acqapn,$var) [lindex $coolpix_base($var) $index]
      }
      #--- Formats supportes par le modele choisi
      set coolpix_base(format) [ ::acqapn::Formats ]
      #--- Si la valeur n'est plus dans la liste on prend le premier de la nouvelle liste
      if { ![regexp $confCam(coolpix,format) $coolpix_base(format)] } {
         set confCam(coolpix,format) [lindex $coolpix_base(format) 0]
      }
      #--- Si la fenetre est affichee on change l'affichage
      if { [winfo exists $This.fra3.reglage.var]=="1" && [$This.fra3.reglage.var get]=="format" } {
         $This.fra3.valeur.val configure -values $coolpix_base(format) -text $confCam(coolpix,format)
      }
      update
   }

   #
   # ::acqapn::MajList
   #--- Fonction appelee pour reconstruire une nouvelle liste d'images
   #
   proc MajList { } {
      global coolpix_base confCam panneau

      set file ""
      if { $panneau(acqapn,initstate)=="1" } {

         #--- Mise a jour du nombre de poses en memoire
         catch { set infos [exec $panneau(acqapn,photopc) $panneau(acqapn,cmd_usb) -s $confCam(coolpix,baud) count] } msg
         if { $msg!="" && $msg!="$infos" } { ::acqapn::ErrComm $msg ; return }
         set confCam(coolpix,nb_images) [lindex $infos end]

         if { $confCam(coolpix,nb_images) > "0" } {

            #--- Cree le fichier saverep.log dans audace\audace\plugin\tool\acqapn\saverep.log
            catch { set infos [exec $panneau(acqapn,photopc) $panneau(acqapn,cmd_usb) -s $confCam(coolpix,baud) list] } msg
            if { $msg!="" && $msg!="$infos" } { ::acqapn::ErrComm $msg ; return }
            set rp [open $panneau(acqapn,saverep) w]
            puts $rp $infos
            close $rp

            #--- Recherche les infos sur le nom des images
            set rp [open $panneau(acqapn,saverep) r]
            while { ![eof $rp] } {
               set taille [lindex $file 2]
               set queue [lindex $file end]
               if { $taille >"0" && ( [regexp ".JPG" $queue]=="1" ||[regexp ".jpg" $queue]=="1" ) } {
                  #--- Construit la liste des images
                  lappend panneau(acqapn,imagelist) $queue
               }
               gets $rp file
            }
            close $rp
         }
         #--- Affiche la liste des images dans le panneau
         set coolpix_base(imagelist) $panneau(acqapn,imagelist)
      }
   }

   #
   # ::acqapn::ConfigListeVues
   #--- Procedure de configuration de la combobox de la liste des vues
   #
   proc ConfigListeVues { } {
      variable This
      global audace confCam panneau

      if [winfo exists $This.fra4.vues] { destroy $This.fra4.vues }

      if { $panneau(acqapn,imagelist)!="" && $confCam(coolpix,nb_images) > "0" } {
         #--- Construction et affichage de la liste des vues contenues dans l'appareil photo
         ::acqapn::SetComboBoxList $This.fra4.vues "imagelist"
         pack $audace(base).acqapn.fra4.vues\
            -in $audace(base).acqapn.fra4 -anchor center -side top -padx 2 -pady 4
         $This.fra4.vues configure -state normal -modifycmd {
            set this "$audace(base).acqapn.fra4.vues"
            set index [$this getvalue]
            set panneau(acqapn,selection) [expr $index+1]
            set panneau(acqapn,imagename) [$this get]
         }
         $This.fra4.vues configure -values $panneau(acqapn,imagelist) -font $audace(font,arial_8_n)
         #--- Et affichage du plus recent
         $This.fra4.vues setvalue last
         set panneau(acqapn,imagename) "[$This.fra4.vues get]"
         set panneau(acqapn,selection) "[expr [$This.fra4.vues getvalue]+1]"
         update

         #--- Mise a jour dynamique de la couleur
         ::confColor::applyColor $This
      }
   }

   #
   # ::acqapn::IdCom
   #--- Recherche du port serie sur lequel la camera repond
   #
   proc IdCom { } {
      global audace panneau

      set nb_port [llength $audace(list_com)]
      set essai_port "no_port"
      set port_pas_trouve "1"
      set index 0
      while { $port_pas_trouve=="1" && ( [expr $nb_port-$index]!="0" ) } {
         set msg ""
         set essai_port [lindex $audace(list_com) $index]
         catch { exec $panneau(acqapn,photopc) "-l$essai_port:" -s 115200 clock } msg
         if { $msg!="eph_open failed" } {
            set port_pas_trouve 0
         } else {
            set essai_port "not found"
            incr index 1
         }
      }
      return $essai_port
   }

   #====================== Les fenetres annexes =================================================
   #
   # ::acqapn::Photo
   #--- Complement de l'outil principal
   #
   proc Photo { } {
      variable This
      global audace caption confCam panneau

      #--- Armement du bouton 'GO'
      Button $This.fra4.expose -borderwidth 4 -text $caption(acqapn,sw,exposer)\
         -font $audace(font,arial_8_b) -state normal -command { ::acqapn::Expose }
      pack $audace(base).acqapn.fra4.expose\
         -in $audace(base).acqapn.fra4 -anchor center -side top -fill x

      #---Le bouton 'Memoire' pour ouvrir le boite des reglages avances
      Button $This.fra4.memory -borderwidth 4 -text $caption(acqapn,label,avance)\
         -font $audace(font,arial_8_n) -state normal -command { ::acqapn::Avance }
      pack $audace(base).acqapn.fra4.memory\
         -in $audace(base).acqapn.fra4 -anchor center -side bottom -fill x

      #--- Configuration de la liste des vues
      ::acqapn::MajList
      ::acqapn::ConfigListeVues

      if {$confCam(coolpix,nb_images)=="0"} {
        pack $This.fra4 -side top -fill x
      } else {
        pack $This.fra4 -side top -fill x
      }

      #--- Frame du programme de prise de vues
      frame $This.fra7 -borderwidth 1 -relief groove

      #--- Le label 'Poses'
      label $This.fra7.lab -text $caption(acqapn,label,poses) -font $audace(font,arial_8_b)
      pack $audace(base).acqapn.fra7.lab\
         -in $audace(base).acqapn.fra7 -anchor center -side top

      #--- Le temps de pose
      LabelEntry $This.fra7.duree -borderwidth 1 -relief flat\
         -label $caption(acqapn,poses,duree) -labelfont $audace(font,arial_7_n) \
         -labelanchor w -labelwidth 8 -padx 4 -width 7 -relief sunken\
         -justify right -font $audace(font,arial_8_b) -state normal\
         -textvariable panneau(acqapn,duree_pose) -helptext $caption(acqapn,help,unites)
      pack $audace(base).acqapn.fra7.duree\
         -in $audace(base).acqapn.fra7 -anchor nw -side top -pady 2
      DynamicHelp::add $This.fra7.duree
      $This.fra7.duree bind <Leave> { ::acqapn::TestValeurs $panneau(acqapn,duree_pose) }

      #--- Le nombre de poses a prendre
      LabelEntry $This.fra7.poses -borderwidth 1 -relief flat\
         -label $caption(acqapn,poses,nb) -labelfont $audace(font,arial_7_n) \
         -labelanchor w -labelwidth 8 -padx 4 -width 7 -relief sunken\
         -justify right -font $audace(font,arial_8_b) -state normal\
         -textvariable panneau(acqapn,nb_poses)
      pack $audace(base).acqapn.fra7.poses \
         -in $audace(base).acqapn.fra7 -anchor nw -side top -pady 2
      $This.fra7.poses bind <Leave> { ::acqapn::VerifNbPoses }

      #--- Le delai avant la premiere pose
      LabelEntry $This.fra7.prog -borderwidth 1 -relief flat\
         -label $caption(acqapn,poses,delai) -labelfont $audace(font,arial_7_n) \
         -labelanchor w -labelwidth 8 -padx 4 -width 7 -relief sunken\
         -justify right -font $audace(font,arial_8_b) -state normal\
         -textvariable panneau(acqapn,delai) -helptext $caption(acqapn,help,unites)
      pack $audace(base).acqapn.fra7.prog\
         -in $audace(base).acqapn.fra7 -anchor nw -side top -pady 2
      DynamicHelp::add $This.fra7.prog
      $This.fra7.prog bind <Leave> { ::acqapn::VerifDelai }

      #--- L'intervalle entre poses
      set panneau(acqapn,intervalle) $panneau(acqapn,intervalle_mini)
      LabelEntry $This.fra7.timer -borderwidth 1 -relief flat\
         -label $caption(acqapn,poses,intervalle) -labelfont $audace(font,arial_7_n) \
         -labelanchor w -labelwidth 8 -padx 4 -width 7 -relief sunken\
         -justify right -state normal\
         -textvariable panneau(acqapn,intervalle) -font $audace(font,arial_8_b)\
         -helptext "$caption(acqapn,help,intervalle1)\n$panneau(acqapn,intervalle_mini) $caption(acqapn,help,unites)\n"
      pack $audace(base).acqapn.fra7.timer\
         -in $audace(base).acqapn.fra7 -anchor nw -side top -pady 2
      DynamicHelp::add $This.fra7.timer
      $This.fra7.timer bind <Leave> { ::acqapn::VerifIntervalle }

      pack $This.fra7 -side top -fill x

      #--- Mise a jour dynamique de la couleur
      ::confColor::applyColor $This
   }

   #
   # ::acqapn::PlusInfo
   #--- Fenetre appelee pour afficher les donnees relatives a l'APN
   #
   proc PlusInfo { } {
      variable This
      global audace caption panneau

      if [winfo exists $This.info] { destroy $This.info }

      #--- Creation de la fenetre 'Plus d'info'
      toplevel $This.info
      wm transient $This.info $This
      wm resizable $This.info 0 0
      wm title $This.info "$caption(acqapn,titre,info)"
      set posx_PlusInfo [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
      set posy_PlusInfo [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
      wm geometry $This.info +[ expr $posx_PlusInfo + 130 ]+[ expr $posy_PlusInfo + 85 ]
      wm protocol $This.info WM_DELETE_WINDOW { destroy $audace(base).acqapn.info }

      #--- Indication du constructeur
      LabelFrame $This.info.connect -textvariable confCam(coolpix_init,camera_id)\
         -font $audace(font,arial_8_n) -side left -padx 5
      pack $audace(base).acqapn.info.connect\
         -in $audace(base).acqapn.info -anchor center -side top

      #--- Identification du n� de serie
      LabelFrame $This.info.numser -text $caption(acqapn,info,serial)\
         -font $audace(font,arial_8_n) -side left -padx 5
         label $This.info.numser.num -textvariable confCam(coolpix_init,serial_number) -font $audace(font,arial_8_n)
         pack $audace(base).acqapn.info.numser.num\
            -in $audace(base).acqapn.info.numser -side left
      pack $audace(base).acqapn.info.numser\
         -in $audace(base).acqapn.info -anchor w -side top

      #--- Identification de la version
      LabelFrame $This.info.version -text $caption(acqapn,info,version)\
         -font $audace(font,arial_8_n) -side left -padx 5
         label $This.info.version.num -textvariable confCam(coolpix_init,version) -font $audace(font,arial_8_n)
         pack $audace(base).acqapn.info.version.num\
            -in $audace(base).acqapn.info.version -side left
      pack $audace(base).acqapn.info.version\
         -in $audace(base).acqapn.info -anchor w -side top

      #--- Caracteristiques du CCD
      LabelFrame $This.info.ccd -text $caption(acqapn,info,ccd)\
         -font $audace(font,arial_8_n) -side left -padx 5
         label $This.info.ccd.num -text $panneau(acqapn,ccd_size) -font $audace(font,arial_8_n)
         pack $audace(base).acqapn.info.ccd.num\
            -in $audace(base).acqapn.info.ccd -side left
      pack $audace(base).acqapn.info.ccd\
         -in $audace(base).acqapn.info -anchor w -side top

      #--- Taille des pixels
      LabelFrame $This.info.pixel -text $caption(acqapn,info,pixel)\
         -font $audace(font,arial_8_n) -side left -padx 5
         label $This.info.pixel.size -text $panneau(acqapn,pixel_size) -font $audace(font,arial_8_n)
         pack $audace(base).acqapn.info.pixel.size\
            -in $audace(base).acqapn.info.pixel -side left
         label $This.info.pixel.dim -text $caption(acqapn,info,um) -font $audace(font,arial_8_n)
         pack $audace(base).acqapn.info.pixel.dim\
            -in $audace(base).acqapn.info.pixel -side left
      pack $audace(base).acqapn.info.pixel\
         -in $audace(base).acqapn.info -anchor w -side top -padx 3

      #--- Charge de la batterie
      LabelFrame $This.info.batt -text $caption(acqapn,info,batterie)\
         -font $audace(font,arial_8_n) -side left -padx 5
         label $This.info.batt.size -textvariable confCam(coolpix_init,battery) -font $audace(font,arial_8_n)
         pack $audace(base).acqapn.info.batt.size\
            -in $audace(base).acqapn.info.batt -side left
      pack $audace(base).acqapn.info.batt\
         -in $audace(base).acqapn.info -anchor w -side top -padx 3

      #--- Nombre de photos enregistrees
      LabelFrame $This.info.vues -text $caption(acqapn,info,vues)\
         -font $audace(font,arial_8_n) -side left -padx 5
         label $This.info.vues.size -textvariable confCam(coolpix,nb_images) -font $audace(font,arial_8_n)
         pack $audace(base).acqapn.info.vues.size\
            -in $audace(base).acqapn.info.vues -side left
      pack $audace(base).acqapn.info.vues\
         -in $audace(base).acqapn.info -anchor w -side top -padx 3

      #--- Memoire libre
      LabelFrame $This.info.mem -text $caption(acqapn,info,memoire_libre)\
         -font $audace(font,arial_8_n) -side left -padx 5
         label $This.info.mem.size -textvariable confCam(coolpix_init,memory_free) -font $audace(font,arial_8_n)
         pack $audace(base).acqapn.info.mem.size\
            -in $audace(base).acqapn.info.mem -side left
         label $This.info.mem.dim -text $caption(acqapn,info,unites) -font $audace(font,arial_8_n)
         pack $audace(base).acqapn.info.mem.dim\
            -in $audace(base).acqapn.info.mem -side left
      pack $audace(base).acqapn.info.mem\
         -in $audace(base).acqapn.info -anchor w -side top -padx 3

      #--- Mise a jour dynamique de la couleur
      ::confColor::applyColor $This.info
   }

   #
   # ::acqapn::GesPar
   #--- Fenetre appelee pour afficher les boutons de gestion des parametres
   #
   proc GesPar { } {
      variable This
      global audace caption

      if [winfo exists $This.param] { destroy $This.param }

      #--- Creation de la fenetre 'Gestion des parametres'
      toplevel $This.param
      wm transient $This.param $This
      wm resizable $This.param 1 0
      wm title $This.param "$caption(acqapn,titre,parametres)"
      set posx_GesPar [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
      set posy_GesPar [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
      wm geometry $This.param +[ expr $posx_GesPar + 130 ]+[ expr $posy_GesPar + 360 ]
      wm protocol $This.param WM_DELETE_WINDOW { destroy $audace(base).acqapn.param }

      #--- Le bouton 'Adopter' les options dans le fichier conf
      Button $This.param.adopt -borderwidth 4 -text $caption(acqapn,but,adopter)\
         -state normal -command { ::acqapn::SaveOptions }
      pack $audace(base).acqapn.param.adopt\
         -in $audace(base).acqapn.param -anchor center -side top -fill x
      DynamicHelp::add $This.param.adopt -text $caption(acqapn,help,adopt)

      #--- Le bouton 'Reinitialiser' pour revenir aux options figurant dans conf
      Button $This.param.init -borderwidth 4 -text $caption(acqapn,but,restaurer)\
         -state normal -command { ::acqapn::SetOptions }
      pack $audace(base).acqapn.param.init\
         -in $audace(base).acqapn.param -anchor center -side top -fill x
      DynamicHelp::add $This.param.init -text $caption(acqapn,help,restaure)

      #--- Le bouton 'Editer' la liste des options sur la console
      Button $This.param.edit -borderwidth 4 -text $caption(acqapn,but,editer)\
         -state normal -command { ::acqapn::EditOptions "" }
      pack $audace(base).acqapn.param.edit\
         -in $audace(base).acqapn.param -anchor center -side top -fill x
      DynamicHelp::add $This.param.edit -text $caption(acqapn,help,edit)

      #--- Mise a jour dynamique de la couleur
      ::confColor::applyColor $This.param
   }

   #
   # ::acqapn::Avance
   #--- Fenetre appelee pour les commandes de la fenetre 'Memoire'
   #
   proc Avance { } {
      variable This
      global audace caption conf confCam confgene panneau

      set this $audace(base).acqapn.avance
      if { [winfo exists $this] != "0" } { destroy $This.avance }

      #--- Creation de la fenetre
      toplevel $this
      wm transient $this $This
      wm resizable $this 1 1
      wm title $this $caption(acqapn,titre,avance)
      set posx_Avance [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
      set posy_Avance [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
      wm geometry $this +[ expr $posx_Avance + 130 ]+[ expr $posy_Avance + 490 ]
      wm protocol $this WM_DELETE_WINDOW { destroy $audace(base).acqapn.avance }

      frame $this.efface -borderwidth 2 -relief ridge
      #--- Le bouton 'Effacer' la memoire de l'APN
      Button $this.efface.erase -borderwidth 4 -text $caption(acqapn,but,effacer)\
         -width 20 -command { ::acqapn::EraseCard }
      pack $audace(base).acqapn.avance.efface.erase\
         -in $audace(base).acqapn.avance.efface -anchor center -side top -fill x
      #--- Les radiosbuttons du choix de la commande
      frame $this.efface.choix
         radiobutton $this.efface.choix.dernier -text $caption(acqapn,label,derniere)\
            -variable panneau(acqapn,a_effacer) -value "last"
         pack $audace(base).acqapn.avance.efface.choix.dernier\
            -in $audace(base).acqapn.avance.efface.choix -anchor center -side left
         radiobutton $this.efface.choix.toutes -text $caption(acqapn,label,toutes)\
            -variable panneau(acqapn,a_effacer) -value "all"
         pack $audace(base).acqapn.avance.efface.choix.toutes\
            -in $audace(base).acqapn.avance.efface.choix -anchor center -side right
      pack $audace(base).acqapn.avance.efface.choix\
         -in $audace(base).acqapn.avance.efface -anchor center -side top -fill x
      pack $audace(base).acqapn.avance.efface\
         -in $audace(base).acqapn.avance -fill x

      frame $this.charge -borderwidth 2 -relief ridge
      #--- Le bouton 'Charger' la memoire de l'APN
      Button $this.charge.load -borderwidth 4 -text $caption(acqapn,but,charger)\
         -width 20 -command { ::acqapn::DownloadCard }
      pack $audace(base).acqapn.avance.charge.load\
         -in $audace(base).acqapn.avance.charge -anchor center -side top -fill x
      #--- Le nom de l'image chargee
      LabelEntry $this.charge.nom -borderwidth 1 -relief flat\
         -label $caption(acqapn,poses,nom) -labelfont $audace(font,arial_8_n) -labelanchor w\
         -labelwidth 7 -padx 4 -width 20 -relief sunken -justify right -font $audace(font,arial_8_b)\
         -textvariable panneau(acqapn,imagename) -helptext $caption(acqapn,help,charge)
      pack $audace(base).acqapn.avance.charge.nom\
         -in $audace(base).acqapn.avance.charge -anchor nw -side top -padx 5
      #--- Les options de chargement
      checkbutton $this.charge.view -text $caption(acqapn,label,afficher)\
         -variable panneau(acqapn,affichage) -offvalue "0" -onvalue "1"
      pack $audace(base).acqapn.avance.charge.view\
         -in $audace(base).acqapn.avance.charge -anchor center -side left
      checkbutton $this.charge.mini -text $caption(acqapn,label,mini)\
         -variable panneau(acqapn,mini) -offvalue "image" -onvalue "thumbnail"
      pack $audace(base).acqapn.avance.charge.mini\
         -in $audace(base).acqapn.avance.charge -anchor center -side right
      pack $audace(base).acqapn.avance.charge\
         -in $audace(base).acqapn.avance -fill x

      frame $this.traite -borderwidth 2 -relief ridge
         #--- Creation du bouton 'Traitement avance' l'image
         Button $this.traite.correction -borderwidth 4 -text $caption(acqapn,but,traiter)\
            -width 20 -command {
               if {$conf(edit_viewer)=="" && $panneau(acqapn,affichage)=="1"} {
                  ::acqapn::ErrComm 12
                  set confgene(EditScript,error,viewer) "0"
                  ::confEditScript::run "$audace(base).confEditScript"
               } else {
                  cd "$conf(rep_images)"
                  if { [ file exists $panneau(acqapn,imagename) ]=="1" } {
                     ::audace::lanceViewerImages [ file join $audace(rep_images) $panneau(acqapn,imagename) ]
                  } else {
                     ::acqapn::ErrComm 13
                  }
               }
            }
         pack $audace(base).acqapn.avance.traite.correction\
            -in $audace(base).acqapn.avance.traite -anchor center -side top -fill x
      pack $audace(base).acqapn.avance.traite\
         -in $audace(base).acqapn.avance -fill x

      #--- Mise a jour dynamique de la couleur
      ::confColor::applyColor $this
   }
#====================== Fin des fenetres annexes =================================================
}

#------------------------------------------------------------
# acqapnBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc acqapnBuildIF { This } {
   global coolpix_base audace caption confCam panneau

   frame $This -borderwidth 2 -relief groove
      #--- Frame du titre et du bouton de l'aide
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Titre de l'outil et bouton de l'aide
         button $This.fra1.but1 -borderwidth 2 -text $panneau(acqapn,titre) \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::acqapn::getPluginType ] ] acqapn \
               [ ::acqapn::getPluginHelp ]"
         pack $This.fra1.but1 -in $This.fra1 -anchor center -expand 1 -fill both -side top
         DynamicHelp::add $This.fra1.but1 -text $caption(acqapn,help,titre)

      pack $This.fra1 -side top -fill x

      #--- Frame du modele d'APN connecte
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Label du modele
         ::acqapn::SetComboBoxList $This.fra2.opt_model "model"
         pack $This.fra2.opt_model -in $This.fra2 -anchor center -side top -pady 2
         $This.fra2.opt_model configure -modifycmd {
               set this "$audace(base).acqapn"
               set confCam(coolpix,model) [$this.fra2.opt_model get]
               #--- Mise a jour des valeurs dependantes du modele d'APN dans la boite d'infos
               ::acqapn::ConfigPanneau
               #--- Mise a jour des scales 'zoom' et "correction d'exposition' dans l'outil 'acqapn'
               $this.fra3.zoom.opt_zoom_variant configure -from $panneau(acqapn,L_focus) -to $panneau(acqapn,H_focus)
               set confCam(coolpix,zoom) $panneau(acqapn,L_focus)
               update
            }

         #--- Le bouton 'Infos' pour afficher plus d'infos sur l'APN
         Button $This.fra2.info -borderwidth 4 -text $caption(acqapn,titre,info) -state normal\
            -command { ::acqapn::PlusInfo }
         pack $This.fra2.info -in $This.fra2 -anchor center -side top -fill x

      pack $This.fra2 -side top -fill x

      #--- Frame pour la video
      frame $This.fra5 -borderwidth 1 -relief groove

         #--- Le bouton 'Video'
         button $This.fra5.video -borderwidth 4 -text $caption(acqapn,sw_video,no) -font $audace(font,arial_8_n) \
            -command { ::acqapn::ShowVideo }
         pack $This.fra5.video -in $This.fra5 -anchor center -side top -fill x

         #--- Le Bouton des reglages renvoie vers la configuration des cameras
         button $This.fra5.avance -borderwidth 4 -text $caption(acqapn,label,reglage) \
            -font $audace(font,arial_8_n) -state normal \
            -command {
               ::confCam::run
               ::confCam::select A coolpix
               tkwait window $audace(base).confCam
            }
         pack $This.fra5.avance -in $This.fra5 -anchor center -side top -fill x

      pack $This.fra5 -side top -fill x

      #--- Frame des options (variable et valeurs)
      frame $This.fra3 -borderwidth 1 -relief groove

         #--- Le label 'Options'
         label $This.fra3.lab1 -text $caption(acqapn,label,options) -font $audace(font,arial_8_b)
         pack $This.fra3.lab1 -in $This.fra3 -anchor center -side top -fill x

         #--- Le label 'Variables'
         LabelFrame $This.fra3.reglage -borderwidth 0 -relief groove\
            -text $caption(acqapn,label,reglage) -side top -anchor center
            #--- Construction du combobox des variables
            ::acqapn::SetComboBoxList $This.fra3.reglage.var "variables"
            pack $This.fra3.reglage.var -in $This.fra3.reglage -anchor center -side top -padx 2 -pady 2
            $This.fra3.reglage.var configure -modifycmd  {
               set this "$audace(base).acqapn.fra3"
               #--- Capture de la nouvelle variable affichee
               set panneau(acqapn,variable_affichee) [$this.reglage.var get]
               #--- Configuration de la liste des valeurs specifique de la variable
               $this.valeur.val configure -values $coolpix_base($panneau(acqapn,variable_affichee))
               #--- Affichage de la valeur correspondante
               $this.valeur.val configure -text $confCam(coolpix,$panneau(acqapn,variable_affichee))
            }
         pack $This.fra3.reglage -in $This.fra3 -anchor center -side top -fill x

            #--- Le label 'Valeur'
            LabelFrame $This.fra3.valeur -borderwidth 0 -relief groove\
               -text $caption(acqapn,label,valeur) -side top -anchor center
               #--- Construction du combobox des valeurs utilisables pour la valeur affichee
               #--- Identification de la variable affichee dans le combobox des variables
               set panneau(acqapn,variable_affichee) [$This.fra3.reglage.var get]

               #--- Construction du combobox des valeurs utilisables pour la valeur afichee
               ::acqapn::SetComboBoxList $This.fra3.valeur.val "$panneau(acqapn,variable_affichee)"
               pack $This.fra3.valeur.val -in $This.fra3.valeur -anchor center -side top -padx 2 -pady 2
               $This.fra3.valeur.val configure -text $confCam(coolpix,$panneau(acqapn,variable_affichee))
               $This.fra3.valeur.val configure -modifycmd {
                  set this "$audace(base).acqapn.fra3"
                  #--- Capture de la nouvelle variable modifiee
                  set panneau(acqapn,variable_affichee) [$this.reglage.var get]
                  #--- Recherche de la valeur litterale associee a l'index et mise a jour
                  set confCam(coolpix,$panneau(acqapn,variable_affichee)) [$this.valeur.val get]
                  ::acqapn::VerifData $panneau(acqapn,variable_affichee)
               }
            pack $This.fra3.valeur -in $This.fra3 -anchor center -side top -fill x

            #--- Le zoom
            LabelFrame $This.fra3.zoom -borderwidth 0 -relief groove \
               -text $caption(acqapn,label,zoom) -side top -anchor center
               scale $This.fra3.zoom.opt_zoom_variant -variable confCam(coolpix,zoom)\
                  -orient horizontal -from $panneau(acqapn,L_focus) -to $panneau(acqapn,H_focus) -resolution 1\
                  -borderwidth 2 -width 5 -length 95 -state normal -relief groove\
                  -command { #a faire }
               pack $This.fra3.zoom.opt_zoom_variant -in $This.fra3.zoom -anchor w -side right -padx 5
            pack $This.fra3.zoom -in $This.fra3 -anchor center -side top -fill x

            #--- La correction d'exposition
            LabelFrame $This.fra3.exposure -borderwidth 0 -relief groove\
               -text $caption(acqapn,label,exposition) -side top -anchor center
               scale $This.fra3.exposure.opt_exposure_variant -variable confCam(coolpix,exposure)\
                  -orient horizontal -from -2.0 -to 2.0 -resolution 0.33\
                  -borderwidth 2 -width 5 -length 95 -state normal -relief groove\
                  -command { ::acqapn::Exposure "" }
               pack $This.fra3.exposure.opt_exposure_variant -in $This.fra3.exposure -anchor w -side right -padx 5
            pack $This.fra3.exposure -in $This.fra3 -anchor center -side top -fill x

            #--- Le bouton 'Parametres'
            Button $This.fra3.param -borderwidth 4 -text $caption(acqapn,but,parametres) -state normal\
               -command { ::acqapn::GesPar }
            pack $This.fra3.param -in $This.fra3 -anchor center -side bottom -fill x

      pack $This.fra3 -side top -fill x

      #--- Frame pour la connexion avec l'APN
      frame $This.fra4 -borderwidth 1 -relief groove

         #--- Le label 'Vues'
         label $This.fra4.lab -text $caption(acqapn,label,vues) -font $audace(font,arial_8_b)
         pack $This.fra4.lab -in $This.fra4 -anchor center -side top

         #--- Le bouton 'Connecter'
         button $This.fra4.connect -borderwidth 4 -text $caption(acqapn,sw_connect,on) \
            -font $audace(font,arial_8_b) -state normal -command { ::coolpix::connect }
         pack $This.fra4.connect -in $This.fra4 -anchor center -side top -fill x

      pack $This.fra4 -side top -fill x

      #--- Mise a jour dynamique de la couleur
      ::confColor::applyColor $This
}

