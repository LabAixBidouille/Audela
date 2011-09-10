#
# Fichier : telshift.tcl
# Description : Script de prise d'images avec deplacement du telescope entre les poses
# Auteur : Christian JASINSKI (e-mail : chris.jasinski@wanadoo.fr)
# Avec l'aide d'Alain KLOTZ pour la partie la plus difficile (grande boucle interne aux procedures)
# Avec l'aide de Robert DELMAS qui a apporte de nombreuses modifications, notamment en matiere de traitement des erreurs
# Mise à jour $Id$
#

#!/logiciels/public/Tcl/bin/wish

#============================================================
# Declaration du namespace telshift
#    initialise le namespace
#============================================================
namespace eval ::telshift {

   #--- loading captions
   source [ file join $audace(rep_plugin) tool telshift telshift.cap ]

   proc createPanel { } {
      #--- create a window
      global base
      global audace
      global caption
      global panneau
      global conf
      global color

      if { ! [ info exists conf(telshift,position) ] } { set conf(telshift,position) "+150+100" }

      set base $audace(base).telima

      if { [winfo exists $base] } {
         wm withdraw $base
         wm deiconify $base
         focus $base.btn.annuler
         return
      }

      set panneau(telshift,stop) "0"

      toplevel $base

      #--- set window title
      wm minsize $base 350 480
      wm title $base "$caption(telshift,titre)"
      wm geometry $base $conf(telshift,position)
      wm protocol $base WM_DELETE_WINDOW ::telshift::Close

      #--- create frames
      frame $base.filename -borderwidth 2 -relief raised
      frame $base.focale -borderwidth 2 -relief raised
      frame $base.binning -borderwidth 2 -relief raised
      frame $base.para -borderwidth 2 -relief raised
      frame $base.image -borderwidth 2 -relief raised
      frame $base.btn -borderwidth 2 -relief raised
      pack $base.btn -side bottom -fill x
      pack $base.filename $base.focale $base.binning $base.image -side top -padx 10 -pady 10
      pack $base.para -ipady 5 -padx 10 -pady 10

      #--- create buttons
      button $base.btn.ok -text "$caption(telshift,ok)" -command ::telshift::Run
      button $base.btn.annuler -text "$caption(telshift,annuler)" -command ::telshift::Close
      button $base.btn.help1 -text "$caption(telshift,aide)" -command ::telshift::Open
      pack $base.btn.ok -side left -ipadx 30 -ipady 5
      pack $base.btn.annuler -side left -ipadx 20 -ipady 5
      pack $base.btn.help1 -side right -ipadx 20 -ipady 5

      #--- create text field in filename frame
      global filename

      label $base.filename.labname -text "$caption(telshift,nomfichier)"
      entry $base.filename.name -width 15 -relief sunken -textvariable filename
      pack $base.filename.labname -side top -anchor center
      pack $base.filename.name -side bottom -pady 5
      bind $base.filename.name <Leave> {
        $base.btn.ok configure -relief raised -state normal
        after 400
        destroy $audace(base).erreurfocale
      }

      #--- create entries and nested frames in parameter frame
      global nbr
      global pose

      frame $base.para.nest1
      label $base.para.labparapose -text "$caption(telshift,parametres)"
      label $base.para.labURL_status_cam -text "$caption(telshift,status)" -fg $color(blue)
      label $base.para.nest1.labnbr -text "$caption(telshift,nbposes)"
      entry $base.para.nest1.nbr -width 3 -relief sunken -textvariable nbr -justify center
      frame $base.para.nest2
      label $base.para.nest2.labduree -text "$caption(telshift,dureepose)"
      entry $base.para.nest2.pose -width 3 -relief sunken -textvariable pose -justify center
      label $base.para.nest2.labsec -text "$caption(telshift,secondes)"

      pack $base.para.labparapose -side top -anchor w
      pack $base.para.labURL_status_cam -side top -anchor center
      pack $base.para.nest1 -side top -ipady 5 -anchor w
      pack $base.para.nest1.labnbr -side left -padx 5
      pack $base.para.nest1.nbr -side left -anchor w -padx 5
      pack $base.para.nest2 -side top -ipady 5 -anchor w
      pack $base.para.nest2.labduree -side left -padx 5
      pack $base.para.nest2.pose -side left
      pack $base.para.nest2.labsec -side left -padx 5

      #--- create radiobuttons in binning frame
      global choice_binning

      label $base.binning.labbin -text "$caption(telshift,binning)"
      pack $base.binning.labbin -side top -anchor w
      foreach {x y z} [ list "$caption(telshift,binning1)" b1 1 "$caption(telshift,binning2)" b2 2 "$caption(telshift,binning4)" b3 4 ] {
         radiobutton $base.binning.$y -text $x -variable choice_binning -value $z
         pack $base.binning.$y -side left -padx 5
      }
      $base.binning.b2 select

      #--- create text field in focal length frame
      global foc

      label $base.focale.labfoc -text "$caption(telshift,focale)"
      entry $base.focale.length -width 15 -relief sunken -textvariable foc
      label $base.focale.mm -text "$caption(telshift,mm)"
      pack $base.focale.labfoc -side top -anchor w
      pack $base.focale.length -side left -anchor w -pady 5
      pack $base.focale.mm -side left -padx 5
      bind $base.focale.length <Leave> {
         $base.btn.ok configure -relief raised -state normal
         after 400
         destroy $audace(base).erreurfocale
      }

      #--- create radiobuttons and label in image frame
      global choice_proc

      label $base.image.labima -text "$caption(telshift,imagerie)"
      pack $base.image.labima -side top -anchor w
      foreach {x y z} [ list "$caption(telshift,imagenormale)" r1 ima "$caption(telshift,superflat)" r2 super "$caption(telshift,mosaique4)" r3 4mosa "$caption(telshift,mosaique9)" r4 9mosa ] {
         radiobutton $base.image.$y -text $x -variable choice_proc -value $z
         pack $base.image.$y -side top -anchor w -padx 5
      }
      $base.image.r1 select
      bind $base.image.r3 <Button-1> {$base.para.nest1.labnbr config -text "$caption(telshift,nbposesmosa)"}
      bind $base.image.r4 <Button-1> {$base.para.nest1.labnbr config -text "$caption(telshift,nbposesmosa)"}
      bind $base.image.r1 <Button-1> {$base.para.nest1.labnbr config -text "$caption(telshift,nbposes)"}
      bind $base.image.r2 <Button-1> {$base.para.nest1.labnbr config -text "$caption(telshift,nbposes)"}

      #--- set up key binding
      bind $base.btn.ok <Return> ::telshift::Run
      bind $base.btn.annuler <Escape> ::telshift::Close
      focus $base.para.nest1.nbr

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $base <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $base
   }

