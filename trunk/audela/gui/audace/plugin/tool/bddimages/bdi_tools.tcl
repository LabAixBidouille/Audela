## @file bdi_tools.tcl
#  @brief     Definitions d'outils pour bddimages
#  @details   This class is used to demonstrate a number of section commands.
#  @author    Jerome Berthier and Frederic Vachier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource 
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools.tcl]
#  @endcode

# Mise à jour $Id: bdi_tools.tcl 9239 2013-03-24 02:12:05Z jberthier $

#============================================================
## Declaration du namespace \c bdi_tools .
#  @brief     Outils generaux pour bddimages
#  @warning   Pour developpeur seulement
namespace eval bdi_tools {
   package provide bdi_tools 1.0

   # #############################################################################
   # Declaration des sous-classes
   # #############################################################################

   #------------------------------------------------------------
   ## Declaration du namespace \c bdi_tools::sendmail .
   # @brief     Mecanismes d'envoie d'emails 
   # @warning   Pour developpeur seulement
   namespace eval sendmail {

      # @var string Nom de la commande d'execution de Thhunderbird (fullpath name)
      variable thunderbird "/usr/bin/thunderbird"

      #------------------------------------------------------------
      ## Ouvre la fenetre de composition de Thunderbird avec les champs pre-remplis
      # @param to string Destinataire du message
      # @param subject string Sujet du message
      # @param body string Message a envoyer
      # @return Code d'erreur (0 si pas d'erreur)
      proc compose_with_thunderbird { to subject body } {

         global audace

         # Enregistre le corps du mail dans un fichier temporaire
         set tempfile [file join $audace(rep_travail) "mail2horizons.txt"]
         set chan0 [open $tempfile w]
         puts $chan0 "$body"
         close $chan0

         # Ouvre la fenetre de mailto de Thunderbird
         set err [catch {exec $::bdi_tools::sendmail::thunderbird -compose "to='$to',subject='$subject',body='$body'"} msg]
         if {$err != 0} {
            gren_erreur "ERROR: unable to launch thunderbird ($msg)"
         }
         return $err

      }

      proc send { } {
         
         set someone "fv@imcce.fr"
         set recipient_list "fv@imcce.fr"
         set cc_list ""
         set subject "BATCH"
         set body    "body"
         
         set msg {From: someone}
         append msg \n "To: " [join $recipient_list ,]
         append msg \n "Cc: " [join $cc_list ,]
         append msg \n "Subject: $subject"
         append msg \n\n $body
         gren_info "$msg\n"
         exec /usr/lib/sendmail -oi -t << $msg
      }

      proc send2 { } {

         set gren(email,originator) "Test"
         set adresse  fv@imcce.fr 
         set gren(email,email_server) smtp.free.fr
         set email_subject "sujet test"
         set texte00 "Bonjour. Fais-moi un reply que c'est OK."
         ::gui_astrometry::send_simple_message $gren(email,originator) $adresse $gren(email,email_server) "$email_subject" "$texte00"

      }

      proc simple_message {originator recipient email_server subject body} {

          package require smtp
          package require mime
          gren_info "ici\n"
          set token [mime::initialize -canonical text/plain -string $body]
          gren_info "la\n"
          smtp::sendmessage $token -servers $email_server -header [list From "$originator"] -header [list To "$recipient"] -header [list Subject "$subject"] -header [list cc ""]  -header [list Bcc ""]
          #smtp::sendmessage $token -header [list From "$originator"] -header [list To "$recipient"] -header [list Subject "$subject"] -header [list cc ""]  -header [list Bcc ""]
          gren_info "ici\n"
          mime::finalize $token
          gren_info "la\n"

      }

   }

}

# #############################################################################
# Implementation des methodes de l'espace de nom aoos
# #############################################################################

#------------------------------------------------------------
## Verifie l'egalite entre deux dates exprimees au format ISO.
# @param date1 string Premiere date au format ISO
# @param date2 string Deuxieme date au format ISO
# @return true or false
#
proc ::bdi_tools::is_isodates_equal { date1 date2 } {
   
   if { [expr abs([mc_date2jd $date1] - [mc_date2jd $date2])*86400.0] <= 0.001 } {
      return 1
   } else {
      return 0
   }
   
}

#------------------------------------------------------------
## Converti un angle sexagesimal en decimal
# @param x list Angle sexagesimal au format {[+-]dd mm ss.s} ou {[+-]dd:mm:ss}
# @param f float Facteur multiplicatif pour exprimer un angle horaire en degres par exemple
# @return float angle decimal
#
proc ::bdi_tools::sexa2dec { x {f "1"} } {

   # Si la liste x a un element alors
   if {[llength $x] == 1} {
      # si c'est deja une valeur decimale
      if {[string is double [lindex $x 0]]} {
         return $x
      } else {
         # sinon on enleve les ":" et reconstruit une liste
         set x [string map {":" " "} [lindex $x 0]]
         set x [split $x " "]
      }
   }

   set x1 [string map {"-0" "-" "+0" "+"} [lindex $x 0]]
   set x2 [lindex $x 1]
   set x3 [lindex $x 2]

   set sgn 1
   if {$x1 < 0 } { set sgn -1 }

   return [expr $f * $sgn*(abs($x1) + $x2 / 60.0 + $x3 / 3600.0)]

}

