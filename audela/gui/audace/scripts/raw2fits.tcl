#
# Fichier : raw2fits.tcl
# Description : Script pour la conversion d'images .ARW .CR2 .CRW .DNG .ERF .MRW \
#.NEF .ORF .RAF .RW2 .SR2 .TIFF .X3F au format .fit
# Auteur : Raymond Zachantke
# Mise a jour $Id: raw2fits.tcl,v 1.8 2009-09-11 15:09:14 robertdelmas Exp $
#

namespace eval ::raw2fits {
   global audace

   source [file join $audace(rep_scripts) raw2fits raw2fits.cap]

   #########################################################################
   #--   Initialisation et filtre l'image affichee                         #
   #########################################################################
   proc ::raw2fits::Init { } {
      global audace
      variable private

      set private(raw2fits,dirname) $audace(rep_images)
      set private(raw2fits,nom)     ""
      set private(raw2fits,visuNo)  $audace(visuNo)

      #--   je declare le rafraichissement automatique sur le nom de l'image si on charge une image
      ::confVisu::addFileNameListener $private(raw2fits,visuNo) "::raw2fits::testeImageAffichee"

      #--   test si il y a une image dans le buffer
      ::raw2fits::testeImageAffichee
      ::raw2fits::CreateDialog
   }

   #########################################################################
   #--   Filtre l'image affichee                                           #
   #########################################################################
   proc ::raw2fits::testeImageAffichee { args } {
      global audace
      variable private

      set file_extension [ list .arw .ARW .cr2 .CR2 .crw .CRW .dng .DNG .erf .ERF .mrw .MRW \
         .nef .NEF .orf .ORF .raf .RAF .rw2 .RW2 .sr2 .SR2 .tiff .TIFF .x3f .X3F ]

      #--   test si il y a une image dans le buffer et que ce n'est pas une image couleurs
      set this "$audace(base).convert"
      set private(raw2fits,This) $this
      set buf_num [ visu$private(raw2fits,visuNo) buf ]
      if { [ winfo exists $this ] } {
         if [ buf$buf_num imageready ] {
            set private(raw2fits,nom) [ ::confVisu::getFileName $private(raw2fits,visuNo) ]
            set extension [ file extension $private(raw2fits,nom) ]
            set test [ lsearch -exact $file_extension $extension ]
            if { $test != "-1" } {
               $this.opt.one configure -state normal
               $this.opt.one select
            } else {
               if { [ info exists private(raw2fits,action) ] } {
                  if { $private(raw2fits,action) == "one" } {
                     $this.opt.one deselect
                  }
               }
               $this.opt.one configure -state disabled
            }
         } else {
            if { [ info exists private(raw2fits,action) ] } {
               if { $private(raw2fits,action) == "one" } {
                  $this.opt.one deselect
               }
            }
            $this.opt.one configure -state disabled
         }
      }
   }

   #########################################################################
   #--   Cree la fenetre 'Conversion d'images brutes au format fits'       #
   #  entree : parametres de l'image affichee                              #
   #  sortie : choix du mode de conversion ou abandon                      #
   #########################################################################
   proc ::raw2fits::CreateDialog {  } {
      global audace color caption
      variable private

      set this $private(raw2fits,This)
      if [ winfo exists $private(raw2fits,This) ] { destroy $private(raw2fits,This) }

      toplevel $this
      wm resizable $this 0 0
      wm deiconify $this
      wm title $this $caption(raw2fits,titre)
      wm geometry $this +40+100
      wm protocol $this WM_DELETE_WINDOW { ::raw2fits::Fermer }

      #--   frame des chekbuttons
      frame $this.opt -borderwidth 1 -relief raised
      checkbutton $this.opt.sub -variable todo \
         -text "[ format $caption(raw2fits,label_1) $private(raw2fits,dirname) ]"\
         -indicatoron 1 -onvalue "sub"
      checkbutton $this.opt.all -variable todo \
         -text "[ format $caption(raw2fits,label_2) $private(raw2fits,dirname) ]"\
         -indicatoron 1 -onvalue "all"
      checkbutton $this.opt.one -variable todo \
         -text $caption(raw2fits,label_4)\
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
      ::raw2fits::CreateButton $this.cmd "ok" $caption(raw2fits,appliquer) { ::raw2fits::Convert $todo }
      pack $this.cmd.ok -side left
      ::raw2fits::CreateButton "$this.cmd" "no" $caption(raw2fits,fermer) { ::raw2fits::Fermer }
      pack $this.cmd.no -side right
      ::raw2fits::CreateButton $this.cmd "hlp" $caption(raw2fits,aide) {
         ::audace::Lance_Notice_pdf [ file join $audace(rep_scripts) raw2fits raw2fits.pdf ]
      }
      pack $this.cmd.hlp -side right
      pack $this.cmd -in $this -anchor s -fill x

      #--   configure l'option en fonction de l'existence d'une image dans le buffer
      ::raw2fits::testeImageAffichee

      #--   bindings
      bind $this <Key-Return> { ::raw2fits::activeconvert ; ::raw2fits::Convert $todo }
      bind $this <Key-Escape> { ::raw2fits::Fermer }

      #--   Focus
      focus $this

   }