   #--- launch Open procedure for help
   proc Open { } {
      global audace
      global caption
      global base
      global langage

      #--- create a window
      set aide $audace(base).help1
      if { [winfo exists $aide] } {
         wm withdraw $aide
         wm deiconify $aide
         focus $aide
         return
      }
      toplevel $aide
      #--- set window title
      wm resizable $aide 1 1
      wm maxsize $aide 350 350
      wm title $aide "$caption(telshift,aideutil)"
      set posx_help1 [ lindex [ split [ wm geometry $base ] "+" ] 1 ]
      set posy_help1 [ lindex [ split [ wm geometry $base ] "+" ] 2 ]
      wm geometry $audace(base).help1 +[ expr $posx_help1 + 370 ]+[ expr $posy_help1 + 0 ]
      #--- create text area and scrollbar
      scrollbar $aide.scroll -command "$aide.text yview" -orient vertical
      text $aide.text -width 295 -height 295 -padx 10 -wrap word -yscrollcommand "$aide.scroll set"
      pack $aide.scroll -side right -fill y
      pack $aide.text -fill both
      #--- insert the help text (telshift.txt) in the text area
      if {[string compare $langage "french"] ==0 } {
         if [catch {open [file join $audace(rep_plugin) tool telshift aide_telshift telshift_fr.txt] r} fileId] {
            set over [tk_messageBox -type ok -message "$caption(telshift,erreuraide)"]
            destroy $aide
            return
         } else {
            set content [read $fileId]
            $aide.text insert 1.0 $content
            close $fileId
         }
      } elseif {[string compare $langage "italian"] ==0 } {
         if [catch {open [file join $audace(rep_plugin) tool telshift aide_telshift telshift_it.txt] r} fileId] {
            set over [tk_messageBox -type ok -message "$caption(telshift,erreuraide)"]
            destroy $aide
            return
         } else {
            set content [read $fileId]
            $aide.text insert 1.0 $content
            close $fileId
         }
      } elseif {[string compare $langage "spanish"] ==0 } {
         if [catch {open [file join $audace(rep_plugin) tool telshift aide_telshift telshift_sp.txt] r} fileId] {
            set over [tk_messageBox -type ok -message "$caption(telshift,erreuraide)"]
            destroy $aide
            return
         } else {
            set content [read $fileId]
            $aide.text insert 1.0 $content
            close $fileId
         }
      } elseif {[string compare $langage "german"] ==0 } {
         if [catch {open [file join $audace(rep_plugin) tool telshift aide_telshift telshift_ge.txt] r} fileId] {
            set over [tk_messageBox -type ok -message "$caption(telshift,erreuraide)"]
            destroy $aide
            return
         } else {
            set content [read $fileId]
            $aide.text insert 1.0 $content
            close $fileId
         }
      } elseif {[string compare $langage "danish"] ==0 } {
         if [catch {open [file join $audace(rep_plugin) tool telshift aide_telshift telshift_da.txt] r} fileId] {
            set over [tk_messageBox -type ok -message "$caption(telshift,erreuraide)"]
            destroy $aide
            return
         } else {
            set content [read $fileId]
            $aide.text insert 1.0 $content
            close $fileId
         }
      } else {
         if [catch {open [file join $audace(rep_plugin) tool telshift aide_telshift telshift_en.txt] r} fileId] {
            set over [tk_messageBox -type ok -message "$caption(telshift,erreuraide)"]
            destroy $aide
            return
         } else {
            set content [read $fileId]
            $aide.text insert 1.0 $content
            close $fileId
         }
      }
      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $aide <Key-F1> { ::console::GiveFocus }
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $aide
   }

