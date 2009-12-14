#
# Fichier : displaycoord.tcl
# Description : Outil pour l'observation des SnAudes
# Auteur : Alain KLOTZ
# Mise a jour $Id: displaycoord.tcl,v 1.2 2009-12-14 18:56:15 michelpujol Exp $
#

#============================================================
# Declaration du namespace displaycoord
#    initialise le namespace
#============================================================
namespace eval ::displaycoord {
   package provide displaycoord 1.0
   package require audela 1.4.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] displaycoord.cap ]
}

#------------------------------------------------------------
# ::displaycoord::getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::displaycoord::getPluginTitle { } {
   global caption

   return $caption(displaycoord,title)
}

#------------------------------------------------------------
# ::displaycoord::getPluginHelp
#    retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::displaycoord::getPluginHelp { } {
   return "displaycoord.htm"
}

#------------------------------------------------------------
# ::displaycoord::getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::displaycoord::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# ::displaycoord::getPluginDirectory
#    retourne le type de plugin
#------------------------------------------------------------
proc ::displaycoord::getPluginDirectory { } {
   return "displaycoord"
}

#------------------------------------------------------------
# ::displaycoord::getPluginOS
#    retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::displaycoord::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
# ::displaycoord::getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::displaycoord::getPluginProperty { propertyName } {
   switch $propertyName {
      menu         { return "tool" }
      function     { return "acquisition" }
      subfunction1 { return "aiming" }
      display      { return "window" }
   }
}

#------------------------------------------------------------
# ::displaycoord::initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::displaycoord::initPlugin { tkbase } {

}

#------------------------------------------------------------
# ::displaycoord::createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::displaycoord::createPluginInstance { { tkParent "" } { visuNo 1 } } {
   variable private 
   
   #--- Creation des variables si elles n'exitaitent pas
   if { ! [ info exists ::conf(displaycoord,serverHost) ] }  { set ::conf(displaycoord,serverHost)  "localhost" }
   if { ! [ info exists ::conf(displaycoord,serverPort) ] }  { set ::conf(displaycoord,serverPort)  "5028" }
   if { ! [ info exists ::conf(displaycoord,windowPosition) ] } { set ::conf(displaycoord,windowPosition)     "640x480+50+15" }   
   if { ! [ info exists ::conf(displaycoord,windowMaximize) ] } { set ::conf(displaycoord,windowMaximize)     0 }   
   
   set dir [ file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [getPluginType]] [getPluginDirectory]]
   source [ file join $dir displayconfig.tcl ]
         
   #--- j'intialise les variables locale
   set private(socketChannel) ""
   set private(etat) "NOT_CONNECTED"
   set private(connexionTimerId) ""
      
   #--- Initialisation
   set private(base) "$tkParent.displaycoord"
   set audace(posobs,observateur,gps) "GPS 5.7157 E 43.931892 633.9"
   set private(sortie)     "0"
   set private(home)       $audace(posobs,observateur,gps)
   ###set private(fonttitle)  {arial  75 bold}
   ###set private(font1)      {tahoma 60 bold}
   ###set private(font2)      {tahoma 17 normal}
   ###set private(font3)      {arial  15 bold}
   ###set private(font4)      {tahoma 22 normal}

   font create displayCoordFont1 -family tahoma -size 60 -weight bold
   font create displayCoordFont2 -family tahoma -size 20 -weight normal
   font create displayCoordFont3 -family arial  -size 20 -weight bold
   set private(fonttitle)  {displayCoordFont1} 
   set private(font1)      {displayCoordFont1}  
   set private(font2)      {displayCoordFont2}
   set private(font3)      {displayCoordFont3}
   set private(font4)      {displayCoordFont2}
 
   
}

