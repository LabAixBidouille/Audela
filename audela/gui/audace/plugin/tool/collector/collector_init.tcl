#
# Fichier : collector_init.tcl
# Description :
# Auteur : Raymond Zachantke
# Mise à jour $Id$
#

   #--   Liste des proc                utilisee par
   # ::collector::onChangeImage        ::confVisu::addFileNameListener
   # ::collector::initLocal            onChangeImage
   # ::collector::initAtm              onChangeImage
   # ::collector::initTarget           onChangeImage
   # ::collector::initPose             onChangeImage
   # ::collector::onChangeOptic        ::confOptic::addOpticListener
   # ::collector::onChangeMount        ::confTel::addMountListener
   # ::collector::onChangeSuivi        trace add variable "::audace(telescope,controle) et onChangeMount
   # ::collector::onChangeCam          configAddRemoveListener
   # ::collector::onChangeObserver     ::confPosObs::addPosObsListener et conf(posobs,observateur,gps)
   # ::collector::onChangeObjName      onChangeMount
   # ::collector::onchangeCumulus      refreshCumulus

   #------------------------------------------------------------
   #  onChangeImage :
   #  Pilote l'initialisation complete lors de
   #  l'initialisation et lors du chargement d'une image
   #------------------------------------------------------------
   proc onChangeImage { visuNo args } {
      variable private
      global audace conf

      #--   inactive le bouton d'ecriture des mots cles
      $private(This).n.kwds.writeKwds state disabled

      set new_image [::confVisu::getFileName $visuNo]

      if {[info exists private(precedent)] && $new_image eq "$private(precedent)"} {return}

      set ext [file extension $new_image]
      set bufNo [visu$visuNo buf]

      #--   noms d'images a exclure
      set image [file join $audace(rep_images) dss$ext]
      if {$new_image eq "$image"} {
         #--   detection des images DSS
         configCmd
         return
      }

      if {[regexp {(Canon).+} [lindex [buf$bufNo getkwd CAMERA] 1]] == 1} {
         #--   detection des image issues de Canon
         set private(image) "type1"
      } elseif {[string trim [lindex [buf$bufNo getkwd INPUTFMT] 1]] eq "SER"} {
         #--   detection des image SER
         set private(image) "type2"
      } else {
         #--   memorise le nom
         set private(image) $new_image
      }

      #--   active le bouton d'ecriture des mots cles
      if {$private(image) ni [list "$image" ""]} {
         $private(This).n.kwds.writeKwds state !disabled
      }

      initLocal $bufNo
      initAtm $bufNo
      onChangeOptic $bufNo
      onChangeMount $visuNo
      onChangeCam $bufNo
      initTarget $bufNo
      initPose $bufNo
      computeTelCoord
      updateInfo naxis1
      onChangeObserver $bufNo
      onChangeObjName $bufNo
   }

   #------------------------------------------------------------
   #  initLocal : mise a jour de l'onglet Local
   #------------------------------------------------------------
   proc initLocal { bufNo } {
      variable private
      global audace

      switch -exact $private(image) {
         type1    {  set private(gps) $audace(posobs,observateur,gps)
                     lassign [getDateExposure $bufNo] private(t) private(tu) private(jd)
                  }
         type2    {  set private(gps) $audace(posobs,observateur,gps)
                     lassign [getDateExposure $bufNo] private(t) private(tu) private(jd)
                  }
         ""       {  set private(gps) $audace(posobs,observateur,gps)
                     set private(t) $audace(etc,input,ccd,t)
                     set date [::audace::date_sys2ut now]
                     lassign [getDateTUJD $date] private(tu) private(jd)
                  }
         default  {  set private(gps) [getTelPosition $bufNo]
                     lassign [getDateExposure $bufNo] private(t) private(tu) private(jd)
                  }
      }

      computeTslMoon

      set private(seeing) $audace(etc,param,local,seeing)
   }

   #------------------------------------------------------------
   #  initAtm : mise a jour de Meteo
   #  Note : la temperature et la pression sont des variables de hip2tel
   #------------------------------------------------------------
   proc initAtm { bufNo } {
      variable private

      lassign [getTPW $bufNo] private(tempair) private(temprose) private(hygro) \
         private(winddir) private(windsp) private(airpress)
   }

   #------------------------------------------------------------
   #  initTarget  : mise a jour de Cible
   #------------------------------------------------------------
   proc initTarget { bufNo } {
      variable private
      global audace

      switch -exact $private(image) {
         type1    {  if {$audace(telNo) != 0} {
                        #--   coordonnees rafraichies par le telescope
                     }
                  }
         type2    {  if {$audace(telNo) != 0} {
                        #--   coordonnees rafraichies par le telescope
                     }
                  }
         ""       {  if {$audace(telNo) == 0} {

                        #--   coordonnees azimutales du zenith
                        set az 0.0 ; set elev 90

                        #--   met a jour les coordonnees
                        refreshCoordsJ2000 $az $elev ALTAZ
                        set private(equinox) "J2000.0"
                     }
                  }
         default  {  if {$audace(telNo) == 0} {
                        #--   collecte et assigne les donnees dans l'image
                        lassign [getImgData $bufNo] private(ra) private(dec) private(equinox) \
                           private(naxis1) private(naxis2) private(bin1) private(bin2) \
                           private(crota2) private(crval1) private(crval2) \
                           private(crpix1) private(crpix2) private(pixsize1) private(pixsize2)
                     }
                  }
      }
   }

   #------------------------------------------------------------
   #  initPose : mise a jour de l'onglet Vue
   #------------------------------------------------------------
   proc initPose { bufNo } {
      variable private

      #--   raccourcis
      foreach v [list naxis1 naxis2 photocell1 photocell2] {
         set $v $private($v)
      }

      if {$private(image) eq ""} {

         set data [list $naxis1 $naxis2 $private(photocell1) $private(photocell2)]

         if {"-" ni $data} {
            #--   bin == 1; dim =naxis ; pixsize = photocell
            set result [linsert $data 0 1 1]
        } else {
            #--   configuration par defaut
            set result [list 1 1 - - - -]
         }

         lassign $result private(bin1) private(bin2) private(naxis1) private(naxis2) private(pixsize1) private(pixsize2)

         if {$private(crota2) in [list "" "-"]} {
            set private(crota2) 0
         }

         set t $::audace(etc,input,ccd,t)
         set audace(etc,param,ccd,bin1) 1
         set audace(etc,param,ccd,bin2) 1

      } elseif {$private(image) in [list type1 type2 ""]} {

         lassign [getImgData $bufNo] -> -> -> private(naxis1) private(naxis2) \
            private(bin1) private(bin2) photocell1 photocell2

         #--   ne change les valeurs que si elles sont connues
         foreach v [list photocell1 photocell2] {
            set value [set $v]
            if {$value ne "-"} {
               set private($v) $value
            }
         }
      }

      #computeCdeltFov
      computeCenterPixVal

      #--   raccourcis
      foreach v [list ra dec pixsize1 pixsize2 foclen cdelt1 cdelt2 crpix1 crpix2 crval1 crval2] {
         set $v $private($v)
      }

      set private(match_wcs) [getMatchWCS $ra $dec $pixsize1 $pixsize2 $foclen $cdelt1 $cdelt2 $crpix1 $crpix2 $crval1 $crval2]

      set private(m) $::audace(etc,input,object,m)
      set private(snr) 3
      set private(error) [format %0.3f [expr { 1.09 / $private(snr) }]]
    }

   #------------------------------------------------------------
   #  onChangeOptic : mise a jour de l'onglet Optique
   #  soit a partir des mots clés de l'image
   #  soit a partir de la configuration de l'optique du telescope
   #------------------------------------------------------------
   proc onChangeOptic { bufNo args } {
      variable private
      global audace

      if {$private(image) ni [list type1 ""]} {

         lassign [getKwdOptic $bufNo] private(telescop) private(aptdia) private(foclen) private(filter)

      }  else {

         if {![info exists private(camItem)]} {
            set private(camItem) A
         }
         lassign [::confOptic::getConfOptic $private(camItem)] private(telescop) aptdia foclen
         set private(aptdia) [format %0.3f $aptdia]
         set private(foclen) [format %0.3f $foclen]
         set private(filter) C

      }

      #--   dans les deux cas, calcule et met a jour le ratio F/D et le pouvoir separateur
      computeOptic

      set private(psf)  [expr {$audace(etc,param,optic,Fwhm_psf_opt)*1e6}]

      #--   met a jour les parametres de etc_tools
      foreach {par val} [list D $private(aptdia) FonD $private(fond)] {
         if {$val ne "-"} {
            set audace(etc,param,optic,$par) $val
          }
      }
   }

   #------------------------------------------------------------
   #  onChangeMount : mise a jour de l'onglet Monture
   #------------------------------------------------------------
   proc onChangeMount { visuNo args } {
      variable private
      global audace

      set notebook $private(This).n

      if {![::confTel::isReady]} {
         #--   masque les onglets specifiques du telescope
         #     qui arrete le rafraichissement de la meteo
         hideTel $notebook
         return
      }

      set telNo $audace(telNo)
      set bufNo [visu$visuNo buf]

      #--   affiche et selectionne l'onglet 'Telescope'
      $notebook add $notebook.tlscp
      $notebook select $notebook.tlscp

      #--   active le rafraichissement de la meteo
      onchangeCumulus

      lassign [getTelConnexion] private(product) private(telname) \
         hasCoordinates hasControlSuivi

      #--   active le suivi
      configTraceSuivi $hasControlSuivi
      onChangeSuivi

      #--   identifie une monture Allemande
      set private(german) [::confTel::getPluginProperty isGermanMount]
      if {$private(german) == 0 && $private(telname) eq "ASCOM (ScopeSim.Telescope)"} {
         set private(german) 1
      }

      #--   active les vitesses
      configTraceRaDec $hasCoordinates

      #--   configure les lignes du parquage
      set do "forget"
      if {$hasCoordinates == 1 && $hasControlSuivi == 1} {
         set do "show"
      }
      configParkInit $notebook.tlscp $do $private(german)

      #--   si necessaire, affiche l'onglet 'Allemnade'
      if {$private(german) == "1"} {
         $notebook add $notebook.german
      }

      #--   met en place la trace du nom de l'objet selectionne dans le panneau telescope
      #     present et trace absente
      set visuNoTel [::confVisu::getToolVisuNo ::tlscp]
      if {$visuNoTel ne "" && $bufNo ne "" && \
         [trace info variable ::tlscp::private($visuNoTel,nomObjet)] eq "" } {
         trace add variable ::tlscp::private($visuNoTel,nomObjet) write "::collector::onChangeObjName $bufNo"
      }
   }

   #------------------------------------------------------------
   #  onChangeSuivi : mise a jour du temoin du suivi
   #  Lancee par trace add variable "::audace(telescope,controle)"
   #  et onChangeMount
   #------------------------------------------------------------
   proc onChangeSuivi { args } {
      variable private

      set indicator [regexp {.+(On)} $::audace(telescope,controle)]
      set suivi  $private(This).n.tlscp.suivi

      if {[winfo exists $suivi] && $indicator == 1} {
         $suivi configure -image $private(greenLed)
      } else {
         $suivi configure -image $private(redLed)
      }
   }

   #------------------------------------------------------------
   #  onChangeCam  : mise a jour des specifications de la cam
   #  soit a partir des kwd de l'image et de etc_tools
   #  soit a partir de la cam connectee
   #------------------------------------------------------------
   proc onChangeCam { bufNo args } {
      variable private

      #--   valeurs par defaut
      set camList $private(actualListOfCam)
      set detnam [lindex $camList 0]
      modifyCamera

      set params [list photocell1 photocell2 eta noise therm gain ampli]
      set style "TEntry"

      if {$private(image) eq "" || $args ne ""} {

         #--   connexion d'une cam
         set data [getCamSpec]

         if {[lindex $data 0] ne "-"} {

            #--   cam avec nom + spec --> change le nom
            lassign $data detnam private(camItem) private(naxis1) private(naxis2) \
               private(photocell1) private(photocell2)
            updateEtc naxis1 $private(naxis1)
            updateEtc naxis2 $private(naxis2)
            updateEtc photocell1 $private(photocell1)
            updateEtc photocell2 $private(photocell2)

            set params [list eta noise therm gain ampli]
            set style "default.TEntry"
         }

      } elseif {$private(image) ne "" && $args eq ""} {

         if {$private(image) ni [list type1 type2]} {
            #--   chargement d'une image
            lassign [getCamName $bufNo] detnam photocell1 photocell2

            #--   ne change les valeurs que si elles sont connues
            foreach v [list photocell1 photocell2] {
               set value [set $v]
               if {$value ne "-"} {
                  set private($v) $value
                  set k [lsearch $params $v]
                  set params [lreplace $params $k $k]
               }
            }
         } else {
            switch -exact $private(image) {
               type1 { set detnam "Canon EOS 60D" }
               type2 { set detnam "BASLER 1300" }
            }
         }
      }

      if {$detnam eq "-"} {
         set detnam "$::caption(collector,newCam)"
      }

      set private(detnam) $detnam

      if {$detnam in $camList} {
         modifyCamera
         if {[info exists private(newCam)]} {
            unset private(newCam)
            if {[winfo exists $::audace(base).newCam]} {
               destroy $::audace(base).newCam
            }
         }
      } else {
         activeOnglet cam
         set private(newCam) $detnam
         set style "default.TEntry"
      }

      #--   gere la couleur des valeurs des parametres
      changeEntryStyle $params $style
   }

   #------------------------------------------------------------
   #  onChangeObserver : mise a jour du nom de l'observateur, etc.
   #  Lancee aussi par ::confPosObs::addPosObsListener
   #------------------------------------------------------------
   proc onChangeObserver { bufNo args } {
      variable private
      global conf

      #--   pm type1 --> nom Canon
      if {$private(image) ni [list type1 type2 ""]} {

         #--   a partir des mots cles d'une image
         lassign [getObserv $bufNo] private(observer) private(sitename)
         set private(gps) [getTelPosition $bufNo]

      } else {

        #--   a partir de la configuration d'Aud'ACE
         set private(observer) $conf(posobs,nom_observateur)
         set private(sitename) $conf(posobs,nom_observatoire)
         set private(origin) $conf(posobs,nom_organisation)
         set private(iau_code) $conf(posobs,station_uai)
         set private(gps) $conf(posobs,observateur,gps)
      }
   }

   #------------------------------------------------------------
   #  onChangeObjName  : mise a jour du type d'image et du nom de l'objet
   #  Lancee aussi par trace add variable ::tlscp::private($visuNoTel,nomObjet)
   #------------------------------------------------------------
   proc onChangeObjName { bufNo args } {
      variable private
      global caption

      #--   identifie le N° de la visu comportant le panneau telescope
      set visuNoTel [::confVisu::getToolVisuNo ::tlscp]

      #--   valeurs par defaut
      set result [list [lindex $caption(collector,imagetypes) 3] mySky] ; # valeurs par defaut

      if {[::confTel::isReady] ==1 && $visuNoTel ne ""} {

         #-- Rem : le panneau Telescope doit etre ouvert prealablement dans une visu
         #--   capture le nom de l'objet pointe si le telescope est en marche
         set result [list [lindex $caption(collector,imagetypes) 3] $::tlscp::private($visuNoTel,nomObjet)]

      } elseif {[buf$bufNo imageready] == 1} {

         #-- Cherche dans les mots cles de l'image
         set result1 [getObject $bufNo]
         if {"-" ni "$result1"} {
            set result $result1
         }

      }

      lassign $result private(imagetyp) private(objname)
   }

   #------------------------------------------------------------
   #  onchangeCumulus  :
   #  active la lecture des parametres meteo si le telescope est actif
   #  et si les autres conditions ont reunies
   #  sinon desactive
   #------------------------------------------------------------
   proc onchangeCumulus { } {
      variable private

      set notebook $private(This).n

      if {[$notebook tab $notebook.tlscp -state] eq "hidden" || $private(meteo) == 0 \
         && $private(cumulus) ne "" || [file exists $private(cumulus)] == 0} {

         #--   tous les autres cas, initialisation par defaut
         lassign [list 16.85 - - - - 101325] private(tempair) private(hygro) \
            private(temprose) private(winddir) private(windsp)  private(airpress)

         #--   arrete la mise a jour
         #--   pas d'importance si pas active
         after cancel ::collector::refreshCumulus

      } else {

         #--   demarre la mise a jour
         refreshCumulus

      }
   }

