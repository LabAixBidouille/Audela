#
# Fichier : aud_menu_8.tcl
# Description : Script regroupant les fonctionnalites du menu Aide
# Mise à jour $Id$
#

namespace eval ::audace {

   #
   # ::audace::Lance_Tutorial
   # Lance le tutorial
   #
   proc Lance_Tutorial { } {
      global caption

      if { $::tcl_platform(platform) == "windows" } {
         exec "[ file join $::audela_start_dir audela.exe ]" --file tutorial.tcl &
      } elseif { $::tcl_platform(platform) == "unix" } {
         set catchError [ catch { exec "[ file join $::audela_start_dir audela ]" --file tutorial.tcl & } ]
         if { $catchError != "0" } {
            ::tkutil::displayErrorInfo "$caption(audace,menu,tutorial)"
         }
      } elseif { $::tcl_platform(platform) == "macintosh" } {
         #--- A completer
      }
   }

   #
   # ::audace::Lance_Site_htm filename
   # Lance le navigation web
   #
   proc Lance_Site_htm { filename } {
      global audace caption conf confgene

      menustate disabled
      set confgene(EditScript,error_script) "1"
      set confgene(EditScript,error_pdf)    "1"
      set confgene(EditScript,error_htm)    "1"
      set confgene(EditScript,error_viewer) "1"
      set confgene(EditScript,error_java)   "1"
      set confgene(EditScript,error_iris)   "1"
      set confgene(EditScript,error_aladin) "1"
      regsub -all " " "$filename" "\%20" filename
      if [string compare $filename ""] {
         set a_effectuer "exec \"$conf(editsite_htm)\" \"$filename\" &"
         if [catch $a_effectuer input] {
           # ::console::affiche_erreur "$caption(audace,console_rate)\n"
            set confgene(EditScript,error_htm) "0"
            ::confEditScript::run "$audace(base).confEditScript"
            set a_effectuer "exec \"$conf(editsite_htm)\" \"$filename\" &"
            if [catch $a_effectuer input] {
               set audace(current_edit) $input
            }
         } else {
            set audace(current_edit) $input
           # ::console::affiche_erreur "$caption(audace,console_gagne)\n"
         }
      } else {
        # ::console::affiche_erreur "$caption(audace,console_annule)\n"
      }
      menustate normal
   }

   #
   # ::audace::editSiteWebAudeLA
   # Connexion au site web d'AudeLA
   # Il faut avoir un navigateur web sur le micro
   #
   proc editSiteWebAudeLA { } {
      global audace

      #--- Fenetre parent
      set fenetre "$audace(base)"
      #--- Repertoire d'initialisation
      set rep_init [ file join $audace(rep_doc_html) web_site ]
      #--- Ouvre la fenetre de choix des pages html
      set filename [ ::tkutil::box_load_html $fenetre $rep_init $audace(bufNo) "1" ]
      #---
      if { $filename != "file:" } {
         ::audace::Lance_Site_htm "$filename"
      }
   }

   #
   # ::audace::editNotice_pdf
   # Edition d'une notice au format .pdf
   # Il faut avoir Acrobate Reader pour Windows ou son equivalent pour Linux sur le micro
   #
   proc editNotice_pdf { } {
      global audace

      #--- Fenetre parent
      set fenetre "$audace(base)"
      #--- Repertoire d'initialisation
      set rep_init $audace(rep_doc_pdf)
      #--- Ouvre la fenetre de choix des notices
      set filename [ ::tkutil::box_load $fenetre $rep_init $audace(bufNo) "4" ]
      #---
      ::audace::Lance_Notice_pdf $filename
   }

###################################################################################
# Procedures annexes des procedures ci-dessus
###################################################################################

   #
   # ::audace::Lance_Notice_pdf filename
   # Lance l'editeur de documents pdf
   #
   proc Lance_Notice_pdf { filename } {
      global audace caption conf confgene

      menustate disabled
      set confgene(EditScript,error_script) "1"
      set confgene(EditScript,error_pdf)    "1"
      set confgene(EditScript,error_htm)    "1"
      set confgene(EditScript,error_viewer) "1"
      set confgene(EditScript,error_java)   "1"
      set confgene(EditScript,error_iris)   "1"
      set confgene(EditScript,error_aladin) "1"
      if [string compare $filename ""] {
         set a_effectuer "exec \"$conf(editnotice_pdf)\" \"$filename\" &"
         if [catch $a_effectuer input] {
           # ::console::affiche_erreur "$caption(audace,console_rate)\n"
            set confgene(EditScript,error_pdf) "0"
            ::confEditScript::run "$audace(base).confEditScript"
            set a_effectuer "exec \"$conf(editnotice_pdf)\" \"$filename\" &"
            if [catch $a_effectuer input] {
               set audace(current_edit) $input
            }
         } else {
            set audace(current_edit) $input
           # ::console::affiche_erreur "$caption(audace,console_gagne)\n"
         }
      } else {
        # ::console::affiche_erreur "$caption(audace,console_annule)\n"
      }
      menustate normal
   }

}
############################# Fin du namespace audace #############################

