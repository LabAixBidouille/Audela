#
# Fichier : astrometry.tcl
# Description : Functions to calibrate astrometry on images
# Auteur : Alain KLOTZ
# Mise a jour $Id: astrometry.tcl,v 1.8 2006-08-25 21:56:06 alainklotz Exp $
#

namespace eval ::astrometry {
   variable astrom

   proc confToWidget {  } {
      variable astrom
      global caption conf

      set astrom(list_combobox) [ list $caption(astrometry,cat,usno) $caption(astrometry,cat,microcat) \
         $caption(astrometry,cat,personal) ]

      if { $::tcl_platform(os) == "Linux" } {
         if { ! [ info exists conf(astrometry,catfolder) ] } { set conf(astrometry,catfolder) "/cdrom/" }
      } else {
         if { ! [ info exists conf(astrometry,catfolder) ] } { set conf(astrometry,catfolder) "d:/" }
      }
      if { ! [ info exists conf(astrometry,cattype) ] }      { set conf(astrometry,cattype)   "0" }
      if { ! [ info exists conf(astrometry,position) ] }     { set conf(astrometry,position)  "+150+100" }

      set astrom(catfolder) "$conf(astrometry,catfolder)"
      set astrom(cattype)   [ lindex "$astrom(list_combobox)" $conf(astrometry,cattype) ]
      set astrom(position)  "$conf(astrometry,position)"
   }

   proc widgetToConf {  } {
      variable astrom
      global caption conf

      set conf(astrometry,catfolder) "$::astrometry::catvalues(catfolder)"
      set conf(astrometry,cattype)   [ lsearch "$astrom(list_combobox)" "$::astrometry::catvalues(cattype)" ]
      set conf(astrometry,position)  "$astrom(position)"
   }

   proc recup_position { } {
      variable astrom

      set astrom(geometry) [ wm geometry $astrom(This) ]
      set deb [ expr 1 + [ string first + $astrom(geometry) ] ]
      set fin [ string length $astrom(geometry) ]
      set astrom(position) "+[ string range $astrom(geometry) $deb $fin ]"
      #---
      ::astrometry::widgetToConf
   }

