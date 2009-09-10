#
# Fichier : convert.tcl
# Description : Conversion d'images FITS au format BMP, EMF, PS, ICO, JPEG/JPG, PDF, PNG, PSD ou TIFF
# Auteur : Raymond ZACHANTKE
# Mise a jour $Id: convert.tcl,v 1.1 2009-09-10 22:19:12 robertdelmas Exp $
#

#============================================================
# Declaration du namespace convert
#    initialise le namespace
#============================================================
namespace eval ::convert {
   package provide convert 1.0
   package require audela 1.5.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] convert.cap ]
}

#------------------------------------------------------------
# getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::convert::getPluginTitle { } {
   global caption

   return "$caption(convert,menu)"
}

#------------------------------------------------------------
# getPluginHelp
#    retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::convert::getPluginHelp { } {
   return "convert.htm"
}

#------------------------------------------------------------
# getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::convert::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# getPluginDirectory
#    retourne le type de plugin
#------------------------------------------------------------
proc ::convert::getPluginDirectory { } {
   return "convert"
}

#------------------------------------------------------------
# getPluginOS
#    retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::convert::getPluginOS { } {
   return [ list Windows ]
}

#------------------------------------------------------------
# getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::convert::getPluginProperty { propertyName } {
   switch $propertyName {
         menu         { return "file" }
         function     { return "convert" }
         subfunction1 { return "" }
         display      { return "window" }
   }
}

#------------------------------------------------------------
# initPlugin
#    initialise le plugin
#------------------------------------------------------------
proc ::convert::initPlugin { tkbase } {
   variable private

   #--- Liste des extensions utilisables
   set private(liste_extension) [list ".bmp" ".emf" ".ps" ".ico" ".jpg" ".pdf" ".png" ".psd" ".tif" ]

   #--- Liste des commentaires pour les extensions utilisables
   set private(commentaires) [list "Windows Bitmap" "Windows Enhanced Metafile" "Postscript" \
      "Windows Icon" "JPEG/JPG" "Portable Document Format" "Portable Network Graphics" \
      "Adobe Photoshop" "Tiff rev. 6" ]

   #--- Liste des types a entrer dans nconvert pour les extensions utilisables
   set private(liste_type) [ list bmp emf ps ico jpeg pdf png psd tiff wmf ]

   #--- Liste de listes pour afficher les formats dans la boite de dialogue
   foreach private(extension) $private(liste_extension) com $private(commentaires) {
      lappend private(affiche_format) [ concat [ list $com ] \{ $private(extension) \} ]
   }
}

#------------------------------------------------------------
# createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::convert::createPluginInstance { { in "" } { visuNo 1 } } {

}

#------------------------------------------------------------
# deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::convert::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
# startTool
#    affiche la fenetre de l'outil
#------------------------------------------------------------
proc ::convert::startTool { visuNo } {
   #--- J'ouvre la fenetre de conversion
   ::convert::run
}

#------------------------------------------------------------
# stopTool
#    masque la fenetre de l'outil
#------------------------------------------------------------
proc ::convert::stopTool { visuNo } {
   #--- Rien a faire, car la fenetre est fermee par l'utilisateur
}

#------------------------------------------------------------
# run
#    cree la fenetre de conversion de l'image FITS
#------------------------------------------------------------
proc ::convert::run { } {
   variable private

   #--- Numero du buffer de la visu principale
   set bufNo [ visu$::audace(visuNo) buf ]

   #--- Sort immediatement s'il n'y a pas d'image dans le buffer
   if { [ buf$bufNo imageready ] == "0" } {
      return
   }

   #--- Capture le nom de l'image affichee
   set private(in) [ ::confVisu::getFileName $::audace(visuNo) ]

   #--- Rustine si l'image a ete enregistree sans extension
   if { [ file extension $private(in) ] == "" } { append private(in) "$::conf(extension,defaut)" }

   #--- Capture les infos utilisateurs
   set private(out) [ tk_getSaveFile \
      -defaultextension "$::conf(extension,defaut)" \
      -filetypes        "$private(affiche_format)" \
      -initialdir       "$::audace(rep_images)" \
      -initialfile      [ file rootname [ file tail $private(in) ] ] \
      -title            "$::caption(convert,titre)"
   ]

   #--- Definit les variables necessaires
   set private(in)        [ file join $::audace(rep_images) $private(in) ]
   set private(out)       [ file join $::audace(rep_images) $private(out) ]
   set private(extension) [ file extension $private(out) ]

   #--- Conversion de l'image FITS
   if { $private(extension) != "$::conf(extension,defaut)" } {
      #--- Initialise le chemin du programme de conversion
      set private(program) [ file join $::audace(rep_plugin) tool convert nconvert.exe ]

      #--- Cherche le code pour nconvert
      set i [ lsearch -exact $private(liste_extension) $private(extension) ]
      set type [ lindex $private(liste_type) $i ]

      #--- Execute la conversion
      catch { exec $private(program) -in -1 -o $private(out) -out $type -ctype rgb $private(in) } msg

      #--- Si le message ne contient pas 'OK'
      if { [ string first "OK" $msg ] == "-1" } {
         #--- Affiche le message d'erreur de nconvert
         tk_messageBox -title "$::caption(convert,erreur)" -icon error -type ok -message $msg
      }

      #--- Aud'Ace ne peut charger que les images jpeg
      if { $type == "jpeg" } {
         loadima $private(out)
      }
   }
}