#------------------------------------------------------------
# ::displaycoord::deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::displaycoord::deletePluginInstance { visuNo } {
   variable private
   
   #--- je deconnecte le serveur de coordonnnes
   ::displaycoord::closeSocketCoord
   #--- je morise l'etat de la fentre (normal=0 , maximized=1)
   if { [wm state $private(base)] == "zoomed" } {      
      set ::conf(displaycoord,windowMaximize) 1
   } else {
      set ::conf(displaycoord,windowMaximize) 0
   }
      
   if { [wm state $private(base)] != "normal" } {
      #--- j'affiche la fenetre en mode normal pour pouvoir recuperer la taille
      wm state $private(base) normal      
   }
   #--- je memorise la position courante et la taille de la fenetre
   set ::conf(displaycoord,windowPosition) [ wm geometry $private(base) ]
   #--- je supprime la fenetre
   destroy $private(base)
   
   set index [lsearch $::confVisu::private($visuNo,pluginInstanceList) ::displaycoord ]
   if { $index != -1 } {
      set ::confVisu::private($visuNo,pluginInstanceList) \
         [lreplace  $::confVisu::private($visuNo,pluginInstanceList) $index $index]
   }
   
   font delete displayCoordFont1
   font delete displayCoordFont2
   font delete displayCoordFont3
         
}

#------------------------------------------------------------
# ::displaycoord::startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::displaycoord::startTool { visuNo } {
   variable private 
   #--- j'affiche la fenetre
   if { [winfo exists $private(base) ] == 0 } {
      ::displaycoord::createWindow $visuNo
      #--- je lance la boucle pour se connecter au serveur
      startConnectionLoop                 
   } else {
      #--- si la fenetre existe deja, je lui donne le focus
      wm withdraw $private(base)
      wm deiconify $private(base)
      focus $private(base)
   }
  
   #--- j'affiche les valeurs par defaut dans les champs
   ::displaycoord::readSocketCoord

}

#------------------------------------------------------------
# ::displaycoord::stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::displaycoord::stopTool { visuNo } {
  #--- rien a faire car c'est l'utilisateur qui ferme la fenetre

}

