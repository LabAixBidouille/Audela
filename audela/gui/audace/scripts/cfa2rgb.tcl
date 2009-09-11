#
# Fichier : cfa2rgb.tcl
# Description : Script pour la conversion d'images CFA-->RVB en masse
# Auteur : Raymond Zachantke
# Mise a jour $Id: cfa2rgb.tcl,v 1.1 2009-09-11 08:21:20 robertdelmas Exp $
#

namespace eval ::cfa2rgb {
   global audace

   source [file join $audace(rep_scripts) cfa2rgb cfa2rgb.cap]

   #########################################################################
   #--   Initialisation et filtre l'image affichee                         #
   #########################################################################
   proc ::cfa2rgb::Init { args } {
      global audace
      variable private

      set private(cfa2rgb,dirname) $audace(rep_images)
      set private(cfa2rgb,nom)     ""
      set private(cfa2rgb,visuNo)  $audace(visuNo)

      #--   je declare le rafraichissement automatique sur le nom de l'image si on charge une image
      ::confVisu::addFileNameListener $private(cfa2rgb,visuNo) "::cfa2rgb::testeImageAffichee"

      #--   test si il y a une image dans le buffer et que ce n'est pas une image couleurs
      ::cfa2rgb::testeImageAffichee
      ::cfa2rgb::CreateDialog
   }

   #########################################################################
   #--   Filtre l'image affichee                                           #
   #########################################################################
   proc ::cfa2rgb::testeImageAffichee { args } {
      global audace
      variable private

      #--   test si il y a une image dans le buffer et que ce n'est pas une image couleurs
      set this "$audace(base).convert"
      set private(cfa2rgb,This) $this
      set buf_num [ visu$private(cfa2rgb,visuNo) buf ]
      if { [ winfo exists $this ] } {
         if [ buf$buf_num imageready ] {
            set private(cfa2rgb,nom) [ ::confVisu::getFileName $private(cfa2rgb,visuNo) ]
            set extension [ file extension $private(cfa2rgb,nom) ]
            set naxis     [ lindex [ buf$buf_num getkwd NAXIS ] 1 ]
            set naxis3    [ lindex [ buf$buf_num getkwd NAXIS3 ] 1 ]
            set rgbfiltr  [ lindex [ buf$buf_num getkwd RGBFILTR ] 1 ]
            #--   configure l'option en fonction de l'existence d'une image dans le buffer
            if { $extension == ".fit" && ( $naxis == "2" && $rgbfiltr == "" ) && $naxis3 != "3" } {
               $this.opt.one configure -state normal
               $this.opt.one select
            } else {
               if { [ info exists private(cfa2rgb,action) ] } {
                  if { $private(cfa2rgb,action) == "one" } {
                     $this.opt.one deselect
                  }
               }
               $this.opt.one configure -state disabled
            }
         } else {
            if { [ info exists private(cfa2rgb,action) ] } {
               if { $private(cfa2rgb,action) == "one" } {
                  $this.opt.one deselect
               }
            }
            $this.opt.one configure -state disabled
         }
      }
   }

   #########################################################################
   #--   Cree la fenetre 'Conversion CFA-->RGB'                            #
   #  entree : parametres de l'image affichee                              #
   #  sortie : choix du mode de conversion ou abandon                      #
   #########################################################################
   proc ::cfa2rgb::CreateDialog {  } {
      global audace color caption
      variable private

      set this $private(cfa2rgb,This)
      if [ winfo exists $private(cfa2rgb,This) ] { destroy $private(cfa2rgb,This) }

      toplevel $this
      wm resizable $this 0 0
      wm deiconify $this
      wm title $this "$caption(cfa2rgb,titre)"
      wm geometry $this +40+100
      wm protocol $this WM_DELETE_WINDOW { ::cfa2rgb::Fermer }

      #--   frame des chekbuttons
      frame $this.opt -borderwidth 1 -relief raised
      checkbutton $this.opt.sub -variable todo \
         -text "[ format $caption(cfa2rgb,label_1) $private(cfa2rgb,dirname) ]"\
         -indicatoron 1 -onvalue "sub"
      checkbutton $this.opt.all -variable todo \
         -text "[ format $caption(cfa2rgb,label_2) $private(cfa2rgb,dirname) ]"\
         -indicatoron 1 -onvalue "all"
      checkbutton $this.opt.one -variable todo \
         -text $caption(cfa2rgb,label_4)\
         -indicatoron 1 -onvalue "one"
      pack $this.opt.sub $this.opt.all $this.opt.one -in $this.opt -anchor w -ipadx 10 -ipady 5
      pack $this.opt -in $this -side top

      #--   frame du message
      frame $this.msg -borderwidth 1 -relief raised
      Label $this.msg.txt -justify center -foreground $color(blue)
      pack $this.msg.txt -in $this.msg
      pack $this.msg -in $this -anchor s -ipadx 5 -ipady 5 -fill x

      #--   frame de la confirmation
      frame $this.cmd -borderwidth 1 -relief raised
      ::cfa2rgb::CreateButton $this.cmd "ok" $caption(cfa2rgb,appliquer) { ::cfa2rgb::Convert $todo }
      pack $this.cmd.ok -side left
      ::cfa2rgb::CreateButton "$this.cmd" "no" $caption(cfa2rgb,fermer) { ::cfa2rgb::Fermer }
      pack $this.cmd.no -side right
      ::cfa2rgb::CreateButton $this.cmd "hlp" $caption(cfa2rgb,aide) {
         ::audace::Lance_Notice_pdf [ file join $audace(rep_scripts) cfa2rgb cfa2rgb.pdf ]
      }
      pack $this.cmd.hlp -in $this.cmd -side right
      pack $this.cmd -in $this -anchor s -fill x

      #--   configure l'option en fonction de l'existence d'une image dans le buffer
      ::cfa2rgb::testeImageAffichee

      #--   bindings
      bind $this <Key-Return> { ::cfa2rgb::activeconvert ; ::cfa2rgb::Convert $todo }
      bind $this <Key-Escape> { ::cfa2rgb::Fermer }

      #--   Focus
      focus $this
   }

