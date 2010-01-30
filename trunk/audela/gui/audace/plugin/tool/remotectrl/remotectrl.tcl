#
# Fichier : remotectrl.tcl
# Description : Outil de controle a distance par RPC
# Auteur : Alain KLOTZ
# Mise a jour $Id: remotectrl.tcl,v 1.33 2010-01-30 14:49:56 robertdelmas Exp $
#

#============================================================
# Declaration du namespace remotectrl
#    initialise le namespace
#============================================================
namespace eval ::remotectrl {
   package provide remotectrl 1.0
   package require audela 1.4.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   set dir [file dirname [info script]]
   source [ file join $dir remotectrl.cap ]
   source [ file join $dir rmtctrlapn.tcl ]
   source [ file join $dir rmtctrlutil.tcl ]
   source [ file join $dir rmtctrltel.tcl ]
   source [ file join $dir rmtctrlccd.tcl ]

   #------------------------------------------------------------
   # getPluginTitle
   #    retourne le titre du plugin dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(remotectrl,title)"
   }

   #------------------------------------------------------------
   # getPluginHelp
   #    retourne le nom du fichier d'aide principal
   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "remotectrl.htm"
   }

   #------------------------------------------------------------
   # getPluginType
   #    retourne le type de plugin
   #------------------------------------------------------------
   proc getPluginType { } {
      return "tool"
   }

   #------------------------------------------------------------
   # getPluginDirectory
   #    retourne le type de plugin
   #------------------------------------------------------------
   proc getPluginDirectory { } {
      return "remotectrl"
   }

   #------------------------------------------------------------
   # getPluginOS
   #    retourne le ou les OS de fonctionnement du plugin
   #------------------------------------------------------------
   proc getPluginOS { } {
      return [ list Windows Linux Darwin ]
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
         subfunction1 { return "remote" }
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
      global audace

      #--- Chargement des fonctions de communication par reseau
      uplevel #0 "source \"[ file join $audace(rep_gui) audace audnet.tcl ]\""

      #--- Mise en place de l'interface graphique
      createPanel $in.remotectrl
   }

   #------------------------------------------------------------
   # deletePluginInstance
   #    suppprime l'instance du plugin
   #------------------------------------------------------------
   proc deletePluginInstance { visuNo } {

   }

   #------------------------------------------------------------
   # createPanel
   #    prepare la creation de la fenetre de l'outil
   #------------------------------------------------------------
   proc createPanel { this } {
      global audace panneau
      variable parametres
      variable This

      #--- Chargement des variables
      ::remotectrl::chargementVar

      #---
      set This $this

      #---
      set panneau(remotectrl,base)          "$this"
      set panneau(remotectrl,wizCon1,base)  "$audace(base).wiz_remotectrl"

      #---
      foreach var [ list ip1 port1 ftp_port1 ip2 port2 path_img ] {
         set panneau(remotectrl,$var) "$parametres($var)"
      }
      set panneau(remotectrl,debug)     "no"

      remotectrlBuildIF $This
   }

   proc chargementVar { } {
      global audace
      variable parametres

      #--- Ouverture du fichier de parametres
      set fichier [ file join $audace(rep_plugin) tool remotectrl remotectrl.ini ]
      if { [ file exists $fichier ] } {
         source $fichier
      }

      set variables [ list ip1 port1 ftp_port1 ip2 port2 path_img ]
      set values [ list "[Ip]" "4000" "21" "[Ip]" 4001" "21" ]
      foreach var $variables val $values {
         if { ! [ info exists parametres($var) ] } { set parametres($var) $val }
      }
      #--- Dans le cas de l'utilisation d'un dossier partage sous Windows uniquement
      ### if { ! [ info exists parametres(path_img) ] }  { set parametres(path_img) "[pwd]/" }
   }

   proc enregistrementVar { } {
      global audace panneau
      variable parametres

      set variables [ list ip1 port1 ftp_port1 ip2 port2 path_img ]
      foreach var $variables {
         set parametres($var) $panneau(remotectrl,$var)
      }

      #--- Sauvegarde des parametres
      catch {
         set nom_fichier [ file join $audace(rep_plugin) tool remotectrl remotectrl.ini ]
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

   proc cmdConnect { } {
      wizCon1
   }

#--   fin du namespace
}

#------------------------------------------------------------
# remotectrlBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc remotectrlBuildIF { This } {
   global audace panneau caption color

   source [ file join $audace(rep_plugin) tool remotectrl rmtctrltel.cap ]

   #---
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove
         #--- Bouton du titre
         Button $This.fra1.but -borderwidth 1 \
            -text "$caption(remotectrl,help_titre1)\n$caption(remotectrl,title)" \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::remotectrl::getPluginType ] ] \
               [ ::remotectrl::getPluginDirectory ] [ ::remotectrl::getPluginHelp ]"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
      DynamicHelp::add $This.fra1.but -text $caption(remotectrl,help_titre)
      pack $This.fra1 -side top -fill x

      #--- Frame de la configuration
      frame $This.fraconf -borderwidth 1 -relief groove

         #--- Label pour l'etat
         label $This.fraconf.labURL2 -text $caption(remotectrl,none) -fg $color(red) -relief flat
         pack $This.fraconf.labURL2 -in $This.fraconf -anchor center -fill none

         #--- Bouton connecter
         button $This.fraconf.but1 -borderwidth 2 \
            -text $caption(remotectrl,connect) \
            -command { ::remotectrl::cmdConnect }
         pack $This.fraconf.but1 -in $This.fraconf -anchor center -fill none -ipadx 3 -ipady 3

      pack $This.fraconf -side top -fill x

      #--   construction de la partie pointage
      ::remotectrl::fillTelPanel

      #--- Frame de l'imageur
      frame $This.fra6 -borderwidth 1 -relief groove
      pack $This.fra6 -side top -fill x

      #--- Frame du mask
      frame $This.fram -borderwidth 1 -relief flat
      place $This.fram -x 3 -y 87 -width 200 -height 600 -anchor nw \
         -bordermode ignore

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