   #--- launch recupPosition procedure to close the main window
   proc recupPosition { } {
      global base
      global conf

      #--- Je mets la position actuelle de la fenetre dans conf()
      set geom [ winfo geometry [winfo toplevel $base ] ]
      set deb [ expr 1 + [ string first + $geom ] ]
      set fin [ string length $geom ]
      set conf(telshift,position) "+[ string range $geom $deb $fin ]"
   }

   #--- launch Close procedure to close the main window
   proc Close { } {
      global audace
      global panneau
      global base

      set panneau(telshift,stop) "1"
      catch {after cancel bell}
      catch {cam$audace(camNo) stop}
      after 200
      set aide $audace(base).help1
      ::telshift::recupPosition
      if { [winfo exists $aide] } {
         destroy $aide
      }
      destroy $base
   }

   #--- lauch Run procedure
   proc Run { } {
   global choice_proc

      switch -exact -- $choice_proc {
         ima   { Procima }
         super { Procsuper }
         4mosa { Proc4mosa }
         9mosa { Proc9mosa }
      }
   }

   #--- lauch Procima procedure to deal with normal images
   proc Procima { } {
      global audace
      global conf
      global caption
      global color
      global panneau
      global nbr
      global pose
      global choice_binning
      global foc
      global filename
      global base

      $base.btn.ok configure -relief groove -state disabled

      #--- case when the scope is not connected
      if { [::tel::list]!="" } {

         #--- case when the camera is not connected
         if { [::cam::list]!="" } {

            #--- get scope position
            set radec [tel$audace(telNo) radec coord -equinox J2000.0]

            #--- get ra
            set ra0 [lindex $radec 0]

            #--- get dec
            set dec0 [lindex $radec 1]

            #--- convert ra in degrees 0 to 360
            set ra0 [mc_angle2deg $ra0]

            #--- convert dec in degrees -90 to +90
            set dec0 [mc_angle2deg $dec0]

            #--- return list with number of cells
            set naxis [cam$audace(camNo) nbcells]

            #--- get naxis1
            set naxis1 [lindex $naxis 0]

            #--- get naxis2
            set naxis2 [lindex $naxis 1]

            #--- return list with cell dimensions
            set cell [cam$audace(camNo) celldim]

            #--- get pixsize1
            set pixsize1 [lindex $cell 0]

            #--- get pixsize2
            set pixsize2 [lindex $cell 1]

            #--- convert foc into metres + error management (no focal length)
           # set foclen [expr $foc/1000.]
            set num [catch {set foclen [expr $foc/1000.]} msg]

            if { $num=="1"} {
               ErreurFocale
            } else {

               #--- make the target list
               set optic [list OPTIC NAXIS1 $naxis1 NAXIS2 $naxis2 FOCLEN $foclen PIXSIZE1 $pixsize1 PIXSIZE2 $pixsize2 CROTA2 0 RA $ra0 DEC $dec0]
               set method [list RANDOM $nbr]
               set compix 30
               set radecall [mc_listradec $optic $method $compix]

               #--- big loop using $nbr frames
               for {set k 0} {$k<$nbr} {incr k 1} {

                  #--- if the user wants to stop the procedure
                  if {$panneau(telshift,stop)=="1"} {
                     set panneau(telshift,stop) "0"
                     break
                  }

                  set kk [expr 1+$k]
                  #--- get nth list of aiming coordinates
                  set radec [lindex $radecall $k]
                  #--- get ra coodinate in degrees
                  set ra [lindex $radec 0]
                  #--- get dec coordinate in degrees
                  set dec [lindex $radec 1]
                  #--- convert degrees into a list {h m s.s}
                  set rahms [mc_angle2hms $ra 360]
                  #--- get hour, minute and second
                  set rah [lindex $rahms 0]
                  set ram [lindex $rahms 1]
                  set ras [lindex $rahms 2]
                  #--- convert seconds in integer for goto format
                  set ras [expr int($ras)]
                  #--- formatting goto format
                  set ra "${rah}h${ram}m${ras}s"
                  #--- convert degrees into a list {d m s.s}
                  set decdms [mc_angle2dms $dec 90]
                  #--- get degree, minute and second
                  set decd [lindex $decdms 0]
                  set decm [lindex $decdms 1]
                  set decs [lindex $decdms 2]
                  #--- convert seconds in integer for goto format
                  set decs [expr int($decs)]
                  #--- formatting goto format
                  set dec "${decd}d${decm}m${decs}s"
                  #--- aiming scope to new field
                  ::console::affiche_resultat "$caption(telshift,pointevers) $ra $dec\n"
                  if {$k>0} {
                     #--- only if we are not on the first field
                     set catchError [ catch {
                        ::telescope::goto [list $ra $dec] 1
                     } ]
                     if { $catchError != 0 } {
                        ::tkutil::displayErrorInfoTelescope "GOTO Error"
                        return
                     }
                  }
                  #--- shoot an image
                  ::console::affiche_resultat "$caption(telshift,lancepose) $kk\n\n"

                  #--- exposure time
                  set exptime $pose

                  #--- binning factor
                  set bin $choice_binning

                  #--- call to acquisition function
                  acq $exptime $bin $k $nbr

                  #--- design of invoking panel
                  $base.para.labURL_status_cam configure -text "$caption(telshift,status)" -fg $color(blue)
                  update

                  #--- save image
                  saveima "$filename$kk"
               }

               if { [winfo exists $base] } {
                  $base.btn.ok configure -relief raised -state normal
                  ::console::affiche_resultat "$caption(telshift,termine)\n\n"
                  set over [tk_messageBox -type ok -message "$caption(telshift,termine)"]
               } else {
                  ::console::affiche_resultat "$caption(telshift,anticipee)\n\n"
                  set over [tk_messageBox -type ok -message "$caption(telshift,anticipee)"]
               }

            }

         } else {
            ::confCam::run
            $base.btn.ok configure -relief raised -state normal
         }

      } else {
         ::confTel::run
         $base.btn.ok configure -relief raised -state normal
      }

   }

