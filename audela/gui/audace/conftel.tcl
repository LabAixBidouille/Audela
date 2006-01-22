#
# Fichier : conftel.tcl
# Description : Gere des objets 'monture' (ex-objets 'telescope')
# Date de mise a jour : 27 novembre 2005
#

#--- Initialisation des variables confTel(lx200,connect), (telcom,connect), (lxnet,connect), (temmaconnect),
#--- (mcmt,connect) et confTel(...)
global confTel

set confTel(lx200,connect)          "0"
set confTel(telcom,connect)         "0"
set confTel(lxnet,connect)          "0"
set confTel(temma,connect)          "0"
set confTel(mcmt,connect)           "0"
set confTel(fenetre,mobile,valider) "0"

namespace eval ::confTel {
   namespace export run
   namespace export ok
   namespace export appliquer
   namespace export fermer
   variable This
   global confTel

   #
   # confTel::init (est lance automatiquement au chargement de ce fichier tcl)
   # Initialise les variables conf(...) et caption(...) 
   # Demarre le driver selectionne par defaut
   #
   proc init { } {
      global audace conf
 
      #--- initConf
      if { ! [ info exists conf(raquette) ] }           { set conf(raquette)           "1" }
      if { ! [ info exists conf(telescope) ] }          { set conf(telescope)          "lx200" }
      if { ! [ info exists conf(telescope,start) ] }    { set conf(telescope,start)    "0" }
      if { ! [ info exists conf(telescope,position) ] } { set conf(telescope,position) "+110+20" }

      #--- Charge le fichier caption
      uplevel #0 "source \"[ file join $audace(rep_caption) conftel.cap ]\""

      #--- Charge les fichiers auxiliaires
      uplevel #0 "source \"[ file join $audace(rep_plugin) mount audecom audecom.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) mount avrcom avrcom.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) mount ouranos ouranoscom.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) mount temma temma.tcl ]\""

      #--- Charge le nom de la raquette utilisee
      ::confPad::getLabelPad
   }

   #
   # confTel::run
   # Cree la fenetre de choix et de configuration des telescopes
   # This = chemin de la fenetre
   # conf(telescope) = nom du telescope (lx200, ouranos, audecom, compad, avrcom, telcom, lxnet, temma, mcmt)
   #
   proc run { } {
      variable This
      global audace conf confTel

      set This "$audace(base).confTel"
      createDialog
      if { [ info exists conf ] } {
         select $conf(telescope)
      } else {
         select lx200
      }
     ### catch { tkwait visibility $This }
   }

   #
   # confTel::ok
   # Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer
   # la configuration, et fermer la fenetre de reglage du telescope
   #
   proc ok { } {
      variable This

      $This.cmd.ok configure -relief groove -state disabled
      $This.cmd.appliquer configure -state disabled
      $This.cmd.aide configure -state disabled
      $This.cmd.fermer configure -state disabled
      appliquer
      fermer
   }

   #
   # confTel::appliquer
   # Fonction appellee lors de l'appui sur le bouton 'Appliquer' pour
   # memoriser et appliquer la configuration
   #
   proc appliquer { } {
      variable This
      global audace caption conf confTel frmm

      set frm $frmm(Telscp3)
      $This.cmd.ok configure -state disabled
      $This.cmd.appliquer configure -relief groove -state disabled
      $This.cmd.aide configure -state disabled
      $This.cmd.fermer configure -state disabled
      if { [ winfo exists $frm.ctlking ] } {
         $frm.ctlking configure -text "$caption(conftel,audecom_ctl_king)" -state disabled
         update
      }
      widgetToConf
      configureTelescope
      set confTel(fenetre,mobile,valider) "0"
      $This.cmd.ok configure -state normal
      $This.cmd.appliquer configure -relief raised -state normal
      $This.cmd.aide configure -state normal
      $This.cmd.fermer configure -state normal
      if { $conf(telescope) == "audecom" } {
         if { [ winfo exists $audace(base).confAudecomKing ] } {
            $frm.ctlking configure -text "$caption(conftel,audecom_ctl_king)" -state disabled
            update
         } else {
            catch {
               $frm.ctlking configure -text "$caption(conftel,audecom_ctl_king)" -state normal \
                  -command { ::confAudecomKing::run "$audace(base).confAudecomKing" }
               update
            }
         }
      }
   }

   #
   # confTel::afficherAide
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc afficherAide { } {
      variable This
      global confTel
      global help

      $This.cmd.ok configure -state disabled
      $This.cmd.appliquer configure -state disabled
      $This.cmd.aide configure -relief groove -state disabled
      $This.cmd.fermer configure -state disabled
      ::audace::showHelpPlugin mount $confTel(tel) "$confTel(tel).htm"
      $This.cmd.ok configure -state normal
      $This.cmd.appliquer configure -state normal
      $This.cmd.aide configure -relief raised -state normal
      $This.cmd.fermer configure -state normal
   }

   #
   # confTel::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This