   proc create { } {
      variable astrom
      global audace
      global caption

      #---
      if { [ buf$audace(bufNo) imageready ] == "0" } {
         tk_messageBox -message "$caption(astrometry,error_no_image)" -title "$caption(astrometry,title)" -icon error
         return
      }

      #---
      set astrom(This)     "$audace(base).astrometry"
      set astrom(typewcs)  {optic classic matrix}
      set astrom(typecal)  {catalog file manual delwcs}
      set astrom(kwds)     {RA                       DEC                       CRPIX1        CRPIX2        CRVAL1          CRVAL2           CDELT1    CDELT2    CROTA2                    CD1_1         CD1_2         CD2_1         CD2_2         FOCLEN         PIXSIZE1       PIXSIZE2}
      set astrom(units)    {deg                      deg                       pixel         pixel         deg             deg              deg/pixel deg/pixel deg                       deg/pixel     deg/pixel     deg/pixel     deg/pixel     m              um             um}
      set astrom(types)    {double                   double                    double        double        double          double           double    double    double                    double        double        double        double        double         double         double}
      set astrom(values)   {""                       ""                        ""            ""            ""              ""               ""        ""        0.                        ""            ""            ""            ""            1.             18.            18.}
      set astrom(comments) {"RA expected for CRPIX1" "DEC expected for CRPIX2" "X ref pixel" "Y ref pixel" "RA for CRPIX1" "DEC for CRPIX2" "X scale" "Y scale" "Position angle of North" "Matrix CD11" "Matrix CD12" "Matrix CD21" "Matrix CD22" "Focal length" "X pixel size" "Y pixel size"}
      #---
      ::astrometry::confToWidget
      #---
     ### if {[buf$audace(bufNo) pointer]==0} {
     ###    return
     ### }
      if { [info commands $astrom(This)]=="$astrom(This)" } {
         wm deiconify $astrom(This)
         return
      }
      toplevel $astrom(This)
      wm geometry $astrom(This) $astrom(position)
      wm maxsize $astrom(This) [winfo screenwidth .] [winfo screenheight .]
      wm minsize $astrom(This) 500 400
      wm resizable $astrom(This) 1 1
      wm deiconify $astrom(This)
      wm title $astrom(This) "$caption(astrometry,title)"
      wm protocol $astrom(This) WM_DELETE_WINDOW ::astrometry::quit
      bind $astrom(This) <Destroy> ::astrometry::quit
      #---
      label $astrom(This).lab1 -text "$caption(astrometry,title)"
      pack $astrom(This).lab1 -in $astrom(This) -anchor center -fill x -pady 1 -ipadx 15 -padx 5
      #--- Button for choosing the WCS type displayed
      button $astrom(This).but1 -text "$caption(astrometry,wcs,[lindex $astrom(typewcs) 0])" \
         -command {::astrometry::wcs_pack +}
      pack $astrom(This).but1 -in $astrom(This) -anchor center -fill x -pady 10 -ipadx 15 -padx 5 -ipady 5
      #--- Frames from the differents tpye of WCS
      frame $astrom(This).wcs
      pack $astrom(This).wcs -in $astrom(This) -anchor center -fill x
      foreach wcs $astrom(typewcs) {
         frame $astrom(This).wcs.${wcs}
      }
      #--- Read the values of header keywords
      ::astrometry::updatewcs
      #--- Update the keywords that are voids
      set dimx [lindex [buf$audace(bufNo) getkwd NAXIS1 ] 1]
      set dimy [lindex [buf$audace(bufNo) getkwd NAXIS2 ] 1]
      if {$::astrometry::astrom(wcsvalues,CRPIX1)==""} {
         set ::astrometry::astrom(wcsvalues,CRPIX1) [expr $dimx /2.]
      }
      if {$::astrometry::astrom(wcsvalues,CRPIX2)==""} {
         set ::astrometry::astrom(wcsvalues,CRPIX2) [expr $dimy /2.]
      }
      #---
      if {($::astrometry::astrom(wcsvalues,CRVAL1)=="")&&($::astrometry::astrom(wcsvalues,RA)=="")} {
         set ::astrometry::astrom(wcsvalues,RA) 0.
      }
      if {($::astrometry::astrom(wcsvalues,CRVAL1)=="")&&($::astrometry::astrom(wcsvalues,RA)!="")} {
         set ::astrometry::astrom(wcsvalues,CRVAL1) $::astrometry::astrom(wcsvalues,RA)
      } elseif {($::astrometry::astrom(wcsvalues,CRVAL1)!="")&&($::astrometry::astrom(wcsvalues,RA)=="")} {
         set ::astrometry::astrom(wcsvalues,RA) $::astrometry::astrom(wcsvalues,CRVAL1)
      }
      if {($::astrometry::astrom(wcsvalues,CRVAL2)=="")&&($::astrometry::astrom(wcsvalues,DEC)=="")} {
         set ::astrometry::astrom(wcsvalues,DEC) 0.
      }
      if {($::astrometry::astrom(wcsvalues,CRVAL2)=="")&&($::astrometry::astrom(wcsvalues,DEC)!="")} {
         set ::astrometry::astrom(wcsvalues,CRVAL2) $::astrometry::astrom(wcsvalues,DEC)
      } elseif {($::astrometry::astrom(wcsvalues,CRVAL2)!="")&&($::astrometry::astrom(wcsvalues,DEC)=="")} {
         set ::astrometry::astrom(wcsvalues,DEC) $::astrometry::astrom(wcsvalues,CRVAL2)
      }
      #---
      set valid_optic 2
      set valid_matrix 2
      set valid_classic 2
      #---
      if { $::astrometry::astrom(wcsvalues,RA) != "" }       { incr valid_optic }
      if { $::astrometry::astrom(wcsvalues,DEC) != "" }      { incr valid_optic }
      if { $::astrometry::astrom(wcsvalues,CRVAL1) != "" }   { incr valid_matrix ; incr valid_classic ; incr valid_optic }
      if { $::astrometry::astrom(wcsvalues,CRVAL2) != "" }   { incr valid_matrix ; incr valid_classic ; incr valid_optic }
      if { $::astrometry::astrom(wcsvalues,CDELT1) != "" }   { incr valid_classic ; incr valid_optic }
      if { $::astrometry::astrom(wcsvalues,CDELT2) != "" }   { incr valid_classic ; incr valid_optic }
      if { $::astrometry::astrom(wcsvalues,CROTA2) != "" }   { incr valid_optic ; incr valid_classic }
      if { $::astrometry::astrom(wcsvalues,PIXSIZE1) != "" } { incr valid_optic }
      if { $::astrometry::astrom(wcsvalues,PIXSIZE2) != "" } { incr valid_optic }
      if { $::astrometry::astrom(wcsvalues,FOCLEN) != "" }   { incr valid_optic }
      if { $::astrometry::astrom(wcsvalues,CD1_1) != "" }    { incr valid_matrix }
      if { $::astrometry::astrom(wcsvalues,CD2_1) != "" }    { incr valid_matrix }
      if { $::astrometry::astrom(wcsvalues,CD1_2) != "" }    { incr valid_matrix }
      if { $::astrometry::astrom(wcsvalues,CD2_2) != "" }    { incr valid_matrix }
      #---
      set ufoclen 1.
      set upixsize1 1.
      set upixsize2 1.
      if {($valid_optic>=8)} {
         if {$::astrometry::astrom(wcsunits,FOCLEN)=="um"} {
            set ufoclen 1e-6
         }
         if {$::astrometry::astrom(wcsunits,FOCLEN)=="mm"} {
            set ufoclen 1e-3
         }
         if {$::astrometry::astrom(wcsunits,FOCLEN)=="m"} {
            set ufoclen 1.
         }
         if {$::astrometry::astrom(wcsunits,PIXSIZE1)=="um"} {
            set upixsize1 1e-6
         }
         if {$::astrometry::astrom(wcsunits,PIXSIZE1)=="mm"} {
            set upixsize1 1e-3
         }
         if {$::astrometry::astrom(wcsunits,PIXSIZE1)=="m"} {
            set upixsize1 1.
         }
         if {$::astrometry::astrom(wcsunits,PIXSIZE2)=="um"} {
            set upixsize2 1e-6
         }
         if {$::astrometry::astrom(wcsunits,PIXSIZE2)=="mm"} {
            set upixsize2 1e-3
         }
         if {$::astrometry::astrom(wcsunits,PIXSIZE2)=="m"} {
            set upixsize2 1.
         }
      }
      #::console::affiche_resultat "valid_classic=$valid_classic valid_optic=$valid_optic valid_matrix=$valid_matrix\n"
      if {($valid_optic>=8)&&($valid_classic<7)} {
         set ::astrometry::astrom(wcsvalues,CDELT1) [expr -2*atan($::astrometry::astrom(wcsvalues,PIXSIZE1)*$upixsize1/2./$::astrometry::astrom(wcsvalues,FOCLEN)/$ufoclen)];
         set ::astrometry::astrom(wcsvalues,CDELT2) [expr  2*atan($::astrometry::astrom(wcsvalues,PIXSIZE2)*$upixsize2/2./$::astrometry::astrom(wcsvalues,FOCLEN)/$ufoclen)];
      }
      #if {(valid_matrix>=8)} {}
      if {($valid_optic>=8)&&($valid_classic<7)} {
         set pi [expr 4*atan(1.)]
         set cosr [expr cos($::astrometry::astrom(wcsvalues,CROTA2)*$pi/180.)]
         set sinr [expr sin($::astrometry::astrom(wcsvalues,CROTA2)*$pi/180.)]
         set ::astrometry::astrom(wcsvalues,CD1_1) [expr $::astrometry::astrom(wcsvalues,CDELT1)*$cosr ]
         set ::astrometry::astrom(wcsvalues,CD1_2) [expr  abs($::astrometry::astrom(wcsvalues,CDELT2))*$::astrometry::astrom(wcsvalues,CDELT1)/abs($::astrometry::astrom(wcsvalues,CDELT1))*$sinr ]
         set ::astrometry::astrom(wcsvalues,CD2_1) [expr -abs($::astrometry::astrom(wcsvalues,CDELT1))*$::astrometry::astrom(wcsvalues,CDELT2)/abs($::astrometry::astrom(wcsvalues,CDELT2))*$sinr ]
         set ::astrometry::astrom(wcsvalues,CD2_2) [expr $::astrometry::astrom(wcsvalues,CDELT2)*$cosr ]
      }
      #--- Display the values of header keywords
      ::astrometry::keyword optic RA
      ::astrometry::keyword optic DEC
      ::astrometry::keyword optic FOCLEN
      ::astrometry::keyword optic PIXSIZE1
      ::astrometry::keyword optic PIXSIZE2
      ::astrometry::keyword optic CROTA2
      ::astrometry::keyword optic CRPIX1
      ::astrometry::keyword optic CRPIX2
      #---
      ::astrometry::keyword classic CRVAL1
      ::astrometry::keyword classic CRVAL2
      ::astrometry::keyword classic CDELT1
      ::astrometry::keyword classic CDELT2
      ::astrometry::keyword classic CROTA2
      ::astrometry::keyword classic CRPIX1
      ::astrometry::keyword classic CRPIX2
      #---
      ::astrometry::keyword matrix CRVAL1
      ::astrometry::keyword matrix CRVAL2
      ::astrometry::keyword matrix CD1_1
      ::astrometry::keyword matrix CD1_2
      ::astrometry::keyword matrix CD2_1
      ::astrometry::keyword matrix CD2_2
      ::astrometry::keyword matrix CRPIX1
      ::astrometry::keyword matrix CRPIX2
      #--- Button for choosing the Method for calibration
      button $astrom(This).but2 -text "$caption(astrometry,cal,[lindex $astrom(typecal) 0])" \
         -command {::astrometry::cal_pack +}
      pack $astrom(This).but2 -in $astrom(This) -anchor center -fill x -pady 10 -ipadx 15 -padx 5 -ipady 5
      #--- Frames from the differents tpye of methods of calibration
      frame $astrom(This).cal
      pack $astrom(This).cal -in $astrom(This) -anchor center -fill x
      foreach cal $astrom(typecal) {
         frame $astrom(This).cal.${cal}
      }
      #--- Calibration from a catalog
      set ::astrometry::catvalues(cattype)   $astrom(cattype)
      set ::astrometry::catvalues(catfolder) $astrom(catfolder)
      set len [ string length $::astrometry::catvalues(catfolder) ]
      set folder "$::astrometry::catvalues(catfolder)"
      if { $len > "0" } {
         set car [ string index "$::astrometry::catvalues(catfolder)" [ expr $len-1 ] ]
         if { $car != "/" } {
            append folder "/"
         }
         set ::astrometry::catvalues(catfolder) $folder
      }
      set cal catalog
      frame $astrom(This).cal.${cal}.fra_0
         label $astrom(This).cal.${cal}.fra_0.lab -text "$caption(astrometry,cal,catname)"
         pack $astrom(This).cal.${cal}.fra_0.lab -side left
         set list_combobox $astrom(list_combobox)
         ComboBox $astrom(This).cal.${cal}.fra_0.cat \
            -width 15         \
            -height [llength $list_combobox ]  \
            -relief sunken    \
            -borderwidth 1    \
            -editable 0       \
            -textvariable ::astrometry::catvalues(cattype) \
            -values $list_combobox
         pack $astrom(This).cal.${cal}.fra_0.cat -side left
      pack $astrom(This).cal.${cal}.fra_0 -anchor center -fill x
      frame $astrom(This).cal.${cal}.fra_1
         button $astrom(This).cal.${cal}.fra_1.but -text ... \
            -command {
               set d [::astrometry::getdirname]
               if {$d!=""} {set ::astrometry::catvalues(catfolder) $d ; update ; focus $::astrometry::astrom(This) }
            }
         pack $astrom(This).cal.${cal}.fra_1.but -side left -padx 2 -ipady 5
         label $astrom(This).cal.${cal}.fra_1.lab -text "$caption(astrometry,cal,catfolder)"
         pack $astrom(This).cal.${cal}.fra_1.lab -side left
         entry $astrom(This).cal.${cal}.fra_1.ent -textvariable ::astrometry::catvalues(catfolder) -width 40
         pack $astrom(This).cal.${cal}.fra_1.ent -side left
      pack $astrom(This).cal.${cal}.fra_1 -anchor center -fill x
      #--- Calibration from a file
      set cal file
      frame $astrom(This).cal.${cal}.fra_1
         button $astrom(This).cal.${cal}.fra_1.but -text ... \
            -command {
               set d [ ::tkutil::box_load $::astrometry::astrom(This) $audace(rep_images) $audace(bufNo) "1" ]
               if {$d!=""} {set ::astrometry::catvalues(reffile) $d ; update ; focus $::astrometry::astrom(This)}
            }
         pack $astrom(This).cal.${cal}.fra_1.but -side left -padx 2 -ipady 5
         label $astrom(This).cal.${cal}.fra_1.lab -text "$caption(astrometry,cal,filename)"
         pack $astrom(This).cal.${cal}.fra_1.lab -side left
         entry $astrom(This).cal.${cal}.fra_1.ent -textvariable ::astrometry::catvalues(reffile) -width 40
         pack $astrom(This).cal.${cal}.fra_1.ent -side left
      pack $astrom(This).cal.${cal}.fra_1 -anchor center -fill x
      #--- Button to start the calibration and help
      frame $astrom(This).cal.fra_2
         button $astrom(This).cal.fra_2.but3 -text "$caption(astrometry,start)" -command {::astrometry::start}
         pack $astrom(This).cal.fra_2.but3 -in $astrom(This).cal.fra_2 -side left -anchor center -fill x -expand true -pady 10 -ipadx 15 -padx 5 -ipady 5
         button $astrom(This).cal.fra_2.but4 -text "$caption(astrometry,help)" -width 7 -command {::astrometry::afficheAide}
         pack $astrom(This).cal.fra_2.but4 -in $astrom(This).cal.fra_2 -side left -anchor center -pady 5 -ipadx 15 -padx 5 -ipady 5
      pack $astrom(This).cal.fra_2 -side bottom -anchor center -fill x
      #---
      frame $astrom(This).status
         label $astrom(This).status.lab -text ""
         pack $astrom(This).status.lab -side left
      pack $astrom(This).status -anchor center -fill x

      #---
      set astrom(currenttypewcs) [lindex $astrom(typewcs) 0]
      ::astrometry::wcs_pack $astrom(currenttypewcs)
      #---
      set astrom(currenttypecal) [lindex $astrom(typecal) 0]
      ::astrometry::cal_pack $astrom(currenttypecal)
      #--- Focus
      focus $astrom(This)
      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $astrom(This) <Key-F1> { $audace(console)::GiveFocus }
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $astrom(This)
   }

