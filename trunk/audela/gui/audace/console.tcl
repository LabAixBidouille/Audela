#
# Fichier : console.tcl
# Description : Creation de la Console
# Mise à jour $Id$
#

namespace eval ::console {

   proc create { { this "" } } {
      variable This
      global audace audela caption color

      if { $this == "" } {
         set This $audace(Console)
      } else {
         set This $this
      }

      if { [winfo exists $This] } {
         wm deiconify $This
         return
      }

      toplevel $This
      wm geometry $This 370x200+220+180
      wm maxsize $This [winfo screenwidth .] [winfo screenheight .]
      wm minsize $This 370 200
      wm resizable $This 1 1
      wm deiconify $This
      wm title $This "$caption(console,titre)"
      wm protocol $This WM_DELETE_WINDOW "::audace::quitter"

      scrollbar $This.scr1 -orient vert -command console::onScr1Scroll
      entry $This.ent1 -bg #FFFFFF -fg #000000 -textvariable console::CmdLine
      text $This.txt1 -bg #DDDDFF -yscrollcommand console::onTxt1Scroll -wrap word

      grid $This.txt1 -row 0 -column 0 -sticky news
      grid $This.scr1 -row 0 -column 1 -sticky ns
      grid $This.ent1 -row 1 -column 0 -sticky ew

      grid rowconfigure $This 0 -weight 1
      grid columnconfigure $This 0 -weight 1

      #--- Polices de caracteres de la Console
      if {[string compare $::tcl_platform(platform) windows]==0} {
         set font(console) "Verdana 8"
      } else {
         set font(console) "Arial 12 bold"
      }
      $This.txt1 configure -font $font(console)
      $This.ent1 configure -font $font(console)

      #--- Initialisation des couleurs de la Console
      set color(textConsoleEntete)   #007F00
      set color(textConsoleResultat) "azure4"
      set color(textConsoleCmd)      "black"
      set color(textConsoleErreur)   "red"
      set color(textConsolePrompt)   "purple"

      #--- Couleurs des messages de la Console
      $This.txt1 tag configure style_entete   -foreground $color(textConsoleEntete)
      $This.txt1 tag configure style_resultat -foreground $color(textConsoleResultat)
      $This.txt1 tag configure style_cmd      -foreground $color(textConsoleCmd)
      $This.txt1 tag configure style_erreur   -foreground $color(textConsoleErreur)
      $This.txt1 tag configure style_prompt   -foreground $color(textConsolePrompt)

      #--- Affichage de l'en-tete dans la Console
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
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright8)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright9)\n" style_entete
      $This.txt1 insert end "#\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright10)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright11)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright12)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright13)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright14)\n" style_entete
      $This.txt1 insert end "# $caption(en-tete,a_propos_de_copyright15)\n" style_entete
      $This.txt1 insert end "#\n" style_entete
      $This.txt1 insert end "\n"

      bind $This.txt1 <Key-Return> {console::onTxt1KeyReturn %W; break;}
      bind $This.ent1 <Key-Return> {console::onEnt1KeyReturn %W; break;}
      bind $This.ent1 <Key-Escape> {console::onEnt1KeyEsc %W; break;}
      bind $This.ent1 <Key-Up>     {console::onEnt1KeyUp %W; break;}
      bind $This.ent1 <Key-Down>   {console::onEnt1KeyDown %W; break;}
      bind $This.txt1 <Key-F1>     {console::onTxt1KeyF1 %W; break;}

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }
   }

   proc GiveFocus {} {
      variable This

      #--- Donne le focus a la Console et positionne le curseur dans la ligne de commande
      switch -- [wm state $This] {
         normal {raise $This}
         iconic {wm deiconify $This}
      }
      focus $This.ent1
      #--- Si la raquette LX200 est utilisee, elle vient au premier plan
      if { [ winfo exists .lx200pad ] } {
         raise .lx200pad
      }
      #--- Si la raquette SuperPad est utilisee, elle vient au premier plan
      if { [ winfo exists .superpad ] } {
         raise .superpad
      }
      #--- Si la raquette T193Pad est utilisee, elle vient au premier plan
      if { [ winfo exists .t193pad ] } {
         raise .t193pad
      }
      #--- Si la raquette TelPad est utilisee, elle vient au premier plan
      if { [ winfo exists .telpad ] } {
         raise .telpad
      }
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

   proc affiche_resultat_bis {ligne} {
      variable This

      $This.txt1 insert end $ligne style_resultat
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
      global caption

      $This.txt1 insert end "# $caption(console,debug)>" style_entete
      $This.txt1 insert end "$ligne -> "
      $This.txt1 see insert
      update
      $This.txt1 insert end "[uplevel $ligne]\n" style_resultat
   }

   proc affiche_entete {ligne} {
      variable This

      $This.txt1 insert end $ligne style_entete
      $This.txt1 see insert
   }

   proc affiche_prompt {ligne} {
      variable This

      $This.txt1 insert end $ligne style_prompt
      $This.txt1 see insert
   }

   proc disp {line} {
      variable This

      $This.txt1 insert end $line style_cmd
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
      $w insert end "\n"
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

      if { [catch {uplevel #0 $cmd} res] != 0} {
         $This.txt1 insert end "# $res\n" style_erreur
      } else {
         if { [string compare $res ""] != 0} {
            $This.txt1 insert end "# $res\n" style_resultat
         }
      }
      $This.txt1 insert end "\n"
   }

}

