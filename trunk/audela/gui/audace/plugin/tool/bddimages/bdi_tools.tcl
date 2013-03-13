#--------------------------------------------------
# source /usr/local/src/audela/gui/audace/plugin/tool/bddimages/bdi_tools.tcl
#--------------------------------------------------
#
# Fichier        : bdi_tools.tcl
# Description    : Outils pour bddimages
# Auteur         : J. Berthier <berthier@imcce.fr> et F. Vachier <fv@imcce.fr>
# Mise à jour $Id: bdi_tools.tcl 6795 2011-02-26 16:05:27Z fredvachier $
#
namespace eval ::bdi_tools {
   package provide bdi_tools 1.0

   # #############################################################################
   # Declaration des attributs de l'espace de nom aoos
   # #############################################################################
   # @var string name-space du schema XML
   #variable xmlSchemaNs "http://www.w3.org/2001/XMLSchema-instance"


}

# #############################################################################
# Implementation des methodes de l'espace de nom aoos
# #############################################################################

#
# Verifie l'egalite entre deux dates exprimees au format ISO.
# @param $date1 string premiere date, format ISO
# @param $date2 string premiere date, format ISO
# @return true or false
#
proc ::bdi_tools::is_isodates_equal { date1 date2 } {
   
   if { [expr abs([mc_date2jd $date1] - [mc_date2jd $date2])*86400.0] <= 0.001 } {
      return 1
   } else {
      return 0
   }
   
}

#
# Converti un angle au format sexagesimal en decimal
# @param list $x angle sexagesimal au format {[+-]dd mm ss.s} ou {[+-]dd:mm:ss}
# @param float $f facteur multiplicatif pour exprimer un angle horaire en degres par exemple
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

#
# Fonction gunzip compatible multi OS
# @param $fname_in string nom complet du fichier a degziper /data/fi.fits.gz
# @param $fname_out string nom complet du fichier de sortie /data/fi.fits
# @return list composed of errnum and msgzip
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
         exec gunzip -c $fname_in > $fname_out
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

#
# Fonction gzip compatible multi OS
# @param $fname_in string nom complet du fichier a gziper /data/fi.fits
# @param $fname_out string nom complet du fichier de sortie /data/fi.fits.gz
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
         exec gzip -c $fname_in > $fname_out
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

#
# Sauve une chaine de caracteres dans un fichier dont le nom est fourni par l'utilisateur
# @param $str string chaine de caracteres a enregistrer
# @param $ftype string type de fichier: TXT, DAT, XML, ...
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


