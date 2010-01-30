   #########################################################################
   #--   Au lancement collecte les donnees sur la camera et les memorise   #
   #########################################################################
   proc searchInfoDslr {} {
      global conf audace panneau caption

      #--   raccourci
      set camNo $panneau(remotectrl,camNo)

      #--   desactive le systeme_service
      eval "send \{cam$camNo systemservice 0\}"

      #--   fixe drivemode
      eval "send \{cam$camNo drivemode 0\}"

      #--   ouvre la liste des types de declenchement
      set panneau(remotectrl,longueposeLabels) \
         [ list "$caption(remotectrl,longuepose,usb)" ]

      #--   memorise l'etat
      set panneau(remotectrl,status) [ list "0" ]

      #--   si la camera est connectee en mode longue pose
      if [ eval "send \{cam$camNo longuepose\}" ] {

         #--   complete la liste des types de declenchement
         lappend panneau(remotectrl,longueposeLabels) \
            "$caption(remotectrl,longuepose,lp)"

         #--   memorise l'etat
         set panneau(remotectrl,status) [ list "1" ]
      }

      #-- ajoute la carte CF à la liste des stockages
      set panneau(remotectrl,stockLabels) \
         [ list "$caption(remotectrl,stock,cf)" ]

      #--   complete l'etat
      lappend panneau(remotectrl,status) "0"

      #--   liste les autres modes de stockage
      if ![ TestEntier $panneau(remotectrl,path_img) ] {

         #--   teste l'acces au lecteur reseau
         set file [ file join $panneau(remotectrl,path_img) test.log ]
         if ![ catch {
            set fd [ open $file w+ ]
            puts $fd "test"
            close $fd
            file delete $file
         } msg ] {

            lappend panneau(remotectrl,stockLabels) \
               "$caption(remotectrl,drive) $panneau(remotectrl,path_img)"

         } else {

            tk_messageBox -title $caption(remotectrl,attention)\
               -icon error -type ok -message $caption(remotectrl,no_acces)
         }

      } else {

         #--   mode FTP
         lappend panneau(remotectrl,stockLabels) \
            "$caption(remotectrl,stock,backyard)" \
            "$caption(remotectrl,stock,home&backyard)" \
            "$caption(remotectrl,stock,home)"
      }

      #--   finalise l'etat
      if { [ llength $panneau(remotectrl,stockLabels) ] > "1" } {
           set panneau(remotectrl,status) \
            [ lreplace $panneau(remotectrl,status) end end "1" ]
      }

      #--   liste les formats possibles
      set panneau(remotectrl,qualityLabels) \
         [ eval "send \{cam$camNo quality list\}" ]

      #--   liste les modes Rafale (bracketing)
      set panneau(remotectrl,bracketLabels) \
         [ list "$caption(remotectrl,bracket,one)" \
            "$caption(remotectrl,bracket,serie)" \
            "$caption(remotectrl,bracket,rafale)" ]

      #--   liste les pas du bracketing
      set panneau(remotectrl,stepLabels) \
         [ list "+6" "+5" "+4" "+3" "+2" "+1" \
            0 "-1" "-2" "-3" "-4" "-5" "-6" ]

      #--   liste les vitesses standards
      set panneau(remotectrl,exptimeLabels) [ list "30" "25" "20" "15" "13" \
         "10" "8" "6" "5" "4" "3.2" "2.5" "2.0" "1.6" "1.3" \
         "1.0"  "0.8" "0.6" "0.5" "0.4" "0.3" "1/4" "1/5" "1/6" "1/8" \
         "1/10" "1/13" "1/15" "1/20" "1/25" "1/30" "1/40" "1/50" "1/60" "1/80" \
         "1/100" "1/125" "1/160" "1/200" "1/250" "1/320" "1/400" "1/500" "1/640" "1/800" \
         "1/1000" "1/1250" "1/1600" "1/2000" "1/2500" "1/3200" "1/4000" "1/5000" "1/6400" "1/8000" ]

      set panneau(remotectrl,exptimeValues) [ list "30" "25" "20" \
         "15" "13" "10" "8" "6" "5" "4" "3.2" "2.5" "2" "1.6" "1.3" \
         "1" "0.8" "0.6" "0.5" "0.4" "0.3" "0.25" "0.2" "0.16667" "0.125" \
         "0.1" "0.076923" "0.06667" "0.05" "0.04" "0.03333" "0.025" "0.02" \
         "0.01667" "0.0125" "0.01" "0.008" "0.00625" "0.005" "0.004" \
         "0.003125" "0.0025" "0.002" "0.0015625" "0.00125" ".001" "0.0008" \
         "0.000625" "0.0005" "0.0004" "0.0003125" "0.00025" "0.0002" "0.00015625" "0.000125" ]

      apnBuildIF
   }

   ############################################################################
   #--   Initialise les variables                                             #
   ############################################################################
   proc initPar {} {
      global panneau
      variable Dslr

      #--  initialise les variables saisies
      lassign { "" "1" "0" "0" "0" " " } ::remotectrl::nom \
         ::remotectrl::nb_poses ::remotectrl::delai ::remotectrl::intervalle \
         panneau(remotectrl,intervalle_mini) panneau(remotectrl,action)

      #--   selectionne le mode de declenchement de niveau le plus eleve
      #set panneau(remotectrl,longuepose) \
      #   [ lindex $panneau(remotectrl,longueposeLabels) end ]

      #--   selectionne le mode de stockage de niveau le plus eleve
      set panneau(remotectrl,stock) \
         [ lindex $panneau(remotectrl,stockLabels) end ]

      #--   selectionne le format actuel d'image
      set panneau(remotectrl,quality) \
         [ eval "send \{cam$panneau(remotectrl,camNo) quality\}" ]

      #--   indique le format (jpeg ou fits)
      ::remotectrl::configFormat

      #--   selectionne le mode de prise de vue 'Une image"
      set panneau(remotectrl,bracket) \
         [ lindex $panneau(remotectrl,bracketLabels) 0 ]

      #-- selectionne le nombre de pas "0"
      set panneau(remotectrl,step) \
         [ lindex $panneau(remotectrl,stepLabels) 6 ]
   }

   ############################################################################
   #--   Module de construction des boutons de menu avec les commandes        #
   #  appelee par ApnBuildIF                                                  #
   ############################################################################
   proc buildMenuButton { var } {
      global panneau caption
      variable Dslr

      #--   raccourcis
      set data $panneau(remotectrl,${var}Labels)
      set camNo $panneau(remotectrl,camNo)

      menubutton $Dslr.$var -menu $Dslr.$var.m \
         -relief raised -width 10 -borderwidth 2 \
         -textvar panneau(remotectrl,$var)
      menu $Dslr.$var.m -tearoff 0

      #--   specifie les commandes associees a chaque item du menu
      foreach label $data {
         set indice [ lsearch $data $label ]
         switch -exact $var {
          "bracket"     {  switch $indice {
                              "0"   {  set cmd "::remotectrl::configImg" }
                              "1"   {  set cmd "::remotectrl::configSerie" }
                              "2"   {  set cmd "::remotectrl::configRafale" }
                           }
                        }
          "longuepose"  {  switch $indice {
                              "0"  {  set cmd "::remotectrl::switchLonguepose $camNo 0" }
                              "1"  {  set cmd "::remotectrl::switchLonguepose $camNo 1" }
                           }
                        }
          "quality"     {  set cmd "eval \"send \{cam$camNo quality $label\}\" ;
                           ::remotectrl::configFormat" }
          "step"        {  set cmd "::remotectrl::test_rafale" }
          "stock"       {  switch $indice {
                              "0"     { set cmd "::remotectrl::switchStorage $camNo 0" }
                              default { set cmd "::remotectrl::switchStorage $camNo 1" }
                           }
                        }
         }

         $Dslr.$var.m add radiobutton -label $label -indicatoron "1" \
            -value $label -variable panneau(remotectrl,$var) -command $cmd
         }
   }

   #########################################################################
   #--   Configure le panneau pour une image seule                         #
   #  appelee par le bouton de mode de prise de vue et par setWindowState  #
   #########################################################################
   proc configImg { } {
      variable Dslr

      configStock
      configLonguepose
      foreach child { step nb_poses intervalle } {
         $Dslr.$child configure -state disabled
      }
   }

   #########################################################################
   #--   Configure le panneau pour une serie d'images                      #
   #  appelee par le bouton de mode de prise de vue et par setWindowState  #
   #########################################################################
   proc configSerie { } {
      variable Dslr

      configStock
      configLonguepose
      foreach child { step nb_poses } {
         $Dslr.$child configure -state normal
      }
   }

   #########################################################################
   #--   Configure le panneau pour une rafale d'images                     #
   #  appelee par le bouton de mode de prise de vue et par setWindowState  #
   #########################################################################
   proc configRafale { } {
      variable Dslr

      configStock
      configLonguepose
      foreach child { step nb_poses } {
         $Dslr.$child configure -state normal
      }
   }

   #########################################################################
   #--   Configure le nom et la visualisation                              #
   #########################################################################
   proc configNomSee { etat } {
      global panneau caption
      variable  Dslr

      if { $etat == "disabled" } {
         set ::remotectrl::nom ""
         set ::remotectrl::see "0"
      }
      foreach child { nom intervalle see } {
         $Dslr.$child configure -state $etat
      }
   }

   #########################################################################
   #--   Configure le bouton Stock                                         #
   #########################################################################
   proc configStock {} {
      global panneau caption
      variable Dslr

      set l [ llength $panneau(remotectrl,stockLabels) ]

      #--   si carte CF seule
      if { $l <= "1" } {

         #--   desactive les autres modes de stockage
         $Dslr.stock.m invoke 0
         $Dslr.stock configure -state disabled

      } else {

         #--   sinon tous les modes sont presents
         #--   libere le bouton
         $Dslr.stock configure -state normal

         #--   si ce n'est pas le mode rafale
         if { $panneau(remotectrl,bracket) != "$caption(remotectrl,bracket,rafale)" } {

            #--   desinhibe longuepose s'il existe
            if { [ llength $panneau(remotectrl,longueposeLabels) ] == "2" } {
               $Dslr.longuepose.m entryconfigure 1 -state normal
            }

            #--   adopte le niveau de stockage le plus eleve
            if { $panneau(remotectrl,stock) != $caption(remotectrl,stock,cf) \
               && [ lindex $panneau(remotectrl,status) 1 ] == "0" } {

                $Dslr.stock.m invoke end
            }

            #--   les autres entrees de stock seront activees
            set etat normal

         } else {

            #--   en mode rafale active la carte CF
            $Dslr.stock.m invoke 0

            #--   les autres entrees de stock seront desactivees
            set etat disabled

            #--   selectionne le mode USB
            $Dslr.longuepose.m invoke 0

            #--   inhibe longuepose s'il existe
            if { [ llength $panneau(remotectrl,longueposeLabels) ] == "2" } {
               $Dslr.longuepose.m entryconfigure 1 -state disabled
            }
         }

         #--   active/desactive les autres entrees que(0)du menu
         for { set i 1 } { $i < $l } { incr i } {
            $Dslr.stock.m entryconfigure $i -state $etat
         }
      }
   }

   #########################################################################
   #--   Configure le bouton USB/Longuepose                                #
   #########################################################################
   proc configLonguepose {} {
      global panneau caption
      variable Dslr

      if { [ llength $panneau(remotectrl,longueposeLabels) ] == "1" } {

         #--   commute vers USB
         $Dslr.longuepose.m invoke 0

         #--   desactive le bouton
         $Dslr.longuepose configure -state disabled

      } else {

         #--   autorise le bouton
         $Dslr.longuepose configure -state normal

         #--   active/desactive le mode longuepose
         if { $panneau(remotectrl,bracket) != "$caption(remotectrl,bracket,rafale)" } {

            #--   si ce n'est pas une rafale, longuepose est desinhibe
            $Dslr.longuepose.m entryconfigure 1 -state normal

         } else {

            #--   une rafale : inhibe longuepose
            $Dslr.longuepose configure -state disabled
         }

         #--   indentifie la selection
         set k [ lsearch $panneau(remotectrl,longueposeLabels) \
            $panneau(remotectrl,longuepose) ]
         switchLonguepose $panneau(remotectrl,camNo) $k
      }
   }

   #-- pour commuter USB/Longuepose
   proc switchLonguepose { camNo ul } {
      global panneau
      variable Dslr

      set etat_anterieur [ lindex $panneau(remotectrl,status) 0 ]
      set longueur_liste [ llength [$Dslr.exptime cget -values] ]

      if { $etat_anterieur != $ul } {
         set status [ eval "send \{cam$camNo longuepose $ul\}" ]
         #--   memorise le nouvel etat
         set panneau(remotectrl,status) [ lreplace \
            $panneau(remotectrl,status) 0 0 "$status" ]
      }

      if { $etat_anterieur != $ul || $longueur_liste == "0" } {
         switch $ul {
            "0"   {  #--   met en place la liste standard
                     $Dslr.exptime configure -editable 0 \
                        -values "$panneau(remotectrl,exptimeLabels)" -height 10
                     #--   selectionne 1 seconde
                     $Dslr.exptime setvalue @15
                  }
            "1"   {  #--   met en place la liste ouverte
                     $Dslr.exptime configure -editable 1 -values "31" -height 1
                     #--   selectionne 31
                     $Dslr.exptime setvalue @0
                  }
         }

         #--   transfert la valeur
         set ::remotectrl::exptime $panneau(remotectrl,time)
         update
      }
    }

   #--   pour configurer le format et l'extension
   proc configFormat { } {
      global panneau conf

      if { $panneau(remotectrl,quality) == "RAW" } {
         set panneau(remotectrl,format) "fits"
         set panneau(remotectrl,extension) "$conf(extension,defaut)"
      } else {
         set panneau(remotectrl,format) "jpeg"
         set panneau(remotectrl,extension) ".jpg"
      }
   }

   #--   pour commuter la memoire
   proc switchStorage { camNo sto } {
      global panneau

      set etat_anterieur [ lindex $panneau(remotectrl,status) 1 ]

      if { $etat_anterieur != $sto } {
         eval "send \{cam$camNo autoload $sto\}"
         set l [ expr { 1 - $sto } ]
         eval "send \{cam$camNo usecf $l\}"
         #--   memorise le nouvel etat
         set panneau(remotectrl,status) \
            [ lreplace $panneau(remotectrl,status) end end "$sto" ]
      }
      if { [ lindex $panneau(remotectrl,status) 1 ] == "0" } {
         configNomSee disabled
      } else {
         configNomSee normal
      }
   }

   ######################################################################
   #--   Gere l'etat des widgets lies a DSLR                            #
   ######################################################################
   proc setWindowState { state } {
      global panneau
      variable Dslr
      variable This

      set children [ list longuepose stock quality step bracket test \
         nom nb_poses exptime delai intervalle see ]

      foreach child $children {
         $Dslr.$child configure -state $state
      }
      $This.fra6.but1 configure -state $state

      if { $state == "normal" } {
         set k [ lsearch $panneau(remotectrl,bracketLabels) $panneau(remotectrl,bracket) ]
         switch -exact  $k {
            "0"   { configImg }
            "1"   { configSerie }
            "2"   { configRafale }
         }
      }
   }

   ######################################################################
   #--   Cree une entree avec un label                                  #
   #  appelee par ApnBuildIF                                            #
   #  parametres : nom descendant                                       #
   ######################################################################
   proc buildLabelEntry { child } {
      global caption
      variable Dslr

      LabelEntry $Dslr.$child -label $caption(remotectrl,$child) \
         -textvariable ::remotectrl::$child -labelanchor w -labelwidth 8 \
         -borderwidth 1 -relief flat -padx 2 -justify right \
         -width 8 -relief sunken
      bind $Dslr.$child <Leave> [ list ::remotectrl::test_$child ]
   }

   ######################################################################
   #--   Decompteur de secondes                                         #
   #  parametre : nom de la variable a decompter (delai ou intervalle)  #
   ######################################################################
   proc delay { var } {
      global panneau

      while { [ set $var ] != "0" } {
            after 1000
            incr $var "-1"
            update
      }
   }

