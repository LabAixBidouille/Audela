#
# Fichier : rmtctrlapn.tcl
# Description : Script pour le controle de l'APN
# Auteur : Raymond ZACHANTKE
# Mise a jour $Id: rmtctrlapn.tcl,v 1.3 2010-02-14 17:58:49 robertdelmas Exp $
#

   ######################################################################
   #-- Gere les prises de vue a partir des reglages de l'utilisateur    #
   ######################################################################
   proc shoot {} {
      global panneau conf caption

      #--   gele les commandes
      setWindowState disabled

      #--   affiche le status 'Attente'
      set panneau(remotectrl,action) $caption(remotectrl,action,wait)

      #--   identifie l'operation par un nombre
      set n [ lsearch $panneau(remotectrl,bracketLabels) $panneau(remotectrl,bracket) ]

      #--   synchronise les extensions des images fits
      if { $panneau(remotectrl,format) == "fits" } {
         send "set conf(extension,defaut) $conf(extension,defaut)"
      }

      #---  si la pose est differee, affichage du temps restant
      if { $::remotectrl::delai != 0 } {
         delay ::remotectrl::delai
      }

      if { $n == "3" } {

         #--   affiche le status 'Acquisition'
         set panneau(remotectrl,action) $caption(remotectrl,action,acq)

         shootRafale

         #--   complete le fichier log
         infLog "$caption(remotectrl,duree) $::remotectrl::intervalle sec."

      } else {

         shootImg $n

      }

      set panneau(remotectrl,action) " "

      #--   degele les commandes
      setWindowState normal
   }

   ######################################################################
   #-- Commande les prises de vue autres que le mode Rafale de l'APN    #
   ######################################################################
   proc shootImg { op } {
      global panneau caption

      #--   raccourcis
      set camNo $panneau(remotectrl,camNo)
      set exptime $::remotectrl::exptime

      #--   memorise
      set nb_poses $remotectrl::nb_poses
      set timer $::remotectrl::intervalle
      set n [ lsearch $panneau(remotectrl,exptimeValues) $exptime ]
      set delta [ expr { -1*$panneau(remotectrl,step) } ]

      #--   compte les images
      set i 1

      while { $::remotectrl::nb_poses > 0 } {

         #--  affiche le status 'Acquisition'
         set panneau(remotectrl,action) $caption(remotectrl,action,acq)

         #--  regle le temps d'exposition
         send "cam$camNo exptime $exptime"

         #--- le temps maintenant
         set time_now [ clock seconds ]

         #--- Alarme sonore de fin de pose sur le pc Jardin
         #send "::camera::alarmeSonore $exptime"

         #--  definit la commande
         if { $op == "2" } {

            #--   En Continu, retard pour valider le changement de temps d'exposition
            if { $delta != "0" } {
               after 1500
            }
            catch { send "cam$camNo acq -blocking" } msg

         } else {

            #--   Une image ou Une serie
            catch {  send "cam$camNo acq"
                     send "vwait status_cam$camNo" } msg
         }

         if ![ regexp "Dialog error" $msg ] {
            if { $remotectrl::nom != "Test" } {
               set name $remotectrl::nom
               append name $i $panneau(remotectrl,extension)
               infLog "$name"
            }
        } else {
            avertiUser "cam_pb"
        }

         #--  charge et visualise l'image si stockage autre que carte CF
         if { $panneau(remotectrl,stock) != "$caption(remotectrl,stock,cf)" } {
            loadandseeImg $i
         }

         #--- decremente et affiche le nombre de poses qui reste a prendre
         incr ::remotectrl::nb_poses "-1"

         #-- incremente l'index de l'image
         incr i

         #--   si ce n'est pas la derniere image
         if { $nb_poses >= $i && $op != 0 } {

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

            #--   met a jour l'intervalle pour Une serie
            if { $op == 1 } {

               set d [ expr { $time_now + $timer -[ clock seconds ] } ]

               if { $d > 1 } {
                  #--   met a jour le timer
                  set ::remotectrl::intervalle $d
                  #--   decompte les secondes
                  ::remotectrl::delay "::remotectrl::intervalle"
               }
            }
         }
      }
   }

   ######################################################################
   #-- Commande le mode Rafale de l'APN                                 #
   ######################################################################
   proc shootRafale {} {
      global panneau

      #--   raccourcis
      set camNo $panneau(remotectrl,camNo)
      set linkNo $panneau(remotectrl,linkNo)
      set bitNo $panneau(remotectrl,bitNo)

      #--  regle le temps d'exposition
      send "cam$camNo exptime $::remotectrl::exptime"

      #--   passe en mode 'rafale'
      send "cam$camNo drivemode 1"

      #--   prend une photo juste pour passer les parametres
      catch {  send "cam$camNo acq -noblocking" } msg

      if [ regexp "Dialog error" $msg ] {
            avertiUser "cam_pb"
      }

      #--   passe en mode longuepose
      send "cam$camNo longuepose 1"

      #--   actionne le bit
      send "link$linkNo bit $bitNo $panneau(remotectrl,startvalue)"
      after [ expr { $remotectrl::intervalle*1000 } ]
      send "link$linkNo bit $bitNo $panneau(remotectrl,stopvalue)"

      #--   repasse en mode USB
      send "cam$camNo longuepose 0"

      #--   repasse en mode normal
      send "cam$camNo drivemode 0"
   }

   ######################################################################
   #-- Nomme, sauvegarde, transfert et affiche l'image                  #
   #-- parametre : index de l'image                                     #
   ######################################################################
   proc loadandseeImg { k } {
      global audace panneau caption

      #--   affiche le status 'Sauvegarde'
      set panneau(remotectrl,action) $caption(remotectrl,action,load)

      #--   nomme l'image
      set name $remotectrl::nom
      if { $name == "" } { set name "tmp" }

      #---  donne un index et une extension a l'image
      append name $k $panneau(remotectrl,extension)

      #--   demande le N° du buffer
      set bufNo [ send "set bufNo [ visu1 buf ]" ]

      #--   attend que le buffer du Jardin soit pret pour fixer les seuils
      set stat [ send "while { \[ buf$bufNo imageready \] == \"0\" } { after 50 } ; buf$bufNo stat" ]

      #--   envoie les valeurs vers la console pour une image RAW
      if { $panneau(remotectrl,format) == "fits" } {
         ::console::affiche_resultat "\n$name\n\
            $caption(remotectrl,maxi) [ lindex $stat 2 ]\n\
            $caption(remotectrl,moyenne) [ lindex $stat 4 ]\n\
            $caption(remotectrl,mini) [ lindex $stat 3 ]\n\n"
      }

      #--   fenetre l'image
      if { $::remotectrl::wind == "1" && $panneau(remotectrl,box) !="" } {
         send "buf$bufNo window \[ list $panneau(remotectrl,box) \]"
      }

      #--   sauve l'image sur Jardin
      send "buf$bufNo save [ file join \$audace(rep_images) $name ]"

      #--   designe le repertoire contenant l'image a visualiser
      set rep $audace(rep_images)
      if ![ TestEntier $panneau(remotectrl,path_img) ] {
         #--   cas du dossier partage
         set rep $panneau(remotectrl,path_img)
      }

      #--   transfert ftp selon stockage et visualisation
      if { [ TestEntier $panneau(remotectrl,path_img) ] == "1" \
         && $panneau(remotectrl,ip2) != "127.0.0.1" } {

          #--   transfert ftp si visualisation ou stockage = Maison ou stockage = Maison et Jardin
         if { $::panneau(remotectrl,stock) == "$caption(remotectrl,stock,home)" || \
            $::panneau(remotectrl,stock) == "$caption(remotectrl,stock,home&backyard)" \
            || $::remotectrl::see == "1" } {

            #--   transfert par FTP
            transferFTP $name
         }
      }

      if { $::remotectrl::see == "1" } {

         #--   affiche le status 'Affichage'
         set panneau(remotectrl,action) $caption(remotectrl,see)

         #--   affiche l'image
         loadima [ file join $rep $name ]
      }

      if { $::panneau(remotectrl,stock) == "$caption(remotectrl,stock,home)" } {

         #--   detruit l'image Jardin si stockage = Maison seulement
         send "file delete [ file join \$audace(rep_images) $name ]"

      } elseif { $::panneau(remotectrl,stock) == "$caption(remotectrl,stock,backyard)" } {

         #--   detruit l'image Maison si stockage = Jardin seulement
         set file [ file join $audace(rep_images) $name ]
         if [ file exists $file ] {
            file delete $file
         }
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

      #--   memorise l'intervalle
      set panneau(remotectrl,intervalle_mini) [ format "%.1f" [ expr { ([clock milliseconds ]-$t0)/1000.0 } ] ]

      #--   fixe l'intervalle mini a afficher
      set ::remotectrl::intervalle $panneau(remotectrl,intervalle_mini)

      #--   definit le nom du fichier
      set file ${::remotectrl::nom}1$panneau(remotectrl,extension)

      #--   supprime le nom affiche
      set ::remotectrl::nom ""

      #--   efface le(s) fichier(s) de test
      switch -exact $panneau(remotectrl,stock) {
         "$caption(remotectrl,stock,backyard)" { \
            #--   efface l'image stockee seulement sur le serveur
            send "file delete \"\$audace(rep_images)/$file\""
         }
         "$caption(remotectrl,stock,home&backyard)" { \
            #--   efface l'image stockee sur le serveur et le client
            send "file delete [ file join $audace(rep_images) $file ]"
            file delete [ file join $audace(rep_images) $file ]
         }
         "$caption(remotectrl,stock,home)" { \
            #--   efface l'image stockee seulement sur le client
            file delete [ file join $audace(rep_images) $file ]
         }
         "default" {
            #--   efface l'image stockee sur le lecteur reseau
            file delete "$panneau(remotectrl,path_img)/$file"
         }
      }

      #--   memorise le test
      set panneau(remotectrl,test) "1"

      #--   libere les commandes
      setWindowState normal
   }

   ######################################################################
   #-- Verifie et Formate le temps en décimal                           #
   ######################################################################
   proc test_exptime {} {
      global panneau

      set exptime $panneau(remotectrl,time)

      if { $panneau(remotectrl,pose) == "<30" } {

         #--   en mode USB, cherche l'index de la valeur
         set i [ lsearch $panneau(remotectrl,exptimeLabels) $exptime ]

         #--   lit le resultat dans la liste de conversion
         set resultat [ lindex $panneau(remotectrl,exptimeValues) $i ]

      } else {

         #--   en mode Longuepose, teste l'entree
         #--   ote tout ce qui suit la virgule
         regsub -all {[^0-9\.]} $exptime {} resultat

         if { $exptime != $resultat || $exptime <= "30" } {
            #--   modifie l'affichage
            set $panneau(remotectrl,time) "31"
            set resultat "31"
         }
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

      if ![ TestEntier $::remotectrl::nb_poses ] {
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
   #-- Si le delai n'est pas un entier il est fixe a 0               #
   ###################################################################
   proc test_delai {} {

      if ![ TestEntier $::remotectrl::delai ] {
         set ::remotectrl::delai "0"
      }
   }

   #########################################################################
   #-- Teste si la valeur d'exposition finale est dans la plage            #
   #-- appelee par le bouton Pas, le nb de poses et le temps d'exposition  #
   #-- s'applique uniquement a 'Une serie' ou 'En continu'                 #
   #########################################################################
   proc test_bracketing {} {
      global panneau

      set exptimeLabels $panneau(remotectrl,exptimeLabels)
      set n [ lsearch $panneau(remotectrl,bracketLabels) $panneau(remotectrl,bracket) ]

      if { $panneau(remotectrl,pose) == "<30" &&  ( $n == "1" || $n == "2" ) } {

         #--   recherche l'indice du temps affiche
         set i_initial [ lsearch $exptimeLabels $panneau(remotectrl,time) ]

         #--   calcule l'indice de la valeur finale
         set i_final [ expr { $i_initial+$panneau(remotectrl,step)*(1-$::remotectrl::nb_poses) } ]

         if { $i_final < 0 || $i_final > [ llength $exptimeLabels ] } {

            #--   message d'alerte si hors plage
            avertiUser "out_of_limits"

            #--   remet pas a 0
            set panneau(remotectrl,step) "0"
         }
      }
   }

   ######################################################################
   #-- Complete le fichier log                                          #
   #-- parametre : nom de l'image                                       #
   ######################################################################
   proc infLog { name } {
      global panneau

      set texte [ list \
            "$panneau(remotectrl,stock)" \
            "$panneau(remotectrl,bracket)" \
            "$panneau(remotectrl,quality)" \
            $::remotectrl::exptime \
            "$name" ]
      writeLog $panneau(remotectrl,log) $texte
   }

   ######################################################################
   #--   Decompteur de secondes                                         #
   #  parametre : nom de la variable a decompter (delai ou intervalle)  #
   ######################################################################
   proc delay { var } {
      global panneau

      while { [ set $var ] != "0" } {
            after 1000
            set $var [ expr { [ set $var ]-1 } ]
            if { [ set $var ] <= 0 } { set $var 0 }
            update
      }
   }