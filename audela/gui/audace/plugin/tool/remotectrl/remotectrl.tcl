#
# Fichier : remotectrl.tcl
# Description : Outil de controle a distance par RPC
# Auteur : Alain KLOTZ
# Mise a jour $Id: remotectrl.tcl,v 1.22 2008-11-21 16:49:20 michelpujol Exp $
#

#============================================================
# Declaration du namespace remotectrl
#    initialise le namespace
#============================================================
namespace eval ::remotectrl {
   package provide remotectrl 1.0
   package require audela 1.4.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] remotectrl.cap ]

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
         function     { return "aiming" }
         subfunction1 { return "acquisition" }
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
      variable This
      variable parametres
      global audace
      global caption
      global panneau

      #--- Chargement des variables
      ::remotectrl::chargementVar
      #---
      set audace(focus,speed)           "1"
      #---
      set This $this
      set panneau(remotectrl,titre)         "$caption(remotectrl,title)"
      set panneau(remotectrl,aide)          "$caption(remotectrl,help_titre)"
      set panneau(remotectrl,configuration) "$caption(remotectrl,configuration)"
      set panneau(remotectrl,none)          "$caption(remotectrl,none)"
      set panneau(remotectrl,home)          "$caption(remotectrl,home)"
      set panneau(remotectrl,backyard)      "$caption(remotectrl,backyard)"
      set panneau(remotectrl,connect)       "$caption(remotectrl,connect)"
      set panneau(remotectrl,unconnect)     "$caption(remotectrl,unconnect)"
      #---
      set panneau(remotectrl,base)          "$this"
      set panneau(remotectrl,wizCon1,base)  "$audace(base).wiz_remotectrl"
      set panneau(remotectrl,font,title2)   "$audace(font,arial_12_b)"
      set panneau(remotectrl,font,normal)   "$audace(font,arial_12_n)"
      set panneau(remotectrl,font,button)   "$audace(font,arial_12_b)"
      #---
      set panneau(remotectrl,wizCon1,title)                "$caption(remotectrl,wizCon1,title)"
      set panneau(remotectrl,wizCon1,title2)               "$caption(remotectrl,wizCon1,title2)"
      set panneau(remotectrl,wizCon1,toconnect)            "$caption(remotectrl,wizCon1,toconnect)"
      set panneau(remotectrl,wizCon1,tounconnect_backyard) "$caption(remotectrl,wizCon1,tounconnect_backyard)"
      set panneau(remotectrl,wizCon1,tounconnect_home)     "$caption(remotectrl,wizCon1,tounconnect_home)"
      set panneau(remotectrl,wizCon1,home)                 "$caption(remotectrl,wizCon1,home)"
      set panneau(remotectrl,wizCon1,backyard)             "$caption(remotectrl,wizCon1,backyard)"
      set panneau(remotectrl,wizCon1,unconnect_backyard)   "$caption(remotectrl,wizCon1,unconnect_backyard)"
      set panneau(remotectrl,wizCon1,unconnect_home)       "$caption(remotectrl,wizCon1,unconnect_home)"
      set panneau(remotectrl,wizCon1,cancel)               "$caption(remotectrl,wizCon1,cancel)"
      set panneau(remotectrl,wizConClient,title)           "$caption(remotectrl,wizConClient,title)"
      set panneau(remotectrl,wizConClient,title2)          "$caption(remotectrl,wizConClient,title2)"
      set panneau(remotectrl,wizConClient,title3)          "$caption(remotectrl,wizConClient,title3)"
      set panneau(remotectrl,wizConClient,connect)         "$caption(remotectrl,wizConClient,connect)"
      set panneau(remotectrl,wizConClient,attention)       "$caption(remotectrl,attention)"
      set panneau(remotectrl,panneau,port_utilise)         "$caption(remotectrl,port_utilise)"
      set panneau(remotectrl,after)                        "200"
      set panneau(remotectrl,bin)                          "$caption(remotectrl,binning)"
      set panneau(remotectrl,choix_bin)                    "1x1 2x2 4x4"
      set panneau(remotectrl,binning)                      "2x2"
      set panneau(remotectrl,menu)                         "$caption(remotectrl,coord)"
      set panneau(remotectrl,nomObjet)                     ""
      set panneau(remotectrl,equinox)                      ""

      #--- Coordonnees J2000.0 de M104
      set panneau(remotectrl,getobj)    "12h40m0 -11d37m22"

      #---
      set panneau(remotectrl,goto)      "$caption(remotectrl,goto)"
      set panneau(remotectrl,match)     "$caption(remotectrl,match)"
      set panneau(remotectrl,exptime)   "2"
      set panneau(remotectrl,secondes)  "$caption(remotectrl,seconde)"
      set panneau(remotectrl,go)        "$caption(remotectrl,goccd)"
      #---
      set panneau(remotectrl,ip1)       "$parametres(ip1)"
      set panneau(remotectrl,port1)     "$parametres(port1)"
      set panneau(remotectrl,debug)     "no"
      set panneau(remotectrl,ftp_port1) "$parametres(ftp_port1)"
      set panneau(remotectrl,ip2)       "$parametres(ip2)"
      set panneau(remotectrl,port2)     "$parametres(port2)"
      set panneau(remotectrl,path_img)  "$caption(remotectrl,path_img)"
      set panneau(remotectrl,port_ftp)  "$caption(remotectrl,port_ftp)"
      set panneau(remotectrl,port_rcp)  "$caption(remotectrl,port_rcp)"
      set panneau(remotectrl,ip)        "$caption(remotectrl,ip)"
      set panneau(remotectrl,path_img)  "$parametres(path_img)"
      remotectrlBuildIF $This
   }

   proc chargementVar { } {
      variable parametres
      global audace

      #--- Ouverture du fichier de parametres
      set fichier [ file join $audace(rep_plugin) tool remotectrl remotectrl.ini ]
      if { [ file exists $fichier ] } {
         source $fichier
      }
      #---
      set ip [lindex [hostaddress] 0]
      set ip "[lindex $ip 0].[lindex $ip 1].[lindex $ip 2].[lindex $ip 3]"
      #---
      if { ! [ info exists parametres(ip1) ] }       { set parametres(ip1) "$ip" }
      if { ! [ info exists parametres(port1) ] }     { set parametres(port1) "4000" }
      if { ! [ info exists parametres(ftp_port1) ] } { set parametres(ftp_port1) "21" } ; # changer 21 par une valeur
      if { ! [ info exists parametres(ip2) ] }       { set parametres(ip2) "$ip" }
      if { ! [ info exists parametres(port2) ] }     { set parametres(port2) "4001" }
      if { ! [ info exists parametres(path_img) ] }  { set parametres(path_img) "21" } ; # changer 21 par une valeur
      #--- Dans le cas de l'utilisation d'un dossier partage sous Windows uniquement
      ### if { ! [ info exists parametres(path_img) ] }  { set parametres(path_img) "[pwd]/" }
   }

   proc enregistrementVar { } {
      variable parametres
      global audace
      global panneau

      set parametres(ip1)       $panneau(remotectrl,ip1)
      set parametres(port1)     $panneau(remotectrl,port1)
      set parametres(ftp_port1) $panneau(remotectrl,ftp_port1)
      set parametres(ip2)       $panneau(remotectrl,ip2)
      set parametres(port2)     $panneau(remotectrl,port2)
      set parametres(path_img)  $panneau(remotectrl,path_img)

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

   proc cmdGoto { } {
      variable This
      global conf
      global audace
      global panneau
      global caption
      global catalogue

      #--- Debut modif reseau
      if {[eval "send \{::tel::list\}"]!=""} {
      #--- Fin modif reseau
         $This.fra2.but1 configure -relief groove -state disabled
         update
         #--- Cas particulier si le premier pointage est en mode coordonnees
         if { $panneau(remotectrl,menu) == "$caption(remotectrl,coord)" } {
            set panneau(remotectrl,list_radec) $panneau(remotectrl,getobj)
         }
         #--- Debut modif reseau
         set message "send \{tel\$audace(telNo) radec goto \{[ list [lindex $panneau(remotectrl,list_radec) 0] [lindex $panneau(remotectrl,list_radec) 1] ]\}\}"
         eval $message
         #--- Fin modif reseau
         $This.fra2.but1 configure -relief raised -state normal
         update
      } else {
         #--- Affiche un message de non connexion du telescope
         set panneau(remotectrl,getra)  "$caption(remotectrl,tel)"
         set panneau(remotectrl,getdec) "$caption(remotectrl,non_connecte)"
         $This.fra3.ent1 configure -text $panneau(remotectrl,getra)
         $This.fra3.ent2 configure -text $panneau(remotectrl,getdec)
         update
      }
      ::remotectrl::cmdAfficheCoord
   }

   proc setRaDec { 1 listRaDec nomObjet equinox magnitude } {
      global panneau

      set panneau(remotectrl,getobj)       $listRaDec
      set panneau(remotectrl,nomObjet)     $nomObjet
      set panneau(remotectrl,equinoxObjet) $equinox
   }

   proc cmdSpeed { { value " " } } {
      global audace

      #--- Debut modif reseau
      if {[eval "send \{::tel::list\}"]!=""} {
         #--- Fin modif reseau

         #--- Incremente la valeur et met à jour les raquettes et les outils locaux
         ::remotectrl::incrementSpeed

         #--- Met à jour les raquettes et les outils distants
         set message "send \{::remotectrl::setSpeed $audace(telescope,speed)\}"
         eval $message

      } else {
         console::affiche_erreur "cmdSpeed erreur"
      }
      update
      return
   }

   proc cmdFocusSpeed { { value " " } } {
      global audace

      #--- Debut modif reseau
      if {[eval "send \{::tel::list\}"]!=""} {
         #--- Fin modif reseau

         #--- Incremente la valeur et met à jour les raquettes et les outils locaux
         ::remotectrl::incrementFocusSpeed

         #--- Met à jour les raquettes et les outils distants
         set message "send \{::remotectrl::setFocusSpeed $audace(focus,speed)\}"
         eval $message

      } else {
         console::affiche_erreur "cmdSpeed erreur"
      }
      update
      return
   }

   #------------------------------------------------------------
   #  incrementSpeed
   #     incremente la vitesse du telescope
   #     et met la nouvelle valeur dans la variable audace(telescope,speed)
   #------------------------------------------------------------
   proc incrementSpeed { } {
      global conf
      global audace

      if {[eval "send \{::tel::list\}"]!=""} {
         if { $conf(telescope) == "audecom" } {
            #--- Pour audecom, l'increment peut prendre 3 valeurs ( 1 2 3 )
            if { $audace(telescope,speed) == "1" } {
               ::remotectrl::setSpeed "2"
            } elseif { $audace(telescope,speed) == "2" } {
               ::remotectrl::setSpeed "3"
            } elseif { $audace(telescope,speed) == "3" } {
               ::remotectrl::setSpeed "1"
            } else {
               ::remotectrl::setSpeed "1"
            }
         } elseif { $conf(telescope) == "lx200" } {
            #--- Pour lx200, l'increment peut prendre 4 valeurs ( 1 2 3 4 )
            if { $audace(telescope,speed) == "1" } {
               ::remotectrl::setSpeed "2"
            } elseif { $audace(telescope,speed) == "2" } {
               ::remotectrl::setSpeed "3"
            } elseif { $audace(telescope,speed) == "3" } {
               ::remotectrl::setSpeed "4"
            } elseif { $audace(telescope,speed) == "4" } {
               ::remotectrl::setSpeed "1"
            } else {
               ::remotectrl::setSpeed "1"
            }
         } elseif { $conf(telescope) == "temma" } {
            #--- Pour temma, l'increment peut prendre 2 valeurs ( 1 2 )
            if { $audace(telescope,speed) == "1" } {
               ::remotectrl::setSpeed "2"
            } elseif { $audace(telescope,speed) == "2" } {
               ::remotectrl::setSpeed "1"
            } else {
               ::remotectrl::setSpeed "1"
            }
         } else {
            #--- Inactif pour autres telescopes
            ::remotectrl::setSpeed "0"
         }
      }
   }

   #------------------------------------------------------------
   #  incrementFocusSpeed
   #     incremente la vitesse du focaliseur
   #     et met la nouvelle valeur dans la variable audace(focus,speed)
   #------------------------------------------------------------
   proc incrementFocusSpeed { } {
      global conf
      global audace

      if {[eval "send \{::tel::list\}"]!=""} {
         if { $conf(telescope) == "audecom" } {
            #--- Pour audecom, l'increment peut prendre 2 valeurs ( 1 2 )
            if { $audace(focus,speed) == "1" } {
               ::remotectrl::setFocusSpeed "2"
            } elseif { $audace(focus,speed) == "2" } {
               ::remotectrl::setFocusSpeed "1"
            } else {
               ::remotectrl::setFocusSpeed "1"
            }
         } elseif { $conf(telescope) == "lx200" } {
            #--- Pour lx200, l'increment peut prendre 2 valeurs ( 1 2 )
            if { $audace(focus,speed) == "1" } {
               ::remotectrl::setFocusSpeed "2"
            } elseif { $audace(focus,speed) == "2" } {
               ::remotectrl::setFocusSpeed "1"
            } else {
               ::remotectrl::setFocusSpeed "1"
            }
         } else {
            #--- Inactif pour autres telescopes
            ::remotectrl::setFocusSpeed "0"
         }
      }
   }

   #------------------------------------------------------------
   #  setSpeed
   #     change la vitesse du telescope
   #
   #     met a jour les variables audace(telescope,speed), audace(telescope,labelspeed),
   #     audace(telescope,rate), statustel(speed)
   #------------------------------------------------------------
   proc setSpeed { { value "2" } } {
      global conf
      global audace
      global caption
      global statustel

      if { $conf(telescope) == "audecom" } {
         if { $value == "1" } {
            set audace(telescope,speed) "1"
            set audace(telescope,labelspeed) "$caption(remotectrl,x1)"
            set audace(telescope,rate) "0"
            set statustel(speed) "0"
         } elseif { $value == "2" } {
            set audace(telescope,speed) "2"
            set audace(telescope,labelspeed) "$caption(remotectrl,x5)"
            set audace(telescope,rate) "0.5"
            set statustel(speed) "0.33"
         } elseif { $value == "3" } {
            set audace(telescope,speed) "3"
            set audace(telescope,labelspeed) "$caption(remotectrl,200)"
            set audace(telescope,rate) "1"
            set statustel(speed) "0.66"
         } else {
            set audace(telescope,speed) "3"
            set audace(telescope,labelspeed) "$caption(remotectrl,200)"
            set audace(telescope,rate) "1"
            set statustel(speed) "0.66"
         }
      } elseif { $conf(telescope) == "lx200" } {
         if { $value == "1" } {
            set audace(telescope,speed) "1"
            set audace(telescope,labelspeed) "1"
            set audace(telescope,rate) "0"
            set statustel(speed) "0"
         } elseif { $value == "2" } {
            set audace(telescope,speed) "2"
            set audace(telescope,labelspeed) "2"
            set audace(telescope,rate) "0.33"
            set statustel(speed) "0.33"
         } elseif { $value == "3" } {
            set audace(telescope,speed) "3"
            set audace(telescope,labelspeed) "3"
            set audace(telescope,rate) "0.66"
            set statustel(speed) "0.66"
         } elseif { $value == "4" } {
            set audace(telescope,speed) "4"
            set audace(telescope,labelspeed) "4"
            set audace(telescope,rate) "1"
            set statustel(speed) "1"
         } else {
            set audace(telescope,speed) "1"
            set audace(telescope,labelspeed) "1"
            set audace(telescope,rate) "0"
            set statustel(speed) "0"
         }
      } elseif { $conf(telescope) == "temma" } {
         if { $value == "1" } {
            set audace(telescope,speed) "1"
            set audace(telescope,labelspeed) "$caption(remotectrl,NS)"
            set audace(telescope,rate) "0"
            set statustel(speed) "0"
         } elseif { $value == "2" } {
            set audace(telescope,speed) "2"
            set audace(telescope,labelspeed) "$caption(remotectrl,HS)"
            set audace(telescope,rate) "1"
            set statustel(speed) "1"
         } else {
            set audace(telescope,speed) "1"
            set audace(telescope,labelspeed) "$caption(remotectrl,NS)"
            set audace(telescope,rate) "0"
            set statustel(speed) "0"
         }
      } else {
         set audace(telescope,speed) "1"
         set audace(telescope,labelspeed) "$caption(remotectrl,interro)"
         set audace(telescope,rate) "0"
         set statustel(speed) "0"
      }
   }

   #------------------------------------------------------------
   #  setFocusSpeed
   #     change la vitesse du focaliseur
   #
   #     met a jour les variables audace(focus,speed), audace(focus,labelspeed),
   #     audace(focus,rate), statustel(speed)
   #------------------------------------------------------------
   proc setFocusSpeed { { value "2" } } {
      global conf
      global audace
      global caption
      global statustel

      if { $conf(telescope) == "audecom" } {
         if { $value == "1" } {
            set audace(focus,speed) "1"
            set audace(focus,labelspeed) "$caption(remotectrl,x1)"
            set audace(focus,rate) "0"
            set statustel(speed) "0"
         } elseif { $value == "2" } {
            set audace(focus,speed) "2"
            set audace(focus,labelspeed) "$caption(remotectrl,x5)"
            set audace(focus,rate) "1"
            set statustel(speed) "0.33"
         } else {
            set audace(focus,speed) "2"
            set audace(focus,labelspeed) "$caption(remotectrl,x5)"
            set audace(focus,rate) "1"
            set statustel(speed) "0.33"
         }
      } elseif { $conf(telescope) == "lx200" } {
         if { $value == "1" } {
            set audace(focus,speed) "1"
            set audace(focus,labelspeed) "1"
            set audace(focus,rate) "0"
            set statustel(speed) "0"
         } elseif { $value == "2" } {
            set audace(focus,speed) "2"
            set audace(focus,labelspeed) "2"
            set audace(focus,rate) "1"
            set statustel(speed) "0.33"
         } else {
            set audace(focus,speed) "1"
            set audace(focus,labelspeed) "1"
            set audace(focus,rate) "0"
            set statustel(speed) "0"
         }
      } else {
         set audace(focus,speed) "1"
         set audace(focus,labelspeed) "$caption(remotectrl,interro)"
         set audace(focus,rate) "0"
         set statustel(speed) "0"
      }
   }

   proc cmdPulse { direction } {
      variable This
      global audace
      global caption
      global panneau

      #--- Debut modif reseau
      if {[eval "send \{::tel::list\}"]!=""} {
      #--- Fin modif reseau
         set delay [expr int($panneau(remotectrl,after))]
         if {$delay<=0} {
            return
         }
         if {$delay>=120000} {
            set delay 120000
         }
         #--- Debut modif reseau
         set message "send \{tel\$audace(telNo) radec move $direction $audace(telescope,rate)\; after $delay; tel\$audace(telNo) radec stop $direction\}"
         eval $message
         #--- Fin modif reseau
      } else {
         #--- Affiche un message de non connexion du telescope
         set panneau(remotectrl,getra)  "$caption(remotectrl,tel)"
         set panneau(remotectrl,getdec) "$caption(remotectrl,non_connecte)"
         $This.fra3.ent1 configure -text $panneau(remotectrl,getra)
         $This.fra3.ent2 configure -text $panneau(remotectrl,getdec)
         update
      }
      ::remotectrl::cmdAfficheCoord
   }

   proc cmdStop { direction } {
      global conf
      global audace

      #--- Debut modif reseau
      if {[eval "send \{::tel::list\}"]!=""} {
      #--- Fin modif reseau
         #--- Debut modif reseau
         set message "send \{tel\$audace(telNo) radec stop $direction\}"
         eval $message
         #--- Fin modif reseau
         if { $conf(telescope) == "audecom" } {
            if { $audace(telescope,speed) == "3" } {
               after 3700
            } else {
               ::remotectrl::cmdBoucle
            }
         } elseif { $conf(telescope) == "lx200" } {
            if { $conf(lx200,modele) == "AudeCom" } {
               if { ( $audace(telescope,speed) == "3" ) || ( $audace(telescope,speed) == "4" ) } {
                  after 3700
               }
            }
         }
      }
      ::remotectrl::cmdAfficheCoord
   }

   proc cmdBoucle { } {
      global audace

      #--- Boucle tant que le telescope n'est pas arrete
      #--- Debut modif reseau
      set message "send \{tel\$audace(telNo) radec coord\}"
      set radecB0 [eval $message]
      #--- Fin modif reseau
      after 300
      #--- Debut modif reseau
      set message "send \{tel\$audace(telNo) radec coord\}"
      set radecB1 [eval $message]
      #--- Fin modif reseau
      while { $radecB0 != $radecB1 } {
         set radecB0 $radecB1
         after 200
         #--- Debut modif reseau
         set message "send \{tel\$audace(telNo) radec coord\}"
         set radecB1 [eval $message]
         #--- Fin modif reseau
      }
   }

   proc cmdPulseFoc { direction } {
      variable This
      global audace
      global caption
      global panneau

      #--- Debut modif reseau
      if {[eval "send \{::tel::list\}"]!=""} {
      #--- Fin modif reseau
         set delay [expr int($panneau(remotectrl,after))]
         if {$delay<=0} {
            return
         }
         if {$delay>=120000} {
            set delay 120000
         }
         #--- Debut modif reseau
         set message "send \{tel\$audace(telNo) focus move $direction $audace(focus,rate)\; after $delay; tel\$audace(telNo) focus stop\}"
         eval $message
         #--- Fin modif reseau
      } else {
         #--- Affiche un message de non connexion du telescope
         set panneau(remotectrl,getra)  "$caption(remotectrl,tel)"
         set panneau(remotectrl,getdec) "$caption(remotectrl,non_connecte)"
         $This.fra3.ent1 configure -text $panneau(remotectrl,getra)
         $This.fra3.ent2 configure -text $panneau(remotectrl,getdec)
         update
      }
   }

   proc cmdMatch { } {
      global audace
      global caption
      global panneau

      #--- Debut modif reseau
      if {[eval "send \{::tel::list\}"]!=""} {
      #--- Fin modif reseau
         set choix [ tk_messageBox -type yesno -icon warning -title "$caption(remotectrl,match)" \
            -message "$caption(remotectrl,match_confirm)" ]
         if { $choix == "yes" } {
            #--- Debut modif reseau
            set message "send \{tel\$audace(telNo) radec init \{$panneau(remotectrl,getobj)\}\}"
            eval $message
            #--- Fin modif reseau
         }
      } else {
        # ::confTel::run
        # tkwait window $audace(base).confTel
      }
      ::remotectrl::cmdAfficheCoord
   }

   proc cmdAfficheCoord0 { } {
      global audace

      #--- Debut modif reseau
      if {[eval "send \{::tel::list\}"]!=""} {
      #--- Fin modif reseau
         ::remotectrl::cmdAfficheCoord
      } else {
        # ::confTel::run
        # tkwait window $audace(base).confTel
         ::remotectrl::cmdAfficheCoord
      }
   }

   proc cmdAfficheCoord { } {
      variable This
      global audace
      global caption
      global panneau

      #--- Debut modif reseau
      if {[eval "send \{::tel::list\}"]!=""} {
      #--- Fin modif reseau
         #--- Debut modif reseau
         set message "send \{tel\$audace(telNo) radec coord\}"
         set radec [eval $message]
         ::console::affiche_resultat "<radec=$radec>\n"
         #--- Fin modif reseau
         #--- Debut modif reseau
         set message [eval "send \{tel\$audace(telNo) radec coord\}"]
         if {[lindex $radec 0]=="$message"} {
            set panneau(remotectrl,getra)  "$caption(remotectrl,astre_est)"
            set panneau(remotectrl,getdec) "$caption(remotectrl,pas_leve)"
         } else {
            set panneau(remotectrl,getra)  [lindex $radec 0]
            set panneau(remotectrl,getdec) [lindex $radec 1]
         }
         #--- Fin modif reseau
      } else {
         set panneau(remotectrl,getra)  "$caption(remotectrl,tel)"
         set panneau(remotectrl,getdec) "$caption(remotectrl,non_connecte)"
      }
      $This.fra3.ent1 configure -text $panneau(remotectrl,getra)
      $This.fra3.ent2 configure -text $panneau(remotectrl,getdec)
      update
      ::telescope::afficheCoord
      #--- Debut modif reseau
      set message "send \{::telescope::afficheCoord\}"
      set radec [eval $message]
      #--- Fin modif reseau
   }

   proc cmdGo { } {
      variable This
      global audace
      global caption
      global conf
      global panneau

      #--- Debut modif reseau
      if {[eval "send \{::cam::list\}"]!=""} {
      #--- Fin modif reseau
         $This.fra6.but1 configure -relief groove -state disabled
         update
         if { ( $panneau(remotectrl,getra) == "$caption(remotectrl,camera)" ) && \
               ( $panneau(remotectrl,getdec) == "$caption(remotectrl,non_connectee)" ) } {
            set panneau(remotectrl,getra)  ""
            set panneau(remotectrl,getdec) ""
            $This.fra3.ent1 configure -text $panneau(remotectrl,getra)
            $This.fra3.ent2 configure -text $panneau(remotectrl,getdec)
            update
         }

         #--- Temps de pose
         set exptime $panneau(remotectrl,exptime)

         #--- Facteur de binning
         set bin 4
         if { $panneau(remotectrl,binning) == "4x4" } { set bin 4 }
         if { $panneau(remotectrl,binning) == "2x2" } { set bin 2 }
         if { $panneau(remotectrl,binning) == "1x1" } { set bin 1 }

         #--- Initialisation du fenetrage
         catch {
            #--- Debut modif reseau
            set message "send \{set n1n2 \[cam\$audace(camNo) nbcells\]\}"
            set n1n2 [eval $message]
            set message "send \{cam\$audace(camNo) window \[list 1 1 \[lindex \$n1n2 0\] \[lindex \$n1n2 1\] ]\}"
            eval $message
            #--- Fin modif reseau
         }

         #--- Alarme sonore de fin de pose
         set message "send \{::camera::alarme_sonore $exptime\}"
         eval $message

         #--- Appel a la fonction d'acquisition
         set message "send \{acq $exptime $bin\}"
         eval $message

         #--- Appel du timer
         if { $exptime > "2" } {
        ### ::remotectrl::dispTime
         }

        # after $exptime ; #--- A tester
         #--- Extension par defaut
         set ext $conf(extension,defaut)
         #---
         if {$panneau(remotectrl,path_img)>1} {
            #--- Transfert par protocole ftp
            set message "send \{saveima \"\$audace(rep_images)/temp$ext\" \}"
            eval $message
            after 1000
            set message "send \{catch \{ set ::ftpd::port \$panneau(remotectrl,ftp_port1) \} \}"
            eval $message
            set message "send \{catch \{set ::ftpd::cwd \$audace(rep_images) \} \}"
            eval $message
            set error [catch {package require ftp} msg]
            if {$error==0} {
               set error [catch {::ftp::Open $panneau(remotectrl,ip1) anonymous software.audela@free.fr -timeout 15} msg]
               if {($error==0)} {
                  set ftpid $msg
                  ::ftp::Type $ftpid binary
                  ::ftp::Get $ftpid temp$ext
                  catch {file rename -force temp$ext "$audace(rep_images)/temp$ext" }
                  catch {loadima "temp$ext"}
                  catch { file delete "$audace(rep_images)/temp$ext" }
                  ::ftp::Close $ftpid
               }
            }
         } else {
            #--- Tranfert par fichier dans un dossier partagé
            set message "send \{saveima \"\$panneau(remotectrl,path_img)/temp$ext\" \}"
            eval $message
            after 1000
            loadima "$panneau(remotectrl,path_img)/temp$ext"
            catch { file delete "$panneau(remotectrl,path_img)/temp$ext" }
         }

         #--- Graphisme panneau
         $This.fra1.but configure -text $panneau(remotectrl,titre)
         $This.fra6.but1 configure -relief raised -state normal
         update

      } else {
         set panneau(remotectrl,getra)  "$caption(remotectrl,camera)"
         set panneau(remotectrl,getdec) "$caption(remotectrl,non_connectee)"
         $This.fra3.ent1 configure -text $panneau(remotectrl,getra)
         $This.fra3.ent2 configure -text $panneau(remotectrl,getdec)
         update
        # ::confCam::run
        # tkwait window $audace(base).confCam
      }
   }

   proc dispTime { } {
      variable This
      global audace
      global caption

      set t "[cam$audace(camNo) timer -1]"
      if {$t>1} {
         $This.fra1.but configure -text "[expr $t-1] / [format "%d" [expr int([cam$audace(camNo) exptime])]]"
         update
         after 1000 ::remotectrl::dispTime
      } else {
         $This.fra1.but configure -text "$caption(remotectrl,numerisation)"
         update
      }
   }
}

