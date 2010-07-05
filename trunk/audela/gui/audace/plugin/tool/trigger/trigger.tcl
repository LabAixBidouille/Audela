#
# Fichier : trigger.tcl
# Description : Outil de declenchement pour APN Canon non reconnu par libgphoto2_canon.dll
# Auteur : Raymond Zachantke
# Mise à jour $Id: trigger.tcl,v 1.3 2010-07-05 20:46:49 robertdelmas Exp $
#

#============================================================
# Declaration du namespace trigger
#    initialise le namespace
#============================================================
namespace eval ::trigger {
   package provide trigger 1.0
   package require audela 1.4.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]]  trigger.cap ]

   #------------------------------------------------------------
   # getPluginTitle
   #    retourne le titre du plugin dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(trigger,title)"
   }

   #------------------------------------------------------------
   # getPluginHelp
   #    retourne le nom du fichier d'aide principal
   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "trigger.htm"
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
      return "trigger"
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
         subfunction  { return "trigger" }
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
      global panneau

      #--- Mise en place de l'interface graphique
      createPanel $in.trigger
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
      variable This

      #---
      set This $this

      #---
      set panneau(trigger,base) "$this"

      triggerBuildIF $This
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

   #------------------------------------------------------------
   # triggerBuildIF
   #    cree la fenetre de l'outil
   #------------------------------------------------------------
   proc triggerBuildIF { This } {
      global audace panneau caption color
      variable Trigger

      #---
      frame $This -borderwidth 2 -relief groove
      pack $This
         #--- Frame du titre
         frame $This.fra1 -borderwidth 2 -relief groove
            #--- Bouton du titre
            Button $This.fra1.but -borderwidth 1 \
               -text "$caption(trigger,help_titre1)\n$caption(trigger,title)" \
               -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::trigger::getPluginType ] ] \
                  [ ::trigger::getPluginDirectory ] [ ::trigger::getPluginHelp ]"
            pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $caption(trigger,help_titre)
         pack $This.fra1 -side top -fill x

         #--   le frame cantonnant les commandes et le bouton GO
         set Trigger $This.fra2
         frame $Trigger -borderwidth 1 -relief sunken
         pack $Trigger -side top -fill x

         #--   initialise les listes pour les combobox
         set panneau(trigger,portLabels) [ ::confLink::getLinkLabels { "parallelport" "quickremote" "serialport" "external" } ]
         set panneau(trigger,port) [ lindex $panneau(trigger,portLabels) 0 ]
         set panneau(trigger,bitLabels) [ ::confLink::getPluginProperty $panneau(trigger,port) bitList ]
         set panneau(trigger,cdeLabels) { 0 1 }
         set panneau(trigger,modeLabels) [ list "$caption(trigger,mode,one)" "$caption(trigger,mode,serie)" ]

         ::blt::table $Trigger

         #--   construction des combobox
         foreach child { port bit cde mode } {
            set len [ llength $panneau(trigger,${child}Labels) ]
            label $Trigger.${child}_lab -text $caption(trigger,$child)
            ComboBox $Trigger.$child -borderwidth 1 -width 5 -height $len \
               -relief sunken -justify center \
               -textvariable panneau(trigger,$child) \
               -values "$panneau(trigger,${child}Labels)"
         }
         $Trigger.port configure -modifycmd "::trigger::configBit" -width 10
         $Trigger.mode configure -modifycmd "::trigger::configPan"

         #--   construit les entrees de donnees
         foreach child { nb_poses activtime delai periode } {
            LabelEntry $Trigger.$child -label $caption(trigger,$child) \
               -textvariable ::trigger::$child -labelanchor w -labelwidth 8 \
               -borderwidth 1 -relief flat -padx 2 -justify right \
               -width 5 -relief sunken
            bind $Trigger.$child <Leave> [ list ::trigger::test $Trigger $child ]
         }

         #--   label pour afficher les etapes
         label $Trigger.state -textvariable panneau(trigger,action) \
            -width 14 -borderwidth 2 -relief sunken

         #-- checkbutton pour la longuepose
         checkbutton $Trigger.lp -text $caption(trigger,lp) \
            -indicatoron "1" -offvalue "0" -onvalue "1" \
            -variable ::trigger::lp -command "::trigger::configTime"

         #--   configure le bouton de lancement d'acquisition
         button $Trigger.but1 -borderwidth 2 -text "$caption(trigger,go)" \
            -command "::trigger::timer"

         ::blt::table $Trigger \
            $Trigger.port_lab 0,0 \
            $Trigger.port 0,1 \
            $Trigger.bit_lab 1,0 \
            $Trigger.bit 1,1 \
            $Trigger.cde_lab 2,0 \
            $Trigger.cde 2,1 \
            $Trigger.mode_lab 3,0 \
            $Trigger.mode 3,1 \
            $Trigger.state 4,0 -cspan 2 \
            $Trigger.nb_poses 5,0 -cspan 2 \
            $Trigger.lp 6,0 -cspan 2 \
            $Trigger.activtime 7,0 -cspan 2 \
            $Trigger.delai 8,0 -cspan 2 \
            $Trigger.periode 9,0 -cspan 2 \
            $Trigger.but1 10,0 -cspan 2 -ipady 3 -fill x
            ::blt::table configure $Trigger r* -pady 2

         #--   ajoute les aides
         foreach child { cde nb_poses activtime delai periode } {
            DynamicHelp::add $Trigger.$child -text $caption(trigger,help$child)
         }

         #--   selectionne les valeurs initiales
         foreach frm { port bit cde mode } index { 0 0 1 0 } {
            set panneau(trigger,$frm) [ lindex $panneau(trigger,${frm}Labels) 0 ]
            $Trigger.$frm setvalue @0
         }

         lassign { "1" " " "0" "1" " " "0" } ::trigger::lp ::trigger::activtime \
            ::trigger::delai ::trigger::periode panneau(trigger,action) \
            panneau(trigger,serieNo)

         $Trigger.lp invoke
         configPan

         #--- Mise ajour dynamique des couleurs
         ::confColor::applyColor $This
   }

   ######################################################################
   #-- Gere les prises de vue a partir des reglages de l'utilisateur    #
   ######################################################################
   proc timer {} {
      global panneau caption
      variable Trigger

      foreach var [ list nb_poses periode activtime delai ] {
         ::trigger::test $Trigger $var
      }

      #--   gele les commandes
      setWindowState disabled

      #--   affiche 'Attente'
      set panneau(trigger,action) $caption(trigger,action,wait)

      #--   memorise les valeurs initiales
      set panneau(trigger,settings) [ list $::trigger::nb_poses \
         $::trigger::periode $::trigger::activtime ]

      #--   raccourcis
      lassign $panneau(trigger,settings) nb_poses periode activtime

      #--   cherche l'index de Une Image/Une série
      set mode [ lsearch $panneau(trigger,modeLabels) $panneau(trigger,mode) ]

      #---  si la pose est differee, affichage du temps restant
      if { $::trigger::delai != 0 } {
         delay delai
      }

      #--   compteur de shoot
      incr panneau(trigger,serieNo) "1"
      ::console::affiche_resultat "\n[ format $caption(trigger,prisedevue) $panneau(trigger,serieNo) ]\n"

      #--   compte les declenchements
      set count 1

      while { $::trigger::nb_poses > 0 } {

         #--   affiche 'Acquisition'
         set panneau(trigger,action) "$caption(trigger,action,acq)"

         #--   capture le temps
         set time_now [ clock seconds ]
         set time [ clock format $time_now -format "%Y %m %d %H %M %S" -timezone :UTC ]

         #--   declenche
         shoot "$activtime"

         #--   message sur la console
         set msg "$time N°$count"
         if { $activtime != " " } {
            append msg "  $activtime sec."
         }
         ::console::affiche_resultat "$msg\n"

         #--   incremente le nombre de shoot
         incr count

         #--   decremente et affiche le nombre de poses qui reste a prendre
         incr ::trigger::nb_poses "-1"

         #--   recharge la duree
         set ::trigger::activtime $activtime

         #--   si c'est Une serie et si ce n'est pas la derniere image
         if { $mode == "1" && $count <= $nb_poses } {

            #--   met a jour la periode pour Une serie
            set i [ expr { $time_now + $periode - [ clock seconds ] } ]

            if { $i > 1 } {
               #--   met a jour le timer
               set ::trigger::periode $i
               #--   decompte les secondes
              delay periode
            }
         }
      }

      #--   degele les commandes
      setWindowState normal

      #--   retablit les valeurs initiales
      lassign $panneau(trigger,settings) ::trigger::nb_poses \
         ::trigger::periode ::trigger::activtime
   }

   ######################################################################
   #--   Declenche un shoot                                             #
   #  parametre : duree                                                 #
   ######################################################################
   proc shoot { t } {
      global panneau

      #--   definit les variables locales
      lassign [ list $panneau(trigger,port) $panneau(trigger,bit) $panneau(trigger,cde) ] \
         port bit start
      set stop  [ expr { 1-$start } ]

      #--   cree une liaison avec le port
      set linkNo [ ::confLink::create "$port" "camera inconnue" "pose" "" ]

      #--- demarre une pose
      if { [ catch { link$linkNo bit "$bit" $start } ] == "1" } {
         avertiUser driver
         return
      }

      if { $t != " " } {
         #--   decremente le compteur de largeur d'impulsion
         delay activtime
      } else {
         #--   la duree minimale de l'impulsion est fixee a 500 msec
         after 500
      }

      #--- arrete la pose
      link$linkNo bit "$bit" $stop

      #--- ferme la liaison
      ::confLink::delete "$port" "camera inconnue" "pose"
   }

   ######################################################################
   #--   Gere l'etat des widgets lies a Trigger                         #
   ######################################################################
   proc setWindowState { state } {
      variable Trigger

      if { $state == "disabled" } {
         foreach child [ list port bit cde mode lp nb_poses activtime delai periode but1 ] {
            $Trigger.$child configure -state "$state"
         }
      } else {
         foreach child [ list port bit cde mode lp delai but1 ] {
            $Trigger.$child configure -state "$state"
         }
         configPan
         configTime
      }
   }

   ######################################################################
   #--   Configure le panneau en fonction du mode                       #
   #  appele par le bouton de mode et par setWindowState                #
   ######################################################################
   proc configPan { } {
      global panneau
      variable Trigger

      set indice [ lsearch $panneau(trigger,modeLabels) $panneau(trigger,mode) ]
      switch $indice {
         "0"   {  lassign { "1" " " } ::trigger::nb_poses ::trigger::periode
                  foreach child { nb_poses periode } {
                     $Trigger.$child configure -state disabled
                  }
               }
         "1"   {  lassign [ list "2" "1" " " ] ::trigger::nb_poses \
                     ::trigger::periode panneau(trigger,action)
                  foreach child { nb_poses periode } {
                     $Trigger.$child configure -state normal
                  }
               }
      }
   }

   ############################################################################
   #--   Configure l'entree de $Trigger.bit en fonction du port               #
   ############################################################################
   proc configBit {} {
      global panneau
      variable Trigger

      set panneau(trigger,bitLabels) [ ::confLink::getPluginProperty \
         $panneau(trigger,port) bitList ]
      set len [ llength $panneau(trigger,bitLabels) ]
      $Trigger.bit configure -values "$panneau(trigger,bitLabels)" -height $len
      $Trigger.bit setvalue @0
   }

   ######################################################################
   #--   Configure la saisie du temps appelee par le checkbutton        #
   ######################################################################
   proc configTime {} {
      variable Trigger

      set time $::trigger::activtime
      if { $::trigger::lp == "1" } {
         if { $time == " " } {
            set data [ list "normal" "1" ]
         } else {
            set data [ list "normal" "$time" ]
         }
      } else {
         set data [ list "disabled" " " ]
      }
      lassign $data state ::trigger::activtime
      $Trigger.activtime configure -state $state
   }

   ######################################################################
   #--   Teste si les valeurs entrees dans les fenetres actives         #
   #--   sont des entiers ; teste si la periode > duree                 #
   #     parametre : fenetre et entree                                  #
   ######################################################################
   proc test { w child } {

      #--   arrete si l'entree est disabled
      if { [ $w.$child cget -state ] == "disabled" } {
         return
      }

      set nom_var [ LabelEntry::cget $w.$child -textvariable ]

      if ![ TestEntier [ set $nom_var ] ] {
         avertiUser $child
         if { $child == "nb_poses" || $child == "activtime" || $child == "periode"  } {
            set $nom_var "1"
         } elseif { $child == "delai" } {
            set $nom_var "0"
         }
      }
      if { $child == "periode" &&  ( [ set $nom_var ] <= "$::trigger::activtime" ) } {
         avertiUser "periode"
         set $nom_var [ expr { $::trigger::activtime+1 } ]
      }
   }

   ######################################################################
   #--   Fenetre d'avertissement                                        #
   #     parametre : variable de caption                                #
   ######################################################################
   proc avertiUser { nom } {
      global caption

      tk_messageBox -title $caption(trigger,attention)\
         -icon error -type ok -message $caption(trigger,help$nom)
   }

   ######################################################################
   #--   Decompteur de secondes                                         #
   #  parametre : nom de la variable a decompter (delai ou periode)     #
   ######################################################################
   proc delay { var } {

      upvar 1 ::trigger::$var t
      while { $t > "0" } {
            after 1000
            incr t "-1"
            update
      }
      set t "0"
      update
   }

#--   fin du namespace
}