   proc quit { } {
      variable astrom

      ::astrometry::recup_position
      destroy $astrom(This)
   }

   proc afficheAide { } {
      global help

      ::audace::showHelpItem "$help(dir,analyse)" "1090astrometrie.htm"
   }

   proc updatewcs { } {
      variable astrom
      global audace

      #--- Read the values of header keywords
      set k 0
      foreach kwd $astrom(kwds) {
         set d [buf$audace(bufNo) getkwd $kwd]
         if {[lindex $d 1]==""} {
            #--- The value does not exists in image, we take the default value
            set ::astrometry::astrom(wcsvalues,$kwd) [lindex $astrom(values) $k]
            set ::astrometry::astrom(wcsunits,$kwd) [lindex $astrom(units) $k]
            set ::astrometry::astrom(wcscomments,$kwd) [lindex $astrom(comments) $k]
            set ::astrometry::astrom(wcstypes,$kwd) [lindex $astrom(types) $k]
         } else {
            #--- The value does exists, we take the image header value
            set ::astrometry::astrom(wcsvalues,$kwd) [lindex $d 1]
            set ::astrometry::astrom(wcsunits,$kwd) [lindex $d 4]
            set ::astrometry::astrom(wcscomments,$kwd) [lindex $d 3]
            set ::astrometry::astrom(wcstypes,$kwd) [lindex $d 2]
         }
         incr k
      }
   }

