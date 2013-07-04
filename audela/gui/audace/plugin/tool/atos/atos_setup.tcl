#------------------------------------------------------------------
# source [ file join $audace(rep_plugin) tool atos atos_setup.tcl
#------------------------------------------------------------------
#
# Fichier        : atos_setup.tcl
# Description    : Configuration de certains parametres de l'outil Acquisition
# Auteur         : Robert DELMAS et Frederic Vachier
# Mise Ã  jour $Id$
#

namespace eval ::atos_setup {

   #
   # atos_setup::init
   # Chargement des captions
   #
   proc ::atos_setup::init { } {
      global audace

      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool atos atos_setup.cap ]
   }

   #
   # atos_setup::initToConf
   # Initialisation des variables de configuration
   #
   proc ::atos_setup::initToConf { visuNo } {

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      if { ! [ info exists ::atos::parametres(atos,$visuNo,messages) ] }                   { set ::atos::parametres(atos,$visuNo,messages)                  "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,save_file_log) ] }              { set ::atos::parametres(atos,$visuNo,save_file_log)             "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,alarme_fin_serie) ] }           { set ::atos::parametres(atos,$visuNo,alarme_fin_serie)          "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,verifier_ecraser_fichier) ] }   { set ::atos::parametres(atos,$visuNo,verifier_ecraser_fichier)  "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,verifier_index_depart) ] }      { set ::atos::parametres(atos,$visuNo,verifier_index_depart)     "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,mode_debug) ] }                 { set ::atos::parametres(atos,$visuNo,mode_debug)                "0" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,screen_refresh) ] }             { set ::atos::parametres(atos,$visuNo,screen_refresh)            "1000" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,exec_ocr) ] }                   { set ::atos::parametres(atos,$visuNo,exec_ocr)                  "jpegtopnm ocr.jpg | gocr -C 0-9 -f UTF8" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,free_space) ] }                 { set ::atos::parametres(atos,$visuNo,free_space)                "500" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,dir_prj) ] }                    { set ::atos::parametres(atos,$visuNo,dir_prj)                   "" }
   }

   #
   # atos_setup::run
   # Cree la fenetre de configuration de l'affichage des messages sur la Console
   # et de l'enregistrement des dates dans le fichier log
   #
   proc ::atos_setup::run { visuNo this } {

      global audace panneau

      #--- Determination de la fenetre parente
      if { $visuNo == "1" } {
         set base "$audace(base)"
      } else {
         set base ".visu$visuNo"
      }

      #---
      set panneau(atos,$visuNo,atos_setup) $this
      ::confGenerique::run $visuNo "$panneau(atos,$visuNo,atos_setup)" "::atos_setup" -modal 0
      set posx_config [ lindex [ split [ wm geometry $base ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $base ] "+" ] 2 ]
      wm geometry $panneau(atos,$visuNo,atos_setup) +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
   }

   #
   # atos_setup::apply
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc ::atos_setup::apply { visuNo } {
       #--- Sauvegarde de la configuration de prise de vue
      ::atos_setup::enregistrerVariable $visuNo

   }

   #
   # atos_setup::showHelp
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc ::atos_setup::showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::atos::getPluginType ] ] \
         [ ::atos::getPluginDirectory ] atos_setup.htm
   }

   #
   # atos_setup::closeWindow
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc ::atos_setup::closeWindow { visuNo } {

   }

   #
   # atos_setup::getLabel
   # Retourne le nom de la fenetre de configuration
   #
   proc ::atos_setup::getLabel { } {
      global caption

      return "$caption(atos_setup,titre)"
   }

   #------------------------------------------------------------
   # ::atos::deletePluginInstance
   #    suppprime l'instance du plugin
   #------------------------------------------------------------
   proc ::atos_setup::enregistrerVariable { visuNo } {

      ::console::affiche_resultat "Enregistrement de la Configuration...\n"
      #foreach { a b } [ array get ::atos::parametres ] {
      #   if  {[string first atos $a]==0} {
      #   ::console::affiche_resultat "$a = $b\n"
      #   }
      #}

      #--- Sauvegarde des parametres
      catch {
        set nom_fichier [ file join $::audace(rep_home) atos.ini ]
        if [ catch { open $nom_fichier w } fichier ] {
           #---
        } else {
           foreach { a b } [ array get ::atos::parametres ] {
              if  {[string first atos $a]==0} {
                 puts $fichier "set ::atos::parametres($a) \"$b\""
              }
           }
           close $fichier
        }
      }
   }
   #
   # atos_acq::demo
   # Ouvre une boite de telechargement d'une video de reference
   #
   proc ::atos_setup::demo { visuNo frm } {

      package require http

      set ::atos_setup::demo_title "Téléchargement en cours"
      set ::atos_setup::demo_state disabled

      $frm configure -text  $::atos_setup::demo_title
      $frm configure -state $::atos_setup::demo_state

      $frm configure -text "Télécharger"
      $frm configure -state normal

      return

      set msg "La Démo va créer un repertoire et un fichier dans votre repertoire projet\n"
      append msg "Une video de 76 Mo va etre telechargée dans ce repertoire\n"
      set res [tk_messageBox -message $msg -type yesno]
      if {$res=="yes"} {
         ::console::affiche_resultat "ok\n"
      }

      if {$::atos::parametres(atos,$visuNo,dir_prj)==""} {
         tk_messageBox -message "Veuillez choisir un repertoire Projet" -type ok
      }

      set url "http://www.imcce.fr/~vachier/occultation/demo/sapphoseg.00.avi"
      #set url "http://www.imcce.fr/~vachier/occultation/demo/test"

      set dir [file join $::atos::parametres(atos,$visuNo,dir_prj) DEMO_20100604_234000_80_Sappho]
      if {![file exists $dir]} {file mkdir $dir}

      set filename [file join $dir [file tail $url]]
      ::console::affiche_resultat "Debut du telechargement de [file tail $url]\n"

      set ::atos_setup::r [http::geturl $url -binary 1]

      set fo [open $filename w]
      fconfigure $fo -translation binary
      puts -nonewline $fo [http::data $::atos_setup::r]
      close $fo
      ::http::cleanup $::atos_setup::r

      ::console::affiche_resultat "Got $url -> $filename"

   }

   #
   # atos_acq::chgdir
   # Ouvre une boite de dialogue pour choisir un nom  de repertoire
   #
   proc ::atos_setup::chgdir { This } {
      global caption
      global cwdWindow
      global audace

      #--- Initialisation des variables a 2 (0 et 1 reservees a Configuration --> Repertoires)
      set cwdWindow(rep_images)      "2"
      set cwdWindow(rep_travail)     "2"
      set cwdWindow(rep_scripts)     "2"
      set cwdWindow(rep_catalogues)  "2"
      set cwdWindow(rep_userCatalog) "2"
      set cwdWindow(rep_archives)    "2"

      set parent "$audace(base)"
      set title "Choisir un repertoire des projets"
      set rep "$audace(rep_images)"

      set numerror [ catch { set filename "[ ::cwdWindow::tkplus_chooseDir "$rep" $title $This ]" } msg ]
      if { $numerror == "1" } {
         set filename "[ ::cwdWindow::tkplus_chooseDir "[pwd]" $title $This ]"
      }

      ::console::affiche_resultat $audace(rep_images)

      $This delete 0 end
      $This insert 0 $filename

   }

   #
   # atos_setup::fillConfigPage
   # Creation de l'interface graphique
   #
   proc ::atos_setup::fillConfigPage { frm visuNo } {

      global caption panneau

      #--- Retourne l'item de la camera associee a la visu
      set camItem [ ::confVisu::getCamItem $visuNo ]
      set frms $panneau(atos,$visuNo,atos_setup)

      #--- Frame pour les commentaires
      frame $frms.frame3 -borderwidth 1 -relief raise

         #--- Frame pour l'en-tete FITS
         frame $frms.frame3.en-tete -borderwidth 0

            #--- Label de l'en-tete FITS
            label $frms.frame3.en-tete.lab -text $caption(atos_setup,en-tete_fits)
            pack $frms.frame3.en-tete.lab -side left -padx 6

            #--- Bouton d'acces aux mots cles
            button $frms.frame3.en-tete.but -text $caption(atos_setup,mots_cles) \
               -command "::keyword::run $visuNo ::conf(atos,keywordConfigName)"
            pack $frms.frame3.en-tete.but -side left -padx 6 -pady 10 -ipadx 20

            #--- Label du nom de la configuration de l'en-tete FITS
            entry $frms.frame3.en-tete.labNom \
               -state readonly -takefocus 0 -textvariable ::conf(atos,keywordConfigName) -justify center
            pack $frms.frame3.en-tete.labNom -side left -padx 6

         pack $frms.frame3.en-tete -side top -fill both -expand 1

         #--- Frame pour le commentaire 1
         frame $frms.frame3.frame4 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 1
            frame $frms.frame3.frame4.frame8 -borderwidth 0
               checkbutton $frms.frame3.frame4.frame8.check1 -highlightthickness 0 \
                  -text "$caption(atos_setup,texte1)" -variable ::atos::parametres(atos,$visuNo,messages)
               pack $frms.frame3.frame4.frame8.check1 -side right -padx 5 -pady 0
            pack $frms.frame3.frame4.frame8 -side left

         pack $frms.frame3.frame4 -side top -fill both -expand 1

         #--- Frame pour le commentaire 4 : verifier_ecraser_fichier
         frame $frms.frame3.frame7 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 4
            frame $frms.frame3.frame7.frame12 -borderwidth 0
               checkbutton $frms.frame3.frame7.frame12.check3 -highlightthickness 0 \
                  -text "$caption(atos_setup,texte4)" -variable ::atos::parametres(atos,$visuNo,verifier_ecraser_fichier)
               pack $frms.frame3.frame7.frame12.check3 -side right -padx 5 -pady 0
            pack $frms.frame3.frame7.frame12 -side left

         pack $frms.frame3.frame7 -side top -fill both -expand 1

         #--- Frame pour le commentaire 5 : mode_debug
         frame $frms.frame3.frame9 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 5
            frame $frms.frame3.frame9.frame12 -borderwidth 0
               checkbutton $frms.frame3.frame9.frame12.check3 -highlightthickness 0 \
                  -text "$caption(atos_setup,texte6)" -variable ::atos::parametres(atos,$visuNo,mode_debug)
               pack $frms.frame3.frame9.frame12.check3 -side right -padx 5 -pady 0
            pack $frms.frame3.frame9.frame12 -side left

         pack $frms.frame3.frame9 -side top -fill both -expand 1

         #--- Frame pour le : screen_refresh
         frame $frms.frame3.screen_refresh -borderwidth 0

            frame $frms.frame3.screen_refresh.frm -borderwidth 0
               entry $frms.frame3.screen_refresh.frm.value -width 5 -textvariable ::atos::parametres(atos,$visuNo,screen_refresh)
               pack $frms.frame3.screen_refresh.frm.value -side right -padx 5 -pady 0
               label $frms.frame3.screen_refresh.frm.lab -text "$caption(atos_setup,screen_refresh)"
               pack $frms.frame3.screen_refresh.frm.lab -side right -padx 5 -pady 0

            pack $frms.frame3.screen_refresh.frm -side left

         pack $frms.frame3.screen_refresh -side top -fill both -expand 1

         #--- Frame pour le : exec_ocr
         frame $frms.frame3.ocr -borderwidth 0

            frame $frms.frame3.ocr.frm -borderwidth 0
               button $frms.frame3.ocr.frm.but -text "test" -borderwidth 1 -command ""
               pack $frms.frame3.ocr.frm.but -side right -padx 5 -pady 0 -ipadx 10
               entry $frms.frame3.ocr.frm.value -width 40 -textvariable ::atos::parametres(atos,$visuNo,exec_ocr)
               pack $frms.frame3.ocr.frm.value -side right -padx 5 -pady 0
               label $frms.frame3.ocr.frm.lab -text "$caption(atos_setup,exec_ocr)"
               pack $frms.frame3.ocr.frm.lab -side right -padx 5 -pady 0

            pack $frms.frame3.ocr.frm -side left

         pack $frms.frame3.ocr -side top -fill both -expand 1

         #--- Frame pour le : free_space
         frame $frms.frame3.free_space -borderwidth 0

            frame $frms.frame3.free_space.frm -borderwidth 0
               entry $frms.frame3.free_space.frm.value -width 5 -textvariable ::atos::parametres(atos,$visuNo,free_space)
               pack $frms.frame3.free_space.frm.value -side right -padx 5 -pady 0
               label $frms.frame3.free_space.frm.lab -text "$caption(atos_setup,free_space)"
               pack $frms.frame3.free_space.frm.lab -side right -padx 5 -pady 0

            pack $frms.frame3.free_space.frm -side left

         pack $frms.frame3.free_space -side top -fill both -expand 1

         #--- Frame pour le : repertoire projet
         frame $frms.frame3.dir_prj -borderwidth 0

            frame $frms.frame3.dir_prj.frm -borderwidth 0
               entry $frms.frame3.dir_prj.frm.value -width 40 -textvariable ::atos::parametres(atos,$visuNo,dir_prj)
               pack $frms.frame3.dir_prj.frm.value -side right -padx 5 -pady 0
               button $frms.frame3.dir_prj.frm.but -text "..." -borderwidth 1 -command "::atos_setup::chgdir $frms.frame3.dir_prj.frm.value"
               pack $frms.frame3.dir_prj.frm.but -side right -padx 2 -pady 0
               label $frms.frame3.dir_prj.frm.lab -text "$caption(atos_setup,dir_prj)"
               pack $frms.frame3.dir_prj.frm.lab -side right -padx 5 -pady 0

            pack $frms.frame3.dir_prj.frm -side left

         pack $frms.frame3.dir_prj -side top -fill both -expand 1

         #--- Frame pour le : repertoire projet
#         frame $frms.frame3.demo -borderwidth 0
#
#            frame $frms.frame3.demo.frm -borderwidth 0
#               button $frms.frame3.demo.frm.but -text "Télécharger" -borderwidth 1 -command "::atos_setup::demo $visuNo $frms.frame3.demo.frm.but"
#               pack $frms.frame3.demo.frm.but -side right -padx 2 -pady 0
#               label $frms.frame3.demo.frm.lab -text "Télécharger la demo : "
#               pack $frms.frame3.demo.frm.lab -side right -padx 5 -pady 0
#            pack $frms.frame3.demo.frm -side left
#
#         pack $frms.frame3.demo -side top -fill both -expand 1

      # --
      pack $frms.frame3 -side top -fill both -expand 1
   }

}

#--- Initialisation au demarrage
::atos_setup::init