#------------------------------------------------------------
## Fonction gunzip compatible multi OS
# @param fname_in string Nom complet du fichier a degziper /data/fi.fits.gz
# @param fname_out string Nom complet du fichier de sortie /data/fi.fits
# @return liste composee of errnum and msgzip
#
proc ::bdi_tools::gunzip { fname_in {fname_out ""} } {
   set ext [file extension $fname_in]
   if {$ext!=".gz"} {
      set fname_in ${fname_in}.gz
   }
   set ext [file extension $fname_out]
   if {$ext==".gz"} {
      set fname_out [file rootname $fname_out]
   }
   if {$fname_out==""} {
      set fname_out [file rootname $fname_in]
   }
   file delete -force -- $fname_out
   if { $::tcl_platform(os) == "Linux" } {
      set errnum [catch {
         eval exec gunzip -c $fname_in > $fname_out
      } msgzip ]
   } else {
      set errnum [catch {
         if {$fname_in!="${fname_out}.gz"} {
            file copy -force -- "$fname_in" "${fname_out}.gz"
            ::gunzip ${fname_out}.gz
         } else {
            ::gunzip "$fname_in"
         }
      } msgzip ]
   }
   return [list $errnum $msgzip]
}

#------------------------------------------------------------
## Fonction gzip compatible multi OS
# @param fname_in string nom complet du fichier a gziper /data/fi.fits
# @param fname_out string nom complet du fichier de sortie /data/fi.fits.gz
# @return list composed of errnum and msgzip
#
proc ::bdi_tools::gzip { fname_in {fname_out ""} } {
   set ext [file extension $fname_in]
   if {$ext == ".gz"} {
      set fname_in [file rootname $fname_in]
   }
   set ext [file extension $fname_out]
   if {$ext != ".gz"} {
      set fname_out ${fname_out}.gz
   }
   # Force l'effacement du fichier out
   if {$fname_out == ""} {
      set fname_out0 ${fname_in}.gz
   } else {
      set fname_out0 $fname_out
   }
   file delete -force -- $fname_out0
   # Zip le fichier
   if { $::tcl_platform(os) == "Linux" } {
      set errnum [catch {
         eval exec gzip -c $fname_in > $fname_out
      } msgzip ]
   } else {
      set errnum [catch {
         if {$fname_out!="${fname_in}.gz"} {
            file copy -force -- "$fname_in" "[file rootname $fname_out]"
         }
         ::gzip "[file rootname $fname_out]"
      } msgzip ]
   }
   return [list $errnum $msgzip]
}

#------------------------------------------------------------
## Recupere une source donnee dans une liste de sources
# @param send_sources list Liste des sources
# @param name string Nom de la source
# @return Code d'erreur (0) et source recherchee
#
proc ::bdi_tools::get_sources { send_sources name } {

      upvar $send_sources sources

      foreach s $sources {
         set cata [::manage_source::name_cata $name]
         set sourcename [::manage_source::naming $s $cata]
         if {$sourcename == $name} {
            return -code 0 $s
         }
      }
      return -code 1 "" 
}

#------------------------------------------------------------
## Recupere une source ASTROID donnee pour une date donnee dans une liste de sources
# @param dateobs date-obs Date consideree (format ISO)
# @param name string Nom de la source ASTROID
# @return Code d'erreur (0) et source recherchee
#
proc ::bdi_tools::get_astroid { dateobs name } {

   set pass "no"
   set id_current_image 0
   foreach current_image $::tools_cata::img_list {
      incr id_current_image
      set tabkey [::bddimages_liste::lget $current_image "tabkey"]
      set datei  [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]
      if {$datei == $dateobs} {
         set pass "ok"
         break
      }
   }
   
   if {$pass == "no"} {
      return -code 1 "No Date"
   }
   
   set astroid ""
   set sources [lindex $::gui_cata::cata_list($id_current_image) 1]
   set err [ catch { set s [::bdi_tools::get_sources sources $name] } msg ]
   if {$err} {
      return -code 2 "No Sources ($msg)"
   }
   
   set pos [lsearch -index 0 $s "ASTROID"]
   if {$pos != -1} {
      set astroid [lindex $s [list $pos 2]]
      return $astroid
   }

   return -code 3 "No ASTROID"

}

#------------------------------------------------------------
## Sauve une chaine de caracteres dans un fichier dont le nom est fourni par l'utilisateur
# @param str string chaine de caracteres a enregistrer
# @param ftype string type de fichier: TXT, DAT, XML, ...
# @return string le nom du fichier sauve
#
proc ::bdi_tools::save_as { str ftype } {

   switch [string toupper $ftype] {
      TXT {
         set filetype { {{Text Files} {.txt}} {{All Files} * } }
      }
      DAT {
         set filetype { {{Data Files} {.dat}} {{All Files} * } }
      }
      XML {
         set filetype { {{XML Files} {.xml}} {{All Files} * } }
      }
      default {
         set filetype "{ {{All Files} * } }"
      }
   }

   set fileName [tk_getSaveFile -title "Save As" -filetypes $filetype]

   if { $fileName != "" } {
      set chan0 [open $fileName w]
      puts $chan0 $str
      close $chan0
   }

   return $fileName
}
