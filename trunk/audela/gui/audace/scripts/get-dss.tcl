#########################################################################
#
# Récupération d'images du DSS (Digital Sky Survey)
#
#     par Guillaume Spitzer
#
# Créer    en  Aout 2005
#
# Modifier en Décembre 2005
#   - Ajout d'une fenetre de dialogue
#   - Ajout d'un fichier log des objets non téléchargés
#   - Possibilité de charger/enregistrer des fichiers de paramètres
#
# Modifier en Juillet 2007
#   - Ajout d'une listebox pour selectionné le catalogue de survey.
#
#########################################################################

package require http
# pour le cryptage des nom/password
package require base64

#
# --- Début des paramètres du script ---
#  (paramètres par défaut)
#  (Il y a maintenant une boite de dialogue)

set param(hauteur) 20.0
set param(largeur) 30.0
set param(rep) D:/@@IMAGES-DSS

# Si la connexion internet passe par un proxy, mettre à yes sinon à no.
set param(proxy) no

# Parametres du Proxy (uniquement s'il y a un proxy, sinon mettre 'no' à la ligne ci-dessus
# -------------------
set proxy NomServeurProxy_ou_IP
set port 8080
set user user_du_proxy
set password password_du_proxy

#
# --- Fin des paramètres par défaut du script
#




#
# --- Génére la ligne d'authentification qui sera renvoyée au proxy.
#
proc buildProxyHeaders {u p} {
  global param

  if { $param(proxy) == "yes" } {
    return [list "Proxy-Authorization" \
           [concat "Basic" [base64::encode $u:$p]]]
  } else {
    return ""
  }
}

#
# --- Procédure de récupération d'une image dont les coordonnées sont obtenues par SIMBAD
#
# ex: objet peut être M27 IC434 NGC15
#

