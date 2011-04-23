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
      multivisu    { return 1 }
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
   variable private

   package require http
   #--- Pour le cryptage des nom et password
   package require base64

   #--- Inititalisation de variables de configuration
   if { ! [ info exists ::conf(getdss,$visuNo,geometry) ] } { set ::conf(getdss,$visuNo,geometry) "410x595+50+50" }

   #--- Initialisation du nom de la fenetre
   set private($visuNo,This) $in.getdss
}

#------------------------------------------------------------
# deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::getdss::deletePluginInstance { visuNo } {
   variable private

   if { [ winfo exists $private($visuNo,This) ] } {
      #--- je ferme la fenetre si l'utilisateur ne l'a pas deja fait
      ::getdss::quitter $visuNo
   }
}

#------------------------------------------------------------
# startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::getdss::startTool { visuNo } {
   #--- J'ouvre la fenetre
   ::getdss::createPanel $visuNo
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
proc ::getdss::confToWidget { visuNo } {
   variable widget

   set widget(getdss,$visuNo,geometry) "$::conf(getdss,$visuNo,geometry)"
}

#------------------------------------------------------------
# widgetToConf
#    Charge les variables locales dans des variables de configuration
#------------------------------------------------------------
proc ::getdss::widgetToConf { visuNo } {
   variable widget

   set ::conf(getdss,$visuNo,geometry) "$widget(getdss,$visuNo,geometry)"
}

