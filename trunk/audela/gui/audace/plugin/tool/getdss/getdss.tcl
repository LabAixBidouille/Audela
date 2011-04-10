#
# Fichier : getdss.tcl
# Description : Recuperation d'images du DSS (Digital Sky Survey)
# Auteur : Guillaume SPITZER
# Mise à jour $Id$
#

#============================================================
# Declaration du namespace getdss
#    initialise le namespace
#============================================================
namespace eval ::getdss {
   package provide getdss 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] getdss.cap ]
}

#------------------------------------------------------------
# getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::getdss::getPluginTitle { } {
   global caption

   return "$caption(getdss,menu)"
}

#------------------------------------------------------------
# getPluginHelp
#    retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::getdss::getPluginHelp { } {
   return "getdss.htm"
}

#------------------------------------------------------------
# getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::getdss::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# getPluginDirectory
#    retourne le type de plugin
#------------------------------------------------------------
proc ::getdss::getPluginDirectory { } {
   return "getdss"
}

#------------------------------------------------------------
# getPluginOS
#    retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::getdss::getPluginOS { } {
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
proc ::getdss::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "file" }
      subfunction1 { return "getdss" }
      display      { return "window" }
   }
}

#------------------------------------------------------------
# initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::getdss::initPlugin { tkbase } {

}

#------------------------------------------------------------
# createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::getdss::createPluginInstance { { in "" } { visuNo 1 } } {
   variable This
   variable This

   package require http
   #--- Pour le cryptage des nom et password
   package require base64

   #--- Inititalisation de variables de configuration
   if { ! [ info exists ::conf(getdss,geometry) ] } { set ::conf(getdss,geometry) "410x570+50+50" }

   set This $::audace(base).getdss
}

#------------------------------------------------------------
# deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::getdss::deletePluginInstance { visuNo } {
   variable This

   if { [ winfo exists $This ] } {
      #--- je ferme la fenetre si l'utilisateur ne l'a pas deja fait
      ::getdss::quitter
   }
}

#------------------------------------------------------------
# startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::getdss::startTool { visuNo } {
   #--- J'ouvre la fenetre
   ::getdss::createPanel
}

#------------------------------------------------------------
# stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::getdss::stopTool { visuNo } {
   #--- Rien a faire, car la fenetre est fermee par l'utilisateur
}

#------------------------------------------------------------
# confToWidget
#    Charge les variables de configuration dans des variables locales
#------------------------------------------------------------
proc ::getdss::confToWidget { } {
   variable widget

   set widget(getdss,geometry) "$::conf(getdss,geometry)"
}

#------------------------------------------------------------
# widgetToConf
#    Charge les variables locales dans des variables de configuration
#------------------------------------------------------------
proc ::getdss::widgetToConf { } {
   variable widget

   set ::conf(getdss,geometry) "$widget(getdss,geometry)"
}

