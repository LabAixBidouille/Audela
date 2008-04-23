#
# Update $Id: audela.tcl,v 1.12 2008-04-23 21:14:13 robertdelmas Exp $
#
#--- Welcome to the AudeLA-Interfaces Easy Launcher
#
#--- If you want to add a language:
#--- 1) Add you language name in 'call the language initialisation' of this file as:
#---    set caption(lg) { "french" "italian" "spanish" "mylanguage" "english" }
#--- 2) Add a flag in 'Create the flag menu to change the language interactively', just
#---    before '#--- english' in this file as:
#---    #--- mylanguage
#---    ...
#---    ...
#--- 3) Complete 'definition of captions' in the file 'audela.cap' (caption directory)
#---    just before "} else {" as:
#---    else if {[string compare $langage "mylanguage"] == 0 } {
#---       ...
#---       ...
#

set nameofexecutable [file tail [file rootname [info nameofexecutable]]]
if {($nameofexecutable!="audela")&&([file exists ../ros]==1)} {
   catch {source ros.tcl}
}

source "version.tcl"

if {[file exists audace.txt]==1} {
   set langage english
   catch {source langage.tcl}
   cd ../gui/audace; source aud.tcl
   return
}

#--- Proc to initialise the caption according to the language
proc basecaption { {langage ""} } {
   global caption
   #--- Selection of langage
   if {[string compare $langage ""] ==0 } {
      #--- First time initialisations
      catch {source langage.tcl}
      if {[info exists langage] == "0"} {
         set langage [lindex $caption(lg) 0]
      }
      if {[lsearch -exact "$caption(lg)" "$langage"]==-1} {
         set langage [lindex $caption(lg) 0]
      }
      catch {
         set f [open "langage.tcl" w]
         puts $f "set langage \"$langage\""
         close $f
      }
      #--- Define captions for the tk_optionmenu
      set caption(lg,1) "$langage"
      set k 1
      foreach lg $caption(lg) {
         if {[string compare "$lg" "$langage"] !=0 } {
            incr k
            set caption(lg,$k) "$lg"
         }
      }
   }
   #--- Definition of captions
   source [ file join $::audela_start_dir ../gui/audace/caption audela.cap ]
   return $langage
}

#--- Call the language initialisation
global caption
set caption(lg) { "french" "italian" "spanish" "german" "portuguese" "danish" "english" }
set langage [basecaption]

#--- Create the toplevel window
set base .choice
toplevel $base -class Toplevel
wm geometry $base 510x220+10+10
wm focusmodel $base passive
wm maxsize $base 510 220
wm minsize $base 510 220
wm overrideredirect $base 0
wm resizable $base 1 1
wm deiconify $base
wm title $base $caption(audela,main_title)
bind $base <Destroy> { destroy .choice ; exit }
wm withdraw .
focus -force $base

#--- Create the flag menu to change the language interactively
set font { Arial 12 bold }
set fontsmall { Arial 8 }
frame $base.fra1
   #--- Label
   label $base.fra1.text1 -text "$caption(audela,language)" -font $font
   pack $base.fra1.text1 -side left -padx 5 -pady 10
   #--- French
   image create photo imageflag1
   imageflag1 configure -file fr.gif -format gif
   label $base.fra1.flag1 -image imageflag1
   pack $base.fra1.flag1 -side left -padx 5 -pady 5
   #--- Italian
   image create photo imageflag2
   imageflag2 configure -file it.gif -format gif
   label $base.fra1.flag2 -image imageflag2
   pack $base.fra1.flag2 -side left -padx 5 -pady 5
   #--- Spanish
   image create photo imageflag3
   imageflag3 configure -file sp.gif -format gif
   label $base.fra1.flag3 -image imageflag3
   pack $base.fra1.flag3 -side left -padx 5 -pady 5
   #--- German
   image create photo imageflag4
   imageflag4 configure -file de.gif -format gif
   label $base.fra1.flag4 -image imageflag4
   pack $base.fra1.flag4 -side left -padx 5 -pady 5
   #--- Portuguese
   image create photo imageflag5
   imageflag5 configure -file pt.gif -format gif
   label $base.fra1.flag5 -image imageflag5
   pack $base.fra1.flag5 -side left -padx 5 -pady 5
   #--- Danish
   image create photo imageflag6
   imageflag6 configure -file da.gif -format gif
   label $base.fra1.flag6 -image imageflag6
   pack $base.fra1.flag6 -side left -padx 5 -pady 5
   #--- English
   image create photo imageflag7
   imageflag7 configure -file gb.gif -format gif
   label $base.fra1.flag7 -image imageflag7
   pack $base.fra1.flag7 -side left -padx 5 -pady 5
