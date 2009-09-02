#
# Fichier : dlgshift.tcl
# Description : Fenetre de dialogue pour saisir les parametres de deplacement entre 2 images
# Auteur : Michel PUJOL
# Mise a jour $Id: dlgshift.tcl,v 1.1 2009-09-02 03:58:50 myrtillelaas Exp $
#

namespace eval ::DlgShift {

   #------------------------------------------------------------
   #  init
   #      load configuration file
   #------------------------------------------------------------
   proc init { } {
      global audace fileName

      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool acqzadko dlgshift.cap ]

      #--- set fileName
      set fileName [ file join $audace(rep_plugin) tool acqzadko dlgshift_ini.tcl ]

      #--- Variables will be ready to use, so load data now
      loadDataFile
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
      global fileName panneau

      #---
      ::DlgShift::recup_position

      set arrayName "panneau"
      set namePattern "DlgShift*"

      #--- save new values into the file
      set fid [open [file join $fileName] w]
      puts $fid "global $arrayName"

      foreach a [lsort [array names $arrayName $namePattern ]] {
         puts $fid "set panneau($a) \"[lindex [array get $arrayName $a] 1]\""
      }
      close $fid

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
      global fileName panneau

      set arrayName "panneau"
      set tempinterp [interp create]
      interp eval $tempinterp "source \"$fileName\""
      array set $arrayName [interp eval $tempinterp "array get $arrayName"]
      interp delete $tempinterp

