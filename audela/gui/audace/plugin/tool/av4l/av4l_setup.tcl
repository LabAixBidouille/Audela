#
# Fichier : av4l_setup.tcl
# Description : Configuration de certains parametres de l'outil Acquisition
# Auteur : Robert DELMAS
# Mise à jour $Id$
#

namespace eval ::av4l_setup {

   #
   # av4l_setup::init
   # Chargement des captions
   #
   proc ::av4l_setup::init { } {
      global audace

      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool av4l av4l_setup.cap ]
   }

   #
   # av4l_setup::initToConf
   # Initialisation des variables de configuration
   #
   proc ::av4l_setup::initToConf { visuNo } {

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,messages) ] }                   { set ::av4l::parametres(av4l,$visuNo,messages)                  "1" }
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,save_file_log) ] }              { set ::av4l::parametres(av4l,$visuNo,save_file_log)             "1" }
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,alarme_fin_serie) ] }           { set ::av4l::parametres(av4l,$visuNo,alarme_fin_serie)          "1" }
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,verifier_ecraser_fichier) ] }   { set ::av4l::parametres(av4l,$visuNo,verifier_ecraser_fichier)  "1" }
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,verifier_index_depart) ] }      { set ::av4l::parametres(av4l,$visuNo,verifier_index_depart)     "1" }
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,mode_debug) ] }                 { set ::av4l::parametres(av4l,$visuNo,mode_debug)                "0" }
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,screen_refresh) ] }             { set ::av4l::parametres(av4l,$visuNo,screen_refresh)            "1000" }
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,exec_ocr) ] }                   { set ::av4l::parametres(av4l,$visuNo,exec_ocr)                  "jpegtopnm ocr.jpg | gocr -C 0-9 -f UTF8" }
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,free_space) ] }                 { set ::av4l::parametres(av4l,$visuNo,free_space)                "500" }
      if { ! [ info exists ::av4l::parametres(av4l,$visuNo,dir_prj) ] }                    { set ::av4l::parametres(av4l,$visuNo,dir_prj)                   "" }
   }


   #
   # av4l_setup::run
   # Cree la fenetre de configuration de l'affichage des messages sur la Console
   # et de l'enregistrement des dates dans le fichier log
   #
   proc ::av4l_setup::run { visuNo this } {

      global audace panneau

      #--- Determination de la fenetre parente
      if { $visuNo == "1" } {
         set base "$audace(base)"
      } else {
         set base ".visu$visuNo"
      }

      #---
      set panneau(av4l,$visuNo,av4l_setup) $this
      ::confGenerique::run $visuNo "$panneau(av4l,$visuNo,av4l_setup)" "::av4l_setup" -modal 0
      set posx_config [ lindex [ split [ wm geometry $base ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $base ] "+" ] 2 ]
      wm geometry $panneau(av4l,$visuNo,av4l_setup) +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
   }

   #
   # av4l_setup::apply
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc ::av4l_setup::apply { visuNo } {
       #--- Sauvegarde de la configuration de prise de vue
      ::av4l_setup::enregistrerVariable $visuNo

   }

   #
   # av4l_setup::showHelp
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc ::av4l_setup::showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::av4l::getPluginType ] ] \
         [ ::av4l::getPluginDirectory ] av4l_setup.htm
   }

   #
   # av4l_setup::closeWindow
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc ::av4l_setup::closeWindow { visuNo } {

   }

   #
   # av4l_setup::getLabel
   # Retourne le nom de la fenetre de configuration
   #
   proc ::av4l_setup::getLabel { } {
      global caption

      return "$caption(av4l_setup,titre)"
   }


   #------------------------------------------------------------
   # ::av4l::deletePluginInstance
   #    suppprime l'instance du plugin
   #------------------------------------------------------------
   proc ::av4l_setup::enregistrerVariable { visuNo } {

      ::console::affiche_resultat "Enregistrement de la Configuration...\n"
      #foreach { a b } [ array get ::av4l::parametres ] {
      #   if  {[string first av4l $a]==0} {
      #   ::console::affiche_resultat "$a = $b\n"
      #   }
      #}

      #--- Sauvegarde des parametres
      catch {
        set nom_fichier [ file join $::audace(rep_home) av4l.ini ]
        if [ catch { open $nom_fichier w } fichier ] {
           #---
        } else {
           foreach { a b } [ array get ::av4l::parametres ] {
              if  {[string first av4l $a]==0} {
                 puts $fichier "set ::av4l::parametres($a) \"$b\""
              }
           }
           close $fichier
        }
      }
   }

   #
   # av4l_acq::chgdir
   # Ouvre une boite de dialogue pour choisir un nom  de repertoire
   #
   proc ::av4l_setup::chgdir { This } {
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
   # av4l_setup::fillConfigPage
   # Creation de l'interface graphique
   #
   proc ::av4l_setup::fillConfigPage { frm visuNo } {

      global caption panneau

      #--- Retourne l'item de la camera associee a la visu
      set camItem [ ::confVisu::getCamItem $visuNo ]
      set frms $panneau(av4l,$visuNo,av4l_setup)


      #--- Frame pour les commentaires
      frame $frms.frame3 -borderwidth 1 -relief raise

         #--- Frame pour l'en-tete FITS
         frame $frms.frame3.en-tete -borderwidth 0

            #--- Label de l'en-tete FITS
            label $frms.frame3.en-tete.lab -text $caption(av4l_setup,en-tete_fits)
            pack $frms.frame3.en-tete.lab -side left -padx 6

            #--- Bouton d'acces aux mots cles
            button $frms.frame3.en-tete.but -text $caption(av4l_setup,mots_cles) \
               -command "::keyword::run $visuNo ::conf(av4l,keywordConfigName)"
            pack $frms.frame3.en-tete.but -side left -padx 6 -pady 10 -ipadx 20

            #--- Label du nom de la configuration de l'en-tete FITS
            entry $frms.frame3.en-tete.labNom \
               -state readonly -takefocus 0 -textvariable ::conf(av4l,keywordConfigName) -justify center
            pack $frms.frame3.en-tete.labNom -side left -padx 6

         pack $frms.frame3.en-tete -side top -fill both -expand 1

         #--- Frame pour le commentaire 1
         frame $frms.frame3.frame4 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 1
            frame $frms.frame3.frame4.frame8 -borderwidth 0
               checkbutton $frms.frame3.frame4.frame8.check1 -highlightthickness 0 \
                  -text "$caption(av4l_setup,texte1)" -variable ::av4l::parametres(av4l,$visuNo,messages)
               pack $frms.frame3.frame4.frame8.check1 -side right -padx 5 -pady 0
            pack $frms.frame3.frame4.frame8 -side left

         pack $frms.frame3.frame4 -side top -fill both -expand 1

         #--- Frame pour le commentaire 4 : verifier_ecraser_fichier
         frame $frms.frame3.frame7 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 4
            frame $frms.frame3.frame7.frame12 -borderwidth 0
               checkbutton $frms.frame3.frame7.frame12.check3 -highlightthickness 0 \
                  -text "$caption(av4l_setup,texte4)" -variable ::av4l::parametres(av4l,$visuNo,verifier_ecraser_fichier)
               pack $frms.frame3.frame7.frame12.check3 -side right -padx 5 -pady 0
            pack $frms.frame3.frame7.frame12 -side left

         pack $frms.frame3.frame7 -side top -fill both -expand 1

         #--- Frame pour le commentaire 5 : mode_debug
         frame $frms.frame3.frame9 -borderwidth 0

            #--- Cree le checkbutton pour le commentaire 5
            frame $frms.frame3.frame9.frame12 -borderwidth 0
               checkbutton $frms.frame3.frame9.frame12.check3 -highlightthickness 0 \
                  -text "$caption(av4l_setup,texte6)" -variable ::av4l::parametres(av4l,$visuNo,mode_debug)
               pack $frms.frame3.frame9.frame12.check3 -side right -padx 5 -pady 0
            pack $frms.frame3.frame9.frame12 -side left

         pack $frms.frame3.frame9 -side top -fill both -expand 1

         #--- Frame pour le : screen_refresh
         frame $frms.frame3.screen_refresh -borderwidth 0

            frame $frms.frame3.screen_refresh.frm -borderwidth 0
               entry $frms.frame3.screen_refresh.frm.value -width 5 -textvariable ::av4l::parametres(av4l,$visuNo,screen_refresh)
               pack $frms.frame3.screen_refresh.frm.value -side right -padx 5 -pady 0
               label $frms.frame3.screen_refresh.frm.lab -text "$caption(av4l_setup,screen_refresh)"
               pack $frms.frame3.screen_refresh.frm.lab -side right -padx 5 -pady 0 

            pack $frms.frame3.screen_refresh.frm -side left

         pack $frms.frame3.screen_refresh -side top -fill both -expand 1

         #--- Frame pour le : exec_ocr
         frame $frms.frame3.ocr -borderwidth 0

            frame $frms.frame3.ocr.frm -borderwidth 0
               button $frms.frame3.ocr.frm.but -text "test" -borderwidth 0 -command "" 
               pack $frms.frame3.ocr.frm.but -side right -padx 5 -pady 0
               entry $frms.frame3.ocr.frm.value -width 30 -textvariable ::av4l::parametres(av4l,$visuNo,exec_ocr)
               pack $frms.frame3.ocr.frm.value -side right -padx 5 -pady 0
               label $frms.frame3.ocr.frm.lab -text "$caption(av4l_setup,exec_ocr)"
               pack $frms.frame3.ocr.frm.lab -side right -padx 5 -pady 0 

            pack $frms.frame3.ocr.frm -side left

         pack $frms.frame3.ocr -side top -fill both -expand 1

         #--- Frame pour le : free_space
         frame $frms.frame3.free_space -borderwidth 0

            frame $frms.frame3.free_space.frm -borderwidth 0
               entry $frms.frame3.free_space.frm.value -width 5 -textvariable ::av4l::parametres(av4l,$visuNo,free_space)
               pack $frms.frame3.free_space.frm.value -side right -padx 5 -pady 0
               label $frms.frame3.free_space.frm.lab -text "$caption(av4l_setup,free_space)"
               pack $frms.frame3.free_space.frm.lab -side right -padx 5 -pady 0 

            pack $frms.frame3.free_space.frm -side left

         pack $frms.frame3.free_space -side top -fill both -expand 1

         #--- Frame pour le : repertoire projet
         frame $frms.frame3.dir_prj -borderwidth 0

            frame $frms.frame3.dir_prj.frm -borderwidth 0
               entry $frms.frame3.dir_prj.frm.value -width 40 -textvariable ::av4l::parametres(av4l,$visuNo,dir_prj)
               pack $frms.frame3.dir_prj.frm.value -side right -padx 5 -pady 0
               button $frms.frame3.dir_prj.frm.but -text "..." -borderwidth 0 -command "::av4l_setup::chgdir $frms.frame3.dir_prj.frm.value" 
               pack $frms.frame3.dir_prj.frm.but -side right -padx 2 -pady 0
               label $frms.frame3.dir_prj.frm.lab -text "$caption(av4l_setup,dir_prj)"
               pack $frms.frame3.dir_prj.frm.lab -side right -padx 5 -pady 0 

            pack $frms.frame3.dir_prj.frm -side left

         pack $frms.frame3.dir_prj -side top -fill both -expand 1


      # --
      pack $frms.frame3 -side top -fill both -expand 1
   }

}

#--- Initialisation au demarrage
::av4l_setup::init