   #########################################################################
   #--   Convertit CFA-->RGB                                               #
   #  entree : choix utilisateur                                           #
   #  sortie : abondon ou choix de commandes                               #
   #########################################################################
   proc ::cfa2rgb::Convert { action } {
      global caption color
      variable private

      #--   initiallisation
      set private(cfa2rgb,action) $action

      #--   change l'etat des boutons
      ::cfa2rgb::activeconvert

      set nb 0
      switch -exact $action {
         "sub"    {
                  set private(cfa2rgb,liste) [ list $private(cfa2rgb,dirname) ]
                  ::cfa2rgb::Explore $private(cfa2rgb,dirname)
                  foreach rep $private(cfa2rgb,liste) {
                     #--   notifie le repertoire d'analyse sur la console
                     ::console::affiche_resultat "\n$caption(cfa2rgb,label_7) $rep\n"
                     set n [::cfa2rgb::ConvertAll $rep ]
                     set nb [ expr { $nb + $n } ]
                  }
               }
         "all"    {
                  set nb [ ::cfa2rgb::ConvertAll $private(cfa2rgb,dirname) ]
               }
         "one"    {
                  set nb [ ::cfa2rgb::ConvertThis $private(cfa2rgb,nom)
                  set private(cfa2rgb,nom) "$private(cfa2rgb,destination)" ]
               }
      }

      if { $nb != "0" } {
         #--   charge la dernière image convertie
         set error [ catch { loadima $private(cfa2rgb,destination) } msg ]
         if { $error == "0" } {
            ::confVisu::autovisu $private(cfa2rgb,visuNo) -no $private(cfa2rgb,destination)
         } else {
            ::console:::affiche_resultat "$caption(cfa2rgb,msg_03) $private(cfa2rgb,destination) : $msg\n"
         }
         $private(cfa2rgb,This).msg.txt configure -text $caption(cfa2rgb,msg_02)
         $private(cfa2rgb,This).cmd.ok configure -state normal -relief raised -fg $color(black)
         $private(cfa2rgb,This).cmd.no configure -state normal
      } else {
         #--   message si pas de fichiers à convertir
         tk_messageBox -title $caption(cfa2rgb,erreur) -icon error -type ok -message $caption(cfa2rgb,msg_03)
         $private(cfa2rgb,This).msg.txt configure -text ""
         $private(cfa2rgb,This).cmd.ok configure -state normal -relief raised -fg $color(black)
         $private(cfa2rgb,This).cmd.no configure -state normal
      }
   }

   #########################################################################
   #--   liste les repertoires dans un répertoire                          #
   #########################################################################
   proc ::cfa2rgb::Explore { { dir . } } {
      variable private

      foreach subdir [ glob -nocomplain -directory $dir -type d * ] {
         set private(cfa2rgb,liste)  [ concat $private(cfa2rgb,liste) [ list $subdir ] ]
         ::cfa2rgb::Explore $subdir
      }
   }