   #########################################################################
   #--   Convertit les images au format fits                               #
   #  entree : choix utilisateur                                           #
   #  sortie : abondon ou choix de commandes                               #
   #########################################################################
   proc ::raw2fits::Convert { action } {
      global caption color
      variable private

      #--   initiallisation
      set private(raw2fits,action) $action

      #--   change l'etat des boutons
      ::raw2fits::activeconvert

      set nb 0
      switch -exact $action {
         "sub"    {
                  set private(raw2fits,liste) [ list $private(raw2fits,dirname) ]
                  ::raw2fits::Explore $private(raw2fits,dirname)
                  foreach rep $private(raw2fits,liste) {
                     set n [::raw2fits::ConvertAll $rep ]
                     set nb [ expr { $nb + $n } ]
                  }
               }
         "all"    { set nb [::raw2fits::ConvertAll $private(raw2fits,dirname) ] }
         "one"    {
                  set private(raw2fits,rootname) [ file rootname $private(raw2fits,nom) ]
                  set private(raw2fits,destination) "$private(raw2fits,rootname).fit"
                  ::raw2fits::ConvertThis $private(raw2fits,nom) $private(raw2fits,destination)
                  ::console::affiche_saut "\n"
                  set nb "1"
               }
      }

      if { $nb != "0" } {
         ::raw2fits::LoadIma
         $private(raw2fits,This).msg.txt configure -text $caption(raw2fits,msg_02)
         $private(raw2fits,This).cmd.ok configure -state normal -relief raised -fg $color(black)
         $private(raw2fits,This).cmd.no configure -state normal
      } else {
         #--   message si pas de fichiers à convertir
         tk_messageBox -title $caption(raw2fits,erreur) -icon error -type ok -message $caption(raw2fits,msg_03)
         $private(raw2fits,This).msg.txt configure -text ""
         $private(raw2fits,This).cmd.ok configure -state normal -relief raised -fg $color(black)
         $private(raw2fits,This).cmd.no configure -state normal
      }
   }

   #########################################################################
   #--   liste les repertoires dans un répertoire                          #
   #########################################################################
   proc ::raw2fits::Explore { {name .} } {
      variable private

      foreach subdir [ glob -nocomplain -directory $name -type d * ] {
         set private(raw2fits,liste) [ concat $private(raw2fits,liste) [ list $subdir ] ]
         ::raw2fits::Explore $subdir
      }
   }

