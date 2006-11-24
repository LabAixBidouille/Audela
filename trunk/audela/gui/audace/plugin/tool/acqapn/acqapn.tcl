#
# Fichier : acqapn.tcl
# Description : Panneau d'acquisition APN
# Auteur : Raymond ZACHANTKE
# Mise a jour $Id: acqapn.tcl,v 1.8 2006-11-24 15:46:39 robertdelmas Exp $
#

   package provide acqapn 1.0

   namespace eval ::AcqAPN {
      global audace

      source [ file join $audace(rep_plugin) tool acqapn acqapn.cap ]

      proc Init { { in "" } } {
         createPanel $in.acqapn
      }

      proc createPanel { this } {
         global audace conf confCam caption panneau apn_base
         variable This 
         variable compteur_erreur

         set This $this
         set compteur_erreur "1"

         #--- Les r�pertoires sp�cifiques
         set panneau(AcqAPN,saveconf) [ file join $audace(rep_plugin) tool acqapn saveconf.log ]
         set panneau(AcqAPN,saverep)  [ file join $audace(rep_plugin) tool acqapn saverep.log ]
         set panneau(AcqAPN,savecmd)  [ file join $audace(rep_plugin) tool acqapn savecmd.log ]
         set panneau(AcqAPN,photopc)  [ file join $audace(rep_install) bin photopc.exe ]

         #--- Chargement de la base de donn�es des apn
         set fichier [ file join $audace(rep_plugin) tool acqapn apnbase.tcl ]
         if { [ file exists $fichier ] } { source $fichier }
         set fichier [ file join $audace(rep_plugin) tool acqapn apncode.tcl ]
         if { [ file exists $fichier ] } { source $fichier }

         #--- Cr�ation des infos de configuration (config.ini) si elles n'existent pas
         if {![info exists conf(apn,adjust)]}            {set conf(apn,adjust)       "Standard"}
         if {![info exists conf(apn,baud)]}              {set conf(apn,baud)         "115200"}
         if {![info exists conf(apn,compression)]}       {set conf(apn,compression)  "Basic"}
         #--- dzoom multipli� par 10 ??????
         if {![info exists conf(apn,dzoom)]}             {set conf(apn,dzoom)        "8"}
         if {![info exists conf(apn,exposure)]}          {set conf(apn,exposure)     "0.0"}
         if {![info exists conf(apn,flash)]}             {set conf(apn,flash)        "Off"}
         if {![info exists conf(apn,focus)]}             {set conf(apn,focus)        "Infinity"}
         if {![info exists conf(apn,format)]}            {set conf(apn,format)       "VGA"}
         if {![info exists conf(apn,lens)]}              {set conf(apn,lens)         "Telephoto"}
         if {![info exists conf(apn,metering)]}          {set conf(apn,metering)     "Center"}
         if {![info exists conf(apn,mode)]}              {set conf(apn,mode)         "Off"}
         if {![info exists conf(apn,model)]}             {set conf(apn,model)        "Coolpix-5700"}
         if {![info exists conf(apn,video_scale)]}       {set conf(apn,video_scale)  "2.0"}
         if {![info exists conf(apn,whitebalance)]}      {set conf(apn,whitebalance) "Auto"}

         #--- Initialisation des variables affich�es dans la fen�tre d'info sur l'apn
         foreach var { camera_id serial_number version battery memory_free } { set confCam(apn_init,$var) "-" }
         set confCam(apn,nb_images) "-"

         #--- Recup�ration de la derni�re configuration pour la mise � jour des panneaux 'acqapn' et 'infos'
         ::AcqAPN::SetOptions

         #--- Initialisation des variables concernant les poses et les images
         ::AcqAPN::InitVar	

         #--- Caract�ristiques du panneau
         set panneau(menu_name,AcqAPN) "$caption(acqapn,titre,panneau)"
         #--- Largeur de l'outil en fonction de l'OS
         if { $::tcl_platform(os) == "Linux" } {
            set panneau(AcqAPN,largeur_outil) "130"
         } elseif { $::tcl_platform(os) == "Darwin" } {
            set panneau(AcqAPN,largeur_outil) "130"
         } else {
            set panneau(AcqAPN,largeur_outil) "108"
         }
         set panneau(AcqAPN,large) [ expr $panneau(AcqAPN,largeur_outil) - 8 ]

         #--- Texte du bouton 'Video'
         set panneau(AcqAPN,showvideo)         "0"
         if { [ ::confCam::hasVideo $audace(camNo) ] == "1" } { set panneau(AcqAPN,showvideo) "1" }
         set panneau(AcqAPN,initstate)         "0"

         #--- Initialisation des radio et checkbutton
         set panneau(AcqAPN,intervalle_mini)   "20"
         set panneau(AcqAPN,affichage)         "0"
         set panneau(AcqAPN,mini)              "image"
         set panneau(AcqAPN,a_effacer)         "last"

         #--- Les variables du panneau d�duites du mod�le d'apn
         ::AcqAPN::ConfigPanneau

         #--- Chargement du package tkimgvideo (video pour les webcams sous Windows uniquement)
         if { $::tcl_platform(os) != "Linux" } {
            set result [ catch { package require tkimgvideo } msg ]
            if { $result == "1" } { console::affiche_erreur "$caption(acqapn,no_package)\n" }
         }
         AcqAPNBuildIF $This
      }

      proc startTool { visuNo } {
         variable This

         pack $This -anchor center -expand 0 -fill y -side left
      }

      proc stopTool { visuNo } {
         variable This

         pack forget $This
      }

      #
      # ::AcqAPN::SetOptions
      #--- Fonction appel�e au d�marrage et par le bouton 'R�initialiser'
      #--- Sp�cifie les variables confCam(apn,...) en rappellant les valeurs m�moris�es dans config.ini
      #
      proc SetOptions { } {
         global conf confCam 

         foreach var { baud } { set confCam(apn,$var) $conf(apn,$var) }
        ### foreach var { baud video_port } { set confCam(apn,$var) $conf(apn,$var) }
        ### set confCam(webcam,port) $conf(webcam,port)
         foreach var { video_scale model adjust compression flash focus format lens\
            metering whitebalance exposure mode dzoom } { 
            set confCam(apn,$var) $conf(apn,$var) 
         }
         #--- La combinaison format+compression est �tablie et v�rifi�e
         ::AcqAPN::Resolution
      }

      #
      #::AcqAPN::SaveOptions
      #--- Fonction appel�e par le bouton 'M�moriser'
      #--- M�morise les valeurs de confCam(apn) dans config.ini
      #
      proc SaveOptions { } {
         global conf confCam

         #--- V�rification de la validit� de la r�solution avant la sauvegarde
         ::AcqAPN::Resolution
         #--- Sauvegarde si r�solution valide
         if { $confCam(apn,resolution) > "0" } {
            #---Les seules variables de configuration sauvegard�es
            foreach var { baud } { set conf(apn,$var) $confCam(apn,$var) }
           ### foreach var { baud video_port } { set conf(apn,$var) $confCam(apn,$var) }
           ### set conf(webcam,port) $confCam(webcam,port)
            foreach var { video_scale model adjust format compression flash focus format lens\
               metering whitebalance exposure mode dzoom} {
               set conf(apn,$var) $confCam(apn,$var)
            }
         } else {
               ::AcqAPN::ErrComm 7
         }
      }

      #
      # ::AcqAPN::EditOptions
      #--- Fonction appel�e notamment par le bouton 'Editer'
      #
      proc EditOptions { reglages } {
         global confCam caption

         if { $reglages=="" } {
            console::affiche_saut "\n$caption(acqapn,msg,edition_selection)\n"
         } elseif { $reglages=="_init" } { 
            console::affiche_saut "\n$caption(acqapn,msg,edition_init)\n"
         }
         #---Les variables de configuration confCam // conf
         foreach var { lens flash zoom mode format compression focus metering whitebalance adjust exposure } {
            console::affiche_saut "$var : $confCam(apn$reglages,$var)\n"
         }
      }

      #
      #::AcqAPN::ShowVideo
      #--- Procedure d'apercu en mode video associ�e au bouton 'Video'
      #--- Au lancement du panneau le bouton affiche "Video Connecte"
      #--- Lorsque la connexion est �tablie le bouton affiche "Video on" (resultat d'un nouvel appui sur le bouton)
      #--- Lorsque l'image est affich�e, le bouton affiche "Video off" (resultat d'un nouvel appui sur le bouton)
      #pas v�rifi�
      proc ShowVideo { } {
         global audace conf panneau caption confCam
         variable This

         if { $panneau(AcqAPN,showvideo) == "0" } {

            $This.fra5.video configure -text $caption(acqapn,sw_video,no) -state disabled

            #--- Si aucune cam�ra n'est connect�e, appelle le panneau confcam
            if { [ ::cam::list ] == "" } {
               ::confCam::run 
               tkwait window $audace(base).confCam
            }

            #--- Message si ce n'est pas un apn ou une webcam
            if { [ ::confCam::hasVideo $audace(camNo) ] == "0" } {
               ::AcqAPN::ErrComm 8
               $This.fra5.video configure -text $caption(acqapn,sw_video,no) -state normal
            } else {
               set panneau(AcqAPN,showvideo) "1"
               $This.fra5.video configure -text $caption(acqapn,sw_video,on) -state normal
            }

         } elseif { $panneau(AcqAPN,showvideo) == "1" } {

###--- Debut modif Michel
###               #--- Je supprime l'image precedente
###               image delete image0
###               buf$audace(bufNo) clear
###
###               #--- Je cree une image de type video
###               image create video image0
###
###               #--- Je connecte la sortie de la camera a l'image
###               set result [ catch { cam$audace(camNo) startvideoview 0 } msg ]
###               if { $result == "1" } {
###                  tk_messageBox -title $caption(acqapn,titre,pb) -type ok \
###                     -message "$caption(acqapn,error) $msg"
###                  set panneau(AcqAPN,showvideo) "0"
###
###                  #--- Configuration du bouton 'Video'
###                  $This.fra5.video configure -text $caption(acqapn,sw_video,no) -state normal
###                  return
###               }
###         
###               #--- On grandit l'image
###               image0 configure -scale $confCam(apn,video_scale)

            ::confVisu::setVideo $audace(visuNo) "1"
###--- Fin modif Michel

            #--- On pr�pare l'action suivante
            set panneau(AcqAPN,showvideo) "2"
            $This.fra5.video configure -text $caption(acqapn,sw_video,off) -state normal   

         } elseif { $panneau(AcqAPN,showvideo) == "2" } {
            ::AcqAPN::StopPreview
         }
   }

      #
      #::AcqAPN::StopPreview
      #--- Proc�dure pour arr�ter la video associ�e au bouton 'Video'
      #
      proc StopPreview { } {
         global audace panneau caption
         variable This

         #--- Arret de la visualisation video
###--- Debut modif Michel
###         cam$audace(camNo) stopvideoview
###         image delete image0
###--- Fin modif Michel
         set panneau(AcqAPN,showvideo) "1"
         $This.fra5.video configure -text $caption(acqapn,sw_video,on)
      }

      #
      #::AcqAPN::MajVideo
      #--- Fonction appel�e pour modifier le taux de grossissement de l'image video
      #
      proc MajVideo { g } {
         global confCam 
         global audace

         if { [ ::confCam::hasVideo $audace(camNo) ] == "1" } {
            ::AcqAPN::StopPreview
            ::AcqAPN::ShowVideo
         }
      }

      #
      # ::AcqAPN::Query
      #--- Fonction appel�e lors de l'appui sur le bouton 'Connecter'
      #pas v�rifi�
      proc Query { } {
         global audace confCam caption panneau
         variable This 

         #--- On stoppe la video
         if { [ ::confCam::hasVideo $audace(camNo) ] == "1" } { ::AcqAPN::StopPreview }

         #--- D�sactivation des boutons 'Connecter' et 'Vid�o'
         $This.fra4.connect configure -text $caption(acqapn,sw,encours) -command {}
         ::AcqAPN::ConfigEtat disabled

         #--- Recherche du port s�rie sur lequel la cam�ra r�pond 
         set port [::AcqAPN::IdCom]
         if { $port!="no port" && $port!="not found" } {
            set confCam(apn,serial_port) $port
            set panneau(AcqAPN,cmd_usb)   "-l$port:"
            console::affiche_saut "\n"
            console::affiche_erreur "$confCam(apn,model) $caption(acqapn,msg,connect) $confCam(apn,serial_port)\n"
            console::affiche_erreur "$caption(acqapn,msg,apn_baud) $confCam(apn,baud)\n"
            ::confVisu::setCamera $audace(visuNo) $audace(camNo) "$confCam(apn,model)"
         } else {
            $This.fra4.connect configure -text $caption(acqapn,sw_connect,on) -command { ::AcqAPN::Query }
            if { $port=="not found" } { set msg 1 } else { set msg 2 }
            ::AcqAPN::ErrComm $msg
            return
         }

         #--- Commandes secretes
         #id  "DIAG RAW" ou "NIKON DIGITAL CAMERA"

         #--- Cr�� le fichier audace\audace\plugin\tool\acqapn\saveconf.log
         catch { set reponse [exec $panneau(AcqAPN,photopc) -q $panneau(AcqAPN,cmd_usb) clock -t -f 3\
            -s $confCam(apn,baud) autoshut-host 1800 autoshut-field 1800 id  "NIKON DIGITAL CAMERA" query] } msg
         if {![info exists reponse] || ( [info exists reponse] && $msg!="$reponse" ) } {
            ::AcqAPN::ErrComm $msg
            $This.fra4.connect configure -text $caption(acqapn,sw_connect,on)
            return $msg
         }

         set fd [open $panneau(AcqAPN,saveconf) w]
         puts $fd $reponse
         close $fd

         #--- Lit le contenu du fichier et isole les valeurs int�ressantes
         set fd [open $panneau(AcqAPN,saveconf) r]
         while { [eof $fd] !="1" } {
            gets $fd file
            ::AcqAPN::IdentifyParameter $file "Resolution" resolution 0
            ::AcqAPN::IdentifyParameter $file "Camera I.D." camera_id 0
            ::AcqAPN::IdentifyParameter $file "Version" version 0
            ::AcqAPN::IdentifyParameter $file "Serial No." serial_number 0
            ::AcqAPN::IdentifyParameter $file "Battery" battery 0
            ::AcqAPN::IdentifyParameter $file "Free memory" memory_free 0
            ::AcqAPN::IdentifyParameter $file "Operation mode" mode 2
            ::AcqAPN::IdentifyParameter $file "Flash" flash 2
            ::AcqAPN::IdentifyParameter $file "Focus mode" focus 2
            ::AcqAPN::IdentifyParameter $file "Image adjust" adjust 2
            ::AcqAPN::IdentifyParameter $file "White balance" whitebalance 2
            ::AcqAPN::IdentifyParameter $file "Metering mode" metering 2
            ::AcqAPN::IdentifyParameter $file "Digital zoom mode" dzoom 0
            ::AcqAPN::IdentifyParameter $file "Shutter adjustment" exposure 0
            ::AcqAPN::IdentifyParameter $file "Effective zoom" zoom 0
         }
         close $fd

         #--- L'apn est connect� et les infos sont disponibles dans le panneau
         set panneau(AcqAPN,initstate) "1"

         #--- Liste des param�tres sur la console
         ::AcqAPN::EditOptions "_init"

         #--- Nouvelle configuration du panneau
         ::AcqAPN::Photo
         $This.fra4.connect configure -text $caption(acqapn,sw_connect,off) -command { ::AcqAPN::Off }
         $This.fra2.info configure -font $audace(font,arial_8_b)
         ::AcqAPN::ConfigEtat normal
      }

      #
      # ::AcqAPN::Off
      #--- Fonction appel�e quitter et mettre l'APN en mode Off
      #
      proc Off { } {
         global audace confCam caption panneau
         variable This 
         variable compteur_erreur

         #--- Connexion par configuration de la camera si deja connecte
         if { [ $This.fra4.connect cget -text ] == "$caption(acqapn,sw_connect,on)" } {
            return
         }

         #--- Modification du bouton 'Connecter' et d�sactivation du panneau
         $This.fra4.connect configure -text $caption(acqapn,sw,encours)
         ::AcqAPN::ConfigEtat disabled

         #--- Remise en �tat des param�tres 
         catch { exec $panneau(AcqAPN,photopc) -q $panneau(AcqAPN,cmd_usb) -s $confCam(apn,baud) \
            flash $confCam(apn_init,flash)\
            dzoom $confCam(apn_init,dzoom)\
            resolution $confCam(apn_init,resolution)\
            focus $confCam(apn_init,focus)\
            adjust $confCam(apn_init,adjust)\
            whitebalance $confCam(apn_init,whitebalance)\
            metering $confCam(apn_init,code_metering)\
            $panneau(apn_init,exposurecmd) $confCam(apn_init,code_exposure)\
            mode Off
         } msg

         if { $msg!="" } {
            if { $compteur_erreur == "1" } {
               incr compteur_erreur "1"
               ::AcqAPN::Off
            } else {
               ::AcqAPN::ErrComm $msg
               $This.fra4.connect configure -text $caption(acqapn,sw_connect,off)
               set compteur_erreur "1"
               return
            }
         } else {
            set compteur_erreur "1"
         }

         #--- Destruction de la fen�tre 'Images' et de la la liste des vues
         if [winfo exists $This.avance] { global audace ; destroy $This.avance }
         destroy $This.fra4.expose
         if [winfo exists $This.fra4.vues] { destroy $This.fra4.vues }
         if [winfo exists $This.fra4.memory] { destroy $This.fra4.memory }
         destroy $This.fra7
         place $This.fra4 -x 4 -y 426 -height 50 -width $panneau(AcqAPN,large) -anchor nw -bordermode ignore

         #--- Modification du flag de la liaison s�rie et r�initialisation de variables il�es aux images et poses
         set panneau(AcqAPN,initstate) "0"
         ::AcqAPN::InitVar

         #--- Mise � jour des variables et reconfiguration du bouton de la fen�tre '+Infos'
         foreach var { camera_id serial_number version battery memory_free } { set confCam(apn_init,$var) "-" }
         set confCam(apn,nb_images) "-"
         $This.fra2.info configure -font $audace(font,arial_8_n)
         $This.fra4.connect configure -text $caption(acqapn,sw_connect,on) -command { ::AcqAPN::Query } 
         ::AcqAPN::ConfigEtat normal

         #--- Impression d'un message
         console::affiche_saut "\n"
         console::affiche_erreur "$confCam(apn,model) $caption(acqapn,msg,deconnect)\n"
      }

      #
      #--- ::AcqAPN::Expose
      # Fonction appel�e pour connecter ou d�connecter l'apn
      #
      proc Expose { } {
         global panneau caption confCam
         variable This
         variable compteur_erreur

         #--- Mofification du texte du bouton 'Go' et d�sactivation du panneau
         $This.fra4.expose configure -text $caption(acqapn,sw,encours)
         ::AcqAPN::ConfigEtat disabled

         #--- Les champs "temps de pose", "nombre de poses", "d�lai"
         #--- et "intervalle" ont �t� v�rifi�s � la saisie
         #--- on affine les autres param�tres
         set confCam(apn,code_metering) [::AcqAPN::Metering $confCam(apn,metering)]
         set confCam(apn,dzoom) [::AcqAPN::Dzoom $confCam(apn,lens)]
         ::AcqAPN::Resolution
         if { $confCam(apn,resolution) < "0" } {
            $This.fra4.expose configure -text $caption(acqapn,sw,exposer)
            ::AcqAPN::ConfigEtat normal
            return 
         }

         #--- Si la pose est diff�r�e on attend le temps n�cessaire     
         while { $panneau(AcqAPN,delai)!=0 } {
            after 1000
            incr panneau(AcqAPN,delai) -1
            update
         }
         update

         #if { $panneau(AcqAPN,duree_pose)!="auto" } { set confCam(apn,duree_pose) "Auto" }

         set time_next "ns"
         set intervalle $panneau(AcqAPN,intervalle) 

         while { $panneau(AcqAPN,nb_poses) > 0 } {
            set msg ""
            catch {
               exec $panneau(AcqAPN,photopc) -q $panneau(AcqAPN,cmd_usb) -s $confCam(apn,baud)\
               flash $confCam(apn,flash)\
               dzoom $confCam(apn,dzoom)\
               resolution $confCam(apn,resolution)\
               focus $confCam(apn,focus)\
               adjust $confCam(apn,adjust)\
               whitebalance $confCam(apn,whitebalance)\
               metering $confCam(apn,code_metering)\
                  $panneau(AcqAPN,exposurecmd) $confCam(apn,code_exposure)\
               dzoom 1.0X\
               snapshot mode $confCam(apn,mode)
            } msg
            #--- le temps apr�s la prise de vue
            set time_now [clock seconds]
            #--- le temps estim� de la prise de vue
            incr time_now -2
            #--- le temps de la prochaine - 10 secondes semblent un temps mini
            set time_next [ expr (1000000*$intervalle+[clock clicks]-11200000) ]

            if { $msg!="" } {
               if { $compteur_erreur == "1" } {
                  incr compteur_erreur "1"
                  ::AcqAPN::Expose
               } else {
                  ::AcqAPN::ErrComm $msg
                  $This.fra4.expose configure -text $caption(acqapn,sw,exposer)
                  set compteur_erreur "1"
                  return
               }
            } else {
               set compteur_erreur "1"
            }

            #--- Si le LCD de l'APN n'est pas d�j� �teint, 
            #--- on l'�teint apr�s un d�lai de 1 secondes
            if { $confCam(apn,mode)!="Off" } {
               after 1000 
               exec $panneau(AcqAPN,photopc) -q $panneau(AcqAPN,cmd_usb) -s $confCam(apn,baud) mode Off
            }

            #--- Les param�tres avec des erreurs : shutter aperture color zoom

            #--- On d�cr�mente le nombre de poses qui reste � prendre
            incr panneau(AcqAPN,nb_poses) -1
            update

            #--- S'il reste au moins une pose � prendre, on reprogramme l'intervalle
            if { $panneau(AcqAPN,nb_poses)> "0"} {
               set panneau(AcqAPN,intervalle) [expr ($time_next - [clock clicks])/1000000]
               while { $panneau(AcqAPN,intervalle) > "0" } {
                  after 1000
                  incr panneau(AcqAPN,intervalle) -1
                  update
               }
            }
            set panneau(AcqAPN,intervalle) $intervalle

            #--- R�initialisation des variables sp�cifiques aux images
            set panneau(AcqAPN,imagelist)    ""
            set confCam(apn,nb_images)    "0"
            #--- MAJ de la liste des images
            ::AcqAPN::MajList
            ::AcqAPN::ConfigListeVues
            console::affiche_saut "\n# [$This.fra4.vues get] $caption(acqapn,msg,expose)\
            [clock format $time_now -format "%H:%M:%S" -gmt 1 ]\n"
            update
         }

         #--- Affichage du bouton 'M�moire'
         if {[winfo exists $This.fra4.memory]=="0" } { 
            Button $This.fra4.memory -borderwidth 4 -text $caption(acqapn,label,avance) -command { ::AcqAPN::Avance }
            pack $audace(base).acqapn.fra4.memory  -in $audace(base).acqapn.fra4 -anchor center -side bottom -fill x
         }

         #--- Reconfiguration du bouton 'Go' et r�activation du panneau
         $This.fra4.expose configure -text $caption(acqapn,sw,exposer)
         place $This.fra4 -x 4 -y 426 -height 130 -width $panneau(AcqAPN,large) -anchor nw -bordermode ignore
         set panneau(AcqAPN,nb_poses) "1"
         ::AcqAPN::ConfigEtat normal
      }

      #
      # ::AcqAPN::EraseCard
      #--- Fonction appel�e pour effacer une ou plusieurs photos sur la carte m�moire
      #
      proc EraseCard { } {
         global confCam caption panneau
         variable This

         #--- Inactivation des panneaux
         $This.avance.efface.erase configure -text $caption(acqapn,sw,encours)
         ::AcqAPN::ConfigEtat disabled

         catch { exec $panneau(AcqAPN,photopc) $panneau(AcqAPN,cmd_usb) -s $confCam(apn,baud)\
            erase$panneau(AcqAPN,a_effacer) } msg

         if { $msg!="eph_open failed" } { 
            if { $panneau(AcqAPN,a_effacer)=="all" || ($panneau(AcqAPN,a_effacer)=="last" && $confCam(apn,nb_images)=="1") } {

               #--- Message sur la console
               console::affiche_saut "\n# $caption(acqapn,msg,carte) $caption(acqapn,msg,effacee)\n"

               #--- Destruction du panneau annexe
               destroy $This.avance
               destroy $This.fra4.vues
               place $This.fra4 -x 4 -y 426 -height 78 -width $panneau(AcqAPN,large) -anchor nw -bordermode ignore

               #--- R�initialisation des variables sp�cifiques aux images
               set confCam(apn,nb_images)       "0"
               set panneau(AcqAPN,imagelist)    ""
               set panneau(AcqAPN,imagename)    ""
               set panneau(AcqAPN,selection)    ""

            } elseif { $panneau(AcqAPN,a_effacer)=="last" && $confCam(apn,nb_images)>"1" } {

               #--- Affichage sur la console de la r�f�rence de l'image effac�e
               console::affiche_saut "\n# $panneau(AcqAPN,imagename) $caption(acqapn,msg,effacee)\n"

               #--- Mise � jour de la liste des poses
               incr confCam(apn,nb_images) -1
               set panneau(AcqAPN,imagelist) [lrange $panneau(AcqAPN,imagelist) 0 [expr $confCam(apn,nb_images)-1]]
               ::AcqAPN::ConfigListeVues
            }
         } else {
            ::AcqAPN::ErrComm $msg
         }

         #--- Activation des commandes du panneau principal
         if [winfo exists $This.avance.efface.erase] { $This.avance.efface.erase configure -text $caption(acqapn,but,effacer) }
         ::AcqAPN::ConfigEtat normal
      }

      #
      # ::AcqAPN::DownloadCard
      #--- Fonction appel�e pour charger une image � partir de la carte
      # 
      proc DownloadCard { } {
         global conf audace confCam panneau caption
         variable This

         #--- MAJ du bouton 'Charger' et activation du panneau
         $This.avance.charge.load configure -text $caption(acqapn,sw,encours)
         ::AcqAPN::ConfigEtat disabled

         if { $confCam(apn,nb_images)!="0" && $confCam(apn,nb_images)!="-" } {
            cd "$conf(rep_images)"
            catch { exec $panneau(AcqAPN,photopc) -q $panneau(AcqAPN,cmd_usb) -s $confCam(apn,baud)\
               "$panneau(AcqAPN,mini)" $panneau(AcqAPN,selection) "$panneau(AcqAPN,imagename)" } msg
            if { $msg=="" } {
               #--- Message sur la console
               console::affiche_saut "\n# photo N� $panneau(AcqAPN,selection) $panneau(AcqAPN,imagename) charg�e\n"
               #--- Affichage
               if { $panneau(AcqAPN,affichage)=="1" } {
                  cd "$audace(rep_audela)"
                  loadima [ file join $conf(rep_images) $panneau(AcqAPN,imagename) ]
               }
            } else {
               ::AcqAPN::ErrComm $msg
            }
         }

         #--- MAJ du bouton 'Charger' et activation du panneau
         $This.avance.charge.load configure -text $caption(acqapn,but,charger)
         ::AcqAPN::ConfigEtat normal

      }

      #====================== Tests des entr�es ===================================================

      #
      # ::AcqAPN::IdentifyParameter
      #--- Fonction appel�e pour identifier la valeur d'un parametre
      #--- Analyse des infos renvoy�es par l'apn
      #
      proc IdentifyParameter { file arg var index} {
         global confCam

         set file0 [lindex [split $file ":"] 0]
         set file1 [lindex [split $file ":"] 1]
         if { [string match $file0 $arg]=="1" } {
            set confCam(apn_init,$var)  "[lindex $file1 $index]"
            update
            if { $var=="resolution" } {
               ::AcqAPN::ReverseResolution
            } elseif { $var=="dzoom" } {
               switch -exact $confCam(apn_init,dzoom) {
                  0 { set confCam(apn_init,lens) "Telephoto" ; set confCam(apn_init,dzoom) "8" }
                  2 { set confCam(apn_init,lens) "Wide" }
                  4 { set confCam(apn_init,lens) "FishEye" }
               }
            } elseif { $var=="exposure" } {
               set confCam(apn_init,exposure) [format "%+1.1f" $confCam(apn_init,exposure)]
               ::AcqAPN::Exposure "_init" [expr $confCam(apn_init,exposure)/10]
            } elseif { $var=="metering" } {
               set confCam(apn_init,code_metering) [::AcqAPN::Metering $confCam(apn_init,metering)]
            } elseif { $var=="adjust" } {
               if { $confCam(apn_init,adjust)=="Auto" } { set confCam(apn_init,adjust) "Standard" }
            }
         }
      }

      #
      #::AcqAPN::VerifNbPoses
      #--- Fonction appel�e pour v�rifier le nb de poses
      #
      proc VerifNbPoses { } {
         global panneau
         variable This

         set entier [::AcqAPN::TestEntier $panneau(AcqAPN,nb_poses)]
         set verif $entier
         if { $entier=="1" } {
            #--- Si le nombre de poses vaut "0" ou "1"
            if { $panneau(AcqAPN,nb_poses)=="0" || $panneau(AcqAPN,nb_poses)=="1" } {
               set panneau(AcqAPN,intervalle) ""
               place $This.fra7 -x 4 -y 560 -height 100 -width $panneau(AcqAPN,large) -anchor nw -bordermode ignore
               if { $panneau(AcqAPN,nb_poses)=="0" } {
                  ::AcqAPN::ErrComm 9
                  set panneau(AcqAPN,nb_poses) "1"
                  set verif "-1"
               }
            } else {
               #--- Le nb d'images est > 1
               set panneau(AcqAPN,intervalle) $panneau(AcqAPN,intervalle_mini)
               place $This.fra7 -x 4 -y 560 -height 124 -width $panneau(AcqAPN,large) -anchor nw -bordermode ignore
               update
            }
         } else {
            set panneau(AcqAPN,intervalle) ""
            ::AcqAPN::ErrComm 10
            place $This.fra7 -x 4 -y 560 -height 100 -width $panneau(AcqAPN,large) -anchor nw -bordermode ignore
         }
         return $verif
      }

      #
      #::AcqAPN::VerifDelai
      #--- Fonction appel�e pour v�rifier l'entr�e du d�lai
      #
      proc VerifDelai { } {
         global panneau

         #--- Si le d�lai n'est pas valide il est remis � "0"
         if { [::AcqAPN::TestEntier $panneau(AcqAPN,delai)]=="0" } {
            set panneau(AcqAPN,delai) "0"
            ::AcqAPN::ErrComm 10
         }
      }

      #
      #::AcqAPN::VerifIntervalle
      #--- Fen�tre appel�e pour capturer l'intervalle entre les poses
      #
      proc VerifIntervalle { } {
         global panneau

         set erreur 0
         #--- En cas d'erreur l'intervalle est remis au minimum
         #--- Test si l'intervalle est un entier positif
         if { [ ::AcqAPN::TestEntier $panneau(AcqAPN,intervalle) ] != "1" } {
            ::AcqAPN::ErrComm 10
            set erreur 1
         } elseif { [expr $panneau(AcqAPN,intervalle)-$panneau(AcqAPN,intervalle_mini)] < "0" } {
            #--- Test si l'intervalle est inf�rieur au seuil mini
            ::AcqAPN::ErrComm 11
            set erreur 1
         }
         if { $erreur=="1" } { set panneau(AcqAPN,intervalle) $panneau(AcqAPN,intervalle_mini) }
   }

   #
      #::AcqAPN::TestValeurs
      #--- Cette proc�dure v�rifie que le temps de pose est vide, un nombre entier positif ou est une fraction 1/n
      #
      proc TestValeurs { valeur } {
         global confCam

         set confCam(apn,duree_pose) ""
         #--- Si aucune valeur n'est saisie, alors 'Auto'
         if { $valeur=="auto" } {
            set confCam(apn,duree_pose) Auto
         } elseif { [::AcqAPN::TestEntier $valeur]=="1" } {
            #--- Si une valeur est saisie, on teste s'il s'agit d'un entier
            set confCam(apn,duree_pose) $valeur
         } elseif { [lindex [split $valeur "/"] 0]=="1" \
            && [::AcqAPN::TestEntier [lindex [split $valeur "/"] 1]]=="1"} {
            #--- S'il s'agit d'une fraction 1/n, le num�rateur vaut 1
            #--- On teste si le d�nominateur est un entier positif
            set confCam(apn,duree_pose) $valeur
         } else {
               ::AcqAPN::ErrComm 6
         }
      }

      #
      #::AcqAPN::TestEntier
      #--- Cette proc�dure (copi�e de Methking) v�rifie que la chaine pass�e en argument d�crit bien un entier
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
      #::AcqAPN::ErrComm
      #--- Routine d'affichage de messages d'erreur
      #
      proc ErrComm { msg } {
         global panneau confCam caption

         switch -exact $msg {
            "eph_open failed" { set message "$confCam(apn,model) $caption(acqapn,msg,pas_detecte)$caption(acqapn,msg,conseil)" }
            "1"         { set message "$confCam(apn,model) $caption(acqapn,msg,pas_detecte)$caption(acqapn,msg,conseil)" }
            "2"         { set message "$caption(acqapn,port_serie) $caption(acqapn,msg,pas_detecte)" }
            "3"         { set message "$caption(acqapn,msg,no_resolution)" }
            "4"         { set message "$caption(acqapn,msg,new_dzoom) : $confCam(apn,dzoom) " }
            "5"         { set message "$caption(acqapn,msg,new_resolution) : $confCam(apn_init,resolution)" }
            "6"         { set message "$caption(acqapn,msg,pose)" }
            "7"         { set message "$caption(acqapn,msg,no_save)" }
            "8"         { set message "$caption(acqapn,no_video_mode)" }
            "9"         { set message "$caption(acqapn,msg,no_pose)" }
            "10"        { set message "$caption(acqapn,msg,indinv)" }
            "11"        { set message "$caption(acqapn,help,intervalle1) $panneau(AcqAPN,intervalle_mini) \
                              $caption(acqapn,help,unites)\n" }
            "12"        { set message "$caption(acqapn,selviewer)" }
            "13"        { set message "$caption(acqapn,msg,no_fichier)" }
            default     { set message $msg }
         }
         tk_messageBox -title $caption(acqapn,titre,pb) -type ok -message $message
         ::AcqAPN::ConfigEtat normal
      }

   #====================== Fonctions de configuration ===================================================

      #
      #::AcqAPN::SetComboBoxList
      #--- Fonction appel�e pour configurer un combobox et cr�er sa liste
      #
      proc SetComboBoxList { this variable } {
         global confCam apn_base 

         set hauteur [llength $apn_base($variable)]
         if { $hauteur > "5" } { set hauteur 5 }
         ComboBox $this -relief sunken -borderwidth 1 -width 18 -editable 0 -height $hauteur \
            -values $apn_base($variable)

         #--- Affiche l'�l�ment s�lectionn�, sinon le premier �l�ment de la liste
         if { ![info exists confCam(apn,$variable)] } {
            $this setvalue @0
         } else {
            $this configure -text $confCam(apn,$variable)
         }

         #--- Mise � jour dynamique de la couleur
         ::confColor::applyColor $this
      }

      #
      #::AcqAPN::InitVar
      #--- Initialisation de quelques variables
      #
      proc InitVar {} {
         global panneau

         #--- R�initialisation des param�tres
         set panneau(AcqAPN,duree_pose)   "auto"
         set panneau(AcqAPN,nb_poses)     "1"
         set panneau(AcqAPN,intervalle)   ""
         set panneau(AcqAPN,delai)        "0"
         #--- Reconfiguration de la liste des poses
         set panneau(AcqAPN,imagelist)    ""
         set panneau(AcqAPN,imagename)    ""
         set panneau(AcqAPN,selection)    ""
      }

      #
      #::AcqAPN::ConfigEtat
      #--- Fonction de configuration des boutons du panneau
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
      #::AcqAPN::ConfigPanneau
      #--- Fonction appel�e pour adapter le panneau � l'apn
      #
      proc ConfigPanneau { } {
         global panneau confCam apn_base
         variable This

         set index [lsearch $apn_base(model) $confCam(apn,model)]
         foreach var { ccd_size pixel_size H_focus L_focus } {
            set panneau(AcqAPN,$var) [lindex $apn_base($var) $index]
         }
         if { $confCam(apn,model) == "Coolpix-990" } {
            # *** Parametres specifiques au CoolPix 990 ***
            set apn_base(format) " MAX XGA VGA 3:2 "
         } else {
            set apn_base(format) " VGA XGA SXGA UXGA 3:2 MAX " 
         }
         #--- Si la valeur n'est plus dans la liste on prend le premier de la nouvelle liste
         if { ![regexp $confCam(apn,format) $apn_base(format)] } {
            set confCam(apn,format) [lindex $apn_base(format) 0]
         }
         #--- Si la fen�tre est affich�e on change l'affichage
         if { [winfo exists $This.fra3.reglage.var]=="1" && [$This.fra3.reglage.var get]=="format" } {
            $This.fra3.valeur.val configure -values $apn_base(format) -text $confCam(apn,format)
         }
         update
      }

      #
      #::AcqAPN::MajList
      #--- Fonction appel�e pour reconstruire une nouvelle liste d'images
      #
      proc MajList { } {
         global confCam panneau apn_base

         set file ""
         if { $panneau(AcqAPN,initstate)=="1" } {

            #--- Mise � jour du nombre de poses en m�moire
            catch { set infos [exec $panneau(AcqAPN,photopc) $panneau(AcqAPN,cmd_usb) -s $confCam(apn,baud) count] }  msg       
            if { $msg!="" && $msg!="$infos" } { ::AcqAPN::ErrComm $msg ; return }
            set confCam(apn,nb_images) [lindex $infos end]

            if { $confCam(apn,nb_images) > "0" } {

               #--- Cr�e le fichier saverep.log dans audace\audace\plugin\tool\acqapn\saverep.log
               catch { set infos [exec $panneau(AcqAPN,photopc) $panneau(AcqAPN,cmd_usb) -s $confCam(apn,baud) list] } msg
               if { $msg!="" && $msg!="$infos" } { ::AcqAPN::ErrComm $msg ; return }
               set rp [open $panneau(AcqAPN,saverep) w]
               puts $rp $infos
               close $rp

               #--- Recherche les infos sur le nom des images
               set rp [open $panneau(AcqAPN,saverep) r]
               while { ![eof $rp] } {
                  set taille [lindex $file 2]
                  set queue [lindex $file end]
                  if { $taille >"0" && ( [regexp ".JPG" $queue]=="1" ||[regexp ".jpg" $queue]=="1" ) } {
                     #--- Construit la liste des images
                     lappend panneau(AcqAPN,imagelist) $queue
                  }
                  gets $rp file
               }
               close $rp
            }
            #--- Affiche la liste des images dans le panneau
            set apn_base(imagelist) $panneau(AcqAPN,imagelist)
         }
      }

      #
      #::AcqAPN::ConfigListeVues
      #--- Proc�dure de configuration du combobox de la liste des vues
      #
      proc ConfigListeVues { } {
         global audace confCam panneau
         variable This

         if [winfo exists $This.fra4.vues] { global audace ; destroy $This.fra4.vues }

         if { $panneau(AcqAPN,imagelist)!="" && $confCam(apn,nb_images) > "0" } {
            #--- Construction et affichage de la liste des vues contenues dans l'appareil photo
            ::AcqAPN::SetComboBoxList $This.fra4.vues "imagelist"
            pack $audace(base).acqapn.fra4.vues\
               -in $audace(base).acqapn.fra4 -anchor center -side top -padx 2 -pady 4
            $This.fra4.vues configure -state normal -modifycmd {
               set this "$audace(base).acqapn.fra4.vues"
               set index [$this getvalue]
               set panneau(AcqAPN,selection) [expr $index+1]
               set panneau(AcqAPN,imagename) [$this get]
            }
            $This.fra4.vues configure -values $panneau(AcqAPN,imagelist) -font $audace(font,arial_8_n)
            #--- Et affichage du plus r�cent
            $This.fra4.vues setvalue last
            set panneau(AcqAPN,imagename) "[$This.fra4.vues get]"
            set panneau(AcqAPN,selection) "[expr [$This.fra4.vues getvalue]+1]"
            update

            #--- Mise � jour dynamique de la couleur
            ::confColor::applyColor $This
         }
      }

      #
      #::AcqAPN::IdCom
      #--- Recherche du port s�rie sur lequel la cam�ra r�pond
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
            catch { exec $panneau(AcqAPN,photopc) "-l$essai_port:" -s 115200 clock } msg
            if { $msg!="eph_open failed" } { 
               set port_pas_trouve 0
            } else {
               set essai_port "not found"
               incr index 1
            }
         }
         return $essai_port
      }

      #====================== Les fen�tres annexes =================================================
      #
      #::AcqAPN::Photo
      #--- Compl�ment du panneau principal
      #
      proc Photo { } {
         global audace confCam caption panneau
         variable This

         #--- Armement du bouton 'GO'
         Button $This.fra4.expose -borderwidth 4 -text $caption(acqapn,sw,exposer)\
            -font $audace(font,arial_8_b) -state normal -command { ::AcqAPN::Expose }
         pack $audace(base).acqapn.fra4.expose\
            -in $audace(base).acqapn.fra4 -anchor center -side top -fill x

         #---Le bouton 'M�moire' pour ouvrir le panneau des r�glages avanc�s
         Button $This.fra4.memory -borderwidth 4 -text $caption(acqapn,label,avance)\
            -font $audace(font,arial_8_n) -state normal -command { ::AcqAPN::Avance }
         pack $audace(base).acqapn.fra4.memory\
            -in $audace(base).acqapn.fra4 -anchor center -side bottom -fill x

         #--- Configuration de la liste des vues
         ::AcqAPN::MajList
         ::AcqAPN::ConfigListeVues

         if {$confCam(apn,nb_images)=="0"} {
            place $This.fra4 -x 4 -y 426 -height 78 -width $panneau(AcqAPN,large) -anchor nw -bordermode ignore
         } else {
            place $This.fra4 -x 4 -y 426 -height 130 -width $panneau(AcqAPN,large) -anchor nw -bordermode ignore
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
            -labelanchor w -labelwidth 6 -padx 4 -width 8 -relief sunken\
            -justify right -font $audace(font,arial_8_b) -state normal\
            -textvariable panneau(AcqAPN,duree_pose) -helptext $caption(acqapn,help,unites)
         pack $audace(base).acqapn.fra7.duree\
            -in $audace(base).acqapn.fra7 -anchor nw -side top -pady 4
         DynamicHelp::add $This.fra7.duree
         $This.fra7.duree bind <Leave> { ::AcqAPN::TestValeurs $panneau(AcqAPN,duree_pose) }

         #--- Le nombre de poses � prendre
         LabelEntry $This.fra7.poses -borderwidth 1 -relief flat\
            -label $caption(acqapn,poses,nb) -labelfont $audace(font,arial_7_n) \
            -labelanchor w -labelwidth 11 -padx 4 -width 8 -relief sunken\
            -justify right -font $audace(font,arial_8_b) -state normal\
            -textvariable panneau(AcqAPN,nb_poses) 
         pack $audace(base).acqapn.fra7.poses \
            -in $audace(base).acqapn.fra7 -anchor nw -side top -pady 4
         $This.fra7.poses bind <Leave> { ::AcqAPN::VerifNbPoses }

         #--- Le d�lai avant la premi�re pose
         LabelEntry $This.fra7.prog -borderwidth 1 -relief flat\
            -label $caption(acqapn,poses,delai) -labelfont $audace(font,arial_7_n) \
            -labelanchor w -labelwidth 6 -padx 4 -width 8 -relief sunken\
            -justify right -font $audace(font,arial_8_b) -state normal\
            -textvariable panneau(AcqAPN,delai) -helptext $caption(acqapn,help,unites)
         pack $audace(base).acqapn.fra7.prog\
            -in $audace(base).acqapn.fra7 -anchor nw -side top -pady 4
         DynamicHelp::add $This.fra7.prog
         $This.fra7.prog bind <Leave> { ::AcqAPN::VerifDelai }

         #--- Le timer
         set panneau(AcqAPN,intervalle) $panneau(AcqAPN,intervalle_mini)
         LabelEntry $This.fra7.timer -borderwidth 1 -relief flat\
            -label $caption(acqapn,poses,intervalle) -labelfont $audace(font,arial_7_n) \
            -labelanchor w -labelwidth 6 -padx 4 -width 8 -relief sunken\
            -justify right -state normal\
            -textvariable panneau(AcqAPN,intervalle) -font $audace(font,arial_8_b)\
            -helptext "$caption(acqapn,help,intervalle1)\n$panneau(AcqAPN,intervalle_mini) $caption(acqapn,help,unites)\n"
         pack $audace(base).acqapn.fra7.timer\
            -in $audace(base).acqapn.fra7 -anchor nw -side top -pady 4
         DynamicHelp::add $This.fra7.timer
         $This.fra7.timer bind <Leave> { ::AcqAPN::VerifIntervalle }

         place $This.fra7 -x 4 -y 560 -height 100 -width $panneau(AcqAPN,large) -anchor nw -bordermode ignore

         #--- Mise � jour dynamique de la couleur
         ::confColor::applyColor $This
   }

      #
      #::AcqAPN::PlusInfo
      #--- Fen�tre appel�e pour afficher les donn�es relatives � l'apn
      #
      proc PlusInfo { } {
         global audace caption panneau
         variable This

         if [winfo exists $This.info] { global audace ; destroy $This.info }

         #--- Creation de la fenetre 'Plus d'info'
         toplevel $This.info
         wm transient $This.info $This
         wm resizable $This.info 0 0
         wm title $This.info "$caption(acqapn,titre,info)"
         set posx_PlusInfo [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
         set posy_PlusInfo [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
         wm geometry $This.info +[ expr $posx_PlusInfo + 120 ]+[ expr $posy_PlusInfo + 90 ]
         wm protocol $This.info WM_DELETE_WINDOW { destroy $audace(base).acqapn.info }

         #--- Indication du constructeur
         LabelFrame $This.info.connect -textvariable confCam(apn_init,camera_id)\
            -font $audace(font,arial_8_n) -side left -padx 5
         pack $audace(base).acqapn.info.connect\
            -in $audace(base).acqapn.info -anchor center -side top

         #--- Identification du n� de s�rie
         LabelFrame $This.info.numser -text $caption(acqapn,info,serial)\
            -font $audace(font,arial_8_n) -side left -padx 5 
            label $This.info.numser.num -textvariable confCam(apn_init,serial_number) -font $audace(font,arial_8_n)
            pack $audace(base).acqapn.info.numser.num\
               -in $audace(base).acqapn.info.numser -side left
         pack $audace(base).acqapn.info.numser\
            -in $audace(base).acqapn.info -anchor w -side top

         #--- Identification de la version
         LabelFrame $This.info.version -text $caption(acqapn,info,version)\
            -font $audace(font,arial_8_n) -side left -padx 5 
            label $This.info.version.num -textvariable confCam(apn_init,version) -font $audace(font,arial_8_n)
            pack $audace(base).acqapn.info.version.num\
               -in $audace(base).acqapn.info.version -side left
         pack $audace(base).acqapn.info.version\
            -in $audace(base).acqapn.info -anchor w -side top

         #--- Caract�ristiques du CCD
         LabelFrame $This.info.ccd -text $caption(acqapn,info,ccd)\
            -font $audace(font,arial_8_n) -side left -padx 5
            label $This.info.ccd.num -text $panneau(AcqAPN,ccd_size) -font $audace(font,arial_8_n)
            pack $audace(base).acqapn.info.ccd.num\
               -in $audace(base).acqapn.info.ccd -side left
         pack $audace(base).acqapn.info.ccd\
            -in $audace(base).acqapn.info -anchor w -side top

         #--- Taille des pixels
         LabelFrame $This.info.pixel -text $caption(acqapn,info,pixel)\
            -font $audace(font,arial_8_n) -side left -padx 5
            label $This.info.pixel.size -text $panneau(AcqAPN,pixel_size) -font $audace(font,arial_8_n)
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
            label $This.info.batt.size -textvariable confCam(apn_init,battery) -font $audace(font,arial_8_n)
            pack $audace(base).acqapn.info.batt.size\
               -in $audace(base).acqapn.info.batt -side left
         pack $audace(base).acqapn.info.batt\
            -in $audace(base).acqapn.info -anchor w -side top -padx 3

         #--- Nombre de photos enregistr�es
         LabelFrame $This.info.vues -text $caption(acqapn,info,vues)\
            -font $audace(font,arial_8_n) -side left -padx 5
            label $This.info.vues.size -textvariable confCam(apn,nb_images) -font $audace(font,arial_8_n)
            pack $audace(base).acqapn.info.vues.size\
               -in $audace(base).acqapn.info.vues -side left
         pack $audace(base).acqapn.info.vues\
            -in $audace(base).acqapn.info -anchor w -side top -padx 3

         #--- M�moire libre
         LabelFrame $This.info.mem -text $caption(acqapn,info,memoire_libre)\
            -font $audace(font,arial_8_n) -side left -padx 5
            label $This.info.mem.size -textvariable confCam(apn_init,memory_free) -font $audace(font,arial_8_n)
            pack $audace(base).acqapn.info.mem.size\
               -in $audace(base).acqapn.info.mem -side left
            label $This.info.mem.dim -text $caption(acqapn,info,unites) -font $audace(font,arial_8_n)
            pack $audace(base).acqapn.info.mem.dim\
               -in $audace(base).acqapn.info.mem -side left
         pack $audace(base).acqapn.info.mem\
            -in $audace(base).acqapn.info -anchor w -side top -padx 3

         #--- Mise � jour dynamique de la couleur
         ::confColor::applyColor $This.info
      }

      #
      #::AcqAPN::GesPar
      #--- Fen�tre appel�e pour afficher les boutons de gestion des param�tres
      #
      proc GesPar { } {
         global audace caption panneau
         variable This

         if [winfo exists $This.param] { global audace ; destroy $This.param }

         #--- Creation de la fenetre 'Gestion des param�tres'
         toplevel $This.param
         wm transient $This.param $This
         wm resizable $This.param 1 0
         wm title $This.param "$caption(acqapn,titre,parametres)"
         set posx_GesPar [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
         set posy_GesPar [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
         wm geometry $This.param +[ expr $posx_GesPar + 120 ]+[ expr $posy_GesPar + 438 ]
         wm protocol $This.param WM_DELETE_WINDOW { destroy $audace(base).acqapn.param }

         #--- Le bouton 'Adopter' les options dans le fichier conf
         Button $This.param.adopt -borderwidth 4 -text $caption(acqapn,but,adopter)\
            -state normal -command { ::AcqAPN::SaveOptions } 
         pack $audace(base).acqapn.param.adopt\
            -in $audace(base).acqapn.param -anchor center -side top -fill x
         DynamicHelp::add $This.param.adopt -text $caption(acqapn,help,adopt)
         
         #--- Le bouton 'R�initialiser' pour revenir aux options figurant dans conf
         Button $This.param.init -borderwidth 4 -text $caption(acqapn,but,restaurer)\
            -state normal -command { ::AcqAPN::SetOptions }
         pack $audace(base).acqapn.param.init\
            -in $audace(base).acqapn.param -anchor center -side top -fill x
         DynamicHelp::add $This.param.init -text $caption(acqapn,help,restaure)

         #--- Le bouton 'Editer' la liste des options sur la console
         Button $This.param.edit -borderwidth 4 -text $caption(acqapn,but,editer)\
            -state normal -command { ::AcqAPN::EditOptions "" }
         pack $audace(base).acqapn.param.edit\
            -in $audace(base).acqapn.param -anchor center -side top -fill x
         DynamicHelp::add $This.param.edit -text $caption(acqapn,help,edit)

         #--- Mise � jour dynamique de la couleur
         ::confColor::applyColor $This.param
   }

      #
      #::AcqAPN::Avance
      #--- Fen�tre appel�e pour des commandes 'M�moire'
      #
      proc Avance { } {
         global audace conf caption panneau confCam confgene
         variable This

         set this $audace(base).acqapn.avance
         if { [winfo exists $this] && $confCam(apn,nb_images)!="0" } { global audace ; destroy $This.avance }

         #--- Creation de la fenetre
         toplevel $this
         wm transient $this $This
         wm resizable $this 1 1
         wm title $this $caption(acqapn,titre,avance)
         set posx_Avance [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
         set posy_Avance [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
         wm geometry $this +[ expr $posx_Avance + 120 ]+[ expr $posy_Avance + 570 ]
         wm protocol $this WM_DELETE_WINDOW { destroy $audace(base).acqapn.avance }

         frame $this.efface -borderwidth 2 -relief ridge 
         #--- Le bouton 'Effacer' la m�moire de l'apn
         Button $this.efface.erase -borderwidth 4 -text $caption(acqapn,but,effacer)\
            -width 20 -command { ::AcqAPN::EraseCard }
         pack $audace(base).acqapn.avance.efface.erase\
            -in $audace(base).acqapn.avance.efface -anchor center -side top -fill x
         #--- Les radiosbuttons du choix de la commande
         frame $this.efface.choix
            radiobutton $this.efface.choix.dernier -text "derni�re"\
               -variable panneau(AcqAPN,a_effacer) -value "last"
            pack $audace(base).acqapn.avance.efface.choix.dernier\
               -in $audace(base).acqapn.avance.efface.choix -anchor center -side left
            radiobutton $this.efface.choix.toutes -text "toutes"\
               -variable panneau(AcqAPN,a_effacer) -value "all"
            pack $audace(base).acqapn.avance.efface.choix.toutes\
               -in $audace(base).acqapn.avance.efface.choix -anchor center -side right
         pack $audace(base).acqapn.avance.efface.choix\
            -in $audace(base).acqapn.avance.efface -anchor center -side top -fill x
         pack $audace(base).acqapn.avance.efface\
            -in $audace(base).acqapn.avance -fill x

         frame $this.charge -borderwidth 2 -relief ridge
         #--- Le bouton 'Charger' la m�moire de l'apn
         Button $this.charge.load -borderwidth 4 -text $caption(acqapn,but,charger)\
            -width 20 -command { ::AcqAPN::DownloadCard } 
         pack $audace(base).acqapn.avance.charge.load\
            -in $audace(base).acqapn.avance.charge -anchor center -side top -fill x
         #--- Le nom de l'image charg�e
         LabelEntry $this.charge.nom -borderwidth 1 -relief flat\
            -label $caption(acqapn,poses,nom) -labelfont $audace(font,arial_8_n) -labelanchor w\
            -labelwidth 7 -padx 4 -width 20 -relief sunken -justify right -font $audace(font,arial_8_b)\
            -textvariable panneau(AcqAPN,imagename) -helptext $caption(acqapn,help,charge)
         pack $audace(base).acqapn.avance.charge.nom\
            -in $audace(base).acqapn.avance.charge -anchor nw -side top -padx 5
         #--- Les options de chargement      
         checkbutton $this.charge.view -text $caption(acqapn,label,afficher)\
            -variable panneau(AcqAPN,affichage) -offvalue "0" -onvalue "1"
         pack $audace(base).acqapn.avance.charge.view\
            -in $audace(base).acqapn.avance.charge -anchor center -side left
         checkbutton $this.charge.mini -text $caption(acqapn,label,mini)\
            -variable panneau(AcqAPN,mini) -offvalue "image" -onvalue "thumbnail"
         pack $audace(base).acqapn.avance.charge.mini\
            -in $audace(base).acqapn.avance.charge -anchor center -side right
         pack $audace(base).acqapn.avance.charge\
            -in $audace(base).acqapn.avance -fill x

         frame $this.traite -borderwidth 2 -relief ridge    
            #--- Cr�ation du bouton 'Traitement avanc�' l'image
         Button $this.traite.correction -borderwidth 4 -text $caption(acqapn,but,traiter)\
            -width 20 -command {
               if {$conf(edit_viewer)=="" && $panneau(AcqAPN,affichage)=="1"} {
                  ::AcqAPN::ErrComm 12
                  set confgene(EditScript,error,viewer) "0"
                  ::confEditScript::run "$audace(base).confEditScript"
               } else {
                  cd "$conf(rep_images)"
                  if { [ file exists $panneau(AcqAPN,imagename) ]=="1" } {
                     ::audace::Lance_viewer_images_apn $panneau(AcqAPN,imagename)
                  } else {
                     ::AcqAPN::ErrComm 13
                  }
               }
            }
         pack $audace(base).acqapn.avance.traite.correction\
            -in $audace(base).acqapn.avance.traite -anchor center -side top -fill x
         pack $audace(base).acqapn.avance.traite\
            -in $audace(base).acqapn.avance -fill x

         #--- Mise � jour dynamique de la couleur
         ::confColor::applyColor $this
      }
#====================== Fin des fen�tres annexes =================================================
}

   proc AcqAPNBuildIF { This } {
      global audace panneau confCam caption apn_base

      frame $This -borderwidth 2 -relief groove -height 75 -width $panneau(AcqAPN,largeur_outil)
         #--- Frame du titre et du bouton de l'aide
         frame $This.fra1 -borderwidth 2 -relief groove

            #--- Titre de l'outil et bouton de l'aide
            button $This.fra1.but1 -borderwidth 2 -text $panneau(menu_name,AcqAPN) \
               -command {
                  ::audace::showHelpPlugin tool acqapn acqapn.htm
               }
            pack $This.fra1.but1 -in $This.fra1 -anchor center -expand 1 -fill both -side top
            DynamicHelp::add $This.fra1.but1 -text $caption(acqapn,help,titre)

         place $This.fra1 -x 4 -y 4 -height 22 -width $panneau(AcqAPN,large) -anchor nw -bordermode ignore

         #--- Frame du mod�le d'APN connect�
         frame $This.fra2 -borderwidth 1 -relief groove

            #--- Label du mod�le
            ::AcqAPN::SetComboBoxList $This.fra2.opt_model "model"
            pack $This.fra2.opt_model -in $This.fra2 -anchor center -side top -pady 2
            $This.fra2.opt_model configure -modifycmd {
                  set this "$audace(base).acqapn"
                  set confCam(apn,model) [$this.fra2.opt_model get]
                  #--- Mise � jour des valeurs d�pendantes du mod�le d'apn dans le panneau d'infos
                  ::AcqAPN::ConfigPanneau
                  #--- Mise � jour des scale 'zoom' et "correction d'exposition' dans le panneau 'acqapn'
                  $this.fra3.zoom.opt_zoom_variant configure -from $panneau(AcqAPN,L_focus) -to $panneau(AcqAPN,H_focus)
                  set confCam(apn,zoom) $panneau(AcqAPN,L_focus)
                  update
               }

            #--- Le bouton 'Infos' pour afficher plus d'infos sur l'APN
            Button $This.fra2.info -borderwidth 4 -text $caption(acqapn,titre,info) -state normal\
               -command { ::AcqAPN::PlusInfo }
            pack $This.fra2.info -in $This.fra2 -anchor center -side top -fill x

         place $This.fra2 -x 4 -y 28 -height 50 -width $panneau(AcqAPN,large) -anchor nw -bordermode ignore

         #--- Frame pour la video
         frame $This.fra5 -borderwidth 1 -relief groove

            #--- Le bouton 'Video'
            button $This.fra5.video -borderwidth 4 -text $caption(acqapn,sw_video,no) -font $audace(font,arial_8_n) \
               -command { ::AcqAPN::ShowVideo }
            pack $This.fra5.video -in $This.fra5 -anchor center -side top -fill x

            #--- Le Bouton des r�glages renvoie vers ConfCam
            button $This.fra5.avance -borderwidth 4 -text $caption(acqapn,label,reglage) \
               -font $audace(font,arial_8_n) -state normal \
               -command { ::confCam::run ; tkwait window $audace(base).confCam }
            pack $This.fra5.avance -in $This.fra5 -anchor center -side top -fill x 

            #--- Definition de l'echelle de l'image video
            LabelFrame $This.fra5.scale -borderwidth 0 -relief groove \
               -text $caption(acqapn,label,scale) -side top -anchor center
               scale $This.fra5.scale.opt_scale_variant -variable confCam(apn,video_scale)\
                  -orient horizontal -from 1 -to 4 -resolution 0.1\
                  -borderwidth 2 -width 5 -length 95 -state normal -relief groove\
                  -command { catch { ::AcqAPN::MajVideo $confCam(apn,video_scale) } }
               pack $This.fra5.scale.opt_scale_variant -in $This.fra5.scale -anchor w -side right -padx 5
            pack $This.fra5.scale -in $This.fra5 -anchor center -side top -fill x

         place $This.fra5 -x 4 -y 82 -height 106 -width $panneau(AcqAPN,large) -anchor nw -bordermode ignore
      
         #--- Frame des options (variable et valeurs)
         frame $This.fra3 -borderwidth 1 -relief groove
            #--- Le label 'Options'
            label $This.fra3.lab1 -text $caption(acqapn,label,options) -font $audace(font,arial_8_b)
            pack $This.fra3.lab1 -in $This.fra3 -anchor center -side top -fill x

            #--- Le label 'Variables'
            LabelFrame $This.fra3.reglage -borderwidth 0 -relief groove\
               -text $caption(acqapn,label,reglage) -side top -anchor center
               #--- Construction du combobox des variables
               ::AcqAPN::SetComboBoxList $This.fra3.reglage.var "variables"
               pack $This.fra3.reglage.var -in $This.fra3.reglage -anchor center -side top -padx 2 -pady 4
               $This.fra3.reglage.var configure -modifycmd  {
                  set this "$audace(base).acqapn.fra3"
                  #--- Capture de la nouvelle variable affich�e
                  set panneau(AcqAPN,variable_affichee) [$this.reglage.var get]
                  #--- Configuration de la liste des valeurs sp�cifique de la variable
                  $this.valeur.val configure -values $apn_base($panneau(AcqAPN,variable_affichee))
                  #--- Affichage de la valeur correspondante
                  $this.valeur.val configure -text $confCam(apn,$panneau(AcqAPN,variable_affichee))
               }
            pack $This.fra3.reglage -in $This.fra3 -anchor center -side top -fill x

               #--- Le label 'Valeur'
               LabelFrame $This.fra3.valeur -borderwidth 0 -relief groove\
                  -text $caption(acqapn,label,valeur) -side top -anchor center
                  #--- Construction du combobox des valeurs utilisables pour la valeur affich�e
                  #--- Identification de la variable affich�e dans le combobox des variables      
                  set panneau(AcqAPN,variable_affichee) [$This.fra3.reglage.var get]

                  #--- Construction du combobox des valeurs utilisables pour la valeur afich�e
                  ::AcqAPN::SetComboBoxList $This.fra3.valeur.val "$panneau(AcqAPN,variable_affichee)"
                  pack $This.fra3.valeur.val -in $This.fra3.valeur -anchor center -side top -padx 2 -pady 4
                  $This.fra3.valeur.val configure -text $confCam(apn,$panneau(AcqAPN,variable_affichee))
                  $This.fra3.valeur.val configure -modifycmd {
                     set this "$audace(base).acqapn.fra3"
                     #--- Capture de la nouvelle variable modifi�e
                     set panneau(AcqAPN,variable_affichee) [$this.reglage.var get]
                     #--- Recherche de la valeur litt�rale associ�e � l'index et mise � jour
                     set confCam(apn,$panneau(AcqAPN,variable_affichee)) [$this.valeur.val get]
                     ::AcqAPN::VerifData $panneau(AcqAPN,variable_affichee)
                  }
               pack $This.fra3.valeur -in $This.fra3 -anchor center -side top -fill x

               #--- Le zoom
               LabelFrame $This.fra3.zoom -borderwidth 0 -relief groove -text $caption(acqapn,label,zoom) -side top -anchor center
                  scale $This.fra3.zoom.opt_zoom_variant -variable confCam(apn,zoom)\
                     -orient horizontal -from $panneau(AcqAPN,L_focus) -to $panneau(AcqAPN,H_focus) -resolution 1\
                     -borderwidth 2 -width 5 -length 95 -state normal -relief groove\
                     -command { #� faire }
                  pack $This.fra3.zoom.opt_zoom_variant -in $This.fra3.zoom -anchor w -side right -padx 5          
               pack $This.fra3.zoom -in $This.fra3 -anchor center -side top -fill x

               #--- La correction d'exposition
               LabelFrame $This.fra3.exposure -borderwidth 0 -relief groove\
                  -text $caption(acqapn,label,exposition) -side top -anchor center    
                  scale $This.fra3.exposure.opt_exposure_variant -variable confCam(apn,exposure)\
                     -orient horizontal -from -2.0 -to 2.0 -resolution 0.33\
                     -borderwidth 2 -width 5 -length 95 -state normal -relief groove\
                     -command { ::AcqAPN::Exposure "" }
                  pack $This.fra3.exposure.opt_exposure_variant -in $This.fra3.exposure -anchor w -side right -padx 5
               pack $This.fra3.exposure -in $This.fra3 -anchor center -side top -fill x 

               #--- Le bouton 'Param�tres'
               Button $This.fra3.param -borderwidth 4 -text $caption(acqapn,but,parametres) -state normal\
                  -command { ::AcqAPN::GesPar }
               pack $This.fra3.param -in $This.fra3 -anchor center -side bottom -fill x 
         place $This.fra3 -x 4 -y 192 -height 230 -width $panneau(AcqAPN,large) -anchor nw -bordermode ignore

         #--- Frame pour la connexion avec l'APN
         frame $This.fra4 -borderwidth 1 -relief groove

            #--- Le label 'Vues'
            label $This.fra4.lab -text $caption(acqapn,label,vues) -font $audace(font,arial_8_b) 
            pack $This.fra4.lab -in $This.fra4 -anchor center -side top

            #--- Le bouton 'Connecter'
            button $This.fra4.connect -borderwidth 4 -text $caption(acqapn,sw_connect,on) \
               -font $audace(font,arial_8_b) -state normal -command { ::AcqAPN::Query } 
            pack $This.fra4.connect -in $This.fra4 -anchor center -side top -fill x

         place $This.fra4 -x 4 -y 426 -height 50 -width $panneau(AcqAPN,large) -anchor nw -bordermode ignore

         #--- Mise � jour dynamique de la couleur
         ::confColor::applyColor $This
   }

      ::AcqAPN::Init $audace(base)