   proc start { {sextractor no } {silent no } } {
      variable astrom
      global audace caption color

      #set sextractor yes
      set starfile no
      #::console::affiche_resultat "=====> astrom(currenttypewcs)=$astrom(currenttypewcs) \n"
      if {$astrom(currenttypecal)=="delwcs"} {
         set kwddels {CD1_1 CD1_2 CD2_1 CD2_2 CRVAL1 CRVAL2 CDELT1 CDELT2 CROTA2 FOCLEN CRPIX1 CRPIX2}
         set kwdnews {}
      } else {
         if {$astrom(currenttypewcs)=="optic"} {
            set kwddels {CD1_1 CD1_2 CD2_1 CD2_2 CRVAL1 CRVAL2 CDELT1 CDELT2}
            set kwdnews {FOCLEN PIXSIZE1 PIXSIZE2 CROTA2 CRPIX1 CRPIX2 RA DEC CRVAL1 CRVAL2 CDELT1 CDELT2}
         }
         if {$astrom(currenttypewcs)=="classic"} {
            set kwddels {FOCLEN CD1_1 CD1_2 CD2_1 CD2_2}
            set kwdnews {CRVAL1 CRVAL2 CDELT1 CDELT2 CROTA2 CRPIX1 CRPIX2}
         }
         if {$astrom(currenttypewcs)=="matrix"} {
            set kwddels {FOCLEN CDELT1 CDELT2 CROTA2}
         set kwdnews {CRVAL1 CRVAL2 CD1_1 CD1_2 CD2_1 CD2_2 CRPIX1 CRPIX2}
         }
      }
      foreach kwd $kwddels {
         catch {buf$audace(bufNo) delkwd $kwd}
         #::console::affiche_resultat " DEL $kwd\n"
      }
       foreach kwd $kwdnews {
         set d [list $kwd "$::astrometry::astrom(wcsvalues,$kwd)" "$::astrometry::astrom(wcstypes,$kwd)" "$::astrometry::astrom(wcscomments,$kwd)" "$::astrometry::astrom(wcsunits,$kwd)"]
         set kwd0 [lindex $d 0]
         set val [lindex $d 1]
         #::console::affiche_resultat " set d=$d\n"
         if {$kwd0!=""} {
            if {$kwd0=="RA"}     { set val [mc_angle2deg $val 360] }
            if {$kwd0=="DEC"}    { set val [mc_angle2deg $val 90] }
            if {$kwd0=="CRVAL1"} { set val [mc_angle2deg $val 360] }
            if {$kwd0=="CRVAL2"} { set val [mc_angle2deg $val 90] }
            if {$kwd0=="CROTA2"} { set val [mc_angle2deg $val 360] }
            set d [lreplace $d 1 1 $val]
            buf$audace(bufNo) setkwd $d
         }
         #::console::affiche_resultat " SET $d\n"
      }
      if {$astrom(currenttypewcs)=="optic"} {
         set valra 0.0
         set valdec 0.0
         foreach kwd $kwdnews {
            set d [list $kwd "$::astrometry::astrom(wcsvalues,$kwd)" "$::astrometry::astrom(wcstypes,$kwd)" "$::astrometry::astrom(wcscomments,$kwd)" "$::astrometry::astrom(wcsunits,$kwd)"]
            set kwd0 [lindex $d 0]
            set val [lindex $d 1]
            set unit [lindex $d 4]
            #::console::affiche_resultat " set d1=$d\n"
            if {$kwd0!=""} {
               if {$kwd0=="RA"}       { set valra [mc_angle2deg $val 360] }
               if {$kwd0=="DEC"}      { set valdec [mc_angle2deg $val 90] }
               if {$kwd0=="FOCLEN"}   { set valfoclen $val }
               if {$kwd0=="PIXSIZE1"} {
                  set mult 1.
                  if {$unit=="m"} {
                     set mult 1e6
                  }
                  set valpixsize1 [expr $val*$mult] ; # um
               }
               if {$kwd0=="PIXSIZE2"} {
                  set mult 1.
                  if {$unit=="m"} {
                     set mult 1e6
                  }
                  set valpixsize2 [expr $val*$mult] ; # um
               }
            }
         }
         set pi [expr 4*atan(1.)]
         foreach kwd $kwdnews {
            set d [list $kwd "$::astrometry::astrom(wcsvalues,$kwd)" "$::astrometry::astrom(wcstypes,$kwd)" "$::astrometry::astrom(wcscomments,$kwd)" "$::astrometry::astrom(wcsunits,$kwd)"]
            set kwd0 [lindex $d 0]
            set val [lindex $d 1]
            #::console::affiche_resultat " set d2=$d ($valdec)\n"
            if {$kwd0!=""} {
               if {$kwd0=="CRVAL1"} { set val $valra }
               if {$kwd0=="CRVAL2"} { set val $valdec }
               if {$kwd0=="CDELT1"} {
                  set mult 1e-6
                  set val [expr -2*atan($valpixsize1/$valfoclen*$mult/2.)*180/$pi]
               }
               if {$kwd0=="CDELT2"} {
                  set mult 1e-6
                  set val [expr 2*atan($valpixsize2/$valfoclen*$mult/2.)*180/$pi]
               }
               set d [lreplace $d 1 1 $val]
               buf$audace(bufNo) setkwd $d
            }
         }
      }
      $astrom(This).status.lab configure -text "$caption(astrometry,start,0)"
      update
      set ext [buf$audace(bufNo) extension]
      set mypath "${audace(rep_images)}"
      set sky0 dummy0
      if {$astrom(currenttypecal)=="catalog"} {
         set cattype $::astrometry::catvalues(cattype)
         set cdpath "$::astrometry::catvalues(catfolder)"
         set sky dummy
         catch {buf$audace(bufNo) delkwd CATASTAR}
         buf$audace(bufNo) save "${mypath}/${sky0}$ext"
         $astrom(This).status.lab configure -text "$caption(astrometry,start,1)" ; update
         if {$sextractor=="no"} {
            ttscript2 "IMA/SERIES \"$mypath\" \"$sky0\" . . \"$ext\" \"$mypath\" \"$sky\" . \"$ext\" STAT \"objefile=${mypath}/x$sky$ext\" detect_kappa=20"
         } else {
            buf$audace(bufNo) save "${mypath}/${sky}$ext"
            # exec sex $mypath/$sky0$ext -c [pwd]/config.sex
            sextractor "$mypath/$sky0$ext" -c config.sex
         }
         $astrom(This).status.lab configure -text "$caption(astrometry,start,2) $cattype : $::astrometry::catvalues(catfolder) ..." ; update
         set erreur [ catch { ttscript2 "IMA/SERIES \"$mypath\" \"$sky\" . . \"$ext\" \"$mypath\" \"$sky\" . \"$ext\" CATCHART \"path_astromcatalog=$cdpath\" astromcatalog=$cattype \"catafile=${mypath}/c$sky$ext\" \"jpegfile_chart2=$mypath/${sky}a.jpg\" " } msg ]
         if { $erreur == "1" } {
            if {$silent=="no"} {
               tk_messageBox -message "$caption(astrometry,erreur_catalog)" -icon error
            }
            file delete [ file join [pwd] usno.lst ]
            file delete [ file join $mypath ${sky}$ext ]
            file delete [ file join $mypath ${sky}0$ext ]
            file delete [ file join $mypath x${sky}$ext ]
            $astrom(This).status.lab configure -text ""
            update
            return
         } else {
            $astrom(This).status.lab configure -text "$caption(astrometry,start,3)" ; update
            if {$sextractor=="no"} {
               ttscript2 "IMA/SERIES \"$mypath\" \"$sky\" . . \"$ext\" \"$mypath\" \"$sky\" . \"$ext\" ASTROMETRY delta=5 epsilon=0.0002"
            } else {
               ttscript2 "IMA/SERIES \"$mypath\" \"$sky\" . . \"$ext\" \"$mypath\" \"$sky\" . \"$ext\" ASTROMETRY objefile=catalog.cat nullpixel=-10000 delta=5 epsilon=0.0002 file_ascii=ascii.txt"
            }
            $astrom(This).status.lab configure -text "$caption(astrometry,start,4) $cattype : $::astrometry::catvalues(catfolder) ..." ; update
            ttscript2 "IMA/SERIES \"$mypath\" \"$sky\" . . \"$ext\" \"$mypath\" \"z$sky\" . \"$ext\" CATCHART \"path_astromcatalog=$cdpath\" astromcatalog=$cattype \"catafile=${mypath}/c$sky$ext\" \"jpegfile_chart2=$mypath/${sky}b.jpg\" "
            ttscript2 "IMA/SERIES \"$mypath\" \"x$sky\" . . \"$ext\" . . . \"$ext\" DELETE"
            ttscript2 "IMA/SERIES \"$mypath\" \"c$sky\" . . \"$ext\" . . . \"$ext\" DELETE"
            buf$audace(bufNo) load "${mypath}/${sky}$ext"
            #---
            set catastar [lindex [buf$audace(bufNo) getkwd CATASTAR] 1]
            if {$catastar>=3} {
               $astrom(This).status.lab configure -text "$caption(astrometry,start,6) $catastar $caption(astrometry,start,6a)" ; update
               ::astrometry::visu_result
            } else {
               $astrom(This).status.lab configure -text "$caption(astrometry,start,7) " ; update
            }
         }
      } elseif {$astrom(currenttypecal)=="file"} {
         set erreur [ catch { calibrate_from_file $::astrometry::catvalues(reffile) } msg ]
         if { $erreur == "1" } {
            if {$silent=="no"} {
               tk_messageBox -message "$caption(astrometry,erreur_file)" -icon error
            }
            $astrom(This).status.lab configure -text ""
            update
            return
         } else {
            buf$audace(bufNo) save "${mypath}/${sky0}$ext"
            buf$audace(bufNo) load "${mypath}/${sky0}$ext"
            $astrom(This).status.lab configure -text "$caption(astrometry,start,8) $::astrometry::catvalues(reffile)"
            set catastar 4
         }
      } elseif {$astrom(currenttypecal)=="manual"} {
         catch {buf$audace(bufNo) delkwd CATASTAR}
         buf$audace(bufNo) save "${mypath}/${sky0}$ext"
         buf$audace(bufNo) load "${mypath}/${sky0}$ext"
         $astrom(This).status.lab configure -text "$caption(astrometry,start,9)"
         set catastar 4
      } elseif {$astrom(currenttypecal)=="delwcs"} {
         catch {buf$audace(bufNo) delkwd CATASTAR}
         buf$audace(bufNo) save "${mypath}/${sky0}$ext"
         buf$audace(bufNo) load "${mypath}/${sky0}$ext"
         $astrom(This).status.lab configure -text "$caption(astrometry,start,11)"
         set catastar 0
         ::astrometry::updatewcs
      }
      if {$catastar<3} {
         return
      }
      #--- Read the values of header keywords
      ::astrometry::updatewcs
      #--- Bind sur les coordonnees
      $audace(base).fra1.labURLX configure -fg $color(blue)
      $audace(base).fra1.labURLY configure -fg $color(blue)
      set audace(labcoord,type) xy
      bind $audace(base).fra1.labURLX <Button-1> {
         global audace
         if { $audace(labcoord,type) == "xy" } {
            set audace(labcoord,type) radec
            $audace(base).fra1.labURLX configure -text "$caption(astrometry,RA) $caption(astrometry,egale) $caption(astrometry,tiret)"
            $audace(base).fra1.labURLY configure -text "$caption(astrometry,DEC) $caption(astrometry,egale) $caption(astrometry,tiret)"
         } else {
            set audace(labcoord,type) xy
            $audace(base).fra1.labURLX configure -text "$caption(astrometry,X) $caption(astrometry,egale) $caption(astrometry,tiret)"
            $audace(base).fra1.labURLY configure -text "$caption(astrometry,Y) $caption(astrometry,egale) $caption(astrometry,tiret)"
         }
      }
      bind $audace(base).fra1.labURLY <Button-1> {
         global audace
         if { $audace(labcoord,type) == "xy" } {
            set audace(labcoord,type) radec
            $audace(base).fra1.labURLX configure -text "$caption(astrometry,RA) $caption(astrometry,egale) $caption(astrometry,tiret)"
            $audace(base).fra1.labURLY configure -text "$caption(astrometry,DEC) $caption(astrometry,egale) $caption(astrometry,tiret)"
         } else {
            set audace(labcoord,type) xy
            $audace(base).fra1.labURLX configure -text "$caption(astrometry,X) $caption(astrometry,egale) $caption(astrometry,tiret)"
            $audace(base).fra1.labURLY configure -text "$caption(astrometry,Y) $caption(astrometry,egale) $caption(astrometry,tiret)"
         }
      }
      #---
      if {$starfile=="yes"} {
         set stars [mc_readcat [ list BUFFER $audace(bufNo) ] [ list * ASTROMMICROCAT $astrom(catfolder) ] {LIST} -objmax 10000 -magr< 14 -magr> 10]
         set texte ""
         foreach re $stars {
            append texte "$re\n"
         }
         set f [open "microcat.txt" w ]
         puts -nonewline $f "$texte"
         close $f
         set texte ""
         set texte2 ""
         foreach re $stars {
            set dimx [lindex [buf$audace(bufNo) getkwd NAXIS1 ] 1]
            set dimy [lindex [buf$audace(bufNo) getkwd NAXIS2 ] 0]
            set racat [lindex $re 0]
            set deccat [lindex $re 1]
            set racat0 [lindex $re 0]
            set deccat0 [lindex $re 1]
            set xcat0 [lindex $re 4]
           # if {($xcat0>1030)&&($xcat0<1040)} {
              # continue
           # }
            set ycat0 [lindex $re 5]
            set err [catch {set xycat [buf$audace(bufNo) radec2xy [list $racat $deccat]]}]
            if {$err==1} {
               break
            }
            #::console::affiche_resultat "$re\n $xycat\n"
            set xcat [lindex $xycat 0]
            #if {$xcat>1035} {
               # set xcat [expr $xcat-4.]
            #}
            set ycat [lindex $xycat 1]
            set fen 4
            set x1 [expr int($xcat-$fen)]
            set y1 [expr int($ycat-$fen)]
            set x2 [expr int($xcat+$fen)]
            set y2 [expr int($ycat+$fen)]
            if {$x1<1} {set x1 1}
            if {$y1<1} {set y1 1}
            if {$x2>$dimx} {set x2 $dimx}
            if {$y2>$dimy} {set y2 $dimy}
            set box [list $x1 $y1 $x2 $y2]
            set d [buf$audace(bufNo) fitgauss $box]
            set xmes [lindex $d 1]
            #if {$xmes>1035} {
               # set xmes [expr $xmes+4.]
            #}
            set ymes [lindex $d 5]
            set radecmes [buf$audace(bufNo) xy2radec [list $xmes $ymes] 1]
            set rames [lindex $radecmes 0]
            set decmes [lindex $radecmes 1]
            set d [mc_anglesep [list $rames $decmes $racat0 $deccat0 ]]
            #::console::affiche_resultat "$xmes $ymes $d  $xcat0 $ycat0 \n"
            append texte "$xmes $ymes $d $xcat0 $ycat0 $rames $decmes $racat0 $deccat0\n"
            #---
            set radecmes [buf$audace(bufNo) xy2radec [list $xmes $ymes] 2]
            set rames [lindex $radecmes 0]
            set decmes [lindex $radecmes 1]
            set d [mc_anglesep [list $rames $decmes $racat0 $deccat0 ]]
            append texte2 "$xmes $ymes $d $xcat0 $ycat0 $rames $decmes $racat0 $deccat0\n"
         }
         set f [open "compare1.txt" w ]
         puts -nonewline $f "$texte"
         close $f
         set f [open "compare2.txt" w ]
         puts -nonewline $f "$texte2"
         close $f
         #---
         set texte ""
         for {set k1 1} {$k1<=2} {incr k1} {
            for {set k2 0} {$k2<=10} {incr k2} {
               append texte "[lindex [buf$audace(bufNo) getkwd PV${k1}_${k2}] 1] \n"
            }
         }
         set f [open "pv.txt" w ]
         puts -nonewline $f "$texte"
         close $f
      }
      #---
      update
   }

