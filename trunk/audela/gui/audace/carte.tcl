#
# Fichier : carte.tcl
# Description : namespace generique des cartes (~ classe abstraite)
#    Transmet les appels aux procedures du namespace de la carte choisie avec confcat.tcl
# Auteur : Michel PUJOL
# Date de mise a jour : 19 mars 2006
#

namespace eval ::carte {
   global audace

   #--- chargement des captions
   uplevel #0  "source \"[file join $audace(rep_caption) carte.cap]\""

   #------------------------------------------------------------
   #  showMapFromBuffer
   #     affiche la carte sur les coordonnees contenues dans le buffer de l'image
   #     mots clés FITS "RA" et "DEC"
   #  parametres :
   #     buffer : buffer de l'image
   #  return 0 (OK) , 1(error)
   #------------------------------------------------------------
   proc showMapFromBuffer { buffer } {
      global caption

      if { [ $buffer imageready ] == "0" } {
         tk_messageBox -message "$caption(carte,error_no_image)" -title "$caption(carte,title)" -icon error
         return
      }

      #--- Premiere tentatvive : je recupere les coordonnees dans le fichier FIT
      set ra  [lindex [$buffer getkwd RA] 1]
      set dec [lindex [$buffer getkwd DEC] 1]

      #console::disp "gotoFromBuffer [$buffer getkwd RA]\n"

      if { "$ra" != "" && "$dec" != "" } {
         #--- je convertis RA au format HMS
         set ra "[mc_angle2hms $ra 360 zero 0 auto string]"
         #--- je supprime les decimales des secondes 
         set ra [string range $ra 0 [expr [string first "s" "$ra" ] ] ]

         #--- je convertis DEC au format DMS
         set dec "[mc_angle2dms $dec 90 zero 0 + string ] "
         #--- je supprime les decimales des secondes 
         set dec [string range $dec 0 [expr [string first "s" "$dec" ] ] ]

         set zoom_carte "10"
         set avant_plan "1"
         ::carte::gotoObject "" "$ra" "$dec" $zoom_carte $avant_plan
      } else {
         set message "$caption(carte,error_image_buffer)"
         tk_messageBox -message "$caption(carte,error_image_buffer)" -title "$caption(carte,title)" -icon error
      }
   }

   #------------------------------------------------------------
   #  gotoObject radec fov
   #     centre la fenetre de la carte sur les coordonnees passes en parametre
   #     et fixe la taille du champ
   #  parametres :
   #     nom_objet  : nom de l'objet   (ex : "NGC7000")
   #     ad         : ascension droite (ex : "16h41m42s")
   #     dec        : declinaison      (ex : "+36d28m00s")
   #     zoom_objet : champ 1 à 10 
   #     avant_plan : 1=mettre la carte au premier plan 0=ne pas mettre au premier plan
   #  return 0 (OK) , 1(error)
   #------------------------------------------------------------
   proc gotoObject { nom_objet ad dec zoom_objet avant_plan } {
      global conf
      global caption

      #console::disp "::carte::gotoObject $nom_objet, $ad, $dec, $zoom_objet, $avant_plan carte=$conf(confCat) \n"

      set result 1
      if { $conf(confCat) != "" } {
         if { [isReady] == 0 } {
            set resultcatch [ catch { set result [$conf(confCat)\:\:gotoObject "$nom_objet" "$ad" "$dec" "$zoom_objet" "$avant_plan" ] } msg]
         } else {
            #--- Affichage de la fenetre de configuration des cartes si aucune carte n'est prete
            set choice [tk_messageBox -message "$caption(carte,error_no_map)" -title "$caption(carte,title)" \
               -icon question -type yesno]
            if {$choice=="yes"} {
               ::confCat::run
            }
         }
      } else { 
         #--- Affichage de la fenetre de configuration des cartes si aucune carte n'est selectionnee
         set choice [tk_messageBox -message "$caption(carte,error_no_map)" -title "$caption(carte,title)" \
            -icon question -type yesno]
         if {$choice=="yes"} {
            ::confCat::run
         }
      }
      return $result
   }

   #------------------------------------------------------------
   #  getSelectedObject {}
   #     recupere les coordonnées et le nom de l'objet selectionne dans la carte
   #  
   #  return [list $ra $dec $objName ]
   #     $ra      : right ascension (ex : "16h41m42s")
   #     $dec     : declinaison     (ex : "+36d28m00s")
   #     $objName : object name     (ex : "M 13")
   #  ou "" si erreur
   #------------------------------------------------------------
   proc getSelectedObject { } {
      global conf

      set result ""
      set resultcatch [ catch { set result [$conf(confCat)\:\:getSelectedObject] } msg]
      if { $resultcatch == "1" } {
         console::affiche_erreur "::carte::gotoObject msg=$msg \n"
      }
      return $result
   }

   #------------------------------------------------------------
   #  isReady
   #     informe de l'etat de la connexion au logiciel qui affiche la carte
   #  
   #  return 0 (ready) , 1 (not ready)
   #
   #------------------------------------------------------------
   proc isReady { } {
      global conf

      set result ""
      set resultcatch [ catch { set result [$conf(confCat)\:\:isReady] } msg]
      if { $resultcatch == "1" } {
         console::affiche_erreur "::carte::gotoObject msg=$msg \n"
      }
      return $result
   }
}

