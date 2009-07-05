#
# Fichier : raw2fits.tcl
# Description : Script pour la conversion d'images .ARW .CR2 .CRW .DNG .ERF .MRW \
#.NEF .ORF .RAF .RW2 .SR2 .TIFF .X3F au format .fit
# Auteur : Raymond Zachantke
# Mise a jour $Id : Exp $
#

namespace eval ::raw2fits {
   global audace

   source [file join $audace(rep_scripts) raw2fits raw2fits.cap]

   #########################################################################
   #--   Cree la fenetre 'Conversion d'images brutes au format fits'       #
   #  entree : parametres de l'image affichee                              #
   #  sortie : choix du mode de conversion ou abandon                      #
   #########################################################################
   proc ::raw2fits::Init { } {
      global audace color caption
      variable private

      set private(raw2fits,dirname) $audace(rep_images)
      set file_extension [ list .arw .ARW .cr2 .CR2 .crw .CRW .dng .DNG .erf .ERF .mrw .MRW \
         .nef .NEF .orf .ORF .raf .RAF .rw2 .RW2 .sr2 .SR2 .tiff .TIFF .x3f .X3F ]

      set this "$audace(base).convert"
      set private(raw2fits,This) $this
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
         -text "$caption(raw2fits,label_1) $private(raw2fits,dirname) $caption(raw2fits,label_2) "\
         -indicatoron 1 -onvalue "sub"
      checkbutton $this.opt.all -variable todo \
         -text "$caption(raw2fits,label_1) $private(raw2fits,dirname) $caption(raw2fits,label_3) "\
         -indicatoron 1 -onvalue "all"
      checkbutton $this.opt.one -variable todo \
         -text $caption(raw2fits,label_5)\
         -indicatoron 1 -onvalue "one"
      if [ buf$audace(bufNo) imageready ] {
         $this.opt.one configure -state normal
      } else {
         $this.opt.one configure -state disabled
      }
      pack $this.opt.sub $this.opt.all $this.opt.one -in $this.opt -anchor w -ipadx 10 -ipady 5
      pack $this.opt -in $this -side top

      if [ buf$audace(bufNo) imageready ] {
          set private(raw2fits,nom) [ ::confVisu::getFileName $audace(visuNo) ]
          set extension  [ file extension $private(raw2fits,nom) ]
          set test [ lsearch -exact $file_extension $extension ]
          if { $test != "-1" } {
            $this.opt.one configure -state normal
            $this.opt.one select
         } else {
            $this.opt.one configure -state disabled
            $this.opt.all select
         }
      } else {
         $this.opt.one configure -state disabled
         $this.opt.all select
      }

      #--   frame du message
      frame $this.msg -borderwidth 1 -relief raised
      Label $this.msg.txt -justify center -foreground $color(blue)
      pack $this.msg.txt -in $this.msg
      pack $this.msg -in $this -anchor s -ipadx 5 -ipady 5 -fill x

      #--   frame de la confirmation
      frame $this.cmd -borderwidth 1 -relief raised
      ::raw2fits::CreateButton $this.cmd "ok" $caption(raw2fits,bouton1) { ::raw2fits::Convert $todo }
         pack $this.cmd.ok -side left
      ::raw2fits::CreateButton "$this.cmd" "no" $caption(raw2fits,bouton3) { ::raw2fits::Fermer }
      pack $this.cmd.no -side right
      ::raw2fits::CreateButton $this.cmd "hlp" $caption(raw2fits,bouton2) {
         ::audace::Lance_Notice_pdf [ file join $audace(rep_scripts) raw2fits raw2fits.pdf ]
      }
      pack $this.cmd.hlp -side right
      pack $this.cmd -in $this -anchor s -fill x

      #---  bindings
         bind $this <Key-Return>  {
         $audace(base).convert.cmd.no configure -state disabled
         $audace(base).convert.cmd.ok configure -state active -relief sunken
         ::raw2fits::Convert $todo
      }
         bind $this <Key-Escape> { ::raw2fits::Fermer }

         #--- Focus
         focus $this

   }

