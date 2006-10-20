#
# Fichier : console.tcl
# Description : Creation de la Console
# Mise a jour $Id: console.tcl,v 1.4 2006-10-20 18:01:56 robertdelmas Exp $
#

namespace eval ::console {

   variable This
   variable CmdLine

   proc create { { this "" } } {
      variable This
      global audace
      global audela
      global caption

      if { $this == "" } {
         set This $audace(Console)
      } else {
         set This $this
      }

      if { [info exists $This] } {
         wm deiconify $This
         return
      }

      toplevel $This
      wm geometry $This 370x200+220+180
      wm maxsize $This [winfo screenwidth .] [winfo screenheight .]
      wm minsize $This 370 200
      wm resizable $This 1 1
      wm deiconify $This
      wm title $This "$caption(audace,console)"
      wm protocol $This WM_DELETE_WINDOW " ::audace::quitter "

      scrollbar $This.scr1 -orient vert -command console::onScr1Scroll
      entry $This.ent1 -bg #FFFFFF -fg #000000 -textvariable console::CmdLine
      text $This.txt1 -yscrollcommand console::onTxt1Scroll -wrap word

      grid $This.txt1 -row 0 -column 0 -sticky news
      grid $This.scr1 -row 0 -column 1 -sticky ns
      grid $This.ent1 -row 1 -column 0 -sticky ew

      grid rowconfigure $This 0 -weight 1
      grid columnconfigure $This 0 -weight 1

      if {[string compare $::tcl_platform(platform) windows]==0} {
         $This.txt1 configure -font {verdana 8}
         $This.ent1 configure -font {verdana 8}
      } else {
         $This.txt1 configure -font {{arial} 12 bold}
         $This.ent1 configure -font {{arial} 12 bold}
      }
      $This.txt1 configure -foreground black
      $This.txt1 configure -background white
      $This.txt1 tag configure style_entete -foreground #007F00
      $This.txt1 tag configure style_resultat -foreground azure4
      $This.txt1 tag configure style_cmd -foreground black
      $This.txt1 tag configure style_erreur -foreground red
      $This.txt1 tag configure style_prompt -foreground purple
      $This.txt1 insert end "#\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,interface_audace_audela) $audela(version)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright1)\n" style_entete
      $This.txt1 insert end "#\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright2)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright3)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright4)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright5)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright6)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright7)\n" style_entete
      $This.txt1 insert end "#\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright8)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright9)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright10)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright11)\n" style_entete
      $This.txt1 insert end "#\n" style_entete
      $This.txt1 insert end "\n" 

      bind $This.txt1 <Key-Return> {console::onTxt1KeyReturn %W; break;}
      bind $This.ent1 <Key-Return> {console::onEnt1KeyReturn %W; break;}
      bind $This.ent1 <Key-Escape> {console::onEnt1KeyEsc %W; break;}
      bind $This.ent1 <Key-Up> {console::onEnt1KeyUp %W; break;}
      bind $This.ent1 <Key-Down> {console::onEnt1KeyDown %W; break;}

      bind $This.txt1 <Key-F1> {console::onTxt1KeyF1 %W; break;}
   }

   proc GiveFocus {} {
      variable This
      switch -- [wm state $This] {
         normal {raise $This}
         iconic {wm deiconify $This}
      }
      focus $This.ent1
   }

   proc affiche_erreur {ligne} {
      variable This
      $This.txt1 insert end "# $ligne" style_erreur
      $This.txt1 see insert
      update
   }

   proc affiche_resultat {ligne} {
      variable This
      $This.txt1 insert end "# $ligne" style_resultat
      $This.txt1 see insert
      update
   }

   proc affiche_saut {ligne} {
      variable This
      $This.txt1 insert end "$ligne" style_resultat
      $This.txt1 see insert
      update
   }

   proc affiche_debug {ligne} {
      variable This
      $This.txt1 insert end "# $caption(audace,console,debug)>" style_entete
      $This.txt1 insert end "$ligne -> "
      $This.txt1 see insert
      update
      $This.txt1 insert end "[uplevel $ligne]\n" style_resultat
   }

   proc affiche_prompt {ligne} {
      variable This
      $This.txt1 insert insert $ligne style_prompt
      $This.txt1 see insert
   }

   proc disp {line} {
      variable This
      $This.txt1 insert insert $line style_cmd
      $This.txt1 see insert
   }

   proc marqueDebut {} {
      variable This
      $This.txt1 mark set debut "insert -1 l lineend"
   }

   proc onTxt1KeyF1 {w} {
      variable This
      focus $This.ent1
   }

   proc onScr1Scroll {args} {
      variable This
      uplevel #0 "$This.txt1 yview $args"
   }

   proc onTxt1Scroll {args} {
      variable This
      uplevel #0 "$This.scr1 set $args"
   }

   proc onTxt1KeyReturn {w} {
      set ligneCmd [$w get "insert linestart" "insert lineend"]
      $w mark set insert "insert lineend"
      $w insert insert "\n"
      execute "$ligneCmd"
      $w see insert
   }

   proc onEnt1KeyReturn {w} {
      variable This
      variable CmdLine
      variable LastSpace

      set Cmd $CmdLine
      $This.txt1 mark set insert end
      ::console::disp "$Cmd\n"
      ::console::execute $Cmd
      $This.txt1 see insert
      historik add "$Cmd"
      set CmdLine ""
      set LastSpace 0
   }

   proc onEnt1KeyEsc {w} {
      variable This
      variable CmdLine
      set CmdLine [historik synchro]
      $This.ent1 icursor end
   }

   proc onEnt1KeyUp {w} {
      variable This
      variable CmdLine
      set CmdLine [historik before]
      $This.ent1 icursor end
   }

   proc onEnt1KeyDown {w} {
      variable This
      variable CmdLine
      set CmdLine [historik after]
      $This.ent1 icursor end
   }

   proc execute {cmd} {
      variable This
      save_cursor
      all_cursor watch
      if { [catch {uplevel #0 $cmd} res] != 0} {
         $This.txt1 insert insert "# $res\n" style_erreur
      } else {
         if { [string compare $res ""] != 0} {
            $This.txt1 insert insert "# $res\n" style_resultat
         }
      }
      $This.txt1 insert insert "\n" 
      restore_cursor
   }

}