   #--- lauch Procsuper procedure to deal with flat field images
   proc Procsuper { } {
      global audace
      global conf
      global caption
      global color
      global panneau
      global nbr
      global pose
      global choice_binning
      global foc
      global filename
      global base

      $base.btn.ok configure -relief groove -state disabled

      #--- case when the scope is not connected
      if { [::tel::list]!="" } {

         #--- case when the camera is not connected
         if { [::cam::list]!="" } {

            #--- get scope position
            set radec [tel$audace(telNo) radec coord -equinox J2000.0]

            #--- get ra
            set ra0 [lindex $radec 0]

            #--- get dec
            set dec0 [lindex $radec 1]

            #--- convert ra in degrees 0 to 360
            set ra0 [mc_angle2deg $ra0]

            #--- convert dec in degrees -90 to +90
            set dec0 [mc_angle2deg $dec0]

            #--- return list with number of cells
            set naxis [cam$audace(camNo) nbcells]

            #--- get naxis1
            set naxis1 [lindex $naxis 0]

            #--- get naxis2
            set naxis2 [lindex $naxis 1]

            #--- return list with cell dimensions
            set cell [cam$audace(camNo) celldim]

            #--- get pixsize1
            set pixsize1 [lindex $cell 0]

            #--- get pixsize2
            set pixsize2 [lindex $cell 1]

            #--- convert foc into metres + error management (no focal length)
           # set foclen [expr $foc/1000.]
            set num [catch {set foclen [expr $foc/1000.]} msg]

            if { $num=="1"} {
               ErreurFocale
            } else {

               #--- make the target list
               set optic [list OPTIC NAXIS1 $naxis1 NAXIS2 $naxis2 FOCLEN $foclen PIXSIZE1 $pixsize1 PIXSIZE2 $pixsize2 CROTA2 0 RA $ra0 DEC $dec0]
               set method [list RANDOM $nbr]
               set compix 3000
               set radecall [mc_listradec $optic $method $compix]

               #--- big loop using $nbr frames
               for {set k 0} {$k<$nbr} {incr k 1} {

                  #--- if the user wants to stop the procedure
                  if {$panneau(telshift,stop)=="1"} {
                     set panneau(telshift,stop) "0"
                     break
                  }

                  set kk [expr 1+$k]
                  #--- get nth list of aiming coordinates
                  set radec [lindex $radecall $k]
                  #--- get ra coodinate in degrees
                  set ra [lindex $radec 0]
                  #--- get dec coordinate in degrees
                  set dec [lindex $radec 1]
                  #--- convert degrees into a list {h m s.s}
                  set rahms [mc_angle2hms $ra 360]
                  #--- get hour, minute and second
                  set rah [lindex $rahms 0]
                  set ram [lindex $rahms 1]
                  set ras [lindex $rahms 2]
                  #--- convert seconds in integer for goto format
                  set ras [expr int($ras)]
                  #--- formatting goto format
                  set ra "${rah}h${ram}m${ras}s"
                  set decdms [mc_angle2dms $dec 90]
                  set decd [lindex $decdms 0]
                  set decm [lindex $decdms 1]
                  set decs [lindex $decdms 2]
                  set decs [expr int($decs)]
                  set dec "${decd}d${decm}m${decs}s"
                  #--- aiming scope to new field
                  ::console::affiche_resultat "$caption(telshift,pointevers) $ra $dec\n"
                  if {$k>0} {
                     #--- only if we are not on the first field
                     set catchError [ catch {
                        ::telescope::goto [list $ra $dec] 1
                     } ]
                     if { $catchError != 0 } {
                        ::tkutil::displayErrorInfoTelescope "GOTO Error"
                        return
                     }
                  }
                  #--- shoot an image
                  ::console::affiche_resultat "$caption(telshift,lancepose) $kk\n\n"
                 # acq $pose $choice_binning

                  #--- exposure time
                  set exptime $pose

                  #--- binning factor
                  set bin $choice_binning

                  #--- call to acquisition function
                  acq $exptime $bin $k $nbr

                  #--- design of invoking panel
                  $base.para.labURL_status_cam configure -text "$caption(telshift,status)" -fg $color(blue)
                  update

                  #--- save image
                  saveima "$filename$kk"
               }

               if { [winfo exists $base] } {
                  $base.btn.ok configure -relief raised -state normal
                  ::console::affiche_resultat "$caption(telshift,termine)\n\n"
                  set over [tk_messageBox -type ok -message "$caption(telshift,termine)"]
               } else {
                  ::console::affiche_resultat "$caption(telshift,anticipee)\n\n"
                  set over [tk_messageBox -type ok -message "$caption(telshift,anticipee)"]
               }

            }

         } else {
            ::confCam::run
            $base.btn.ok configure -relief raised -state normal
         }

      } else {
         ::confTel::run
         $base.btn.ok configure -relief raised -state normal
      }

   }

