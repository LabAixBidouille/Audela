#
# Fichier : rmtctrlutil.tcl
# Description : Script pour la configuration de l'outil
# Auteur : Raymond ZACHANTKE
# Mise a jour $Id: rmtctrlutil.tcl,v 1.3 2010-02-14 17:58:49 robertdelmas Exp $
#

   #########################################################################
   #--   Au lancement collecte les donnees sur la camera et les memorise   #
   #########################################################################
   proc searchInfoDslr {} {
      global panneau caption

      #--   raccourci
      set camNo $panneau(remotectrl,camNo)

      #--   fixe drivemode a 0
      send "cam$camNo drivemode 0"

      #--   ouvre la liste des types de declenchement
      set panneau(remotectrl,poseLabels) [ list "<30" ]

      #--   memorise l'etat
      set panneau(remotectrl,status) [ list "0" ]

      #--   si la camera est connectee en mode longue pose
      if [ send "cam$camNo longuepose" ] {

         #--   complete la liste des types de declenchement
         lappend panneau(remotectrl,poseLabels) ">30"

         set panneau(remotectrl,linkNo) [ send "cam$camNo longueposelinkno" ]
         set panneau(remotectrl,bitNo) [ send "cam$camNo longueposelinkbit" ]
         set panneau(remotectrl,startvalue) [ send "cam$camNo longueposestartvalue" ]
         set panneau(remotectrl,stopvalue) [ send "cam$camNo longueposestopvalue" ]

         #--   memorise l'etat
         set panneau(remotectrl,status) [ list "1" ]
      }

      #-- ajoute la carte CF à la liste des stockages
      set panneau(remotectrl,stockLabels) \
         [ list "$caption(remotectrl,stock,cf)" ]

      #--   complete l'etat
      lappend panneau(remotectrl,status) "1"

      #--   liste les autres modes de stockage
      if ![ TestEntier $panneau(remotectrl,path_img) ] {

         #--   teste l'acces au lecteur reseau
         set file [ file join $panneau(remotectrl,path_img) test.log ]
         set err [ writeLog $file "test" ]
         if { $err == "0" } {

            #--   ajoute le lecteur reseau a la liste
            lappend panneau(remotectrl,stockLabels) \
               "$caption(remotectrl,drive) $panneau(remotectrl,path_img)"

            #--   detruit le fichier test
            file delete $file

         } else {

            #--   message de non acces
            avertiUser "no_acces"
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
            [ lreplace $panneau(remotectrl,status) end end "0" ]
      }

      #--   liste les formats possibles
      set panneau(remotectrl,qualityLabels) [ send "cam$camNo quality list" ]

      #--   liste les modes de prise de vue
      set panneau(remotectrl,bracketLabels) \
         [ list "$caption(remotectrl,bracket,one)" \
            "$caption(remotectrl,bracket,serie)" \
            "$caption(remotectrl,bracket,continu)" ]

      #--   ajoute le mode Rafale si la longuepose existe
      if { [ llength $panneau(remotectrl,poseLabels) ] == "2" } {
         lappend panneau(remotectrl,bracketLabels) "$caption(remotectrl,bracket,rafale)"
      }

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

   ###################################################################
   #-- Complete le panneau d'acquisition                             #
   ###################################################################
   proc apnBuildIF {} {
      global panneau caption
      variable Dslr
      variable This

      #--   changement de variable
      set Dslr $This.fra6.dslr

      #--   le frame cantonnant le DSLR
      frame $Dslr -borderwidth 1 -relief sunken
      pack $Dslr
      ::blt::table $Dslr

      #---   construit les menubutton
      foreach var { stock quality step bracket pose } {
         buildMenuButton $var
      }
      $Dslr.step configure -textvar "" -text $caption(remotectrl,step) -width 2
      $Dslr.pose configure -width 2

      #--   label pour afficher le format de l'image
      label $Dslr.format -textvariable panneau(remotectrl,format) \
         -width 4 -borderwidth 1

      #--   construit le bouton 'Test'
      button $Dslr.test -relief raised -width 10 -borderwidth 2 \
         -text $caption(remotectrl,test) -command "::remotectrl::testTime"

      #--   construit les entrees de donnees
      foreach var { nom nb_poses delai intervalle } {
         buildLabelEntry $var
      }
      $Dslr.nom configure -labelwidth 6 -width 10
      bind $Dslr.nom <Leave> { ::remotectrl::test_bracketing ; ::remotectrl::test_nom }

      #--   la combobox pour le temps de pose
      ComboBox $Dslr.exptime -borderwidth 1 -width 8 -relief sunken \
         -height 10 -justify center \
         -textvariable panneau(remotectrl,time) \
         -modifycmd "::remotectrl::test_bracketing ; ::remotectrl::test_exptime"
      bind $Dslr.exptime <Leave> { ::remotectrl::test_bracketing ; ::remotectrl::test_exptime }

      #--   checkbutton pour la visualisation
      checkbutton $Dslr.see -text $caption(remotectrl,see) \
         -indicatoron "1" -onvalue "1" -offvalue "0" \
         -variable ::remotectrl::see

      #--   checkbutton pour le fenetrage
      checkbutton $Dslr.wind -text $caption(remotectrl,wind) \
         -indicatoron "1" -onvalue "1" -offvalue "0" \
         -variable ::remotectrl::wind \
         -command "::remotectrl::getWindow"

      #--   label pour afficher les etapes
      label $Dslr.state -textvariable panneau(remotectrl,action) \
         -width 14 -borderwidth 2 -relief sunken

      #--   packaging des widgets
      ::blt::table $Dslr \
         $Dslr.stock 0,0 -cspan 2 \
         $Dslr.format 1,0 \
         $Dslr.quality 1,1 \
         $Dslr.step 2,0 \
         $Dslr.bracket 2,1 \
         $Dslr.test 3,0 -cspan 2 \
         $Dslr.state 4,0 -cspan 2 \
         $Dslr.nom 5,0 -cspan 2 \
         $Dslr.nb_poses 6,0 -cspan 2 \
         $Dslr.pose 7,0 \
         $Dslr.exptime 7,1 \
         $Dslr.delai 8,0 -cspan 2 \
         $Dslr.intervalle 9,0 -cspan 2 \
         $Dslr.see 10,0 -cspan 2 \
         $Dslr.wind 11,0 -cspan 2
         ::blt::table configure $Dslr r* -pady 2

      #--   ajoute les bulles d'aide
      foreach child { step test nom nb_poses pose delai wind } {
         DynamicHelp::add $Dslr.$child -text $caption(remotectrl,help$child)
      }

      initPar

      #--   demarre sur la configuration 'Une image'
      configImg

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $Dslr
   }

   ############################################################################
   #--   Initialise les variables                                             #
   ############################################################################
   proc initPar {} {
      global audace panneau caption

      lassign { "" "0" "0" "0" " " } ::remotectrl::nom ::remotectrl::delai \
         panneau(remotectrl,intervalle_mini) panneau(remotectrl,test) \
         panneau(remotectrl,action)

      #--   selectionne le mode de stockage de niveau le plus eleve
      set panneau(remotectrl,stock) [ lindex $panneau(remotectrl,stockLabels) end ]

      #--   selectionne le format actuel d'image
      set panneau(remotectrl,quality) [ send "cam$panneau(remotectrl,camNo) quality" ]

      #--   indique le format (jpeg ou fits)
      ::remotectrl::configFormat

      #--   selectionne le mode de prise de vue 'Une image"
      set panneau(remotectrl,bracket) [ lindex $panneau(remotectrl,bracketLabels) 0 ]

      #--   selectionne le nombre de pas "0"
      set panneau(remotectrl,step) [ lindex $panneau(remotectrl,stepLabels) 6 ]

       #--   selectionne le mode de declenchement de niveau le plus eleve
      set l [ llength  $panneau(remotectrl,poseLabels) ]
      incr l "-1"
      set panneau(remotectrl,pose) [ lindex $panneau(remotectrl,poseLabels) $l ]

      #--   selectionne la gamme de temps d'exposition
      configTimeScale $l

      #--   initalise le fichier log
      set rep "$audace(rep_images)"
      if ![ TestEntier $panneau(remotectrl,path_img) ] {
          set rep $panneau(remotectrl,path_img)
      }
      set nom "DSLR remotectrl "
      set date [clock format [clock seconds] -format "%A %d %B %Y"]
      append nom $date ".log"
      set panneau(remotectrl,log) [ file join $rep $nom ]
      writeLog $panneau(remotectrl,log) "$caption(remotectrl,ouvsess)"
   }

   ############################################################################
   #--   Module de construction des boutons de menu avec les commandes        #
   #  appelee par ApnBuildIF                                                  #
   ############################################################################
   proc buildMenuButton { var } {
      global panneau
      variable Dslr

      #--   raccourcis
      set data $panneau(remotectrl,${var}Labels)
      set camNo $panneau(remotectrl,camNo)

      menubutton $Dslr.$var -menu $Dslr.$var.m -relief raised \
         -width 10 -borderwidth 2 -textvar panneau(remotectrl,$var)
      menu $Dslr.$var.m -tearoff 0

      #--   specifie les commandes associees a chaque item du menu
      foreach label $data {
         set indice [ lsearch $data $label ]
         switch -exact $var {
          "bracket"  {  switch $indice {
                           "0"   {  set cmd "::remotectrl::configImg ;
                                    set panneau(remotectrl,test) 0"
                                 }
                           "1"   {  set cmd "::remotectrl::configSerie ;
                                    set panneau(remotectrl,test) 0"
                                 }
                           "2"   {  set cmd "::remotectrl::configContinu" }
                           "3"   {  set cmd "::remotectrl::configRafale" }
                        }
                     }
          "pose"     {  switch $indice {
                              "0"  {  set cmd "::remotectrl::switchExpTime 0" }
                              "1"  {  set cmd "::remotectrl::switchExpTime 1" }
                           }
                        }
          "quality"     {  set cmd "send \"cam$camNo quality $label\" ;
                              ::remotectrl::configFormat"
                        }
          "step"        {  set cmd "::remotectrl::test_bracketing" }
          "stock"       {  switch $indice {
                              "0"     { set cmd "::remotectrl::switchStock 1" }
                              default { set cmd "::remotectrl::switchStock 0" }
                           }
                        }
         }

         $Dslr.$var.m add radiobutton -label $label -indicatoron "1" \
            -value $label -variable panneau(remotectrl,$var) -command $cmd
         }
   }

   ######################################################################
   #--   Gere l'etat des widgets lies a DSLR                            #
   ######################################################################
   proc setWindowState { state } {
      global panneau
      variable Dslr
      variable This

      set children [ list stock quality step bracket test \
         nom nb_poses pose exptime delai intervalle see wind ]

      foreach child $children {
         $Dslr.$child configure -state $state
      }
      $This.fra6.but1 configure -state $state

      if { $state == "normal" } {
         set k [ lsearch $panneau(remotectrl,bracketLabels) $panneau(remotectrl,bracket) ]
         switch -exact  $k {
            "0"   { configImg }
            "1"   { configSerie }
            "2"   { configContinu }
            "3"   { configRafale }
         }
      }
   }

   #########################################################################
   #--   Configure le panneau pour une image seule                         #
   #  appelee par le bouton de mode de prise de vue et par setWindowState  #
   #########################################################################
   proc configImg { } {
      global panneau
      variable Dslr

      configStock
      configPose
      configIntervalle "1"

      foreach child { test nom } {
         $Dslr.$child configure -state normal
      }

      set ::remotectrl::nb_poses "1"
      foreach child { step nb_poses } {
         $Dslr.$child configure -state disabled
      }
   }

   #########################################################################
   #--   Configure le panneau pour une serie d'images                      #
   #  appelee par le bouton de mode de prise de vue et par setWindowState  #
   #########################################################################
   proc configSerie { } {
      global panneau
      variable Dslr

      configStock
      configPose
      configIntervalle "2"

      set ::remotectrl::nb_poses "2"
      foreach child { test nom nb_poses } {
         $Dslr.$child configure -state normal
      }

      set etat "normal"
      if { $panneau(remotectrl,pose) == ">31" } {
         set etat "disabled"
      }
      $Dslr.step configure -state $etat
   }

   #########################################################################
   #--   Configure le panneau pour une serie continue d'images             #
   #  appelee par le bouton de mode de prise de vue et par setWindowState  #
   #########################################################################
   proc configContinu { } {
      variable Dslr

      configStock
      configPose
      configIntervalle "3"

      set ::remotectrl::nb_poses "2"
      foreach child { step nb_poses } {
         $Dslr.$child configure -state normal
      }
      foreach child { test nom } {
         $Dslr.$child configure -state disabled
      }
   }

   #########################################################################
   #--   Configure le panneau pour une rafale d'images                     #
   #  appelee par le bouton de mode de prise de vue et par setWindowState  #
   #########################################################################
   proc configRafale { } {
      variable Dslr

      configStock
      configPose
      configIntervalle "4"

      set ::remotectrl::nb_poses " "
      foreach child { step test nom nb_poses } {
         $Dslr.$child configure -state disabled
      }
   }

   #########################################################################
   #--   Configure le bouton Stock                                         #
   #########################################################################
   proc configStock {} {
      global panneau caption
      variable Dslr

      set l [ llength $panneau(remotectrl,stockLabels) ]

      #--   si carte CF seule ou mode continu ou mode rafale
      if { $l == "1" \
         || $panneau(remotectrl,bracket) == "$caption(remotectrl,bracket,continu)" \
         || $panneau(remotectrl,bracket) == "$caption(remotectrl,bracket,rafale)" } {
         #--   active usecf 1
         $Dslr.stock.m invoke 0
         #--   gele le bouton
         $Dslr.stock configure -state disabled
      } elseif { $panneau(remotectrl,ip2) == "127.0.0.1" } {
         #--   Maison et Jardin
         $Dslr.stock.m invoke 2
         $Dslr.stock.m entryconfigure 1 -state disabled
         $Dslr.stock.m entryconfigure 3 -state disabled
      } else {
        $Dslr.stock configure -state normal
      }
   }

   #########################################################################
   #--   Configure le bouton USB/Longuepose                                #
   #########################################################################
   proc configPose {} {
      global panneau caption
      variable Dslr

      if { [ llength $panneau(remotectrl,poseLabels) ] == "2" \
         && $panneau(remotectrl,bracket) != "$caption(remotectrl,bracket,continu)" \
         && $panneau(remotectrl,bracket) != "$caption(remotectrl,bracket,rafale)" } {
            set etat "normal"
      } else {
            $Dslr.pose.m invoke 0
            set etat "disabled"
      }
      $Dslr.pose configure -state $etat
   }

   #########################################################################
   #--   Commute USB/Longuepose                                            #
   #  parametres : camNo choix ( si USB ul =0 sinon ul=1 )                 #
   #########################################################################
   proc switchExpTime { ul } {
      global panneau
      variable Dslr

      set etat_anterieur [ lindex $panneau(remotectrl,status) 0 ]

      if { $etat_anterieur != $ul } {
         set status [ send "cam$panneau(remotectrl,camNo) longuepose $ul" ]
         #--   memorise le nouvel etat
         set panneau(remotectrl,status) \
            [ lreplace $panneau(remotectrl,status) 0 0 "$status" ]
      }

      #--   adapte l'entree du temps d'exposition
      if { $etat_anterieur != $ul || [ llength [ $Dslr.exptime cget -values ] ] == "0" } {
         configTimeScale $ul
         #--   transfert la valeur
         set ::remotectrl::exptime $panneau(remotectrl,time)
         update
      }
   }

   #########################################################################
   #--   Configure l'entree du temps d'exposition                          #
   #  parametre : camNo choix ( si USB s =0 sinon s=1 )                    #
   #########################################################################
   proc  configTimeScale { s } {
      global panneau
      variable Dslr

      switch $s {
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

   #########################################################################
   #--   Commute la memoire                                                #
   #  parametres : camNo stockage ( si CF sto =1 sinon sto=0 )             #
   #########################################################################
   proc switchStock { sto } {
      global panneau
      variable Dslr

      set camNo $panneau(remotectrl,camNo)
      set etat_anterieur [ lindex $panneau(remotectrl,status) 1 ]

      if { $etat_anterieur != $sto } {
         send "cam$camNo autoload [ expr { 1-$sto } ]"
         send "cam$camNo usecf $sto"
         #--   memorise le nouvel etat
         set panneau(remotectrl,status) \
            [ lreplace $panneau(remotectrl,status) end end "$sto" ]
      }

      #--   si usage de CF
      if { $sto == "1" } {
         set ::remotectrl::nom ""
         set ::remotectrl::see "0"
         set ::remotectrl::wind "0"
         set etat "disabled"
      } else {
         set etat "normal"
      }

      foreach child { nom see wind } {
         $Dslr.$child configure -state $etat
      }
   }

   #########################################################################
   #--   Configure le format et l'extension                                #
   #########################################################################
   proc configFormat { } {
      global panneau conf

      if { $panneau(remotectrl,quality) == "RAW" } {
         set panneau(remotectrl,format) "fits"
         set panneau(remotectrl,extension) "$conf(extension,defaut)"
      } else {
         set panneau(remotectrl,format) "jpeg"
         set panneau(remotectrl,extension) ".jpg"
      }

      #--   decoche le fenetrage a chaque changement de format
      set ::remotectrl::wind "0"
      set panneau(remotectrl,box) ""
   }

   #########################################################################
   #--   Configure l'entree Intervalle                                     #
   #########################################################################
   proc configIntervalle { n } {
      global panneau caption
      variable Dslr

      set var "intervalle"
      #--   si rafale
      if { $n == "4" } { set var "duree" }

      if { $n == "1" || $n == "2" } {
         if { $panneau(remotectrl,test) != "1" } {
            set val " "
            set state "disabled"
         } else {
            set val $panneau(remotectrl,intervalle_mini)
            set state "normal"
         }
       } elseif { $n == "3" } {

         set val " "
         set state "disabled"

       } elseif { $n == "4" } {

         set val "1"
         set state "normal"

      }

      set ::remotectrl::intervalle $val
      $Dslr.intervalle configure -label $caption(remotectrl,$var) -state $state
      DynamicHelp::add $Dslr.intervalle -text $caption(remotectrl,help$var)
   }

   ######################################################################
   #--   Dimensionne une selection pour le fenetrage                    #
   ######################################################################
   proc getWindow {} {
      global audace panneau

      set panneau(remotectrl,box) ""
      if { $::remotectrl::wind == "1" } {
         set bufNo [ visu$audace(visuNo) buf ]
         if [  buf$bufNo imageready ] {
            set panneau(remotectrl,box) [ ::confVisu::getBox $audace(visuNo) ]
         }
      }
   }

   ######################################################################
   #--   Cree une entree avec un label appelee par ApnBuildIF           #
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
   #--   Ecriture du fichier log                                        #
   #  parametres :   nom du fichier texte                               #
   ######################################################################
   proc writeLog { f m } {

      set err [ catch {
            set fd [ open $f a+ ]
            puts $fd $m
            close $fd
         } msg ]
      return $err
   }

   ######################################################################
   #--   Fenetre d'avertissement                                        #
   #  parametres :   variable de caption                                #
   ######################################################################
   proc avertiUser { v } {
      global caption

      tk_messageBox -title $caption(remotectrl,attention)\
         -icon error -type ok -message $caption(remotectrl,$v)
   }