#------------------------------------------------------------
# createPanel
#    prepare la creation de la fenetre de l'outil
#------------------------------------------------------------
proc ::getdss::createPanel { visuNo } {
   variable widget
   variable private
   global caption

   #--- Initialisation de variables
   set private($visuNo,NomObjet)  M
   set private($visuNo,debut)     ""
   set private($visuNo,fin)       ""
   set private($visuNo,ad)        "02h02m53.5s"
   set private($visuNo,dec)       "-12d29m14.3s"
   set private($visuNo,hauteur)   20.0
   set private($visuNo,largeur)   30.0
   set private($visuNo,catalogue) ""
   set private($visuNo,rep)       [ file join $::audace(rep_images) @@IMAGES-DSS ]

   #--- Si la connexion internet passe par un proxy, mettre a yes sinon a no
   set private($visuNo,proxy) no

   #--- Initialisation de variables du Proxy
   set private($visuNo,proxyname)     NomServeurProxy_ou_IP
   set private($visuNo,proxyport)     8080
   set private($visuNo,proxyuser)     user_du_proxy
   set private($visuNo,proxypassword) password_du_proxy

   # --- Initialisation
   ::getdss::confToWidget $visuNo

   #--- Si la fenetre existe deja
   if { [winfo exists $private($visuNo,This)] } {
      wm withdraw $private($visuNo,This)
      wm deiconify $private($visuNo,This)
      focus -force $private($visuNo,This).f9.b1
      return
   }

   #--- Construction de l'interface
   toplevel $private($visuNo,This)
   wm geometry $private($visuNo,This) $widget(getdss,$visuNo,geometry)
   wm resizable $private($visuNo,This) 1 1
   wm deiconify $private($visuNo,This)
   wm title $private($visuNo,This) "$caption(getdss,menu) (visu$visuNo)"
   wm protocol $private($visuNo,This) WM_DELETE_WINDOW "::getdss::quitter $visuNo"

   #--- Boutons
   frame $private($visuNo,This).f00 -borderwidth 5
   pack $private($visuNo,This).f00 -side top -fill x

   button $private($visuNo,This).f00.ouvrir -text $caption(getdss,ouvrir) -command "::getdss::ouvrir $visuNo"
   pack $private($visuNo,This).f00.ouvrir -side left -padx 10 -ipadx 5 -fill x -expand 1
   button $private($visuNo,This).f00.enregistrer -text $caption(getdss,enregistrer) -command ::getdss::enregistrer
   pack $private($visuNo,This).f00.enregistrer -side left -padx 10 -ipadx 5 -fill x -expand 1

   #--- Radio boutons
   frame $private($visuNo,This).f0 -borderwidth 5
   pack $private($visuNo,This).f0 -side top -fill x

   radiobutton $private($visuNo,This).f0.but1 -variable ::getdss::private($visuNo,NomObjet) -text $caption(getdss,messier) -value M
   pack $private($visuNo,This).f0.but1 -side left
   radiobutton $private($visuNo,This).f0.but2 -variable ::getdss::private($visuNo,NomObjet) -text $caption(getdss,ngc) -value NGC
   pack $private($visuNo,This).f0.but2 -side left
   radiobutton $private($visuNo,This).f0.but3 -variable ::getdss::private($visuNo,NomObjet) -text $caption(getdss,ic) -value IC
   pack $private($visuNo,This).f0.but3 -side left
   radiobutton $private($visuNo,This).f0.but4 -variable ::getdss::private($visuNo,NomObjet) -text $caption(getdss,coord) -value Coord
   pack $private($visuNo,This).f0.but4 -side left

   $private($visuNo,This).f0.but1 configure -command "::getdss::active_objet $visuNo"
   $private($visuNo,This).f0.but2 configure -command "::getdss::active_objet $visuNo"
   $private($visuNo,This).f0.but3 configure -command "::getdss::active_objet $visuNo"
   $private($visuNo,This).f0.but4 configure -command "::getdss::active_objet $visuNo"

   #--- Indices de debut et de fin de recherche
   frame $private($visuNo,This).f01 -borderwidth 5
   pack $private($visuNo,This).f01 -side top -fill x

   #--- Entry pour l'indice de debut
   label $private($visuNo,This).f01.l1 -text $caption(getdss,debut)
   pack $private($visuNo,This).f01.l1 -side left
   entry $private($visuNo,This).f01.e1 -textvariable ::getdss::private($visuNo,debut) -width 6 -justify center
   pack $private($visuNo,This).f01.e1 -side left -fill x -padx 5
   bind $private($visuNo,This).f01.e1 <Enter> "::getdss::active_objet $visuNo"
   bind $private($visuNo,This).f01.e1 <Leave> "::getdss::active_objet $visuNo"

   #--- Entry pour l'indice de fin
   label $private($visuNo,This).f01.l2 -text $caption(getdss,fin)
   pack $private($visuNo,This).f01.l2 -side left
   entry $private($visuNo,This).f01.e2 -textvariable ::getdss::private($visuNo,fin) -width 6 -justify center
   pack $private($visuNo,This).f01.e2 -side left -fill x -padx 5
   bind $private($visuNo,This).f01.e2 <Enter> "::getdss::active_objet $visuNo"
   bind $private($visuNo,This).f01.e2 <Leave> "::getdss::active_objet $visuNo"

   #--- Entry pour les coordonnees
   frame $private($visuNo,This).f001 -borderwidth 5
   pack $private($visuNo,This).f001 -side top -fill x

   #--- Entry pour l'AD
   label $private($visuNo,This).f001.lAD -text $caption(getdss,ad)
   pack $private($visuNo,This).f001.lAD -side left -anchor w
   entry $private($visuNo,This).f001.eAD -textvariable ::getdss::private($visuNo,ad) -width 12
   pack $private($visuNo,This).f001.eAD -side left -padx 5
   bind $private($visuNo,This).f001.eAD <Enter> "::getdss::active_objet $visuNo"
   bind $private($visuNo,This).f001.eAD <Leave> "::getdss::active_objet $visuNo"

   #--- Entry la Dec.
   label $private($visuNo,This).f001.lDec -text $caption(getdss,dec)
   pack $private($visuNo,This).f001.lDec -side left -anchor w
   entry $private($visuNo,This).f001.eDec -textvariable ::getdss::private($visuNo,dec) -width 12
   pack $private($visuNo,This).f001.eDec -side left -padx 5
   bind $private($visuNo,This).f001.eDec <Enter> "::getdss::active_objet $visuNo"
   bind $private($visuNo,This).f001.eDec <Leave> "::getdss::active_objet $visuNo"

   #--- Texte de rappel de la recherche
   frame $private($visuNo,This).f02 -borderwidth 5
   pack $private($visuNo,This).f02 -side top -fill x

   label $private($visuNo,This).f02.l1
   pack $private($visuNo,This).f02.l1 -side left

   #--- Choix du catalogue dans lequel on recupere l'image
   frame $private($visuNo,This).lb -borderwidth 2
   pack $private($visuNo,This).lb -side top -fill x
   label $private($visuNo,This).lb.l1 -text $caption(getdss,catalogue)
   pack $private($visuNo,This).lb.l1 -side left -padx 5
   listbox   $private($visuNo,This).lb.lb1 -width 25 -height 8 -borderwidth 2 -relief sunken -yscrollcommand [list $private($visuNo,This).lb.scrollbar set]
   pack      $private($visuNo,This).lb.lb1 -side left -anchor nw
   scrollbar $private($visuNo,This).lb.scrollbar -orient vertical -command [list $private($visuNo,This).lb.lb1 yview]
   pack      $private($visuNo,This).lb.scrollbar -side left -fill y

   $private($visuNo,This).lb.lb1 insert end "POSS2/UKSTU Red"
   $private($visuNo,This).lb.lb1 insert end "POSS2/UKSTU Blue"
   $private($visuNo,This).lb.lb1 insert end "POSS2/UKSTU IR"
   $private($visuNo,This).lb.lb1 insert end "POSS1 Red"
   $private($visuNo,This).lb.lb1 insert end "POSS1 Blue"
   $private($visuNo,This).lb.lb1 insert end "Quick-V"
   $private($visuNo,This).lb.lb1 insert end "HST Phase 2 (GSC2)"
   $private($visuNo,This).lb.lb1 insert end "HST Phase 2 (GSC1)"

   #--- Largeur de l'image
   frame $private($visuNo,This).f1 -borderwidth 5
   pack $private($visuNo,This).f1 -side top -fill x

   label $private($visuNo,This).f1.l1 -text $caption(getdss,largeur)
   pack $private($visuNo,This).f1.l1 -side left
   entry $private($visuNo,This).f1.e1 -textvariable ::getdss::private($visuNo,largeur) -width 10
   pack $private($visuNo,This).f1.e1 -side left -padx 5

   #--- Hauteur de l'image
   frame $private($visuNo,This).f2 -borderwidth 5
   pack $private($visuNo,This).f2 -side top -fill x

   label $private($visuNo,This).f2.l2 -text $caption(getdss,hauteur)
   pack $private($visuNo,This).f2.l2 -side left
   entry $private($visuNo,This).f2.e2 -textvariable ::getdss::private($visuNo,hauteur) -width 10
   pack $private($visuNo,This).f2.e2 -side left -padx 5

   #--- Repertoire de sauvegarde de l'image
   frame $private($visuNo,This).f3 -borderwidth 5
   pack $private($visuNo,This).f3 -side top -fill x

   label $private($visuNo,This).f3.l3 -text $caption(getdss,repertoire)
   pack $private($visuNo,This).f3.l3 -side left
   entry $private($visuNo,This).f3.e3 -textvariable ::getdss::private($visuNo,rep) -width 40
   pack $private($visuNo,This).f3.e3 -side left -padx 5
   $private($visuNo,This).f3.e3 xview end
   button $private($visuNo,This).f3.b3 -text $caption(getdss,parcourir) -command "::getdss::getdir $visuNo"
   pack $private($visuNo,This).f3.b3 -side left

   #--- Compresser le fichier
   frame $private($visuNo,This).f4 -borderwidth 5
   pack $private($visuNo,This).f4 -side top -fill x

   checkbutton $private($visuNo,This).f4.cbcompresse -text $caption(getdss,compression) -variable ::getdss::private($visuNo,compresse) -onvalue yes -offvalue no
   pack $private($visuNo,This).f4.cbcompresse -side left

   #--- Proxy
   frame $private($visuNo,This).f5 -borderwidth 5
   pack $private($visuNo,This).f5 -side top -fill x

   checkbutton $private($visuNo,This).f5.cbproxy -text $caption(getdss,proxy) -variable ::getdss::private($visuNo,proxy) -onvalue yes -offvalue no
   pack $private($visuNo,This).f5.cbproxy -side left
   $private($visuNo,This).f5.cbproxy configure -command "::getdss::active_proxy $visuNo"
   set private($visuNo,proxy) no

   #--- Frames pour les donnees du Proxy
   frame $private($visuNo,This).f6 -borderwidth 5
   pack $private($visuNo,This).f6 -side top -fill x

   frame $private($visuNo,This).f6.f7 -borderwidth 5
   pack $private($visuNo,This).f6.f7 -side left -fill x

   frame $private($visuNo,This).f6.f8 -borderwidth 5
   pack $private($visuNo,This).f6.f8 -side left -fill x

   #--- Proxy : Nom
   label $private($visuNo,This).f6.f7.l7 -text $caption(getdss,nom)
   pack $private($visuNo,This).f6.f7.l7 -side top -anchor w
   entry $private($visuNo,This).f6.f8.e7 -textvariable ::getdss::private($visuNo,proxyname) -width 30
   pack $private($visuNo,This).f6.f8.e7 -side top -padx 5

   #--- Proxy : Port
   label $private($visuNo,This).f6.f7.l8 -text $caption(getdss,port)
   pack $private($visuNo,This).f6.f7.l8 -side top -anchor w
   entry $private($visuNo,This).f6.f8.e8 -textvariable ::getdss::private($visuNo,proxyport) -width 30
   pack $private($visuNo,This).f6.f8.e8 -side top -padx 5

   #--- Proxy : Utilisateur
   label $private($visuNo,This).f6.f7.l9 -text $caption(getdss,user)
   pack $private($visuNo,This).f6.f7.l9 -side top -anchor w
   entry $private($visuNo,This).f6.f8.e9 -textvariable ::getdss::private($visuNo,proxyuser) -width 30
   pack $private($visuNo,This).f6.f8.e9 -side top -padx 5

   #--- Proxy : Mot de passe
   label $private($visuNo,This).f6.f7.l10 -text $caption(getdss,password)
   pack $private($visuNo,This).f6.f7.l10 -side top -anchor w
   entry $private($visuNo,This).f6.f8.e10 -textvariable ::getdss::private($visuNo,proxypassword) -width 30
   pack $private($visuNo,This).f6.f8.e10 -side top -padx 5

   #--- Boutons
   frame $private($visuNo,This).f9 -borderwidth 5
   pack $private($visuNo,This).f9 -side bottom -fill x

   button $private($visuNo,This).f9.b1 -text $caption(getdss,lancer) -command "::getdss::recuperation $visuNo"
   pack $private($visuNo,This).f9.b1 -side left -padx 3 -ipadx 5 -ipady 5
   button $private($visuNo,This).f9.b2 -text $caption(getdss,fermer) -command "::getdss::quitter $visuNo"
   pack $private($visuNo,This).f9.b2 -side right -padx 3 -ipadx 5 -ipady 5
   button $private($visuNo,This).f9.b3 -text $caption(getdss,aide) -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::getdss::getPluginType ] ] \
   [ ::getdss::getPluginDirectory ] [ ::getdss::getPluginHelp ]"
   pack $private($visuNo,This).f9.b3 -side right -padx 3 -ipadx 5 -ipady 5

   bind $private($visuNo,This) <Key-Escape> "::getdss::quitter $visuNo"

   #--- La fenetre est active
   focus $private($visuNo,This)

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $private($visuNo,This) <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $private($visuNo,This)

   #--- Creation de la fenetre qui servira a l'affichage des messages d'attente
   toplevel .dialog($visuNo)
   label .dialog($visuNo).l1 -text "" -width 50
   pack .dialog($visuNo).l1 -side top
   pack forget .dialog($visuNo)

   wm withdraw .dialog($visuNo)

   #--- Fenetre centree
   set x [expr {([winfo screenwidth .]-[winfo width .dialog($visuNo)])/2}]
   set y [expr {([winfo screenheight .]-[winfo height .dialog($visuNo)])/2}]
   wm geometry  .dialog($visuNo) +$x+$y
   wm resizable .dialog($visuNo) 1 1
   wm title     .dialog($visuNo) $caption(getdss,imagerecup)
   wm protocol  .dialog($visuNo) WM_DELETE_WINDOW "::getdss::quitter $visuNo"

   ::getdss::active_objet $visuNo
   ::getdss::active_proxy $visuNo

   #--- Cache la fenetre wish par defaut
   wm withdraw .
   #--- Met le focus sur le bouton 'Lancer'
   focus -force $private($visuNo,This).f9.b1
}

