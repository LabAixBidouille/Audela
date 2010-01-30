#
# Fichier : rmtctrlapn.tcl
# Description : Script pour le controle de l'APN
# Auteur : Raymond ZACHANTKE
# Mise a jour $Id: rmtctrlapn.tcl,v 1.1 2010-01-30 14:47:15 robertdelmas Exp $
#

   ###################################################################
   #-- Complete le panneau d'acquistion                              #
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
      foreach var { longuepose stock quality step bracket } {
         buildMenuButton $var
      }
      $Dslr.step configure -textvar "" -text $caption(remotectrl,step) -width 2

      #--   label pour afficher le format de l'image
      label $Dslr.format -textvariable panneau(remotectrl,format) \
         -width 4 -borderwidth 1

      #--   construit le bouton 'Test'
      button $Dslr.test -relief raised -width 10 -borderwidth 2 \
         -text $caption(remotectrl,test) -command "::remotectrl::testTime"

      #--   label pour afficher les etapes
      label $Dslr.state -textvariable panneau(remotectrl,action) \
         -width 14 -borderwidth 2 -relief sunken

      #--   construit les entrees de donnees
      foreach var { nom nb_poses delai intervalle } {
         buildLabelEntry $var
      }
      $Dslr.nom configure -labelwidth 6 -width 10
      bind $Dslr.nom <Leave> { ::remotectrl::test_rafale ; ::remotectrl::test_nom }

      #--   la combobox pour le temps de pose
      label $Dslr.lab_exptime -text $caption(remotectrl,exptime)
      ComboBox $Dslr.exptime -borderwidth 1 -width 8 -relief sunken \
         -height 10 -justify center \
         -textvariable panneau(remotectrl,time) \
         -modifycmd "::remotectrl::test_rafale ; ::remotectrl::test_exptime"
      bind $Dslr.exptime <Leave> { ::remotectrl::test_rafale ; ::remotectrl::test_exptime }

      #--   checkbutton pour la visualisation
      checkbutton $Dslr.see -text $caption(remotectrl,see) \
         -indicatoron "1" -onvalue "1" -offvalue "0" \
         -variable ::remotectrl::see

      #--   packaging des widgets
      ::blt::table $Dslr \
         $Dslr.longuepose 0,0 -cspan 2 \
         $Dslr.stock 1,0 -cspan 2 \
         $Dslr.format 2,0 \
         $Dslr.quality 2,1 \
         $Dslr.step 3,0 \
         $Dslr.bracket 3,1\
         $Dslr.test 4,0 -cspan 2 \
         $Dslr.state 5,0 -cspan 2 \
         $Dslr.nom 6,0 -cspan 2 \
         $Dslr.nb_poses 7,0 -cspan 2 \
         $Dslr.lab_exptime 8,0 -anchor w \
         $Dslr.exptime 8,1 -anchor e \
         $Dslr.delai 9,0 -cspan 2 \
         $Dslr.intervalle 10,0 -cspan 2 \
         $Dslr.see 11,0 -cspan 2
      ::blt::table configure $Dslr r* -pady 2

      #--   ajoute les bulles d'aide
      foreach child { step test nom nb_poses exptime delai intervalle } {
         DynamicHelp::add $Dslr.$child -text $caption(remotectrl,help_$child)
      }

      initPar

      #--   demarre sur la configuration 'Une image'
      configImg

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $Dslr
   }

   ######################################################################
   #-- Gere les prises de vue a partir des reglages de l'utilisateur    #
   ######################################################################
   proc shoot {} {
      global panneau conf caption
      variable Dslr

      #--   gele les commandes
      setWindowState disabled

      #--   affiche le status 'Attente'
      set panneau(remotectrl,action) $caption(remotectrl,action,wait)

      #--   raccourcis
      set camNo $panneau(remotectrl,camNo)
      set type $panneau(remotectrl,bracket)
      set storage $panneau(remotectrl,stock)
      set nb_poses $remotectrl::nb_poses
      set timer $::remotectrl::intervalle
      set n [ lsearch $panneau(remotectrl,exptimeValues) $::remotectrl::exptime ]
      set delta [ expr { -1*$panneau(remotectrl,step) } ]

      #---  si la pose est differee, affichage du temps restant
      if { $::remotectrl::delai != 0 } {
         delay ::remotectrl::delai
      }

      #--   s'il y a lieu synchronise les extensions des images fits
      if { $panneau(remotectrl,format) == "fits" } {
         eval "send \{set conf(extension,defaut) \"$conf(extension,defaut)\"\}"
      }

      #--   compte les images
      set i 1

      while { $::remotectrl::nb_poses > 0 } {

         #--  affiche le status 'Acquisition'
         set panneau(remotectrl,action) $caption(remotectrl,action,acq)

         #--  regle le temps d'exposition
         eval "send \{cam$camNo exptime $::remotectrl::exptime\}"

         #--- le temps maintenant
         set time_now [ clock seconds ]

         #--- Alarme sonore de fin de pose sur le pc Jardin
         #set message "send \{::camera::alarmeSonore $::remotectrl::exptime\}"
         #eval $message

         #--  definit la commande
         if { $type == $caption(remotectrl,bracket,rafale) } {
            #--   retard pour valider le changement de temps d'exposition
            if { $delta != "0" } { after 1500 }
            catch { eval "send \{cam$camNo acq -blocking\}" } msg
         } else {
            #--   acquiert l'image
            catch {  eval "send \{cam$camNo acq\}"
                     eval "send \{vwait status_cam$camNo\}" } msg
         }

         if [ regexp "Dialog error" $msg ] {
            tk_messageBox -title $caption(remotectrl,attention)\
               -icon error -type ok -message $caption(remotectrl,cam_pb)
         }

         #--  charge et visualise l'image si stockage autre que carte CF
         if { $storage != "$caption(remotectrl,stock,cf)" } {
            loadandseeImg $i
         }

         #--- decremente et affiche le nombre de poses qui reste a prendre
         incr ::remotectrl::nb_poses "-1"

         #-- incremente l'index de l'image
         incr i

         #--   si ce n'est pas la derniere image
         if { $nb_poses >= $i && $type != $caption(remotectrl,bracket,one) } {

            #--   recalcule et affiche exptime pour serie et rafale
            if { $delta != "0" } {
               #--   incremente l'index = regresse dans la liste
               incr n "$delta"
               #--   extrait le temps de pose
               set ::remotectrl::exptime [ lindex  $panneau(remotectrl,exptimeValues) $n ]
               #--   actualise le temps de pose sur le panneau
               $Dslr.exptime setvalue @$n
               update
            }

            #--   met a jour l'intervalle si on a a faire a une serie
            if { $type == $caption(remotectrl,bracket,serie) } {
               set d [ expr { $time_now + $timer -[ clock seconds ] } ]
               if { $d > 1 } {
                  #--   met a jour le timer
                  set ::remotectrl::intervalle $d
                  #--   decompte les secondes
                  ::remotectrl::delay "::remotectrl::intervalle"
               }
            }
         }
      #--   fin du while
      }

      #--   recharge le nb_poses
      set ::remotectrl::nb_poses "1"

      #--   recharge l'intervalle mini
      set remotectrl::intervalle $timer

      #--   efface le status
      set panneau(remotectrl,action) ""

      #--   selectionne la valeur d'exposition finale
      $Dslr.exptime setvalue @$n

      #--   degele les commandes
      setWindowState normal
   }

   ######################################################################
   #-- Nomme, sauvegarde, transfert et affiche l'image                  #
   #-- parametre : index de l'image                                     #
   ######################################################################
   proc loadandseeImg { k } {
      global panneau caption

      #--   affiche le status 'Sauvegarde'
      set panneau(remotectrl,action) $caption(remotectrl,action,load)

      set name $remotectrl::nom
      if { $name == "" } { set name "tmp" }

      #---  donne un index et une extension a l'image
      append name $k $panneau(remotectrl,extension)

      #---  repertoire image Jardin
      set file "\$audace(rep_images)/$name"

      #--   demande le N° du buffer
      set bufNo [ eval "send \{set bufNo [visu1 buf]\}" ]

      #--   attend que le buffer du Jardin soit pret
      eval "send \{ while \{ \[ buf$bufNo imageready \] != \"1\" \} \{ after 10 \} ; buf$bufNo stat\}"

      #--   sauve l'image sur Jardin
      if { $panneau(remotectrl,extension) != ".jpg" } {
         eval "send \{buf$bufNo save \"$file\"\}"
      } else {
         eval "send \{buf$bufNo save \"$file\" -quality 100\}"
      }

      #--   operation en fonction du choix de stockage
      if [ TestEntier $panneau(remotectrl,path_img) ] {

         #--   transfert par FTP
         transferFTP $name

         #--   detruit l'image Jardin si stockage = Maison seulement
         if { $::panneau(remotectrl,stock) == "$caption(remotectrl,stock,home)" } {
            eval "send \{ file delete \"\$audace(rep_images)/$name\" \}"
         }
      }

       #--  affiche l'image
      if { $::remotectrl::see == "1" } {

         #--   affiche le status 'Affichage'
         set panneau(remotectrl,action) $caption(remotectrl,see)

         #--   affiche l'image
         loadima "$panneau(remotectrl,path_img)/$name"
      }
   }

   ######################################################################
   #--  Mesure l'intervalle mini dans les conditions de reglages        #
   ######################################################################
   proc testTime { } {
      global audace panneau caption

      #--   annule le delai
      set ::remotectrl::delai "0"

      #--   affiche le nom
      set ::remotectrl::nom "$caption(remotectrl,test)"

      #--   inhibe les commandes
      setWindowState disabled

      #--   fixe le nb de pose a 1
      set ::remotectrl::nb_poses "1"

      #--   le temps maintenant
      set t0 [clock milliseconds]

      #--   lance une acquisition
      shoot

      #--   calcule la duree de la sequence
      set duree [ expr { ([clock milliseconds ]-$t0)/1000.0 } ]

      #--   memorise l'intervalle
      set panneau(remotecrtl,intervalle_mini) "$duree"

      #--   fixe l'intervalle mini a afficher
      set ::remotectrl::intervalle "[ format "%.1f" $duree ]"

      #--   definit le nom du fichier
      set file ${::remotectrl::nom}1$panneau(remotectrl,extension)

      #--   supprime le nom affiche
      set ::remotectrl::nom ""

      #--   efface le(s) fichier(s) de test
      switch -exact $panneau(remotectrl,stock) {
         "$caption(remotectrl,stock,cf)" { \
            #--   efface l'image stockee seulement sur la carte memoire
            eval "send \{cam$panneau(remotectrl,camNo) delete 1 \}"
         }
         "$caption(remotectrl,stock,backyard)" { \
            #--   efface l'image stockee seulement sur le serveur
            eval "send \{ file delete \"\$audace(rep_images)/$file\" \}"
         }
         "$caption(remotectrl,stock,home&backyard)" { \
            #--   efface l'image stockee sur le serveur et le client
            eval "send \{ file delete \"\$audace(rep_images)/$file\" \}"
            file delete [ file join $audace(rep_images) $file ]
         }
         "$caption(remotectrl,stock,home)" { \
            #--   efface l'image stockee seulement sur le client
            file delete [ file join $audace(rep_images) $file ]
         }
         "default" {
            #--   efface l'image stockee seulement sur le lecteur reseau
            file delete "$panneau(remotectrl,path_img)/$file"
         }
      }

      #--   libere les commandes
      setWindowState normal
   }

   ######################################################################
   #-- Verifie et Formate le temps en décimal                           #
   ######################################################################
   proc test_exptime {} {
      global panneau caption

      set exptime $panneau(remotectrl,time)

      if { $panneau(remotectrl,longuepose) == "$caption(remotectrl,longuepose,lp)" } {

         #--   test en mode Longuepose (entree manuelle)
         #--   ote tout ce qui suit la virgule
         regsub -all {[^0-9\.]} $exptime {} resultat

         if { $exptime != $resultat || $exptime <= "30" } {
            set resultat "31"
            #--   modifie l'affichage
            set $panneau(remotectrl,time) "31"
         }

      } else {

         #--   en mode USB, fait
         set i [ lsearch $panneau(remotectrl,exptimeLabels) $exptime ]
         #--   lit le resultat dans la liste de conversion
         set resultat [ lindex $panneau(remotectrl,exptimeValues) $i ]
      }

      set ::remotectrl::exptime $resultat
   }

   ###################################################################
   #-- Ote tous les caracteres non alphanumeriques ou non underscore #
   ###################################################################
   proc test_nom {} {
      #-- seuls les caracteres alphanumériques et le underscore sont autorises
      regsub -all {[^\w_]} $::remotectrl::nom {} ::remotectrl::nom
   }

   ###################################################################
   #-- Si le nombre de poses n'est pas un entier il est fixe a 1     #
   ###################################################################
   proc test_nb_poses {} {
      variable Dslr

      if ![ TestEntier $::remotectrl::nb_poses ] {
         #-- par defaut le nombre de pose est egal a 1
         set ::remotectrl::nb_poses "1"
      }
   }

   #######################################################################
   #-- Si l'intervalle n'est pas un entier ou est < l'intervalle minimum #
   #-- il est fixe à l'intervalle minimum                                #
   #######################################################################
   proc test_intervalle {} {
      global panneau

      regsub -all {[^0-9\.]} $::remotectrl::intervalle {} resultat
      if { $resultat < $panneau(remotectrl,intervalle_mini) } {
         set resultat $panneau(remotectrl,intervalle_mini)
      }
      set ::remotectrl::intervalle $resultat
   }

   ###################################################################
   #-- Si le nombre de poses n'est pas un entier il est fixe a 0     #
   ###################################################################
   proc test_delai { } {
      if ![ TestEntier $::remotectrl::delai ] {
         set ::remotectrl::delai "0"
      }
   }

   #######################################################################
   #-- Teste si la valeur d'exposition finale est dans la plage          #
   #-- appelee par le bouton Pas, le nb de poses et le temps d'exposition#
   #######################################################################
   proc test_rafale { } {
      global panneau caption
      variable Dslr

      #--sans objet si une image
      if { $panneau(remotectrl,bracket) == $caption(remotectrl,bracket,one) } {
         return
      }

      #--   recherche l'indice du temps affiche
      set i_initial [ lsearch $panneau(remotectrl,exptimeLabels) $panneau(remotectrl,time) ]

      #--   selectionne cette valeur
      $Dslr.exptime setvalue @$i_initial

      #--   calcule l'indice de la valeur finale
      set i_final [ expr { $i_initial+$panneau(remotectrl,step)*(1-$::remotectrl::nb_poses) } ]

      if { $i_final < 0 || $i_final > [ llength $panneau(remotectrl,exptimeLabels) ] } {
         #--   message d'alerte si hors plage
         tk_messageBox -title $caption(remotectrl,attention)\
            -icon error -type ok -message $caption(remotectrl,out_of_limits)
         #--   remet pas a 0
         set panneau(remotectrl,step) 0
      }
   }