#------------------------------------------------------------
# createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::getdss::createPanel { } {
   variable This
   variable widget
   global caption param

   #--- Initialisation de variables
   set param(NomObjet) M
   set param(hauteur)  20.0
   set param(largeur)  30.0
   set param(rep)      [ file join $::audace(rep_images) @@IMAGES-DSS ]

   #--- Si la connexion internet passe par un proxy, mettre a yes sinon a no
   set param(proxy) no

   #--- Initialisation de variables du Proxy
   set param(proxyname)     NomServeurProxy_ou_IP
   set param(proxyport)     8080
   set param(proxyuser)     user_du_proxy
   set param(proxypassword) password_du_proxy

   # --- Initialisation
   ::getdss::confToWidget

   #--- Si la fenetre existe deja
   if { [winfo exists $This] } {
      wm withdraw $This
      wm deiconify $This
      focus -force $This.f9.b1
      return
   }

   #--- Construction de l'interface
   toplevel $This
   wm geometry $This $widget(getdss,geometry)
   wm resizable $This 1 1
   wm deiconify $This
   wm title $This "$caption(getdss,menu)"
   wm protocol $This WM_DELETE_WINDOW ::getdss::quitter

   #--- Boutons
   frame $This.f00 -borderwidth 5
   pack $This.f00 -side top -fill x

   button $This.f00.ouvrir -text $caption(getdss,ouvrir) -command ::getdss::ouvrir
   pack $This.f00.ouvrir -side left -padx 10 -ipadx 5 -fill x -expand 1
   button $This.f00.enregistrer -text $caption(getdss,enregistrer) -command ::getdss::enregistrer
   pack $This.f00.enregistrer -side left -padx 10 -ipadx 5 -fill x -expand 1

   #--- Radio boutons
   frame $This.f0 -borderwidth 5
   pack $This.f0 -side top -fill x

   radiobutton $This.f0.but1 -variable param(NomObjet) -text $caption(getdss,messier) -value M
   pack $This.f0.but1 -side left
   radiobutton $This.f0.but2 -variable param(NomObjet) -text $caption(getdss,ngc) -value NGC
   pack $This.f0.but2 -side left
   radiobutton $This.f0.but3 -variable param(NomObjet) -text $caption(getdss,ic) -value IC
   pack $This.f0.but3 -side left

   $This.f0.but1 configure -command ::getdss::active_objet
   $This.f0.but2 configure -command ::getdss::active_objet
   $This.f0.but3 configure -command ::getdss::active_objet

   #--- Indices de debut et de fin de recherche
   frame $This.f01 -borderwidth 5
   pack $This.f01 -side top -fill x

   label $This.f01.l1 -text $caption(getdss,debut)
   pack $This.f01.l1 -side left
   entry $This.f01.e1 -textvariable param(debut) -width 6 -justify center
   pack $This.f01.e1 -side left -fill x -padx 5
   bind $This.f01.e1 <Enter> ::getdss::active_objet
   bind $This.f01.e1 <Leave> ::getdss::active_objet

   label $This.f01.l2 -text $caption(getdss,fin)
   pack $This.f01.l2 -side left
   entry $This.f01.e2 -textvariable param(fin) -width 6 -justify center
   pack $This.f01.e2 -side left -fill x -padx 5
   bind $This.f01.e2 <Enter> ::getdss::active_objet
   bind $This.f01.e2 <Leave> ::getdss::active_objet

   #--- Texte de rappel de la recherche
   frame $This.f02 -borderwidth 5
   pack $This.f02 -side top -fill x

   label $This.f02.l1
   pack $This.f02.l1 -side left

   #--- Choix du catalogue dans lequel on recupere l'image
   frame $This.lb -borderwidth 2
   pack $This.lb -side top -fill x
   label $This.lb.l1 -text $caption(getdss,catalogue)
   pack $This.lb.l1 -side left -padx 5
   listbox   $This.lb.lb1 -width 25 -height 8 -borderwidth 2 -relief sunken -yscrollcommand [list $This.lb.scrollbar set]
   pack      $This.lb.lb1 -side left -anchor nw
   scrollbar $This.lb.scrollbar -orient vertical -command [list $This.lb.lb1 yview]
   pack      $This.lb.scrollbar -side left -fill y

   $This.lb.lb1 insert end "POSS2/UKSTU Red"
   $This.lb.lb1 insert end "POSS2/UKSTU Blue"
   $This.lb.lb1 insert end "POSS2/UKSTU IR"
   $This.lb.lb1 insert end "POSS1 Red"
   $This.lb.lb1 insert end "POSS1 Blue"
   $This.lb.lb1 insert end "Quick-V"
   $This.lb.lb1 insert end "HST Phase 2 (GSC2)"
   $This.lb.lb1 insert end "HST Phase 2 (GSC1)"

   #--- Largeur de l'image
   frame $This.f1 -borderwidth 5
   pack $This.f1 -side top -fill x

   label $This.f1.l1 -text $caption(getdss,largeur)
   pack $This.f1.l1 -side left
   entry $This.f1.e1 -textvariable param(largeur) -width 10
   pack $This.f1.e1 -side left -padx 5

   #--- Hauteur de l'image
   frame $This.f2 -borderwidth 5
   pack $This.f2 -side top -fill x

   label $This.f2.l2 -text $caption(getdss,hauteur)
   pack $This.f2.l2 -side left
   entry $This.f2.e2 -textvariable param(hauteur) -width 10
   pack $This.f2.e2 -side left -padx 5

   #--- Repertoire de sauvegarde de l'image
   frame $This.f3 -borderwidth 5
   pack $This.f3 -side top -fill x

   label $This.f3.l3 -text $caption(getdss,repertoire)
   pack $This.f3.l3 -side left
   entry $This.f3.e3 -textvariable param(rep) -width 40
   pack $This.f3.e3 -side left -padx 5
   $This.f3.e3 xview end
   button $This.f3.b3 -text $caption(getdss,parcourir) -command ::getdss::getdir
   pack $This.f3.b3 -side left

   #--- Compresser le fichier
   frame $This.f4 -borderwidth 5
   pack $This.f4 -side top -fill x

   checkbutton $This.f4.cbcompresse -text $caption(getdss,compression) -variable param(compresse) -onvalue yes -offvalue no
   pack $This.f4.cbcompresse -side left

   #--- Proxy
   frame $This.f5 -borderwidth 5
   pack $This.f5 -side top -fill x

   checkbutton $This.f5.cbproxy -text $caption(getdss,proxy) -variable param(proxy) -onvalue yes -offvalue no
   pack $This.f5.cbproxy -side left
   $This.f5.cbproxy configure -command { ::getdss::active_proxy ; ::getdss::active_objet }
   set param(proxy) no

   #--- Frames pour les donnees du Proxy
   frame $This.f6 -borderwidth 5
   pack $This.f6 -side top -fill x

   frame $This.f6.f7 -borderwidth 5
   pack $This.f6.f7 -side left -fill x

   frame $This.f6.f8 -borderwidth 5
   pack $This.f6.f8 -side left -fill x

   #--- Proxy : Nom
   label $This.f6.f7.l7 -text $caption(getdss,nom)
   pack $This.f6.f7.l7 -side top -anchor w
   entry $This.f6.f8.e7 -textvariable param(proxyname) -width 30
   pack $This.f6.f8.e7 -side top -padx 5

   #--- Proxy : Port
   label $This.f6.f7.l8 -text $caption(getdss,port)
   pack $This.f6.f7.l8 -side top -anchor w
   entry $This.f6.f8.e8 -textvariable param(proxyport) -width 30
   pack $This.f6.f8.e8 -side top -padx 5

   #--- Proxy : Utilisateur
   label $This.f6.f7.l9 -text $caption(getdss,user)
   pack $This.f6.f7.l9 -side top -anchor w
   entry $This.f6.f8.e9 -textvariable param(proxyuser) -width 30
   pack $This.f6.f8.e9 -side top -padx 5

   #--- Proxy : Mot de passe
   label $This.f6.f7.l10 -text $caption(getdss,password)
   pack $This.f6.f7.l10 -side top -anchor w
   entry $This.f6.f8.e10 -textvariable param(proxypassword) -width 30
   pack $This.f6.f8.e10 -side top -padx 5

   #--- Boutons
   frame $This.f9 -borderwidth 5
   pack $This.f9 -side bottom -fill x

   button $This.f9.b1 -text $caption(getdss,lancer) -command ::getdss::recuperation
   pack $This.f9.b1 -side left -padx 3 -ipadx 5 -ipady 5
   button $This.f9.b2 -text $caption(getdss,fermer) -command ::getdss::quitter
   pack $This.f9.b2 -side right -padx 3 -ipadx 5 -ipady 5
   button $This.f9.b3 -text $caption(getdss,aide) -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::getdss::getPluginType ] ] \
   [ ::getdss::getPluginDirectory ] [ ::getdss::getPluginHelp ]"
   pack $This.f9.b3 -side right -padx 3 -ipadx 5 -ipady 5

   bind $This <Key-Escape> {::getdss::quitter}

   #--- La fenetre est active
   focus $This

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This

   #--- Creation de la fenetre qui servira a l'affichage des messages d'attente
   toplevel .dialog
   label .dialog.l1 -text "" -width 50
   pack .dialog.l1 -side top
   pack forget .dialog

   wm withdraw .dialog

   #--- Fenetre centree
   set x [expr {([winfo screenwidth .]-[winfo width .dialog])/2}]
   set y [expr {([winfo screenheight .]-[winfo height .dialog])/2}]
   wm geometry  .dialog +$x+$y
   wm resizable .dialog 1 1
   wm title     .dialog $caption(getdss,imagerecup)
   wm protocol  .dialog WM_DELETE_WINDOW ::getdss::quitter

   ::getdss::active_proxy

   #--- Cache la fenetre wish par defaut
   wm withdraw .
   #--- Mets le focus sur le bouton 'Lancer'
   focus -force $This.f9.b1
}