#------------------------------------------------------------
# buildProxyHeaders
#    genere la ligne d'authentification qui sera renvoyee au proxy
#------------------------------------------------------------
proc ::getdss::buildProxyHeaders { u p } {
   variable private

   if { $private($visuNo,proxy) == "yes" } {
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
proc ::getdss::Charge_Objet_SIMBAD { visuNo objet } {
   variable private
   global audace ferreur

   #--- Gestion d'un proxy
   #--- Identification du browser, pas indispensable
   ::http::config -useragent "Mozilla/4.75 (X11; U; Linux 2.2.17; i586; Nav)"
   if { $private($visuNo,proxy) == "yes" } {
      ::http::config -proxyhost $private($visuNo,proxyname) -proxyport $private($visuNo,proxyport)
      ::http::ProxyRequired $private($visuNo,proxyname)
   } else {
      ::http::ProxyRequired ""
   }

   #--- URL de la requete CGI 1 permettant de transformer le nom en coordonnees
   set BASE_URL http://stdatu.stsci.edu/cgi-bin/dss_form/

   if { $private($visuNo,NomObjet) != "Coord" } {

      #--- Creation de la requete CGI 1
      #--- Format : nom_du_champs   valeur_du_champ, etc ... (repete n fois)
      #--- On a besoin que du champs 'target' dont on precise la valeur $objet
      set query [::http::formatQuery target $objet]

      #--- Lance la requete 1
      if { $private($visuNo,proxy) == "yes" } {
         set token1 [::http::geturl $BASE_URL -query $query -headers [::getdss::buildProxyHeaders $private($visuNo,proxyuser) $private($visuNo,proxypassword)] ]
      } else {
         set token1 [::http::geturl $BASE_URL -query $query]
      }

      set data1 [::http::data $token1]

      ::http::cleanup $token1

      update

      #--- Recherche les chaines qui contiennent les coordonnees retournees par la requete
      #--- set res [regexp -inline {(<a href="/dss/dss_help.html#coordinates">RA</a> <input name=r value=")([0-9]+ [0-9]+ [0-9]+[[:punct:]][0-9]+)(" >)} $data1 ]
      #--- syntaxe de regexp :
      #---  - entre {} l'ensemble de la chaine non ambigue a reperer
      #---  - entre () les differentes parties a isoler pour etre mis dans des variables distinctes
      #---    Le plus dur est de trouver une maniere sans ambiguite pour identifier le champs
      #---    que l'on desire isoler
      set ra ""
      set dec ""
      regexp -all {([0-9]+ [0-9]+ [0-9]+[[:punct:]][0-9]+)(" >)} $data1 match ra filler2
      regexp -all {([+-][0-9]+ [0-9]+ [[:punct:]]?[0-9]+[[:punct:]][0-9])(">)} $data1 match dec filler2

   } else {

      set had [ lindex [ split $private($visuNo,ad) h ] 0 ]
      set mad [ lindex [ split [ lindex [ split $private($visuNo,ad) h ] 1 ] m ] 0 ]
      set sad [ lindex [ split [ lindex [ split [ lindex [ split $private($visuNo,ad) h ] 1 ] m ] 1 ] s ] 0 ]

      set ddec [ lindex [ split $private($visuNo,dec) d ] 0 ]
      set mdec [ lindex [ split [ lindex [ split $private($visuNo,dec) d ] 1 ] m ] 0 ]
      set sdec [ lindex [ split [ lindex [ split [ lindex [ split $private($visuNo,dec) d ] 1 ] m ] 1 ] s ] 0 ]

      set ra  "$had $mad $sad"
      set dec "$ddec $mdec $sdec"

   }

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

      set private($visuNo,catalogue) [$private($visuNo,This).lb.lb1 get [$private($visuNo,This).lb.lb1 curselection]]

      switch -exact -- $private($visuNo,catalogue) {
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

      set query [::http::formatQuery v $catal r $ra d $dec e J2000 h $private($visuNo,hauteur) w $private($visuNo,largeur) f fits c none fov NONE v3 ""]

      #--- Lance la requete 2
      if { $private($visuNo,proxy) == "yes" } {
         set token2 [::http::geturl ${BASE_URL} -query $query -headers [::getdss::buildProxyHeaders $private($visuNo,proxyuser) $private($visuNo,proxypassword)] ]
      } else {
         set token2 [::http::geturl ${BASE_URL} -query $query]
      }

      #--- Recuperation dans $html de l'image proprement dite
      set html  [::http::data $token2]
      ::http::cleanup $token2

      update

      #--- Enregistrement de l'image (en memoire) dans un fichier
      if { $private($visuNo,NomObjet) != "Coord" } {
         set fichier_objet ${objet}.fit
      } else {
         set fichier_objet ${objet}.AD$private($visuNo,ad).DEC$private($visuNo,dec).fit
      }
      set fp [open $fichier_objet w]
      fconfigure $fp -translation binary
      puts -nonewline $fp $html
      close $fp

      #--- Si on demande un format .gz, alors on charge l'image en memoire et on sauve avec l'option .gz
      #--- Les catch permettent de trapper certaines erreurs dues au serveur d'images
      #--- (pas bien compris pourquoi) afin de ne pas planter le script et permettre de charger les images suivantes
      if { $private($visuNo,compresse) == "yes" } {
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
proc ::getdss::recuperation { visuNo } {
   variable private
   global caption old_rep ferreur

   #--- Test sur les indices de debut et de fin
   if { $private($visuNo,NomObjet) != "Coord" } {
      if { $private($visuNo,debut) == "" } {
         tk_messageBox -title $caption(getdss,attention) -message $caption(getdss,texte3)
         return
      }
      if { $private($visuNo,fin) == "" } {
         tk_messageBox -title $caption(getdss,attention) -message $caption(getdss,texte4)
         return
      }
   }

   #--- Creation du repertoire si inexistant et si creat vaut 'y'
   if { $private($visuNo,rep) != "" } {
      if { ! [file isdirectory $private($visuNo,rep)] } {
         set chx [ tk_messageBox -type yesno -title $caption(getdss,repinexistant) \
            -message $caption(getdss,nouveaurep) ]
         if { $chx == "yes" } {
            file mkdir $private($visuNo,rep)
         }
      }
   }

   if { [file isdirectory $private($visuNo,rep)] } {
      #--- Sauvegarde le repertoire de base
      set old_rep [pwd]
      cd $private($visuNo,rep)

      #--- Ouverture du fichier des erreurs
      set ferreur [open notloaded.txt a]

      set ligne "[clock format [clock seconds] -format "20%y %m %d - %X"] - "
      if { $private($visuNo,NomObjet) != "Coord" } {
         append ligne [ format $caption(getdss,texte1a) $private($visuNo,NomObjet)$private($visuNo,debut) $private($visuNo,NomObjet)$private($visuNo,fin) ]
      } else {
         append ligne [ format $caption(getdss,texte1b) $private($visuNo,ad) $private($visuNo,dec) ]
      }
      puts $ferreur $ligne
      flush $ferreur

      #--- Recuperation des objets choisis
      if { $private($visuNo,NomObjet) != "Coord" } {
         for {set x $private($visuNo,debut)} {$x <= $private($visuNo,fin)} {incr x} {
            .dialog($visuNo).l1 configure -text [ format $caption(getdss,chargement) $private($visuNo,NomObjet)$x ]
            update
            wm deiconify .dialog($visuNo)

            set catchError [ catch { ::getdss::Charge_Objet_SIMBAD $visuNo $private($visuNo,NomObjet)$x } ]
            if { $catchError != "0" } {
               wm iconify .dialog($visuNo)
               tk_messageBox -title $caption(getdss,attention) -message $caption(getdss,texte2)
               return
            }

            wm iconify .dialog($visuNo)
            focus -force $private($visuNo,This).f9.b1
            update
         }
      } else {
         .dialog($visuNo).l1 configure -text [ format $caption(getdss,chargement1) $private($visuNo,ad) $private($visuNo,dec) ]
         update
         wm deiconify .dialog($visuNo)

         set catchError [ catch { ::getdss::Charge_Objet_SIMBAD $visuNo $private($visuNo,NomObjet) } ]
         if { $catchError != "0" } {
            wm iconify .dialog($visuNo)
            tk_messageBox -title $caption(getdss,attention) -message $caption(getdss,texte2)
            return
         }

         wm iconify .dialog($visuNo)
         focus -force $private($visuNo,This).f9.b1
         update
      }

      wm withdraw .dialog($visuNo)

      #--- Fermeture du fichier des erreurs
      puts $ferreur "-------------------------------------------------"
      close $ferreur

      #--- Restaure le repertoire de base
      cd $old_rep

      tk_messageBox -title $caption(getdss,attention) -message $caption(getdss,fintraitement)
   }

   focus -force $private($visuNo,This).f9.b1
}

#------------------------------------------------------------
# active_proxy
#    active et desactive les widgets du proxy
#------------------------------------------------------------
proc ::getdss::active_proxy { visuNo } {
   variable private

   if { $private($visuNo,proxy) == "yes" } {
      $private($visuNo,This).f6.f8.e7 configure -state normal
      $private($visuNo,This).f6.f8.e8 configure -state normal
      $private($visuNo,This).f6.f8.e9 configure -state normal
      $private($visuNo,This).f6.f8.e10 configure -state normal
   } else {
      $private($visuNo,This).f6.f8.e7 configure -state disable
      $private($visuNo,This).f6.f8.e8 configure -state disable
      $private($visuNo,This).f6.f8.e9 configure -state disable
      $private($visuNo,This).f6.f8.e10 configure -state disable
   }
}

#------------------------------------------------------------
# active_objet
#    active et desactive les widgets des indices et des
#    coordonnees
#    active la mise a jour du rappel de recherche
#------------------------------------------------------------
proc ::getdss::active_objet { visuNo } {
   variable private
   global caption

   if { $private($visuNo,NomObjet) == "Coord" } {
      $private($visuNo,This).f01.e1 configure -state disable
      $private($visuNo,This).f01.e2 configure -state disable
      $private($visuNo,This).f001.eAD configure -state normal
      $private($visuNo,This).f001.eDec configure -state normal
   } else {
      $private($visuNo,This).f01.e1 configure -state normal
      $private($visuNo,This).f01.e2 configure -state normal
      $private($visuNo,This).f001.eAD configure -state disable
      $private($visuNo,This).f001.eDec configure -state disable
   }

   if { $private($visuNo,NomObjet) == "M" } {
      $private($visuNo,This).f02.l1 configure -text [ format $caption(getdss,Messier) $private($visuNo,debut) $private($visuNo,fin) ]
    }
   if { $private($visuNo,NomObjet) == "NGC" } {
      $private($visuNo,This).f02.l1 configure -text [ format $caption(getdss,NGC) $private($visuNo,debut) $private($visuNo,fin) ]
    }
   if { $private($visuNo,NomObjet) == "IC" } {
      $private($visuNo,This).f02.l1 configure -text [ format $caption(getdss,IC) $private($visuNo,debut) $private($visuNo,fin) ]
    }
   if { $private($visuNo,NomObjet) == "Coord" } {
      $private($visuNo,This).f02.l1 configure -text [ format $caption(getdss,champ) $private($visuNo,ad) $private($visuNo,dec) ]
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
proc ::getdss::ouvrir { visuNo } {
   variable private
   global caption

   set filetypes [ list [ list "$caption(getdss,fichierparam)" ".ini" ] ]
   set fichier [tk_getOpenFile -title $caption(getdss,ouvrirconfig) \
      -filetypes $filetypes \
      -initialdir "$::audace(rep_home)" ]

   #--- Creation d'un interpreteur
   set tmpinterp [interp create]

   #--- Interprete le fichier de configuration
   catch {interp eval $tmpinterp "source \"$fichier\""}

   #--- Charge dans le tableau private_temp les donnees de l'interpreteur temporaire
   array set private_temp [interp eval $tmpinterp "array get private"]

   #--- Supprime l'interpreteur temporaire
   interp delete $tmpinterp

   #--- Charge dans private de l'interpreteur courant les valeur du private_temp
   array set private [array get private_temp]

   active_proxy $visuNo
}

#------------------------------------------------------------
# enregistrer
#    enregistre le fichier de configuration
#------------------------------------------------------------
proc ::getdss::enregistrer { } {
   variable private
   global caption

   set filetypes [ list [ list "$caption(getdss,fichierparam)" ".ini" ] ]
   set fichier [tk_getSaveFile -title $caption(getdss,sauveconfig) \
      -filetypes $filetypes \
      -initialdir "$::audace(rep_home)" ]

   set fp [open [::getdss::ajout_ini ${fichier}] w]
   foreach a [array names private] {
      puts $fp "set private($a) \"[lindex [array get private $a] 1]\""
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
proc ::getdss::getdir { visuNo } {
   variable private

   set old_dir $private($visuNo,rep)

   set rep [ ::getdss::getdirname ]
   if { $rep != "" } {
      set private($visuNo,rep) $rep
   }
}

#------------------------------------------------------------
# recupPosition
#    Recupere la position de la fenetre
#------------------------------------------------------------
proc ::getdss::recupPosition { visuNo } {
   variable private
   variable widget

   set widget(getdss,$visuNo,geometry) [ wm geometry $private($visuNo,This) ]
   ::getdss::widgetToConf $visuNo
}

#------------------------------------------------------------
# quitter
#    ferme l'interface
#------------------------------------------------------------
proc ::getdss::quitter { visuNo } {
   variable private
   global old_rep

   #--- Recupere la position de la fenetre
   ::getdss::recupPosition $visuNo

   #--- Restaure le repertoire initial
   catch {cd $old_rep}

   destroy .dialog($visuNo)
   destroy $private($visuNo,This)
}