pack $base.fra1 -side top -in $base

#--- Create the buttons
label $base.lab1 \
   -borderwidth 1 -text "$caption(audela,description)" -font $font
pack $base.lab1 \
   -in $base -anchor center -expand 1 -fill both -side top

button $base.but2 -text $caption(audela,soft)  -width 12 -font $font -command \
   { if {$direct==1} { catch { set f [open audace.txt w] ; close $f} } ; unset caption ; wm withdraw $base ; \
     cd ../gui/audace ; source aud.tcl }
pack $base.but2 -anchor center -side top -fill x -padx 4 -pady 4 \
   -in $base -anchor center -expand 1 -fill both -side top

frame $base.frame1
   button $base.frame1.but3 -text "$caption(audela,launch)" -width 12 -font $font -command \
      { wm withdraw $base ; cd [lindex [split $caption(audela,dirtcl) " "] 0] ; \
        set name [lindex [split $caption(audela,dirtcl) " "] 1] ; unset caption ; \
        source $name }
   pack $base.frame1.but3 -anchor center -side top -fill x -padx 4 -pady 4 \
      -anchor center -expand 1 -fill both -side left
   entry $base.frame1.ent1 -textvariable caption(audela,dirtcl) -width 12 -font $font
   pack $base.frame1.ent1 -anchor center -side top -fill x -padx 4 -pady 4 \
      -anchor center -expand 1 -fill both -side left
pack $base.frame1 -anchor center -side top -fill x -padx 0 -pady 0 \
   -in $base -anchor center -expand 1 -fill both -side top

frame $base.frame2
   checkbutton $base.frame2.check1 -variable direct
   pack $base.frame2.check1 -anchor center -side top -padx 4 -pady 4 \
      -anchor center -expand 0 -fill both -side left
   label $base.frame2.lab1 -text "$caption(audela,direct_audace)" \
      -font $fontsmall
   pack $base.frame2.lab1 -fill x -padx 4 -pady 4 \
      -anchor w -expand 1 -fill both -side left
pack $base.frame2 -anchor center -side top -fill x -padx 0 -pady 0 \
   -in $base -anchor center -expand 0 -fill none -side top

#--- Bindings on flag images
bind $base.fra1.flag1 <ButtonPress-1> { set langage "[lindex $caption(lg) 0]"  }
bind $base.fra1.flag2 <ButtonPress-1> { set langage "[lindex $caption(lg) 1]"  }
bind $base.fra1.flag3 <ButtonPress-1> { set langage "[lindex $caption(lg) 2]"  }
bind $base.fra1.flag4 <ButtonPress-1> { set langage "[lindex $caption(lg) 3]"  }
bind $base.fra1.flag5 <ButtonPress-1> { set langage "[lindex $caption(lg) 4]"  }
bind $base.fra1.flag6 <ButtonPress-1> { set langage "[lindex $caption(lg) 5]"  }
bind $base.fra1.flag7 <ButtonPress-1> { set langage "[lindex $caption(lg) 6]"  }

#--- An infinite loop to change the language interactively
while {1==1} {
   vwait langage
   catch {
      set f [open "langage.tcl" w]
      puts $f "set langage \"$langage\""
      close $f
   }
   basecaption "$langage"
   wm title $base $caption(audela,main_title)
   $base.fra1.text1 configure -text "$caption(audela,language)"
   $base.lab1 configure -text "$caption(audela,description)"
   $base.but2 configure -text $caption(audela,soft)
   $base.frame1.but3 configure -text "$caption(audela,launch)"
   $base.frame2.lab1 configure -text "$caption(audela,direct_audace)"
}

