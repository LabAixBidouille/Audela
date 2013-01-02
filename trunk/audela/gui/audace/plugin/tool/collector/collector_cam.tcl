#
# Fichier : collector_cam.tcl
# Description :
# Auteur : Raymond Zachantke
# Mise à jour $Id$
#

   #----------gestion de la fenetre Ajouter/Supprimer une camera--------------
   # ::collector::addNewCam
   # ::collector::cmdaddCam
   # ::collector::cmdsupprCam
   # ::collector::cmdcancel
   # ::collector::configCamList
   # ::collector::setConfCam
   # ::collector::changeEntryStyle

   #---------------------------------------------------------------------------
   #  addNewCam
   #  Fenetre de saisie du nom d'une nouvelle camera
   #  Commande associee a 'Nouvelle camera'
   #---------------------------------------------------------------------------
   proc addNewCam {} {
      variable private
      global audace caption

      set this $audace(base).newCam
      if {![info exists private(newCam)]} {
         set private(newCam) ""
      }

      #---
      if { [ winfo exists $this ] } {
         wm withdraw $this
         wm deiconify $this
         focus $this
         return
      }

      toplevel $this -class Toplevel
      wm title $this $caption(collector,addSupprCam)
      lassign [split [wm geometry $private(This)] "+"] -> posx posy
      wm geometry $this +[expr {$posx + 200}]+[expr {$posy + 10}]
      wm resizable $this 0 0
      wm transient  $this $private(This)
      wm protocol $this WM_DELETE_WINDOW ::collector::cmdCancelNewCam

      label $this.lab -text "$caption(collector,camName)"
      grid $this.lab -row 0 -column 0 -padx 5 -pady 5
      ttk::entry $this.name -textvariable ::collector::private(newCam) -width 20 -justify center
      grid $this.name -row 0 -column 1 -columnspan 2 -padx 5 -pady 5 -sticky w

      set c 0
      foreach b [list addCam supprCam cancel] {
         grid [ttk::button $this.$b -text $caption(collector,$b) -command "::collector::cmd$b"] \
            -row 1 -column $c -padx 2 -pady 5
         incr c
      }

      #--   signale les parametres en rouge
      collector::changeEntryStyle $private(paramsList) "default.TEntry"

      focus $this.name

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $this
   }

   #---------------------------------------------------------------------------
   #  cmdaddCam
   #  Complete l'array des cameras et actualise la liste de la combobox
   #  Commande associee au bouton OK
   #---------------------------------------------------------------------------
   proc cmdaddCam { } {
      variable private
      global caption cameras

      set newCam [string trimright $private(newCam)]
      set newCam [string trimleft $newCam]

      if {$newCam ne ""} {

         #--   collecte les donnees
         set data [::struct::list map $private(paramsList) getValue]
         for {set k 2} {$k <=3} {incr k} {
            set value [expr {[lindex $data $k]*1e-6}]
            set data [lreplace $data $k $k $value]
         }

         #--   complete l'array
         if {[llength $data] == 9} {
            array set cameras [list $newCam $data]
         }

         configCamList $private(newCam)
         setConfCam
      }

      cmdcancel
   }

   #---------------------------------------------------------------------------
   #  cmdsupprCam
   #  Supprime une camera dans la liste de la combobox et dans l'array
   #---------------------------------------------------------------------------
   proc cmdsupprCam {} {
      variable private
      global caption cameras

     if {$private(newCam) in $private(actualListOfCam)} {

         #-- met a jour l'array
         array unset cameras $private(newCam)

         #--   cherche le rang de la camera a pointer
         set l [lsearch $private(actualListOfCam) $private(newCam)]
         #--   selectionne la cam de rang inferieur
         incr l -1
         if {$l < 0} {set l 0}
         set detnam [lindex $private(actualListOfCam) $l]

         configCamList $detnam
         setConfCam
     }

     cmdcancel
   }

   #---------------------------------------------------------------------------
   #  cmdcancel
   #  Ferme la fenetre de saisie
   #  Commande associee au bouton Cancel
   #---------------------------------------------------------------------------
   proc cmdcancel { } {
      variable private
      global audace

      if {[info exists private(newCam)]} {
         unset private(newCam)
      }

      destroy $audace(base).newCam

      #--   remet tous les parametres en noir
      changeEntryStyle $private(paramsList) "TEntry"
   }

   #---------------------------------------------------------------------------
   #  configCamList
   #  Actualise la variable private(actualListOfCam) a partir de l'array cameras
   #  et la liste de la combobox
   #---------------------------------------------------------------------------
   proc configCamList { camName } {
      variable private
      global caption cameras

      set camList [lsort -dictionary [array names cameras]]
      set k [lsearch $camList ""]
      if {$k !=  -1 } {
         set camList [lreplace $camList $k $k]
      }
      set private(actualListOfCam) $camList

      #--   ajoute 'Nouvelle camera" a la liste
      set values [linsert $private(actualListOfCam) end $caption(collector,newCam)]
      $private(This).n.cam.detnam configure -values $values

      set private(detnam) $camName

      #--   met a jour etc_tools
      modifyCamera
   }

   #---------------------------------------------------------------------------
   #  setConfCam
   #  Actualise la variable conf(collector,cam)
   #---------------------------------------------------------------------------
   proc setConfCam { } {
      variable private
      global conf cameras

      set conf(collector,cam) ""
      foreach camName $private(actualListOfCam) {
         if {[lsearch $private(etcCam) $camName] == -1} {
            lappend conf(collector,cam) [array get cameras $camName]
         }
      }
   }

   #---------------------------------------------------------------------------
   #  changeEntryStyle
   #  Change la couleur des valeurs affichees
   #  Paramètres : params (liste des variables a modifier)
   #     et style [default.Tentry == rouge | TEntry == $audace(color,entryTextColor)}
   #---------------------------------------------------------------------------
   proc changeEntryStyle { params style } {
      variable private

      set w $private(This).n.cam

      foreach child $params {
         if {[winfo exists $w.$child]} {
            $w.$child configure -style $style
         }
      }
   }