#------------------------------------------------------------
# ::displaycoord::createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::displaycoord::createWindow { visuNo } {
   variable private
   
   set couleur_blanche       #FFFFFF
   set couleur_noire         #000000
   set couleur_or            #FFAA00
   set couleur_orclair       #FF9900
   set couleur_bleuclair     #00AAFF
   set couleur_bleu          #0000FF
   set couleur_rouge         #FF5500
   set private(color,back) $couleur_bleu
   set private(color,text) $couleur_or
   
   #--- Create the toplevel window
   set  base $private(base)
   toplevel $base -class Toplevel
   wm geometry $base $::conf(displaycoord,windowPosition)
   wm focusmodel $base passive
   ###wm maxsize $base 2000 2000
   wm minsize $base 600 400
   wm resizable $base 1 1
   wm deiconify $base
   wm title $base $::caption(displaycoord,title)
   wm protocol $base WM_DELETE_WINDOW "::displaycoord::deletePluginInstance $visuNo"
   ###bind $base <Destroy> { destroy .ohp_t193 }
   $base configure -bg $private(color,back)
   wm withdraw .
   focus -force $base
   if { $::conf(displaycoord,windowMaximize) == 1 } {
      wm state $base zoomed
   }
   #---
   set private(ohp_t193,adinit)  ""
   set private(ohp_t193,decinit) ""
   #set private(ohp_t193,adinit)  00h00m00s
   #set private(ohp_t193,decinit) +00°00'00\"
   set private(ohp_t193,fichierlog) codeurs_t193.log

   
   #--- frame principale
   frame $base.f -bg $private(color,back)
   
   #--- titre et bouton de configuration
   frame $base.f.titre -bg $private(color,back)   
   label $base.f.titre.lab_titre \
     -bg $private(color,back) -fg $couleur_bleuclair \
     -font $private(fonttitle) -text $::caption(displaycoord,title)
   ###pack $base.f.titre.lab_titre -anchor c 
   grid $base.f.titre.lab_titre -row 0 -column 0 -sticky ew   
   
   button $base.f.titre.configuration  -text $::caption(displaycoord,configuration) \
      -command "::displaycoord::config::run $private(base) $visuNo"   
   ###pack $base.f.titre.configuration -anchor e -side right
   grid $base.f.titre.configuration -row 0 -column 1 -sticky e -padx 4
   grid columnconfig $base.f.titre 0 -weight 1
   
   pack $base.f.titre -fill x -pady 2 -anchor e
   
   #--- Etat du telescope   
   label $base.f.lab_etat \
      -bg $private(color,text) -fg $private(color,back) \
      -font $private(font1)
   pack $base.f.lab_etat -fill none -pady 2 -anchor e
    
   #--- temps
   label $base.f.lab_tu \
     -bg $private(color,back) -fg $private(color,text) \
     -font $private(font1)
     
   label $base.f.lab_tsl \
     -bg $private(color,back) -fg $private(color,text) \
     -font $private(font1)
   pack $base.f.lab_tu -fill none -pady 2 -anchor w
   pack $base.f.lab_tsl -fill none -pady 2 -anchor w

   #--- coordonnees equatoriales : Alpha et Delta
   ###label $base.f.lab_ad \
   ###   -bg $private(color,back) -fg $private(color,text) \
   ###   -font $private(font1)
   ###pack $base.f.lab_ad -fill none -pady 2 -anchor w
   ###label $base.f.lab_dec \
   ###   -bg $private(color,back) -fg $private(color,text) \
   ###   -font $private(font1)
   ###pack $base.f.lab_dec -fill none -pady 2 -anchor w
   
   frame $base.f.coord -bg $private(color,back)
      label $base.f.coord.alpha_label -text $::caption(displaycoord,ad) \
        -bg $private(color,back) -fg $private(color,text) \
        -font $private(font1)
      grid $base.f.coord.alpha_label -row 0 -column 0 -sticky w
      label $base.f.coord.alpha_value \
          -bg $private(color,back) -fg $private(color,text) \
          -font $private(font1)
      grid $base.f.coord.alpha_value -row 0 -column 1 -sticky w
      label $base.f.coord.alpha_calage \
            -bg $private(color,back) -fg $private(color,text) \
            -font $private(font1)
      grid $base.f.coord.alpha_calage -row 0 -column 2 -sticky w
   
      label $base.f.coord.delta_label -text $::caption(displaycoord,dec) \
         -bg $private(color,back) -fg $private(color,text) \
         -font $private(font1)
      grid $base.f.coord.delta_label -row 1 -column 0 -sticky w
      label $base.f.coord.delta_value \
         -bg $private(color,back) -fg $private(color,text) \
         -font $private(font1)
      grid $base.f.coord.delta_value -row 1 -column 1 -sticky w
      label $base.f.coord.delta_calage \
         -bg $private(color,back) -fg $private(color,text) \
         -font $private(font1)
      grid $base.f.coord.delta_calage -row 1 -column 2 -sticky w
   
      grid columnconfig $base.f.coord 0 -weight 1      
      grid columnconfig $base.f.coord 1 -weight 1      
      grid columnconfig $base.f.coord 2 -weight 1      
   pack $base.f.coord -fill x -pady 2 -padx 2 -anchor w
                                                             
   #--- coordonnees brutes (sans modele de pointage)
   label $base.f.lab_coord0 \
      -bg $private(color,back) -fg $couleur_bleuclair \
      -font $private(font3)
   pack $base.f.lab_coord0 -fill none -pady 2 -anchor center
   
   #--- angle horaire
   label $base.f.lab_ha \
     -bg $private(color,back) -fg $couleur_bleuclair\
     -font $private(font1)
   pack $base.f.lab_ha -fill none -pady 2 -anchor center

   #--- nom du site 
   label $base.f.lab_ohp \
     -bg $private(color,back) -fg $private(color,text) \
     -font $private(font4) \
     -text ""
   pack $base.f.lab_ohp -fill none -pady 2 -anchor w  
   
   #--- donnees GPS OHP - Latitude - Longitude - Altitude   
   label $base.f.lab_altaz \
     -bg $private(color,back) -fg $private(color,text) \
     -font $private(font2) -justify left
   pack $base.f.lab_altaz -fill none -pady 0 -padx 10  -anchor w 
   
   #--- modele de pointage
   label $base.f.lab_model \
     -bg $private(color,back) -fg $private(color,text) \
     -font $private(font2) \
     -text "$::caption(displaycoord,modeldescr) : " 
   pack $base.f.lab_model -fill y -pady 0 -padx 10 -anchor w 

   pack $base.f -fill both -expand 1 
   
   bind  $private(base).f <Configure> [list onResizeWindow %w %h ]
   
}


