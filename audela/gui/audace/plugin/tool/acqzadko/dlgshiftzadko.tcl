#
# Fichier : dlgshiftzadko.tcl
# Description : Fenetre de dialogue pour saisir les parametres de deplacement entre 2 images
# Auteur : Michel PUJOL
# Mise à jour $Id: dlgshiftzadko.tcl,v 1.1 2010-05-24 08:03:43 robertdelmas Exp $
#

namespace eval ::DlgShiftZadko {

   #------------------------------------------------------------
   #  init
   #      load configuration file
   #------------------------------------------------------------
   proc init { } {
      global audace

      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool acqzadko dlgshiftzadko.cap ]

      #--- Variables will be ready to use, so load data now
      loadDataFile
   }

   #------------------------------------------------------------
   #  initToConf
   #------------------------------------------------------------
   proc initToConf { } {
      variable parametres

      #--- Creation des variables si elles n'existent pas
      if { ! [ info exists parametres(DlgShiftZadko,buttonShift) ] }      { set parametres(DlgShiftZadko,buttonShift)      "0" }
      if { ! [ info exists parametres(DlgShiftZadko,geometry) ] }         { set parametres(DlgShiftZadko,geometry)         "278x182+657+251" }
      if { ! [ info exists parametres(DlgShiftZadko,position) ] }         { set parametres(DlgShiftZadko,position)         "+657+251" }
      if { ! [ info exists parametres(DlgShiftZadko,shiftSpeed) ] }       { set parametres(DlgShiftZadko,shiftSpeed)       "x5" }
      if { ! [ info exists parametres(DlgShiftZadko,xShiftDirection) ] }  { set parametres(DlgShiftZadko,xShiftDirection)  "O" }
      if { ! [ info exists parametres(DlgShiftZadko,xShiftDirection1) ] } { set parametres(DlgShiftZadko,xShiftDirection1) "w" }
      if { ! [ info exists parametres(DlgShiftZadko,xShiftTime) ] }       { set parametres(DlgShiftZadko,xShiftTime)       "2" }
      if { ! [ info exists parametres(DlgShiftZadko,yShiftDirection) ] }  { set parametres(DlgShiftZadko,yShiftDirection)  "N" }
      if { ! [ info exists parametres(DlgShiftZadko,yShiftDirection1) ] } { set parametres(DlgShiftZadko,yShiftDirection1) "n" }
      if { ! [ info exists parametres(DlgShiftZadko,yShiftTime) ] }       { set parametres(DlgShiftZadko,yShiftTime)       "2" }
   }

   #------------------------------------------------------------
   #  confToWidget
   #------------------------------------------------------------
   proc confToWidget { } {
      variable parametres
      global panneau

      #--- confToWidget
      set panneau(DlgShiftZadko,buttonShift)      $parametres(DlgShiftZadko,buttonShift)
      set panneau(DlgShiftZadko,geometry)         $parametres(DlgShiftZadko,geometry)
      set panneau(DlgShiftZadko,position)         $parametres(DlgShiftZadko,position)
      set panneau(DlgShiftZadko,shiftSpeed)       $parametres(DlgShiftZadko,shiftSpeed)
      set panneau(DlgShiftZadko,xShiftDirection)  $parametres(DlgShiftZadko,xShiftDirection)
      set panneau(DlgShiftZadko,xShiftDirection1) $parametres(DlgShiftZadko,xShiftDirection1)
      set panneau(DlgShiftZadko,xShiftTime)       $parametres(DlgShiftZadko,xShiftTime)
      set panneau(DlgShiftZadko,yShiftDirection)  $parametres(DlgShiftZadko,yShiftDirection)
      set panneau(DlgShiftZadko,yShiftDirection1) $parametres(DlgShiftZadko,yShiftDirection1)
      set panneau(DlgShiftZadko,yShiftTime)       $parametres(DlgShiftZadko,yShiftTime)
   }

   #------------------------------------------------------------
   #  run
   #      display dialog
   #------------------------------------------------------------
   proc run { this } {
      variable This

      set This $this
      createDialog
      tkwait window $This
      return
   }

   #------------------------------------------------------------
   #  cmdSave
   #------------------------------------------------------------
   proc cmdSave { } {
      variable parametres
      global panneau

      #---
      ::DlgShiftZadko::recup_position

      #---
      set parametres(DlgShiftZadko,buttonShift)      $panneau(DlgShiftZadko,buttonShift)
      set parametres(DlgShiftZadko,geometry)         $panneau(DlgShiftZadko,geometry)
      set parametres(DlgShiftZadko,position)         $panneau(DlgShiftZadko,position)
      set parametres(DlgShiftZadko,shiftSpeed)       $panneau(DlgShiftZadko,shiftSpeed)
      set parametres(DlgShiftZadko,xShiftDirection)  $panneau(DlgShiftZadko,xShiftDirection)
      set parametres(DlgShiftZadko,xShiftDirection1) $panneau(DlgShiftZadko,xShiftDirection1)
      set parametres(DlgShiftZadko,xShiftTime)       $panneau(DlgShiftZadko,xShiftTime)
      set parametres(DlgShiftZadko,yShiftDirection)  $panneau(DlgShiftZadko,yShiftDirection)
      set parametres(DlgShiftZadko,yShiftDirection1) $panneau(DlgShiftZadko,yShiftDirection1)
      set parametres(DlgShiftZadko,yShiftTime)       $panneau(DlgShiftZadko,yShiftTime)

      #--- Sauvegarde des parametres
      catch {
        set nom_fichier [ file join $::audace(rep_home) dlgshiftzadko.ini ]
        if [ catch { open $nom_fichier w } fichier ] {
           #---
        } else {
           foreach { a b } [ array get parametres ] {
              puts $fichier "set parametres($a) \"$b\""
           }
           close $fichier
        }
      }

      #--- close the dialog window
      closeDialog
   }

   #------------------------------------------------------------
   #  cmdCancel
   #      close dialog without saving
   #------------------------------------------------------------
   proc cmdCancel { } {
      #--- reload old values
      loadDataFile
      #--- close the dialog window
      closeDialog
   }

   #------------------------------------------------------------
   #  loadDataFile
   #      read file
   #      display fields values in the grid
   #------------------------------------------------------------
   proc loadDataFile { } {
      #--- Ouverture du fichier de parametres
      set fichier [ file join $::audace(rep_home) dlgshiftzadko.ini ]
      if { [ file exists $fichier ] } {
         source $fichier
      }
   }

   #------------------------------------------------------------
   #  closeDialog
   #      close dialog
   #------------------------------------------------------------
   proc closeDialog { } {
      variable This

      #--- close and destroy the dialog window
      destroy $This
      unset This

   }

   #------------------------------------------------------------
   #  Decalage_Telescope
   #      decalage du telescope pendant une serie d'images
   #------------------------------------------------------------
   proc Decalage_Telescope { } {
      global caption panneau

      #--- Déplacement du télescope
      if { $panneau(DlgShiftZadko,buttonShift) == "1" } {
         if { ( $panneau(DlgShiftZadko,xShiftDirection) != "" ) || ( $panneau(DlgShiftZadko,yShiftDirection) != "" ) } {
            ::console::affiche_saut "\n"
            ::console::affiche_resultat "$caption(dlgshiftzadko,labelTelescope)\n"
         }

         ::console::affiche_prompt "::telescope::setSpeed $panneau(DlgShiftZadko,shiftSpeed) \n"
         ::telescope::decodeSpeedDlgShiftZadko

         #--- Sur l'axe est/ouest
         if { $panneau(DlgShiftZadko,xShiftDirection) != "" } {
            if { $panneau(DlgShiftZadko,xShiftDirection) == "$caption(dlgshiftzadko,est)" } {
               set panneau(DlgShiftZadko,xShiftDirection1) "e"
            } elseif { $panneau(DlgShiftZadko,xShiftDirection) == "$caption(dlgshiftzadko,ouest)" } {
               set panneau(DlgShiftZadko,xShiftDirection1) "w"
            }
            ::telescope::move $panneau(DlgShiftZadko,xShiftDirection1)
            after [expr $panneau(DlgShiftZadko,xShiftTime) * 1000]
            ::telescope::stop $panneau(DlgShiftZadko,xShiftDirection1)
         }
         #--- Sur l'axe nord/sud
         if { $panneau(DlgShiftZadko,yShiftDirection) != "" } {
            if { $panneau(DlgShiftZadko,yShiftDirection) == "$caption(dlgshiftzadko,nord)" } {
               set panneau(DlgShiftZadko,yShiftDirection1) "n"
            } elseif { $panneau(DlgShiftZadko,yShiftDirection) == "$caption(dlgshiftzadko,sud)" } {
               set panneau(DlgShiftZadko,yShiftDirection1) "s"
            }
            ::telescope::move $panneau(DlgShiftZadko,yShiftDirection1)
            after [expr $panneau(DlgShiftZadko,yShiftTime) * 1000]
            ::telescope::stop $panneau(DlgShiftZadko,yShiftDirection1)
         }
         if { ( $panneau(DlgShiftZadko,xShiftDirection) != "" ) || ( $panneau(DlgShiftZadko,yShiftDirection) != "" ) } {
            ::console::affiche_resultat "$caption(dlgshiftzadko,labelStop)\n"
         }
      }
   }

   #------------------------------------------------------------
   #  recup_position
   #      give position window
   #------------------------------------------------------------
   proc recup_position { } {
      variable This
      global panneau

      set panneau(DlgShiftZadko,geometry) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $panneau(DlgShiftZadko,geometry) ] ]
      set fin [ string length $panneau(DlgShiftZadko,geometry) ]
      set panneau(DlgShiftZadko,position) "+[string range $panneau(DlgShiftZadko,geometry) $deb $fin]"
   }

   #------------------------------------------------------------
   #  createDialog
   #      display dialog window
   #------------------------------------------------------------
   proc createDialog { } {
      variable This
      variable parametres
      global caption conf panneau

      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This.frameButton.buttonSave
         return
      }

      #--- confToWidget
      ::DlgShiftZadko::confToWidget

      #---
      if { [ info exists panneau(DlgShiftZadko,geometry) ] } {
         set deb [ expr 1 + [ string first + $panneau(DlgShiftZadko,geometry) ] ]
         set fin [ string length $panneau(DlgShiftZadko,geometry) ]
         set panneau(DlgShiftZadko,position) "+[string range $panneau(DlgShiftZadko,geometry) $deb $fin]"
      }

      #--- create toplevel window
      toplevel $This -class Toplevel
      wm geometry $This $panneau(DlgShiftZadko,position)
      wm title $This $caption(dlgshiftzadko,title)

      #--- redirect WM_DELETE_WINDOW message
      wm protocol $This WM_DELETE_WINDOW {::DlgShiftZadko::cmdCancel}

      #--- create frame to display parameters -------------------------------------
      frame $This.frameConfig -borderwidth 1 -relief raised

      label $This.frameConfig.labelTimex -width 34 -borderwidth 2 -relief groove \
         -text $caption(dlgshiftzadko,labelTimex)
      grid configure $This.frameConfig.labelTimex -column 0 -row 0 -sticky we -in $This.frameConfig -ipadx 15 -ipady 5

      label $This.frameConfig.labelDirectionx -width 34 -borderwidth 2 -relief groove \
         -text $caption(dlgshiftzadko,labelDirectionx)
      grid configure $This.frameConfig.labelDirectionx -column 0 -row 1 -sticky we -in $This.frameConfig -ipadx 15 -ipady 5

      label $This.frameConfig.labelTimey -width 34 -borderwidth 2 -relief groove \
         -text $caption(dlgshiftzadko,labelTimey)
      grid configure $This.frameConfig.labelTimey -column 0 -row 2 -sticky we -in $This.frameConfig -ipadx 15 -ipady 5

      label $This.frameConfig.labelDirectiony -width 34 -borderwidth 2 -relief groove \
         -text $caption(dlgshiftzadko,labelDirectiony)
      grid configure $This.frameConfig.labelDirectiony -column 0 -row 3 -sticky we -in $This.frameConfig -ipadx 15 -ipady 5

      label $This.frameConfig.labelSpeed -width 34 -borderwidth 2 -relief groove \
         -text $caption(dlgshiftzadko,labelSpeed)
      grid configure $This.frameConfig.labelSpeed -column 0 -row 4 -sticky we -in $This.frameConfig -ipadx 15 -ipady 5

      #--- entry xShiftTime
      entry $This.frameConfig.xShiftTime -width 5 -borderwidth 2 -justify center \
         -textvariable panneau(DlgShiftZadko,xShiftTime)
      grid configure $This.frameConfig.xShiftTime -column 1 -row 0 -sticky we -in $This.frameConfig -ipady 5

      menubutton $This.frameConfig.xShiftDirection -textvariable panneau(DlgShiftZadko,xShiftDirection) \
         -menu $This.frameConfig.xShiftDirection.menu -relief raised
      grid configure $This.frameConfig.xShiftDirection -column 1 -row 1 -sticky we -in $This.frameConfig
      set m [menu $This.frameConfig.xShiftDirection.menu -tearoff 0]
      foreach xShiftDirection "$caption(dlgshiftzadko,est) $caption(dlgshiftzadko,ouest)" {
         $m add radiobutton -label "$xShiftDirection" \
            -indicatoron "1" \
            -value "$xShiftDirection" \
            -variable panneau(DlgShiftZadko,xShiftDirection) \
            -command { }
      }

      #--- entry yShiftTime
      entry $This.frameConfig.yShiftTime -width 5 -borderwidth 2 -justify center \
         -textvariable panneau(DlgShiftZadko,yShiftTime)
      grid configure $This.frameConfig.yShiftTime -column 1 -row 2 -sticky we -in $This.frameConfig -ipady 5

      menubutton $This.frameConfig.yShiftDirection -textvariable panneau(DlgShiftZadko,yShiftDirection) \
         -menu $This.frameConfig.yShiftDirection.menu -relief raised
      grid configure $This.frameConfig.yShiftDirection -column 1 -row 3 -sticky we -in $This.frameConfig
      set m [menu $This.frameConfig.yShiftDirection.menu -tearoff 0]
      foreach yShiftDirection "$caption(dlgshiftzadko,nord) $caption(dlgshiftzadko,sud)" {
         $m add radiobutton -label "$yShiftDirection" \
            -indicatoron "1" \
            -value "$yShiftDirection" \
            -variable panneau(DlgShiftZadko,yShiftDirection) \
            -command { }
      }

      if { $conf(telescope) == "audecom" } {
         set speed_list "$caption(dlgshiftzadko,x1) $caption(dlgshiftzadko,x5) $caption(dlgshiftzadko,200)"
      } elseif { $conf(telescope) == "temma" } {
         set speed_list "$caption(dlgshiftzadko,NS) $caption(dlgshiftzadko,HS)"
      } else {
         set speed_list "1 2 3 4"
      }

      menubutton $This.frameConfig.shiftSpeed -textvariable panneau(DlgShiftZadko,shiftSpeed) \
         -menu $This.frameConfig.shiftSpeed.menu -relief raised
      grid configure $This.frameConfig.shiftSpeed -column 1 -row 4 -sticky we -in $This.frameConfig
      set m [menu $This.frameConfig.shiftSpeed.menu -tearoff 0]
      foreach shiftSpeed $speed_list {
         $m add radiobutton -label "$shiftSpeed" \
            -indicatoron "1" \
            -value "$shiftSpeed" \
            -variable panneau(DlgShiftZadko,shiftSpeed) \
            -command { }
      }

      pack $This.frameConfig -side top -fill both -expand 0

      #--- create frame to display buttons -------------------------------------
      frame $This.frameButton -borderwidth 1 -relief raised

      #--- button CANCEL
      button $This.frameButton.buttonCancel -text $caption(dlgshiftzadko,buttonCancel) \
         -borderwidth 2 -command "::DlgShiftZadko::cmdCancel"
      pack   $This.frameButton.buttonCancel -in $This.frameButton -anchor w -fill none -side left \
         -padx 3 -pady 3 -ipadx 5 -ipady 3

      #--- button SAVE
      button $This.frameButton.buttonSave -text $caption(dlgshiftzadko,buttonSave) \
         -borderwidth 2  -command "::DlgShiftZadko::cmdSave"
      pack   $This.frameButton.buttonSave -in $This.frameButton -anchor e -fill none \
         -padx 3 -pady 3 -ipadx 5 -ipady 3

      pack $This.frameButton -side bottom -fill both -expand 0

      #--- La fenetre est active
      focus $This

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }
}

::DlgShiftZadko::init