      ::confTel::recup_position
      $This.cmd.ok configure -state disabled
      $This.cmd.appliquer configure -state disabled
      $This.cmd.aide configure -state disabled
      $This.cmd.fermer configure -relief groove -state disabled
      destroy $This
   }

   #
   # confTel::connectLX200
   # Permet d'activer ou de désactiver le bouton Mise a jour heure, longitude, latitude et altitude du LX200,
   # ainsi que la tempo de l'interface Ite-lente quand on passe d'un onglet 'Telescope' a l'autre en evitant
   # les erreurs dues a un appui 'curieux' sur ce bouton
   #
   proc connectLX200 { } {
      global caption conf confTel frmm

      catch {
         set frm $frmm(Telscp1)
         if { $confTel(lx200,connect) == "1" } {
            if { $conf(lx200,modele) == "$caption(conftel,modele_lx200)" } {
               $frm.majpara configure -state normal -command {
                  catch {
                     tel$audace(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
                     tel$audace(telNo) home $audace(posobs,observateur,gps)
                  }
               }
            } elseif { $conf(lx200,modele) == "$caption(conftel,modele_skysensor)" } {
               $frm.majpara configure -state normal -command {
                  catch {
                     tel$audace(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
                     tel$audace(telNo) home $audace(posobs,observateur,gps)
                  }
               }
            } elseif { $conf(lx200,modele) == "$caption(conftel,modele_gemini)" } {
               $frm.majpara configure -state normal -command {
                  catch {
                     tel$audace(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
                     tel$audace(telNo) home $audace(posobs,observateur,gps)
                  }
               }
            } else {
               $frm.majpara configure -state disabled
            }
         } else {
            $frm.majpara configure -state disabled
         }
      }
   }

   #
   # confTel::connectIte-lente
   # Permet d'activer ou de désactiver la tempo de l'interface Ite-lente
   #
   proc connectIte-lente { } {
      global caption confTel frmm

      catch {
         set frm $frmm(Telscp1)
         if { $confTel(lx200,modele) == "$caption(conftel,modele_ite-lente)" } {
	      #--- Label de la tempo Ite-lente
	      label $frm.lab4 -text "$caption(conftel,ite-lente_tempo)"
	      pack $frm.lab4 -in $frm.frame4a -anchor center -side left -padx 10 -pady 10
            #--- Entree de la tempo Ite-lente
	      entry $frm.tempo -textvariable confTel(lx200,ite-lente_tempo) -justify center -width 5
	      pack $frm.tempo -in $frm.frame4a -anchor center -side left -padx 10 -pady 10
         } else {
            destroy $frm.lab4 ; destroy $frm.tempo
         }
      }
   }

   #
   # confTel::connectOuranos
   # Permet d'activer ou de désactiver les radio-boutons 'Etoiles', 'Messier', 'NGC' et 'IC' ainsi que les
   # boutons 'Regler', 'Stopper' et 'Lire' quand on passe d'un onglet 'Telescope' a l'autre en evitant les
   # erreurs dues a un appui 'curieux' sur ces boutons
   #
   proc connectOuranos { } {
      global caption confTel frmm

      catch {
         set frm $frmm(Telscp2)
         if { $confTel(ouranos,connect) == "1" } {
            $frm.but_init configure -relief raised -state normal -command { ::OuranosCom::find_res }
	      $frm.but_close configure -relief raised -state normal -command { ::OuranosCom::close_com }
	      $frm.but_read configure -relief raised -state normal -command { ::OuranosCom::go_ouranos }
            if { $confTel(conf_ouranos,show_coord) == "1" } {
               $frm.rad0 configure -state normal -command {
                     set confTel(conf_ouranos,obj_choisi) $caption(conftel,ouranos_etoile)
                     ::cataGoto::CataEtoiles
                  }
               $frm.rad1 configure -state normal -command {
                     set confTel(conf_ouranos,obj_choisi) $caption(conftel,ouranos_messier)
                     ::cataGoto::CataObjet $caption(conftel,ouranos_messier)
                  }
               $frm.rad2 configure -state normal -command {
                     set confTel(conf_ouranos,obj_choisi) $caption(conftel,ouranos_ngc)
                     ::cataGoto::CataObjet $caption(conftel,ouranos_ngc)
                  }
               $frm.rad3 configure -state normal -command {
                     set confTel(conf_ouranos,obj_choisi) $caption(conftel,ouranos_ic)
                     ::cataGoto::CataObjet $caption(conftel,ouranos_ic)
                  }
            } else {
               $frm.rad0 configure -state disabled
               $frm.rad1 configure -state disabled
               $frm.rad2 configure -state disabled
               $frm.rad3 configure -state disabled
            }
         } else {
            $frm.but_init configure -state disabled
	      $frm.but_close configure -state disabled
	      $frm.but_read configure -state disabled
            $frm.rad0 configure -state disabled
            $frm.rad1 configure -state disabled
            $frm.rad2 configure -state disabled
            $frm.rad3 configure -state disabled
         }
      }
   }

   #
   # confTel::connectAudeCom
   # Permet d'activer ou de désactiver le bouton 'Controle de la vitesse de King' quand on passe d'un onglet
   # 'Telescope' a l'autre en evitant les erreurs dues a un appui 'curieux' sur ce bouton 
   #
   proc connectAudeCom { } {
      global caption confTel frmm

      catch {
         set frm $frmm(Telscp3)
         if { $confTel(audecom,connect) == "1" } {
            if { [ winfo exists $frm.ctlking ] } {
            } else {
               button $frm.ctlking -text "$caption(conftel,audecom_ctl_king)" -state disabled
	         pack $frm.ctlking -in $frm.frame14 -anchor center -side top -pady 3 -ipadx 10 -ipady 5 -expand true
            }
         } else {
            destroy $frm.ctlking
         }
         #--- Fonctionnalités d'une monture equatoriale allemande pilotee par AudeCom
         ::confTel::config_equatorial_audecom
         #--- Mise a jour dynamique des couleurs
         ::confColor::applyColor $frm
      }
   }

   #
   # confTel::config_equatorial_audecom
   # Permet d'afficher les fonctionnalites d'une monture equatoriale allemande pilotee par AudeCom
   #
   proc config_equatorial_audecom { } {
      global audace caption conf confTel frmm

      catch {
         set frm $frmm(Telscp3)
         if { $confTel(conf_audecom,german) == "1" } {
            #---
            destroy $frm.pos_tel
            destroy $frm.pos_tel_ew
            destroy $frm.pos_tel_est
            destroy $frm.chg_pos_tel
            #--- Position du telescope sur la monture equatoriale allemande : A l'est ou a l'ouest
            label $frm.pos_tel -text "$caption(conftel,position_telescope)"
	      pack $frm.pos_tel -in $frm.frame19 -anchor center -side left -padx 10 -pady 3
            #---
            label $frm.pos_tel_ew -width 15 -anchor w -textvariable audace(pos_tel_ew)
            pack $frm.pos_tel_ew -in $frm.frame19 -anchor center -side left
            #--- Nouvelle position d'origine du telescope : A l'est ou a l'ouest
            label $frm.pos_tel_est -text "$caption(conftel,change_position_telescope)"
            pack $frm.pos_tel_est -in $frm.frame19 -anchor center -side left -padx 10 -pady 3
            #---
            if { $confTel(audecom,connect) == "1" } {
               button $frm.chg_pos_tel -relief raised -state normal -textvariable audace(chg_pos_tel) -command {
                 ### set pos_tel [ tel$audace(telNo) german ]
                 ### if { $pos_tel == "E" } {
                 ###    tel$audace(telNo) german W
                 ### } elseif { $pos_tel == "W" } {
                 ###    tel$audace(telNo) german E
                 ### }
                 ### ::telescope::monture_allemande
               }
               pack $frm.chg_pos_tel -in $frm.frame19 -anchor center -side left -padx 10 -pady 3 -ipadx 5 -ipady 5
            } else {
               button $frm.chg_pos_tel -text "  ?  " -relief raised -state disabled
               pack $frm.chg_pos_tel -in $frm.frame19 -anchor center -side left -padx 10 -pady 3 -ipadx 5 -ipady 5
            }
         } else {
            destroy $frm.pos_tel
            destroy $frm.pos_tel_ew
            destroy $frm.pos_tel_est
            destroy $frm.chg_pos_tel
         }
         #--- Mise a jour dynamique des couleurs
         ::confColor::applyColor $frm
      }
   }

   #
   # confTel::connectAvrCom
   # Permet d'activer ou de désactiver les boutons 'Initialiser' et 'Transmettre' quand on passe d'un onglet
   # 'Telescope' a l'autre en evitant les erreurs dues a un appui 'curieux' sur ces boutons
   #
   proc connectAvrCom { } {
      global avrcom caption confTel frmm

      catch {
         set frm $frmm(Telscp5)
         if { $confTel(avrcom,connect) == "1" } {
            $frm.but_init configure -state normal -command { ::AvrCom::go_pad }
	      $frm.but_send configure -state normal -command { ::AvrCom::send_pad $avrcom(cmd) }
         } else {
            $frm.but_init configure -state disabled
	      $frm.but_send configure -state disabled
         }
      }
   }

   #
   # confTel::connectLXnet
   # Permet d'activer ou de désactiver le bouton Mise a jour heure, longitude, latitude et altitude du LX200 
   # via LXnet quand on passe d'un onglet 'Telescope' a l'autre en evitant les erreurs dues a un appui 
   # 'curieux' sur ce bouton
   #
   proc connectLXnet { } {
      global caption conf confTel frmm

      catch {
         set frm $frmm(Telscp7)
         if { $confTel(lxnet,connect) == "1" } {
            if { $conf(lxnet,modele) == "$caption(conftel,modele_lx200)" } {
               $frm.majpara configure -state normal -command {
                  catch {
                     tel$audace(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
                     tel$audace(telNo) home $audace(posobs,observateur,gps)
                  }
               }
            } elseif { $conf(lxnet,modele) == "$caption(conftel,modele_skysensor)" } {
               $frm.majpara configure -state normal -command {
                  catch {
                     tel$audace(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
                     tel$audace(telNo) home $audace(posobs,observateur,gps)
                  }
               }
            } elseif { $conf(lxnet,modele) == "$caption(conftel,modele_gemini)" } {
               $frm.majpara configure -state normal -command {
                  catch {
                     tel$audace(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
                     tel$audace(telNo) home $audace(posobs,observateur,gps)
                  }
               }
            } else {
               $frm.majpara configure -state disabled
            }
         } else {
            $frm.majpara configure -state disabled
         }
      }
   }

   #
   # confTel::connectTemma
   # Permet d'activer ou de désactiver les boutons 'Initialisation au zenith' et '  ?  ' quand on passe d'un onglet 
   # 'Telescope' a l'autre en evitant les erreurs dues a un appui 'curieux' sur ces boutons
   #
   proc connectTemma { } {
      global audace confTel frmm

      catch {
         set frm $frmm(Telscp8)
         if { $confTel(temma,connect) == "1" } {
            $frm.init_zenith configure -state normal -command { 
               tel$audace(telNo) initzenith
               ::telescope::afficheCoord
            }
            $frm.chg_pos_tel configure -state normal -textvariable audace(chg_pos_tel) -command { 
               set pos_tel [ tel$audace(telNo) german ]
               if { $pos_tel == "E" } {
                  tel$audace(telNo) german W
               } elseif { $pos_tel == "W" } {
                  tel$audace(telNo) german E
               }
               ::telescope::monture_allemande
            }
         } else {
            $frm.init_zenith configure -state disabled
            $frm.chg_pos_tel configure -text "  ?  " -state disabled
         }
      }
   }

   #
   # confTel::config_correc_Temma
   # Permet d'afficher une ou deux echelles de reglage de la vitesse normale de correction
   #
   proc config_correc_Temma { } {
      global caption conf confTel frmm

      catch {
         set frm $frmm(Telscp8)
         if { $confTel(temma,liaison) != "1" } {

            destroy $frm.lab3
            destroy $frm.liaison
            destroy $frm.lab4
            destroy $frm.correc_variantAD
            destroy $frm.correc_variantDec

            #--- Label de la correction en AD
            label $frm.lab3 -text "$caption(conftel,temma_correc_AD)"
            pack $frm.lab3 -in $frm.frame4 -anchor e -side top -pady 7

            #--- Le checkbutton pour la liaison physique des 2 reglages en Ad et en Dec.
            checkbutton $frm.liaison -text "$caption(conftel,temma_liaison_AD_Dec)" -highlightthickness 0 \
               -variable confTel(temma,liaison) -command { ::confTel::config_correc_Temma }
            pack $frm.liaison -in $frm.frame4 -anchor w -side top -padx 10

            #--- Label de la correction en Dec
            label $frm.lab4 -text "$caption(conftel,temma_correc_Dec)"
            pack $frm.lab4 -in $frm.frame4 -anchor e -side top -pady 7

            #--- Reglage de la vitesse de correction en AD pour la vitesse normale (NS)
            scale $frm.correc_variantAD -from 10 -to 90 -length 210 -orient horizontal -showvalue true -tickinterval 10 \
               -borderwidth 2 -relief groove -variable confTel(temma,correc_AD) -width 10
            pack $frm.correc_variantAD -in $frm.frame5 -side top -padx 10

            #--- Reglage de la vitesse de correction en Dec. pour la vitesse normale (NS)
            scale $frm.correc_variantDec -from 10 -to 90 -length 210 -orient horizontal -showvalue true -tickinterval 10 \
               -borderwidth 2 -relief groove -variable confTel(temma,correc_Dec) -width 10
            pack $frm.correc_variantDec -in $frm.frame5 -side top -padx 10

         } else {

            destroy $frm.lab3
            destroy $frm.liaison
            destroy $frm.lab4
            destroy $frm.correc_variantAD
            destroy $frm.correc_variantDec

            #--- Label de la correction en AD
            label $frm.lab3 -text "$caption(conftel,temma_correc_AD)"
            pack $frm.lab3 -in $frm.frame4 -anchor e -side top

            #--- Le checkbutton pour la liaison physique des 2 reglages en Ad et en Dec.
            checkbutton $frm.liaison -text "$caption(conftel,temma_liaison_AD_Dec)" -highlightthickness 0 \
               -variable confTel(temma,liaison) -command { ::confTel::config_correc_Temma }
            pack $frm.liaison -in $frm.frame4 -anchor w -side top -padx 10

            #--- Label de la correction en Dec
            label $frm.lab4 -text "$caption(conftel,temma_correc_Dec)"
            pack $frm.lab4 -in $frm.frame4 -anchor e -side top

            #--- Reglage de la vitesse de correction en AD pour la vitesse normale (NS)
            scale $frm.correc_variantAD -from 10 -to 90 -length 210 -orient horizontal -showvalue true -tickinterval 10 \
               -borderwidth 2 -relief groove -variable confTel(temma,correc_AD) -width 10
            pack $frm.correc_variantAD -in $frm.frame5 -side top -padx 10

            #--- Liaison des corrections en AD et en Dec.
            set confTel(temma,correc_Dec) $confTel(temma,correc_AD)

         }
         #--- Mise a jour dynamique des couleurs
         ::confColor::applyColor $frm
      }
   }

   #
   # confTel::MatchOuranos
   # Permet de gerer l'affichage du bouton MATCH d'Ouranos et informations associes ainsi que du bouton
   # transfert des coordonnees pour MATCH
   #
   proc MatchOuranos { } {
      global audace caption confTel frmm ouranoscom

      catch {
         set frm $frmm(Telscp2)
         destroy $frm.match_ra
         destroy $frm.match_ra_entry
         destroy $frm.match_dec
         destroy $frm.match_dec_entry

         if { $confTel(conf_ouranos,show_coord) == "1" } {
            if { $ouranoscom(lecture) == "0" } {
               #--- Bouton MATCH avec entry inactif
               $frm.but_match configure -state disabled
            } elseif { $ouranoscom(lecture) == "1" } {
               #--- Bouton MATCH avec entry actif
               $frm.but_match configure -text "$caption(conftel,ouranos_match)" -width 8 -state normal \
                  -command { ::OuranosCom::match_ouranos }
               update
            }
	      #--- Valeur Dec. en ° ' "
            entry $frm.match_dec_entry -textvariable confTel(conf_ouranos,match_dec) -justify center -width 12
	      pack $frm.match_dec_entry -in $frm.frame4 -anchor center -side right -padx 10
	      #--- Commentaires Dec.
	      label $frm.match_dec -text "$caption(conftel,dec) $caption(conftel,dms_angle)"
	      pack $frm.match_dec -in $frm.frame4 -anchor center -side right -padx 10
            #--- Gestion des evenements Dec.
            bind $frm.match_dec_entry <Enter> { ::confTel::Format_Match_Dec }
            bind $frm.match_dec_entry <Leave> { destroy $audace(base).format_match_dec }
	      #--- Valeur AD en h mn s
            entry $frm.match_ra_entry -textvariable confTel(conf_ouranos,match_ra) -justify center -width 12
	      pack $frm.match_ra_entry -in $frm.frame4 -anchor center -side right -padx 10
	      #--- Commentaires AD
	      label $frm.match_ra -text "$caption(conftel,ra) $caption(conftel,hms_angle)"
	      pack $frm.match_ra -in $frm.frame4 -anchor center -side right -padx 10
            #--- Gestion des evenements AD
            bind $frm.match_ra_entry <Enter> { ::confTel::Format_Match_AD }
            bind $frm.match_ra_entry <Leave> { destroy $audace(base).format_match_ad }
            #--- Mise a jour dynamique des couleurs
            ::confColor::applyColor $frm
         } else {
            #--- Bouton MATCH sans entry inactif
	      $frm.but_match configure -state disabled
         }
      }
   }

   #
   # confTel::radio_bouton_Ouranos
   # Permet d'activer ou de désactiver les radio-boutons 'Etoiles', 'Messier', 'NGC' et 'IC'
   #
   proc radio_bouton_Ouranos { } {
      global caption conf confTel frmm

      catch {
         set frm $frmm(Telscp2)
         if { ( $confTel(conf_ouranos,show_coord) == "1" ) && ( $confTel(ouranos,connect) == "1" ) } {
            $frm.rad0 configure -state normal -command {
                  set confTel(conf_ouranos,obj_choisi) $caption(conftel,ouranos_etoile)
                  ::cataGoto::CataEtoiles
               }
            $frm.rad1 configure -state normal -command {
                  set confTel(conf_ouranos,obj_choisi) $caption(conftel,ouranos_messier)
                  ::cataGoto::CataObjet $caption(conftel,ouranos_messier)
               }
            $frm.rad2 configure -state normal -command {
                  set confTel(conf_ouranos,obj_choisi) $caption(conftel,ouranos_ngc)
                  ::cataGoto::CataObjet $caption(conftel,ouranos_ngc)
               }
            $frm.rad3 configure -state normal -command {
                  set confTel(conf_ouranos,obj_choisi) $caption(conftel,ouranos_ic)
                  ::cataGoto::CataObjet $caption(conftel,ouranos_ic)
               }
         } else {
            $frm.rad0 configure -state disabled
            $frm.rad1 configure -state disabled
            $frm.rad2 configure -state disabled
            $frm.rad3 configure -state disabled
         }
      }
   }

   #
   # confTel::recup_position
   # Permet de recuperer et de sauvegarder la position de la fenetre de configuration du telescope
   #
   proc recup_position { } {
      variable This
      global conf confTel

      set confTel(telescope,geometry) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $confTel(telescope,geometry) ] ]
      set fin [ string length $confTel(telescope,geometry) ]
      set confTel(telescope,position) "+[ string range $confTel(telescope,geometry) $deb $fin ]"
      #---
      set conf(telescope,position) $confTel(telescope,position)
   }	

   proc createDialog { } {
      variable This
      global audace caption conf confTel

      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         select $conf(telescope)
         focus $This
         return
      }
      #---
      set confTel(telescope,position) $conf(telescope,position)
      #---
      if { [ info exists confTel(telescope,geometry) ] } {
         set deb [ expr 1 + [ string first + $confTel(telescope,geometry) ] ]
         set fin [ string length $confTel(telescope,geometry) ]
         set confTel(telescope,position) "+[ string range $confTel(telescope,geometry) $deb $fin ]"
      }
      #---
      toplevel $This
      if { $::tcl_platform(os) == "Linux" } {
         wm geometry $This 640x445$confTel(telescope,position)
         wm minsize $This 640 445
      } else {
         wm geometry $This 510x445$confTel(telescope,position)
         wm minsize $This 510 445
      }
      wm resizable $This 1 0
      wm deiconify $This
      wm title $This "$caption(conftel,config)"
      wm protocol $This WM_DELETE_WINDOW ::confTel::fermer

      frame $This.usr -borderwidth 0 -relief raised
         #--- Creation de la fenetre a onglets
         set nn $This.usr.book
         Rnotebook:create $nn -tabs { LX200 Ouranos AudeCom ComPad AvrCom TelCom LXnet Temma MCMT } -borderwidth 1
         fillPage1 $nn
         fillPage2 $nn
         fillPage3 $nn
         fillPage4 $nn
         fillPage5 $nn
         fillPage6 $nn
         fillPage7 $nn
         fillPage8 $nn
         fillPage9 $nn
         pack $nn -fill both -expand 1
      pack $This.usr -side top -fill both -expand 1
      frame $This.start -borderwidth 1 -relief raised
         checkbutton $This.start.chk -text "$caption(conftel,creer_au_demarrage)" \
            -highlightthickness 0 -variable conf(telescope,start)
         pack $This.start.chk -side top -padx 3 -pady 3 -fill x
      pack $This.start -side top -fill x
      frame $This.cmd -borderwidth 1 -relief raised
         button $This.cmd.ok -text "$caption(conftel,ok)" -relief raised -state normal -width 7 \
            -command { ::confTel::ok }
         if { $conf(ok+appliquer) == "1" } {
            pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }
         button $This.cmd.appliquer -text "$caption(conftel,appliquer)" -relief raised -state normal -width 8 \
            -command { ::confTel::appliquer }
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.fermer -text "$caption(conftel,fermer)" -relief raised -state normal -width 7 \
            -command { ::confTel::fermer }
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.aide -text "$caption(conftel,aide)" -relief raised -state normal -width 7 \
            -command { ::confTel::afficherAide }
         pack $This.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x
      pack $This.cmd -side top -fill x

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # Onglet de configuration du LX200
   #
   proc fillPage1 { nn } {
      global audace caption color conf confTel frmm

      #--- initConf
      if { ! [ info exists conf(lx200,format) ] }          { set conf(lx200,format) "1" }
      if { ! [ info exists conf(lx200,modele) ] }          { set conf(lx200,modele) "LX200" }
      if { ! [ info exists conf(lx200,port) ] }            { set conf(lx200,port)   [ lindex "$audace(list_com)" 0 ] }
      if { ! [ info exists conf(lx200,ite-lente_tempo) ] } { set conf(lx200,ite-lente_tempo) "300" }

      #--- confToWidget
      set confTel(lx200,format)          [ lindex "$caption(conftel,format_court_long)" $conf(lx200,format) ]
      set confTel(lx200,modele)          $conf(lx200,modele)
      set confTel(lx200,port)            $conf(lx200,port)
      set confTel(lx200,ite-lente_tempo) $conf(lx200,ite-lente_tempo)

      set confTel(raquette)     $conf(raquette)

      #--- Initialisation
      set frmm(Telscp1) [ Rnotebook:frame $nn 1 ]
      set frm $frmm(Telscp1)

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill x

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side top -fill x

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -side top -fill x

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -side top -fill x

      frame $frm.frame4a -borderwidth 0 -relief raised
      pack $frm.frame4a -side top -fill x

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -side bottom -fill x -pady 2

      frame $frm.frame6 -borderwidth 0 -relief raised
      pack $frm.frame6 -in $frm.frame1 -side left -fill both -expand 1

      frame $frm.frame7 -borderwidth 0 -relief raised
      pack $frm.frame7 -in $frm.frame1 -side left -fill both -expand 1

      frame $frm.frame8 -borderwidth 0 -relief raised
      pack $frm.frame8 -in $frm.frame6 -side top -fill x

      frame $frm.frame9 -borderwidth 0 -relief raised
      pack $frm.frame9 -in $frm.frame6 -side top -fill x

      #--- Definition du port
      label $frm.lab1 -text "$caption(conftel,port)"
	pack $frm.lab1 -in $frm.frame8 -anchor center -side left -padx 10 -pady 10

      ComboBox $frm.port \
         -width 14         \
         -height [ llength $audace(list_com) ] \
         -relief sunken    \
         -borderwidth 1    \
         -textvariable confTel(lx200,port) \
         -editable 0       \
         -values $audace(list_com)
	pack $frm.port -in $frm.frame8 -anchor center -side right -padx 10 -pady 10

      #--- Definition du format des donnees transmises au LX200
      label $frm.lab2 -text "$caption(conftel,format)"
	pack $frm.lab2 -in $frm.frame9 -anchor center -side left -padx 10 -pady 10

      set list_combobox "$caption(conftel,format_court_long)"
      ComboBox $frm.formatradec \
         -width 7          \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -textvariable confTel(lx200,format) \
         -editable 0       \
         -values $list_combobox
	pack $frm.formatradec -in $frm.frame9 -anchor center -side right -padx 10 -pady 10

      #--- Definition du LX200 ou du clone
      set list_combobox [ list $caption(conftel,modele_lx200) $caption(conftel,modele_audecom) \
         $caption(conftel,modele_skysensor) $caption(conftel,modele_gemini) $caption(conftel,modele_ite-lente) ]
      ComboBox $frm.modele \
         -width 17         \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -textvariable confTel(lx200,modele) \
         -modifycmd { ::confTel::connectIte-lente } \
         -editable 0       \
         -values $list_combobox
	pack $frm.modele -in $frm.frame7 -anchor n -side right -padx 10 -pady 10

      label $frm.lab3 -text "$caption(conftel,modele)"
	pack $frm.lab3 -in $frm.frame7 -anchor n -side right -padx 10 -pady 10

      #--- Le bouton de commande maj heure et position du LX200
      button $frm.majpara -text "$caption(conftel,maj_lx200)" -relief raised -command {
         catch {
            tel$audace(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
            tel$audace(telNo) home $audace(posobs,observateur,gps)
         }
      }
      pack $frm.majpara -in $frm.frame2 -anchor center -side top -padx 10 -pady 5 -ipadx 10 -ipady 5 -expand true

	#--- Entree de la tempo Ite-lente
	label $frm.lab4 -text "$caption(conftel,ite-lente_tempo)"
	pack $frm.lab4 -in $frm.frame4a -anchor center -side left -padx 10 -pady 10

	entry $frm.tempo -textvariable confTel(lx200,ite-lente_tempo) -justify center -width 5
	pack $frm.tempo -in $frm.frame4a -anchor center -side left -padx 10 -pady 10

      #--- Gestion du bouton actif/inactif
      ::confTel::connectLX200

      #--- Gestion de la tempo pour Ite-lente
      ::confTel::connectIte-lente

      #--- Le checkbutton pour la visibilite de la raquette a l'ecran
      checkbutton $frm.raquette -text "$caption(conftel,raquette_tel)" \
         -highlightthickness 0 -variable confTel(raquette)
	pack $frm.raquette -in $frm.frame3 -anchor center -side left -padx 10 -pady 10
      ComboBox $frm.nom_raquette \
         -width 10         \
         -height [ llength $::confPad::private(driverlist) ]  \
         -relief sunken    \
         -borderwidth 1    \
         -modifycmd {
            set label $audace(nom_raquette)
            set index [lsearch -exact $::confPad::private(driverlist) $label ]
            if { $index != -1 } {
               set ::confPad::private(conf_confPad) [ lindex $::confPad::private(namespacelist) $index ]
            } else {
               set ::confPad::private(conf_confPad) ""
            }
            set conf(confPad) $::confPad::private(conf_confPad)

            ::confPad::run
         } \
         -textvariable audace(nom_raquette) \
         -editable 0       \
         -values $::confPad::private(driverlist)
      pack $frm.nom_raquette -in $frm.frame3 -anchor center -side left -padx 0 -pady 10

      #--- Choix de la raquette
      button $frm.choix_raquette -text "$caption(conftel,config_raquette)" -command { ::confPad::run }
	pack $frm.choix_raquette -in $frm.frame3 -anchor center -side top -padx 10 -pady 10 -ipadx 20 -ipady 5 -expand true

      #--- Site web officiel du LX200
      label $frm.lab103 -text "$caption(conftel,site_web_ref)"
      pack $frm.lab103 -in $frm.frame5 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(conftel,site_lx200)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame5 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $frm.labURL <ButtonPress-1> {
         set filename "$caption(conftel,site_lx200)"
         ::audace::Lance_Site_htm $filename
      }
      bind $frm.labURL <Enter> {
	   global frmm
         set frm $frmm(Telscp1)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
	   global frmm
         set frm $frmm(Telscp1)
         $frm.labURL configure -fg $color(blue)
      }

      bind [ Rnotebook:button $nn 1 ] <Button-1> { global confTel ; set confTel(tel) "lx200" }
   }

   #
   # Onglet de configuration d'Ouranos
   #
   proc fillPage2 { nn } {
      global audace caption color conf confTel frmm ouranoscom

      #--- Initialisation des fenetres d'affichage des coordonnees AD et Dec.
      if { ! [ info exists conf(ouranos,wmgeometry) ] }     { set conf(ouranos,wmgeometry)     "200x70+640+268" }
      if { ! [ info exists conf(ouranos,x10,wmgeometry) ] } { set conf(ouranos,x10,wmgeometry) "850x500+0+0" }

      #--- initConf
      if { ! [ info exists conf(ouranos,cod_dec) ] }        { set conf(ouranos,cod_dec)     "32768" }
      if { ! [ info exists conf(ouranos,cod_ra) ] }         { set conf(ouranos,cod_ra)      "32768" }
      if { ! [ info exists conf(ouranos,freq) ] }           { set conf(ouranos,freq)        "1" }
      if { ! [ info exists conf(ouranos,init) ] }           { set conf(ouranos,init)        "0" }
      if { ! [ info exists conf(ouranos,inv_dec) ] }        { set conf(ouranos,inv_dec)     "1" }
      if { ! [ info exists conf(ouranos,inv_ra) ] }         { set conf(ouranos,inv_ra)      "1" }
      if { ! [ info exists conf(ouranos,port) ] }           { set conf(ouranos,port)        [ lindex $audace(list_com) 0 ] }
      if { ! [ info exists conf(ouranos,show_coord) ] }     { set conf(ouranos,show_coord)  "1" }
      if { ! [ info exists conf(ouranos,tjrsvisible) ] }    { set conf(ouranos,tjrsvisible) "0" }

      #--- confToWidget
      if { $ouranoscom(lecture) != "1" } {
         ::OuranosCom::init_ouranos
      }
      set confTel(ouranos,port) $conf(ouranos,port)

      #--- Initialisation
      set frmm(Telscp2) [ Rnotebook:frame $nn 2 ]
      set frm $frmm(Telscp2)

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill x

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side top -fill both -expand 1

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -side top -fill both -expand 1

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -side top -fill both -expand 1

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -side top -fill both -expand 1

      frame $frm.frame6 -borderwidth 0 -relief raised
      pack $frm.frame6 -side bottom -fill x -pady 2

      frame $frm.frame7 -borderwidth 0 -relief raised
      pack $frm.frame7 -in $frm.frame2 -side left -fill both -expand 1

      frame $frm.frame8 -borderwidth 0 -relief raised
      pack $frm.frame8 -in $frm.frame2 -side left -fill both -expand 1

      frame $frm.frame9 -borderwidth 0 -relief raised
      pack $frm.frame9 -in $frm.frame2 -side left -fill both -expand 1

      frame $frm.frame10 -borderwidth 0 -relief raised
      pack $frm.frame10 -in $frm.frame3 -side left -fill both -expand 1

      frame $frm.frame11 -borderwidth 0 -relief raised
      pack $frm.frame11 -in $frm.frame3 -side left -fill both -expand 1

      frame $frm.frame12 -borderwidth 0 -relief raised
      pack $frm.frame12 -in $frm.frame7 -side top -fill both -expand 1

      frame $frm.frame13 -borderwidth 0 -relief raised
      pack $frm.frame13 -in $frm.frame7 -side top -fill both -expand 1

      frame $frm.frame14 -borderwidth 0 -relief raised
      pack $frm.frame14 -in $frm.frame8 -side top -fill both -expand 1

      frame $frm.frame15 -borderwidth 0 -relief raised
      pack $frm.frame15 -in $frm.frame8 -side top -fill both -expand 1

      #--- Definition du port
      label $frm.lab1 -text "$caption(conftel,port)"
	pack $frm.lab1 -in $frm.frame1 -anchor center -side left -padx 10 -pady 5

	entry $frm.status -font $audace(font,arial_8_b) -textvariable confTel(conf_ouranos,status) -width 4 \
         -justify center -bg $color(red)
	pack $frm.status -in $frm.frame1 -anchor center -side left -padx 10 -pady 5

      ComboBox $frm.port \
         -width 14         \
         -height [ llength $audace(list_com) ]  \
         -relief sunken    \
         -borderwidth 1    \
         -textvariable confTel(ouranos,port) \
         -editable 0       \
         -values $audace(list_com)
	pack $frm.port -in $frm.frame1 -anchor center -side left -padx 13 -pady 5

	#--- Selection affichage toujours visibles ou non
	checkbutton $frm.visible -text "$caption(conftel,ouranos_visible)" -highlightthickness 0 \
         -variable confTel(conf_ouranos,tjrsvisible) -onvalue 1 -offvalue 0 \
         -command { set confTel(conf_ouranos,dim) "0" ; ::OuranosCom::TjrsVisible }
	pack $frm.visible -in $frm.frame1 -anchor center -side right -padx 11 -pady 5

	#--- Definition des unités de l'affichage (pas encodeurs ou coordonnées)
	checkbutton $frm.unites -text "$caption(conftel,ouranos_unites)" -highlightthickness 0 \
         -variable confTel(conf_ouranos,show_coord) -onvalue 1 -offvalue 0 \
         -command { ::confTel::radio_bouton_Ouranos ; ::confTel::MatchOuranos ; ::OuranosCom::show1 }
	pack $frm.unites -in $frm.frame1 -anchor center -side right -pady 5

	#--- Informations concernant le codeur RA
	label $frm.ra -text "$caption(conftel,ouranos_res_codeur)"
	pack $frm.ra -in $frm.frame12 -anchor center -side left -padx 10 -pady 5

	#--- Valeur des pas encodeurs RA pour 1 tour
      entry $frm.codRA -textvariable confTel(conf_ouranos,cod_ra) -justify center -width 7
	pack $frm.codRA -in $frm.frame12 -anchor center -side left -padx 10 -pady 5

	#--- Definition de l'inversion de RA
	checkbutton $frm.invra -text "$caption(conftel,ouranos_inv)" -highlightthickness 0 \
         -variable confTel(conf_ouranos,inv_ra) -onvalue -1 -offvalue 1
	pack $frm.invra -in $frm.frame14 -anchor center -side left -padx 10 -pady 5

      #--- Label pour les coordonnées RA
      label  $frm.encRA -text "$caption(conftel,ra)"
	pack $frm.encRA -in $frm.frame14 -anchor center -side right -padx 10 -pady 5

      #--- Fenêtre de lecture de RA
	label $frm.coordRA -font $audace(font,arial_8_b) -textvariable confTel(conf_ouranos,coord_ra) \
         -justify left -width 12
	pack $frm.coordRA -in $frm.frame9 -anchor center -side top -padx 10 -pady 7

	#--- Informations concernant le codeur DEC
      label $frm.dec -text "$caption(conftel,ouranos_res_codeur)"
	pack $frm.dec -in $frm.frame13 -anchor center -side left -padx 10 -pady 5

	#--- Valeur des pas encodeurs DEC pour 1 tour
      entry $frm.codDEC -textvariable confTel(conf_ouranos,cod_dec) -justify center -width 7
	pack $frm.codDEC -in $frm.frame13 -anchor center -side left -padx 10 -pady 5

	#--- Definition de l'inversion de DEC
	checkbutton $frm.invdec -text "$caption(conftel,ouranos_inv)" -highlightthickness 0 \
         -variable confTel(conf_ouranos,inv_dec) -onvalue -1 -offvalue 1
	pack $frm.invdec -in $frm.frame15 -anchor center -side left -padx 10 -pady 5

	#--- Label pour les coordonnées DEC
	label  $frm.encDEC -text "$caption(conftel,dec)"
	pack $frm.encDEC -in $frm.frame15 -anchor center -side right -padx 10 -pady 5

	#--- Fenêtre de lecture de DEC
	label $frm.coordDEC -font $audace(font,arial_8_b) -textvariable confTel(conf_ouranos,coord_dec) \
         -justify left -width 12
	pack $frm.coordDEC -in $frm.frame9 -anchor center -side bottom -padx 10 -pady 7

 	#--- Definition de l'initialisation DEC
	radiobutton $frm.dec90 -text "$caption(conftel,ouranos_init1)" -highlightthickness 0 \
                  -indicatoron 1 -variable confTel(conf_ouranos,init) -value 0 -command { ::OuranosCom::set_dec_ra }
	pack $frm.dec90 -in $frm.frame10 -anchor w -side top -padx 5

	radiobutton $frm.dec0 -text "$caption(conftel,ouranos_init2)" -highlightthickness 0 \
                  -indicatoron 1 -variable confTel(conf_ouranos,init) -value 1 -command { ::OuranosCom::set_dec_ra }
	pack $frm.dec0 -in $frm.frame10 -anchor w -side top -padx 5

      #--- Les boutons de commande
      if { $confTel(ouranos,connect) == "1" } {
         button $frm.but_init -text "$caption(conftel,ouranos_reglage)"  -width 7 -relief raised -state normal \
            -command { ::OuranosCom::find_res }
	   pack $frm.but_init -in $frm.frame11 -anchor center -side left -padx 10 -pady 5 -ipady 5
	   button $frm.but_close -text "$caption(conftel,ouranos_stop)" -width 6 -relief raised -state normal \
            -command { ::OuranosCom::close_com }
	   pack $frm.but_close -in $frm.frame11 -anchor center -side left -padx 10 -pady 5 -ipady 5
	   button $frm.but_read -text "$caption(conftel,ouranos_lire)" -width 6 -relief raised -state normal \
            -command { ::OuranosCom::go_ouranos }
	   pack $frm.but_read -in $frm.frame11 -anchor center -side left -padx 10 -pady 5 -ipady 5
      } else {
         button $frm.but_init -text "$caption(conftel,ouranos_reglage)"  -width 7 -relief raised -state disabled
	   pack $frm.but_init -in $frm.frame11 -anchor center -side left -padx 10 -pady 5 -ipady 5
	   button $frm.but_close -text "$caption(conftel,ouranos_stop)" -width 6 -relief raised -state disabled
	   pack $frm.but_close -in $frm.frame11 -anchor center -side left -padx 10 -pady 5 -ipady 5
	   button $frm.but_read -text "$caption(conftel,ouranos_lire)" -width 6 -relief raised -state disabled
	   pack $frm.but_read -in $frm.frame11 -anchor center -side left -padx 10 -pady 5 -ipady 5
      }

	#--- Definition de la fréquence de lecture
      label  $frm.title1 -text "$caption(conftel,ouranos_seconde)"
	pack $frm.title1 -in $frm.frame11 -anchor center -side right -padx 5 -pady 5

	entry $frm.freq -textvariable confTel(conf_ouranos,freq) -justify center -width 5
	pack $frm.freq -in $frm.frame11 -anchor center -side right -padx 5 -pady 5

	label  $frm.title -text "$caption(conftel,ouranos_frequence)"
	pack $frm.title -in $frm.frame11 -anchor center -side right -padx 10 -pady 5

      #--- Gestion du bouton MATCH et des coordonnees pour MATCH
      set confTel(conf_ouranos,show_coord) $conf(ouranos,show_coord)
      if { $confTel(conf_ouranos,show_coord) == "1" } {
         #--- Bouton MATCH avec entry inactif
	   button $frm.but_match -text "$caption(conftel,ouranos_match)" -width 8 -state disabled
	   pack $frm.but_match -in $frm.frame4 -anchor center -side left -padx 20 -ipady 5
	   #--- Valeur Dec. en ° ' "
         entry $frm.match_dec_entry -textvariable confTel(conf_ouranos,match_dec) -justify center -width 12
	   pack $frm.match_dec_entry -in $frm.frame4 -anchor center -side right -padx 10
	   #--- Commentaires Dec.
	   label $frm.match_dec -text "$caption(conftel,dec) $caption(conftel,dms_angle)"
	   pack $frm.match_dec -in $frm.frame4 -anchor center -side right -padx 10
         #--- Gestion des evenements Dec.
         bind $frm.match_dec_entry <Enter> { ::confTel::Format_Match_Dec }
         bind $frm.match_dec_entry <Leave> { destroy $audace(base).format_match_dec }
	   #--- Valeur AD en h mn s
         entry $frm.match_ra_entry -textvariable confTel(conf_ouranos,match_ra) -justify center -width 12
	   pack $frm.match_ra_entry -in $frm.frame4 -anchor center -side right -padx 10
	   #--- Commentaires AD
	   label $frm.match_ra -text "$caption(conftel,ra) $caption(conftel,hms_angle)"
	   pack $frm.match_ra -in $frm.frame4 -anchor center -side right -padx 10
         #--- Gestion des evenements AD
         bind $frm.match_ra_entry <Enter> { ::confTel::Format_Match_AD }
         bind $frm.match_ra_entry <Leave> { destroy $audace(base).format_match_ad }
      } else {
         #--- Bouton MATCH sans entry inactif
	   button $frm.but_match -text "$caption(conftel,ouranos_match)" -width 8 -state disabled
	   pack $frm.but_match -in $frm.frame4 -anchor center -side left -padx 10 -ipady 5
      }

      #--- Gestion des catalogues
      if { ( $confTel(ouranos,connect) == "1" ) && ( $confTel(conf_ouranos,show_coord) == "1" ) } {
         #--- Bouton radio Etoile
         radiobutton $frm.rad0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 -state normal \
            -text "$caption(conftel,ouranos_etoile)" -value 0 -variable confTel(conf_ouranos,objet) -command {
               set confTel(conf_ouranos,obj_choisi) $caption(conftel,ouranos_etoile)
               ::cataGoto::CataEtoiles
            }
	   pack $frm.rad0 -in $frm.frame5 -anchor center -side left -padx 30
         #--- Bouton radio Messier
         radiobutton $frm.rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 -state normal \
            -text "$caption(conftel,ouranos_messier)" -value 1 -variable confTel(conf_ouranos,objet) -command {
               set confTel(conf_ouranos,obj_choisi) $caption(conftel,ouranos_messier)
               ::cataGoto::CataObjet $caption(conftel,ouranos_messier)
            }
	   pack $frm.rad1 -in $frm.frame5 -anchor center -side left -padx 30
         #--- Bouton radio NGC
         radiobutton $frm.rad2 -anchor nw -highlightthickness 0 -padx 0 -pady 0 -state normal \
            -text "$caption(conftel,ouranos_ngc)" -value 2 -variable confTel(conf_ouranos,objet) -command {
               set confTel(conf_ouranos,obj_choisi) $caption(conftel,ouranos_ngc)
               ::cataGoto::CataObjet $caption(conftel,ouranos_ngc)
            }
	   pack $frm.rad2 -in $frm.frame5 -anchor center -side left -padx 30
         #--- Bouton radio IC
         radiobutton $frm.rad3 -anchor nw -highlightthickness 0 -padx 0 -pady 0 -state normal \
            -text "$caption(conftel,ouranos_ic)" -value 3 -variable confTel(conf_ouranos,objet) -command {
               set confTel(conf_ouranos,obj_choisi) $caption(conftel,ouranos_ic)
               ::cataGoto::CataObjet $caption(conftel,ouranos_ic)
         }
	   pack $frm.rad3 -in $frm.frame5 -anchor center -side left -padx 30
      } else {
         #--- Bouton radio Etoile
         radiobutton $frm.rad0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 -state disabled \
            -text "$caption(conftel,ouranos_etoile)" -value 0 -variable confTel(conf_ouranos,objet)
	   pack $frm.rad0 -in $frm.frame5 -anchor center -side left -padx 30
         #--- Bouton radio Messier
         radiobutton $frm.rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 -state disabled \
            -text "$caption(conftel,ouranos_messier)" -value 1 -variable confTel(conf_ouranos,objet)
	   pack $frm.rad1 -in $frm.frame5 -anchor center -side left -padx 30
         #--- Bouton radio NGC
         radiobutton $frm.rad2 -anchor nw -highlightthickness 0 -padx 0 -pady 0 -state disabled \
            -text "$caption(conftel,ouranos_ngc)" -value 2 -variable confTel(conf_ouranos,objet)
	   pack $frm.rad2 -in $frm.frame5 -anchor center -side left -padx 30
         #--- Bouton radio IC
         radiobutton $frm.rad3 -anchor nw -highlightthickness 0 -padx 0 -pady 0 -state disabled \
            -text "$caption(conftel,ouranos_ic)" -value 3 -variable confTel(conf_ouranos,objet)
	   pack $frm.rad3 -in $frm.frame5 -anchor center -side left -padx 30
      }

      #--- Site web officiel d'Ouranos
      label $frm.lab103 -text "$caption(conftel,site_web_ref)"
      pack $frm.lab103 -in $frm.frame6 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(conftel,site_ouranos)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame6 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $frm.labURL <ButtonPress-1> {
         set filename "$caption(conftel,site_ouranos)"
         ::audace::Lance_Site_htm $filename
      }
      bind $frm.labURL <Enter> {
	   global frmm
         set frm $frmm(Telscp2)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
	   global frmm
         set frm $frmm(Telscp2)
         $frm.labURL configure -fg $color(blue)
      }

      #---
      if [ winfo exists $audace(base).tjrsvisible ] {
         set confTel(conf_ouranos,tjrsvisible) "1"
      }
      if { $ouranoscom(lecture) == "1" } {
         #--- Traitement graphique du bouton 'Lire'
         $frm.but_read configure -text "$caption(conftel,ouranos_lire)" -relief groove -state disabled
         #--- Traitement graphique du bouton 'Regler'
         $frm.but_init configure -text "$caption(conftel,ouranos_reglage)" -state disabled
         if { $confTel(conf_ouranos,show_coord) == "1" } {
            #--- Bouton MATCH avec entry actif
            $frm.but_match configure -text "$caption(conftel,ouranos_match)" -state normal
         } else {
            #--- Bouton MATCH avec entry inactif
            $frm.but_match configure -text "$caption(conftel,ouranos_match)" -state disabled
         }
         update
      }

      bind [ Rnotebook:button $nn 2 ] <Button-1> { global confTel ; set confTel(tel) "ouranos" }
   }

   #
   # Onglet de configuration d'AudeCom
   #
   proc fillPage3 { nn } {
      global audace caption color conf confTel frmm

      #--- Initialisation des parametres de la monture lies a la reduction des axes AD et Dec. (par editeur de texte)
      if { ! [ info exists conf(audecom,dlimp) ] }        { set conf(audecom,dlimp)        "100" }
      if { ! [ info exists conf(audecom,dlimpmax) ] }     { set conf(audecom,dlimpmax)     "255" }
      if { ! [ info exists conf(audecom,dlimpmin) ] }     { set conf(audecom,dlimpmin)     "0" }
      if { ! [ info exists conf(audecom,dlimprecouv) ] }  { set conf(audecom,dlimprecouv)  "192" }
      if { ! [ info exists conf(audecom,dmaxad) ] }       { set conf(audecom,dmaxad)       "16" }
      if { ! [ info exists conf(audecom,dmaxadmax) ] }    { set conf(audecom,dmaxadmax)    "16" }
      if { ! [ info exists conf(audecom,dmaxadmin) ] }    { set conf(audecom,dmaxadmin)    "4" }
      if { ! [ info exists conf(audecom,dmaxdec) ] }      { set conf(audecom,dmaxdec)      "16" }
      if { ! [ info exists conf(audecom,dmaxdecmax) ] }   { set conf(audecom,dmaxdecmax)   "16" }
      if { ! [ info exists conf(audecom,dmaxdecmin) ] }   { set conf(audecom,dmaxdecmin)   "4" }
      if { ! [ info exists conf(audecom,dsuividelta) ] }  { set conf(audecom,dsuividelta)  "192" }
      if { ! [ info exists conf(audecom,dsuivinom) ] }    { set conf(audecom,dsuivinom)    "192" }
      if { ! [ info exists conf(audecom,dsuivinommax) ] } { set conf(audecom,dsuivinommax) "255" }
      if { ! [ info exists conf(audecom,dsuivinommin) ] } { set conf(audecom,dsuivinommin) "130" }
      if { ! [ info exists conf(audecom,dsuivinomxt0) ] } { set conf(audecom,dsuivinomxt0) "37.9159872" }
      if { ! [ info exists conf(audecom,internom) ] }     { set conf(audecom,internom)     "197.4791" }

      #--- initConf
      if { ! [ info exists conf(audecom,ad) ] }           { set conf(audecom,ad)           "999999" }
      if { ! [ info exists conf(audecom,dec) ] }          { set conf(audecom,dec)          "999999" }
      if { ! [ info exists conf(audecom,dep_val) ] }      { set conf(audecom,dep_val)      "250" }
      if { ! [ info exists conf(audecom,german) ] }       { set conf(audecom,german)       "0" }
      if { ! [ info exists conf(audecom,intra_extra) ] }  { set conf(audecom,intra_extra)  "0" }
      if { ! [ info exists conf(audecom,inv_rot) ] }      { set conf(audecom,inv_rot)      "0" }
      if { ! [ info exists conf(audecom,gotopluslong) ] } { set conf(audecom,gotopluslong) "0" }
      if { ! [ info exists conf(audecom,king) ] }         { set conf(audecom,king)         "1" }
      if { ! [ info exists conf(audecom,limp) ] }         { set conf(audecom,limp)         "50" }
      if { ! [ info exists conf(audecom,maxad) ] }        { set conf(audecom,maxad)        "16" }
      if { ! [ info exists conf(audecom,maxdec) ] }       { set conf(audecom,maxdec)       "16" }
      if { ! [ info exists conf(audecom,mobile) ] }       { set conf(audecom,mobile)       "0" }
      if { ! [ info exists conf(audecom,pec) ] }          { set conf(audecom,pec)          "1" }
      if { ! [ info exists conf(audecom,port) ] }         { set conf(audecom,port)         [ lindex $audace(list_com) 0 ] }
      if { ! [ info exists conf(audecom,rat_ad) ] }       { set conf(audecom,rat_ad)       "0.5" }
      if { ! [ info exists conf(audecom,rat_dec) ] }      { set conf(audecom,rat_dec)      "0.5" }
      if { ! [ info exists conf(audecom,rpec) ] }         { set conf(audecom,rpec)         "6" }
      if { ! [ info exists conf(audecom,type) ] }         { set conf(audecom,type)         "2" }
      if { ! [ info exists conf(audecom,t0) ] }           { set conf(audecom,t0)           "192" }
      if { ! [ info exists conf(audecom,t1) ] }           { set conf(audecom,t1)           "192" }
      if { ! [ info exists conf(audecom,t2) ] }           { set conf(audecom,t2)           "192" }
      if { ! [ info exists conf(audecom,t3) ] }           { set conf(audecom,t3)           "192" }
      if { ! [ info exists conf(audecom,t4) ] }           { set conf(audecom,t4)           "192" }
      if { ! [ info exists conf(audecom,t5) ] }           { set conf(audecom,t5)           "192" }
      if { ! [ info exists conf(audecom,t6) ] }           { set conf(audecom,t6)           "192" }
      if { ! [ info exists conf(audecom,t7) ] }           { set conf(audecom,t7)           "192" }
      if { ! [ info exists conf(audecom,t8) ] }           { set conf(audecom,t8)           "192" }
      if { ! [ info exists conf(audecom,t9) ] }           { set conf(audecom,t9)           "192" }
      if { ! [ info exists conf(audecom,t10) ] }          { set conf(audecom,t10)          "192" }
      if { ! [ info exists conf(audecom,t11) ] }          { set conf(audecom,t11)          "192" }
      if { ! [ info exists conf(audecom,t12) ] }          { set conf(audecom,t12)          "192" }
      if { ! [ info exists conf(audecom,t13) ] }          { set conf(audecom,t13)          "192" }
      if { ! [ info exists conf(audecom,t14) ] }          { set conf(audecom,t14)          "192" }
      if { ! [ info exists conf(audecom,t15) ] }          { set conf(audecom,t15)          "192" }
      if { ! [ info exists conf(audecom,t16) ] }          { set conf(audecom,t16)          "192" }
      if { ! [ info exists conf(audecom,t17) ] }          { set conf(audecom,t17)          "192" }
      if { ! [ info exists conf(audecom,t18) ] }          { set conf(audecom,t18)          "192" }
      if { ! [ info exists conf(audecom,t19) ] }          { set conf(audecom,t19)          "192" }
      if { ! [ info exists conf(audecom,vitesse) ] }      { set conf(audecom,vitesse)      "30" }

      #--- confToWidget
      set confTel(conf_audecom,port)         $conf(audecom,port)
      set confTel(conf_audecom,pec)          $conf(audecom,pec)
      set confTel(conf_audecom,king)         $conf(audecom,king)
      set confTel(conf_audecom,mobile)       $conf(audecom,mobile)
      set confTel(conf_audecom,german)       $conf(audecom,german)
      #--- Pour la fenetre de configuration des parametres moteurs
      set confTel(conf_audecom,limp)         $conf(audecom,limp)
      set confTel(conf_audecom,maxad)        $conf(audecom,maxad)
      set confTel(conf_audecom,maxdec)       $conf(audecom,maxdec)
      set confTel(conf_audecom,rat_ad)       $conf(audecom,rat_ad)
      set confTel(conf_audecom,rat_dec)      $conf(audecom,rat_dec)
      #--- Pour la fenetre de configuration des parametres de la focalisation
      set confTel(conf_audecom,dep_val)      $conf(audecom,dep_val)
      set confTel(conf_audecom,intra_extra)  $conf(audecom,intra_extra)
      set confTel(conf_audecom,inv_rot)      $conf(audecom,inv_rot)
      set confTel(conf_audecom,vitesse)      $conf(audecom,vitesse)
      #--- Pour la fenetre de configuration de la programmation du PEC
      set confTel(conf_audecom,rpec)         $conf(audecom,rpec)
      set confTel(conf_audecom,t0)           $conf(audecom,t0)
      set confTel(conf_audecom,t1)           $conf(audecom,t1)
      set confTel(conf_audecom,t2)           $conf(audecom,t2)
      set confTel(conf_audecom,t3)           $conf(audecom,t3)
      set confTel(conf_audecom,t4)           $conf(audecom,t4)
      set confTel(conf_audecom,t5)           $conf(audecom,t5)
      set confTel(conf_audecom,t6)           $conf(audecom,t6)
      set confTel(conf_audecom,t7)           $conf(audecom,t7)
      set confTel(conf_audecom,t8)           $conf(audecom,t8)
      set confTel(conf_audecom,t9)           $conf(audecom,t9)
      set confTel(conf_audecom,t10)          $conf(audecom,t10)
      set confTel(conf_audecom,t11)          $conf(audecom,t11)
      set confTel(conf_audecom,t12)          $conf(audecom,t12)
      set confTel(conf_audecom,t13)          $conf(audecom,t13)
      set confTel(conf_audecom,t14)          $conf(audecom,t14)
      set confTel(conf_audecom,t15)          $conf(audecom,t15)
      set confTel(conf_audecom,t16)          $conf(audecom,t16)
      set confTel(conf_audecom,t17)          $conf(audecom,t17)
      set confTel(conf_audecom,t18)          $conf(audecom,t18)
      set confTel(conf_audecom,t19)          $conf(audecom,t19)
      #--- Pour la fenetre de configuration du suivi des objets mobiles
      set confTel(conf_audecom,ad)           $conf(audecom,ad)
      set confTel(conf_audecom,dec)          $conf(audecom,dec)
      set confTel(conf_audecom,type)         $conf(audecom,type)

      set confTel(raquette)                  $conf(raquette)

      #--- Initialisation
      set frmm(Telscp3) [ Rnotebook:frame $nn 3 ]
      set frm $frmm(Telscp3)

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill x

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side top -fill both -expand 1

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -side bottom -fill x -pady 2

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -in $frm.frame1 -side left -fill both -expand 1

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -in $frm.frame1 -side left -fill both -expand 1

      frame $frm.frame6 -borderwidth 0 -relief raised
      pack $frm.frame6 -in $frm.frame4 -side top -fill x

      frame $frm.frame7 -borderwidth 0 -relief raised
      pack $frm.frame7 -in $frm.frame4 -side top -fill x

      frame $frm.frame16 -borderwidth 0 -relief raised
      pack $frm.frame16 -in $frm.frame4 -side bottom -fill x

      frame $frm.frame8 -borderwidth 0 -relief raised
      pack $frm.frame8 -in $frm.frame4 -side bottom -fill x

      frame $frm.frame9 -borderwidth 0 -relief raised
      pack $frm.frame9 -in $frm.frame4 -side bottom -fill x

      frame $frm.frame10 -borderwidth 0 -relief raised
      pack $frm.frame10 -in $frm.frame4 -side top -fill x

      frame $frm.frame11 -borderwidth 0 -relief raised
      pack $frm.frame11 -in $frm.frame5 -side top -fill x

      frame $frm.frame12 -borderwidth 0 -relief raised
      pack $frm.frame12 -in $frm.frame5 -side top -fill x

      frame $frm.frame13 -borderwidth 0 -relief raised
      pack $frm.frame13 -in $frm.frame5 -side top -fill x

      frame $frm.frame14 -borderwidth 0 -relief raised
      pack $frm.frame14 -in $frm.frame5 -side top -fill x

      frame $frm.frame17 -borderwidth 0 -relief raised
      pack $frm.frame17 -in $frm.frame5 -side bottom -fill x

      frame $frm.frame15 -borderwidth 0 -relief raised
      pack $frm.frame15 -in $frm.frame5 -side bottom -fill x

      frame $frm.frame18 -borderwidth 0 -relief raised
      pack $frm.frame18 -in $frm.frame2 -side top -fill x

      frame $frm.frame19 -borderwidth 0 -relief raised
      pack $frm.frame19 -in $frm.frame2 -side top -fill x

      #--- Definition du port
      label $frm.lab1 -text "$caption(conftel,port)"
	pack $frm.lab1 -in $frm.frame6 -anchor center -side left -padx 10 -pady 10

      ComboBox $frm.port \
         -width 14         \
         -height [ llength $audace(list_com) ]  \
         -relief sunken    \
         -borderwidth 1    \
         -textvariable confTel(conf_audecom,port) \
         -editable 0       \
         -values $audace(list_com)
	pack $frm.port -in $frm.frame6 -anchor center -side left -padx 10 -pady 8

      #--- Intercallaire
      label $frm.lab2 -text ""
	pack $frm.lab2 -in $frm.frame7 -anchor center -side left -padx 10 -pady 10

      #--- Les checkbuttons
      checkbutton $frm.mobile -text "$caption(conftel,audecom_mobile)" -highlightthickness 0 \
         -variable confTel(conf_audecom,mobile)
	pack $frm.mobile -in $frm.frame8 -anchor center -side left -padx 10 -pady 8

      checkbutton $frm.king -text "$caption(conftel,audecom_king)" -highlightthickness 0 \
         -variable confTel(conf_audecom,king)
	pack $frm.king -in $frm.frame9 -anchor center -side left -padx 10 -pady 8

      checkbutton $frm.pec -text "$caption(conftel,audecom_pec)" -highlightthickness 0 \
         -variable confTel(conf_audecom,pec)
	pack $frm.pec -in $frm.frame10 -anchor center -side left -padx 10 -pady 8

      #--- Les boutons de commande
      button $frm.paramot -text "$caption(conftel,audecom_para_moteur)" \
         -command { ::confAudecomMot::run "$audace(base).confAudecomMot" }
	pack $frm.paramot -in $frm.frame11 -anchor center -side top -pady 3 -ipadx 10 -ipady 5 -expand true

      button $frm.parafoc -text "$caption(conftel,audecom_para_foc)" \
         -command { ::confAudecomFoc::run "$audace(base).confAudecomFoc" }
	pack $frm.parafoc -in $frm.frame12 -anchor center -side top -pady 3 -ipadx 10 -ipady 5 -expand true

      button $frm.progpec -text "$caption(conftel,audecom_prog_pec)" \
         -command { ::confAudecomPec::run "$audace(base).confAudecomPec" }
	pack $frm.progpec -in $frm.frame13 -anchor center -side top -pady 3 -ipadx 10 -ipady 5 -expand true

      #--- Affiche le bouton de controle de la vitesse de King si le telescope AudeCom est connecte
      if { $confTel(audecom,connect) == "1" } {
         if { [ winfo exists $audace(base).confAudecomKing ] } {
            button $frm.ctlking -text "$caption(conftel,audecom_ctl_king)" -relief groove -state disabled \
               -command { ::confAudecomKing::run "$audace(base).confAudecomKing" }
	      pack $frm.ctlking -in $frm.frame14 -anchor center -side top -pady 3 -ipadx 10 -ipady 5 -expand true
         } else {
            button $frm.ctlking -text "$caption(conftel,audecom_ctl_king)" -state normal \
               -command { ::confAudecomKing::run "$audace(base).confAudecomKing" }
	      pack $frm.ctlking -in $frm.frame14 -anchor center -side top -pady 3 -ipadx 10 -ipady 5 -expand true
         }
      }

      #--- Le bouton de commande
      button $frm.ctlmobile -text "$caption(conftel,audecom_ctl_mobile)" -state normal \
         -command { ::confAudecomMobile::run "$audace(base).confAudecomMobile" }
	pack $frm.ctlmobile -in $frm.frame15 -anchor center -side top -pady 3 -ipadx 10 -ipady 5 -expand true

      #--- Le checkbutton pour la visibilite de la raquette a l'ecran
      checkbutton $frm.raquette -text "$caption(conftel,raquette_tel)" \
         -highlightthickness 0 -variable confTel(raquette)
      pack $frm.raquette -in $frm.frame16 -anchor center -side left -padx 10 -pady 8
      ComboBox $frm.nom_raquette \
         -width 10         \
         -height [ llength $::confPad::private(driverlist) ]  \
         -relief sunken    \
         -borderwidth 1    \
         -modifycmd {
            set label $audace(nom_raquette)
            set index [lsearch -exact $::confPad::private(driverlist) $label ]
            if { $index != -1 } {
               set ::confPad::private(conf_confPad) [ lindex $::confPad::private(namespacelist) $index ]
            } else {
               set ::confPad::private(conf_confPad) ""
            }
            set conf(confPad) $::confPad::private(conf_confPad)

            ::confPad::run
         } \
         -textvariable audace(nom_raquette) \
         -editable 0       \
         -values $::confPad::private(driverlist)
      pack $frm.nom_raquette -in $frm.frame16 -anchor center -side left -padx 0 -pady 8

      #--- Choix de la raquette
      button $frm.choix_raquette -text "$caption(conftel,config_raquette)" -command { ::confPad::run }
	pack $frm.choix_raquette -in $frm.frame17 -anchor center -side left -padx 10 -pady 3 -ipadx 20 -ipady 5 -expand true

      #--- Le checkbutton pour la monture equatoriale allemande
      checkbutton $frm.german -text "$caption(conftel,audecom_mont_allemande)" -highlightthickness 0 \
         -variable confTel(conf_audecom,german) -command { ::confTel::config_equatorial_audecom }
	pack $frm.german -in $frm.frame18 -anchor nw -side left -padx 10 -pady 8

      #--- Gestion de l'option monture equatoriale allemande
      if { $confTel(conf_audecom,german) == "1" } {
         #--- Position du telescope sur la monture equatoriale allemande : A l'est ou a l'ouest
         label $frm.pos_tel -text "$caption(conftel,position_telescope)"
	   pack $frm.pos_tel -in $frm.frame19 -anchor center -side left -padx 10 -pady 3

         label $frm.pos_tel_ew -width 15 -anchor w -textvariable audace(pos_tel_ew)
         pack $frm.pos_tel_ew -in $frm.frame19 -anchor center -side left

         #--- Nouvelle position d'origine du telescope : A l'est ou a l'ouest
         label $frm.pos_tel_est -text "$caption(conftel,change_position_telescope)"
         pack $frm.pos_tel_est -in $frm.frame19 -anchor center -side left -padx 10 -pady 3

         if { $confTel(audecom,connect) == "1" } {
            button $frm.chg_pos_tel -relief raised -state normal -textvariable audace(chg_pos_tel) -command {
              ### set pos_tel [ tel$audace(telNo) german ]
              ### if { $pos_tel == "E" } {
              ###    tel$audace(telNo) german W
              ### } elseif { $pos_tel == "W" } {
              ###    tel$audace(telNo) german E
              ### }
              ### ::telescope::monture_allemande
            }
            pack $frm.chg_pos_tel -in $frm.frame19 -anchor center -side left -padx 10 -pady 3 -ipadx 5 -ipady 5
         } else {
            button $frm.chg_pos_tel -text "  ?  " -relief raised -state disabled
            pack $frm.chg_pos_tel -in $frm.frame19 -anchor center -side left -padx 10 -pady 3 -ipadx 5 -ipady 5
         }
      }

      #--- Document officiel d'AudeCom
      label $frm.lab103 -text "$caption(conftel,document_ref)"
      pack $frm.lab103 -in $frm.frame3 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(conftel,doc_audecom)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame3 -side top -fill x -pady 2

      #--- Creation du lien avec le visualiseur de notice et changement de sa couleur
      bind $frm.labURL <ButtonPress-1> {
         set filename "[ file join $audace(rep_plugin) mount audecom french $caption(conftel,doc_audecom) ]"
         ::audace::Lance_Notice_pdf $filename
      }
      bind $frm.labURL <Enter> {
	   global frmm
         set frm $frmm(Telscp3)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
	   global frmm
         set frm $frmm(Telscp3)
         $frm.labURL configure -fg $color(blue)
      }

      bind [ Rnotebook:button $nn 3 ] <Button-1> { global confTel ; set confTel(tel) "audecom" }
   }

   #
   # Onglet de configuration de ComPad
   #
   proc fillPage4 { nn } {
      global audace caption color conf confTel frmm

      #--- initConf
      if { ! [ info exists conf(compad,port) ] } { set conf(compad,port) [ lindex $audace(list_com) 0 ] }

      #--- confToWidget
      set confTel(compad,port) $conf(compad,port)

      #--- Initialisation
      set frmm(Telscp4) [ Rnotebook:frame $nn 4 ]
      set frm $frmm(Telscp4)

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill x

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side top -fill both -expand 1

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -side bottom -fill x -pady 2

      #--- Definition du port
      label $frm.lab1 -text "$caption(conftel,port)"
	pack $frm.lab1 -in $frm.frame1 -anchor center -side left -padx 10 -pady 10

      ComboBox $frm.port \
         -width 14         \
         -height [ llength $audace(list_com) ]  \
         -relief sunken    \
         -borderwidth 1    \
         -textvariable confTel(compad,port) \
         -editable 0       \
         -values $audace(list_com)
      pack $frm.port -in $frm.frame1 -anchor center -side left -padx 10 -pady 10

      #--- Site web officiel de ComPad
      label $frm.lab103 -text "$caption(conftel,site_web_ref)"
      pack $frm.lab103 -in $frm.frame3 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(conftel,site_compad)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame3 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $frm.labURL <ButtonPress-1> {
         set filename "$caption(conftel,site_compad)"
         ::audace::Lance_Site_htm $filename
      }
      bind $frm.labURL <Enter> {
	   global frmm
         set frm $frmm(Telscp4)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
	   global frmm
         set frm $frmm(Telscp4)
         $frm.labURL configure -fg $color(blue)
      }

      bind [ Rnotebook:button $nn 4 ] <Button-1> { global confTel ; set confTel(tel) "compad" }
   }

   #
   # Onglet de configuration d'AvrCom
   #
   proc fillPage5 { nn } {
      global avrcom audace caption color conf confTel frmm

      #--- initConf
      if { ! [ info exists conf(avrcom,port) ] } { set conf(avrcom,port) [ lindex $audace(list_com) 0 ] }

      #--- confToWidget
      set confTel(avrcom,port) $conf(avrcom,port)

      #--- Initialisation
      set frmm(Telscp5) [ Rnotebook:frame $nn 5 ]
      set frm $frmm(Telscp5)

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill x

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side top -fill x

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -side top -fill x

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -side bottom -fill x -pady 2

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -in $frm.frame1 -side left -fill both -expand 1

      frame $frm.frame6 -borderwidth 0 -relief raised
      pack $frm.frame6 -in $frm.frame1 -side left -fill both -expand 1

      frame $frm.frame7 -borderwidth 0 -relief raised
      pack $frm.frame7 -in $frm.frame5 -side top -fill x

      frame $frm.frame8 -borderwidth 0 -relief raised
      pack $frm.frame8 -in $frm.frame5 -side top -fill x

      frame $frm.frame9 -borderwidth 0 -relief raised
      pack $frm.frame9 -in $frm.frame2 -side left -fill x -expand 1

      frame $frm.frame10 -borderwidth 0 -relief raised
      pack $frm.frame10 -in $frm.frame2 -side left -fill x -expand 1

      #--- Definition du port
      label $frm.lab1 -text "$caption(conftel,port)"
	pack $frm.lab1 -in $frm.frame7 -anchor center -side left -padx 10 -pady 10

      ComboBox $frm.port \
         -width 14         \
         -height [ llength $audace(list_com) ]  \
         -relief sunken    \
         -borderwidth 1    \
         -textvariable confTel(avrcom,port) \
         -editable 0       \
         -values $audace(list_com)
	pack $frm.port -in $frm.frame7 -anchor center -side right -padx 10 -pady 10

	#--- Entree de commande
	label $frm.cmd1 -text "$caption(conftel,avr_commande)"
	pack $frm.cmd1 -in $frm.frame8 -anchor center -side left -padx 10 -pady 10

	entry $frm.cmd2 -textvariable avrcom(cmd) -justify center -width 9
	pack $frm.cmd2 -in $frm.frame8 -anchor center -side right -padx 10 -pady 10

	#--- Fenêtre de lecture
	label $frm.cmd3 -font $audace(font,arial_8_b) -textvariable avrcom(answer) -justify left -width 25
	pack $frm.cmd3 -in $frm.frame6 -anchor w -side bottom -padx 10 -pady 10

	#--- Les boutons de commande
      button $frm.but_init -text "$caption(conftel,avr_initialiser)"  -width 10 -relief raised -state normal \
         -command { ::AvrCom::go_pad }
      pack $frm.but_init -in $frm.frame9 -anchor center -side right -padx 20 -pady 10 -ipady 5
      button $frm.but_send -text "$caption(conftel,avr_transmettre)" -width 10 -relief raised -state normal \
         -command { ::AvrCom::send_pad $avrcom(cmd) }
      pack $frm.but_send -in $frm.frame10 -anchor center -side left -padx 20 -pady 10 -ipady 5

      #--- Gestion du bouton actif/inactif
      ::confTel::connectAvrCom

      #--- Site web officiel d'AvrCom
      label $frm.lab103 -text "$caption(conftel,site_web_ref)"
      pack $frm.lab103 -in $frm.frame4 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(conftel,site_avrcom)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame4 -side top -fill x -pady 2

      #--- Creation du lien avec le visualiseur de notice et changement de sa couleur
      bind $frm.labURL <ButtonPress-1> {
         set filename "$caption(conftel,site_avrcom)"
         ::audace::Lance_Site_htm $filename
      }
      bind $frm.labURL <Enter> {
	   global frmm
         set frm $frmm(Telscp5)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
	   global frmm
         set frm $frmm(Telscp5)
         $frm.labURL configure -fg $color(blue)
      }

      bind [ Rnotebook:button $nn 5 ] <Button-1> { global confTel ; set confTel(tel) "avrcom" }
   }

   #
   # Onglet de configuration de TelCom
   #
   proc fillPage6 { nn } {
      global audace caption color conf confTel frmm

      #--- initConf
      if { ! [ info exists conf(telcom,port) ] } { set conf(telcom,port) [ lindex $audace(list_com) 0 ] }

      #--- confToWidget
      set confTel(telcom,port) $conf(telcom,port)

      set confTel(raquette)    $conf(raquette)

      #--- Initialisation
      set frmm(Telscp6) [ Rnotebook:frame $nn 6 ]
      set frm $frmm(Telscp6)

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill x

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side top -fill x

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -side top -fill both -expand 1

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -side bottom -fill x -pady 2

      #--- Definition du port
      label $frm.lab1 -text "$caption(conftel,port)"
	pack $frm.lab1 -in $frm.frame1 -anchor center -side left -padx 10 -pady 10

      ComboBox $frm.port \
         -width 14         \
         -height [ llength $audace(list_com) ]  \
         -relief sunken    \
         -borderwidth 1    \
         -textvariable confTel(telcom,port) \
         -editable 0       \
         -values $audace(list_com)
      pack $frm.port -in $frm.frame1 -anchor center -side left -padx 10 -pady 10

      #--- Le checkbutton pour la visibilite de la raquette a l'ecran
      checkbutton $frm.raquette -text "$caption(conftel,raquette_tel)" \
         -highlightthickness 0 -variable confTel(raquette)
	pack $frm.raquette -in $frm.frame2 -anchor center -side left -padx 10 -pady 10
      ComboBox $frm.nom_raquette \
         -width 10         \
         -height [ llength $::confPad::private(driverlist) ]  \
         -relief sunken    \
         -borderwidth 1    \
         -modifycmd {
            set label $audace(nom_raquette)
            set index [lsearch -exact $::confPad::private(driverlist) $label ]
            if { $index != -1 } {
               set ::confPad::private(conf_confPad) [ lindex $::confPad::private(namespacelist) $index ]
            } else {
               set ::confPad::private(conf_confPad) ""
            }
            set conf(confPad) $::confPad::private(conf_confPad)

            ::confPad::run
         } \
         -textvariable audace(nom_raquette) \
         -editable 0       \
         -values $::confPad::private(driverlist)
      pack $frm.nom_raquette -in $frm.frame2 -anchor center -side left -padx 0 -pady 10

      #--- Choix de la raquette
      button $frm.choix_raquette -text "$caption(conftel,config_raquette)" -command { ::confPad::run }
	pack $frm.choix_raquette -in $frm.frame2 -anchor center -side top -padx 10 -pady 10 -ipadx 20 -ipady 5 -expand true

      #--- Document officiel de TelCom
      label $frm.lab103 -text "$caption(conftel,document_ref)"
      pack $frm.lab103 -in $frm.frame4 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(conftel,doc_telcom)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame4 -side top -fill x -pady 2

      #--- Creation du lien avec le visualiseur de notice et changement de sa couleur
     # bind $frm.labURL <ButtonPress-1> {
     #    set filename "[ file join $audace(rep_plugin) mount telcom french $caption(conftel,doc_telcom) ]"
     #    ::audace::Lance_Notice_pdf $filename
     # }
      bind $frm.labURL <Enter> {
	   global frmm
         set frm $frmm(Telscp6)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
	   global frmm
         set frm $frmm(Telscp6)
         $frm.labURL configure -fg $color(blue)
      }

      bind [ Rnotebook:button $nn 6 ] <Button-1> { global confTel ; set confTel(tel) "telcom" }
   }

   #
   # Onglet de configuration de LXnet
   #
   proc fillPage7 { nn } {
      global audace caption color conf confTel frmm

      #--- initConf
      #--- Remarque : L'adresse IP de lxnet est la meme adresse que celle de la camera audinet
      if { ! [ info exists conf(audinet,host) ] }        { set conf(audinet,host)        "168.254.216.36" }
      if { ! [ info exists conf(audinet,ipsetting) ] }   { set conf(audinet,ipsetting)   "0" }
      if { ! [ info exists conf(audinet,mac_address) ] } { set conf(audinet,mac_address) "00:01:02:03:04:05" }
      if { ! [ info exists conf(lxnet,autoflush) ] }     { set conf(lxnet,autoflush)     "1" }  
      if { ! [ info exists conf(lxnet,focuser_addr) ] }  { set conf(lxnet,focuser_addr)  "112" }
      if { ! [ info exists conf(lxnet,focuser_bit) ] }   { set conf(lxnet,focuser_bit)   "0" }
      if { ! [ info exists conf(lxnet,focuser_type) ] }  { set conf(lxnet,focuser_type)  "lx200" }
      if { ! [ info exists conf(lxnet,format) ] }        { set conf(lxnet,format)        "0" }
      if { ! [ info exists conf(lxnet,modele) ] }        { set conf(lxnet,modele)        "SkySensor 2000 PC" }

      #--- confToWidget
      set confTel(lxnet,host)         $conf(audinet,host)         
      set confTel(lxnet,ipsetting)    $conf(audinet,ipsetting) 
      set confTel(lxnet,mac_address)  $conf(audinet,mac_address)         
      set confTel(lxnet,autoflush)    $conf(lxnet,autoflush)
      set confTel(lxnet,focuser_addr) $conf(lxnet,focuser_addr)
      set confTel(lxnet,focuser_bit)  $conf(lxnet,focuser_bit)
      set confTel(lxnet,focuser_type) $conf(lxnet,focuser_type)
      set confTel(lxnet,format)       [ lindex "$caption(conftel,format_court_long)" $conf(lxnet,format) ]
      set confTel(lxnet,modele)       $conf(lxnet,modele)

      set confTel(raquette)           $conf(raquette)

      #--- Initialisation du panneau
      set frmm(Telscp7) [ Rnotebook:frame $nn 7 ]
      set frm $frmm(Telscp7)

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill x

      frame $frm.frameIPSetting -borderwidth 0 -relief raised
      pack $frm.frameIPSetting -side top -fill both -expand 1

      frame $frm.frame9 -borderwidth 0 -relief raised
      pack $frm.frame9 -side top -fill both -expand 1

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side top -fill both -expand 1

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -side top -fill both -expand 1

      frame $frm.frameFocuser -borderwidth 0 -relief raised
      pack $frm.frameFocuser -side top -fill both -expand 1

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -side top -fill both -expand 1

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -side bottom -fill x -pady 2

      frame $frm.frame6 -borderwidth 0 -relief raised
      pack $frm.frame6 -in $frm.frame1 -side left -fill both -expand 1

      frame $frm.frame7 -borderwidth 0 -relief raised
      pack $frm.frame7 -in $frm.frame1 -side left -fill both -expand 1

      frame $frm.frame8 -borderwidth 0 -relief raised
      pack $frm.frame8 -in $frm.frame6 -side top -fill x

      #--- Definition de l'adresse IP du host
      label $frm.lab1 -text "$caption(conftel,host_audinet)"
	pack $frm.lab1 -in $frm.frame8 -anchor center -side left -padx 10 -pady 10

      entry $frm.host -width 17 -textvariable confTel(lxnet,host)
	pack $frm.host -in $frm.frame8 -anchor center -side left -padx 0 -pady 10

      #--- Bouton de test de la connexion
      button $frm.ping -text "$caption(conftel,test_lxnet)" -relief raised -state normal \
         -command { 
            #--- Si l'envoi de l'adresse IP est demande, j'execute setip avant ping
            if { $confTel(lxnet,ipsetting) == "1" } {
               #--- Remarque : Comme setip est une commande specifique au telescope lxnet,
               #--- il faut creer temporairement un telescope de type lxnet pour pouvoir executer la commande
               set teltemp [ tel::create lxnet "" ]
               tel$teltemp setip $confTel(lxnet,mac_address) $confTel(lxnet,host)
               tel::delete $teltemp
            } 
            #--- J'execute la commande ping   
            ::confCam::testping $confTel(lxnet,host)
         }
	pack $frm.ping -in $frm.frame8 -anchor center -side right -padx 60 -pady 7 -ipadx 10 -ipady 5 -expand true

      #--- Envoi ou non de l'adresse IP a Audinet
      checkbutton $frm.ipsetting -text "$caption(conftel,envoyer_adresse_lxnet)" -highlightthickness 0 \
         -variable confTel(lxnet,ipsetting)
	pack $frm.ipsetting -in $frm.frameIPSetting -anchor center -side left -padx 10

      #--- Saisie adresse MAC
      entry $frm.macaddress -width 17 -textvariable confTel(lxnet,mac_address)
	pack $frm.macaddress -in $frm.frameIPSetting -anchor center -side right -padx 10

      #--- Label adresse MAC
      label $frm.labMac -text "$caption(conftel,mac_address)"
	pack $frm.labMac -in $frm.frameIPSetting -anchor center -side right -padx 0

      #--- Definition du format des donnees transmises au LXnet
      label $frm.lab2 -text "$caption(conftel,format)"
	pack $frm.lab2 -in $frm.frame9 -anchor center -side left -padx 10

      set list_combobox "$caption(conftel,format_court_long)"
      ComboBox $frm.formatradec \
         -width 7          \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confTel(lxnet,format) \
         -values $list_combobox
	pack $frm.formatradec -in $frm.frame9 -anchor center -side left -padx 0

      #--- Definition du mode de vidage de la communication avec le telescope
      checkbutton $frm.autoflush -text "$caption(conftel,autoflush)" -highlightthickness 0 \
         -variable confTel(lxnet,autoflush)
	pack $frm.autoflush -in $frm.frame9 -anchor center -side left -expand true

      #--- Definition du LX200 ou du clone
      set list_combobox [ list $caption(conftel,modele_lx200) $caption(conftel,modele_audecom) \
         $caption(conftel,modele_skysensor) $caption(conftel,modele_gemini) ]
      ComboBox $frm.modele \
         -width 17         \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -textvariable confTel(lxnet,modele) \
         -editable 0       \
         -values $list_combobox
   	pack $frm.modele -in $frm.frame9 -anchor center -side right -padx 10

      label $frm.lab3 -text "$caption(conftel,modele)"
	pack $frm.lab3 -in $frm.frame9 -anchor center -side right -padx 0

      #--- Le bouton de commande maj heure et position du LXnet
      button $frm.majpara -text "$caption(conftel,maj_lx200)" -relief raised -state normal -command {
         catch {
            tel$audace(telNo) date [ mc_date2jd [ ::audace::date_sys2ut now ] ]
            tel$audace(telNo) home $audace(posobs,observateur,gps)
         }
      }
      pack $frm.majpara -in $frm.frame2 -anchor center -side top -padx 10 -pady 5 -ipadx 10 -ipady 5 -expand true

      #--- Gestion du bouton actif/inactif
      ::confTel::connectLXnet

      #--- Le checkbutton pour la visibilite de la raquette a l'ecran
      checkbutton $frm.raquette -text "$caption(conftel,raquette_tel)" \
         -highlightthickness 0 -variable confTel(raquette)
	pack $frm.raquette -in $frm.frame3 -anchor center -side left -padx 10 -pady 10
      ComboBox $frm.nom_raquette \
         -width 10         \
         -height [ llength $::confPad::private(driverlist) ]  \
         -relief sunken    \
         -borderwidth 1    \
         -modifycmd {
            set label $audace(nom_raquette)
            set index [lsearch -exact $::confPad::private(driverlist) $label ]
            if { $index != -1 } {
               set ::confPad::private(conf_confPad) [ lindex $::confPad::private(namespacelist) $index ]
            } else {
               set ::confPad::private(conf_confPad) ""
            }
            set conf(confPad) $::confPad::private(conf_confPad)

            ::confPad::run
         } \
         -textvariable audace(nom_raquette) \
         -editable 0       \
         -values $::confPad::private(driverlist)
      pack $frm.nom_raquette -in $frm.frame3 -anchor center -side left -padx 0 -pady 10

      #--- Choix de la raquette
      button $frm.choix_raquette -text "$caption(conftel,config_raquette)" -command { ::confPad::run }
	pack $frm.choix_raquette -in $frm.frame3 -anchor center -side top -padx 10 -pady 10 -ipadx 20 -ipady 5 -expand true

      #--- Choix du systeme de mise au point (focuser)
      label $frm.lab_focuser_type -text "$caption(conftel,focuser_type)"
      pack $frm.lab_focuser_type -in $frm.frameFocuser -anchor center -side left -padx 10

      set list_combobox [ list lx200 i2c ] 
      ComboBox $frm.combo_focuser_type \
         -width 6          \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -values $list_combobox \
         -textvariable confTel(lxnet,focuser_type) \
         -modifycmd {
            #--- Autoriser/masquer l'autre widget en fontion du type de focuser
            global confTel frmm
            if { $confTel(lxnet,focuser_type) == "lx200" } {   
               $frmm(Telscp7).ent_focuser_adr configure -state disabled        
            } else {                                            
               $frmm(Telscp7).ent_focuser_adr configure -state normal      
            } 
         }
      #--- Je selectionne la valeur par defaut
      pack $frm.combo_focuser_type -in $frm.frameFocuser -anchor center -side left -padx 10

      #--- Label adresse I2C du focuser 
      label $frm.lab_focuser_adr -text "$caption(conftel,focuser_i2c_address)"
      pack $frm.lab_focuser_adr -in $frm.frameFocuser -anchor center -side left -padx 10
      
      #--- Saisie adresse I2C du focuser 
      entry $frm.ent_focuser_adr -width 17 -textvariable confTel(lxnet,focuser_addr)
      pack $frm.ent_focuser_adr -in $frm.frameFocuser -anchor center -side left -padx 10

      #--- Site web officiel du LXnet
      label $frm.lab103 -text "$caption(conftel,site_web_ref)"
      pack $frm.lab103 -in $frm.frame5 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(conftel,site_lxnet)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame5 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $frm.labURL <ButtonPress-1> {
         set filename "$caption(conftel,site_lxnet)"
         ::audace::Lance_Site_htm $filename
      }
      bind $frm.labURL <Enter> {
	   global frmm
         set frm $frmm(Telscp7)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
	   global frmm
         set frm $frmm(Telscp7)
         $frm.labURL configure -fg $color(blue)
      }

      #--- J'autorise l'affichage des parametres associes a la valeur par defaut
      uplevel #0  "[ $frm.combo_focuser_type cget -modifycmd ]"

      bind [ Rnotebook:button $nn 7 ] <Button-1> { global confTel ; set confTel(tel) "lxnet" }
   }

   #
   # Onglet de configuration des modules Temma
   #
   proc fillPage8 { nn } {
      global audace caption color conf confTel frmm

      #--- initConf
      if { ! [ info exists conf(temma,correc_AD) ] }  { set conf(temma,correc_AD)  "50" }
      if { ! [ info exists conf(temma,correc_Dec) ] } { set conf(temma,correc_Dec) "50" }
      if { ! [ info exists conf(temma,liaison) ] }    { set conf(temma,liaison)    "1" }
      if { ! [ info exists conf(temma,modele) ] }     { set conf(temma,modele)     "0" }
      if { ! [ info exists conf(temma,port) ] }       { set conf(temma,port)       [ lindex $audace(list_com) 0 ] }
      if { ! [ info exists conf(temma,suivi_ad) ] }   { set conf(temma,suivi_ad)   "0" }
      if { ! [ info exists conf(temma,suivi_dec) ] }  { set conf(temma,suivi_dec)  "0" }
      if { ! [ info exists conf(temma,type) ] }       { set conf(temma,type)       "0" }

      #--- confToWidget
      set confTel(temma,correc_AD)   $conf(temma,correc_AD)
      set confTel(temma,correc_Dec)  $conf(temma,correc_Dec)
      set confTel(temma,liaison)     $conf(temma,liaison)
      set confTel(temma,modele)      [ lindex "$caption(conftel,temma_modele_1) $caption(conftel,temma_modele_2) $caption(conftel,temma_modele_3)" $conf(temma,modele) ]
      set confTel(temma,port)        $conf(temma,port)
      set confTel(temma,suivi_ad)    $conf(temma,suivi_ad)
      set confTel(temma,suivi_dec)   $conf(temma,suivi_dec)
      set confTel(temma,type)        $conf(temma,type)

      set confTel(raquette)          $conf(raquette)

      #--- Initialisation
      set frmm(Telscp8) [ Rnotebook:frame $nn 8 ]
      set frm $frmm(Telscp8)

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill x

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side top -fill x

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -side top -fill x

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -in $frm.frame2 -side left -fill x -expand 1

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -in $frm.frame2 -side left -fill x

      frame $frm.frame6 -borderwidth 0 -relief raised
      pack $frm.frame6 -side top -fill x

      frame $frm.frame7 -borderwidth 0 -relief raised
      pack $frm.frame7 -side top -fill x

      frame $frm.frame8 -borderwidth 0 -relief raised
      pack $frm.frame8 -side bottom -fill x -pady 2

      #--- Definition du port
      label $frm.lab1 -text "$caption(conftel,port)"
	pack $frm.lab1 -in $frm.frame1 -anchor center -side left -padx 10 -pady 10

      ComboBox $frm.port \
         -width 14         \
         -height [ llength $audace(list_com) ]  \
         -relief sunken    \
         -borderwidth 1    \
         -textvariable confTel(temma,port) \
         -editable 0       \
         -values $audace(list_com)
      pack $frm.port -in $frm.frame1 -anchor center -side left -padx 10 -pady 10

      #--- Definition du modele Temma
      set list_combobox [ list $caption(conftel,temma_modele_1) $caption(conftel,temma_modele_2) \
         $caption(conftel,temma_modele_3) ]
      ComboBox $frm.modele \
         -width 25         \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -textvariable confTel(temma,modele) \
         -editable 0       \
         -values $list_combobox
	pack $frm.modele -in $frm.frame1 -anchor center -side right -padx 10 -pady 10

      label $frm.lab2 -text "$caption(conftel,modele)"
	pack $frm.lab2 -in $frm.frame1 -anchor center -side right -padx 10 -pady 10

      #--- Liaison des curseurs d'AD et de Dec.
      if { $confTel(temma,liaison) != "1" } {

         #--- Label de la correction en AD
         label $frm.lab3 -text "$caption(conftel,temma_correc_AD)"
         pack $frm.lab3 -in $frm.frame4 -anchor e -side top -pady 7

         #--- Le checkbutton pour la liaison physique des 2 reglages en Ad et en Dec.
         checkbutton $frm.liaison -text "$caption(conftel,temma_liaison_AD_Dec)" -highlightthickness 0 \
            -variable confTel(temma,liaison) -onvalue 1 -offvalue 0 -command { ::confTel::config_correc_Temma }
         pack $frm.liaison -in $frm.frame4 -anchor w -side top -padx 10

         #--- Label de la correction en Dec
         label $frm.lab4 -text "$caption(conftel,temma_correc_Dec)"
         pack $frm.lab4 -in $frm.frame4 -anchor e -side top -pady 7

         #--- Reglage de la vitesse de correction en AD pour la vitesse normale (NS)
         scale $frm.correc_variantAD -from 10 -to 90 -length 210 -orient horizontal -showvalue true -tickinterval 10 \
            -borderwidth 2 -relief groove -variable confTel(temma,correc_AD) -width 10
         pack $frm.correc_variantAD -in $frm.frame5 -side top -padx 10

         #--- Reglage de la vitesse de correction en Dec. pour la vitesse normale (NS)
         scale $frm.correc_variantDec -from 10 -to 90 -length 210 -orient horizontal -showvalue true -tickinterval 10 \
            -borderwidth 2 -relief groove -variable confTel(temma,correc_Dec) -width 10
         pack $frm.correc_variantDec -in $frm.frame5 -side top -padx 10

      } else {

         #--- Label de la correction en AD
         label $frm.lab3 -text "$caption(conftel,temma_correc_AD)"
         pack $frm.lab3 -in $frm.frame4 -anchor e -side top

         #--- Le checkbutton pour la liaison physique des 2 reglages en Ad et en Dec.
         checkbutton $frm.liaison -text "$caption(conftel,temma_liaison_AD_Dec)" -highlightthickness 0 \
            -variable confTel(temma,liaison) -command { ::confTel::config_correc_Temma }
         pack $frm.liaison -in $frm.frame4 -anchor w -side top -padx 10

         #--- Label de la correction en Dec
         label $frm.lab4 -text "$caption(conftel,temma_correc_Dec)"
         pack $frm.lab4 -in $frm.frame4 -anchor e -side top

         #--- Reglage de la vitesse de correction en AD pour la vitesse normale (NS)
         scale $frm.correc_variantAD -from 10 -to 90 -length 210 -orient horizontal -showvalue true -tickinterval 10 \
            -borderwidth 2 -relief groove -variable confTel(temma,correc_AD) -width 10
         pack $frm.correc_variantAD -in $frm.frame5 -side top -padx 10

         #--- Liaison des corrections en AD et en Dec.
         set confTel(temma,correc_Dec) $confTel(temma,correc_AD)

      }

      #--- Position du telescope sur la monture equatoriale allemande : A l'est ou a l'ouest
      label $frm.pos_tel -text "$caption(conftel,position_telescope)"
	pack $frm.pos_tel -in $frm.frame3 -anchor center -side left -padx 10 -pady 10

      label $frm.pos_tel_ew -width 15 -anchor w -textvariable audace(pos_tel_ew)
	pack $frm.pos_tel_ew -in $frm.frame3 -anchor center -side left -pady 10

      #--- Initialisation de l'instrument au zenith
      if { $confTel(temma,connect) == "1" } {
         button $frm.init_zenith -text "$caption(conftel,temma_init_zenith)" -relief raised -state normal -command {
            tel$audace(telNo) initzenith
            ::telescope::afficheCoord
         }
         pack $frm.init_zenith -in $frm.frame3 -anchor nw -side right -padx 10 -pady 10 -ipadx 5 -ipady 5
      } else {
         button $frm.init_zenith -text "$caption(conftel,temma_init_zenith)" -relief raised -state disabled
         pack $frm.init_zenith -in $frm.frame3 -anchor nw -side right -padx 10 -pady 10 -ipadx 5 -ipady 5
      }

      #--- Nouvelle position d'origine du telescope : A l'est ou a l'ouest
      label $frm.pos_tel_est -text "$caption(conftel,change_position_telescope)"
      pack $frm.pos_tel_est -in $frm.frame6 -anchor center -side left -padx 10 -pady 5

      if { $confTel(temma,connect) == "1" } {
         button $frm.chg_pos_tel -relief raised -state normal -textvariable audace(chg_pos_tel) -command {
            set pos_tel [ tel$audace(telNo) german ]
            if { $pos_tel == "E" } {
               tel$audace(telNo) german W
            } elseif { $pos_tel == "W" } {
               tel$audace(telNo) german E
            }
            ::telescope::monture_allemande
         }
         pack $frm.chg_pos_tel -in $frm.frame6 -anchor nw -side left -padx 10 -pady 10 -ipadx 5 -ipady 5
      } else {
         button $frm.chg_pos_tel -text "  ?  " -relief raised -state disabled
         pack $frm.chg_pos_tel -in $frm.frame6 -anchor nw -side left -padx 10 -pady 10 -ipadx 5 -ipady 5
      }

      #--- Bouton de controle de la vitesse de suivi
      button $frm.tracking -text "$caption(conftel,temma_ctl_mobile)" -state normal \
         -command { ::confTemmaMobile::run "$audace(base).confTemmaMobile" }
      pack $frm.tracking -in $frm.frame6 -anchor center -side right -padx 10 -pady 10 -ipadx 5 -ipady 5

      #--- Rafraichissement de la position du telescope par rapport a la monture
      if { $confTel(temma,connect) == "1" } {
         #--- Affichage de la position du telescope
         ::telescope::monture_allemande
      }

      #--- Le checkbutton pour la visibilite de la raquette a l'ecran
      checkbutton $frm.raquette -text "$caption(conftel,raquette_tel)" \
         -highlightthickness 0 -variable confTel(raquette)
      pack $frm.raquette -in $frm.frame7 -anchor nw -side left -padx 10 -pady 10
      ComboBox $frm.nom_raquette \
         -width 10         \
         -height [ llength $::confPad::private(driverlist) ]  \
         -relief sunken    \
         -borderwidth 1    \
         -modifycmd {
            set label $audace(nom_raquette)
            set index [lsearch -exact $::confPad::private(driverlist) $label ]
            if { $index != -1 } {
               set ::confPad::private(conf_confPad) [ lindex $::confPad::private(namespacelist) $index ]
            } else {
               set ::confPad::private(conf_confPad) ""
            }
            set conf(confPad) $::confPad::private(conf_confPad)

            ::confPad::run
         } \
         -textvariable audace(nom_raquette) \
         -editable 0       \
         -values $::confPad::private(driverlist)
      pack $frm.nom_raquette -in $frm.frame7 -anchor center -side left -padx 0 -pady 10

      #--- Choix de la raquette
      button $frm.choix_raquette -text "$caption(conftel,config_raquette)" -command { ::confPad::run }
	pack $frm.choix_raquette -in $frm.frame7 -anchor center -side top -padx 10 -pady 5 -ipadx 20 -ipady 5 -expand true

      #--- Site web officiel Temma et Takahashi
      label $frm.lab103 -text "$caption(conftel,site_web_ref)"
      pack $frm.lab103 -in $frm.frame8 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(conftel,site_temma)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame8 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $frm.labURL <ButtonPress-1> {
         set filename "$caption(conftel,site_temma)"
         ::audace::Lance_Site_htm $filename
      }
      bind $frm.labURL <Enter> {
	   global frmm
         set frm $frmm(Telscp8)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
	   global frmm
         set frm $frmm(Telscp8)
         $frm.labURL configure -fg $color(blue)
      }

      bind [ Rnotebook:button $nn 8 ] <Button-1> { global confTel ; set confTel(tel) "temma" }
   }

   #
   # Onglet de configuration de MCMT
   #
   proc fillPage9 { nn } {
      global audace caption color conf confTel frmm

      #--- initConf
      if { ! [ info exists conf(mcmt,nbr_dent_ad) ] }  { set conf(mcmt,nbr_dent_ad)  "360" }
      if { ! [ info exists conf(mcmt,nbr_dent_dec) ] } { set conf(mcmt,nbr_dent_dec) "359" }
      if { ! [ info exists conf(mcmt,port) ] }         { set conf(mcmt,port)         [ lindex $audace(list_com) 0 ] }

      #--- confToWidget
      set confTel(mcmt,nbr_dent_ad)  $conf(mcmt,nbr_dent_ad)
      set confTel(mcmt,nbr_dent_dec) $conf(mcmt,nbr_dent_dec)
      set confTel(mcmt,port)         $conf(mcmt,port)

      set confTel(raquette)          $conf(raquette)

      #--- Initialisation
      set frmm(Telscp9) [ Rnotebook:frame $nn 9 ]
      set frm $frmm(Telscp9)

      #--- Creation des differents frames
      frame $frm.frame1 -borderwidth 0 -relief raised
      pack $frm.frame1 -side top -fill x

      frame $frm.frame2 -borderwidth 0 -relief raised
      pack $frm.frame2 -side top -fill both -expand 1

      frame $frm.frame3 -borderwidth 0 -relief raised
      pack $frm.frame3 -side bottom -fill x -pady 2

      frame $frm.frame4 -borderwidth 0 -relief raised
      pack $frm.frame4 -in $frm.frame2 -anchor n -side left -fill x

      frame $frm.frame5 -borderwidth 0 -relief raised
      pack $frm.frame5 -in $frm.frame2 -anchor n -side left -fill x -expand 1

      frame $frm.frame6 -borderwidth 0 -relief raised
      pack $frm.frame6 -in $frm.frame4 -fill x

      frame $frm.frame7 -borderwidth 0 -relief raised
      pack $frm.frame7 -in $frm.frame4 -fill x

      frame $frm.frame8 -borderwidth 0 -relief raised
      pack $frm.frame8 -in $frm.frame5 -anchor w -side top -fill x -expand 1

      frame $frm.frame9 -borderwidth 0 -relief raised
      pack $frm.frame9 -in $frm.frame5 -anchor w -side top -fill x -expand 1

      frame $frm.frame10 -borderwidth 0 -relief raised
      pack $frm.frame10 -anchor nw -side top -fill x -expand 1

      #--- Definition du port
      label $frm.lab1 -text "$caption(conftel,port)"
	pack $frm.lab1 -in $frm.frame1 -anchor center -side left -padx 10 -pady 10

      ComboBox $frm.port \
         -width 14         \
         -height [ llength $audace(list_com) ]  \
         -relief sunken    \
         -borderwidth 1    \
         -textvariable confTel(mcmt,port) \
         -editable 0       \
         -values $audace(list_com)
      pack $frm.port -in $frm.frame1 -anchor center -side left -padx 10 -pady 10

	#--- Label pour la roue AD
	label $frm.lab_nbr_dent_ad -text "$caption(conftel,mcmt_nbre_dents_roue_ad)"
	pack $frm.lab_nbr_dent_ad -in $frm.frame6 -anchor center -side left -padx 10 -pady 5

	#--- Valeur du nombre de dents de la roue AD
      entry $frm.nbr_dent_ad -textvariable confTel(mcmt,nbr_dent_ad) -justify center -width 5
	pack $frm.nbr_dent_ad -in $frm.frame8 -anchor center -side left -padx 10 -pady 5

	#--- Label pour la roue Dec
      label $frm.lab_nbr_dent_dec -text "$caption(conftel,mcmt_nbre_dents_roue_dec)"
	pack $frm.lab_nbr_dent_dec -in $frm.frame7 -anchor center -side left -padx 10 -pady 5

	#--- Valeur du nombre de dents de la roue Dec
      entry $frm.nbr_dent_dec -textvariable confTel(mcmt,nbr_dent_dec) -justify center -width 5
	pack $frm.nbr_dent_dec -in $frm.frame9 -anchor center -side left -padx 10 -pady 5

      #--- Le checkbutton pour la visibilite de la raquette a l'ecran
      checkbutton $frm.raquette -text "$caption(conftel,raquette_tel)" \
         -highlightthickness 0 -variable confTel(raquette)
      pack $frm.raquette -in $frm.frame10 -anchor nw -side left -padx 10 -pady 10
      ComboBox $frm.nom_raquette \
         -width 10         \
         -height [ llength $::confPad::private(driverlist) ]  \
         -relief sunken    \
         -borderwidth 1    \
         -modifycmd {
            set label $audace(nom_raquette)
            set index [lsearch -exact $::confPad::private(driverlist) $label ]
            if { $index != -1 } {
               set ::confPad::private(conf_confPad) [ lindex $::confPad::private(namespacelist) $index ]
            } else {
               set ::confPad::private(conf_confPad) ""
            }
            set conf(confPad) $::confPad::private(conf_confPad)

            ::confPad::run
         } \
         -textvariable audace(nom_raquette) \
         -editable 0       \
         -values $::confPad::private(driverlist)
      pack $frm.nom_raquette -in $frm.frame10 -anchor center -side left -padx 0 -pady 10

      #--- Choix de la raquette
      button $frm.choix_raquette -text "$caption(conftel,config_raquette)" -command { ::confPad::run }
	pack $frm.choix_raquette -in $frm.frame10 -anchor center -side top -padx 10 -pady 5 -ipadx 20 -ipady 5 -expand true

      #--- Site web officiel de MCMT
      label $frm.lab103 -text "$caption(conftel,site_web_ref)"
      pack $frm.lab103 -in $frm.frame3 -side top -fill x -pady 2

      label $frm.labURL -text "$caption(conftel,site_mcmt)" -font $audace(font,url) -fg $color(blue)
      pack $frm.labURL -in $frm.frame3 -side top -fill x -pady 2

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $frm.labURL <ButtonPress-1> {
         set filename "$caption(conftel,site_mcmt)"
         ::audace::Lance_Site_htm $filename
      }
      bind $frm.labURL <Enter> {
	   global frmm
         set frm $frmm(Telscp9)
         $frm.labURL configure -fg $color(purple)
      }
      bind $frm.labURL <Leave> {
	   global frmm
         set frm $frmm(Telscp9)
         $frm.labURL configure -fg $color(blue)
      }

      bind [ Rnotebook:button $nn 9 ] <Button-1> { global confTel ; set confTel(tel) "mcmt" }
   }

   #
   # confTel::Format_Match_AD
   # Definit le format en entree de l'AD pour MATCH d'Ouranos
   #
   proc Format_Match_AD { } {
      global audace caption

      if [ winfo exists $audace(base).format_match_ad ] {
         destroy $audace(base).format_match_ad
      }
      toplevel $audace(base).format_match_ad
      wm transient $audace(base).format_match_ad $audace(base).confTel
      wm title $audace(base).format_match_ad "$caption(conftel,attention)"
      if { $::tcl_platform(os) == "Linux" } {
         set posx_format_match_ad [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 1 ]
         set posy_format_match_ad [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 2 ]
         wm geometry $audace(base).format_match_ad +[ expr $posx_format_match_ad + 74 ]+[ expr $posy_format_match_ad + 185 ]
      } else {
         set posx_format_match_ad [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 1 ]
         set posy_format_match_ad [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 2 ]
         wm geometry $audace(base).format_match_ad +[ expr $posx_format_match_ad + 30 ]+[ expr $posy_format_match_ad + 185 ]
      }
      wm resizable $audace(base).format_match_ad 0 0

      #--- Cree l'affichage du message
      label $audace(base).format_match_ad.lab1 -text "$caption(conftel,ouranos_formataddec1)"
      uplevel #0 { pack $audace(base).format_match_ad.lab1 -padx 10 -pady 2 }
      label $audace(base).format_match_ad.lab2 -text "$caption(conftel,ouranos_formataddec2)"
      uplevel #0 { pack $audace(base).format_match_ad.lab2 -padx 10 -pady 2 }

      #--- La nouvelle fenetre est active
      focus $audace(base).format_match_ad

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).format_match_ad
   }

   #
   # confTel::Format_Match_Dec
   # Definit le format en entree de la Dec pour MATCH d'Ouranos
   #
   proc Format_Match_Dec { } {
      global audace caption

      if [ winfo exists $audace(base).format_match_dec ] {
         destroy $audace(base).format_match_dec
      }
      toplevel $audace(base).format_match_dec
      wm transient $audace(base).format_match_dec $audace(base).confTel
      wm title $audace(base).format_match_dec "$caption(conftel,attention)"
      if { $::tcl_platform(os) == "Linux" } {
         set posx_format_match_dec [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 1 ]
         set posy_format_match_dec [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 2 ]
         wm geometry $audace(base).format_match_dec +[ expr $posx_format_match_dec + 294 ]+[ expr $posy_format_match_dec + 162 ]
      } else {
         set posx_format_match_dec [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 1 ]
         set posy_format_match_dec [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 2 ]
         wm geometry $audace(base).format_match_dec +[ expr $posx_format_match_dec + 224 ]+[ expr $posy_format_match_dec + 162 ]
      }
      wm resizable $audace(base).format_match_dec 0 0

      #--- Cree l'affichage du message
      label $audace(base).format_match_dec.lab3 -text "$caption(conftel,ouranos_formataddec3)"
      uplevel #0 { pack $audace(base).format_match_dec.lab3 -padx 10 -pady 2 }
      label $audace(base).format_match_dec.lab4 -text "$caption(conftel,ouranos_formataddec4)"
      uplevel #0 { pack $audace(base).format_match_dec.lab4 -padx 10 -pady 2 }
      label $audace(base).format_match_dec.lab5 -text "$caption(conftel,ouranos_formataddec5)"
      uplevel #0 { pack $audace(base).format_match_dec.lab5 -padx 10 -pady 2 }

      #--- La nouvelle fenetre est active
      focus $audace(base).format_match_dec

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).format_match_dec
   }

   #
   # confTel::Connect_Telescope
   # Affichage d'un message d'alerte pendant la connexion du telescope au demarrage
   #
   proc Connect_Telescope { } {
      variable This
      global audace caption color

      if [ winfo exists $audace(base).connectTelescope ] {
         destroy $audace(base).connectTelescope
      }

      toplevel $audace(base).connectTelescope
      wm resizable $audace(base).connectTelescope 0 0
      wm title $audace(base).connectTelescope "$caption(conftel,attention)"
      if { [ info exists This ] } {
         set posx_connectTelescope [ lindex [ split [ wm geometry $This ] "+" ] 1 ]
         set posy_connectTelescope [ lindex [ split [ wm geometry $This ] "+" ] 2 ]
         wm geometry $audace(base).connectTelescope +[ expr $posx_connectTelescope + 50 ]+[ expr $posy_connectTelescope + 100 ]
         wm transient $audace(base).connectTelescope $This
      } else {
         wm geometry $audace(base).connectTelescope +200+100
         wm transient $audace(base).connectTelescope $audace(base)
      }

      #--- Cree l'affichage du message
      label $audace(base).connectTelescope.labURL_1 -text "$caption(conftel,connexion_texte1)" \
         -font $audace(font,arial_10_b) -fg $color(red)
      uplevel #0 { pack $audace(base).connectTelescope.labURL_1 -padx 10 -pady 2 }
      label $audace(base).connectTelescope.labURL_2 -text "$caption(conftel,connexion_texte2)" \
         -font $audace(font,arial_10_b) -fg $color(red)
      uplevel #0 { pack $audace(base).connectTelescope.labURL_2 -padx 10 -pady 2 }

      #--- La nouvelle fenetre est active
      focus $audace(base).connectTelescope

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).connectTelescope
   }

   #
   # confTel::select [ tel ]
   # Selectionne un onglet en passant le nom (eventuellement) du telescope decrit dans le panneau
   #
   proc select { { tel lx200 } } {
      variable This
      global confTel

      set nn $This.usr.book
      set confTel(tel) $tel
      switch -exact -- $tel {
         mcmt    { Rnotebook:raise $nn 9 }
         temma   { Rnotebook:raise $nn 8 }
         lxnet   { Rnotebook:raise $nn 7 }
         telcom  { Rnotebook:raise $nn 6 }
         avrcom  { Rnotebook:raise $nn 5 }
         compad  { Rnotebook:raise $nn 4 }
         audecom { Rnotebook:raise $nn 3 }
         ouranos { Rnotebook:raise $nn 2 }
         lx200   { Rnotebook:raise $nn 1 }
      }
   }

   #
   # confTel::configureTelescope
   # Configure le telescope en fonction des donnees contenues dans le tableau conf :
   # conf(telescope) -> type de telescope employe
   # conf(tel,...)   -> proprietes de ce type de telescope
   #
   proc configureTelescope { } {
      variable This
      global audace caption conf confTel espion frmm ouranoscom

      #--- Affichage d'un message d'alerte si necessaire
      ::confTel::Connect_Telescope

      #--- Inhibe les menus
      ::audace::menustate disabled

      #--- Efface la fenetre de controle de la vitesse de King si elle existe
      if { [ winfo exists $audace(base).confAudecomKing ] && ( $conf(telescope) != "audecom" ) } {
         set espion 1
         destroy $audace(base).confAudecomKing
      }

      switch -exact -- $conf(telescope) {
         audecom {
               set confTel(lx200,connect)   "0"
               set confTel(ouranos,connect) "0"
               set confTel(audecom,connect) "1"
               set confTel(avrcom,connect)  "0"
               set confTel(telcom,connect)  "0"
               set confTel(lxnet,connect)   "0"
               set confTel(temma,connect)   "0"
               set confTel(mcmt,connect)    "0"
               if { [ llength [ tel::list ] ] == "1" } { tel::delete [ tel::list ] }
               set erreur [ catch { tel::create audecom $conf(audecom,port) } msg ]
               if { $erreur == "1" } {
                  if { $audace(list_com) == "" } {
                     #--- Commentaire uniquement en anglais (donc pas de caption)
                     append msg "\nNo Port COM."
                  }
                  tk_messageBox -message "$msg" -icon error
                  set confTel(audecom,connect) "0"
               } else {
                  console::affiche_saut "\n"
                  console::affiche_erreur "$caption(conftel,port_audecom) $caption(conftel,2points)\
                     $conf(audecom,port)\n"
                  set audace(telNo) $msg
                  ::confTel::connectAudeCom
                  #--- Lit et affiche la version du firmware
                  set v_firmware [ tel$audace(telNo) firmware ]
                  set v_firmware "[ string range $v_firmware 0 0 ].[ string range $v_firmware 1 2 ]"
                  console::affiche_erreur "$caption(conftel,audecom_ver_firmware)$v_firmware\n"
                  #--- Transfere les parametres des moteurs dans le microcontroleur
                  tel$audace(telNo) slewspeed $conf(audecom,maxad) $conf(audecom,maxdec)
                  tel$audace(telNo) pulse $conf(audecom,limp)
                  tel$audace(telNo) mechanicalplay $conf(audecom,rat_ad) $conf(audecom,rat_dec)
                  tel$audace(telNo) focspeed $conf(audecom,vitesse)
                  #--- R : Inhibe le PEC
                  tel$audace(telNo) pec_period 0
                  #--- Transfere les corrections pour le PEC dans le microcontroleur
                  for { set i 0 } { $i <= 19 } { incr i } {
                     tel$audace(telNo) pec_speed $conf(audecom,t$i)
                  }
                  #--- r : Active ou non le PEC
                  if { $conf(audecom,pec) == "1" } {
                     tel$audace(telNo) pec_period $conf(audecom,rpec)
                  }
                  #--- Transfere les parametres de derive dans le microcontroleur
		      set vit_der_alpha "0" ; set vit_der_delta "0"
                  if { $confTel(fenetre,mobile,valider) == "1" } {
                     if { $conf(audecom,mobile) == "1" } {
		            switch -exact -- $conf(audecom,type) {
                           0 { set vit_der_alpha "43636" ; set vit_der_delta "0" } ; #--- Lune
                           1 { set vit_der_alpha "3548"  ; set vit_der_delta "0" } ; #--- Soleil
                           2 { set vit_der_alpha $conf(audecom,ad) ; set vit_der_delta $conf(audecom,dec) } ; #--- Comete
                           3 { set vit_der_alpha "0" ; set vit_der_delta "0" } ; #--- Etoile
                        }
		         }
                  } else {
                     catch { set frm $frmm(Telscp3) }
                     set confTel(conf_audecom,mobile) "0"
                     set conf(audecom,mobile)         "0"
                     if { $conf(telescope,start) != "1" } {
                        $frm.mobile configure
                     }
                  }
		      #--- Precaution pour ne jamais diviser par zero
		      if { $vit_der_alpha == "0" } { set vit_der_alpha "1" }
		      if { $vit_der_delta == "0" } { set vit_der_delta "1" }
		      #--- Calcul de la correction
                  set alpha [ expr $conf(audecom,dsuivinom)*1296000/$vit_der_alpha ]
		      set alpha [ expr round($alpha) ]
                  set delta [ expr $conf(audecom,dsuividelta)*1296000/$vit_der_delta ]
		      set delta [ expr round($delta) ]
		      #--- Bornage de la correction
                  if { $alpha > "99999999" }  { set alpha "99999999" }
		      if { $alpha < "-99999999" } { set alpha "-99999999" }
                  if { $delta > "99999999" }  { set delta "99999999" }
		      if { $delta < "-99999999" } { set delta "-99999999" }
		      #--- Arret des moteurs + Application des corrections + Mise en marche des moteurs
                  tel$audace(telNo) radec motor off
                  tel$audace(telNo) driftspeed $alpha $delta
                  tel$audace(telNo) radec motor on
                  #--- Affichage de la position du telescope
                 ### ::telescope::monture_allemande
               }
            }
         ouranos {
               set conf(raquette)           "0"
               set confTel(lx200,connect)   "0"
               set confTel(ouranos,connect) "1"
               set confTel(audecom,connect) "0"
               set confTel(avrcom,connect)  "0"
               set confTel(telcom,connect)  "0"
               set confTel(lxnet,connect)   "0"
               set confTel(temma,connect)   "0"
               set confTel(mcmt,connect)    "0"
               #--- Arrete la lecture des coordonnees
               set ouranoscom(lecture) "0"
               if { [ llength [ tel::list ] ] == "1" } { tel::delete [ tel::list ] }
               set erreur [ catch { tel::create ouranos $conf(ouranos,port) } msg ]
               if { $erreur == "1" } {
                  if { $audace(list_com) == "" } {
                     #--- Commentaire uniquement en anglais (donc pas de caption)
                     append msg "\nNo Port COM."
                  }
                  tk_messageBox -message "$msg" -icon error
               } else {
                  console::affiche_saut "\n"
                  console::affiche_erreur "$caption(conftel,port_ouranos) $caption(conftel,2points)\
                     $conf(ouranos,port)\n"
                  console::affiche_erreur "$caption(conftel,ouranos_res_codeurs)\n"
                  console::affiche_erreur "$caption(conftel,ra) $caption(conftel,2points)\
                     $conf(ouranos,cod_ra) $caption(conftel,ouranos_pas) $caption(conftel,et) $caption(conftel,dec)\
                     $caption(conftel,2points) $conf(ouranos,cod_dec) $caption(conftel,ouranos_pas)\n\n"
                  set audace(telNo) $msg
                  set ouranoscom(tty) [ tel$audace(telNo) channel ]
                  #--- Initialisation de l'interface Ouranos
                  tel$audace(telNo) invert $conf(ouranos,inv_ra) $conf(ouranos,inv_dec)
                  tel$audace(telNo) resolution $conf(ouranos,cod_ra) $conf(ouranos,cod_dec)
                  #--- Initialisation de l'affichage
                  set confTel(conf_ouranos,coord_ra) ""
                  set confTel(conf_ouranos,coord_dec) ""
                  #--- Statut du port
                  set confTel(conf_ouranos,status) $caption(conftel,ouranos_on)
               }
               #--- Gestion des boutons actifs/inactifs
               ::confTel::MatchOuranos
            }
         lx200 {
               set confTel(lx200,connect)   "1"
               set confTel(ouranos,connect) "0"
               set confTel(audecom,connect) "0"
               set confTel(avrcom,connect)  "0"
               set confTel(telcom,connect)  "0"
               set confTel(lxnet,connect)   "0"
               set confTel(temma,connect)   "0"
               set confTel(mcmt,connect)    "0"
               if { [ llength [ tel::list ] ] == "1" } { tel::delete [ tel::list ] }
               set erreur [ catch { tel::create lx200 $conf(lx200,port) } msg ]
               if { $erreur == "1" } {
                  if { $audace(list_com) == "" } {
                     #--- Commentaire uniquement en anglais (donc pas de caption)
                     append msg "\nNo Port COM."
                  }
                  tk_messageBox -message "$msg" -icon error
               } else {
                  console::affiche_saut "\n"
                  console::affiche_erreur "$caption(conftel,port_lx200) ($conf(lx200,modele))\
                     $caption(conftel,2points) $conf(lx200,port)\n"
                  set audace(telNo) $msg
                  if { $conf(lx200,format) == "0" } {
                     tel$audace(telNo) longformat off
                  } else {
                     tel$audace(telNo) longformat on
                  }
                  if { $conf(lx200,modele) == "Ite-lente" } {
                     tel$audace(telNo) tempo $conf(lx200,ite-lente_tempo)
                  }
               }
            }
         compad {
               set conf(raquette)           "0"
               set confTel(lx200,connect)   "0"
               set confTel(ouranos,connect) "0"
               set confTel(audecom,connect) "0"
               set confTel(avrcom,connect)  "0"
               set confTel(telcom,connect)  "0"
               set confTel(lxnet,connect)   "0"
               set confTel(temma,connect)   "0"
               set confTel(mcmt,connect)    "0"
               if { [ llength [ tel::list ] ] == "1" } { tel::delete [ tel::list ] }
               set erreur [ catch { tel::create compad $conf(compad,port) } msg ]
               if { $erreur == "1" } {
                  if { $audace(list_com) == "" } {
                     #--- Commentaire uniquement en anglais (donc pas de caption)
                     append msg "\nNo Port COM."
                  }
                  tk_messageBox -message "$msg" -icon error
              } else {
                  console::affiche_saut "\n"
                  console::affiche_erreur "$caption(conftel,port_compad) $caption(conftel,2points)\
                     $conf(compad,port)\n"
                  set audace(telNo) $msg
               }
            }
         avrcom {
               set conf(raquette)           "0"
               set confTel(lx200,connect)   "0"
               set confTel(ouranos,connect) "0"
               set confTel(audecom,connect) "0"
               set confTel(avrcom,connect)  "1"
               set confTel(telcom,connect)  "0"
               set confTel(lxnet,connect)   "0"
               set confTel(temma,connect)   "0"
               set confTel(mcmt,connect)    "0"
               if { [ llength [ tel::list ] ] == "1" } { tel::delete [ tel::list ] }
               set erreur [ catch { tel::create avrcom $conf(avrcom,port) } msg ]
               if { $erreur == "1" } {
                  if { $audace(list_com) == "" } {
                     #--- Commentaire uniquement en anglais (donc pas de caption)
                     append msg "\nNo Port COM."
                  }
                  tk_messageBox -message "$msg" -icon error
               } else {
                  console::affiche_saut "\n"
                  console::affiche_erreur "$caption(conftel,port_avrcom) $caption(conftel,2points)\
                     $conf(avrcom,port)\n"
                  set audace(telNo) $msg
               }
            }
         telcom {
               set confTel(lx200,connect)   "0"
               set confTel(ouranos,connect) "0"
               set confTel(audecom,connect) "0"
               set confTel(avrcom,connect)  "0"
               set confTel(telcom,connect)  "1"
               set confTel(lxnet,connect)   "0"
               set confTel(temma,connect)   "0"
               set confTel(mcmt,connect)    "0"
               #---
               if { [ llength [ tel::list ] ] == "1" } { tel::delete [ tel::list ] }
               set erreur [ catch { tel::create telcom $conf(telcom,port) } msg ]
               if { $erreur == "1" } {
                  if { $audace(list_com) == "" } {
                     #--- Commentaire uniquement en anglais (donc pas de caption)
                     append msg "\nNo Port COM."
                  }
                  tk_messageBox -message "$msg" -icon error
               } else {
                  #--- Mise a 'zero' des bits
                  catch {
                     combit [ string range $conf(telcom,port) 3 3 ] 3 0
                     combit [ string range $conf(telcom,port) 3 3 ] 4 0
                     combit [ string range $conf(telcom,port) 3 3 ] 7 0
                  }
                  #---
                  console::affiche_saut "\n"
                  console::affiche_erreur "$caption(conftel,port_telcom) $caption(conftel,2points) $conf(telcom,port)\n"
                  set audace(telNo) $msg
               }
            }
         lxnet {
               set confTel(lx200,connect)   "0"
               set confTel(ouranos,connect) "0"
               set confTel(audecom,connect) "0"
               set confTel(avrcom,connect)  "0"
               set confTel(telcom,connect)  "0"
               set confTel(lxnet,connect)   "1"
               set confTel(temma,connect)   "0"
               set confTel(mcmt,connect)    "0"
               if { [ llength [ tel::list ] ] == "1" } { tel::delete [ tel::list ] }
               set erreur [ catch { set audace(telNo) [ tel::create lxnet "" -name lxnet \
                     -host $conf(audinet,host) \
                     -ipsetting $conf(audinet,ipsetting) \
                     -macaddress $conf(audinet,mac_address) \
                     -autoflush $conf(lxnet,autoflush) \
                     -focusertype $conf(lxnet,focuser_type) \
                     -focuseraddr $conf(lxnet,focuser_addr) \
                     -focuserbit $conf(lxnet,focuser_bit)   \
                  ] } msg ]
               if { $erreur == "1" } {
                  tk_messageBox -message "$msg" -icon error    
               } else {
                  console::affiche_saut "\n"
                  console::affiche_erreur "$caption(conftel,host_audinet) $caption(conftel,2points)\
                     $conf(audinet,host)\n"  
                  set audace(telNo) $msg
                  if { $conf(lxnet,format) == "0" } {
                     tel$audace(telNo) longformat off
                  } else {
                     tel$audace(telNo) longformat on
                  }
               }
            }
         temma {
               set confTel(lx200,connect)   "0"
               set confTel(ouranos,connect) "0"
               set confTel(audecom,connect) "0"
               set confTel(avrcom,connect)  "0"
               set confTel(telcom,connect)  "0"
               set confTel(lxnet,connect)   "0"
               set confTel(temma,connect)   "1"
               set confTel(mcmt,connect)    "0"
               if { [ llength [ tel::list ] ] == "1" } { tel::delete [ tel::list ] }
               set erreur [ catch { tel::create temma $conf(temma,port) } msg ]
               if { $erreur == "1" } {
                  if { $audace(list_com) == "" } {
                     #--- Commentaire uniquement en anglais (donc pas de caption)
                     append msg "\nNo Port COM."
                  }
                  tk_messageBox -message "$msg" -icon error
               } else {
                  if { $conf(temma,modele) == "0" } {
                     set confTel(temma,modele) $caption(conftel,temma_modele_1)
                  } elseif { $conf(temma,modele) == "1" } {
                     set confTel(temma,modele) $caption(conftel,temma_modele_2)
                  } else {
                     set confTel(temma,modele) $caption(conftel,temma_modele_3)
                  }
                  console::affiche_saut "\n"
                  console::affiche_erreur "$caption(conftel,port_temma) ($confTel(temma,modele)) \
                     $caption(conftel,2points) $conf(temma,port)\n"
                  set audace(telNo) $msg
                  #--- Lit et affiche la version du Temma
                  set version [ tel$audace(telNo) firmware ]
                  console::affiche_erreur "$caption(conftel,temma_version) $version\n"
                  #--- Demande et recoit la latitude
                  set latitude_temma [ tel$audace(telNo) getlatitude ]
                  #--- Mise en forme de la latitude du lieu du format Temma au format d'affichage
                  set signe_lat [ string range $latitude_temma 0 0 ]
                  if { $signe_lat == "-" } {
                     set signe_lat "S"
                     set lat_deg [ lindex [ mc_angle2dms $latitude_temma 90 zero ] 0 ]
                     set lat_deg [ string range $lat_deg 1 2 ]
                  } else {
                     set signe_lat "N"
                     set lat_deg [ lindex [ mc_angle2dms $latitude_temma 90 zero ] 0 ]
                  }
                  set lat_min [ lindex [ mc_angle2dms $latitude_temma 90 zero ] 1 ]
                  set lat_min_deci [ format "%.1f" [ expr [ lindex [ mc_angle2dms $latitude_temma 90 zero ] 2 ] / 60.0 ] ]
                  set lat_min_deci [ string range $lat_min_deci 2 2 ]
                  set latitude_temma "$signe_lat $lat_deg° $lat_min.$lat_min_deci'"
                  #--- Affichage de la latitude
                  ::console::affiche_erreur "$caption(conftel,temma_init_module)\n"
                  ::console::affiche_erreur "$caption(conftel,temma_latitude) $latitude_temma\n\n"
                  #--- Prise en compte des encodeurs
                  tel$audace(telNo) encoder "1"
                  #--- Force la mise en marche des moteurs
                  tel$audace(telNo) radec motor on
                  #--- Prise en compte des corrections de la vitesse normale en AD et en Dec.
                  if { $conf(temma,liaison) == "1" } {
                     tel$audace(telNo) correctionspeed $conf(temma,correc_AD) $conf(temma,correc_AD)
                  } else {
                     tel$audace(telNo) correctionspeed $conf(temma,correc_AD) $conf(temma,correc_Dec)
                  }
                  #--- Correction de la vitesse de suivi en ad et en dec
                  if { $conf(temma,type) == "0" } {
                     tel$audace(telNo) driftspeed 0 0
                     ::console::affiche_resultat "$caption(temma,para_mobile_etoile)\n\n"
                  } elseif { $conf(temma,type) == "1" } {
                     tel$audace(telNo) driftspeed $conf(temma,suivi_ad) $conf(temma,suivi_dec)
                     set correction_suivi [ tel$audace(telNo) driftspeed ]
                     ::console::affiche_resultat "$caption(temma,para_ctl_mobile)\n"
                     ::console::affiche_resultat "$caption(temma,para_mobile_ad) $caption(temma,2points)\
                        [ lindex $correction_suivi 0 ]\n"
                     ::console::affiche_resultat "$caption(temma,para_mobile_dec) $caption(temma,2points)\
                        [ lindex $correction_suivi 1 ]\n\n"
                  }
                  #--- Affichage de la position du telescope
                  ::telescope::monture_allemande
               }
               #--- Gestion des boutons actifs/inactifs
               ::confTel::config_correc_Temma
            }
         mcmt {
               set confTel(lx200,connect)   "0"
               set confTel(ouranos,connect) "0"
               set confTel(audecom,connect) "0"
               set confTel(avrcom,connect)  "0"
               set confTel(telcom,connect)  "0"
               set confTel(lxnet,connect)   "0"
               set confTel(temma,connect)   "0"
               set confTel(mcmt,connect)    "1"
               if { [ llength [ tel::list ] ] == "1" } { tel::delete [ tel::list ] }
               set erreur [ catch { tel::create mcmt $conf(mcmt,port) } msg ]
               if { $erreur == "1" } {
                  if { $audace(list_com) == "" } {
                     #--- Commentaire uniquement en anglais (donc pas de caption)
                     append msg "\nNo Port COM."
                  }
                  tk_messageBox -message "$msg" -icon error
               } else {
                  console::affiche_saut "\n"
                  console::affiche_erreur "$caption(conftel,port_mcmt) $caption(conftel,2points)\
                     $conf(mcmt,port)\n"
                  set audace(telNo) $msg
               }
            }
      }

      #--- Raffraichissement de la vitesse dans les raquettes et les panneaux, et de l'affichage des coordonnees
      if { $conf(raquette) == "1" } {
         ::confPad::configureDriver
      } else {
         ::confPad::stopDriver
      }
      if { $erreur == "0" } {
         if  { ( $conf(telescope) != "ouranos" ) && ( $conf(telescope) != "compad" ) && 
            ( $conf(telescope) != "telcom" ) } {
            ::telescope::setSpeed "$audace(telescope,speed)"
            ::focus::setSpeed "$audace(focus,speed)"

         } else {
            ::telescope::setSpeed "0"
            ::focus::setSpeed "0"
         }
         ::telescope::afficheCoord
      }

      #--- Gestion du modele de telescope connecte
      if { $erreur == "1" } {
         #--- En cas de probleme, je desactive le demarrage automatique	 
         set conf(telescope,start) "0" 
         #--- En cas de probleme, telescope par defaut
         set conf(telescope)      "lx200"
         set conf(lx200,port)     [ lindex $audace(list_com) 0 ]
         set confTel(lx200,connect)   "0"
         set confTel(ouranos,connect) "0"
         set confTel(audecom,connect) "0"
         set confTel(avrcom,connect)  "0"
         set confTel(telcom,connect)  "0"
         set confTel(lxnet,connect)   "0"
         set confTel(temma,connect)   "0"
         set confTel(mcmt,connect)    "0"
         $audace(base).fra1.labTel_name configure -text "$caption(conftel,tiret)"
      } else {
         $audace(base).fra1.labTel_name configure -text "$conf(telescope)"
      }

      #--- Gestion des boutons actifs/inactifs
      ::confTel::connectLX200
      ::confTel::connectLXnet
      ::confTel::connectOuranos
      if { $conf(telescope) != "audecom" } {
         ::confTel::connectAudeCom
      }
      ::confTel::connectAvrCom
      ::confTel::connectTemma

      #--- Effacement du message d'alerte s'il existe
      if [ winfo exists $audace(base).connectTelescope ] {
         destroy $audace(base).connectTelescope
      }

      #--- Restaure les menus
      ::audace::menustate normal
   }

   #
   # confTel::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc widgetToConf { } {
      variable This
      global audace caption conf confTel

      set nn $This.usr.book
      set conf(telescope)             $confTel(tel)
      set conf(raquette)       	  $confTel(raquette)
      #--- Memorise la configuration du LX200 dans le tableau conf(lx200,...)
      set frm [ Rnotebook:frame $nn 1 ]
      set conf(lx200,port)            $confTel(lx200,port)
      set conf(lx200,format)          [ lsearch "$caption(conftel,format_court_long)" "$confTel(lx200,format)" ]
      set conf(lx200,modele)          $confTel(lx200,modele)
      set conf(lx200,ite-lente_tempo) $confTel(lx200,ite-lente_tempo)
      #--- Memorise la configuration de Ouranos dans le tableau conf(ouranos,...)
      set frm [ Rnotebook:frame $nn 2 ]
      set conf(ouranos,cod_dec)       $confTel(conf_ouranos,cod_dec)
      set conf(ouranos,cod_ra)        $confTel(conf_ouranos,cod_ra)
      set conf(ouranos,freq)          $confTel(conf_ouranos,freq)
      set conf(ouranos,init)          $confTel(conf_ouranos,init)
      set conf(ouranos,inv_dec)       $confTel(conf_ouranos,inv_dec)
      set conf(ouranos,inv_ra)        $confTel(conf_ouranos,inv_ra)
      set conf(ouranos,port)          $confTel(ouranos,port)
      set conf(ouranos,show_coord)    $confTel(conf_ouranos,show_coord)
      #--- Memorise la configuration de AudeCom dans le tableau conf(audecom,...)
      set frm [ Rnotebook:frame $nn 3 ]
      set conf(audecom,port)          $confTel(conf_audecom,port)
      set conf(audecom,pec)           $confTel(conf_audecom,pec)
      set conf(audecom,king)          $confTel(conf_audecom,king)
      set conf(audecom,mobile)        $confTel(conf_audecom,mobile)
      set conf(audecom,german)        $confTel(conf_audecom,german)
      #--- Vient de la fenetre de configuration des parametres moteurs
      set conf(audecom,limp)          $confTel(conf_audecom,limp)
      set conf(audecom,maxad)         $confTel(conf_audecom,maxad)
      set conf(audecom,maxdec)        $confTel(conf_audecom,maxdec)
      set conf(audecom,rat_ad)        $confTel(conf_audecom,rat_ad)
      set conf(audecom,rat_dec)       $confTel(conf_audecom,rat_dec)
      #--- Vient de la fenetre de configuration des parametres de la focalisation
      set conf(audecom,dep_val)       $confTel(conf_audecom,dep_val)
      set conf(audecom,intra_extra)   $confTel(conf_audecom,intra_extra)
      set conf(audecom,inv_rot)       $confTel(conf_audecom,inv_rot)
      set conf(audecom,vitesse)       $confTel(conf_audecom,vitesse)
      #--- Vient de la fenetre de configuration de la programmation PEC
      set conf(audecom,rpec)          $confTel(conf_audecom,rpec)
      set conf(audecom,t0)            $confTel(conf_audecom,t0)
      set conf(audecom,t1)            $confTel(conf_audecom,t1)
      set conf(audecom,t2)            $confTel(conf_audecom,t2)
      set conf(audecom,t3)            $confTel(conf_audecom,t3)
      set conf(audecom,t4)            $confTel(conf_audecom,t4)
      set conf(audecom,t5)            $confTel(conf_audecom,t5)
      set conf(audecom,t6)            $confTel(conf_audecom,t6)
      set conf(audecom,t7)            $confTel(conf_audecom,t7)
      set conf(audecom,t8)            $confTel(conf_audecom,t8)
      set conf(audecom,t9)            $confTel(conf_audecom,t9)
      set conf(audecom,t10)           $confTel(conf_audecom,t10)
      set conf(audecom,t11)           $confTel(conf_audecom,t11)
      set conf(audecom,t12)           $confTel(conf_audecom,t12)
      set conf(audecom,t13)           $confTel(conf_audecom,t13)
      set conf(audecom,t14)           $confTel(conf_audecom,t14)
      set conf(audecom,t15)           $confTel(conf_audecom,t15)
      set conf(audecom,t16)           $confTel(conf_audecom,t16)
      set conf(audecom,t17)           $confTel(conf_audecom,t17)
      set conf(audecom,t18)           $confTel(conf_audecom,t18)
      set conf(audecom,t19)           $confTel(conf_audecom,t19)
      #--- Vient de la fenetre de configuration de suivi
      set conf(audecom,ad)            $confTel(conf_audecom,ad)
      set conf(audecom,dec)       	  $confTel(conf_audecom,dec)
      set conf(audecom,type)          $confTel(conf_audecom,type)
      #--- Memorise la configuration du ComPad dans le tableau conf(compad,...)
      set frm [ Rnotebook:frame $nn 4 ]
      set conf(compad,port)           $confTel(compad,port)
      #--- Memorise la configuration du AvrCom dans le tableau conf(avrcom,...)
      set frm [ Rnotebook:frame $nn 5 ]
      set conf(avrcom,port)           $confTel(avrcom,port)
      #--- Memorise la configuration du TelCom dans le tableau conf(telcom,...)
      set frm [ Rnotebook:frame $nn 6 ]
      set conf(telcom,port)           $confTel(telcom,port)
      #--- Memorise la configuration de LXnet dans le tableau conf(lxnet,...)
      set frm [ Rnotebook:frame $nn 7 ]
      #--- Remarque : L'adresse IP du host de LXnet est la meme adresse que celle de la camera AudiNet
      set conf(audinet,host)          $confTel(lxnet,host)
      set conf(audinet,ipsetting)     $confTel(lxnet,ipsetting)
      set conf(audinet,mac_address)   $confTel(lxnet,mac_address)
      set conf(lxnet,autoflush)       $confTel(lxnet,autoflush)
      set conf(lxnet,focuser_addr)    $confTel(lxnet,focuser_addr)
      set conf(lxnet,focuser_bit)     $confTel(lxnet,focuser_bit)
      set conf(lxnet,focuser_type)    $confTel(lxnet,focuser_type)
      set conf(lxnet,format)          [ lsearch "$caption(conftel,format_court_long)" "$confTel(lxnet,format)" ]
      set conf(lxnet,modele)          $confTel(lxnet,modele)
      #--- Memorise la configuration du module temma dans le tableau conf(temma,...)
      set frm [ Rnotebook:frame $nn 8 ]
      set conf(temma,correc_AD)       $confTel(temma,correc_AD)
      set conf(temma,correc_Dec)      $confTel(temma,correc_Dec)
      set conf(temma,liaison)         $confTel(temma,liaison)
      set conf(temma,modele)          [ lsearch "$caption(conftel,temma_modele_1) $caption(conftel,temma_modele_2) $caption(conftel,temma_modele_3)" "$confTel(temma,modele)" ]
      set conf(temma,port)            $confTel(temma,port)
      set conf(temma,suivi_ad)        $confTel(temma,suivi_ad)
      set conf(temma,suivi_dec)       $confTel(temma,suivi_dec)
      set conf(temma,type)            $confTel(temma,type)
      #--- Memorise la configuration du MCMT dans le tableau conf(mcmt,...)
      set frm [ Rnotebook:frame $nn 9 ]
      set conf(mcmt,nbr_dent_ad)      $confTel(mcmt,nbr_dent_ad)
      set conf(mcmt,nbr_dent_dec)     $confTel(mcmt,nbr_dent_dec)
      set conf(mcmt,port)             $confTel(mcmt,port)
   }
}

#--- Connexion au demarrage du telescope selectionne par defaut
::confTel::init