#------------------------------------------------------------
# onResizeWindow
#   redimmensionne les polices de caractere qund on change la taille de la fenetre
#
#------------------------------------------------------------

proc onResizeWindow { width height } {
   variable private
   set nbCol  35
   set nbLine 20
   
   
   set widthFontSize [expr int($width / $nbCol) ]
   set heightFontSize [expr int($height / $nbLine) ]
   if { $widthFontSize < $heightFontSize } {
      set fontSize1 $widthFontSize
   } else {
      set fontSize1 $heightFontSize           
   }
   if {  $fontSize1 < 8 } {
      set fontSize1 8
   }
   
   set  fontSize23 [expr int($fontSize1 /2)]
   if {  $fontSize23 < 8 } {
      set fontSize23 8
   }
   
   font configure displayCoordFont1 -size $fontSize1
   font configure displayCoordFont2 -size $fontSize23
   font configure displayCoordFont3 -size $fontSize23
}


######################################################################
#
#  gestion de la socket de communication avec le serveur de coordonn©es
#
#######################################################################

#------------------------------------------------------------
# startConnectionLoop
#   Ouvre une socket en lecture pour recevoir les notifications des coordonnees 
#   Les parametres de la sconnexion sont dans des variables globales
#     adresse/nom de host = ::conf(displaycoord,serverHost)
#     port = ::conf(displaycoord,serverPort)
#
#------------------------------------------------------------
proc ::displaycoord::startConnectionLoop { } {
   variable private
   
   #--- je connecte au serveur de coordonnees 
   #--- avec un délai de 5 secondes pour ne pas retarder le demarrage d'Audela 
   #--- si cet outil est lancé au démarrage d'audela 
   set private(connexionTimerId) [after 5000 ::displaycoord::openSocketCoord ]  
   
}
#------------------------------------------------------------
# openSocketCoord
#   Ouvre une socket en lecture pour recevoir les notifications des coordonnees 
#   Les parametres de la sconnexion sont dans des variables globales
#     adresse/nom de host = ::conf(displaycoord,serverHost)
#     port = ::conf(displaycoord,serverPort)
#
#------------------------------------------------------------
proc ::displaycoord::openSocketCoord { } {
   variable private
   
   set catchError [ catch {
      
      if { $private(socketChannel) != "" } {
          ::displaycoord::closeSocketCoord 
      }
      
      set private(socketChannel) [socket $::conf(displaycoord,serverHost) $::conf(displaycoord,serverPort) ]
      #---  -translation binary -encoding binary
      fconfigure $private(socketChannel) -buffering line -blocking true -translation binary -encoding binary
      fileevent $private(socketChannel) readable [list ::displaycoord::readSocketCoord ]
      
      set private(etat) "CONNECTED"
      #--- j'affiche l'affichage (je fais comme si on avais recu une notification)
      readSocketCoord
      set private(connexionTimerId) ""
      ###console::disp "::displaycoord::openSocketCoord $private(etat)\n"
   } ]
   if { $catchError != 0 } {
      #--- j'affiche l'etat 
      readSocketCoord
      console::disp "::displaycoord::openSocketCoord $private(etat)\n"
      #--- je fais une nouvelle tentative dans 30s 
      set private(connexionTimerId) [after 30000 ::displaycoord::openSocketCoord ]    
   }
}