   proc wcs_pack { { wcs + } } {
      variable astrom
      global caption

      foreach xwcs $astrom(typewcs) {
         pack forget $astrom(This).wcs.${xwcs}
      }
      set n [llength $astrom(typewcs)]
      if {$wcs=="+"} {
         set k [lsearch $astrom(typewcs) $astrom(currenttypewcs)]
         incr k
         if {$k>=$n} { set k 0 }
      } else {
         set k [lsearch $astrom(typewcs) $wcs]
         if {$k<0} { set k 0 }
         if {$k>$n} { set k [expr $n-1] }
      }
      set astrom(currenttypewcs) [lindex $astrom(typewcs) $k]
      pack $astrom(This).wcs.$astrom(currenttypewcs) -in $astrom(This).wcs -anchor center -fill x
      $astrom(This).but1 configure -text "$caption(astrometry,wcs,$astrom(currenttypewcs))"
      update
   }

   proc cal_pack { { cal + } } {
      variable astrom
      global caption

      foreach xcal $astrom(typecal) {
         pack forget $astrom(This).cal.${xcal}
      }
      set n [llength $astrom(typecal)]
      if {$cal=="+"} {
         set k [lsearch $astrom(typecal) $astrom(currenttypecal)]
         incr k
         if {$k>=$n} { set k 0 }
      } else {
         set k [lsearch $astrom(typecal) $cal]
         if {$k<0} { set k 0 }
         if {$k>$n} { set k [expr $n-1] }
      }
      set astrom(currenttypecal) [lindex $astrom(typecal) $k]
      pack $astrom(This).cal.$astrom(currenttypecal) -in $astrom(This).cal -anchor center -fill x
      $astrom(This).but2 configure -text "$caption(astrometry,cal,$astrom(currenttypecal))"
      $astrom(This).status.lab configure -text ""
      update
   }