#------------------------------------------------------------
# buildProxyHeaders
#    genere la ligne d'authentification qui sera renvoyee au proxy
#------------------------------------------------------------
proc ::getdss::buildProxyHeaders { u p } {
   global param

   if { $param(proxy) == "yes" } {
      return [list "Proxy-Authorization" [concat "Basic" [base64::encode $u:$p]]]
   } else {
      return ""
   }
}

#------------------------------------------------------------
# Charge_Objet_SIMBAD
#    procedure de recuperation d'une image dont les coordonnees sont obtenues par SIMBAD
#
#    exemple : objet peut etre M27 IC434 NGC15
#------------------------------------------------------------
proc ::getdss::Charge_Objet_SIMBAD { objet } {
   variable This
   global audace param ferreur

   #--- Gestion d'un proxy
   #--- Identification du browser, pas indispensable
   ::http::config -useragent "Mozilla/4.75 (X11; U; Linux 2.2.17; i586; Nav)"
   if { $param(proxy) == "yes" } {
      ::http::config -proxyhost $param(proxyname) -proxyport $param(proxyport)
      ::http::ProxyRequired $param(proxyname)
   } else {
      ::http::ProxyRequired ""
   }

   #--- URL de la requete CGI 1 permettant de transformer le nom en coordonnees
   set BASE_URL http://stdatu.stsci.edu/cgi-bin/dss_form/

   #--- Creation de la requete CGI 1
   #--- Format : nom_du_champs   valeur_du_champ, etc ... (repete n fois)
   #--- On a besoin que du champs 'target' dont on precise la valeur $objet
   set query [::http::formatQuery target $objet]

   #--- Lance la requete 1
   if { $param(proxy) == "yes" } {
      set token1 [::http::geturl $BASE_URL -query $query -headers [::getdss::buildProxyHeaders $param(proxyuser) $param(proxypassword)] ]
   } else {
      set token1 [::http::geturl $BASE_URL -query $query]
   }

   set data1 [::http::data $token1]

   ::http::cleanup $token1

   update

   #--- Recherche les chaines qui contiennent les coordonnees retournees par la requete
   #--- set res [regexp -inline {(<a href="/dss/dss_help.html#coordinates">RA</a>  <input name=r value=")([0-9]+ [0-9]+ [0-9]+[[:punct:]][0-9]+)(" >)} $data1 ]
   #--- syntaxe de regexp :
   #---  - entre {} l'ensemble de la chaine non ambigue a reperer
   #---  - entre () les differentes parties a isoler pour etre mis dans des variables distinctes
   #---    Le plus dur est de trouver une maniere sans ambiguite pour identifier le champs
   #---    que l'on desire isoler
   set ra ""
   set dec ""
   regexp -all {([0-9]+ [0-9]+ [0-9]+[[:punct:]][0-9]+)(" >)} $data1 match ra filler2
   regexp -all {([+-][0-9]+ [0-9]+ [[:punct:]]?[0-9]+[[:punct:]][0-9])(">)} $data1 match dec filler2

   #--- Ici, $ra et $dec contiennent les coordonnees de l'objet

   #--- Format de la ligne de la 2eme requete html :
   #--- http://stdatu.stsci.edu/cgi-bin/dss_search?v=poss2ukstu&r=16+41+41.44&d=%2B36+27+36.9&e=J2000&h=15.0&w=15.0&f=gif&c=none&fov=NONE&v3=
   #--- URL de la requete CGI 2
   set BASE_URL http://stdatu.stsci.edu/cgi-bin/dss_search/

   #--- Creation de la requete 2 (Obtention de l'image)
   #--- Ici, plusieurs parametres composent la requete CGI donc le parametre de ::http::formatQuery
   #--- comporte plusieurs couple champs - valeur_du_champs
   #--- Ici, les champs sont : v, r, d, e, h, w, f, c, fov, v3
   #--- v=poss2ukstu_red&r=00+31+45.00&d=-05+09+11.0&e=J2000&h=15.0&w=15.0&f=gif&c=none&fov=NONE&v3=
   #--- set query [::http::formatQuery v poss2ukstu_red r 00+31+45.00 d -05+09+11.0 e J2000 h 15.0 w 15.0 f fits c none fov NONE v3 ""]
   if { [catch {set a $ra}] } { set ra "" }
   if { [catch {set a $dec}] } { set dec "" }

   if { ($ra != "") && ($dec != "") } {

      set catalogue [$This.lb.lb1 get [$This.lb.lb1 curselection]]

      switch -exact -- $catalogue {
         "POSS2/UKSTU Red" { set catal poss2ukstu_red }
         "POSS2/UKSTU Blue" { set catal poss2ukstu_blue }
         "POSS2/UKSTU IR" { set catal poss2ukstu_ir }
         "POSS1 Red" { set catal poss1_red }
         "POSS1 Blue" { set catal poss1_blue }
         "Quick-V" { set catal quickv }
         "HST Phase 2 (GSC2)" { set catal phase2_gsc2 }
         "HST Phase 2 (GSC1)" { set catal phase2_gsc1 }
         default { set catal poss2ukstu_red }
      }

      set query [::http::formatQuery v $catal r $ra d $dec e J2000 h $param(hauteur) w $param(largeur) f fits c none fov NONE v3 ""]

      #--- Lance la requete 2
      if { $param(proxy) == "yes" } {
         set token2 [::http::geturl ${BASE_URL} -query $query -headers [::getdss::buildProxyHeaders $param(proxyuser) $param(proxypassword)] ]
      } else {
         set token2 [::http::geturl ${BASE_URL} -query $query]
      }

      #--- Recuperation dans $html de l'image proprement dite
      set html  [::http::data $token2]
      ::http::cleanup $token2

      update

      #--- Enregistrement de l'image (en memoire) dans un fichier
      set fichier_objet ${objet}.fit
      set fp [open $fichier_objet w]
      fconfigure $fp -translation binary
      puts -nonewline $fp $html
      close $fp

      #--- Si on demande un format .gz, alors on charge l'image en memoire et on sauve avec l'option .gz
      #--- Les catch permettent de trapper certaines erreurs dues au serveur d'images
      #--- (pas bien compris pourquoi) afin de ne pas planter le script et permettre de charger les images suivantes
      if { $param(compresse) == "yes" } {
         catch { buf[ ::confVisu::getBufNo $audace(visuNo) ] load $fichier_objet }
         catch { buf[ ::confVisu::getBufNo $audace(visuNo) ] compress gzip }
         catch { buf[ ::confVisu::getBufNo $audace(visuNo) ] save $fichier_objet }
      }
   } else {
      puts $ferreur $objet
      flush $ferreur
   }
}

#------------------------------------------------------------
# recuperation
#    Procedure principale a completer pour pouvoir recuperer n'importe quoi !!!
#    Quelques exemples :
#    En fait, on passe en parametre a la fonction Charge_Objet_SIMBAD le nom que l'on met normalement
#    sur la page WEB
#------------------------------------------------------------
proc ::getdss::recuperation { } {
   variable This
   global caption param old_rep ferreur

   #--- Test sur les indices de debut et de fin
   if { $param(debut) == "" } {
      tk_messageBox -title $caption(getdss,attention) -message $caption(getdss,texte5)
      return
   }
   if { $param(fin) == "" } {
      tk_messageBox -title $caption(getdss,attention) -message $caption(getdss,texte6)
      return
   }

   #--- Creation du repertoire si inexistant et si creat vaut 'y'
   if { $param(rep) != "" } {
      if { ! [file isdirectory $param(rep)] } {
         set chx [ tk_messageBox -type yesno -title $caption(getdss,repinexistant) \
            -message $caption(getdss,nouveaurep) ]
         if { $chx == "yes" } {
            file mkdir $param(rep)
         }
      }
   }

   if { [file isdirectory $param(rep)] } {
      #--- Sauvegarde le repertoire de base
      set old_rep [pwd]
      cd $param(rep)

      #--- Ouverture du fichier des erreurs
      set ferreur [open notloaded.txt a]

      set ligne "[clock format [clock seconds] -format "20%y %m %d - %X"] - "
      append ligne "$caption(getdss,texte1) $param(NomObjet)$param(debut) $caption(getdss,texte2) $param(NomObjet)$param(fin) "
      append ligne "$caption(getdss,texte3)"
      puts $ferreur $ligne
      flush $ferreur

      #--- Recuperation des objets choisis
      for {set x $param(debut)} {$x <= $param(fin)} {incr x} {
         .dialog.l1 configure -text "$caption(getdss,chargement) $param(NomObjet)$x"
         update
         wm deiconify .dialog

         set catchError [ catch { ::getdss::Charge_Objet_SIMBAD $param(NomObjet)$x } ]
         if { $catchError != "0" } {
            wm iconify .dialog
            tk_messageBox -title $caption(getdss,attention) -message $caption(getdss,texte4)
            return
         }

         wm iconify .dialog
         focus -force $This.f9.b1
         update
      }

      wm withdraw .dialog

      #--- Fermeture du fichier des erreurs
      puts $ferreur "-------------------------------------------------"
      close $ferreur

      #--- Restaure le repertoire de base
      cd $old_rep

      tk_messageBox -title $caption(getdss,attention) -message $caption(getdss,fintraitement)
   }

   focus -force $This.f9.b1
}

#------------------------------------------------------------
# active_proxy
#    active et desactive les widgets du proxy
#------------------------------------------------------------
proc ::getdss::active_proxy { } {
   variable This
   global param

   if { $param(proxy) == "yes" } {
      $This.f6.f8.e7 configure -state normal
      $This.f6.f8.e8 configure -state normal
      $This.f6.f8.e9 configure -state normal
      $This.f6.f8.e10 configure -state normal
   } else {
      $This.f6.f8.e7 configure -state disable
      $This.f6.f8.e8 configure -state disable
      $This.f6.f8.e9 configure -state disable
      $This.f6.f8.e10 configure -state disable
   }
}

#------------------------------------------------------------
# active_objet
#    active la mise a jour du rappel de recherche
#------------------------------------------------------------
proc ::getdss::active_objet { } {
   variable This
   global param
   global caption

   if { $param(NomObjet) == "M" } {
      $This.f02.l1 configure -text "$caption(getdss,debMessier) $param(debut) $caption(getdss,finMessier) $param(fin)"
    }
   if { $param(NomObjet) == "NGC" } {
      $This.f02.l1 configure -text "$caption(getdss,debNGC)$param(debut) $caption(getdss,finNGC)$param(fin)"
    }
   if { $param(NomObjet) == "IC" } {
      $This.f02.l1 configure -text "$caption(getdss,debIC)$param(debut) $caption(getdss,finIC)$param(fin)"
    }

   return 1
}

#------------------------------------------------------------
# ajout_ini
#    ajoute l'extension .ini au fichier de configuration
#------------------------------------------------------------
proc ::getdss::ajout_ini { fic } {
   if { [file extension $fic] != ".ini" } {
      return "${fic}.ini"
   } else {
      return ${fic}
   }
}

#------------------------------------------------------------
# ouvrir
#    ouvre le fichier de configuration
#------------------------------------------------------------
proc ::getdss::ouvrir { } {
   global caption param

   set fichier [tk_getOpenFile -title $caption(getdss,ouvrirconfig) \
      -filetypes {{{$caption(getdss,fichierparam)} {.ini}} } \
      -initialdir "$::audace(rep_home)" ]

   #--- Creation d'un interpreteur
   set tmpinterp [interp create]

   #--- Interprete le fichier de parametres
   catch {interp eval $tmpinterp "source \"$fichier\""}

   #--- Charge dans le tableau param_temp les donnees de l'interpreteur temporaire
   array set param_temp [interp eval $tmpinterp "array get param"]

   #--- Supprime l'interpreteur temporaire
   interp delete $tmpinterp

   #--- Charge dans param de l'interpreteur courant les valeur du param_temp
   array set param [array get param_temp]

   active_proxy
}

#------------------------------------------------------------
# enregistrer
#    enregistre le fichier de configuration
#------------------------------------------------------------
proc ::getdss::enregistrer { } {
   global caption param

   set fichier [tk_getSaveFile -title $caption(getdss,sauveconfig) \
      -filetypes {{{$caption(getdss,fichierparam)} {.ini}} } \
      -initialdir "$::audace(rep_home)" ]

   set fp [open [::getdss::ajout_ini ${fichier}] w]
   foreach a [array names param] {
      puts $fp "set param($a) \"[lindex [array get param $a] 1]\""
   }
   close $fp
}

#------------------------------------------------------------
# getdirname
#    navigateur de repertoire
#------------------------------------------------------------
proc ::getdss::getdirname { { creat y } } {
   global caption

   set dirname [tk_chooseDirectory -title $caption(getdss,selectrep) \
      -initialdir $::audace(rep_images)]
   set len [ string length $dirname ]
   set folder "$dirname"
   #--- Ajoute un / a la fin s'il n'y en a pas
   if { $len > "0" } {
      set car [ string index "$dirname" [ expr $len-1 ] ]
      if { $car != "/" } {
         append folder "/"
      }
      set dirname $folder
   }

   #--- Creation du repertoire si inexistant et si creat vaut 'y'
   if { $dirname != "" } {
      if { $creat == "y" } {
         if { ! [file isdirectory $dirname] } {
            file mkdir $dirname
         }
      }
   }

   return $dirname
}

#------------------------------------------------------------
# getdir
#    fournit le repertoire
#------------------------------------------------------------
proc ::getdss::getdir { } {
   global param

   set old_dir $param(rep)

   set rep [ ::getdss::getdirname ]
   if { $rep != "" } {
      set param(rep) $rep
   }
}

#------------------------------------------------------------
# recupPosition
#    Recupere la position de la fenetre
#------------------------------------------------------------
proc ::getdss::recupPosition { } {
   variable This
   variable widget

   set widget(getdss,geometry) [ wm geometry $This ]
   ::getdss::widgetToConf
}

#------------------------------------------------------------
# quitter
#    ferme l'interface
#------------------------------------------------------------
proc ::getdss::quitter { } {
   variable This
   global old_rep

   #--- Recupere la position de la fenetre
   ::getdss::recupPosition

   #--- Restaure le repertoire initial
   catch {cd $old_rep}

   destroy .dialog
   destroy $This
}