   #--- variable for saving the images in the following procedure
   global i
   set i 1

   #--- lauch Proc4mosa procedure to deal with mosaic of 4 images
   proc Proc4mosa { } {
      global audace
      global conf
      global caption
      global color
      global panneau
      global pose
      global choice_binning
      global foc
      global filename
      global nbr
      global i
      global base

      $base.btn.ok configure -relief groove -state disabled

      #--- case when the scope is not connected
      if { [::tel::list]!="" } {

         #--- case when the camera is not connected
         if { [::cam::list]!="" } {

            #--- get scope position
            set radec [tel$audace(telNo) radec coord -equinox J2000.0]

            #--- get ra
            set ra0 [lindex $radec 0]

            #--- get dec
            set dec0 [lindex $radec 1]

            #--- convert ra in degrees 0 to 360
            set ra0 [mc_angle2deg $ra0]

            #--- convert dec in degrees -90 to +90
            set dec0 [mc_angle2deg $dec0]

            #--- return list with number of cells
            set naxis [cam$audace(camNo) nbcells]

            #--- get naxis1
            set naxis1 [lindex $naxis 0]

            #--- get naxis2
            set naxis2 [lindex $naxis 1]

            #--- return list with cell dimensions
            set cell [cam$audace(camNo) celldim]

            #--- get pixsize1
            set pixsize1 [lindex $cell 0]

            #--- get pixsize2
            set pixsize2 [lindex $cell 1]

            #--- convert foc into metres + error management (no focal length)
            #set foclen [expr $foc/1000.]
            set num [catch {set foclen [expr $foc/1000.]} msg]

            if { $num=="1"} {
               ErreurFocale
            } else {

               #--- parameters for the target list
               set optic [list OPTIC NAXIS1 $naxis1 NAXIS2 $naxis2 FOCLEN $foclen PIXSIZE1 $pixsize1 PIXSIZE2 $pixsize2 CROTA2 0 RA $ra0 DEC $dec0]
               set method [list ROLL 4]
               set compix 30

               #--- shift the origine because the center of the first image is not the center coordinates of the mosaic.
               set shiftx [expr $compix*0.5]
               set shifty [expr $compix*0.5]
               set radec0 [mc_xy2radec $shiftx $shifty $optic]
               set ra0 [lindex $radec0 0]
               set dec0 [lindex $radec0 1]
               set ra0 [mc_angle2deg $ra0]
               set dec0 [mc_angle2deg $dec0]
               set optic [list OPTIC NAXIS1 $naxis1 NAXIS2 $naxis2 FOCLEN $foclen PIXSIZE1 $pixsize1 PIXSIZE2 $pixsize2 CROTA2 0 RA $ra0 DEC $dec0]

               #--- make the target list
               set radecall [mc_listradec $optic $method $compix]

               #--- big loop using $mo4_nbr frames
               set mosa 4
               set mo4_nbr [expr {$nbr * 4}]
               set kkk 0
               for {set k 0} {$k<$mosa} {incr k 1} {

                  #--- if the user wants to stop the procedure
                  if {$panneau(telshift,stop)=="1"} {
                     set panneau(telshift,stop) "0"
                     break
                  }

                  set kk [expr 1+$k]
                  #--- get nth list of aiming coordinates
                  set radec [lindex $radecall $kkk]
                  incr kkk 1
                  set kkkk $kkk

                  #--- get ra coodinate in degrees
                  set ra [lindex $radec 0]
                  #--- get dec coordinate in degrees
                  set dec [lindex $radec 1]
                  #--- convert degrees into a list {h m s.s}
                  set rahms [mc_angle2hms $ra 360]
                  #--- get hour, minute and second
                  set rah [lindex $rahms 0]
                  set ram [lindex $rahms 1]
                  set ras [lindex $rahms 2]
                  #--- convert seconds in integer for goto format
                  set ras [expr int($ras)]
                  #--- formatting goto format
                  set ra "${rah}h${ram}m${ras}s"
                  set decdms [mc_angle2dms $dec 90]
                  set decd [lindex $decdms 0]
                  set decm [lindex $decdms 1]
                  set decs [lindex $decdms 2]
                  set decs [expr int($decs)]
                  set dec "${decd}d${decm}m${decs}s"
                  #--- aiming scope to new field
                  ::console::affiche_resultat "$caption(telshift,pointevers) $ra $dec\n"
                  set catchError [ catch {
                     ::telescope::goto [list $ra $dec] 1
                  } ]
                  if { $catchError != 0 } {
                     ::tkutil::displayErrorInfoTelescope "GOTO Error"
                     return
                  }
                  ::console::affiche_resultat "$caption(telshift,pointesur) $ra $dec\n"

                  for {set s 0} {$s<$nbr} {incr s 1} {

                     #--- shoot an image
                     ::console::affiche_resultat "$caption(telshift,lancepose) $kk\n\n"
                    # acq $pose $choice_binning

                     #--- exposure time
                     set exptime $pose

                     #--- binning factor
                     set bin $choice_binning

                     #--- call to acquisition function
                     acqmosa $exptime $bin $kkkk $s $mosa

                     #--- design of invoking panel
                     $base.para.labURL_status_cam configure -text "$caption(telshift,status)" -fg $color(blue)
                     update

                     #--- save image
                     set loop [expr {$k + 1}]
                     set image [expr {$s + 1}]
                     saveima "$filename-$loop-$image"

                  }
               }

               if { [winfo exists $base] } {
                  $base.btn.ok configure -relief raised -state normal
                  ::console::affiche_resultat "$caption(telshift,termine)\n\n"
                  set over [tk_messageBox -type ok -message "$caption(telshift,termine)"]
               } else {
                  ::console::affiche_resultat "$caption(telshift,anticipee)\n\n"
                  set over [tk_messageBox -type ok -message "$caption(telshift,anticipee)"]
               }

            }

         } else {
            ::confCam::run
            $base.btn.ok configure -relief raised -state normal
         }

      } else {
         ::confTel::run
         $base.btn.ok configure -relief raised -state normal
      }

   }

