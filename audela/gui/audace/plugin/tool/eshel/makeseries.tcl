#
# Fichier : eshel.tcl
# Description : fenetre saisie des mots clefs
# Auteurs : Michel Pujol
# Mise a jour $Id: makeseries.tcl,v 1.1 2009-11-07 08:13:07 michelpujol Exp $
#

################################################################
# namespace ::eshel::makeseries
#  fenetre saisie des mots clefs
################################################################

namespace eval ::eshel::makeseries {
   variable private

}

#------------------------------------------------------------
# ::eshel::process::run
#    affiche la fenetre du traitement
# return
#   1 si la saisie est validee
#   0 si la saisie est abandonne
#------------------------------------------------------------
proc ::eshel::makeseries::run { tkbase visuNo tkTable fileIndexes } {
   variable private

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists ::conf(eshel,makeSeriesPosition) ] } { set ::conf(eshel,makeSeriesPosition)     "650x240+100+15" }

   set private(mandatoryKeywords) [::eshel::process::getFileAttributeNames]
   #--- liste des motcls affiches = mots cles obligatoires + mots cles facultatifs
   set keywordList $private(mandatoryKeywords)
   lappend keywordList "OBSERVER"
   lappend keywordList "CONFNAME"


   set private(tkTable) $tkTable
   set private(fileIndexes) $fileIndexes


   foreach keywordName $keywordList {
      set private(values,$keywordName) ""
      set private(selected,$keywordName) ""
   }

   set private(apply) ""

   #--- j'affiche la fenetre
   set private($visuNo,This) "$tkbase.makeseries"
   set result [::confGenerique::run $visuNo $private($visuNo,This) "::eshel::makeseries" \
      -modal 1 -geometry $::conf(eshel,makeSeriesPosition) -resizable 1 ]

   if { $private(apply) == "ok" } {
     return 1
   } else {
     return 0
   }

}

#------------------------------------------------------------
# ::eshel::makeseries::getLabel
#   retourne le titre de la fenetre
#------------------------------------------------------------
proc ::eshel::makeseries::getLabel { } {
   global caption

   return "$caption(eshel,title) - $::caption(eshel,process,makeSerie)"
}


#------------------------------------------------------------
# config::apply
#   enregistre la valeur des widgets
#------------------------------------------------------------
proc ::eshel::makeseries::apply { visuNo } {
   variable private

   #--- je controle les valeurs de mots clefs obligatoires (mandatoryKeywords)
   set badKeywords ""
   foreach keywordName $private(mandatoryKeywords) {
      switch $keywordName {
         DATE-OBS {
            #--- je ne controle pas DATE-OBS
         }
         SITENAME {
            #--- je ne controle pas SITENAME
         }
         OBSERVER {
            #--- je ne controle pas DATE-OBS
         }
         OBJNAME {
            #--- ce mot clef est obligatoire si IMAGETYP=OBJECT
            set keywordValue $private(selected,$keywordName)
            if { $private(selected,IMAGETYP) == "OBJECT" && $keywordValue == "" } {
               lappend badKeywords $keywordName
            }
         }
         default {
            #--- je verifie que la valeur n'est pas nulle
            set keywordValue $private(selected,$keywordName)
            if { $keywordValue == "" } {
               lappend badKeywords $keywordName
            }
         }
      }
   }

   if { $badKeywords != "" } {
      tk_messageBox -message  "$::caption(eshel,process,nullKeyword) : $badKeywords" -icon error -title $::caption(eshel,title)
      set private(apply) "error"
      #--- j'arrete le traitement et retourne 0 pour empecher la fermeture de la fenetre
      return 0
   }

   #--- je copie les mots clefs dans la table
   foreach fileIndex $private(fileIndexes)  {
      foreach keywordName $private(mandatoryKeywords) {
         switch $keywordName {
            DATE-OBS {
               #--- on ne modifie pas DATE-OBS car elle est propre a chaque

            }
            default {
               set keywordValue $private(selected,$keywordName)
               $private(tkTable) cellconfigure $fileIndex,$keywordName -text $keywordValue
            }
         }
      }
   }

   set private(apply) "ok"
}


#------------------------------------------------------------
# config::closeWindow
#   controle les valeurs de mots clefs
#   si un mot clefs n'est pas correctement rempli
#      affiche un message d'erreur s
#      et interrompt la fermeture de la fenetre
#   si tous les mots clefs sont corrects
#      ferme la fenetre
# return
#   0  s'il ne fait pas fermer la fenetre
#   rien s'il faut fermer la feenetre
#------------------------------------------------------------
proc ::eshel::makeseries::closeWindow { visuNo } {
   variable private

   if { $private(apply) == "error" } {
      #--- il reste une erreur
      set private(applyResult) ""
      return 0
   }

   #--- je memorise la position courante de la fenetre
   set ::conf(eshel,makeSeriesPosition) [ wm geometry $private($visuNo,This) ]

   #--- on peut fermer la fenetre
   return 1
}