   #########################################################################
   #--   Convertit les images au format fits                               #
   #  entree : choix utilisateur                                           #
   #  sortie : abondon ou choix de commandes                               #
   #########################################################################
   proc ::raw2fits::Convert { action } {
      global audace caption
      variable private

      set nb 0
      $private(raw2fits,This).msg.txt configure -text $caption(raw2fits,msg_01)

      switch -exact $action {
         "sub"    {
                  set private(raw2fits,liste) [ list $private(raw2fits,dirname) ]
                  ::raw2fits::Explore $private(raw2fits,dirname)
                  foreach rep $private(raw2fits,liste) {
                     set n [::raw2fits::ConvertAll $rep ]
                     set nb [ expr { $nb + $n } ]
                  }
               }
         "all"    {  set nb [::raw2fits::ConvertAll $private(raw2fits,dirname) ] }
         "one"    {
                  set private(raw2fits,rootname) [ file rootname $private(raw2fits,nom) ]
                  set private(raw2fits,destination) "$private(raw2fits,rootname).fit"
                  ::raw2fits::ConvertThis $private(raw2fits,nom) $private(raw2fits,destination)
                  ::console::affiche_saut "\n"
                  set nb "1"
               }
      }

      $private(raw2fits,This).msg.txt configure -text $caption(raw2fits,msg_02)

      if { $nb != "0" } {
         ::raw2fits::LoadIma
         $audace(base).convert.cmd.ok configure -state normal -relief raised
         $audace(base).convert.cmd.no configure -state normal
      } else {
         #--   message si pas de fichiers à convertir
         tk_messageBox -title $caption(raw2fits,erreur) -icon error -type ok -message $caption(raw2fits,msg_03)
         ::raw2fits::Fermer
      }
   }

   #########################################################################
   #--   liste les repertoires dans un répertoire                          #
   #########################################################################
   proc ::raw2fits::Explore { {name .} } {
      variable private

      foreach subdir [ glob -nocomplain -directory $name -type d * ] {
         set private(raw2fits,liste)  [ concat $private(raw2fits,liste) [ list $subdir ] ]
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
         ::console::affiche_resultat "$caption(raw2fits,label_4) $rep\n"

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
      global audace caption
      variable private

      #--   met à jour la fenetre
      $private(raw2fits,This).msg.txt configure -text $caption(raw2fits,msg_01)

      set name [ lindex [ file split $source ] end ]
      set error [ catch { buf$audace(bufNo) load $source } msg ]
      if { $error == "0" } {
         #--   sauve l'image
         buf$audace(bufNo) save $destination
         ::console::affiche_resultat "$caption(raw2fits,label_7) $name --> $private(raw2fits,nom)\n"
      } else {
         #--   message d'echec
         ::console:::affiche_resultat "$caption(raw2fits,label_6) $source : $msg\n"
         #--   suppression de l'image de la liste
         set index [ lsearch -exact $private(raw2fits,liste_cibles) $name ]
         set private(raw2fits,liste_cibles) [ lreplace $private(raw2fits,liste_cibles) $index $index ]
      }
   }

   #########################################################################
   #--   charge la derniere image convertie                                #
   #########################################################################
   proc ::raw2fits::LoadIma { } {
      global audace
      variable private

      set error [ catch { loadima $private(raw2fits,destination) } msg ]
      if { $error == "0" } {
         ::audace::autovisu $audace(visuNo)
      } else {
         ::console:::affiche_resultat "$caption(raw2fits,msg_04) $private(raw2fits,destination) : $msg\n"
      }
   }

   #########################################################################
   #--   Fermeture de le fenetre et destruction du namespace               #
   #########################################################################
   proc ::raw2fits::Fermer { } {
      variable private

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