# ==============================================================================================
# ==============================================================================================
   ##########################################################
   #-- Panneau 1 de configuration de la connexion           #
   ##########################################################
   proc wizCon1 { } {
      global audace conf panneau rpcid caption

      set base $panneau(remotectrl,wizCon1,base)
      if [winfo exists $base] { destroy $base }

      #--- New Toplevel
      toplevel $base -class Toplevel
      wm title $base $caption(remotectrl,wizCon,title)
      wm transient $base $audace(base)
      set posxWizCon1 [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
      set posyWizCon1 [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
      if {$rpcid(state)==""} {
         set texte "$caption(remotectrl,wizCon1,toconnect)"
         wm geometry $base +[ expr $posxWizCon1 + 220 ]+[ expr $posyWizCon1 + 70 ]
      } elseif {$rpcid(state)=="server"} {
         set texte "$caption(remotectrl,wizCon1,tounconnect_backyard)"
         wm geometry $base +[ expr $posxWizCon1 + 180 ]+[ expr $posyWizCon1 + 70 ]
      } else {
         set texte "$caption(remotectrl,wizCon1,tounconnect_home)"
         wm geometry $base +[ expr $posxWizCon1 + 180 ]+[ expr $posyWizCon1 + 70 ]
      }
      wm resizable $base 0 0

      ::blt::table $base

      #--- Title
      label $base.lab_title2 -text "$caption(remotectrl,wizCon,title)"
      #--- Describe
      label $base.lab_desc -text $texte

      #--- Buttons
      if {$rpcid(state)==""} {

         #--- Button BACKYARD >>
         button $base.but_1 -text "$caption(remotectrl,backyard) >>" \
            -borderwidth 2 -width 10 \
            -command { wizConServer $panneau(remotectrl,port1) }

         #--- Button HOME >>
         button $base.but_2 -text "$caption(remotectrl,home) >>" \
            -borderwidth 2 -width 10 \
            -command { wizConClient }

      } else {

         #--- Button << CANCEL
         button $base.but_1 -text $caption(remotectrl,wizCon,cancel) \
            -borderwidth 2 -width 10 \
            -command { global panneau
                  destroy $panneau(remotectrl,wizCon1,base)
            }

         #--- Button DECONNECT >>
         button $base.but_2 -text $caption(remotectrl,wizCon,unconnect) \
            -borderwidth 2 -width 10
         if {$rpcid(state)=="server"} {
            $base.but_2 configure -command {
               if { $conf(confPad) != "" } {
                  ::$conf(confPad)::deletePluginInstance
               }
               wizDelServer
            }
         } else {
            $base.but_2 configure -command {
               if { $conf(confPad) != "" } {
                  ::$conf(confPad)::deletePluginInstance
               }
               wizDelClient
            }
         }
      }

      #--   positionne les elements dans la table
      ::blt::table $base \
      $base.lab_title2 0,0 -cspan 2 -pady 5 \
      $base.lab_desc  1,0 -cspan 2 -pady 5 \
      $base.but_1 2,0 -cspan 2 -pady 5 -ipadx 10 -ipady 5 \
      $base.but_2 3,0 -cspan 2 -pady 5 -ipadx 10 -ipady 5
      ::blt::table configure $base -padx 20

      #---
      focus $base

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $base
   }

   ##########################################################
   #-- Panneau 2 de configuration de la connexion client #
   ##########################################################
   proc wizConClient { } {
      global audace panneau caption

      set base $panneau(remotectrl,wizCon1,base)
      if [winfo exists $base] { destroy $base }
      #--- New Toplevel
      toplevel $base -class Toplevel
      wm title $base $caption(remotectrl,wizCon,title)
      wm transient $base $audace(base)
      set posxWizCon1 [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
      set posyWizCon1 [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
      wm geometry $base +[ expr $posxWizCon1 + 170 ]+[ expr $posyWizCon1 + 70 ]
      wm resizable $base 0 0

      ::blt::table $base
      #--   Describe
      #---  Title
      label $base.lab_title2 -text "$caption(remotectrl,wizConClient,title2)"
      #--   Backyard IP
      label $base.lab_ip1 -text "$caption(remotectrl,backyard) $caption(remotectrl,ip)"
      entry $base.ent_ip1 -textvariable panneau(remotectrl,ip1) -width 15
      #--   Backyard RCP port
      label $base.lab_port1 -text "$caption(remotectrl,backyard) $caption(remotectrl,port_rcp)"
      entry $base.ent_port1 -textvariable panneau(remotectrl,port1) -width 5
      #--   Home IP
      set panneau(remotectrl,ip2) "[Ip]"
      label $base.lab_ip2 -text "$caption(remotectrl,home) $caption(remotectrl,ip)"
      entry $base.ent_ip2 -textvariable panneau(remotectrl,ip2) -width 15
      #--   Home RCP port
      label $base.lab_port2 -text "$caption(remotectrl,home) $caption(remotectrl,port_rcp)"
      entry $base.ent_port2 -textvariable panneau(remotectrl,port2) -width 5
      #--   Path image
      label $base.lab_path -text "$caption(remotectrl,path_img)"
      entry $base.ent_path -textvariable panneau(remotectrl,path_img) -width 5

      #--- Button << CANCEL
      button $base.but_backyard -text $caption(remotectrl,wizCon,cancel) -borderwidth 2 \
         -command {
            global panneau
            destroy $panneau(remotectrl,wizCon1,base)
         }
      #--- Button CONNECT >>
      button $base.but_home -text $caption(remotectrl,wizConClient,connect) -borderwidth 2 \
         -command {
            global panneau
            ::remotectrl::enregistrementVar
            wizConClient2 $panneau(remotectrl,ip1) $panneau(remotectrl,port1) $panneau(remotectrl,ip2) $panneau(remotectrl,port2)
         }

      foreach child { ent_ip1 ent_port1 ent_ip2 ent_port2 ent_path } {
         $base.$child configure -relief groove -justify center
      }

      #--   positionne les elements dans la table
      ::blt::table $base \
         $base.lab_title2 0,0 -cspan 2 -pady 5 \
         $base.lab_ip1 1,0 -anchor w -pady 5 \
         $base.ent_ip1 1,1 -pady 5 \
         $base.lab_port1 2,0 -anchor w -pady 5 \
         $base.ent_port1 2,1 -pady 5 \
         $base.lab_ip2 3,0 -anchor w -pady 5 \
         $base.ent_ip2 3,1 -pady 5 \
         $base.lab_port2 4,0 -anchor w -pady 5 \
         $base.ent_port2 4,1 -pady 5 \
         $base.lab_path 5,0 -anchor w -pady 5 \
         $base.ent_path 5,1 -pady 5 \
         $base.but_backyard 6,0 -pady 5 -ipadx 10 -ipady 5 \
         $base.but_home 6,1 -pady 5 -ipadx 10 -ipady 5
      ::blt::table configure $base -padx 20
      ::blt::table configure $base c* -width 120

      #---
      focus $base

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $base
   }

   ##########################################################
   #--   Panneau de la connexion client                     #
   ##########################################################
   proc wizConClient2 { ip1 port1 ip2 port2 } {
      global audace panneau color caption rpcid

      set base $panneau(remotectrl,wizCon1,base)
      if [winfo exists $base] { destroy $base }

      if {($ip2!="")&&($port2!="")} {
         set num_port [ catch { set res [create_client $panneau(remotectrl,ip1) $panneau(remotectrl,port1) $panneau(remotectrl,ip2) $panneau(remotectrl,port2)] } msg ]
      } else {
         set num_port [ catch { set res [create_client $panneau(remotectrl,ip1) $panneau(remotectrl,port1)] } msg ]
      }

      #--   si pas de connexion
      if { $num_port == "1" } {

         wizDelClient
         #-- message d'avertissement
         tk_messageBox -type ok -icon warning -title "$caption(remotectrl,attention)" \
            -message "$caption(remotectrl,port_utilise)"

      } else {

         if {$rpcid(state)==""} {
            return
         }

         #--   si connexion
         set This $panneau(remotectrl,base)

         if {$rpcid(state)=="client"} {

            #--   configure le mot 'Maison'
            $This.fraconf.labURL2 configure -text $caption(remotectrl,home) -fg $color(blue)
            set texte "[ format $caption(remotectrl,ip_port) $panneau(remotectrl,ip2) $panneau(remotectrl,port2) ]"
            append  texte "\n$caption(remotectrl,wizConClient,connect) \n"
            append texte "[ format $caption(remotectrl,ip_port) $panneau(remotectrl,ip1) $panneau(remotectrl,port1) ]"
            DynamicHelp::add $This.fraconf.labURL2 \
               -text $texte

            #--   spécialise les panneaux
            set camName [ searchCamTel ]
            switch -exact $camName {
               "DSLR"   {  source [ file join $audace(rep_plugin) tool remotectrl rmtctrlapn.cap ]
                           ::remotectrl::searchInfoDslr
                           set cmd "::remotectrl::shoot"
                           set texte "$caption(remotectrl,go) $camName"
                        }
               "WEBCAM" {  #source [ file join $audace(rep_plugin) tool remotectrl rmtctrlwebcam.cap ]
                           #::remotectrl::searchInfoWebcam
                           set cmd ""
                           set texte "$caption(remotectrl,go) $camName"
                        }
               ""       {  set cmd ""
                           set texte "$caption(remotectrl,nocam)"
                        }
               "default" { source [ file join $audace(rep_plugin) tool remotectrl rmtctrlccd.cap ]
                           ::remotectrl::fillCCDPanel
                           set cmd { ::remotectrl::cmdGo }
                           set texte "$caption(remotectrl,go) $camName"
                         }
            }

            #--   configure le bouton de lancement d'acquisition
            button $This.fra6.but1 -borderwidth 2 -text $texte -command $cmd
            pack $This.fra6.but1 -in $This.fra6 -anchor center -fill x -ipadx 15 -ipady 3

         }

         if {$rpcid(state)=="client/server"} {

            #--   configure le mot 'Jardin'
            $This.fraconf.labURL2 configure -text $caption(remotectrl,home) -fg $color(blue)
            DynamicHelp::add $This.fraconf.labURL2 \
               -text "[ format $caption(remotectrl,ip_port) $panneau(remotectrl,ip2)\
                  $panneau(remotectrl,port2) ]"
         }

         #--   configure le bouton de connexion
         $This.fraconf.but1 configure -text $caption(remotectrl,unconnect)

         #--- Le client demasque les commandes
         place $This.fram -x 3 -y 87 -width 200 -height 1 -anchor nw \
            -bordermode ignore
         ::remotectrl::cmdAfficheCoord
      }
   }

   ##########################################################
   #-- Panneau de configuration de la connexion du serveur  #
   ##########################################################
   proc wizConServer { port } {
      global audace panneau caption color rpcid

      set base $panneau(remotectrl,wizCon1,base)
      if { [winfo exists $base] } {
         destroy $base
      }

      #--- New Toplevel
      toplevel $base -class Toplevel
      wm title $base $caption(remotectrl,wizCon,title)
      wm transient $base $audace(base)
      set posxWizCon1 [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
      set posyWizCon1 [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
      wm geometry $base +[ expr $posxWizCon1 + 190 ]+[ expr $posyWizCon1 + 70 ]
      wm resizable $base 0 0

      ::blt::table $base

      #--- Title
      label $base.lab_title2 -text "$caption(remotectrl,wizConClient,title3)"
      #--  Port RCP
      label $base.lab_port1 -text "$caption(remotectrl,backyard) $caption(remotectrl,port_rcp)"
      entry $base.ent_port1 -textvariable panneau(remotectrl,port1) -width 5 -relief groove -justify center
      #--  Port pour les images
      label $base.lab_path -text "$caption(remotectrl,path_img)"
      entry $base.ent_path -textvariable panneau(remotectrl,ftp_port1) -width 5 -relief groove -justify center

      #--- Button << CANCEL
      button $base.but_backyard -text $caption(remotectrl,wizCon,cancel) -borderwidth 2 \
         -command {
            global panneau
            destroy $panneau(remotectrl,wizCon1,base)
          }

      #--- Button CONNECT >>
      button $base.but_home -text "$caption(remotectrl,wizConClient,connect)" -borderwidth 2 \
         -command {
            global audace caption panneau
            ::remotectrl::enregistrementVar
            if {$panneau(remotectrl,debug)=="no"} {

               if { [::cam::list]== "" } {
                  ::confCam::run
               }
               if { [::tel::list] == "" } {
                  ::confTel::run
               }
            }
            set num_port [ catch { set res [create_server $panneau(remotectrl,port1)] } msg ]
            if { $num_port == "1" } {
               wizDelServer
               tk_messageBox -type ok -icon warning -title "$caption(remotectrl,attention)" \
                  -message "$caption(remotectrl,panneau,port_utilise)"
            } else {
               set error [catch {package require ftpd} msg]
               if {$error==0} {
                  set error [catch {::ftpd::server} msg]
                  if {($error==0)||(($error==1)&&($msg=="couldn't open socket: address already in use"))} {
                     set ::ftpd::port $panneau(remotectrl,ftp_port1)
                     set ::ftpd::cwd $audace(rep_images)
                  }
               }
               set base $panneau(remotectrl,wizCon1,base)
               if [winfo exists $base] { destroy $base }

               if {$rpcid(state)==""} { return }

               set This $panneau(remotectrl,base)
               DynamicHelp::add $This.fraconf.labURL2 \
                  -text "[ format $caption(remotectrl,ip_port) $panneau(remotectrl,ip2) \
                     $panneau(remotectrl,port2) ]"

               $This.fraconf.labURL2 configure -text $caption(remotectrl,backyard) -fg $color(blue)
               DynamicHelp::add $This.fraconf.labURL2 \
                  -text "[ format $caption(remotectrl,ip_port) [Ip] $panneau(remotectrl,port2) ]"
               $This.fraconf.but1 configure -text $caption(remotectrl,unconnect)

               #--- Le serveur masque les commandes
               place $This.fram -x 3 -y 87 -width 200 -height 600 -anchor nw \
                  -bordermode ignore
            }
      }

      #--   positionne les elements dans la table
      ::blt::table $base \
         $base.lab_title2 0,0 -cspan 2 -pady 5 \
         $base.lab_port1 1,0 -anchor w -pady 5 \
         $base.ent_port1 1,1 -pady 5 \
         $base.lab_path 2,0 -anchor w -pady 5 \
         $base.ent_path 2,1 -pady 5 \
         $base.but_backyard 3,0 -pady 5 -ipadx 10 -ipady 5 \
         $base.but_home 3,1 -pady 5 -ipadx 10 -ipady 5
      ::blt::table configure $base -padx 20
      ::blt::table configure $base c* -width 120

      #---
      focus $base

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $base
   }

   ##########################################################
   #-- Transfert par FTP                                    #
   #-- parametre : nom court (avec extension) de l'image    #
   ##########################################################
   proc transferFTP { nom } {
      global audace panneau

       eval "send \{catch \{ set ::ftpd::port \$panneau(remotectrl,ftp_port1) \} \}"
       eval "send \{catch \{ set ::ftpd::cwd \$audace(rep_images) \} \}"

       set error [catch {package require ftp} msg]
       if {$error==0} {
         set error [catch {::ftp::Open $panneau(remotectrl,ip1) anonymous software.audela@free.fr -timeout 15} msg]
            if {($error==0)} {
               set ftpid $msg
               ::ftp::Type $ftpid binary
               ::ftp::Get $ftpid $nom $audace(rep_images)
               ::ftp::Close $ftpid
            }
       }
   }

   ##########################################################
   #-- Deconnexon du serveur                                #
   ##########################################################
   proc wizDelServer {} {
      set res [delete_server]
      wizDelPanel
   }

   ##########################################################
   #-- Deconnexon du client                                 #
   ##########################################################
   proc wizDelClient {} {
      set res [delete_client]
      wizDelPanel
   }

   ##########################################################
   #-- S/programme de deconnexion                           #
   ##########################################################
   proc wizDelPanel {} {
      global panneau caption color rpcid
      variable This

      set base $panneau(remotectrl,wizCon1,base)
      if [winfo exists $base] { destroy $base }

      if {$rpcid(state)!=""} { return }

      set This $panneau(remotectrl,base)
      $This.fraconf.labURL2 configure -text $caption(remotectrl,none) -fg $color(red)
      $This.fraconf.but1 configure -text $caption(remotectrl,connect)

      #--- Masque les commandes
      place $This.fram -x 3 -y 87 -width 200 -height 700 -anchor nw \
         -bordermode ignore
   }

   ##########################################################
   #-- Retourne l'IP locale formatée                       #
   ##########################################################
   #--   retourne l'ip dans le reseau
   proc Ip {} {
      set ip [lindex [hostaddress] 0]
      set ip "[lindex $ip 0].[lindex $ip 1].[lindex $ip 2].[lindex $ip 3]"
      return $ip
   }

   ##########################################################
   #-- Pour rapatrier les donnees vers Maison               #
   ##########################################################
   proc searchCamTel {} {
      global audace conf panneau

      #--   demande le N° de cam et de tel
      set cmd "send \{set a \[ list \"\$audace(camNo)\" \"\$audace(telNo)\"\]\}"
      lassign [ eval $cmd ] camNo telNo

      set camName ""
      if { $camNo != "0" } {

         #--   demande nom de la camera
         set camName [ eval "send \{cam$camNo name\}" ]

         #--   demande le product de la camera
         set camProduct [ eval "send \{cam$camNo product\}" ]

         #--   demande attachement A,B,C de la camera
         set camItem [ eval "send \{::confVisu::getCamItem $camNo\}" ]

         #--
         set conf(camera,$camItem,camName) "$camProduct"

         #--   pour les panneaux DSLR & WEBCAM
         set panneau(remotectrl,camNo) $camNo
      }

      set telName ""
      if { $telNo != "0" } {

         #--   demande nom du telescope
         set telName [ eval "send \{tel$telNo name\}" ]

         #--   demande product du telescope
         set telProduct [ eval "send \{tel$telNo product\}" ]

         #--
         set conf(telescope) "$telProduct"

      }

      #::confCam::setMount $camItem $audace(telNo)

      return $camName
   }