#------------------------------------------------------------
# remotectrlBuildIF
#    cree la fenetre de l'outil
#------------------------------------------------------------
proc remotectrlBuildIF { This } {
   global audace
   global caption
   global panneau
   global color

   #---
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Label du titre
         Button $This.fra1.but -borderwidth 1 -text $panneau(remotectrl,titre) \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::remotectrl::getPluginType ] ] \
               [ ::remotectrl::getPluginDirectory ] [ ::remotectrl::getPluginHelp ]"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $panneau(remotectrl,aide)

      pack $This.fra1 -side top -fill x

      #--- Frame de la configuration
      frame $This.fraconf -borderwidth 1 -relief groove

         #--- Label pour l'etat
         label $This.fraconf.labURL2 -text $panneau(remotectrl,none) -fg $color(red) -relief flat
         pack $This.fraconf.labURL2 -in $This.fraconf -anchor center -fill none

         #--- Bouton connecter
         button $This.fraconf.but1 -borderwidth 2 -text $panneau(remotectrl,connect) -command { ::remotectrl::cmdConnect }
         pack $This.fraconf.but1 -in $This.fraconf -anchor center -fill none -ipadx 3 -ipady 3

      pack $This.fraconf -side top -fill x

      #--- Frame du pointage
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Frame pour choisir un catalogue
         ::cataGoto::createFrameCatalogue $This.fra2.catalogue $panneau(remotectrl,getobj) 1 "::remotectrl"
         pack $This.fra2.catalogue -in $This.fra2 -anchor nw -side top -padx 4 -pady 1

         #--- Label de l'objet choisi
         label $This.fra2.lab1 -textvariable panneau(remotectrl,nomObjet) -relief flat
         pack $This.fra2.lab1 -in $This.fra2 -anchor center -padx 2 -pady 1

         #--- Entry pour l'objet a entrer
         entry $This.fra2.ent1 -font $audace(font,arial_8_b) -textvariable panneau(remotectrl,getobj) \
            -width 14 -relief groove
         pack $This.fra2.ent1 -in $This.fra2 -anchor center -pady 2

         #--- Bouton GOTO
         button $This.fra2.but1 -borderwidth 2 -text $panneau(remotectrl,goto) -command { ::remotectrl::cmdGoto }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill x -ipadx 15 -ipady 3

      pack $This.fra2 -side top -fill x

      bind $This.fra2.but1 <ButtonRelease-3> { ::remotectrl::cmdMatch }

      #--- Frame des coordonnees
      frame $This.fra3 -borderwidth 1 -relief groove

         set panneau(remotectrl,getra)  " "
         set panneau(remotectrl,getdec) " "

         #--- Label pour RA
         label $This.fra3.ent1 -font $audace(font,arial_10_b) -text $panneau(remotectrl,getra) -relief flat
         pack $This.fra3.ent1 -in $This.fra3 -anchor center -fill none -pady 0

         #--- Label pour DEC
         label $This.fra3.ent2 -font $audace(font,arial_10_b) -text $panneau(remotectrl,getdec) -relief flat
         pack $This.fra3.ent2 -in $This.fra3 -anchor center -fill none -pady 1

      pack $This.fra3 -side top -fill x

      set zone(radec) $This.fra3
      bind $zone(radec) <ButtonPress-1>      { ::remotectrl::cmdAfficheCoord0 }
      bind $zone(radec).ent1 <ButtonPress-1> { ::remotectrl::cmdAfficheCoord0 }
      bind $zone(radec).ent2 <ButtonPress-1> { ::remotectrl::cmdAfficheCoord0 }

      #--- Frame des boutons manuels
      frame $This.fra4 -borderwidth 1 -relief groove

         #--- Create frame of delay
         frame $This.fra4.after -width 27 -borderwidth 0 -relief flat

            #--- Write the label delay
            label $This.fra4.after.lab -text " $caption(remotectrl,delay)" -borderwidth 0 -relief flat
            pack $This.fra4.after.lab -in $This.fra4.after -side left

            #--- Write the entry
            entry $This.fra4.after.entry -font $audace(font,arial_8_b) -textvariable panneau(remotectrl,after) \
               -relief groove -width 4 -justify center
            pack $This.fra4.after.entry -in $This.fra4.after -side left -padx 0

            #--- Write the label milliseconds
            label $This.fra4.after.ms -text "$caption(remotectrl,ms)" -borderwidth 0 -relief flat
            pack $This.fra4.after.ms -in $This.fra4.after -side left

         pack $This.fra4.after -in $This.fra4 -side top -fill x -pady 1

         #--- Create the button 'E'
         frame $This.fra4.e -width 27 -borderwidth 0 -relief flat
         pack $This.fra4.e -in $This.fra4 -side left -expand true -fill y
         #--- Button-design 'E'
         button $This.fra4.e.canv1 -borderwidth 2 \
            -font [ list {Arial} 12 bold ] \
            -text "$caption(remotectrl,est)" \
            -width 2 \
            -anchor center \
            -relief ridge
         pack $This.fra4.e.canv1 -in $This.fra4.e -expand 1

         #--- Create the buttons 'N S'
         frame $This.fra4.ns -width 27 -borderwidth 0 -relief flat
         pack $This.fra4.ns -in $This.fra4 -side left -expand true -fill y
         #--- Button-design 'N'
         button $This.fra4.ns.canv1 -borderwidth 2 \
            -font [ list {Arial} 12 bold ] \
            -text "$caption(remotectrl,nord)" \
            -width 2 \
            -anchor center \
            -relief ridge
         pack $This.fra4.ns.canv1 -in $This.fra4.ns -expand 1 -side top

         #--- Write the label of moves speed
         label $This.fra4.ns.lab -font [list {Arial} 12 bold ] -textvariable audace(telescope,labelspeed) \
            -borderwidth 0 -relief flat
         pack $This.fra4.ns.lab -in $This.fra4.ns -expand 0 -side top -pady 6

         #--- Button-design 'S'
         button $This.fra4.ns.canv2 -borderwidth 2 \
            -font [ list {Arial} 12 bold ] \
            -text "$caption(remotectrl,sud)" \
            -width 2 \
            -anchor center \
            -relief ridge
         pack $This.fra4.ns.canv2 -in $This.fra4.ns -expand 1 -side bottom

         #--- Create the button 'W'
         frame $This.fra4.w -width 27 -borderwidth 0 -relief flat
         pack $This.fra4.w -in $This.fra4 -side left -expand true -fill y
         #--- Button-design 'W'
         button $This.fra4.w.canv1 -borderwidth 2 \
            -font [ list {Arial} 12 bold ] \
            -text "$caption(remotectrl,ouest)" \
            -width 2 \
            -anchor center \
            -relief ridge
         pack $This.fra4.w.canv1 -in $This.fra4.w -expand 1

         set zone(e) $This.fra4.e.canv1
         set zone(n) $This.fra4.ns.canv1
         set zone(s) $This.fra4.ns.canv2
         set zone(w) $This.fra4.w.canv1

      pack $This.fra4 -side top -fill x

      #--- Cardinal speed
      bind $This.fra4.ns.lab <ButtonPress-1> { ::remotectrl::cmdSpeed }

      #--- Cardinal moves
      bind $zone(e) <ButtonRelease-1> { catch { ::remotectrl::cmdPulse e } }
      bind $zone(w) <ButtonRelease-1> { catch { ::remotectrl::cmdPulse w } }
      bind $zone(s) <ButtonRelease-1> { catch { ::remotectrl::cmdPulse s } }
      bind $zone(n) <ButtonRelease-1> { catch { ::remotectrl::cmdPulse n } }

      #--- Frame des boutons manuels
      frame $This.fra5 -borderwidth 1 -relief groove

         #--- Create the button '+'
         frame $This.fra5.e -width 27 -borderwidth 0 -relief flat
         pack $This.fra5.e -in $This.fra5 -side left -expand true -fill y
         #--- Button-design '+'
         button $This.fra5.e.canv1 -borderwidth 2 \
            -font [ list {Arial} 12 bold ] \
            -text "+" \
            -width 2 \
            -anchor center \
            -relief ridge
         pack $This.fra5.e.canv1 -in $This.fra5.e -expand 1

         #--- Create the button focus speed
         frame $This.fra5.speed -width 27 -borderwidth 0 -relief flat
         pack $This.fra5.speed -in $This.fra5 -side left -expand true -fill y
         #--- Write the label of focus speed
         label $This.fra5.speed.lab -font [list {Arial} 12 bold ] -textvariable audace(focus,labelspeed) \
            -borderwidth 0 -relief flat
         pack $This.fra5.speed.lab -in $This.fra5.speed -expand 0 -side top -pady 6

         #--- Create the button '-'
         frame $This.fra5.w -width 27 -borderwidth 0 -relief flat
         pack $This.fra5.w -in $This.fra5 -side left -expand true -fill y
         #--- Button-design '-'
         button $This.fra5.w.canv1 -borderwidth 2 \
            -font [ list {Arial} 12 bold ] \
            -text "-" \
            -width 2 \
            -anchor center \
            -relief ridge
         pack $This.fra5.w.canv1 -in $This.fra5.w -expand 1

         set zone(+) $This.fra5.e.canv1
         set zone(-) $This.fra5.w.canv1

      pack $This.fra5 -side top -fill x

      #--- Foc speed
      bind $This.fra5.speed.lab <ButtonPress-1> { ::remotectrl::cmdFocusSpeed }

      #--- Foc moves
      bind $zone(+) <ButtonRelease-1> { catch { ::remotectrl::cmdPulseFoc + } }
      bind $zone(-) <ButtonRelease-1> { catch { ::remotectrl::cmdPulseFoc - } }

      #--- Frame de l'image
      frame $This.fra6 -borderwidth 1 -relief groove

         #--- Frame invisible pour le temps de pose
         frame $This.fra6.fra1

            #--- Entry pour l'objet a entrer
            entry $This.fra6.fra1.ent1 -font $audace(font,arial_8_b) -textvariable panneau(remotectrl,exptime) \
               -relief groove -width 5 -justify center
            pack $This.fra6.fra1.ent1 -in $This.fra6.fra1 -side left -fill none -padx 4 -pady 2

            #--- Label pour les secondes
            label $This.fra6.fra1.lab1 -text $panneau(remotectrl,secondes) -relief flat
            pack $This.fra6.fra1.lab1 -in $This.fra6.fra1 -side left -fill none -padx 1 -pady 1

         pack   $This.fra6.fra1 -in $This.fra6 -side top -fill x

         #--- Menu pour binning
         frame $This.fra6.optionmenu1 -borderwidth 0 -relief groove
            menubutton $This.fra6.optionmenu1.but_bin -text $panneau(remotectrl,bin) \
               -menu $This.fra6.optionmenu1.but_bin.menu -relief raised
            pack $This.fra6.optionmenu1.but_bin -in $This.fra6.optionmenu1 -side left -fill none
            set m [ menu $This.fra6.optionmenu1.but_bin.menu -tearoff 0 ]
            foreach valbin $panneau(remotectrl,choix_bin) {
               $m add radiobutton -label "$valbin" \
                  -indicatoron "1" \
                  -value "$valbin" \
                  -variable panneau(remotectrl,binning) \
                  -command { }
            }
            entry $This.fra6.optionmenu1.lab_bin -width 3 -font {arial 10 bold}  -relief groove \
              -textvariable panneau(remotectrl,binning) -justify center -state disabled
            pack $This.fra6.optionmenu1.lab_bin -in $This.fra6.optionmenu1 -side left -fill both -expand true
         pack $This.fra6.optionmenu1 -anchor n -fill x -expand 0 -pady 2

         #--- Bouton GO
         button $This.fra6.but1 -borderwidth 2 -text $panneau(remotectrl,go) -command { ::remotectrl::cmdGo }
         pack $This.fra6.but1 -in $This.fra6 -anchor center -fill x -ipadx 15 -ipady 3

      pack $This.fra6 -side top -fill x

      #--- Frame du mask
      frame $This.fram -borderwidth 1 -relief flat
      place $This.fram -x 3 -y 74 -width 200 -height 600 -anchor nw \
         -bordermode ignore

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
}

