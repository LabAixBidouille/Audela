#
# Fichier : spytimer.tcl
# Description : Outil pour APN Canon non reconnu par libgphoto2_canon.dll
# Auteur : Raymond Zachantke
# Mise à jour $Id$
#

#============================================================
# Declaration du namespace spytimer
#    initialise le namespace
#============================================================
namespace eval ::spytimer {
   package provide spytimer 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]]  spytimer.cap ]
   source [ file join [file dirname [info script]]  foc.tcl ]

   #------------------------------------------------------------
   # getPluginTitle
   #    retourne le titre du plugin dans la langue de l'utilisateur
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(spytimer,title)"
   }

   #------------------------------------------------------------
   # getPluginHelp
   #    retourne le nom du fichier d'aide principal
   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "spytimer.htm"
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
      return "spytimer"
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
         subfunction  { return "dslr" }
         display      { return "panel" }
         multivisu    { return 1 }
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

      package require BLT

      #--- Mise en place de l'interface graphique
      createPanel $in.spytimer $visuNo
   }

   #------------------------------------------------------------
   # deletePluginInstance
   #    suppprime l'instance du plugin
   #------------------------------------------------------------
   proc deletePluginInstance { visuNo } {
      variable private

      #--   sauvegarde les parametres
      if [ catch { open $private(fichier_ini) w } fichier ] {
         Message console "%s\n" $fichier
      } else {

         #--   liste le nom des variables
         set variable_list [ list port bit cde xpixsz ypixsz pixsize1 pixsize2 crota2 foclen aptdia ]

         #--   liste leur valeur
         foreach var $variable_list {
            lappend value_list $private($visuNo,$var)
         }

         #--   sauve le nom et la valeur
         foreach var $variable_list val $value_list {
            puts $fichier "set parametres($var) \"$val\""
         }
         close $fichier
      }

      #--   desactive le timeListener
      if { [ trace info variable ::audace(hl,format,hm)]  ne "" } {
         trace remove variable ":::audace(hl,format,hm)" write "::spytimer::autoShoot $visuNo"
      }
   }

   #------------------------------------------------------------
   # createPanel : prepare la creation de la fenetre de l'outil
   #  Parametres : chemin et N° de la visu
   #------------------------------------------------------------
   proc createPanel { this visuNo } {
      variable private
      global audace conf

      set private(fichier_ini) [ file join $audace(rep_home) spytimer$visuNo.ini ]

      set default_values [ list port "" bit "" cde "" xpixsz "" \
         ypixsz "" pixsize1 "" pixsize2 "" crota2 "" foclen "" aptdia "" ]

      if { [ file exists $private(fichier_ini) ] } {
         source $private(fichier_ini)
      }

      foreach { param value } $default_values {
         if { [ info exists parametres($param) ] }  {
            #--   affecte les valeurs initiales sauvegardees dans le fichier ini
            set private($visuNo,$param) $parametres($param)

            if { $param eq "aptdia" } {
               #--   calcule le pouvoir separateur
               set private($visuNo,pouvoir_separateur) [ format "%.3f" [ expr { 0.120 / $private($visuNo,$param) } ] ]
            }

         } elseif { [ info exists parametres($param) ] == 0 && $param ni [ list port bit cde ] } {
            #--   sinon prend la valeur par defaut pour les autres variables
            set private($visuNo,$param) $value
         }
      }

      #--   identifie le nom de la configuration des mots cles
      set configName $conf(spytimer,visu$visuNo,keywordConfigName)

      #--   obtient la liste des variables checkees
      set checked $::conf(keyword,$configName,check)
      regsub -all "1,check," $checked " " checked

      #--   valide les mots cles checkes
      foreach kwd [ list aptdia crota2 foclen pixsize1 pixsize2 xpixsz ypixsz ] {
         if { [ string toupper $kwd ] in $checked } {
            set private($visuNo,opt_$kwd) 1
         } else {
            set private($visuNo,opt_$kwd) 0
         }
      }

      set private($visuNo,portLabels) [ ::confLink::getLinkLabels { "parallelport" "quickremote" "serialport" "external" } ]
      if { ![ info exists private($visuNo,port) ] } {
         set private($visuNo,port) [lindex $private($visuNo,portLabels) 0]
      }

      #--   arrete si aucun port
      if { $private($visuNo,portLabels) eq "" } {
         ::spytimer::stopTool
         ::spytimer::deletePluginInstance
      }

      set private($visuNo,bitLabels) [ ::confLink::getPluginProperty $private($visuNo,port) bitList ]
      if { ![ info exists private($visuNo,bit) ] } {
         set private($visuNo,bit) [ lindex $private($visuNo,bitLabels) 0 ]
      }

      set private($visuNo,cdeLabels) { 0 1 }
      if { ![ info exists private($visuNo,cde) ] } {
         set private($visuNo,cde) [ lindex $private($visuNo,cdeLabels) 1 ]
      }

      set private($visuNo,intervalle) 1

      #---
      set private($visuNo,base) "$this"

      if { [ winfo exists $this ] } { destroy $this }

      spytimerBuildIF $visuNo
   }

   #------------------------------------------------------------
   # startTool : affiche la fenetre de l'outil
   #  Parametres : N° de la visu
   #------------------------------------------------------------
   proc startTool { visuNo } {
      variable private

	  #--- On cree la variable de configuration des mots cles
      if { ![ info exists ::conf(spytimer,visu$visuNo,keywordConfigName) ] } {
		   set ::conf(spytimer,visu$visuNo,keywordConfigName) "default"
      }
      pack $private($visuNo,base) -side left -fill y
   }

   #------------------------------------------------------------
   # stopTool : masque la fenetre de l'outil
   #  Parametres : N° de la visu
   #------------------------------------------------------------
   proc stopTool { visuNo } {
      variable private

      pack forget $private($visuNo,base)
   }

   #------------------------------------------------------------
   # spytimerBuildIF : cree la fenetre de l'outil
   #  Parametres : N° de la visu
   #------------------------------------------------------------
   proc spytimerBuildIF { visuNo } {
      variable private
      global caption color

      set This $private($visuNo,base)
      #-- frame du titre
      frame $This -borderwidth 2 -relief groove
      pack $This
         #--- Frame du titre
         frame $This.fra1 -borderwidth 2 -relief groove
            #--- Bouton du titre
            Button $This.fra1.but -borderwidth 1 \
               -text "$caption(spytimer,help_titre1)\n$caption(spytimer,title)" \
               -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::spytimer::getPluginType ] ] \
                  [ ::spytimer::getPluginDirectory ] [ ::spytimer::getPluginHelp ]"
            pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 2
         DynamicHelp::add $This.fra1.but -text $caption(spytimer,help_titre)
         pack $This.fra1 -side top -fill x

      #-- frame de la configuration
      frame $This.fra2 -borderwidth 2 -relief groove
         button $This.fra2.but -borderwidth 2 -text $caption(spytimer,configuration) \
            -command "::spytimer::configParameters $visuNo"
         pack $This.fra2.but -side top -fill x -ipadx 2 -ipady 5
      pack $This.fra2 -side top -fill x

      #-- frame de la surveillance
      frame $This.fra3 -borderwidth 2 -relief groove
         checkbutton $This.fra3.opt -text "$caption(spytimer,survey)" \
            -indicatoron 1 -onvalue 1 -offvalue 0 \
            -variable ::spytimer::private($visuNo,survey) \
            -command "::spytimer::initSurvey $visuNo"
         checkbutton $This.fra3.convert -text "$caption(spytimer,convert)" \
            -indicatoron 1 -onvalue 1 -offvalue 0 \
            -variable ::spytimer::private($visuNo,convert)
         pack $This.fra3.opt $This.fra3.convert -anchor w -pady 2
     pack $This.fra3 -side top -fill x

     #--   le frame des commandes  du timer-intervallometre et le bouton GO
     set this [frame $This.fra4 -borderwidth 2 -relief groove]
     set private($visuNo,this) $this
     pack $this -side top -fill x

         label $this.mode_lab -text $caption(spytimer,mode)
         set private($visuNo,modeLabels) [ list "$caption(spytimer,mode,one)" "$caption(spytimer,mode,serie)" ]
         set private($visuNo,mode) [ lindex $private($visuNo,modeLabels) 0 ]
         ComboBox $this.mode -borderwidth 1 -width 5 \
            -height [ llength $private($visuNo,modeLabels) ] \
            -relief sunken -justify center \
            -textvariable ::spytimer::private($visuNo,mode) \
            -values "$private($visuNo,modeLabels)" \
            -modifycmd "::spytimer::configPan $visuNo"

         #--   construit les entrees de donnees
         foreach child { nb_poses activtime delai periode } {
            LabelEntry $this.$child -label $caption(spytimer,$child) \
               -textvariable ::spytimer::private($visuNo,$child) -labelanchor w -labelwidth 8 \
               -borderwidth 1 -relief flat -padx 2 -justify right \
               -width 5 -relief sunken
            bind $this.$child <Leave> [ list ::spytimer::test $visuNo $this $child ]
         }

         #--   label pour afficher les etapes
         label $this.state -textvariable ::spytimer::private($visuNo,action) \
            -width 14 -borderwidth 2 -relief sunken

         #-- checkbutton pour la longuepose
         checkbutton $this.lp -text $caption(spytimer,lp) \
            -indicatoron 1 -offvalue 0 -onvalue 1 \
            -variable ::spytimer::private($visuNo,lp) -command "::spytimer::configTime $visuNo"

         #--   configure le bouton de lancement d'acquisition
         button $this.but1 -borderwidth 2 -text "$caption(spytimer,go)" \
            -command "::spytimer::timer $visuNo"

         checkbutton $this.auto -text "$caption(spytimer,auto)" \
            -indicatoron 1 -offvalue 0 -onvalue 1 \
           -variable ::spytimer::private($visuNo,auto) \
            -command "::spytimer::confTimeListener $::audace(visuNo)"

         frame $this.timer -borderwidth 2
         for {set i 1} {$i < 24} {incr i} {
            lappend lhr [format "%02.f" $i]
         }
         lappend lhr [format "%02.f" 0] $lhr
         tk::spinbox $this.timer.hr \
            -width 2 -relief sunken -borderwidth 1 \
            -state readonly -values $lhr -wrap 1 \
            -textvariable ::spytimer::private($visuNo,hr)

         label $this.timer.lab_hr -text "$caption(spytimer,hr)"

         for {set i 1} {$i < 60} {incr i} {
            lappend lmin [format "%02.f" $i]
         }
         lappend lmin [format "%02.f" 0] $lmin
         tk::spinbox $this.timer.min \
            -width 2 -relief sunken -borderwidth 1 \
            -state readonly -values $lmin -wrap 1 \
            -textvariable ::spytimer::private($visuNo,min)

         label $this.timer.lab_min -text "$caption(spytimer,min)"
         pack $this.timer.hr $this.timer.lab_hr $this.timer.min $this.timer.lab_min -side left

         ::blt::table $this \
            $this.mode_lab 0,0 \
            $this.mode 0,1 \
            $this.state 1,0 -cspan 2 \
            $this.nb_poses 2,0 -cspan 2 \
            $this.lp 3,0 -cspan 2 \
            $this.activtime 4,0 -cspan 2 \
            $this.delai 5,0 -cspan 2 \
            $this.periode 6,0 -cspan 2 \
            $this.but1 7,0 -cspan 2 -ipady 3 -fill x \
            $this.auto 8,0 -cspan 2 \
            $this.timer 9,0 -cspan 2
            blt::table configure $this r* -pady 2
         pack $this -side top -fill x

      #--   ajoute les aides
      foreach child { nb_poses activtime delai periode } {
         DynamicHelp::add $this.$child -text $caption(spytimer,help$child)
      }

      lassign { "1" "1" " " "0" "1" " " "0" "" "0" "0" } private($visuNo,intervalle) \
         private($visuNo,lp) private($visuNo,activtime) private($visuNo,delai) \
         private($visuNo,periode) private($visuNo,action) private($visuNo,serieNo) \
         private($visuNo,msgbox) private($visuNo,hr) private($visuNo,min)

      $this.lp invoke
      configPan $visuNo

      #--- Mise ajour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #---------------------------------------------------------------------------
   #  timer : gere les prises de vue a partir des reglages de l'utilisateur
   #  Parametres : N° de la visu
   #---------------------------------------------------------------------------
   proc timer { visuNo } {
      variable private
      global caption

      foreach var [ list nb_poses periode activtime delai ] {
         ::spytimer::test $visuNo $private($visuNo,this) $var
      }

      #--   gele les commandes
      setWindowState $visuNo disabled

      #--   affiche 'Attente'
      set private($visuNo,action) $caption(spytimer,action,wait)

      #--   memorise les valeurs initiales
      set private($visuNo,settings) [ list $private($visuNo,nb_poses) \
         $private($visuNo,periode) $private($visuNo,activtime) ]

      #--   raccourcis
      lassign $private($visuNo,settings) nb_poses periode activtime

      #--   cherche l'index de Une Image/Une série
      set mode [ lsearch $private($visuNo,modeLabels) $private($visuNo,mode) ]

      #---  si la pose est differee, affichage du temps restant
      if { $private($visuNo,delai) != 0 } {
         delay delai
      }

      #--   compteur de shoot
      incr private($visuNo,serieNo) "1"

      #--   cree une liaison avec le port
      set linkNo [ ::confLink::create "$private($visuNo,port)" "camera inconnue" "pose" "" ]

      #--   compte les declenchements
      set count 1

      while { $private($visuNo,nb_poses) > 0 } {

         #--   prepare le message de log
         set private($visuNo,msg) [ format $caption(spytimer,prisedevue) $private($visuNo,serieNo) $count ]
         if { $activtime != " " } {
            append private($visuNo,msg) "  $activtime sec."
         }

         #--   affiche 'Acquisition'
         set private($visuNo,action) "$caption(spytimer,action,acq)"

         #--   declenche ; t = temps au debut du shoot en secondes,millisecondes
         set time_start [ shoot $visuNo $linkNo "$activtime" ]

         #--   decremente et affiche le nombre de poses qui reste a prendre
         incr private($visuNo,nb_poses) "-1"

         #--   recharge la duree
         set private($visuNo,activtime) $activtime

         #--   si c'est Une serie
         if { $mode == "1" } {
            if { $count == "1" } {
               set time_first $time_start
            }
            #--   si ce n'etait pas la derniere image
            if { $count < $nb_poses } {
               set private($visuNo,periode) [ expr { $time_first + $periode*$count - [ clock seconds ] } ]
               delay periode
            }
         }

         #--   incremente le nombre de shoot
         incr count
      }

      #--- ferme la liaison
      ::confLink::delete "$private($visuNo,port)" "camera inconnue" "pose"

      #--   degele les commandes
      setWindowState $visuNo normal

      #--   retablit les valeurs initiales
      lassign $private($visuNo,settings) private($visuNo,nb_poses) \
         private($visuNo,periode) private($visuNo,activtime)

      set private($visuNo,action) " "
   }

   #---------------------------------------------------------------------------
   #  shoot : declenche un shoot
   #  Parametres : N° de la visu ,N° du lien et duree
   #---------------------------------------------------------------------------
   proc shoot { visuNo linkNo t } {
      variable private

      #--   definit les variables locales
      set start $private($visuNo,cde)
      set stop  [ expr { 1-$start } ]

      majLog $visuNo

      #--   intercepte l'erreur sur le test
      #  et sur l'absence de liaison serie
      if { [ catch {
         #--- demarre une pose
         link$linkNo bit $private($visuNo,bit) $start
      } ErrInfo ] } {
         return
      }
      set time_start [ clock seconds ]

      if { $t != " " } {
         #--   decremente le compteur de largeur d'impulsion
         delay activtime
      } else {
         #--   la duree minimale de l'impulsion est fixee a 500 msec
         after 500
      }

      #--- arrete la pose
      link$linkNo bit $private($visuNo,bit) $stop

      return $time_start
   }

   #---------------------------------------------------------------------------
   #  setWindowState : gere l'etat des widgets
   #  Parametres : N° de la visu et etat {normal|disabled}
   #---------------------------------------------------------------------------
   proc setWindowState { visuNo state } {
      variable private

      if { $state == "disabled" } {
         foreach child [ list mode lp nb_poses activtime delai periode but1 ] {
            $private($visuNo,this).$child configure -state "$state"
         }
      } else {
         foreach child [ list mode lp delai but1 ] {
            $private($visuNo,this).$child configure -state "$state"
         }
         configPan $visuNo
         #configTime $visuNo
      }
   }

   #---------------------------------------------------------------------------
   #  configPan : configure le panneau en fonction du mode
   #  appele par le bouton de mode et par setWindowState
   #  Parametres : N° de la visu
   #---------------------------------------------------------------------------
   proc configPan { visuNo } {
      variable private

      set indice [ lsearch $private($visuNo,modeLabels) $private($visuNo,mode) ]
      switch $indice {
         "0"   {  lassign { "1" " " } private($visuNo,nb_poses) private($visuNo,periode)
                  foreach child { nb_poses periode } {
                     $private($visuNo,this).$child configure -state disabled
                  }
               }
         "1"   {  lassign [ list "2" "1" " " ] private($visuNo,nb_poses) \
                     private($visuNo,periode) private($visuNo,action)
                  foreach child { nb_poses periode } {
                     $private($visuNo,this).$child configure -state normal
                  }
               }
      }
      configTime $visuNo
   }

   #---------------------------------------------------------------------------
   #  configTime : configure la saisie du temps appelee par le checkbutton
   #  Parametres : N° de la visu, fenetre et entree
   #---------------------------------------------------------------------------
   proc configTime { visuNo } {
      variable private

      set time $private($visuNo,activtime)
      if { $private($visuNo,lp) == "1" } {
         if { $time == " " } {
            set data [ list "normal" "1" ]
         } else {
            set data [ list "normal" "$time" ]
         }
      } else {
         set data [ list "disabled" " " ]
      }
      lassign $data state private($visuNo,activtime)
      $private($visuNo,this).activtime configure -state $state
   }

   #---------------------------------------------------------------------------
   #  test : teste si les valeurs entrees dans les fenetres actives
   #  sont des entiers ; teste si la periode > duree
   #  Parametres : N° de la visu, fenetre et entree
   #---------------------------------------------------------------------------
   proc test { visuNo w child } {
      variable private

      #--   arrete si l'entree est disabled
      if { [ $w.$child cget -state ] == "disabled" } {
         return
      }

	  #--   teste les valeurs decimales
      if {$child in [ list aptdia crota2 pixsize1 pixsize2 foclen xpixsz ypixsz ] } {
         set value $private($visuNo,$child)
         if { [ string is double -strict $value ] != 1 || $value < 0 } {
            avertiUser $visuNo reel
         } else {
            set private($visuNo,$child) [format %.3f $value]
            if { $child eq "aptdia" } {
               #--   calcule le pouvoir separateur
               set pouvoir_separateur [ format "%.3f" [ expr { 0.120/$private($visuNo,$child) } ] ]
               set private($visuNo,pouvoir_separateur) $pouvoir_separateur
            }
            update
         }
         return
      }

      #--   teste les valeurs entieres
      if { ![ TestEntier $private($visuNo,$child) ] } {
         avertiUser $visuNo $child
         if { $child in [ list nb_poses activtime periode interval ] } {
            set private($visuNo,$child) "1"
         } elseif { $child == "delai" } {
            set private($visuNo,$child) "0"
         }
      }

      #--   compare la periode a la duree
      if { $child == "periode" && [ $w.activtime cget -state ] eq "normal" } {
         if { $private($visuNo,periode) <= $private($visuNo,activtime) } {
            avertiUser $visuNo "periode"
            set private($visuNo,periode) [ expr { $private($visuNo,activtime)+1 } ]
         }
      }
      update
   }

   #---------------------------------------------------------------------------
   #  avertiUser : fenetre d'avertissement
   #  Parametres :N° de la visu et variable de caption
   #---------------------------------------------------------------------------
   proc avertiUser { visuNo nom } {
      variable private
      global caption

      #--   pour eviter les ouvertures multiples
      if { $private($visuNo,msgbox) != "$nom" } {

         #--   memorise l'affichage de l'erreur
         set private($visuNo,msgbox) $nom

         tk_messageBox -title $caption(spytimer,attention)\
           -icon error -type ok -message $caption(spytimer,help$nom)

         #--   au retour annule la memoire
         set private($visuNo,msgbox) ""
      }
   }

   #---------------------------------------------------------------------------
   #  delay :  decompteur de secondes
   #  Parametres : nom de la variable a decompter (delai ou periode)
   #---------------------------------------------------------------------------
   proc delay { var } {

      upvar ::spytimer::$var t
      while { $t > "0" } {
         after 1000
         incr t "-1"
         update
      }
      set t "0"
      update
   }

   #---------------------------------------------------------------------------
   #  majLog :  maj du fichier log
   #  Parametres : N° de la visu
   #---------------------------------------------------------------------------
   proc majLog { visuNo } {
      variable private

      set file_log [ file join $::audace(rep_log) spytimer.log ]
      set msg "$::audace(tu,format,dmyhmsint) $private($visuNo,msg)"

      if { ![ catch { open $file_log a } fichier ] } {
         chan puts $fichier $msg
         chan close $fichier
      }
      ::console::affiche_resultat "$msg\n"
   }

   #------------------------------- fenetre de configuration ------------------

   #---------------------------------------------------------------------------
   #  configParameters : cree la fenetre de configuration
   #  Parametres : N° de la visu
   #---------------------------------------------------------------------------
   proc configParameters { visuNo } {
      variable private
      global audace caption color

      set this $private($visuNo,base).config
      if { [ winfo exists $this ] } {
         wm withdraw $this
         wm deiconify $this
         focus $this
         return
      }

      #--- Cree la fenetre $This de niveau le plus haut
      toplevel $this
      wm title $this "$caption(spytimer,titre)"
      wm geometry $this "+150+80"
      wm resizable $this 0 0
      wm protocol $this WM_DELETE_WINDOW ""

      set bordure "10"
      set result_width "12"

      frame $this.kwd -borderwidth 2 -relief groove
         set l 0
         label $this.kwd.label_kwd -text $caption(spytimer,en-tete_fits)
         grid $this.kwd.label_kwd -row $l -column 0 -padx 10 -sticky w
         button $this.kwd.but -borderwidth 2 -text $caption(spytimer,keywords) -width 15 \
            -command "::keyword::run $visuNo ::conf(spytimer,visu$visuNo,keywordConfigName)"
         grid $this.kwd.but -row $l -column 1
         entry $this.kwd.name_kwd -width $result_width -state readonly -takefocus 0 \
            -textvariable ::conf(spytimer,visu$visuNo,keywordConfigName)
         grid $this.kwd.name_kwd -row $l -column 2 -padx $bordure -sticky e

         #--   cree la ligne pour XPIXSZ, YPIXSZ, PIXSIZE1, PIXSIZE2, CROTA2, FOCLEN et APTDIA
         incr l
         foreach var { xpixsz ypixsz pixsize1 pixsize2 crota2 foclen aptdia } {
            checkbutton  $this.kwd.opt_$var -text "$caption(spytimer,$var)" \
               -indicatoron 1 -onvalue 1 -offvalue 0 \
               -variable ::spytimer::private($visuNo,opt_$var) \
               -command "::spytimer::configEntry $visuNo $this.kwd $var"
            grid $this.kwd.opt_$var -row $l -column 0 -padx 10 -sticky w
            label $this.kwd.label_$var -borderwidth 1 -relief sunken \
				   -justify center -text [ string toupper $var ]
            grid $this.kwd.label_$var -row $l -column 1 -sticky ew
            entry $this.kwd.$var -width 7 -borderwidth 1 -relief sunken \
               -justify right -textvariable ::spytimer::private($visuNo,$var) \
               -state disabled
            grid $this.kwd.$var -row $l -column 2 -padx $bordure -sticky e
            incr l
         }
         foreach var { pouvoir_separateur champ echantillonnage } {
            label $this.kwd.label_$var -text $caption(spytimer,$var)
            grid $this.kwd.label_$var -row $l -column 0 -columnspan 2 -padx 10 -sticky w
            entry $this.kwd.$var -textvariable ::spytimer::private($visuNo,$var) \
               -width $result_width -state readonly -takefocus 0 -justify center
            grid $this.kwd.$var -row $l -column 2 -padx $bordure -sticky e
            incr l
         }
      pack $this.kwd -anchor w -side top -fill x -expand 1

      #--   construction des combobox pour la com
      frame $this.com -borderwidth 2 -relief groove
         set l 0
         foreach child { port bit cde } {
            set len [ llength $private($visuNo,${child}Labels) ]
            label $this.com.${child}_lab -text $caption(spytimer,$child)
            grid $this.com.${child}_lab -row $l -column 0 -padx 10 -sticky w
            ComboBox $this.com.$child -borderwidth 1 -width 5 -height $len \
               -relief sunken -justify center \
               -textvariable ::spytimer::private($visuNo,$child) \
               -values "$private($visuNo,${child}Labels)"
            grid $this.com.$child -row $l -column 1 -sticky e
            incr l
         }
         grid columnconfigure $this.com {0} -minsize 100
         $this.com.port configure -modifycmd "::spytimer::configBit $visuNo" -width 9
         DynamicHelp::add $this.com.cde -text $caption(spytimer,helpcde)
      pack $this.com -anchor w -side top -fill x -expand 1

      frame $this.survey -borderwidth 2 -relief groove
         LabelEntry $this.survey.intervalle -labelanchor w \
            -label $caption(spytimer,intervalle) \
            -labelwidth [string length  $caption(spytimer,intervalle)] \
            -textvariable ::spytimer::private($visuNo,intervalle) \
            -borderwidth 1 -relief flat -justify right -width 5 -relief sunken
         pack $this.survey.intervalle -anchor w -padx 10
         bind $this.survey.intervalle <Leave> [ list ::spytimer::test $visuNo $this.survey intervalle ]
      pack $this.survey -anchor w -side top -fill x -expand 1

      frame $this.cmd -borderwidth 2 -relief groove
         set len [string length $caption(spytimer,focalisation)]
         button $this.cmd.foc -borderwidth 2 -text $caption(spytimer,focalisation) \
        	   -command "::spytimer::focGraphe $visuNo" -width $len
         pack $this.cmd.foc -anchor w -side left -padx 10
      pack $this.cmd -anchor w -side top -fill x -expand 1
   }

   #------------------------------------------------------------
   #  configEntry : inhibe/desinhibe les entree des mots cles
   #  Parametres : N° de la visu, nom du parent et de la variable
   #------------------------------------------------------------
   proc configEntry { visuNo w v } {
      variable private

      if { $private($visuNo,opt_$v) == "0" } {
         set $private($visuNo,$v) ""
         $w.$v configure -state disabled
         bind $w.$v <Leave> ""
      } else {
         $w.$v configure -state normal
         bind $w.$v <Leave> [ list ::spytimer::test $visuNo $w $v ]
      }
   }

   #---------------------------------------------------------------------------
   #  configBit : configure l'entree de .bit en fonction du port
   #  Parametres : N° de la visu
   #---------------------------------------------------------------------------
   proc configBit { visuNo } {
      variable private

      set w $private($visuNo,base).config.bit
      set len [ llength $private($visuNo,bitLabels) ]
      $w configure -values "$private($visuNo,bitLabels)" -height $len
      $w setvalue @0
   }

   #---------------------------------------------------------------------------
   #  addKeywords : ajoute les mots cles
   #  Parametres : N° de la visu
   #---------------------------------------------------------------------------
   proc addKeywords { visuNo bufNo } {
      variable private

      #--   raccourcis
      set aptdia $private($visuNo,aptdia)
      set crota2 $private($visuNo,crota2)
      set foclen $private($visuNo,foclen)
      set xpixsz $private($visuNo,xpixsz)
      set ypixsz $private($visuNo,ypixsz)
      set pixsize1 $private($visuNo,pixsize1)
      set pixsize2 $private($visuNo,pixsize2)

      #--   calcule CRPIX1 et CRPIX2 par defaut
      set naxis1 [ lindex [ buf$bufNo getkwd NAXIS1 ] 1 ]
      set naxis2 [ lindex [ buf$bufNo getkwd NAXIS2 ] 1 ]
      #--   valeur pas defaut
      set crpix1 [ expr { $naxis1/2.0 } ]
      set crpix2 [ expr { $naxis2/2.0 } ]

      foreach keyword [ ::keyword::getKeywords $visuNo $::conf(spytimer,visu$visuNo,keywordConfigName) ] {
         set key [lindex $keyword 0]
         if { $key in [ list APTDIA CROTA2 CRPIX1 CRPIX2 FOCLEN PIXSIZE1 PIXSIZE2 XPIXSZ YPIXSZ ] && [ lindex $keyword 1 ] eq ""} {
            set value [ set [ string tolower $key ] ]
            #--   si une valeur a ete donnee
            if { $value ne "" } {
               #--   remplace la valeur vide par la valeur reelle
               set keyword [ lreplace $keyword 1 1 $value ]
            }
         }
         buf$bufNo setkwd $keyword
      }

      #--   calcule le champ et l'echantillonnage
      if { $xpixsz ne "" && $ypixsz ne "" && $foclen ne "" } {
         lassign [ ::spytimer::calculette $naxis1 $naxis2 $xpixsz $ypixsz $foclen ] \
            private($visuNo,champ) private($visuNo,echantillonnage)
         update
      }
   }

   #---------------------------------------------------------------------------
   #  calculette : calcule le champ et l'echantillonage du capteur
   #  Parametres : naxis1 naxis2 xpixsz ypixsz foclen
   #---------------------------------------------------------------------------
   proc calculette { naxis1 naxis2 xpixsz ypixsz foclen } {

       #--  calcule les dimensions du capteur en mm
       set dim_x [ expr { $naxis1 * $xpixsz / 1000 } ]
       set dim_y [ expr { $naxis2 * $ypixsz / 1000 } ]

       #--- Champ en x et en y en minutes d'arc
       set champ_x  [ format "%.1f" [ expr { 206265 * $dim_x / ( $foclen * 1000.*60. ) } ] ]
       set champ_y  [ format "%.1f" [ expr { 206265 * $dim_y / ( $foclen * 1000.*60. ) } ] ]
       set champ "$champ_x X $champ_y"

       #--- Echantillonnage du CMOS en x et en y en secondes d'arc par pixels
       set echantillonnage_x [ format "%.1f"  [expr {$champ_x*60./$naxis1}]]
       set echantillonnage_y [ format "%.1f"  [expr {$champ_y*60./$naxis2}]]
       set echantillonnage "$echantillonnage_x X $echantillonnage_y"

       return [ list $champ $echantillonnage ]
   }

   #----------------- fonction de surveillance du répertoire ------------------

   #---------------------------------------------------------------------------
   # initSurvey : initialise la surveillance
   #  Parametres : N° de la visu
   #---------------------------------------------------------------------------
   proc initSurvey { visuNo } {
      variable private

      if { $private($visuNo,survey) == 1 } {
         #--   fait et memorise la liste initiale des fichiers presents
         set private($visuNo,oldList) [ ::spytimer::listeFiles visuNo ]
         #--  lance la surveillance
         ::spytimer::surveyDirectory $visuNo
      } else {
         catch { after cancel $private(afterId) }
      }
   }

   #---------------------------------------------------------------------------
   #  surveyDirectory : detecte et charge une nouvelle image
   #  Parametres : N° de la visu
   #---------------------------------------------------------------------------
   proc surveyDirectory { visuNo } {
      variable private
      global audace conf

      #--   arrete si la fenetre a ete fermee
      if { [ catch { set bufNo [ ::confVisu::getBufNo $visuNo ] } ErrInfo ] } {
         return
      }

      #--   fait la liste des fichiers presents
      ::spytimer::listeFiles $visuNo

      #--   oublie la liste des anciennes images
      regsub -all $private($visuNo,oldList) $private($visuNo,listFiles) "" newFile

      #--  en cas de plusieurs fichiers, retient le dernier
      set newFile [ lindex $newFile end ]

      if { $newFile ne "" } {

         set ext [ file extension $newFile ]
         set name [ file rootname $newFile ]
         set fileName [ file join $::audace(rep_images) $name$ext ]
         set time [ file atime $fileName ]
         set minuscules [ string tolower $conf(extension,defaut) ]
         set majuscules [ string toupper $conf(extension,defaut) ]

         #-- change la casse de l'extension FITS s'il y a discordance
         if {$ext in [list $minuscules $majuscules]} {
            if {[string match $conf(extension,defaut) $ext] == 0} {
               set fileName $name$conf(extension,defaut)
               file rename -force $name$ext $fileName
               set ext $conf(extension,defaut)
            }
         }

         #--   charge l'image
         loadima $fileName $visuNo

         #--- cree DATE-OBS pour les images jpeg et les FITS sans date
         if { [ lindex [ buf$bufNo getkwd "DATE-OBS" ] 1 ] eq ""}  {
            set time [ clock format $time -format "%Y-%m-%dT%H:%M:%Ss" -timezone :UTC ]
            buf$bufNo setkwd [ list DATE-OBS $time string "Start of exposure. FITS standard]" "iso8601" ]
         }

         if { $private($visuNo,convert) == 1 } {
            #--- ajoute des mots cles
            ::spytimer::addKeywords $visuNo $bufNo
            #--   sauve l'image avec l'extension par defaut
            set fileName [ file join $::audace(rep_images) $name$::conf(extension,defaut) ]
            buf$bufNo save $fileName
            loadima $fileName $visuNo
            #file delete [file join $::audace(rep_images) $newFile]
         }

         #--   rafraichit le graphique de derive
         if { [ winfo exists $private($visuNo,base).qmes ] && [ file extension $fileName ] eq "$conf(extension,defaut)" } {
            set precedent [lindex $private($visuNo,listFiles) end-1]
            set img1 [ file rootname $precedent ]
            if { $img1 ne "" } {
               ::spytimer::verifData $visuNo [ list $img1 [ file rootname [ file tail $fileName ] ] ]
            }
         }

         #--   rafraichit le graphique de focalisation
         if { [ winfo exists $private($visuNo,base).parafoc ] } {
            ::spytimer::refreshFocGraph $visuNo $bufNo
         }
      }

      #--   memorise la nouvelle liste
      set private($visuNo,oldList) $private($visuNo,formatList)

      set intervalle [ expr { $private($visuNo,intervalle) * 1000 } ]
      set private(afterId) [ after $intervalle ::spytimer::surveyDirectory $visuNo ]
   }

   #---------------------------------------------------------------------------
   #  listeFiles : liste les nom courts des fichiers images
   #  Parametres : N° de la visu
   #---------------------------------------------------------------------------
   proc listeFiles { visuNo } {
      variable private
      global audace

     set dir $audace(rep_images)

      set raw ""
      if { $::tcl_platform(platform) == "windows" } {
        #--- la recherche de l'extension est insensible aux minuscules/majuscules ... sous windows uniquement
         foreach extension [list CR2 CRW JPG FIT FITS] {
            set raw [ concat $raw [ glob -nocomplain -type f -join $dir *.$extension ] ]
         }
      } else {
         #--- la recherche de l'extension est _sensible_ aux minuscules/majuscules dans tous les autres cas
         foreach extension [list CR2 CRW JPG cr2 crw jpg FIT fit FITS fits] {
            set raw [ concat $raw [ glob -nocomplain -type f -join $dir *.$extension ] ]
         }
      }

      lassign [ list "" "" ] private($visuNo,listFiles) private($visuNo,formatList)

      if { $raw ne "" } {
         set formatList "("
         foreach file [ lsort -dictionary  $raw ] {
            set short_name [ file tail $file ]
            lappend private($visuNo,listFiles) $short_name
            append formatList $short_name |
         }
         set private($visuNo,formatList) [ string trimright $formatList "|" ]
         append private($visuNo,formatList) ")"
      }

      return $private($visuNo,formatList)
   }

   #-----------------------fonction de lancement auto -------------------------

   #---------------------------------------------------------------------------
   # confTimeListener : met en place/arrete le listener de minuteur
   # commande du bouton de programmation de shoot 'Auto'
   # Parametres : N° de la visu
   #---------------------------------------------------------------------------
   proc confTimeListener { visuNo } {
      variable private

      if { $private($visuNo,auto) == "1" } {
         ::confVisu::addTimeListener $visuNo "::spytimer::autoShoot $visuNo"
      } else {
         ::confVisu::removeTimeListener $visuNo "::spytimer::autoShoot $visuNo"
      }
   }

   #---------------------------------------------------------------------------
   # autoShoot : lance le programme
   # Parametres : N° de la visu
   #---------------------------------------------------------------------------
   proc autoShoot { visuNo args } {
      variable private

      set progr "$private($visuNo,hr) $private($visuNo,min)"

      if { $::audace(hl,format,hm) != "" && $::audace(hl,format,hm) eq "$progr" } {
         ::spytimer::timer $visuNo
      }
   }

#--   fin du namespace ::spytimer
}