#------------------------------------------------------------
# config::fillConfigPage
#   cree les widgets de la fenetre de configuration
#   return rien
#------------------------------------------------------------
proc ::eshel::makeseries::fillConfigPage { frm visuNo } {
   variable private

   #--- premiere passe pour recenser les valeurs existantes
   foreach fileIndex $private(fileIndexes)  {
      foreach keywordName $private(mandatoryKeywords) {
         set keywordValue [$private(tkTable) cellcget $fileIndex,$keywordName -text]
         switch $keywordName {
            ###DATE-OBS {
            ###   $private(values,$keywordName)
            ###   #--- j'utilise DATE-OBS comme identifiant de la série
            ###   if { $private(selected,SERIESID) == "" } {
            ###      #--- je prends la premiere valeur de DATE-OBS rencontree
            ###      set private(selected,SERIESID) $keywordValue
            ###   } else {
            ###      if { [string compare $keywordValue $private(selected,SERIESID)] < 0 } {
            ###         #--- si elle est plus petite que celle rencontre dans un autre fichier
            ###         set private(selected,SERIESID) $keywordValue
            ###      }
            ###   }
            ###}
            DATE-OBS {
               if { $keywordValue != "" } {
                  if { [lsearch $private(values,SERIESID) $keywordValue] == -1  }  {
                     lappend private(values,SERIESID) $keywordValue
                  }
               }
            }
            default {
               if { $keywordValue != "" } {
                  if { [lsearch $private(values,$keywordName) $keywordValue] == -1  }  {
                     lappend private(values,$keywordName) $keywordValue
                  }
               }
            }
         }
      }
   }

   #--- j'affiche les valeurs dans les combobox
   Label $frm.title -text $::caption(eshel,process,keywordValues)  -justify left
   grid $frm.title -in $frm -row 0 -column 0 -columnspan 3 -sticky w
   set row 1
   foreach keywordName $private(mandatoryKeywords) {
      if { $keywordName == "DATE-OBS" } {
         #--- je n'affiche pas DATE-OBS
         continue
      }
      #--- je cree la combobox avec les valeurs du mots clefs
      ComboBox $frm.combo$keywordName \
         -height [ llength $private(values,$keywordName) ] \
         -relief sunken -borderwidth 1 -editable 1 \
         -textvariable ::eshel::makeseries::private(selected,$keywordName) \
         -values [lsort -dictionary $private(values,$keywordName)]
      $frm.combo$keywordName setvalue "@0"
      Label $frm.color_invariant_$keywordName -text "$keywordName ([llength $private(values,$keywordName)] valeurs)"  -justify left
      if { [string trim $private(values,$keywordName)] == "" } {
         if { $keywordName == "SITENAME" || $keywordName == "OBSERVER" \
          || ($keywordName == "OBJNAME" && [lindex $private(values,IMAGETYP) 0] != "OBJECT")  } {
            #--- j'affiche en bleu les mots clefs optionele manquants
            $frm.color_invariant_$keywordName configure -fg blue
         } else {
            #--- j'affiche en rouge les mots clefs obligatories manquants
            $frm.color_invariant_$keywordName configure -fg red
         }
      }
      grid $frm.color_invariant_$keywordName -in $frm -row $row -column 0 -sticky nw
      grid $frm.combo$keywordName -in $frm -row $row -column 1 -sticky nw

      #--- ajoute un bouton les mots clefs qui possedent une valeur par defaut dans la configuration instrument
      switch $keywordName {
         INSTRUME -
         TELESCOP -
         DETNAM {
            Button $frm.button$keywordName -text "current instrument" \
               -command "::eshel::makeseries::getCurrentInstrumentValue $visuNo $keywordName"
            grid $frm.button$keywordName -in $frm -row $row -column 2  -sticky nw
         }
      }
      grid columnconfig $frm $row -weight 1
      incr row
   }
   grid rowconfig $frm 0 -weight 0
   grid rowconfig $frm 1 -weight 0
   grid rowconfig $frm 2 -weight 0
}

#------------------------------------------------------------
# getCurrentInstrumentValue
#   recupere la valeur de la configuration instrument courante
#   return rien
#------------------------------------------------------------
proc ::eshel::makeseries::getCurrentInstrumentValue { visuNo keywordName } {
   variable private

   switch $keywordName {
      DETNAM {
         set private(selected,DETNAM)  $::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),cameraName)
      }
      INSTRUME {
         set private(selected,INSTRUME)  $::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),spectroName)
      }
      TELESCOP {
         set private(selected,TELESCOP)  $::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),telescopeName)
      }
   }

}