   proc keyword { wcs kwd } {
      variable astrom

      frame $astrom(This).wcs.${wcs}.fra_${kwd}
         label $astrom(This).wcs.${wcs}.fra_${kwd}.lab1 -text ${kwd}
         pack $astrom(This).wcs.${wcs}.fra_${kwd}.lab1 -side left
         entry $astrom(This).wcs.${wcs}.fra_${kwd}.ent -textvariable ::astrometry::astrom(wcsvalues,${kwd})
         pack $astrom(This).wcs.${wcs}.fra_${kwd}.ent -side left
         label $astrom(This).wcs.${wcs}.fra_${kwd}.lab2 -text "$astrom(wcsunits,${kwd}) ($astrom(wcscomments,${kwd}))"
         pack $astrom(This).wcs.${wcs}.fra_${kwd}.lab2 -side left
      pack $astrom(This).wcs.${wcs}.fra_${kwd} -anchor center -fill x
   }

   proc getdirname { } {
      variable astrom
      global audace
      global caption

      set dirname [tk_chooseDirectory -title "$caption(astrometry,cal,catfolder)" \
         -initialdir $audace(rep_catalogues) -parent $astrom(This)]
      set len [ string length $dirname ]
      set folder "$dirname"
      if { $len > "0" } {
         set car [ string index "$dirname" [ expr $len-1 ] ]
         if { $car != "/" } {
            append folder "/"
         }
         set dirname $folder
      }
      return $dirname
   }