   #--- lauch Proc9mosa procedure to deal with mosaic of 9 images
   proc Proc9mosa { } {
      global audace
      global conf
      global caption
      global color
      global panneau
      global pose
      global choice_binning
      global foc
      global filename
      global nbr
      global i
      global base

      set i 1

      $base.btn.ok configure -relief groove -state disabled

      #--- case when the scope is not connected
      if { [::tel::list]!="" } {

         #--- case when the camera is not connected
         if { [::cam::list]!="" } {

            #--- get scope position
            set radec [tel$audace(telNo) radec coord -equinox J2000.0]

            #--- get ra
            set ra0 [lindex $radec 0]

            #--- get dec
            set dec0 [lindex $radec 1]

            #--- convert ra in degrees 0 to 360
            set ra0 [mc_angle2deg $ra0]

            #--- convert dec in degrees -90 to +90
            set dec0 [mc_angle2deg $dec0]

            #--- return list with number of cells
            set naxis [cam$audace(camNo) nbcells]

            #--- get naxis1
            set naxis1 [lindex $naxis 0]

            #--- get naxis2
            set naxis2 [lindex $naxis 1]

            #--- return list with cell dimensions
            set cell [cam$audace(camNo) celldim]

            #--- get pixsize1
            set pixsize1 [lindex $cell 0]

            #--- get pixsize2
            set pixsize2 [lindex $cell 1]

            #--- convert foc into metres + error management (no focal length)
            #set foclen [expr $foc/1000.]
            set num [catch {set foclen [expr $foc/1000.]} msg]

            if { $num=="1"} {
               ErreurFocale
            } else {

               #--- make the target list
               set optic [list OPTIC NAXIS1 $naxis1 NAXIS2 $naxis2 FOCLEN $foclen PIXSIZE1 $pixsize1 PIXSIZE2 $pixsize2 CROTA2 0 RA $ra0 DEC $dec0]
               set method [list ROLL 9]
               set compix 30
               set radecall [mc_listradec $optic $method $compix]

               #--- big loop using $mo9_nbr frames
               set mosa 9
               set mo9_nbr [expr {$nbr * 9}]
               set kkk 0
               for {set k 0} {$k<$mosa} {incr k 1} {

                  #--- if the user wants to stop the procedure
                  if {$panneau(telshift,stop)=="1"} {
                     set panneau(telshift,stop) "0"
                     break
                  }

                  set kk [expr 1+$k]

                  #--- get nth list of aiming coordinates
                  set radec [lindex $radecall $kkk]
                  incr kkk 1
                  set kkkk $kkk

                  #--- get ra coodinate in degrees
                  set ra [lindex $radec 0]
                  #--- get dec coordinate in degrees
                  set dec [lindex $radec 1]
                  #--- convert degrees into a list {h m s.s}
                  set rahms [mc_angle2hms $ra 360]
                  #--- get hour, minute and second
                  set rah [lindex $rahms 0]
                  set ram [lindex $rahms 1]
                  set ras [lindex $rahms 2]
                  #--- convert seconds in integer for goto format
                  set ras [expr int($ras)]
                  #--- formatting goto format
                  set ra "${rah}h${ram}m${ras}s"
                  set decdms [mc_angle2dms $dec 90]
                  set decd [lindex $decdms 0]
                  set decm [lindex $decdms 1]
                  set decs [lindex $decdms 2]
                  set decs [expr int($decs)]
                  set dec "${decd}d${decm}m${decs}s"
                  #--- aiming scope to new field
                  ::console::affiche_resultat "$caption(telshift,pointevers) $ra $dec\n"
                  if {$k>0} {
                     #--- only if we are not on the first field
                     set catchError [ catch {
                        ::telescope::goto [list $ra $dec] 1
                     } ]
                     if { $catchError != 0 } {
                        ::tkutil::displayErrorInfoTelescope "GOTO Error"
                        return
                     }
                     ::console::affiche_resultat "$caption(telshift,pointesur) $ra $dec\n"
                  }

                  for {set s 0} {$s<$nbr} {incr s 1} {

                     #--- shoot an image
                     ::console::affiche_resultat "$caption(telshift,lancepose) $kk\n\n"
                    # acq $pose $choice_binning

                     #--- exposure time
                     set exptime $pose

                     #--- binning factor
                     set bin $choice_binning

                     #--- call to acquisition function
                     acqmosa $exptime $bin $kkkk $s $mosa

                     #--- design of invoking panel
                     $base.para.labURL_status_cam configure -text "$caption(telshift,status)" -fg $color(blue)
                     update

                     #--- save image
                     set loop [expr {$k + 1}]
                     set image [expr {$s + 1}]
                     saveima "$filename-$loop-$image"

                  }

               }

               if { [winfo exists $base] } {
                  $base.btn.ok configure -relief raised -state normal
                  ::console::affiche_resultat "$caption(telshift,termine)\n\n"
                  set over [tk_messageBox -type ok -message "$caption(telshift,termine)"]
               } else {
                  ::console::affiche_resultat "$caption(telshift,anticipee)\n\n"
                  set over [tk_messageBox -type ok -message "$caption(telshift,anticipee)"]
               }

            }

         } else {
            ::confCam::run
            $base.btn.ok configure -relief raised -state normal
         }

      } else {
         ::confTel::run
         $base.btn.ok configure -relief raised -state normal
      }

   }

