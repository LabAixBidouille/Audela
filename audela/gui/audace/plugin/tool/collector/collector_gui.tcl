#
# Fichier : collector_gui.tcl
# Description :
# Auteur : Raymond Zachantke
# Mise à jour $Id$
#

   #--   Liste des proc de configuration de la fenetre de l'outil
   # nom proc                             utilisee par
   # ::collector::initCollector           createPluginInstance
   # ::collector::createMyNoteBook        initCollector
   # ::collector::configLigne             createMyNoteBook
   # ::collector::configCmd
   # ::collector::configButtons
   # ::collector::closeMyNoteBook         Commande du bouton 'Fermer"
   # ::collector::confToWidget            initCollector
   # ::collector::configAddRemoveListener initCollector et closeMyNoteBook
   # ::collector::configTraceSuivi        onChangeMount
   # ::collector::configTraceRaDec        onChangeMount
   # ::collector::configParkInit          onChangeMount et hideTel
   # ::collector::configDirname           Commande du bouton '...'
   # ::collector::hideTel                 onChangeMount

   proc initCollector { {visuNo 1} } {
      variable private
      global audace cameras

      #--   precaution
      array unset cameras

      #--   cree les images d'icones
      foreach icon {baguette chaudron greenLed redLed} {
         if {![winfo exists $audace(base).newCam]} {
            createIcon $icon
         }
      }

      confToWidget

      #--  lance etc_tools
      etc_init

      #--   liste les cameras dans etc_tools
      set private(etcCam) [lsort -dictionary [etc_set_camera]]

      #--   ajoute les cameras utilisateurs
      set l [llength $private(cam)]
      if {$l > 0} {
         for {set i 0} {$i < $l} {incr i} {
            array set cameras [lindex $private(cam) $i]
         }
      }

      set private(actualListOfCam) [lsort -dictionary [array names cameras]]

      #--   liste equivalente a celle de etc_tools : naxis1 naxis2 photocell1 photocell2 C_th G N_ro eta Em
      set private(paramsList) [list naxis1 naxis2 photocell1 photocell2 therm gain noise eta ampli]

      #--   liste les couples de variables 'etc_tools' et 'collector''
      set private(etc_variables) [list {aptdia D} {fond FonD} {foclen Foclen} {filter band} \
         {psf Fwhm_psf_opt} {seeing seeing} {naxis1 naxis1} {naxis2 naxis2} \
         {bin1 bin1} {bin2 bin2} {t t} {m m} {snr snr} \
         {eta eta} {noise N_ro} {therm C_th} {gain G} {ampli Em} \
         {photocell1 photocell1} {photocell2 photocell2}]

      #--   liste les variables exclusivement label (resultat de calculs ou affichage simple)
      #--   non modifiables par l'utilisateur
      set private(labels) [list equinox true raTel decTel azTel elevTel haTel error \
         telescop fov1 fov2 cdelt1 cdelt2 gps jd tsl moonphas moonalt moon_age ncfz \
         temprose hygro winddir windsp fwhm secz airmass aptdia foclen fond resolution \
         telname connexion suivi vra vdec vxPix vyPix observer sitename origin iau_code access cumulus]

      #--   liste les variables 'entry' avec binding, modifiables par l'utilisateur
      set private(entry) [list ra dec bin1 bin2 naxis1 naxis2 crota2 m snr t \
         tu seeing tempair airpress psf photocell1 photocell2 eta gain noise therm ampli isospeed objname]

      #--   liste les variables necessaires pour synthetiser une image
      set private(syn_variables) [list snr m t aptdia foclen fond psf filter \
         bin1 bin2 naxis1 naxis2 photocell1 photocell2 eta gain noise therm ampli]

      #--   liste les variables necessaires pour synthetiser une image, sans image dans la visu
      set private(special_variables) [list ra dec gps t tu jd tsl telescop aptdia foclen fwhm \
         bin1 bin2 naxis1 naxis2 cdelt1 cdelt2 crota2 filter detnam photocell1 photocell2 \
         pixsize1 pixsize2 crval1 crval2 crpix1 crpix2 tempair airpress \
         observer sitename imagetyp objname]

      #--   liste les variables necessaires pour activer le bouton 'image DSS'
      set private(dss_variables) [list crval1 crval2 fov1 fov2 naxis1 naxis2 crota2]

      #--   liste les boutons
      set private(buttonList) [list cmd.syn cmd.special cmd.dss cmd.close cmd.hlp \
       n.local.modifGps n.optic.modifOptic n.config.search n.kwds.modifObs \
       n.kwds.editKwds n.kwds.writeKwds n.config.realtime n.config.dispEtc n.config.simulimage ]

      set this $::audace(base).info
      set private(This) $this
      createMyNoteBook $visuNo

      #--   initialise les listener permanents
      configAddRemoveListener $visuNo add
   }

   #------------------------------------------------------------
   #  createMyNoteBook : creation de l'interface graphique
   #------------------------------------------------------------
   proc createMyNoteBook { visuNo } {
      variable private
      global audace caption conf color

      set this $private(This)

      if {[winfo exists $this]} {
         closeMyNoteBook $visuNo $this
      }

      toplevel $this -class Toplevel
      wm title $this "$caption(collector,title)"
      wm geometry $this "$private(position)"
      wm resizable $this 0 0
      wm protocol $this WM_DELETE_WINDOW "::collector::closeMyNoteBook $visuNo $this"

      ttk::style configure my.TEntry -foreground $audace(color,entryTextColor)
      ttk::style configure default.TEntry -foreground red

      pack [ttk::notebook $this.n]

      #--   liste des variables de chaque onglet, affichees dans cet ordre
      set targetChildren [list equinox ra dec separator1 true raTel decTel azTel elevTel haTel]
      set dynamicChildren [list m error snr t prior]
      set poseChildren [list bin1 bin2 cdelt1 cdelt2 naxis1 naxis2 fov1 fov2 crota2]
      set localChildren [list gps modifGps tu jd tsl moonphas moonalt moon_age]
      set atmChildren [list tempair temprose hygro airpress winddir windsp seeing fwhm secz airmass]
      set opticChildren [list telescop modifOptic aptdia foclen fond resolution ncfz psf filter]
      set camChildren [list detnam photocell1 photocell2 eta noise therm gain ampli isospeed]
      set tlscpChildren [list telname suivi vra vdec vxPix vyPix separator1]
      set kwdsChildren [list observer modifObs sitename origin iau_code imagetyp objname separator1 editKwds writeKwds]
      if { $::tcl_platform(platform) == "windows" } {
         set configChildren [list catname access search separator1 meteo cumulus realtime separator2 dispEtc simulimage]
      } else {
         set configChildren [list catname access search separator1 dispEtc simulimage]
      }

      #--   construit le notebook dans cet ordre
      foreach topic [list target dynamic pose local atm optic cam tlscp german kwds config] {
         set fr [frame $this.n.$topic]
         #--   ajoute un onglet
         $this.n add $fr -text "$caption(collector,$topic)"
         if {$topic ne "german"} {
            #--   ajoute les lignes dans l'onglet
            set children [set ${topic}Children]
            set len [llength $children]
            for {set k 0} {$k < $len} {incr k} {
               set child [lindex $children $k]
               configLigne $topic $child $k
            }
            grid columnconfigure $fr {1} -pad 5 -weight 1
         } else {
            #--   construit l'onglet pour une monture allemande
            buildOngletGerman $this.n.german $visuNo
         }
      }

      buildPark "$this.n.tlscp"

     #--   boutons de commande principaux
     frame $this.cmd

       foreach {but side} [list syn left dss left close right hlp right]  {
            pack [ttk::button $this.cmd.$but -text "$caption(collector,$but)" -width 10] \
               -side $side -padx 10 -pady 5 -ipady 5
       }
       ttk::button $this.cmd.special -image $private(baguette) -width 4 -compound image
         pack $this.cmd.special -after $this.cmd.syn -side left -padx 10 -pady 5 -ipadx 4 -ipady 4

         #-- specialisation des boutons
         $this.cmd.syn configure -command "::collector::synthetiser $visuNo"
         $this.cmd.special configure -command "::collector::createSpecial $visuNo $this.cmd.special"
         $this.cmd.dss configure -command "::collector::requestSkyView \"[file join $::audace(rep_images) dss$::conf(extension,defaut)]\" "
         $this.cmd.hlp configure -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::collector::getPluginType ] ] [ ::collector::getPluginDirectory ] collector.htm"
         $this.cmd.close configure -command "::collector::closeMyNoteBook $visuNo $this"

      pack $this.cmd -in $this -side bottom -fill x

      $this.cmd.special state disabled
      $this.cmd.syn state disabled
      $this.cmd.dss state disabled

      #--   initialisation partielle
      lassign [list "" 0] private(suivi) private(german)
      $this.n.tlscp.suivi configure -image $private(redLed) \
         -compound right -textvariable ""
      set private(image) ""

      $this.n.dynamic.prior current 0
      $this.n.kwds.imagetyp current 3
      set private(objname) "mySky"

      set private(meteo) 0

      onChangeImage $visuNo

      #--- La fenetre est active
      focus $this

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $this
   }

   #------------------------------------------------------------
   #  configLigne : construit une ligne de la fenetre
   #  Paremetres : nom topic et du child, n° de ligne (row)
   #  Initialise les variables non initialisees à "-"
   #------------------------------------------------------------
   proc configLigne { topic child row {visuNo 1} } {
      variable private
      global audace caption

      set onglet $private(This).n.$topic
      set w $onglet.$child

      #--   corrige row pour certaines lignes
      if {$child in [list tu aptdia foclen sitename]} {incr row -1}

      if {[regexp {(separator).} $child] == 1} {

         grid [ttk::separator $w -orient horizontal] \
           -row $row -column 0 -columnspan 3 -padx 10 -pady 5 -sticky news
         $w state !disabled
         return

      } elseif {$child eq "meteo"} {

         ttk::checkbutton $onglet.$child -text "$caption(collector,$child)" \
            -variable ::collector::private($child) -onvalue 1 -offvalue 0 \
            -command "::collector::onchangeCumulus"
         grid $onglet.$child -row $row -column 0 -columnspan 3 -sticky w -padx 10 -pady 3
         return

      } elseif {$child in [list modifGps modifOptic search realtime modifObs modifSite editKwds writeKwds dispEtc simulimage]} {

         ttk::button $w -text "$caption(collector,$child)"
         switch -exact $child {
            modifGps   {$w configure -command "::confPosObs::run $audace(base).confPosObs" -width 7 -padding {2 2}
                        grid $w -row 0 -column 2
                       }
            modifOptic {$w configure -command "::confOptic::run $visuNo" -width 7 -padding {2 30}
                        grid $w -row 0 -column 2 -rowspan 3
                       }
            search     {$w configure -command "::collector::configDirname $w" -width 4 -padding {2 2}
                        grid $w -row 1 -column 2
                       }
            realtime   {$w configure -command "::collector::configDirname $w" -width 4 -padding {2 2}
                        grid $w -row 5 -column 2
                       }
            modifObs   {$w configure -command "::confPosObs::run $audace(base).confPosObs" -width 7 -padding {2 2}
                        grid $w -row 0 -column 2 -rowspan 5
                       }
            editKwds   {$w configure -command "::collector::createKeywords ; ::collector::editKeywords"
                        grid $w -row $row -column 1
                       }
            writeKwds  {$w configure -command "::collector::setKeywords"
                        grid $w -row $row -column 1
                       }
            dispEtc    {$w configure -command "etc_disp"
                        grid $w -row $row -column 1
                       }
            simulimage {$w configure -command "::audace::showHelpItem \"$::audace(rep_doc_html)/french/12tutoriel\" \"1030tutoriel_simulimage1.htm\""
                        grid $w -row $row -column 1
                       }
         }
         grid configure $w -padx 5 -pady 5 -sticky news
         return

      }

      #--   nomme la ligne
      label $onglet.lab_$child -text "$caption(collector,$child)" -justify left
      grid $onglet.lab_$child -row $row -column 0 -sticky w -padx 10 -pady 3

      if {$child in $private(labels)} {

        label $w -textvariable ::collector::private($child)

      } elseif {$child in $private(entry)} {

         set width 7
         if {$child in [list gps tu ]} {
            set width 30
         } elseif {$child in [list ra dec objname]} {
            set width 15
         }

         ttk::entry $w -textvariable ::collector::private($child) \
            -width $width -justify right
         set private(prev,$child) ""

         #--   configure la validation de la saisie
         if {$child ni [list equinox gps ra dec tu objname]} {
            bind $w <Leave> [list ::collector::testNumeric $child] ; # pattern de la variable , variables numeriques (dont etc_tools)
          } else {
            bind $w <Leave> [list ::collector::testPattern $child] ; # pattern de la variable
         }

      } elseif {$child in [list prior filter detnam imagetyp catname catname2]} {

         #--   combobox
         #--   liste et commande du binding
         switch -exact $child {
            prior    {  set values $caption(collector,prior_combo)
                        set cmd "::collector::modifyPriority"
                     }
            filter   {  set values $caption(collector,band)
                        set cmd "::collector::modifyBand"
                     }
            detnam   {  set values [linsert $private(actualListOfCam) end $caption(collector,newCam)]
                        set cmd "::collector::modifyCamera"
                     }
            imagetyp {  set values $caption(collector,imagetypes)
                        set cmd "return"
                    }
            catname  {  set values $caption(collector,catalog)
                        set cmd "return"
                     }
         }

         #--   largeur
         set width [::tkutil::lgEntryComboBox $values]
         if {$width < 4} {set width 4}

         ttk::combobox $w -width $width -justify center -values $values \
            -textvariable ::collector::private($child)
         $w state !disabled

         #--   binding
         bind $w <<ComboboxSelected>> [list $cmd]

         #--   positionnement initial
         if {$child eq "catname"} {
            $w set [lindex $values 0]
         }
      }

      grid $w -row $row -column 1 -sticky e -padx 10

      #--   initialise la variable
      if {![info exists private($child)]} {set private($child) "-"}
   }

   #------------------------------------------------------------
   #  configCmd
   #  Configure chaque bouton {syn|dss|special} en fonction des infos disponibles
   #------------------------------------------------------------
   proc configCmd { } {
      variable private

      foreach but [list dss syn special] {

         #--   empeche une erreur si la fenetre a ete fermee
         if {![winfo exists $private(This).cmd.$but]} {return}

         set state !disabled
         if {$but ne "syn" || $private(image) ne ""} {
            if {"-" in [::struct::list map $private(${but}_variables) getValue]} {
               set state disabled
            }
         } else {
            set state disabled
         }
         $private(This).cmd.$but state $state
      }
   }

   #---------------------------------------------------------------------------
   #  configButtons
   #  Inhibe/Desinhibe tous les boutons
   #---------------------------------------------------------------------------
   proc configButtons { state } {
      variable private

      foreach b $private(buttonList) {
         $private(This).$b state $state
      }
      if {$state eq "!disabled"} {
         configCmd
      }
   }

   #------------------------------------------------------------
   #  closeMyNoteBook
   #  Commande du bouton 'Fermer"
   #------------------------------------------------------------
   proc closeMyNoteBook { visuNo this } {
      variable private
      global audace conf

      #--   arrete la mise a jour
      #--   pas d'importance si pas active
      after cancel ::collector::refreshCumulus

      foreach icon {baguette chaudron greenLed redLed} {
         if {[info exists $private($icon)]} {
            image delete $private($icon)
         }
      }

      configTraceSuivi 0
      configTraceRaDec 0
      configAddRemoveListener $visuNo remove

      #--   equivalent de widgetToConf
      set conf(collector,access) $private(access)
      set conf(collector,catname) $private(catname)
      if {$private(cumulus) ne ""} {
         set conf(collector,cumulus) $private(cumulus)
      }
      regsub {([0-9]+x[0-9]+)} [wm geometry $this] "" conf(collector,position)

      set conf(collector,colors) [list $private(colFond) $private(colReticule) \
         $private(colTel) $private(colButee) $private(colSector)]
      set conf(collector,butees) [list $private(buteeWest) $private(buteeEast)]
      setConfCam

      #--   detruit la fenetre Ajouter/Supprimer
      if {[winfo exists $audace(base).newCam]} {
         destroy $audace(base).newCam
      }

      destroy $this
   }

   #---------------------------------------------------------------------------
   #  confToWidget
   #  Initalise les variables issues de conf
   #---------------------------------------------------------------------------
   proc confToWidget {} {
      variable private
      global audace conf color

      if {![info exists conf(collector,colors)]} {
         set conf(collector,colors) [list blue azure yellow red gray]
      }
      lassign $conf(collector,colors) private(colFond) private(colReticule) \
         private(colTel) private(colButee) private(colSector)

      if {![info exists conf(collector,butees)]} {
         set conf(collector,butees) [list +6.10 -6.10]
      }
      lassign $conf(collector,butees) private(buteeWest) private(buteeEast)

      #--   conf par defaut et confToWidget
      set listConf [list catname access cumulus cam position]
      set listDefault [list "MICROCAT" "[file join $audace(rep_userCatalog) microcat]" "" " " "+800+500"]
      foreach topic $listConf value $listDefault {
         if {![info exists conf(collector,$topic)]} {
             set conf(collector,$topic) $value
         }
         set private($topic) $conf(collector,$topic)
      }

      #editCamerasArray
   }

   #------------------------------------------------------------
   #  configAddRemoveListener
   #  Configure les listener
   #  Paremetres : visuNo {add|remove}
   #------------------------------------------------------------
   proc configAddRemoveListener { visuNo op } {

      set bufNo [visu$visuNo buf]

      #---  trace les changements d'image
      ::confVisu::${op}FileNameListener $visuNo "::collector::onChangeImage $visuNo"
      #---  trace les changements de Cam
      ::confVisu::${op}CameraListener $visuNo "::collector::onChangeCam $bufNo"
      #---  trace les changements de configuration optique
      ::confOptic::${op}OpticListener "::collector::onChangeOptic $bufNo"
      #---  trace la connexion d'un telescope
      ::confTel::${op}MountListener "::collector::onChangeMount $visuNo"
      #---  trace les changements de Observateur et de la position de l'observateur
      ::confPosObs::${op}PosObsListener "::collector::onChangeObserver $bufNo"
      trace $op variable conf(posobs,observateur,gps) write "::collector::onChangeObserver $bufNo"
   }

   #---------------------------------------------------------------------------
   #  configTraceSuivi
   #  Configure la trace du controle du suivi en cas de connexion/deconnexion du telescope
   #  Paremetre : suiviState {0|1}
   #---------------------------------------------------------------------------
   proc configTraceSuivi { suiviState } {
      variable private

      set trace 0
      if {[trace info variable ::audace(telescope,controle)] ne ""} {
         set trace 1
      }

      #--   configure la trace
      if {$suiviState != 0 && $trace == 0} {
         trace add variable ::audace(telescope,controle) write "::collector::onChangeSuivi"
      } elseif {$suiviState == 0 && $trace == 1} {
         trace remove variable ::audace(telescope,controle) write "::collector::onChangeSuivi"
      }

      #--   configure la ligne
      set w $private(This).n.tlscp

      if {$suiviState == 1} {
         grid $w.lab_suivi -row 1 -column 0 -sticky w -padx 10 -pady 3
         grid $w.suivi -row 1 -column 1 -sticky e -padx 10
      } else {
         if {[winfo exists $w.lab_suivi]} {
            grid forget $w.lab_suivi $w.suivi
         }
      }
   }

   #---------------------------------------------------------------------------
   #  configTraceRaDec
   #  Configure la trace en cas des coordonnees du telescope
   #  Paremetre : hasCoordinates {0|1}
   #---------------------------------------------------------------------------
   proc configTraceRaDec { hasCoordinates } {
      variable private

      set trace 0
      if {[trace info variable ::audace(telescope,getra)] ne ""} {
         set trace 1
      }

      #--   configure la trace
      if {$hasCoordinates == 1 && $trace == 0} {
         trace add variable ::audace(telescope,getra) write "::collector::refreshNotebook"
      } elseif {$hasCoordinates == 0 && $trace == 1} {
         trace remove variable ::audace(telescope,getra) write "::collector::refreshNotebook"
      }

      #--   configure les lignes
      set w $private(This).n.tlscp

      if {$hasCoordinates == 1} {
         #--   affiche les lignes
         set r 2
         foreach v [list vra vdec vxPix vyPix] {
            grid $w.lab_$v -row $r -column 0 -sticky w -padx 10 -pady 3
            grid $w.$v -row $r -column 1 -sticky e -padx 10
            incr r
         }
      } else {
         #--   supprime les lignes
         if {[winfo exists ${w}.lab_vra]} {
            grid forget $w.lab_vra $w.vra $w.lab_vdec $w.vdec $w.lab_vxPix $w.vxPix $w.lab_vyPix $w.vyPix
         }
      }
   }

   #------------------------------------------------------------
   #  configParkInit
   #  Masque ou affiche les fonctions d'initialisation/garage
   #  Parametres : { show = affiche | forget == masque }
   #------------------------------------------------------------
   proc configParkInit { w state german } {

      switch -exact $state {
         "forget" {  grid forget $w.action1
                     grid forget $w.coords
                     grid forget $w.action3
                  }
         "show"   {  grid $w.action1 -row 8 -column 0 -columnspan 2 -sticky w -pady 3
                     grid $w.coords -row 9 -column 0 -columnspan 2 -sticky w -pady 3
                     grid $w.action3 -row 10 -column 0 -columnspan 2 -sticky w -pady 3
                     #--   configure le choix du cote ou se trouve le tube pour les montures allemandes
                     if {$german == 0} {
                        pack forget $w.coords.parkside
                     }
                     cmdParkMode $w.coords
                  }
      }
   }

   #---------------------------------------------------------------------------
   #  configDirname
   #  Commande du bouton '...'
   #---------------------------------------------------------------------------
   proc configDirname { this } {
      variable private
      global audace caption conf

      set dirname [tk_chooseDirectory -title "$caption(collector,access)" \
         -initialdir $audace(rep_userCatalog) -parent $this]

      if { [string length $dirname] != 0 && [string index $dirname end] ne "/" } {
         append dirname /
      }

      if {[lindex [split $this "."] end] eq "search"} {
         if {$dirname ne ""} {
            set private(access) "$dirname"
         } else {
            set private(access) "$conf(collector,access)"
         }
      } elseif {[lindex [split $this "."] end] eq "realtime"} {
         #--   verifie la presence de cumulus.exe
         if {$dirname ne "" && [file exists [file join $dirname cumulus.exe]]} {
            set private(cumulus) "[file join $dirname realtime.txt]"
         }
      }
   }

   #---------------------------------------------------------------------------
   #  hideTel
   #  masque les onglets Monture et Allmande
   #---------------------------------------------------------------------------
   proc hideTel { notebook } {
      variable private

      $notebook hide $notebook.tlscp
      $notebook hide $notebook.german

      #--   supprime le suivi
      configTraceSuivi 0

      #--   supprime l'affichage du parquage
      configParkInit $notebook.tlscp forget 0

      #--   supprime l'affichage des vitesses
      configTraceRaDec 0

      #--   reinitialise les variables
      set private(vra) [format %0.5f 0]
      set private(vdec) [format %0.5f 0]
      set private(vxPix) [format %0.1f 0]
      set private(vyPix) [format %0.1f 0]

      #--   si trace presente et telescope deconnecte
      set bufNo 1
      set visuNoTel [::confVisu::getToolVisuNo ::tlscp]
      if {[trace info variable ::tlscp::private($visuNoTel,nomObjet)] ne ""} {
         trace remove variable ::tlscp::private($visuNoTel,nomObjet) write "::collector::onChangeObjName $bufNo"
      }
   }

   #--   proc associees a des fonctions ::struct::list
   #--   retourne la liste des valeurs d'une liste de variables
   proc getValue {var} {return $::collector::private($var)}
   #--   extrait tous les elements d'index n dans une liste de listes
   proc extractIndex {n list} {::lindex $list $n}

