#
# Update $Id: audela.tcl,v 1.16 2009-11-15 13:47:51 michelpujol Exp $
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

#--- Taking into account the coding UTF-8
encoding system utf-8

#--- Add audela/lib directory to ::auto_path if it doesn't already exist
set audelaLibPath [file join [file join [file dirname [file dirname [info nameofexecutable]] ] lib]]
if { [lsearch $::auto_path $audelaLibPath] == -1 } {
   lappend ::auto_path $audelaLibPath
}

set nameofexecutable [file tail [file rootname [info nameofexecutable]]]
if {($nameofexecutable!="audela")&&([file exists ../ros]==1)} {
   catch {source ros.tcl}
}

source version.tcl

if {[file exists audace.txt]==1} {
   set langage english
   catch {source langage.tcl}
   cd ../gui/audace
   source aud.tcl
   return
}

#--- Proc to select language
proc selectLangage { langue } {
   global base caption langage

   $base.fra1.$::langage configure -borderwidth 0
   set ::langage $langue
   $base.fra1.$langue configure -borderwidth 3
   set f [open "[ file join $::audela_start_dir langage.tcl ]" w]
   puts $f "set langage \"$langue\""
   close $f
   basecaption "$langage"
   wm title $base $caption(audela,main_title)
   $base.fra1.text1 configure -text "$caption(audela,language)"
   $base.but2 configure -text "$caption(audela,launch)"
}

#--- Proc to launch Aud'ACE
proc apply { } {
   global base caption

   set f [open audace.txt w]
   close $f
   unset caption
   cd ../gui/audace
   after 10 [ list uplevel #0 source aud.tcl ]
   wm withdraw .choice
   unset base
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

set caption(lg) { "french" "italian" "spanish" "german" "portuguese" "danish" "ukrainian" "russian" "english" }
set langage [basecaption]

#--- Create the toplevel window
set base .choice
toplevel $base -class Toplevel
wm geometry $base 640x150+10+10
wm focusmodel $base passive
wm overrideredirect $base 0
wm resizable $base 0 0
wm deiconify $base
wm title $base $caption(audela,main_title)
bind $base <Destroy> { destroy .choice ; exit }
wm withdraw .
focus -force $base

#--- Create the flag menu to change the language interactively
frame $base.fra1
   #--- Label
   label $base.fra1.text1 -text "$caption(audela,language)" -font { Arial 12 bold } -width 18
   pack $base.fra1.text1 -side left -padx 5 -pady 10
   #--- French
   image create photo imageflag1
   imageflag1 configure -file fr.gif -format gif
   label $base.fra1.french -image imageflag1 -borderwidth 0 -relief solid
   pack $base.fra1.french -side left -padx 5 -pady 5
   #--- Italian
   image create photo imageflag2
   imageflag2 configure -file it.gif -format gif
   label $base.fra1.italian -image imageflag2 -borderwidth 0 -relief solid
   pack $base.fra1.italian -side left -padx 5 -pady 5
   #--- Spanish
   image create photo imageflag3
   imageflag3 configure -file sp.gif -format gif
   label $base.fra1.spanish -image imageflag3 -borderwidth 0 -relief solid
   pack $base.fra1.spanish -side left -padx 5 -pady 5
   #--- German
   image create photo imageflag4
   imageflag4 configure -file de.gif -format gif
   label $base.fra1.german -image imageflag4 -borderwidth 0 -relief solid
   pack $base.fra1.german -side left -padx 5 -pady 5
   #--- Portuguese
   image create photo imageflag5
   imageflag5 configure -file pt.gif -format gif
   label $base.fra1.portuguese -image imageflag5 -borderwidth 0 -relief solid
   pack $base.fra1.portuguese -side left -padx 5 -pady 5
   #--- Danish
   image create photo imageflag6
   imageflag6 configure -file da.gif -format gif
   label $base.fra1.danish -image imageflag6 -borderwidth 0 -relief solid
   pack $base.fra1.danish -side left -padx 5 -pady 5
   #--- Ukrainian
   image create photo imageflag7
   imageflag7 configure -file ua.gif -format gif
   label $base.fra1.ukrainian -image imageflag7 -borderwidth 0 -relief solid
   pack $base.fra1.ukrainian -side left -padx 5 -pady 5
   #--- Russian
   image create photo imageflag8
   imageflag8 configure -file ru.gif -format gif
   label $base.fra1.russian -image imageflag8 -borderwidth 0 -relief solid
   pack $base.fra1.russian -side left -padx 5 -pady 5
   #--- English
   image create photo imageflag9
   imageflag9 configure -file gb.gif -format gif
   label $base.fra1.english -image imageflag9 -borderwidth 0 -relief solid
   pack $base.fra1.english -side left -padx 5 -pady 5
pack $base.fra1 -side top -in $base

$base.fra1.$::langage configure -borderwidth 3

#--- Create the button
button $base.but2 -text "$caption(audela,launch)" -font { Arial 20 bold } -command { apply }
pack $base.but2 -anchor center -side top -padx 4 -pady 4 \
   -in $base -anchor center -expand 1 -fill none -side top

#--- Bindings on flag images
bind $base.fra1.french <ButtonPress-1> { selectLangage "[lindex $::caption(lg) 0]" }
bind $base.fra1.italian <ButtonPress-1> { selectLangage "[lindex $::caption(lg) 1]" }
bind $base.fra1.spanish <ButtonPress-1> { selectLangage "[lindex $::caption(lg) 2]" }
bind $base.fra1.german <ButtonPress-1> { selectLangage "[lindex $::caption(lg) 3]" }
bind $base.fra1.portuguese <ButtonPress-1> { selectLangage "[lindex $::caption(lg) 4]" }
bind $base.fra1.danish <ButtonPress-1> { selectLangage "[lindex $::caption(lg) 5]" }
bind $base.fra1.ukrainian <ButtonPress-1> { selectLangage "[lindex $::caption(lg) 6]" }
bind $base.fra1.russian <ButtonPress-1> { selectLangage "[lindex $::caption(lg) 7]" }
bind $base.fra1.english <ButtonPress-1> { selectLangage "[lindex $::caption(lg) 8]" }