   #--- avoids getting the Tcl/Tk error message if there is no focal value in mm
   proc ErreurFocale { } {
      global audace
      global caption
      global base

      if [winfo exists $audace(base).erreurfocale] {
         destroy $audace(base).erreurfocale
      }
      toplevel $audace(base).erreurfocale
      wm transient $audace(base).erreurfocale $base
      wm resizable $audace(base).erreurfocale 0 0
      wm title $audace(base).erreurfocale "$caption(telshift,attention)"
      set posx_erreurfocale [ lindex [ split [ wm geometry $base ] "+" ] 1 ]
      set posy_erreurfocale [ lindex [ split [ wm geometry $base ] "+" ] 2 ]
      wm geometry $audace(base).erreurfocale +[ expr $posx_erreurfocale + 270 ]+[ expr $posy_erreurfocale + 50 ]
      wm protocol $audace(base).erreurfocale WM_DELETE_WINDOW {
         $base.btn.ok configure -relief raised -state normal
         after 400
         destroy $audace(base).erreurfocale
      }

      #--- create the message display
      label $audace(base).erreurfocale.lab1 -text "$caption(telshift,erreurfocale1)"
      pack $audace(base).erreurfocale.lab1 -padx 10 -pady 2
      label $audace(base).erreurfocale.lab2 -text "$caption(telshift,erreurfocale2)"
      pack $audace(base).erreurfocale.lab2 -padx 10 -pady 2
      label $audace(base).erreurfocale.lab3 -text "$caption(telshift,erreurfocale3)"
      pack $audace(base).erreurfocale.lab3 -padx 10 -pady 2

      #--- the new window is on
      focus $audace(base).erreurfocale

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).erreurfocale
   }

   proc acq { exptime binning { k "" } { nbr "" } } {
      global audace
      global base
      global conf
      global caption
      global color

      #--- shortcuts
      set camera cam$audace(camNo)
      set buffer buf$audace(bufNo)

      #--- the exptime control is used to determine the exposure time for the image
      $camera exptime $exptime

      #--- the bin control is used to determine the binning data
      $camera bin [list $binning $binning]

      #---
      if {$exptime>1} {
      } else {
         $base.para.labURL_status_cam configure -text "$caption(telshift,numerisation)" -fg $color(red)
         update
      }

      #--- beginning of acquisition
      $camera acq

      #--- Alarme sonore de fin de pose
      ::camera::alarmeSonore $exptime

      #--- call to timer
      if {$exptime>1} {
         dispTime $k $nbr
      }

      #--- waiting for exposure end
      vwait status_$camera

      #--- image viewing
      ::audace::autovisu $audace(visuNo)
   }

   proc dispTime { { k "" } { nbr "" } } {
      global audace
      global base
      global caption
      global color

      set t "[cam$audace(camNo) timer -1]"
      if {$t>1} {
         $base.para.labURL_status_cam configure -text "[expr $t-1]/[format "%d" [expr int([cam$audace(camNo) exptime])]] ([expr $k+1]:$nbr)" -fg $color(red)
         update
         after 1000 dispTime $k $nbr
      } else {
         $base.para.labURL_status_cam configure -text "$caption(telshift,numerisation)" -fg $color(red)
         update
      }
   }

   proc acqmosa { exptime binning { kkkk "" } { s "" } { mosa "" } } {
      global audace
      global base
      global conf
      global caption
      global color

      #--- shortcuts
      set camera cam$audace(camNo)
      set buffer buf$audace(bufNo)

      #--- the exptime control is used to determine the exposure time for the image
      $camera exptime $exptime

      #--- the bin control is used to determine the binning data
      $camera bin [list $binning $binning]

      #---
      if {$exptime>1} {
      } else {
         $base.para.labURL_status_cam configure -text "$caption(telshift,numerisation)" -fg $color(red)
         update
      }

      #--- beginning of acquisition
      $camera acq

      #--- Alarme sonore de fin de pose
      ::camera::alarmeSonore $exptime

      #--- call to timer
      if {$exptime>1} {
         dispTimemosa $kkkk $s $mosa
      }

      #--- waiting for exposure end
      vwait status_$camera

      #--- image viewing
      ::audace::autovisu $audace(visuNo)
   }

   proc dispTimemosa { { kkkk "" } { s "" } { mosa "" } } {
      global audace
      global base
      global caption
      global color

      set t "[cam$audace(camNo) timer -1]"
      if {$t>1} {
         $base.para.labURL_status_cam configure -text "[expr $t-1]/[format "%d" [expr int([cam$audace(camNo) exptime])]] ([expr $s+1]-[expr $kkkk]:$mosa)" -fg $color(red)
         update
         after 1000 dispTimemosa $kkkk $s $mosa
      } else {
         $base.para.labURL_status_cam configure -text "$caption(telshift,numerisation)" -fg $color(red)
         update
      }
   }

}