   proc calibrate_from_file { fullfilename } {
      variable astrom
      global audace

      set k [::buf::create]
      buf$k load $fullfilename
      foreach kwd $astrom(kwds) {
         set d [buf$k getkwd $kwd]
         catch {buf$audace(bufNo) delkwd $kwd}
         if {[lindex $d 0]!=""} {
            buf$audace(bufNo) setkwd $d
         }
      }
      set kwds {CMAGR CATASTAR}
      foreach kwd $kwds {
         set d [buf$k getkwd $kwd]
         if {[lindex $d 0]!=""} {
            buf$audace(bufNo) setkwd $d
         }
      }
      ::buf::delete $k
   }

   proc mpc_provisional2packed { designation {format old} } {
      #               1222345   122233335
      # 2000EL118 <=> K00EB8L   K00E0118L
      #--- On met en majuscules
      set designation [string toupper $designation]
      #--- On supprime les espaces
      regsub -all " " $designation "" a
      #--- Verifie la longueur de la chaine
      set len [string length $a]
      if {$len<6} {
         return ""
      }
      #--- Decode le siecle
      set yy [string range $a 0 1]
      set a1 [format %c [expr 65+$yy-10]]
      #--- Decode l'annee et la premiere lettre
      set a2 [string range $a 2 4]
      #--- Decode l'annee et la seconde lettre
      set a5 [string range $a 5 5]
      #--- Decode le nombre
      set numorder [string range $a 6 end]
      if {$numorder==""} {
         set a3 0
         set a4 0
      } else {
         set len [string length $numorder]
         if {$format=="old"} {
            if {$len==1} {
               set a3 0
               set a4 [string index $numorder 0]
            } elseif {$len==2} {
               set a3 [string index $numorder 0]
               set a4 [string index $numorder 1]
            } else {
               set yy [string range $numorder 0 1]
               set a3 [format %c [expr 65+$yy-10]]
               set a4 [string index $numorder 2]
            }
         } else {
            set a3 [format %04d $numorder]
            set a4 ""
         }
      }
      #--- Chaine finale
      set designation "${a1}${a2}${a3}${a4}${a5}"
      return $designation
   }