proc Charge_Objet_SIMBAD {objet} {
  global param ferreur

  #
  # --- Gestion d'un proxy
  #
  # Identification du browser. Pas indispensable
  ::http::config -useragent "Mozilla/4.75 (X11; U; Linux 2.2.17; i586; Nav)"
  if { $param(proxy) == "yes" } {
    ::http::config -proxyhost $param(proxyname) -proxyport $param(proxyport)
    ::http::ProxyRequired $param(proxyname)
  } else {
    ::http::ProxyRequired ""
  }

  # URL de la requète CGI 1 permettant de transformer le nom en coordonnées.
  set BASE_URL http://stdatu.stsci.edu/cgi-bin/dss_form/

  # Création de la requète CGI 1
  # format : nom_du_champs   valeur_du_champ, etc ... (répété n fois)
  # On a besoin que du champs 'target' dont on précise la valeur $objet.
  set query [::http::formatQuery target $objet]

  # Lance la requete 1
  if { $param(proxy) == "yes" } {
    set token1 [::http::geturl $BASE_URL -query $query -headers [buildProxyHeaders $param(proxyuser) $param(proxypassword)] ]
    } else {
    set token1 [::http::geturl $BASE_URL -query $query]
  }


  set data1  [::http::data $token1]

  ::http::cleanup $token1

  update

  # Recherche les chaines qui contiennent les coordonnées retournées par la requete
  # set res [regexp -inline {(<a href="/dss/dss_help.html#coordinates">RA</a>  <input name=r value=")([0-9]+ [0-9]+ [0-9]+[[:punct:]][0-9]+)(" >)} $data1 ]
  # syntaxe de regexp :
  #  - entre {} l'ensemble de la chaine non ambigue à repérer
  #  - entre () les différentes parties à isoler pour être mis dans des variables distinct.
  #    Le plus dur est de trouver une manière sans ambiguité pour identifier le champs
  #    que l'on désire isoler.
  set ra ""
  set dec ""
  regexp -all {([0-9]+ [0-9]+ [0-9]+[[:punct:]][0-9]+)(" >)} $data1 match ra filler2
  regexp -all {([+-][0-9]+ [0-9]+ [[:punct:]]?[0-9]+[[:punct:]][0-9])(">)} $data1 match dec filler2

  # Ici, $ra et $dec contienne les coordonnées de l'objet

  # Format de la ligne de la 2eme requete html :
  # http://stdatu.stsci.edu/cgi-bin/dss_search?v=poss2ukstu&r=16+41+41.44&d=%2B36+27+36.9&e=J2000&h=15.0&w=15.0&f=gif&c=none&fov=NONE&v3=
  # Incident du 13/07/2007 :
  # Origine :
  #   Plantage à cause d'un changement du nom de catalogue codé en dur dans le programme
  # Résolution :
  # Ajout d'une boite de dialogue permettant le choix du catalogue parmis :
  #  <option value="poss2ukstu_red" selected>   POSS2/UKSTU Red</option>
  #  <option value="poss2ukstu_blue" >          POSS2/UKSTU Blue</option>
  #  <option value="poss2ukstu_ir" >            POSS2/UKSTU IR</option>
  #  <option value="poss1_red" >                POSS1 Red</option>
  #  <option value="poss1_blue" >               POSS1 Blue</option>
  #  <option value="quickv" >                   Quick-V</option>
  #  <option value="phase2_gsc2" >              HST Phase 2 (GSC2)</option>
  #  <option value="phase2_gsc1" >              HST Phase 2 (GSC1)</option>

  # URL de la requète CGI 2
  set BASE_URL http://stdatu.stsci.edu/cgi-bin/dss_search/

  # Création de la requète 2 (Obtention de l'image)
  # Ici, plusieurs paramètres composent la requète CGI donc le paramètre de ::http::formatQuery
  # comporte plusieurs couple champs - valeur_du_champs
  # Ici, les champs sont : v, r, d, e, h, w, f, c, fov, v3
  # v=poss2ukstu_red&r=00+31+45.00&d=-05+09+11.0&e=J2000&h=15.0&w=15.0&f=gif&c=none&fov=NONE&v3=
  #set query [::http::formatQuery v poss2ukstu_red r 00+31+45.00 d -05+09+11.0 e J2000 h 15.0 w 15.0 f fits c none fov NONE v3 ""]
  if { [catch {set a $ra}] } { set ra "" }
  if { [catch {set a $dec}] } { set dec "" }

  if { ($ra != "") && ($dec != "") } {

    set catalogue [.pre.lb.lb1 get [.pre.lb.lb1 curselection]]

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

    # Lance la requete 2
    if { $param(proxy) == "yes" } {
      set token2 [::http::geturl ${BASE_URL} -query $query -headers [buildProxyHeaders $param(proxyuser) $param(proxypassword)] ]
    } else {
      set token2 [::http::geturl ${BASE_URL} -query $query]
    }


    # Récupération dans $html de l'image proprement dite.
    set html  [::http::data $token2]
    ::http::cleanup $token2

    update

    # Enregistrement de l'image (en mémoire) dans un fichier
    set fichier_objet ${objet}.fit
    set fp [open $fichier_objet w]
    fconfigure $fp -translation binary
    puts -nonewline $fp $html
    close $fp

    # Si on demande un format .gz, alors on charge l'image en mémoire et on sauve avec l'option .gz
    # Les catch permettent de trapper certaines erreurs dûes au serveur d'images
    # (pas bien compris pourquoi) afin de ne pas planter le script et permettre de charger les images suivantes.
    if { $param(compresse) == "yes" } {
      catch {buf1 load $fichier_objet}
      catch {buf1 compress gzip}
      catch {buf1 save $fichier_objet}
    }
  } else {
    puts $ferreur $objet
    flush $ferreur
  }
}

proc Affiche_Objet {objet} {
  visu1 disp
  return
}



# Procédure principale à compléter pour pouvoir récupérer n'importe quoi !!!
# Quelques exemples ...
# En fait, on passe en paramètre à la fonction Charge_Objet_SIMBAD le nom que l'on met normalement
# sur la page WEB

proc recuperation {} {
  global param old_rep ferreur

  # Création du répertoire si inexistant et si creat vaut 'y'
  if { $param(rep) != "" } {
    if { ! [file isdirectory $param(rep)] } {
      set chx [tk_messageBox -type yesno -title "Répertoire $param(rep) inexistant" \
            -message "Voulez-vous créer ce répertoire ?"]
      if { $chx == "yes" } {
        file mkdir $param(rep)
      }
    }
  }

  if { [file isdirectory $param(rep)] } {
    # sauvegarde le répertoire de base
    set old_rep [pwd]
    cd $param(rep)

    # Ouverture du fichier des erreurs
    set ferreur [open notloaded.txt a]

    set ligne "[clock format [clock seconds] -format "20%y %m %d - %X"] - "
    append ligne "Lors du chargement des objets $param(NomObjet)$param(debut) à $param(NomObjet)$param(fin) "
    append ligne "les objets suivants étaient manquant :"
    puts $ferreur $ligne
    flush $ferreur

    #
    # Recuperation des objets choisis
    #
    for {set x $param(debut)} {$x <= $param(fin)} {incr x} {
      .dialog.l1 configure -text "chargement de $param(NomObjet)$x"
      update
      wm deiconify .dialog

      Charge_Objet_SIMBAD $param(NomObjet)$x

      # Affiche_Objet $param(NomObjet)$x

      wm iconify .dialog
      focus -force .pre.f10.b2
      update
    }

    wm withdraw .dialog

    # fermeture du fichier des erreurs
    puts $ferreur "-------------------------------------------------"
    close $ferreur

    # restaure le répertoire de base
    cd $old_rep

    tk_messageBox -message "FIN DU TRAITEMENT"
  }

  focus -force .pre.f10.b2
}


proc active_proxy {} {
  global param

  if { $param(proxy) == "yes" } {
    .pre.f6.e6 configure -state normal
    .pre.f7.e7 configure -state normal
    .pre.f8.e8 configure -state normal
    .pre.f9.e9 configure -state normal
  } else {
    .pre.f6.e6 configure -state disable
    .pre.f7.e7 configure -state disable
    .pre.f8.e8 configure -state disable
    .pre.f9.e9 configure -state disable
  }
}

proc active_objet {} {
  global param

  if { $param(NomObjet) == "M" } {
    .pre.f02.l1 configure -text "Objets : Messier $param(debut) à Messier $param(fin)"
   }
  if { $param(NomObjet) == "NGC" } {
    .pre.f02.l1 configure -text "Objets : NGC$param(debut) à NGC$param(fin)"
   }
  if { $param(NomObjet) == "IC" } {
    .pre.f02.l1 configure -text "Objets : IC$param(debut) à IC$param(fin)"
   }

  return 1
}

proc ajout_ini {fic} {

  if { [file extension $fic] != ".ini" } {
    return "${fic}.ini"
  } else {
    return ${fic}
  }
}

proc ouvrir {} {
  global param

  set fichier [tk_getOpenFile -title "Ouvrir un fichier de paramètres" \
    -filetypes {{{Fichier paramètres} {.ini}} } \
    -initialdir "c:/" ]

  # crée un interpréteur
  set tmpinterp [interp create]

  # interprète le fichier de paramètres
  catch {interp eval $tmpinterp "source \"$fichier\""}

  # charge dans le tableau param_temp les données de l'interpréteur temporaire
  array set param_temp [interp eval $tmpinterp "array get param"]

  # supprime l'interpreteur temporaire
  interp delete $tmpinterp

  # charge dans param de l'interpréteur courant les valeur du param_temp
  array set param [array get param_temp]

  active_proxy
}

proc enregistrer {} {
  global param

  set fichier [tk_getSaveFile -title "Sauvegarder un fichier de paramètres" \
    -filetypes {{{Fichier paramètres} {.ini}} } \
    -initialdir "c:/" ]

  set fp [open [ajout_ini ${fichier}] w]
  foreach a [array names param] {
    puts $fp "set param($a) \"[lindex [array get param $a] 1]\""
  }
  close $fp
}

proc getdirname { {titre  "Selectionnez un repertoire"} { repinit "C:/" } { creat y } } {

  set dirname [tk_chooseDirectory -title $titre \
    -initialdir $repinit]
  set len [ string length $dirname ]
  set folder "$dirname"
  # Ajoute un / à la fin s'il n'y en a pas
  if { $len > "0" } {
    set car [ string index "$dirname" [ expr $len-1 ] ]
    if { $car != "/" } {
      append folder "/"
    }
    set dirname $folder
  }

  # Création du répertoire si inexistant et si creat vaut 'y'
  if { $dirname != "" } {
    if { $creat == "y" } {
      if { ! [file isdirectory $dirname] } {
        file mkdir $dirname
      }
    }
  }

  return $dirname
}
proc getdir {} {
  global param

  set old_dir $param(rep)

  set rep [getdirname]
  if { $rep != "" } {
    set param(rep) $rep
  }
}

proc quitter {} {
  global ferreur old_rep

  # Restaure le répertoire initial
  catch {cd $old_rep}

  destroy .dialog
  destroy .pre
}


####################################################################
#  routine principale                                              #
####################################################################

toplevel .pre
wm geometry  .pre +50+50
wm title .pre "Récupération d'images du DSS"
wm protocol .pre WM_DELETE_WINDOW quitter


#
# Lecture du fichier de paramètres
#

# Crée une frame par champs de saisie (+ simple pour utiliser le packer)

frame .pre.f00 -borderwidth 5
pack configure .pre.f00 -side top -fill x
button .pre.f00.ouvrir -text "Ouvrir Param." -command ouvrir
pack .pre.f00.ouvrir -side left
button .pre.f00.enregistrer -text "Enregistrer Param." -command enregistrer
pack .pre.f00.enregistrer -side left

# Radio bouton
frame .pre.f0 -borderwidth 5
pack configure .pre.f0 -side top -fill x

radiobutton .pre.f0.but1 -variable param(NomObjet) -text Messier -value M
pack .pre.f0.but1 -side left
radiobutton .pre.f0.but2 -variable param(NomObjet) -text NGC -value NGC
pack .pre.f0.but2 -side left
radiobutton .pre.f0.but3 -variable param(NomObjet) -text IC -value IC
pack .pre.f0.but3 -side left

.pre.f0.but1 configure -command {active_objet}
.pre.f0.but2 configure -command {active_objet}
.pre.f0.but3 configure -command {active_objet}


# indice début/fin
frame .pre.f01 -borderwidth 5
pack configure .pre.f01 -side top -fill x

label .pre.f01.l1 -text {Indice début :}
pack configure .pre.f01.l1 -side left
entry .pre.f01.e1 -textvariable param(debut)
pack configure .pre.f01.e1 -side left -fill x
.pre.f01.e1 configure -validate focusout
.pre.f01.e1 configure -validatecommand {active_objet}

label .pre.f01.l2 -text {Indice fin :}
pack configure .pre.f01.l2 -side left
entry .pre.f01.e2 -textvariable param(fin)
pack configure .pre.f01.e2 -side left -fill x
.pre.f01.e2 configure -validate focusout
.pre.f01.e2 configure -validatecommand {active_objet}

# texte de rappel
frame .pre.f02 -borderwidth 5
pack configure .pre.f02 -side top -fill x

label .pre.f02.l1
pack configure .pre.f02.l1 -side left





# Choix du catalogue dans lequel prendre l'image
#frame .pre.frl borderwidth 5
#pack configure .pre.frl -side top -fill x

#listbox .pre.frl.lb -listvariable {{POSS2/UKSTU Red}{POSS2/UKSTU Blue}{POSS2/UKSTU IR}{POSS1 Red}{POSS1 Blue}{Quick-V}{HST Phase 2 (GSC2)}{HST Phase 2 (GSC1)}} -state normal -height 3
#pack configure .pre.frl.lb -side left

  #  <option value="poss2ukstu_red" selected>   POSS2/UKSTU Red</option>
  #  <option value="poss2ukstu_blue" >          POSS2/UKSTU Blue</option>
  #  <option value="poss2ukstu_ir" >            POSS2/UKSTU IR</option>
  #  <option value="poss1_red" >                POSS1 Red</option>
  #  <option value="poss1_blue" >               POSS1 Blue</option>
  #  <option value="quickv" >                   Quick-V</option>
  #  <option value="phase2_gsc2" >              HST Phase 2 (GSC2)</option>
  #  <option value="phase2_gsc1" >              HST Phase 2 (GSC1)</option>

frame       .pre.lb -borderwidth 2
# -relief groove
pack configure .pre.lb -side top -fill x
listbox     .pre.lb.lb1 -width 25 -height 5 -borderwidth 2 -relief sunken -yscrollcommand [list .pre.lb.scrollbar set]
pack        .pre.lb.lb1 -side left -anchor nw
scrollbar   .pre.lb.scrollbar -orient vertical -command [list .pre.lb.lb1 yview]
pack        .pre.lb.scrollbar -side left -fill y

.pre.lb.lb1 insert end "POSS2/UKSTU Red"
.pre.lb.lb1 insert end "POSS2/UKSTU Blue"
.pre.lb.lb1 insert end "POSS2/UKSTU IR"
.pre.lb.lb1 insert end "POSS1 Red"
.pre.lb.lb1 insert end "POSS1 Blue"
.pre.lb.lb1 insert end "Quick-V"
.pre.lb.lb1 insert end "HST Phase 2 (GSC2)"
.pre.lb.lb1 insert end "HST Phase 2 (GSC1)"


# largeur image
frame .pre.f1 -borderwidth 5
pack configure .pre.f1 -side top -fill x

label .pre.f1.l1 -text {Largeur image en arcmin :}
pack configure .pre.f1.l1 -side left
entry .pre.f1.e1 -textvariable param(largeur)
pack configure .pre.f1.e1 -side left

# hauteur image
frame .pre.f2 -borderwidth 5
pack configure .pre.f2 -side top -fill x

label .pre.f2.l2 -text {Hauteur image en arcmin :}
pack configure .pre.f2.l2 -side left
entry .pre.f2.e2 -textvariable param(hauteur)
pack configure .pre.f2.e2 -side left

# répertoire
frame .pre.f3 -borderwidth 5
pack configure .pre.f3 -side top -fill x

label .pre.f3.l3 -text {Répertoire de destination :}
pack configure .pre.f3.l3 -side left
entry .pre.f3.e3 -textvariable param(rep) -width 40
pack configure .pre.f3.e3 -side left
button .pre.f3.b3 -text "..." -command  {getdir}
pack .pre.f3.b3 -side left

# compresser le fichier
frame .pre.f4 -borderwidth 5
pack configure .pre.f4 -side top -fill x

label .pre.f4.l4 -text {Compressé image :}
pack configure .pre.f4.l4 -side left
checkbutton .pre.f4.cbcompresse -variable param(compresse) -onvalue yes -offvalue no
pack configure .pre.f4.cbcompresse -side left

# proxy
frame .pre.f5 -borderwidth 5
pack configure .pre.f5 -side top -fill x

label .pre.f5.l5 -text {Proxy :}
pack configure .pre.f5.l5 -side left
checkbutton .pre.f5.cbproxy -variable param(proxy) -onvalue yes -offvalue no
pack configure .pre.f5.cbproxy -side left
.pre.f5.cbproxy configure -command {active_proxy; active_objet}
set param(proxy) no

# proxy - nom
frame .pre.f6 -borderwidth 5
pack configure .pre.f6 -side top -fill x

label .pre.f6.l6 -text {Nom Proxy :}
pack configure .pre.f6.l6 -side left
entry .pre.f6.e6 -textvariable param(proxyname)
pack configure .pre.f6.e6 -side left

# proxy - port
frame .pre.f7 -borderwidth 5
pack configure .pre.f7 -side top -fill x

label .pre.f7.l7 -text {Port Proxy :}
pack configure .pre.f7.l7 -side left
entry .pre.f7.e7 -textvariable param(proxyport)
pack configure .pre.f7.e7 -side left

# proxy - user
frame .pre.f8 -borderwidth 5
pack configure .pre.f8 -side top -fill x

label .pre.f8.l8 -text {User Proxy :}
pack configure .pre.f8.l8 -side left
entry .pre.f8.e8 -textvariable param(proxyuser)
pack configure .pre.f8.e8 -side left

# proxy - password
frame .pre.f9 -borderwidth 5
pack configure .pre.f9 -side top -fill x

label .pre.f9.l9 -text {Password Proxy :}
pack configure .pre.f9.l9 -side left
entry .pre.f9.e9 -textvariable param(proxypassword)
pack configure .pre.f9.e9 -side left

# ok/annuler
frame .pre.f10 -borderwidth 20
pack configure .pre.f10 -side top -fill x

button .pre.f10.b1 -text "Annuler"  -command  {quitter}
button .pre.f10.b2 -text "Lancer" -command  {recuperation}
pack .pre.f10.b1 -side left
pack .pre.f10.b2 -side left -padx 10

bind .pre <Key-Escape> {quitter}

# Définie la fenetre qui servira à l'affichage des messages d'attente.
toplevel .dialog
label .dialog.l1 -text "" -width 50
pack .dialog.l1 -side top
pack forget .dialog

wm withdraw .dialog

# Fenetre centree
set x [expr {([winfo screenwidth .]-[winfo width .dialog])/2}]
set y [expr {([winfo screenheight .]-[winfo height .dialog])/2}]
wm geometry  .dialog +$x+$y
# wm transient .dialog .
wm resizable .dialog 1 1
wm title     .dialog "Image en cours de traitement ..."
wm protocol  .dialog WM_DELETE_WINDOW quitter

active_proxy

# Cache la fenetre wish par défaut
wm withdraw .
# Mets le focus sur le bouton 'lancer'
focus -force .pre.f10.b2

