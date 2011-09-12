#
# Fichier : spytimer.tcl
# Description : Outil pour APN Canon non reconnu par libgphoto2_canon.dll
# Auteur : Raymond Zachantke
# Mise à jour $Id: spytimer.tcl 7554 2011-08-31 15:17:22Z rzachantke $
#

#============================================================
# Declaration du namespace spytimer
#    initialise le namespace
#============================================================
namespace eval ::spytimer {
   package provide spytimer 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]]  spytimer.cap ]

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
         foreach var [ list port bit cde ] \
            val [ list $private(port) $private(bit) $private(cde) ] {
            puts $fichier "set parametres($var) \"$val\""
         }
         close $fichier
      }

      #--   desactive le timeListener
      if {[trace info variable ::audace(hl,format,hm)]  ne ""} {
         trace remove variable ":::audace(hl,format,hm)" write "::spytimer::autoShoot $visuNo"
      }
   }

   #------------------------------------------------------------
   # createPanel
   #    prepare la creation de la fenetre de l'outil
   #------------------------------------------------------------
   proc createPanel { this visuNo } {
      variable private
      global audace

      set private(fichier_ini) [ file join $audace(rep_home) spytimer.ini ]
      if [ file exists $private(fichier_ini) ] {
         source $private(fichier_ini)
         foreach var { port bit cde } {
            if [ info exists parametres($var) ]  {
               #--   affecte les valeurs initiales sauvegardees dans le fichier ini
               set private($var) $parametres($var)
            }
         }
      }

      #---
      set private($visuNo,base) "$this"

      triggerBuildIF $visuNo
   }

   #------------------------------------------------------------
   # startTool
   #    affiche la fenetre de l'outil
   #------------------------------------------------------------
   proc startTool { visuNo } {
      variable private

      #--- On cree la variable de configuration des mots cles
      if { ! [ info exists ::conf(spytimer,keywordConfigName) ] } { set ::conf(spytimer,keywordConfigName) "default" }

      #--- Je selectionne les mots cles selon les exigences de l'outil
      ::spytimer::configToolKeywords $visuNo

      pack $private($visuNo,base) -side left -fill y
   }

   #------------------------------------------------------------
   # stopTool
   #    masque la fenetre de l'outil
   #------------------------------------------------------------
   proc stopTool { visuNo } {
      variable private

      pack forget $private($visuNo,base)
   }

   #------------------------------------------------------------
   # triggerBuildIF
   #    cree la fenetre de l'outil
   #------------------------------------------------------------
   proc triggerBuildIF { visuNo } {
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

      #-- frame de la configuration et de la surveillance
      frame $This.fra2 -borderwidth 2 -relief groove
         button $This.fra2.but -borderwidth 2 -text $caption(spytimer,configuration) \
             -command "::keyword::run $::audace(visuNo) ::conf(spytimer,keywordConfigName)"
         pack $This.fra2.but -side top -fill x -ipadx 2 -ipady 5

         checkbutton $This.fra2.opt -text "$caption(spytimer,survey)" \
            -indicatoron 1 -onvalue 1 -offvalue 0 \
            -variable ::spytimer::private(survey) \
            -command "::spytimer::initSurvey $visuNo"

         LabelEntry $This.fra2.interval -label $caption(spytimer,survey_interv) \
               -textvariable ::spytimer::private(intervalle) -labelanchor w -labelwidth 15 \
               -borderwidth 1 -relief flat -padx 2 -justify right \
               -width 5 -relief sunken
         bind $This.fra2.interval <Leave> [ list ::spytimer::test $This.fra2 interval ]

         checkbutton $This.fra2.convert -text "$caption(spytimer,convert)" \
            -indicatoron 1 -onvalue 1 -offvalue 0 \
            -variable ::spytimer::private(convert)

         pack $This.fra2.opt $This.fra2.interval $This.fra2.convert \
            -anchor w -pady 2
     pack $This.fra2 -side top -fill x

     #--   le frame cantonnant les commandes  du timer-intervallometre et le bouton GO
     set this [frame $This.fra3 -borderwidth 2 -relief groove]
     set private($visuNo,this) $this
     pack $this -side top -fill x

         #--   initialise les listes pour les combobox
         set private(portLabels) [ ::confLink::getLinkLabels { "parallelport" "quickremote" "serialport" "external" } ]
         if ![ info exists private(port) ] {
            set private(port) [ lindex $private(portLabels) 0 ]
         }
         set private(bitLabels) [ ::confLink::getPluginProperty $private(port) bitList ]
         if ![ info exists private(bit) ] {
            set private(bit) [ lindex $private(bitLabels) 0 ]
         }
         set private(cdeLabels) { 0 1 }
         if ![ info exists private(cde) ] {
            set private(cde) [ lindex $private(cdeLabels) 1 ]
         }
         set private(modeLabels) [ list "$caption(spytimer,mode,one)" "$caption(spytimer,mode,serie)" ]
         set private(mode) [ lindex $private(modeLabels) 0 ]

         ::blt::table $this

         #--   construction des combobox
         foreach child { port bit cde mode } {
            set len [ llength $private(${child}Labels) ]
            label $this.${child}_lab -text $caption(spytimer,$child)
            ComboBox $this.$child -borderwidth 1 -width 5 -height $len \
               -relief sunken -justify center \
               -textvariable ::spytimer::private($child) \
               -values "$private(${child}Labels)"
         }
         $this.port configure -modifycmd "::spytimer::configBit $visuNo" -width 9
         $this.mode configure -modifycmd "::spytimer::configPan $visuNo"

         #--   construit les entrees de donnees
         foreach child { nb_poses activtime delai periode } {
            LabelEntry $this.$child -label $caption(spytimer,$child) \
               -textvariable ::spytimer::$child -labelanchor w -labelwidth 8 \
               -borderwidth 1 -relief flat -padx 2 -justify right \
               -width 5 -relief sunken
            bind $this.$child <Leave> [ list ::spytimer::test $this $child ]
         }

         #--   label pour afficher les etapes
         label $this.state -textvariable private(action) \
            -width 14 -borderwidth 2 -relief sunken

         #-- checkbutton pour la longuepose
         checkbutton $this.lp -text $caption(spytimer,lp) \
            -indicatoron 1 -offvalue 0 -onvalue 1 \
            -variable ::spytimer::lp -command "::spytimer::configTime $visuNo"

         #--   configure le bouton de lancement d'acquisition
         button $this.but1 -borderwidth 2 -text "$caption(spytimer,go)" \
            -command "::spytimer::timer $visuNo"

         frame $this.timer -borderwidth 2

         checkbutton $this.timer.auto -text "$caption(spytimer,auto)" \
            -indicatoron 1 -offvalue 0 -onvalue 1 \
            -variable ::spytimer::private(auto) \
            -command "::spytimer::confTimeListener $::audace(visuNo)"

         for {set i 1} {$i < 24} {incr i} {
            lappend lhr [format "%02.f" $i]
         }
         lappend lhr "00" $lhr
         tk::spinbox $this.timer.hr \
            -width 2 -relief sunken -borderwidth 1 \
            -state readonly -values $lhr -wrap 1 \
            -textvariable ::spytimer::private(hr)

         label $this.timer.lab_hr -text "$caption(spytimer,hr)"

         for {set i 1} {$i < 60} {incr i} {
            lappend lmin [format "%02.f" $i]
         }
         lappend lmin "00" $lmin
         tk::spinbox $this.timer.min \
            -width 2 -relief sunken -borderwidth 1 \
            -state readonly -values $lmin -wrap 1 \
            -textvariable ::spytimer::private(min)

         label $this.timer.lab_min -text "$caption(spytimer,min)"
         pack $this.timer.auto $this.timer.hr $this.timer.lab_hr $this.timer.min $this.timer.lab_min -side left

         ::blt::table $this \
            $this.port_lab 0,0 \
            $this.port 0,1 \
            $this.bit_lab 1,0 \
            $this.bit 1,1 \
            $this.cde_lab 2,0 \
            $this.cde 2,1 \
            $this.mode_lab 3,0 \
            $this.mode 3,1 \
            $this.state 4,0 -cspan 2 \
            $this.nb_poses 5,0 -cspan 2 \
            $this.lp 6,0 -cspan 2 \
            $this.activtime 7,0 -cspan 2 \
            $this.delai 8,0 -cspan 2 \
            $this.periode 9,0 -cspan 2 \
            $this.but1 10,0 -cspan 2 -ipady 3 -fill x \
            $this.timer 11,0 -cspan 2
            ::blt::table configure $this r* -pady 2

      #--   ajoute les aides
      foreach child { cde nb_poses activtime delai periode } {
         DynamicHelp::add $this.$child -text $caption(spytimer,help$child)
      }

      lassign { "1" "1" " " "0" "1" " " "0" "" "0" "0"} private(intervalle) \
         ::spytimer::lp ::spytimer::activtime ::spytimer::delai \
         ::spytimer::periode private(action) private(serieNo) \
         private(msgbox) private(hr) private(min)

      $this.lp invoke
      configPan $visuNo

      #--- Mise ajour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #---------------------------------------------------------------------------
   #  timer : gere les prises de vue a partir des reglages de l'utilisateur
   #---------------------------------------------------------------------------
   proc timer { visuNo } {
      variable private
      global caption

      foreach var [ list nb_poses periode activtime delai ] {
         ::spytimer::test $private($visuNo,this) $var
      }

      #--   gele les commandes
      setWindowState $visuNo disabled

      #--   affiche 'Attente'
      set private(action) $caption(spytimer,action,wait)

      #--   memorise les valeurs initiales
      set private(settings) [ list $::spytimer::nb_poses \
         $::spytimer::periode $::spytimer::activtime ]

      #--   raccourcis
      lassign $private(settings) nb_poses periode activtime

      #--   cherche l'index de Une Image/Une série
      set mode [ lsearch $private(modeLabels) $private(mode) ]

      #---  si la pose est differee, affichage du temps restant
      if { $::spytimer::delai != 0 } {
         delay delai
      }

      #--   compteur de shoot
      incr private(serieNo) "1"

      #--   cree une liaison avec le port
      set linkNo [ ::confLink::create "$private(port)" "camera inconnue" "pose" "" ]

      #--   compte les declenchements
      set count 1

      while { $::spytimer::nb_poses > 0 } {

         #--   prepare le message de log
         set private(msg) [ format $caption(spytimer,prisedevue) $private(serieNo) $count ]
         if { $activtime != " " } {
            append private(msg) "  $activtime sec."
         }

         #--   affiche 'Acquisition'
         set private(action) "$caption(spytimer,action,acq)"

         #--   declenche ; t = temps au debut du shoot en secondes,millisecondes
         set time_start [ shoot $linkNo "$activtime" ]

         #--   decremente et affiche le nombre de poses qui reste a prendre
         incr ::spytimer::nb_poses "-1"

         #--   recharge la duree
         set ::spytimer::activtime $activtime

         #--   si c'est Une serie
         if { $mode == "1" } {
            if { $count == "1" } {
               set time_first $time_start
            }
            #--   si ce n'etait pas la derniere image
            if { $count < $nb_poses } {
               set ::spytimer::periode [ expr { $time_first + $periode*$count - [ clock seconds ] } ]
               delay periode
            }
         }

         #--   incremente le nombre de shoot
         incr count
      }

      #--- ferme la liaison
      ::confLink::delete "$private(port)" "camera inconnue" "pose"

      #--   degele les commandes
      setWindowState $visuNo normal

      #--   retablit les valeurs initiales
      lassign $private(settings) ::spytimer::nb_poses \
         ::spytimer::periode ::spytimer::activtime

      set private(action) " "
   }

   #---------------------------------------------------------------------------
   #  shoot : declenche un shoot
   #  Parametre : N° du lien et duree
   #---------------------------------------------------------------------------
   proc shoot { linkNo t } {
      variable private

      #--   definit les variables locales
      set start $private(cde)
      set stop  [ expr { 1-$start } ]

      majLog

      #--   intercepte l'erreur sur le test
      #  et sur l'absence de laison serie
      if {[catch {
         #--- demarre une pose
         link$linkNo bit $private(bit) $start
      } ErrInfo]} {
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
      link$linkNo bit $private(bit) $stop

      return $time_start
   }

  #---------------------------------------------------------------------------
  #   setWindowState : gere l'etat des widgets
  #   Parametre : etat
  #---------------------------------------------------------------------------
  proc setWindowState { visuNo state } {
      variable private

      if { $state == "disabled" } {
         foreach child [ list port bit cde mode lp nb_poses activtime delai periode but1 ] {
            $private($visuNo,this).$child configure -state "$state"
         }
      } else {
         foreach child [ list port bit cde mode lp delai but1 ] {
            $private($visuNo,this).$child configure -state "$state"
         }
         configPan $visuNo
         configTime $visuNo
      }
   }

  #---------------------------------------------------------------------------
  #   configPan : configure le panneau en fonction du mode
  #  appele par le bouton de mode et par setWindowState
  #---------------------------------------------------------------------------
   proc configPan { visuNo } {
      variable private

      set indice [ lsearch $private(modeLabels) $private(mode) ]
      switch $indice {
         "0"   {  lassign { "1" " " } ::spytimer::nb_poses ::spytimer::periode
                  foreach child { nb_poses periode } {
                     $private($visuNo,this).$child configure -state disabled
                  }
               }
         "1"   {  lassign [ list "2" "1" " " ] ::spytimer::nb_poses \
                     ::spytimer::periode private(action)
                  foreach child { nb_poses periode } {
                     $private($visuNo,this).$child configure -state normal
                  }
               }
      }
      set private(intervalle) 1
  }

  #---------------------------------------------------------------------------
  #   Configure l'entree de .bit en fonction du port
  #---------------------------------------------------------------------------
  proc configBit { visuNo } {
      variable private

      set private(bitLabels) [ ::confLink::getPluginProperty \
         $private(port) bitList ]
      set len [ llength $private(bitLabels) ]
      $private($visuNo,this).bit configure -values "$private(bitLabels)" -height $len
      $private($visuNo,this).bit setvalue @0
   }

   #---------------------------------------------------------------------------
   #  configTime : configure la saisie du temps appelee par le checkbutton
   #---------------------------------------------------------------------------
   proc configTime { visuNo } {
      variable private

      set time $::spytimer::activtime
      if { $::spytimer::lp == "1" } {
         if { $time == " " } {
            set data [ list "normal" "1" ]
         } else {
            set data [ list "normal" "$time" ]
         }
      } else {
         set data [ list "disabled" " " ]
      }
      lassign $data state ::spytimer::activtime
      $private($visuNo,this).activtime configure -state $state
   }

   #---------------------------------------------------------------------------
   #  test : teste si les valeurs entrees dans les fenetres actives
   #  sont des entiers ; teste si la periode > duree
   #  Parametres : fenetre et entree
   #---------------------------------------------------------------------------
   proc test { w child } {

      #--   arrete si l'entree est disabled
      if { [ $w.$child cget -state ] == "disabled" } {
         return
      }

      set nom_var [ LabelEntry::cget $w.$child -textvariable ]

      if ![ TestEntier [ set $nom_var ] ] {
         avertiUser $child
         if { $child in [list nb_poses activtime periode interval] } {
            set $nom_var "1"
         } elseif { $child == "delai" } {
            set $nom_var "0"
         }
      }
      if { $child == "periode" &&  ( [ set $nom_var ] <= "$::spytimer::activtime" ) } {
         avertiUser "periode"
         set $nom_var [ expr { $::spytimer::activtime+1 } ]
      }
   }

   #---------------------------------------------------------------------------
   #  avertiUser :  fenetre d'avertissement
   #  parametre : variable de caption
   #---------------------------------------------------------------------------
   proc avertiUser { nom } {
      variable private
      global caption

      #--   pour eviter les ouvertures multiples
      if { $private(msgbox) != "$nom" } {

         #--   memorise l'affichage de l'erreur
         set private(msgbox) $nom

         tk_messageBox -title $caption(acqdslr,attention)\
           -icon error -type ok -message $caption(spytimer,help$nom)

         #--   au retour annule la memoire
         set private(msgbox) ""
     }
   }

   #---------------------------------------------------------------------------
   #  delay :  decompteur de secondes
   #  parametre : nom de la variable a decompter (delai ou periode)
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
   #   majLog :  Maj du fichier log
   #---------------------------------------------------------------------------
   proc majLog {} {
      variable private

      set file_log [ file join $::audace(rep_log) spytimer.log ]
      set msg "$::audace(tu,format,dmyhmsint) $private(msg)"

      if ![ catch { open $file_log a } fichier ] {
         chan puts $fichier $msg
         chan close $fichier
      }
      ::console::affiche_resultat "$msg\n"
   }

   #---------------------------------------------------------------------------
   # confTimeListener : met en place/arrete le listener de minuteur
   # commande du bouton de programmation de shoot 'Auto'
   # Parametres : visuNo
   #---------------------------------------------------------------------------
   proc confTimeListener { visuNo } {
      variable private

      if {$private(auto) == "1"} {
         ::confVisu::addTimeListener $visuNo "::spytimer::autoShoot $visuNo"
      } else {
         ::confVisu::removeTimeListener $visuNo "::spytimer::autoShoot $visuNo"
      }
   }

   #---------------------------------------------------------------------------
   # autoShoot : lance le programme
   # Parametres : numero de la visu
   #---------------------------------------------------------------------------
   proc autoShoot { visuNo args } {
      variable private

      if {$::audace(hl,format,hm) != "" && $::audace(hl,format,hm) eq "$private(hr) $private(min)"} {
         ::spytimer::timer $visuNo
      }
   }

   #---------------------------------------------------------------------------
   # initSurvey : initialise la surveillance
   #---------------------------------------------------------------------------
   proc initSurvey { visuNo } {
      variable private

      if {$private(survey) ==1} {

         #--   fait et memorise la liste initiale des fichiers presents
         ::spytimer::::listeFiles
         set private(oldList) $private(formatList)

         #--  lance la surveillance
         ::spytimer::::surveyDirectory $visuNo
      } else {
         if {[info exists private(afterId)] == 1 && [after info $private(afterId)] ne ""} {
            after cancel $private(afterId)
         }
      }
   }

   #---------------------------------------------------------------------------
   #  surveyDirectory : detecte et charge une nouvelle image
   #---------------------------------------------------------------------------
   proc surveyDirectory { visuNo } {
      variable private
      global audace

      #--   fait la liste des fichiers presents
      ::spytimer::::listeFiles

      #--   supprime les anciennes images
      regsub -all $private(oldList) $private(listFiles) "" newFile
      #--   supprime les espaces
      regsub {(\s)+} $newFile "" newFile

      if {$newFile ne ""} {

         #--   memorise la nouvelle liste
         set private(oldList) $private(formatList)
         set fileName [file join $::audace(rep_images) $newFile]
         set ext [file extension $newFile]

         #--   charge l'image
         loadima $fileName

         if {$private(convert) == 1 && $ext ni [list JPG jpg]} {

            #--- Rajoute des mots cles dans l'en-tete FITS
            set bufNo [::confVisu::getBufNo $visuNo]
            foreach keyword [ ::keyword::getKeywords $visuNo $::conf(spytimer,keywordConfigName) ] {
               buf$bufNo setkwd $keyword
            }

            set newName "[file rootname $fileName]$::conf(extension,defaut)"
            buf$bufNo save $newName
         }
      }

      set intervalle [expr {$private(intervalle)*1000}]
      set private(afterId) [after $intervalle ::spytimer::surveyDirectory $visuNo]
   }

   #---------------------------------------------------------------------------
   #  listeFiles : liste les nom courts des fichiers images
   #---------------------------------------------------------------------------
   proc listeFiles { } {
      variable private
      global audace

      set dir $audace(rep_images)

      set raw ""
      if { $::tcl_platform(platform) == "windows" } {
        #--- la recherche de l'extension est insensible aux minuscules/majuscules ... sous windows uniquement
         foreach extension { CR2 CRW JPG} {
            set raw [ concat $raw [ glob -nocomplain -type f -join $dir *.$extension ] ]
         }
      } else {
         #--- la recherche de l'extension est _sensible_ aux minuscules/majuscules dans tous les autres cas
         foreach extension { CR2 CRW DNG JPG cr2 crw jpg} {
            set raw [ concat $raw [ glob -nocomplain -type f -join $dir *.$extension ] ]
         }
      }

      set private(listFiles) ""
      set formatList "("
      foreach file [lsort -dictionary  $raw] {
         set short_name [file tail $file]
         lappend private(listFiles) $short_name
         append formatList $short_name |
      }
      set private(formatList) [string trimright $formatList "|"]
      append private(formatList) ")"
   }

   #------------------------------------------------------------
   # configToolKeywords
   #    configure les mots cles FITS de l'outil
   #------------------------------------------------------------
   proc configToolKeywords { visuNo { configName "" } } {

      #--- Je traite la variable configName
      if { $configName == "" } {
         set configName $::conf(spytimer,keywordConfigName)
      }

      #--- Je selectionne les mots cles optionnels a ajouter dans les images
      #--- Ce sont les mots cles CRPIX1, CRPIX2
      #::keyword::selectKeywords $visuNo $configName [ list CRPIX1 CRPIX2 ]

      #--- Je selectionne la liste des mots cles non modifiables
      #::keyword::setKeywordState $visuNo $configName [ list CRPIX1 CRPIX2 ]
   }

#--   fin du namespace ::spytimer
}

