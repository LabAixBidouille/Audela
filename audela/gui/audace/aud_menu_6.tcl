#
# Fichier : aud_menu_6.tcl
# Description : Script regroupant les fonctionnalites du menu Outils
# Mise a jour $Id: aud_menu_6.tcl,v 1.3 2006-11-12 16:08:52 robertdelmas Exp $
#

namespace eval ::audace {

   #
   # ::audace::pas_Outil
   # Efface l'interface graphique de l'outil affichee dans la visu
   #
   proc pas_Outil { } {
      global audace

      ::confVisu::stopTool $audace(visuNo)
   }

   #
   # ::audace::affiche_Outil visuNo
   # Fonction qui permet d'afficher tous les outils dans le menu Outils
   #
   proc affiche_Outil { visuNo } {
      global audace caption conf confgene panneau

      set confgene(Choix_Outil,nbre) "0"
      set i "0"
      set liste ""
      foreach m [array names panneau menu_name,*] {
         lappend liste [list "$panneau($m) " $m]
      }
      foreach m [lsort $liste] {
         set m [lindex $m 1]
         set i [expr $i + 1]
         #--- Initialisation des variables indispensable ici
         if { ! [ info exists conf(panneau,n$i) ] }   { set conf(panneau,n$i)  "1" }
         if { ! [ info exists conf(raccourci,n$i) ] } { set conf(raccourci,n$i) "" }
         #---
         set confgene(Choix_Outil,nbre) [ expr $confgene(Choix_Outil,nbre) + 1 ]
         set confgene(Choix_Outil,n$confgene(Choix_Outil,nbre)) $conf(panneau,n$confgene(Choix_Outil,nbre))
         if { $confgene(Choix_Outil,n$confgene(Choix_Outil,nbre)) == "1" } {
            if { [scan "$m" "menu_name,%s" ns] == "1" } {
               Menu_Command $visuNo "$caption(audace,menu,outils)" "$panneau($m)" "::confVisu::selectTool $visuNo ::$ns"
               if { $conf(raccourci,n$i) != "" } {
                  set raccourci(n$i) $conf(raccourci,n$i)
                  if { [string range $raccourci(n$i) 0 3] == "Alt+" } {
                     set raccourci(n$i) "Alt-[string tolower [string range $raccourci(n$i) 4 4]]"
                  } elseif { [string range $raccourci(n$i) 0 4] == "Ctrl+" } {
                     set raccourci(n$i) "Control-[string tolower [string range $raccourci(n$i) 5 5]]"
                  }
                  #---
                  lappend audace(list_raccourcis) [ list $conf(raccourci,n$i) ]
                  lappend audace(list_ns_raccourcis) [ list $ns ]
                  #---
                  Menu_Bind $visuNo $audace(base) <$raccourci(n$i)> "$caption(audace,menu,outils)" "$panneau($m)" "$conf(raccourci,n$i)"
                            bind $audace(Console) <$raccourci(n$i)> "focus $audace(base) ; ::confVisu::selectTool $visuNo ::$ns"
               }
            }
         }
      }
   }

###################################################################################
# Procedures annexes des procedures ci-dessus
###################################################################################

   #
   # ::audace::affiche_Outil_F2
   # Affiche automatiquement au demarrage l'outil ayant F2 pour raccourci
   #
   proc affiche_Outil_F2 { } {
      global audace conf panneau

      #---
      set i "0"
      set liste ""
      foreach m [array names panneau menu_name,*] {
         lappend liste [list "$panneau($m) " $m]
      }
      foreach m [lsort $liste] {
         set m [lindex $m 1]
         set i [expr $i + 1]
         if { $conf(raccourci,n$i) != "" } {
            set raccourci(n$i) $conf(raccourci,n$i)
            if { $raccourci(n$i) == "F2" } {
               if { [scan "$m" "menu_name,%s" ns] == "1" } {
                  #--- Lancement automatique de l'outil ayant le raccourci F2
                  ::confVisu::selectTool $audace(visuNo) ::$ns
               }
            }
         }
      }
   }

}
############################# Fin du namespace audace #############################