# ==============================================================================================
# ==============================================================================================
# ==============================================================================================
# ==============================================================================================
# ==============================================================================================

   proc wizCon1 { } {
      global audace conf panneau rpcid

      set base $panneau(remotectrl,wizCon1,base)
      if { [winfo exists $base] } {
         destroy $base
      }
      #--- New Toplevel
      toplevel $base -class Toplevel
      wm title $base $panneau(remotectrl,wizCon1,title)
      wm transient $base $audace(base)
      set posxWizCon1 [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
      set posyWizCon1 [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
      if {$rpcid(state)==""} {
         set texte "$panneau(remotectrl,wizCon1,toconnect)"
         wm geometry $base +[ expr $posxWizCon1 + 220 ]+[ expr $posyWizCon1 + 70 ]
      } elseif {$rpcid(state)=="server"} {
         set texte "$panneau(remotectrl,wizCon1,tounconnect_backyard)"
         wm geometry $base +[ expr $posxWizCon1 + 180 ]+[ expr $posyWizCon1 + 70 ]
      } else {
         set texte "$panneau(remotectrl,wizCon1,tounconnect_home)"
         wm geometry $base +[ expr $posxWizCon1 + 180 ]+[ expr $posyWizCon1 + 70 ]
      }
      wm resizable $base 0 0
      #--- Title
      label $base.lab_title2 -text "$panneau(remotectrl,wizCon1,title2)" -borderwidth 2 -font $panneau(remotectrl,font,title2)
      pack $base.lab_title2 -side top -anchor center -padx 20 -pady 5 -expand 0
      #--- Describe
      label $base.lab_desc -text $texte -borderwidth 2 -font $panneau(remotectrl,font,normal)
      pack $base.lab_desc -side top  -anchor center -padx 20 -pady 5 -expand 0
      #--- Buttons
      if {$rpcid(state)==""} {
         #--- Button HOME >>
         button $base.but_home -text $panneau(remotectrl,wizCon1,home) -borderwidth 2 \
            -font $panneau(remotectrl,font,button) -command { wizConClient }
         pack $base.but_home -side bottom -anchor center -padx 20 -pady 5 -ipadx 10 -ipady 5 -expand 0
         #--- Button BACKYARD >>
         button $base.but_backyard -text $panneau(remotectrl,wizCon1,backyard) -borderwidth 2 \
            -font $panneau(remotectrl,font,button) -command { wizConServer $panneau(remotectrl,port1) }
         pack $base.but_backyard -side bottom -anchor center -padx 20 -pady 5 -ipadx 10 -ipady 5 -expand 0
      } else {
         #--- Button << CANCEL
         button $base.but_backyard -text $panneau(remotectrl,wizCon1,cancel) -borderwidth 2 \
            -font $panneau(remotectrl,font,button) -command {
               global panneau
               destroy $panneau(remotectrl,wizCon1,base)
            }
         pack $base.but_backyard -side left -anchor se -padx 20 -pady 5 -ipadx 10 -ipady 5 -expand 0
         #--- Button DECONNECT >>
         if {$rpcid(state)=="server"} {
            button $base.but_home -text $panneau(remotectrl,wizCon1,unconnect_backyard) -borderwidth 2 \
               -font $panneau(remotectrl,font,button) -command {
                  ::$conf(confPad)::deletePluginInstance
                  wizDelServer
               }
         } else {
            button $base.but_home -text $panneau(remotectrl,wizCon1,unconnect_home) -borderwidth 2 \
               -font $panneau(remotectrl,font,button) -command {
                  ::$conf(confPad)::deletePluginInstance
                  wizDelClient
               }
         }
         pack $base.but_home -side right -anchor se -padx 20 -pady 5 -ipadx 10 -ipady 5 -expand 0
      }

      #---
      focus $base

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $base
   }

   proc wizConClient { } {
      global audace
      global panneau

      set base $panneau(remotectrl,wizCon1,base)
      if { [winfo exists $base] } {
         destroy $base
      }
      #--- New Toplevel
      toplevel $base -class Toplevel
      wm title $base $panneau(remotectrl,wizConClient,title)
      wm transient $base $audace(base)
      set posxWizCon1 [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
      set posyWizCon1 [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
      wm geometry $base +[ expr $posxWizCon1 + 170 ]+[ expr $posyWizCon1 + 70 ]
      wm resizable $base 0 0
      #--- Title
      label $base.lab_title2 -text "$panneau(remotectrl,wizConClient,title2)" -borderwidth 2 \
         -font $panneau(remotectrl,font,title2)
      pack $base.lab_title2 -side top -anchor center -padx 20 -pady 5 -expand 0
      #--- Describe
      frame $base.f1
         #---
         label $base.f1.lab_ip1 -text "$panneau(remotectrl,backyard) $panneau(remotectrl,ip)" \
            -font $panneau(remotectrl,font,normal)
         pack $base.f1.lab_ip1 -side left -anchor se -padx 20 -pady 5 -expand 0
         entry $base.f1.ent_ip1 -textvariable panneau(remotectrl,ip1) -width 15 -relief groove \
            -font $panneau(remotectrl,font,normal) -justify center
         pack $base.f1.ent_ip1 -side left -anchor se -pady 5 -expand 0
         #---
      pack $base.f1 -side top -anchor sw
      frame $base.f2
         #---
         label $base.f2.lab_port1 -text "$panneau(remotectrl,backyard) $panneau(remotectrl,port_rcp)" \
            -font $panneau(remotectrl,font,normal)
         pack $base.f2.lab_port1 -side left -anchor se -padx 20 -pady 5 -expand 0
         entry $base.f2.ent_port1 -textvariable panneau(remotectrl,port1) -width 5 -relief groove \
            -font $panneau(remotectrl,font,normal) -justify center
         pack $base.f2.ent_port1 -side left -anchor se -pady 5 -expand 0
         #---
      pack $base.f2 -side top -anchor sw
      frame $base.f3
         #---
         label $base.f3.lab_ip2 -text "$panneau(remotectrl,home) $panneau(remotectrl,ip)" \
            -font $panneau(remotectrl,font,normal)
         pack $base.f3.lab_ip2 -side left -anchor se -padx 20 -pady 5 -expand 0
         entry $base.f3.ent_ip2 -textvariable panneau(remotectrl,ip2) -width 15 -relief groove \
            -font $panneau(remotectrl,font,normal) -justify center
         pack $base.f3.ent_ip2 -side left -anchor se -pady 5 -expand 0
         #---
      pack $base.f3 -side top -anchor sw
      frame $base.f4
         #---
         label $base.f4.lab_port2 -text "$panneau(remotectrl,home) $panneau(remotectrl,port_rcp)" \
            -font $panneau(remotectrl,font,normal)
         pack $base.f4.lab_port2 -side left -anchor se -padx 20 -pady 5 -expand 0
         entry $base.f4.ent_port2 -textvariable panneau(remotectrl,port2) -width 5 -relief groove \
            -font $panneau(remotectrl,font,normal) -justify center
         pack $base.f4.ent_port2 -side left -anchor se -pady 5 -expand 0
         #---
      pack $base.f4 -side top -anchor sw
      frame $base.f5
         #---
         label $base.f5.lab_path -text "$panneau(remotectrl,path_img)" -font $panneau(remotectrl,font,normal)
         pack $base.f5.lab_path -side left -anchor se -padx 20 -pady 5 -expand 0
         entry $base.f5.ent_path -textvariable panneau(remotectrl,path_img) -width 5 -relief groove \
            -font $panneau(remotectrl,font,normal) -justify center
         pack $base.f5.ent_path -side left -anchor center -pady 5 -expand 0
         #---
      pack $base.f5 -side top -anchor sw
      #--- Button << CANCEL
      button $base.but_backyard -text $panneau(remotectrl,wizCon1,cancel) -borderwidth 2 \
         -font $panneau(remotectrl,font,button) -command {
            global panneau
            destroy $panneau(remotectrl,wizCon1,base)
         }
      pack $base.but_backyard -side left -anchor se -padx 20 -pady 5 -ipadx 10 -ipady 5 -expand 0
      #--- Button CONNECT >>
      button $base.but_home -text $panneau(remotectrl,wizConClient,connect) -borderwidth 2 \
         -font $panneau(remotectrl,font,button) -command {
            global panneau
            ::remotectrl::enregistrementVar
            wizConClient2 $panneau(remotectrl,ip1) $panneau(remotectrl,port1) $panneau(remotectrl,ip2) $panneau(remotectrl,port2)
         }
      pack $base.but_home -side right -anchor se -padx 20 -pady 5 -ipadx 10 -ipady 5 -expand 0

      #---
      focus $base

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $base
   }

   proc wizConClient2 { ip1 port1 ip2 port2 } {
      global audace
      global panneau
      global color
      global rpcid

      set base $panneau(remotectrl,wizCon1,base)
      if { [winfo exists $base] } {
         destroy $base
      }
      if {($ip2!="")&&($port2!="")} {
         set num_port [ catch { set res [create_client $panneau(remotectrl,ip1) $panneau(remotectrl,port1) $panneau(remotectrl,ip2) $panneau(remotectrl,port2)] } msg ]
      } else {
         set num_port [ catch { set res [create_client $panneau(remotectrl,ip1) $panneau(remotectrl,port1)] } msg ]
      }
      if { $num_port == "1" } {
         wizDelClient
         tk_messageBox -type ok -icon warning -title "$panneau(remotectrl,wizConClient,attention)" \
            -message "$panneau(remotectrl,panneau,port_utilise)"
      } else {
         if {$rpcid(state)==""} {
            return
         }
         set This $panneau(remotectrl,base)
         if {$rpcid(state)=="client"} {
            $This.fraconf.labURL2 configure -text $panneau(remotectrl,home) -fg $color(blue)
         }
         if {$rpcid(state)=="client/server"} {
            $This.fraconf.labURL2 configure -text $panneau(remotectrl,home) -fg $color(blue)
         }
         $This.fraconf.but1 configure -text $panneau(remotectrl,unconnect)
         #--- Le client demasque les commandes
         place $This.fram -x 3 -y 74 -width 200 -height 1 -anchor nw \
            -bordermode ignore
         ::remotectrl::cmdAfficheCoord
      }
   }

   proc wizConServer { port } {
      global audace
      global panneau
      global color
      global rpcid

      set base $panneau(remotectrl,wizCon1,base)
      if { [winfo exists $base] } {
         destroy $base
      }
      #--- New Toplevel
      toplevel $base -class Toplevel
      wm title $base $panneau(remotectrl,wizConClient,title)
      wm transient $base $audace(base)
      set posxWizCon1 [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
      set posyWizCon1 [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
      wm geometry $base +[ expr $posxWizCon1 + 190 ]+[ expr $posyWizCon1 + 70 ]
      wm resizable $base 0 0
      #--- Title
      label $base.lab_title2 -text "$panneau(remotectrl,wizConClient,title3)" -borderwidth 2 \
         -font $panneau(remotectrl,font,title2)
      pack $base.lab_title2 -side top -anchor center -padx 20 -pady 5 -expand 0
      #--- Describe
      frame $base.f1
         #---
         label $base.f1.lab_port1 -text "$panneau(remotectrl,backyard) $panneau(remotectrl,port_rcp)" \
            -font $panneau(remotectrl,font,normal)
         pack $base.f1.lab_port1 -side left -anchor se -padx 20 -pady 5 -expand 0
         entry $base.f1.ent_port1 -textvariable panneau(remotectrl,port1) -width 5 -relief groove \
            -font $panneau(remotectrl,font,normal) -justify center
         pack $base.f1.ent_port1 -side left -anchor se -pady 5 -expand 0
         #---
      pack $base.f1 -side top -anchor sw
      frame $base.f2
         #---
         label $base.f2.lab_port1 -text "$panneau(remotectrl,backyard) $panneau(remotectrl,port_ftp)" \
            -font $panneau(remotectrl,font,normal)
         pack $base.f2.lab_port1 -side left -anchor se -padx 20 -pady 5 -expand 0
         entry $base.f2.ent_port1 -textvariable panneau(remotectrl,ftp_port1) -width 5 -relief groove \
            -font $panneau(remotectrl,font,normal) -justify center
         pack $base.f2.ent_port1 -side left -anchor se -pady 5 -expand 0
         #---
      pack $base.f2 -side top -anchor sw

      #--- Button << CANCEL
      button $base.but_backyard -text $panneau(remotectrl,wizCon1,cancel) -borderwidth 2 \
         -font $panneau(remotectrl,font,button) -command {
            global panneau
            destroy $panneau(remotectrl,wizCon1,base)
          }
      pack $base.but_backyard -side left -anchor se -padx 20 -pady 5 -ipadx 10 -ipady 5 -expand 0
      #--- Button CONNECT >>
      button $base.but_home -text $panneau(remotectrl,wizConClient,connect) -borderwidth 2 \
         -font $panneau(remotectrl,font,button) -command {
            global audace
            global panneau
            ::remotectrl::enregistrementVar
            if {$panneau(remotectrl,debug)=="no"} {
               if {[::cam::list]==""} {
                  ::confCam::run
                  tkwait window $audace(base).confCam
               }
               if {[::tel::list]==""} {
                  ::confTel::run
                  tkwait window $audace(base).confTel
               }
            }
            set num_port [ catch { set res [create_server $panneau(remotectrl,port1)] } msg ]
            if { $num_port == "1" } {
               wizDelServer
               tk_messageBox -type ok -icon warning -title "$panneau(remotectrl,wizConClient,attention)" \
                  -message "$panneau(remotectrl,panneau,port_utilise)"
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
               if { [winfo exists $base] } {
                  destroy $base
               }
               if {$rpcid(state)==""} {
                  return
               }
               set This $panneau(remotectrl,base)
               $This.fraconf.labURL2 configure -text $panneau(remotectrl,backyard) -fg $color(blue)
               $This.fraconf.but1 configure -text $panneau(remotectrl,unconnect)
               #--- Le serveur masque les commandes
               place $This.fram -x 3 -y 74 -width 200 -height 600 -anchor nw \
                  -bordermode ignore
            }
         }
      pack $base.but_home -side right -anchor se -padx 20 -pady 5 -ipadx 10 -ipady 5 -expand 0

      #---
      focus $base

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $base
   }

   proc wizDelServer { } {
      variable This
      global audace
      global panneau
      global rpcid
      global color

      set res [delete_server]
      set base $panneau(remotectrl,wizCon1,base)
      if { [winfo exists $base] } {
         destroy $base
      }
      if {$rpcid(state)!=""} {
         return
      }
      set This $panneau(remotectrl,base)
      $This.fraconf.labURL2 configure -text $panneau(remotectrl,none) -fg $color(red)
      $This.fraconf.but1 configure -text $panneau(remotectrl,connect)
      #--- Masque les commandes
      place $This.fram -x 3 -y 74 -width 200 -height 600 -anchor nw \
         -bordermode ignore
   }

   proc wizDelClient { } {
      variable This
      global audace
      global panneau
      global rpcid
      global color

      set res [delete_client]
      set base $panneau(remotectrl,wizCon1,base)
      if { [winfo exists $base] } {
         destroy $base
      }
      if {$rpcid(state)!=""} {
         return
      }
      set This $panneau(remotectrl,base)
      $This.fraconf.labURL2 configure -text $panneau(remotectrl,none) -fg $color(red)
      $This.fraconf.but1 configure -text $panneau(remotectrl,connect)
      #--- Masque les commandes
      place $This.fram -x 3 -y 74 -width 200 -height 600 -anchor nw \
         -bordermode ignore
   }