#------------------------------------------------------------
# closeSocketCoord
#   ferme la socket
#
#------------------------------------------------------------
proc ::displaycoord::closeSocketCoord { } {
   variable private
   if { $private(socketChannel) != "" } {
      close $private(socketChannel)
      set private(socketChannel) ""
      #--- j'affiche l'affichage (je fais comme si on avais recu une notification)
      readSocketCoord      
   } 
   
   #--- j'arrete le timer de reconnexion s'il etait lancé 
   if { $private(connexionTimerId) != "" } {
      after cancel $private(connexionTimerId)
      set private(connexionTimerId) ""
   }
 
}

#------------------------------------------------------------
# readSocketSophie
#   envoie des donnes vers le PC de guidage
#
#------------------------------------------------------------
proc ::displaycoord::readSocketCoord {  } {
   variable private

   set catchError [catch {
      set tuh    "00"
      set tum    "00"
      set tus    "00"
      set tslh   "00"
      set tslm   "00"
      set tsls   "00"
      set angle_h "00h 00m 00.00s"
      set az     "0000.00"
      set alt    "+0000.00"
      set site_name "OHP"     
      set pos_obs "Latitude: 43°55'54.8''  Longitude: 05°42'56.5''  Altitude: 633.9 m"
      set ra     "00h00m00s00" 
      set dec    "+00d00m00s00" 
      set ra0    "00h00m00s00" 
      set dec0   "+00d00m00s00" 
      set raCalage "A"
      set decCalage "A"
      
      if { $private(socketChannel) == "" } {
         #--- j'affiche les valeurs par defaut
            set private(etat) "NOT_CONNECTED"
         } else {
         if { [eof $private(socketChannel)] } {
            #--- la connexion est ferme par le serveur
            set private(etat) "NOT_CONNECTED"
            ::displaycoord::closeSocketCoord
            #--- je lance une tentative de connexion dans 30s
            set private(connexionTimerId) [after 30000 ::displaycoord::openSocketCoord ]
         } else {
            set private(etat) "CONNECTED"
            set notification [gets $private(socketChannel) ]
            
            #--- je recupere les valeurs 
            # !RADEC COORD [Code retour] [TU] [TS] [alpha_corr] [delta_corr] [alpha_0] [delta_0] [calage_alpha] [calage_delta] @\n
            # Code retour
            #     0   OK
            #     5   Probleme moteur
            #     6   Butées atteintes
            # TU
            #     Format= ISO8601
            # TS
            #     Format= ISO8601
            # alpha_corr : coordonn©e alpha corrig©e avec le mod¨le de pointage
            #     Format = "%02dh%02dm%05.2fs"
            # delta_corr : coordonn©e delta corrig©e avec le mod¨le de pointage
            #     Format = "%1s%02dd%02dm%05.2fs"
            # alpha_0 : coordonn©e brute alpha
            #     Format = "%02dh%02dm%05.2fs"
            # delta_0 : coordonn©e brute delta
            #     Format = "%1s%02dd%02dm%05.2fs"
            # calage_alpha
            #     C : cal©
            #     D : d©cal©
            #     A : autre : ni cal© ni d©cal©
            # calage_delta
            #     C : cal©
            #     D : d©cal©
            #     A : autre : ni cal© ni d©cal©
            
            set nbVar [scan $notification "!RADEC COORD %d %s %s %s %s %s %s %s %s @" returnCode tu ts ra dec ra0 dec0 raCalage decCalage ]
            if { $nbVar == 9 } {
               if { $returnCode == 0 } {
                  scan $tu "%dh%dm%ds" tuh tum tus
                  scan $ts "%dh%dm%ds" tslh tslm tsls
               } else {
                  console::affiche_erreur "readSocketCoord warning returnCode=$returnCode notification=$notification\n"   
               }
            } else {
               #--- le message n'a pas le format attendu 
               console::affiche_erreur "readSocketCoord error nbVar=$nbVar notification=$notification\n"
            }         
         }
      }
      
      switch $private(etat) {
         "NOT_CONNECTED" { 
            set etat $::caption(displaycoord,nonConnecte)          
         }
         "CONNECTED" {
            set etat $::caption(displaycoord,connecte) 
         }
      }  

      if { $raCalage != "C" && $raCalage != "D" && $raCalage != "A" } {
         set raCalage "A"
      }
      if { $decCalage != "C" && $decCalage != "D" && $decCalage != "A" } {
         set decCalage "A"
      }

   
      #--- Affichage de l'etat
      $private(base).f.lab_etat configure  -text $etat
      
      #--- Affichage temps (TU, TSL) et coordonn©es (ALPHA, DELTA, ANGLE HORAIRE, Azimut, hauteur du t©lescope)
      # $private(base).f.lab_tu configure    -text " $::caption(displaycoord,tu)   ${tuh}h ${tum}m ${tus}s"
      # $private(base).f.lab_tsl configure   -text " $::caption(displaycoord,tsl)  ${tslh}h ${tslm}m ${tsls}s"
      # $private(base).f.lab_ha configure    -text " $::caption(displaycoord,angle_horaire)   $angle_h"
      # $private(base).f.lab_altaz configure -text " $pos_obs\t\t$::caption(displaycoord,azimut) ${az}°\t$::caption(displaycoord,hauteur) ${alt}°"
      $private(base).f.lab_tu configure    -text "$::caption(displaycoord,tu)  ${tuh}h ${tum}m ${tus}s"
      $private(base).f.lab_tsl configure   -text "$::caption(displaycoord,tsl)  ${tslh}h ${tslm}m ${tsls}s"
      $private(base).f.lab_ha configure    -text "$::caption(displaycoord,angle_horaire)   $angle_h"
      $private(base).f.lab_ohp configure   -text "$site_name"
      $private(base).f.lab_altaz configure -text "$pos_obs \n$::caption(displaycoord,azimut) ${az}°\t$::caption(displaycoord,hauteur) ${alt}°"
      
      set alpha "[string range $ra 0 1]h [string range $ra 3 4]m [string range $ra) 6 7].[string range $ra 9 10]s "
      set delta "[string range $dec 0 2]° [string range $dec 4 5]'   [string range $dec) 7 8].[string range $dec 10 10]0'' "
      ###$private(base).f.lab_ad configure -text  " $::caption(displaycoord,ad) \t  $alpha  \t $::caption(displaycoord,calage,$raCalage)"
      ###$private(base).f.lab_dec configure -text " $::caption(displaycoord,dec) \t $delta \t $::caption(displaycoord,calage,$decCalage)"
      $private(base).f.coord.alpha_value configure -text $alpha
      $private(base).f.coord.alpha_calage configure -text $::caption(displaycoord,calage,$raCalage)
      $private(base).f.coord.delta_value configure -text $delta
      $private(base).f.coord.delta_calage configure -text $::caption(displaycoord,calage,$decCalage)
      
      #--- coordonnées brutes (sans correction du modèle de pointage)
      set alpha0 "[string range $ra0 0 1]h [string range $ra0 3 4]m [string range $ra0) 6 7].[string range $ra0 9 10]s "
      set delta0 "[string range $dec0 0 2]° [string range $dec0 4 5]'   [string range $dec0) 7 8].[string range $dec0 10 10]0'' "
      $private(base).f.lab_coord0 configure -text "$::caption(displaycoord,ad0) $alpha0 \n$::caption(displaycoord,dec0) $delta0"
      
   }]
   if { $catchError != 0 } {
      console::affiche_erreur ":$::errorInfo\n"
   }
     
}
