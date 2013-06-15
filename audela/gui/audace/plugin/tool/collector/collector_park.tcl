#
# Fichier : collector_park.tcl
# Description :
# Auteur : Raymond Zachantke
# Mise à jour $Id$
#

   #--   Liste des proc de la gestion du parquage/deparquage
   # nom proc                             utilisee par
   # ::collector::doUnPark                Commande du bouton 'Initialiser'
   # ::collector::doPark                  Commande du bouton 'Garer'
   # ::collector::buildPark               createMyNoteBook
   # ::collector::cmdParkMode             Commande associee a la combobox de choix du mode
   # ::collector::configTimeListener      Commande du checkbutton de programmation du parquage 'Auto'
   # ::collector::updateTlscp             doUnPark et doPark
   # ::collector::confirmPark             doUnPark et doPark
   # ::collector::configParkWidget        doUnPark et doPark

   #----------------------------deparquage/initialisation-----------------------

   #------------------------------------------------------------
   #  doUnPark
   #  Initialise la monture
   #  Commande du bouton 'Déparquer'
   #------------------------------------------------------------
   proc doUnPark { } {
      variable private
      global audace conf caption

       #--   raccourcis
      foreach v [list product telname german ra dec parkMode parkaz parkelev] {set $v $private($v)}

      set telNo $audace(telNo)
      set w $private(This).n.tlscp
      if {$german == 1} {
         set mountside [string map [list 0 W 1 E] [$w.coords.parkside current]]
      }
      set modeNo [$w.coords.mode current]

      #--   inhibe les widgets appropries
      configParkWidget $w $modeNo $german disabled

      #--   met a jour les coordonnees
      refreshCoordsJ2000 $parkaz $parkelev ALTAZ

      #--   rafraichit le panneau telescope
      updateTlscp $ra $dec $parkMode
      if {$german == 1} {
         ::telescope::match [list $ra $dec] "J2000.0" $mountside
       } else {
         ::telescope::match [list $ra $dec] "J2000.0"
      }

      #--   bascule vers Suivi On
      tel$telNo radec motor on
      set audace(telescope,controle) "$caption(telescope,suivi_marche)"

      #--   verifie le cote pour les montures allemandes
      if {$german == 1} {
         tel$telNo german $mountside
         lassign [getGermanSide] telSide telIndex side
         confirmPark unpark $telname $parkMode $parkaz $parkelev $ra $dec $side
         initMyTel $modeNo $telSide
      } else {
         confirmPark unpark $telname $parkMode $parkaz $parkelev $ra $dec
      }

      #--   memorise le deparquage en supprimant la variable conf
      if {[info exists conf($product,park)]} {
         unset conf($product,park)
      }
      set private(unpark) 0

      #--   desinhibe les widgets appropries
      configParkWidget $w $modeNo $german !disabled
   }

   #---------------------------- parquage ----------------------

   #------------------------------------------------------------
   #  doPark
   #  Parque la monture
   #  Commande du bouton 'Parquer'
   #------------------------------------------------------------
   proc doPark {  args } {
      variable private
      global audace caption conf

      #--   ne fait rien si le suivi est arrete, si la commande n'est pas activee
      #  ou si ce n'est pas l'heure
      if {$audace(telescope,controle) eq "$caption(telescope,suivi_arret)" || \
         ($private(parkAuto) == 1 && $audace(hl,format,hm) ne "$private(parkHr) $private(parkMin)")} {
         return
      }

      set telNo $audace(telNo)
      set w $private(This).n.tlscp
      set german $private(german)
      set modeNo [$w.coords.mode current]

      #--   inhibe les widgets appropries
      configParkWidget $w $modeNo $german disabled

      set side "" ; #-- telescope non equatorial

      #--   execute
      if {$private(parkAuto) == 0} {

         set modeNo 9 ; #--  utilisateur
         $w.coords.mode current $modeNo
         set private(parkaz) $private(azTel)
         set private(parkelev) $private(elevTel)
         if {$german == 1} {
            lassign [getGermanSide] -> -> private(parkside)
         }

         #--   refraichit le panneau Telescope
         updateTlscp $private(ra) $private(dec) $private(parkMode)

      } else {

         #--   autres positions avec un GOTO
         set modeNo [$w.coords.mode current]
         set parkside [string map [list 0 W 1 E] [$w.coords.parkside current]]

         #--   met a jour les coordonnees
         refreshCoordsJ2000 $private(parkaz) $private(parkelev) ALTAZ

         #--   refraichit le panneau Telescope
         updateTlscp $private(ra) $private(dec) $private(parkMode)

         #--   execute un GOTO non bloquant
         if {[catch {::telescope::goto [list $private(ra) $private(dec)] 0} ErrInfo]} {

            ::console::affiche_resultat "erreur de parquage : $ErrInfo\n"

            set private(park) 0
            set private(parkAuto) 0

            #--   desinhibe les widgets appropries
            configParkWidget $w $modeNo $german !disabled

            return
         }
      }

      #--   arrete les moteurs
      tel$telNo radec motor off
      #--   bascule vers Suivi Off
      set audace(telescope,controle) "$caption(telescope,suivi_arret)"

      #--   actualise les coordonnees du telescope
      lassign [tel$telNo radec coord -equinox J2000.0] targetRa targetDec

      #--   confirme dans la console
      if {$german == 1} {
         lassign [getGermanSide] -> sideIndex side
         set conf($private(product),park) [list $modeNo $private(parkaz) $private(parkelev) $sideIndex]
         confirmPark park $private(telname) $private(parkMode) $private(parkaz) $private(parkelev) $targetRa $targetDec $side
      } else {
         set conf($private(product),park) [list $modeNo $private(parkaz) $private(parkelev)]
         confirmPark park $private(telname) $private(parkMode) $private(parkaz) $private(parkelev) $targetRa $targetDec
      }

      set private(park) 0
      set private(parkAuto) 0

      #--   desinhibe les widgets appropries
      configParkWidget $w $modeNo $german !disabled
   }

   #------------------------------------------------------------
   #  buildPark
   #  Construit la ligne du deparquage
   #  Parametre : (onglet tlscp)
   #------------------------------------------------------------
   proc buildPark { w } {
      variable private
      global audace caption conf

       #--   initialisation des variables
      lassign [list 0 0.0 90.0 0 0 0 "00" "00"] private(unpark) \
         private(parkaz) private(parkelev) \
         private(park) private(parkAuto) private(parkHr) private(parkMin)

      #------------- frame des actions -----------------------

      set w1 [frame $w.action1]
      ttk::checkbutton $w1.unpark -variable ::collector::private(unpark) \
         -offvalue 0 -onvalue 1 -text "$caption(collector,unpark)" \
         -command "::collector::doUnPark"
      pack $w1.unpark -side left -padx 2

      #------------- frame des coordonnnees -----------------------

      set w2 [frame $w.coords]

      label $w2.lab_coords -text "$caption(collector,parkOptAltAz)"
      set values "$caption(collector,parkModes)"
      set width [expr {int([::tkutil::lgEntryComboBox $values]*0.8)}]
      ttk::combobox $w2.mode -width $width -justify center -state normal \
         -textvariable ::collector::private(parkMode) -values $values
      bind $w2.mode <<ComboboxSelected>> "::collector::cmdParkMode $w2"

      label $w2.lab_az -text "$caption(collector,parkaz)"
      ttk::entry $w2.parkaz -textvariable ::collector::private(parkaz) \
         -width 6 -justify right
      bind $w2.parkaz <Leave> {::collector::testPattern parkaz}

      label $w2.lab_elev -text "$caption(collector,parkelev)"
      ttk::entry $w2.parkelev -textvariable ::collector::private(parkelev) \
         -width 6 -justify right
      bind $w2.parkelev <Leave> {::collector::testPattern parkelev}

      set values "$caption(collector,parkOptSide)"
      set width [::tkutil::lgEntryComboBox $values]
      ttk::combobox $w2.parkside -textvariable ::collector::private(parkside) \
         -width $width -justify center -state normal -values $values

      pack $w2.lab_coords $w2.mode $w2.lab_az $w2.parkaz \
         $w2.lab_elev $w2.parkelev $w2.parkside -side left -padx 2

      #--   initialisation des variables
      $w2.mode current 6      ; #--  zenith
      $w2.parkside current 0  ; #--  tube cote ouest

      #------------- frame du garage -----------------------

      set w3 [frame $w.action3]

      ttk::checkbutton $w3.park -variable ::collector::private(park) \
         -offvalue 0 -onvalue 1 -text "$caption(collector,park)" \
         -command "::collector::doPark"

      ttk::checkbutton $w3.timer -variable ::collector::private(parkAuto) \
         -offvalue 0 -onvalue 1 -text "$caption(collector,timer)" \
         -command "::collector::configTimeListener"

      for {set i 0} {$i < 24} {incr i} {
         lappend lhr [format "%02.f" $i]
      }
      lappend lhr "00" $lhr
      ttk::spinbox $w3.parkhr -textvariable ::collector::private(parkHr) \
         -width 2 -state readonly -values $lhr -wrap 1
      label $w3.lab_parkhr -text "$caption(collector,hr)"

      for {set i 0} {$i < 60} {incr i} {
         lappend lmin [format "%02.f" $i]
      }
      ttk::spinbox $w3.parkmin -textvariable ::collector::private(parkMin) \
         -width 2 -state readonly -values $lmin -wrap 1
      label $w3.lab_parkmin -text "$caption(collector,min)"

      pack $w3.lab_parkmin $w3.parkmin $w3.lab_parkhr $w3.parkhr \
         $w3.timer $w3.park -in $w3 -anchor w -side right -padx 2 -fill x

   }

   #------------------------------------------------------------
   #  cmdParkMode
   #  Configure les coordonnees AltAZ
   #  Commande de la combobox de choix du mode
   #  Parametre : (onglet tlscp).coords
   #------------------------------------------------------------
   proc cmdParkMode { w } {
      variable private

      set latitude [lindex $private(gps) 3]
      set modeNo [$w.mode current]
      set sideIndex [$w.parkside current]
      set german $private(german)
      set az 0.0
      set elev 0.0

      switch -exact $modeNo {
         0  {  set elev 1.0 ; #-- Horizon Sud  erreur "below horizon" si elev = 0}
         1  {  set az 270.0 ; set elev 7.0 ; #-- Horizon Est erreur "below horizon" si elev < 7}
         2  {  set az 90.0 ; #-- Horizon Ouest Ok }
         3  {  set az 180.0 ; #-- Horizon Nord Ok}
         4  {  set elev $latitude ; #-- Equateur Sud Ok }
         5  {  set az 180.0 ; set elev [expr {-90+$latitude}] ; #-- Equateur Nord }
         6  {  set elev 90 ; #-- Zenith Ok }
         7  {  set az 180.0 ; set elev $latitude ; #-- Pôle Nord Ok}
         8  {  set az 180.0 ; set elev -$latitude ; #-- Pôle Sud}
         9  {  #--   choix Utilisateur
               if {[info exists conf($private(product),park)] == 1} {
                  set data $conf($product,park)
               } else {
                  #--   valeurs par defaut
                  set data [list 9 0.0 0.0 0]
                  if {$german == 1} {
                     lappend data 1
                  }

               }
               lassign $data modeNo az elev sideIndex
            }
      }

      set private(parkaz) $az
      set private(parkelev) $elev

      if {$german == 1} {
         $w.parkside current $sideIndex
      }

      if {$modeNo != 9} {
         set state disabled
      } else {
         set state !disabled
      }
      $w.parkaz state $state
      $w.parkelev state $state
   }

   #------------------------------------------------------------
   #  configTimeListener
   #  Active/arrete le listener du minuteur
   #  Commande du bouton de programmation du parquage 'Auto'
   #------------------------------------------------------------
   proc configTimeListener { {visuNo 1} } {
      variable private

      if {$private(parkAuto) == 0} {
         set choice remove
      } else {
          set choice add
      }

      ::confVisu::${choice}TimeListener $visuNo "::collector::doPark"
   }

  #------------------------------------------------------------
  #  updateTlscp
  #  Met a jour le panneau Telescope, s'il existe
  #  Parametres :
  #      targetRa (hms)
  #      targetDec (dms)
  #      position (litterale, ex Zénith)
  #------------------------------------------------------------
  proc updateTlscp { targetRa targetDec position } {

      #--   identifie le N° de la visu contenant le panneau
      set visuNo [::confVisu::getToolVisuNo ::tlscp]
      if {$visuNo ne ""} {
         #-- positionne la combobox de choix du catalogue sur 'Coord'
         .audace.tool.tlscp.fra2.catalogue.list setvalue @0
         set ::tlscp::private($visuNo,nomObjet)  "$position"
         set ::tlscp::private($visuNo,raObjet)   "$targetRa"
         set ::tlscp::private($visuNo,decObjet)  "$targetDec"
         set ::tlscp::private($visuNo,equinoxObjet) "J2000.0"
      }
   }

   #------------------------------------------------------------
   #  confirmPark
   #  Edite un message de confirmation dans la Console
   #  Les coordonnees RADEC sont en J2000.0
   #  Parametres :
   #     action      : initialisater, garer
   #     telname     : nom du telescope
   #     parkMode    : position d'initialisation ou de garage
   #     parkaz      : azimuth (degres)
   #     parkelev    : elevation (degrees)
   #     targetRa    : AD (hms)
   #     targetDec   : DEC (dms)
   #     optionnels  : equinox et mountside {E|W}
   #------------------------------------------------------------
   proc confirmPark {  action telname parkMode parkaz parkelev targetRa targetDec {equinox J2000.0} { mountside ?} } {
      global audace caption

      set msg "$caption(collector,$action) $telname \
        [format $caption(collector,msgPark) \
         $audace(hl,format,hmsint) $parkMode \
         $parkaz $parkelev \
         $targetRa $targetDec $equinox]"

      if {$mountside ne "?"} {
         append msg " $mountside"
      }
      ::console::affiche_resultat "\n$msg\n"
   }

   #------------------------------------------------------------
   #  configParkWidget
   #  Gere l'etat des widgets
   #  Parametres :
   #      onglet tlscp                 : w
   #      position                     : modeNo (0...9)
   #      monture allemande german     : {0|1}
   #      etat inhibe ou non           : state {disabled|!disabled}
   #------------------------------------------------------------
   proc configParkWidget { w modeNo german state } {

      set children [list action1.unpark coords.mode action3.park action3.timer \
         action3.parkhr action3.parkmin]

      if {$modeNo == 9} {
         #-- desinhibe seulement dans le mode Utilisateur
         lappend children coords.parkaz coords.parkelev
      }

      if {$german == 1} {
         #-- n'existe que pour une monture allemande
         lappend children coords.parkside
      }

      foreach child $children {
         $w.$child state $state
      }
   }