      return [array get $arrayName]
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
      if { $panneau(DlgShift,buttonShift) == "1" } {
         if { ( $panneau(DlgShift,xShiftDirection) != "" ) || ( $panneau(DlgShift,yShiftDirection) != "" ) } {
            console::affiche_saut "\n"
            ::console::affiche_resultat "$caption(dlgshift,labelTelescope)\n"
         }

         console::affiche_erreur "::telescope::setSpeed $panneau(DlgShift,shiftSpeed) \n"
         ::telescope::decodeSpeedDlgShift

         #--- Sur l'axe est/ouest
         if { $panneau(DlgShift,xShiftDirection) != "" } {
            if { $panneau(DlgShift,xShiftDirection) == "$caption(dlgshift,est)" } {
               set panneau(DlgShift,xShiftDirection1) "e"
            } elseif { $panneau(DlgShift,xShiftDirection) == "$caption(dlgshift,ouest)" } {
               set panneau(DlgShift,xShiftDirection1) "w"
            }
            ::telescope::move $panneau(DlgShift,xShiftDirection1)
            after [expr $panneau(DlgShift,xShiftTime) * 1000]
            ::telescope::stop $panneau(DlgShift,xShiftDirection1)
         }
         #--- Sur l'axe nord/sud
         if { $panneau(DlgShift,yShiftDirection) != "" } {
            if { $panneau(DlgShift,yShiftDirection) == "$caption(dlgshift,nord)" } {
               set panneau(DlgShift,yShiftDirection1) "n"
            } elseif { $panneau(DlgShift,yShiftDirection) == "$caption(dlgshift,sud)" } {
               set panneau(DlgShift,yShiftDirection1) "s"
            }
            ::telescope::move $panneau(DlgShift,yShiftDirection1)
            after [expr $panneau(DlgShift,yShiftTime) * 1000]
            ::telescope::stop $panneau(DlgShift,yShiftDirection1)
         }
         if { ( $panneau(DlgShift,xShiftDirection) != "" ) || ( $panneau(DlgShift,yShiftDirection) != "" ) } {
            ::console::affiche_resultat "$caption(dlgshift,labelStop)\n"
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

      set panneau(DlgShift,geometry) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $panneau(DlgShift,geometry) ] ]
      set fin [ string length $panneau(DlgShift,geometry) ]
      set panneau(DlgShift,position) "+[string range $panneau(DlgShift,geometry) $deb $fin]"
   }

   #------------------------------------------------------------
   #  createDialog
   #      display dialog window
   #------------------------------------------------------------
   proc createDialog { } {
      variable This
      global caption conf panneau

      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This.frameButton.buttonSave
         return
      }

      if { [ info exists panneau(DlgShift,geometry) ] } {
         set deb [ expr 1 + [ string first + $panneau(DlgShift,geometry) ] ]
         set fin [ string length $panneau(DlgShift,geometry) ]
         set panneau(DlgShift,position) "+[string range $panneau(DlgShift,geometry) $deb $fin]"
      }

      #--- create toplevel window
      toplevel $This -class Toplevel
      wm geometry $This $panneau(DlgShift,position)
      wm title $This $caption(dlgshift,title)

      #--- redirect WM_DELETE_WINDOW message
      wm protocol $This WM_DELETE_WINDOW {::DlgShift::cmdCancel}

      #--- create frame to display parameters -------------------------------------
      frame $This.frameConfig -borderwidth 1 -relief raised

      label $This.frameConfig.labelTimex -width 34 -borderwidth 2 -relief groove \
         -text $caption(dlgshift,labelTimex)
      grid configure $This.frameConfig.labelTimex -column 0 -row 0 -sticky we -in $This.frameConfig -ipadx 15 -ipady 5

      label $This.frameConfig.labelDirectionx -width 34 -borderwidth 2 -relief groove \
         -text $caption(dlgshift,labelDirectionx)
      grid configure $This.frameConfig.labelDirectionx -column 0 -row 1 -sticky we -in $This.frameConfig -ipadx 15 -ipady 5

      label $This.frameConfig.labelTimey -width 34 -borderwidth 2 -relief groove \
         -text $caption(dlgshift,labelTimey)
      grid configure $This.frameConfig.labelTimey -column 0 -row 2 -sticky we -in $This.frameConfig -ipadx 15 -ipady 5

      label $This.frameConfig.labelDirectiony -width 34 -borderwidth 2 -relief groove \
         -text $caption(dlgshift,labelDirectiony)
      grid configure $This.frameConfig.labelDirectiony -column 0 -row 3 -sticky we -in $This.frameConfig -ipadx 15 -ipady 5

      label $This.frameConfig.labelSpeed -width 34 -borderwidth 2 -relief groove \
         -text $caption(dlgshift,labelSpeed)
      grid configure $This.frameConfig.labelSpeed -column 0 -row 4 -sticky we -in $This.frameConfig -ipadx 15 -ipady 5

      #--- entry xShiftTime
      entry $This.frameConfig.xShiftTime -width 5 -borderwidth 2 -justify center \
         -textvariable panneau(DlgShift,xShiftTime)
      grid configure $This.frameConfig.xShiftTime -column 1 -row 0 -sticky we -in $This.frameConfig -ipady 5

      menubutton $This.frameConfig.xShiftDirection -textvariable panneau(DlgShift,xShiftDirection) \
         -menu $This.frameConfig.xShiftDirection.menu -relief raised
      grid configure $This.frameConfig.xShiftDirection -column 1 -row 1 -sticky we -in $This.frameConfig
      set m [menu $This.frameConfig.xShiftDirection.menu -tearoff 0]
      foreach xShiftDirection "$caption(dlgshift,est) $caption(dlgshift,ouest)" {
         $m add radiobutton -label "$xShiftDirection" \
            -indicatoron "1" \
            -value "$xShiftDirection" \
            -variable panneau(DlgShift,xShiftDirection) \
            -command { }
      }

      #--- entry yShiftTime
      entry $This.frameConfig.yShiftTime -width 5 -borderwidth 2 -justify center \
         -textvariable panneau(DlgShift,yShiftTime)
      grid configure $This.frameConfig.yShiftTime -column 1 -row 2 -sticky we -in $This.frameConfig -ipady 5

      menubutton $This.frameConfig.yShiftDirection -textvariable panneau(DlgShift,yShiftDirection) \
         -menu $This.frameConfig.yShiftDirection.menu -relief raised
      grid configure $This.frameConfig.yShiftDirection -column 1 -row 3 -sticky we -in $This.frameConfig
      set m [menu $This.frameConfig.yShiftDirection.menu -tearoff 0]
      foreach yShiftDirection "$caption(dlgshift,nord) $caption(dlgshift,sud)" {
         $m add radiobutton -label "$yShiftDirection" \
            -indicatoron "1" \
            -value "$yShiftDirection" \
            -variable panneau(DlgShift,yShiftDirection) \
            -command { }
      }

      if { $conf(telescope) == "audecom" } {
         set speed_list "$caption(dlgshift,x1) $caption(dlgshift,x5) $caption(dlgshift,200)"
      } elseif { $conf(telescope) == "temma" } {
         set speed_list "$caption(dlgshift,NS) $caption(dlgshift,HS)"
      } else {
         set speed_list "1 2 3 4"
      }

      menubutton $This.frameConfig.shiftSpeed -textvariable panneau(DlgShift,shiftSpeed) \
         -menu $This.frameConfig.shiftSpeed.menu -relief raised
      grid configure $This.frameConfig.shiftSpeed -column 1 -row 4 -sticky we -in $This.frameConfig
      set m [menu $This.frameConfig.shiftSpeed.menu -tearoff 0]
      foreach shiftSpeed $speed_list {
         $m add radiobutton -label "$shiftSpeed" \
            -indicatoron "1" \
            -value "$shiftSpeed" \
            -variable panneau(DlgShift,shiftSpeed) \
            -command { }
      }

      pack $This.frameConfig -side top -fill both -expand 0

      #--- create frame to display buttons -------------------------------------
      frame $This.frameButton -borderwidth 1 -relief raised

      #--- button CANCEL
      button $This.frameButton.buttonCancel -text $caption(dlgshift,buttonCancel) \
         -borderwidth 2 -command "::DlgShift::cmdCancel"
      pack   $This.frameButton.buttonCancel -in $This.frameButton -anchor w -fill none -side left \
         -padx 3 -pady 3 -ipadx 5 -ipady 3

      #--- button SAVE
      button $This.frameButton.buttonSave -text $caption(dlgshift,buttonSave) \
         -borderwidth 2  -command "::DlgShift::cmdSave"
      pack   $This.frameButton.buttonSave -in $This.frameButton -anchor e -fill none \
         -padx 3 -pady 3 -ipadx 5 -ipady 3

      pack $This.frameButton -side bottom -fill both -expand 0

      #--- La fenetre est active
      focus $This

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }
}

::DlgShift::init