   #########################################################################
   #--   filtre les fichiers dans un repertoire                            #
   #########################################################################
   proc ::cfa2rgb::ConvertAll { rep } {
      variable private

      set private(cfa2rgb,liste_cibles) ""
      set nb "0"

      #--   etablit la liste des fichiers d'extension .fit
      set private(cfa2rgb,liste_cibles) [ glob -nocomplain -type f -join $rep *.FIT ]

      #--   mise a jour de la liste des images en fonction de leur nature
      foreach cible $private(cfa2rgb,liste_cibles) {
         set name [ file tail $cible ]

         #--   capture les kwds
         set err [ catch { set kwds_list [ fitsheader $cible ] } msg ]

         if { $err == "0" } {
            #--   cree un array des kwds
            array unset kwds
            foreach kwd $kwds_list {
               array set kwds [ list [ lindex $kwd 0 ] [ lindex $kwd 1 ] ]
            }

            #--   extrait les kwd en vue des tests
            set naxis [ lindex [ array get kwds "NAXIS" ] 1 ]
            set naxis3 [ lindex [ array get kwds "NAXIS3" ] 1 ]
            set rgbfiltr [ lindex [ array get kwds "RGBFILTR" ] 1 ]

            set test "0"
            if { ( $naxis == "2" && $rgbfiltr == "" ) && $naxis3 != "3" } {
               set test "1"
            }

            #--   filtre les images qui ne seraient pas strictement CFA
            if { $test == "0" } {
               #--   actualise la liste des images a traiter
               set index [ lsearch -exact $private(cfa2rgb,liste_cibles) $cible ]
               set private(cfa2rgb,liste_cibles) [ lreplace $private(cfa2rgb,liste_cibles) \
                  $index $index ]
            }
         } else {
            tk_messageBox -title $caption(cfa2rgb,attention) -icon error -type ok \
            -message "$caption(cfa2rgb,msg_04) : $msg "
         }
      }

      #--   initie les conversions
      if { $private(cfa2rgb,liste_cibles) != "" } {
         foreach source $private(cfa2rgb,liste_cibles) {
            set n [ ::cfa2rgb::ConvertThis $source ]
            set nb [ expr { $nb+$n } ]
         }
      }

      #--   retourne le nombre d'images converties
      return $nb
   }

   #########################################################################
   #--   Creation de l'image couleurs RVB                                  #
   #########################################################################
   proc ::cfa2rgb::ConvertThis { source } {
      global caption
      variable private

      set buf_num [ visu$private(cfa2rgb,visuNo) buf ]

      set name [ file tail $source ]
      set dir [ file dirname $source ]
      set destination [ file join $dir rgb_$name ]

      if { $private(cfa2rgb,nom) =="" || $name != $private(cfa2rgb,nom) } {
         #--   charge l'image dans le buffer
         set error [ catch { buf$buf_num load $source } msg ]
      } else {
         #--   elle est deja chargee
         set error "0"
      }

      if { $error == "0" } {
         #--   convertit l'image
         buf$buf_num cfa2rgb 1

         #--   pour pouvoir afficher la dernière image convertie
         set private(cfa2rgb,destination) $destination

         #--   sauve l'image
         saveima $private(cfa2rgb,destination)
         ::console::affiche_resultat "[ format $caption(cfa2rgb,label_6) "$name --> rgb_$name" ]\n"
         set ok "1"

      } else {
         if { $error == "1" } {
            #--   message
            ::console::affiche_resultat "[ format $caption(cfa2rgb,label_5) "$name : $msg" ]\n"
            set ok "0"
         }
      }

      return $ok
   }

   #########################################################################
   #--   Cree un bouton                                                    #
   #  parametres : le nom de la fenetre parent, enfant, texte, commande    #
   #########################################################################
   proc ::cfa2rgb::CreateButton { parent child com cmd } {
      global color

      button $parent.$child -text $com -relief raised -activeforeground $color(red) \
         -borderwidth 3 -command $cmd -width 10
      pack $parent.$child -in $parent -padx 5 -pady 5
   }

   #########################################################################
   #--   Modifie l'etat des boutons                                        #
   #########################################################################
   proc ::cfa2rgb::activeconvert { } {
      global caption color
      variable private

      #--   nettoye l'affichage du message
      $private(cfa2rgb,This).cmd.ok configure -state normal -relief sunken -fg $color(red)
      $private(cfa2rgb,This).msg.txt configure -text $caption(cfa2rgb,msg_01)
      $private(cfa2rgb,This).cmd.no configure -state disabled
      update
   }

   #########################################################################
   #--   Fermeture de le fenetre et destruction du namespace               #
   #########################################################################
   proc ::cfa2rgb::Fermer { args } {
      variable private

      #--   j'arrete le rafraichissement automatique sur le nom de l'image si on charge une image
      ::confVisu::removeFileNameListener $private(cfa2rgb,visuNo) "::cfa2rgb::testeImageAffichee"

      catch { destroy $private(cfa2rgb,This) }
      namespace delete "::cfa2rgb"
   }
}

::cfa2rgb::Init