   proc mpc_packed2provisional { designation {format old} } {
      #               1222345   122233335
      # 2000EL118 <=> K00EB8L   K00E0118L
      #--- On supprime les espaces
      regsub -all " " $designation "" a
      #--- Verifie la longueur de la chaine
      set len [string length $a]
      if {$len<7} {
         return ""
      }
      #--- Table de conversion
      set table ""
      for {set k 1} {$k<=26} {incr k} {
         lappend table [format %c [expr 64+$k]]
      }
      #--- Decode le siecle
      set yy [string range $a 0 0]
      set a1 [expr 10+[lsearch $table $yy]]
      #--- Decode l'annee et la premiere lettre
      set a2 [string range $a 1 3]
      #--- Decode la lettre et le nombre
      if {$format=="old"} {
         #--- Decode l'annee et la seconde lettre
         set a5 [string range $a 6 6]
         #--- Decode le nombre
         set numorder [string range $a 4 4]
         set a3 [expr 10+[lsearch $table $numorder]]
         if {$a3==9} {
            set a3 [expr $numorder]
         }
         if {$a3==0} {
            set a3 ""
         }
         set numorder [string range $a 5 5]
            set a4 [expr $numorder]
         if {$a4==0} {
            set a4 ""
         }
      } else {
         #--- Decode l'annee et la seconde lettre
         set a5 [string range $a 8 8]
         #--- Decode le nombre
         set a3 [string trimleft [string range $a 4 7] 0]
         set a4 ""
      }
      #--- Chaine finale
      set designation "${a1}${a2}${a5}${a3}${a4}"
      return $designation
   }

   #
   # astrometry::Astrom_Scrolled_Canvas
   # Cree un canvas scrollable, ainsi que les deux scrollbars pour le deplacer
   # Ref : Brent Welsh, Practical Programming in TCL/TK, rev.2, page 392
   #
   proc Astrom_Scrolled_Canvas { c args } {
      frame $c
      eval {canvas $c.canvas \
         -xscrollcommand [list $c.xscroll set] \
         -yscrollcommand [list $c.yscroll set] \
         -highlightthickness 0 \
         -borderwidth 0} $args
      scrollbar $c.xscroll -orient horizontal -command [list $c.canvas xview]
      scrollbar $c.yscroll -orient vertical -command [list $c.canvas yview]
      grid $c.canvas $c.yscroll -sticky news
      grid $c.xscroll -sticky ew
      grid rowconfigure $c 0 -weight 1
      grid columnconfigure $c 0 -weight 1
      return $c.canvas
   }

   proc visu_result { } {
      variable astrom
      global audace
      global caption

      #--- Nom de la fenetre
      set astrom(This_check) "$audace(base).check_astro"

      #--- Initialisation du fichier image du controle de la calibration
      set mypath "${audace(rep_images)}"
      set sky "dummy"

      #--- Creation de l'image et calcul de sa dimension
      set img [ image create photo -file [ file join $mypath/${sky}b.jpg ] ]
      set largeur [ image width $img ]
      set hauteur [ image height $img ]

      #---
      if [ winfo exists $astrom(This_check) ] {
         destroy $astrom(This_check)
      }

      #--- Fenetre de visualisation en fonction de la dimension de l'image
      if { $largeur < "390" || $hauteur < "260" } {
         toplevel $astrom(This_check) -borderwidth 1 -width $largeur -height $hauteur -relief sunken
         wm geometry $astrom(This_check) +20+20
      } else {
         toplevel $astrom(This_check) -borderwidth 1 -relief sunken
         wm geometry $astrom(This_check) 640x480+20+20
      }
      wm resizable $astrom(This_check) 1 1
      wm title $astrom(This_check) "$caption(astrometry,start,10)"
      wm protocol $astrom(This_check) WM_DELETE_WINDOW { ::astrometry::delete_dummy_lst }

      #--- Affichage de l'explication
      message $astrom(This_check).legende -text "$caption(astrometry,comment)" -justify center \
         -width [ expr 0.9 * $largeur ]
      pack $astrom(This_check).legende -in $astrom(This_check) -side top -anchor center -fill both -padx 10 -pady 10

      #--- Cree le canevas pour l'affichage de l'image
      ::astrometry::Astrom_Scrolled_Canvas $astrom(This_check).result -borderwidth 0 -relief flat \
         -width $largeur -height $hauteur -scrollregion {0 0 0 0} -cursor crosshair
      $astrom(This_check).result.canvas configure -borderwidth 0
      $astrom(This_check).result.canvas configure -relief flat
      pack $astrom(This_check).result \
         -in $astrom(This_check) -expand 1 -side left -anchor center -fill both -padx 0 -pady 0

      #--- Affichage de l'image dans le canvas
      $astrom(This_check).result.canvas create image 0 0 -anchor nw -tag display
      $astrom(This_check).result.canvas itemconfigure display -image $img
      $astrom(This_check).result.canvas configure -scrollregion [list 0 0 $largeur $hauteur ]

      #--- Focus
      focus $astrom(This_check)

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $astrom(This_check) <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $astrom(This_check)
   }

   proc delete_dummy_lst { } {
      variable astrom
      global audace

      set mypath "${audace(rep_images)}"
      set sky "dummy"
      image delete
      #--- Nettoyage des eventuels fichiers crees
      set ext [buf$audace(bufNo) extension]
      catch {
         file delete [ file join $mypath ${sky}a.jpg ]
         file delete [ file join $mypath ${sky}b.jpg ]
         file delete [ file join $mypath ${sky}$ext ]
         file delete [ file join $mypath ${sky}0$ext ]
         file delete [ file join $mypath c${sky}$ext ]
         file delete [ file join $mypath x${sky}$ext ]
         file delete [ file join $mypath z${sky}$ext ]
         file delete [ file join [pwd] com.lst ]
         file delete [ file join [pwd] dif.lst ]
         file delete [ file join [pwd] eq.lst ]
         file delete [ file join [pwd] obs.lst ]
         file delete [ file join [pwd] pointzero.lst ]
         file delete [ file join [pwd] usno.lst ]
         file delete [ file join [pwd] xy.lst ]
      }
      destroy $astrom(This_check)
   }

}

#::astrometry::create