   #########################################################################
   #--   liste les fichiers dans un repertoire                             #
   #  redefinit le nom generique et l'index du fichier                     #
   #########################################################################
   proc ::raw2fits::ConvertAll { rep } {
      global caption
      variable private

      cd $rep
      set private(raw2fits,liste_cibles) ""

      #--   etablit la liste des fichiers d'extensions acceptees présents dans le repertoire
      set private(raw2fits,liste_cibles) [glob -nocomplain *.ARW *.CR2 *.CRW *.DNG *.MRW \
         *.NEF *.ORF *.RAF *.RW2 *.SR2 *.TIFF *.X3F ]

      if { $private(raw2fits,liste_cibles) != "" } {

         #--   notifie le repertoire analyse
         ::console::affiche_resultat "$caption(raw2fits,label_3) $rep\n"

         #--   prend pour generique le nom du repertoire
         set i [ string last "/" $rep ]
         set generique "[ string range $rep [ incr i ] end ]_"

         foreach cible $private(raw2fits,liste_cibles) {

            #--   definit le nouvel index de l'image
            set index [ lsearch -exact $private(raw2fits,liste_cibles)  $cible]

            #--   le N° est egal a index+1
            incr index

            #--   definit le nom complet du fichier destination
            set private(raw2fits,nom) "$generique$index.fit"
            set private(raw2fits,destination) [ file join $rep $private(raw2fits,nom) ]
            ::raw2fits::ConvertThis $cible $private(raw2fits,destination)
         }
         ::console::affiche_resultat "\n\n"
      }

      #--   retourne la longueur de la liste finale des images converties
      return [ llength $private(raw2fits,liste_cibles) ]
   }

   #########################################################################
   #--   Creation du fichier au format fits                                #
   #########################################################################
   proc ::raw2fits::ConvertThis { source destination } {
      global caption
      variable private

      set buf_num [ visu$private(raw2fits,visuNo) buf ]

      #--   met à jour la fenetre
      $private(raw2fits,This).msg.txt configure -text $caption(raw2fits,msg_01)

      set name [ lindex [ file split $source ] end ]
      set error [ catch { buf$buf_num load $source } msg ]
      if { $error == "0" } {
         #--   sauve l'image
         buf$buf_num save $destination
         ::console::affiche_resultat "[ format $caption(raw2fits,label_6) $name $destination ]\n"
      } else {
         #--   message d'echec
         ::console::affiche_resultat "[ format $caption(raw2fits,label_5) $source $msg" ]\n"
         #--   suppression de l'image de la liste
         set index [ lsearch -exact $private(raw2fits,liste_cibles) $name ]
         set private(raw2fits,liste_cibles) [ lreplace $private(raw2fits,liste_cibles) $index $index ]
      }
   }

   #########################################################################
   #--   charge la derniere image convertie                                #
   #########################################################################
   proc ::raw2fits::LoadIma { } {
      variable private

      set error [ catch { loadima $private(raw2fits,destination) } msg ]
      if { $error == "0" } {
         ::confVisu::autovisu $private(raw2fits,visuNo) -no $private(raw2fits,destination)
      } else {
         ::console:::affiche_resultat "$caption(raw2fits,msg_04) $private(raw2fits,destination) : $msg\n"
      }
   }

   #########################################################################
   #--   Modifie l'etat des boutons                                        #
   #########################################################################
   proc ::raw2fits::activeconvert { } {
      global caption color
      variable private

      #--   nettoye l'affichage du message
      $private(raw2fits,This).cmd.ok configure -state normal -relief sunken -fg $color(red)
      $private(raw2fits,This).msg.txt configure -text $caption(raw2fits,msg_01)
      $private(raw2fits,This).cmd.no configure -state disabled
      update
   }

   #########################################################################
   #--   Fermeture de le fenetre et destruction du namespace               #
   #########################################################################
   proc ::raw2fits::Fermer { } {
      variable private

      #--   j'arrete le rafraichissement automatique sur le nom de l'image si on charge une image
      ::confVisu::removeFileNameListener $private(raw2fits,visuNo) "::raw2fits::testeImageAffichee"

      catch { destroy $private(raw2fits,This) }
      namespace delete "::raw2fits"
   }

   #########################################################################
   #--   Cree un bouton                                                    #
   #  parametres : le nom de la fenetre parent, enfant, texte, commande    #
   #########################################################################
   proc ::raw2fits::CreateButton { parent child com cmd } {
      global color

      button $parent.$child -text $com -relief raised -activeforeground $color(red) \
         -borderwidth 3 -command $cmd -width 10
      pack $parent.$child -in $parent -padx 5 -pady 5
   }

}

::raw2fits::Init

