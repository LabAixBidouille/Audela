#
# Fichier : eshelfile.tcl
# Description : assistant pour le reglage des parametres de traitement
# Auteur : Michel PUJOL
# Mise à jour $Id$
#

################################################################
# namespace ::eshel::file
#
################################################################

namespace eval ::eshel::file {

}

#------------------------------------------------------------
# ::eshel::process::run
#    affiche la fenetre du traitement
#
#------------------------------------------------------------
proc ::eshel::file::isLED { fileName } {
   variable private


}

##------------------------------------------------------------
# retourne la valeur d'un mot clef
#
# @param   hFile          handle du fichier fitd
# @param   keywordName    nom du mot clef
#
# @return valeur du mot clef
# @private
#------------------------------------------------------------
proc ::eshel::file::getKeyword { hFile keywordName} {
   variable private

   #--- je recupere les mots clefs dans le nom contient la valeur keywordName
   #--- cette fonction retourne une liste de triplets { name value description }

   set catchResult [ catch {
      set keywords [$hFile get keyword $keywordName]
   }]
   if { $catchResult !=0 } {
      #--- je transmets l'erreur en ajoutant le nom du mot clé
      error "keyword $keywordName not found\n$::errorInfo"
   }

   #--- je cherche le mot cle qui a exactement le nom requis
   foreach keyword $keywords {
      set name [lindex $keyword 0]
      set value [lindex $keyword 1]
      if { $name == $keywordName } {
         #--- je supprime les apostrophes et les espaces qui entourent la valeur
         set value [string trim [string map {"'" ""} [lindex $keyword 1] ]]
         break
      }
   }
   if { $name != $keywordName } {
      #--- je retourne une erreur si le mot clef n'est pas trouve
      error "keyword $keywordName not found"
   }
   return $value
}


proc ::eshel::file::findMargin { ledFileName } {

   set result [eshel_findMargin  $ledFileName \
         $::conf(eshel,tempDirectory)/led_wizard.fit" \
         $width $height  \
         $threshold $snNoise \
         $minOrder $maxOrder ]
      console::disp "eshel_findMargin: $result\n"

}

