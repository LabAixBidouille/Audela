#
# Fichier : tkutil.tcl
# Description : Regroupement d'utilitaires
# Auteur : Robert DELMAS
# Mise a jour $Id: tkutil.tcl,v 1.31 2010-01-24 15:19:54 michelpujol Exp $
#

namespace eval tkutil:: {
   #--- Chargement des captions
   source [ file join $::audace(rep_caption) tkutil.cap ]
}

#
# getOpenFileType
#    Gere les differentes extensions des fichiers images, ainsi que le cas ou l'extension
#    des fichiers FITS est differente de .fit
#
proc ::tkutil::getOpenFileType { } {
   variable openFileType

   #---
   set openFileType [ list ]
   #---
   if { ( $::conf(extension,defaut) != ".fit" ) && ( $::conf(extension,defaut) != ".fts" ) &&
      ( $::conf(extension,defaut) != ".fits" ) } {
      lappend openFileType \
         [ list "$::caption(tkutil,image_file)" $::conf(extension,defaut) ] \
         [ list "$::caption(tkutil,image_file)" $::conf(extension,defaut).gz ] \
         [ list "$::caption(tkutil,image_fits)" $::conf(extension,defaut) ] \
         [ list "$::caption(tkutil,image_fits)" $::conf(extension,defaut).gz ]
   }

   #---
   lappend openFileType \
      [ list "$::caption(tkutil,image_file)"       {.fit}                ] \
      [ list "$::caption(tkutil,image_file)"       {.fit.gz}             ] \
      [ list "$::caption(tkutil,image_file)"       {.fts}                ] \
      [ list "$::caption(tkutil,image_file)"       {.fts.gz}             ] \
      [ list "$::caption(tkutil,image_file)"       {.fits}               ] \
      [ list "$::caption(tkutil,image_file)"       {.fits.gz}            ] \
      [ list "$::caption(tkutil,image_file)"       {.crw .cr2 .nef .dng} ] \
      [ list "$::caption(tkutil,image_file)"       {.CRW .CR2 .NEF .DNG} ] \
      [ list "$::caption(tkutil,image_file)"       {.jpeg .jpg}          ] \
      [ list "$::caption(tkutil,image_file)"       {.bmp}                ] \
      [ list "$::caption(tkutil,image_file)"       {.gif}                ] \
      [ list "$::caption(tkutil,image_file)"       {.png}                ] \
      [ list "$::caption(tkutil,image_file)"       {.tiff .tif}          ] \
      [ list "$::caption(tkutil,image_fits)"       {.fit}                ] \
      [ list "$::caption(tkutil,image_fits)"       {.fit.gz}             ] \
      [ list "$::caption(tkutil,image_fits)"       {.fts}                ] \
      [ list "$::caption(tkutil,image_fits)"       {.fts.gz}             ] \
      [ list "$::caption(tkutil,image_fits)"       {.fits}               ] \
      [ list "$::caption(tkutil,image_fits)"       {.fits.gz}            ] \
      [ list "$::caption(tkutil,image_raw)"        {.crw .cr2 .nef .dng} ] \
      [ list "$::caption(tkutil,image_raw)"        {.CRW .CR2 .NEF .DNG} ] \
      [ list "$::caption(tkutil,image_jpeg)"       {.jpeg .jpg}          ] \
      [ list "$::caption(tkutil,image_bmp)"        {.bmp}                ] \
      [ list "$::caption(tkutil,image_gif)"        {.gif}                ] \
      [ list "$::caption(tkutil,image_png)"        {.png}                ] \
      [ list "$::caption(tkutil,image_tiff)"       {.tiff .tif}          ] \
      [ list "$::caption(tkutil,image_jpeg)"       {}      JPEG          ] \
      [ list "$::caption(tkutil,image_gif)"        {}      GIFF          ] \
      [ list "$::caption(tkutil,image_png)"        {}      PNGF          ] \
      [ list "$::caption(tkutil,image_tiff)"       {}      TIFF          ] \
      [ list "$::caption(tkutil,fichier_tous)"     *                     ]
}

#
# box_load parent initialdir numero_buffer type
#    Ouvre la fenetre de selection des fichiers a proposer au chargement (hors fichiers html)
#
proc ::tkutil::box_load { { parent } { initialdir } { numero_buffer } { type } { visuNo "1" } } {
   variable openFileType

   #--- Ouvre la fenetre de choix des fichiers
   if { $type == "1" } {
      set title "$::caption(tkutil,charger_image) (visu$visuNo)"
      ::tkutil::getOpenFileType
      set filetypes "$openFileType"
   } elseif { $type == "2" } {
      set title "$::caption(tkutil,editer_script)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_tcl)" ".tcl" ] \
         [ list "$::caption(tkutil,fichier_txt)" ".txt" ] [ list "$::caption(tkutil,fichier_tous)" "*" ] ]
   } elseif { $type == "3" } {
      set title "$::caption(tkutil,lancer_script)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_tcl)" ".tcl" ] ]
   } elseif { $type == "4" } {
      set title "$::caption(tkutil,editer_notice)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_pdf)" ".pdf" ] ]
   } elseif { $type == "5" } {
      set title "$::caption(tkutil,editer_catalogue)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_txt)" ".txt" ] ]
   } elseif { $type == "6" } {
      set title "$::caption(tkutil,editeur_script)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_tous)" "*" ] ]
   } elseif { $type == "7" } {
      set title "$::caption(tkutil,editeur_pdf)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_tous)" "*" ] ]
   } elseif { $type == "8" } {
      set title "$::caption(tkutil,editeur_page_web)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_tous)" "*" ] ]
   } elseif { $type == "9" } {
      set title "$::caption(tkutil,editeur_image)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_tous)" "*" ] ]
   } elseif { $type == "10" } {
      set title "$::caption(tkutil,editer_modpoi)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_txt)" ".txt" ] ]
   } elseif { $type == "11" } {
      set title "$::caption(tkutil,editer_fichier)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_txt)" "*" ] ]
   } elseif { $type == "12" } {
      set title "$::caption(tkutil,executable_java)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_tous)" "*" ] ]
   } elseif { $type == "13" } {
      set title "$::caption(tkutil,executable_aladin)"
      if { $::tcl_platform(os) == "Linux" } {
         set filetypes [ list [ list "$::caption(tkutil,fichier_jar)" ".jar" ] ]
      } else {
         set filetypes [ list [ list "$::caption(tkutil,fichier_tous)" "*" ] ]
      }
   }
   set filename [ tk_getOpenFile -title $title -filetypes $filetypes -initialdir $initialdir -parent $parent ]
   #---
   catch {
      #--- Je detruis la boite de dialogue cree par tk_getOpenFile
      #--- car sous Linux la fenetre n'est pas detruite a la fin de
      #--- l'utilisation (bug de linux ?)
      destroy $parent.__tk_filedialog
   }
   #---
   return $filename
}

#
# box_load_html parent initialdir numero_buffer type
#    Ouvre la fenetre de selection des fichiers html a proposer au chargement
#
proc ::tkutil::box_load_html { { parent } { initialdir } { numero_buffer } { type } } {
   #--- Ouvre la fenetre de choix des fichiers
   if { $type == "1" } {
      set title "$::caption(tkutil,editer_site_web)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_html)" ".htm" ] ]
   }
   set filename [ file join file:///[ tk_getOpenFile -title $title \
      -filetypes $filetypes -initialdir $initialdir -parent $parent ] ]
   #---
   catch {
      #--- Je detruis la boite de dialogue cree par tk_getOpenFile
      #--- car sous Linux la fenetre n'est pas detruite a la fin de
      #--- l'utilisation (bug de linux ?)
      destroy $parent.__tk_filedialog
   }
   #---
   return $filename
}

#
# getSavefiletype
#    Gere les differentes extensions des fichiers images, ainsi que le cas ou l'extension
#    des fichiers FITS est differente de .fit, de .fts et de .fits
#
proc ::tkutil::getSaveFileType { } {
   variable saveFileType

   #---
   set saveFileType [ list ]
   #---
   if { ( $::conf(extension,defaut) != ".fit" ) && ( $::conf(extension,defaut) != ".fts" ) &&
      ( $::conf(extension,defaut) != ".fits" ) && ( $::conf(extension,defaut) != ".crw" ) &&
      ( $::conf(extension,defaut) != ".CRW" ) && ( $::conf(extension,defaut) != ".cr2" ) &&
      ( $::conf(extension,defaut) != ".CR2" ) && ( $::conf(extension,defaut) != ".nef" ) &&
      ( $::conf(extension,defaut) != ".NEF" ) && ( $::conf(extension,defaut) != ".dng" ) &&
      ( $::conf(extension,defaut) != ".DNG" ) } {
      set x [ list "$::caption(tkutil,image_fits)"    $::conf(extension,defaut) ]
      set y [ list "$::caption(tkutil,image_fits) gz" $::conf(extension,defaut).gz ]
   }

   #---
   set a [ list "$::caption(tkutil,image_fits) "  {.fit}     ]
   set b [ list "$::caption(tkutil,image_fits) 1" {.fit.gz}  ]
   set c [ list "$::caption(tkutil,image_fits) 2" {.fts}     ]
   set d [ list "$::caption(tkutil,image_fits) 3" {.fts.gz}  ]
   set e [ list "$::caption(tkutil,image_fits) 4" {.fits}    ]
   set f [ list "$::caption(tkutil,image_fits) 5" {.fits.gz} ]
   set g [ list "$::caption(tkutil,image_raw) "   {.crw}     ]
   set h [ list "$::caption(tkutil,image_raw) 1"  {.CRW}     ]
   set i [ list "$::caption(tkutil,image_raw) 2"  {.cr2}     ]
   set j [ list "$::caption(tkutil,image_raw) 3"  {.CR2}     ]
   set k [ list "$::caption(tkutil,image_raw) 4"  {.nef}     ]
   set l [ list "$::caption(tkutil,image_raw) 5"  {.NEF}     ]
   set m [ list "$::caption(tkutil,image_raw) 6"  {.dng}     ]
   set n [ list "$::caption(tkutil,image_raw) 7"  {.DNG}     ]
   set o [ list "$::caption(tkutil,image_jpeg)"   {.jpg}     ]
   set p [ list "$::caption(tkutil,image_bmp)"    {.bmp}     ]
   set q [ list "$::caption(tkutil,image_png)"    {.png}     ]
   set r [ list "$::caption(tkutil,image_tiff)"   {.tif}     ]

   if { $::conf(extension,defaut) == ".fit" } {
      if { $::conf(fichier,compres) == "0" } {
         lappend saveFileType $a $b $c $d $e $f $g $h $i $j $k $l $m $n $o $p $q $r
      } elseif { $::conf(fichier,compres) == "1" } {
         lappend saveFileType $b $a $c $d $e $f $g $h $i $j $k $l $m $n $o $p $q $r
      }
   } elseif { $::conf(extension,defaut) == ".fts" } {
      if { $::conf(fichier,compres) == "0" } {
         lappend saveFileType $c $d $a $b $e $f $g $h $i $j $k $l $m $n $o $p $q $r
      } elseif { $::conf(fichier,compres) == "1" } {
         lappend saveFileType $d $c $a $b $e $f $g $h $i $j $k $l $m $n $o $p $q $r
      }
   } elseif { $::conf(extension,defaut) == ".fits" } {
      if { $::conf(fichier,compres) == "0" } {
         lappend saveFileType $e $f $a $b $c $d $g $h $i $j $k $l $m $n $o $p $q $r
      } elseif { $::conf(fichier,compres) == "1" } {
         lappend saveFileType $f $e $a $b $c $d $g $h $i $j $k $l $m $n $o $p $q $r
      }
   } else {
      if { $::conf(fichier,compres) == "0" } {
         lappend saveFileType $x $y $a $b $c $d $e $f $g $h $i $j $k $l $m $n $o $p $q $r
      } elseif { $::conf(fichier,compres) == "1" } {
         lappend saveFileType $y $x $a $b $c $d $e $f $g $h $i $j $k $l $m $n $o $p $q $r
      }
   }
}

#
# box_save parent initialdir numero_buffer type
#    Ouvre la fenetre de selection des fichiers a proposer a la sauvegarde
#
proc ::tkutil::box_save { { parent } { initialdir } { numero_buffer } { type } { visuNo "" } } {
   variable saveFileType

   #--- Ouvre la fenetre de choix des fichiers
   if { $type == "1" } {
      set title "$::caption(tkutil,sauver_image) (visu$visuNo)"
      ::tkutil::getSaveFileType
      set filetypes "$saveFileType"
      set filename [ tk_getSaveFile -title $title -filetypes $filetypes -initialdir $initialdir -parent $parent -defaultextension $::conf(extension,defaut) ]
   } elseif { $type == "2" } {
      set title "$::caption(tkutil,sauver_image_jpeg) (visu1)"
      set filetypes [ list [ list "$::caption(tkutil,image_jpeg)" ".jpg" ] ]
      set filename [ tk_getSaveFile -title $title -filetypes $filetypes -initialdir $initialdir -parent $parent -defaultextension ".jpg" ]
   }
   if { $filename == "" } {
      return
   }
   return $filename
}

#
# lgEntryComboBox liste
#    Fourni la largeur de l'entry d'une combobox adaptee au plus long element de la liste
#
proc ::tkutil::lgEntryComboBox { liste } {
   set a "0"
   set lgListe [ llength $liste ]
   for { set k 1 } { $k <= $lgListe} { incr k } {
      set index [ expr $k - 1 ]
      set lgElement [ string length [ lindex $liste $index ] ]
      set b $lgElement
      if { $b > $a } {
         set a $b
      }
   }
   if { $a == "0" } {
      set a "5"
   }
   set longEntryComboBox [ expr $a + 2 ]
   return $longEntryComboBox
}

#
# displayErrorInfo
#    Affiche le contenu de ::errorInfo dans la Console et dans une fenetre modale
#    avec eventuellement un message optionnel
#
proc ::tkutil::displayErrorInfo { title { messageOptionnel "" } } {
   #--- j'affiche le message complet dans la console
   ::console::affiche_erreur "$::errorInfo\n"
   #--- j'affiche le message d'erreur dasn une fenetre modale.
   tk_messageBox -icon error -title $title \
      -message "[string range $::errorInfo 0 [string first "\n    while executing" $::errorInfo]]$messageOptionnel"
}

##--------------------------------------------------------------
# validateNumber
#    verifie la valeur saisie dans un widget
#    Cette verification est activee en ajoutant les options suivantes au widget :
#    -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s <class> <minValue> <maxValue> <errrorVariable> }
#
# <br>Exemple
# <br>    -validatecommand { ::tkutil::validateNumber %W %V %P %s "numRef" integer -360 360 }
#
# @param  win      : nom tk du widget renseigne avec %W
# @param  event    : evenement (key, focusout,...) sur le widget renseigne avec %V
# @param  newValue : valeur apres l'evenement renseignee avec %P
# @param  oldValue : valeur avant l'evenement renseignee avec %s
# @param  class    : classe de la valeur attendue
#            - boolean : booleen ( 0, 1, false, true, no, yes , off , on)
#            - double  : nombre decimal
#            - integer : nombre entier
# @param  minValue      : valeur minimale du nombre
# @param  maxValue      : valeur maximale du nombre
# @param  errorVariable : nom de la variable d'erreur associee au widget
#
# @return
#   - 1 si OK
#   - 0 si erreur
# @public
#----------------------------------------------------------------------------
proc ::tkutil::validateNumber { win event newValue oldValue class minValue maxValue { errorVariable "" } } {
   variable widget

   set result 0
   if { $event == "key" || $event == "focusout"  } {
      #--- cas des nombres negatifs
      if { $minValue < 0 } {
         if { $newValue == "-" } {
            set result 1
            return $result
         }
      }
      #--- je verifie la classe
      set classCheck [string is $class -failindex charIndex $newValue]
      if { $classCheck == 0 } {
         set fullCheck $classCheck
         if { $errorVariable != "" } {
            set $errorVariable [format $::caption(tkutil,badCharacter) "\"$newValue\"" "\"[string range $newValue $charIndex $charIndex]\"" ]
         }
         set result 0
      } else {
         #--- je verifie la plage
         if {$minValue > $maxValue} {
            #--- je verifie l'ordre des bornes de l'intervalle
            set tmp $minValue; set minValue $maxValue; set maxValue $tmp
         }
         if { $newValue == "" } {
            set textVariable [$win cget -textvariable]
            set newValue $minValue
            if { $textVariable != "" } {
               #---
               set $textVariable $newValue
            }
         }
         if { $newValue < $minValue } {
            if { $errorVariable != "" } {
               set $errorVariable [format $::caption(tkutil,numberTooSmall) $newValue $minValue ]
            }
            set result 0
         } elseif { $newValue > $maxValue } {
            if { $errorVariable != "" } {
               set $errorVariable [format $::caption(tkutil,numberTooGreat) $newValue $maxValue ]
            }
            set result 0
         } else {
            if { $errorVariable != "" } {
               if { [info exists $errorVariable] } {
                  unset $errorVariable
               }
            }
            set result 1
         }
      }
      if { $result == 0 } {
         #--- j'affiche en inverse video
         ####$win configure -bg $::color(lightred) -fg $::audace(color,entryTextColor)
         bell
      } else {
         #--- j'affiche normalement
         ####$win configure -bg $::audace(color,entryBackColor) -fg $::audace(color,entryTextColor)
      }
   } else {
      #--- je ne traite pas l'evenement
      set result 1
   }
   return $result
}

##--------------------------------------------------------------
# validateString
#    Verifie le caractere saisie dans un widget
#    Cette verification est activee en ajoutant les options suivantes au widget :
#    -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s <class> <minLength> <maxLength> ?<errrorVariable>? }
#
# <br>Exemple 1
# <br>    -validatecommand { ::tkutil::validateString %W %V %P %s fits 1 70 }
#
# <br>Exemple 2 : avec variable de controle
# <br>    entry .frame.yyy -validatecommand { ::tkutil::validateString %W %V %P %s fits 1 70 ::xxxx::widget($visuNo,error,yyy) }
# <br>    entry .frame.zzz -validatecommand { ::tkutil::validateString %W %V %P %s fits 1 70 ::xxxx::widget($visuNo,error,zzz) }
#
# <br> puis faire les controles dans la procedure ::xxxx::apply
#     if { [array names ::xxxx::widget $visuNo,error,* ] != "" } {
#        #--- j'affiche un message d'erreur s'il existe au moins une variable ::xxxx::widget($visuNo,error,...)
#        ...
#     }
#
# @param  win      : nom tk du widget renseigne avec %W
# @param  event    : evenement sur le widget renseigne avec %V (key, focusout,...)
# @param  newValue : valeur apres l'evenement renseignee avec %P
# @param  oldValue : valeur avant l'evenement renseignee avec %s
# @param  class    : classe de la valeur attendue
#            - alnum     : caracteres alphabetiques ou numeriques
#            - alpha     : caracteres alphabetiques
#            - ascii     : caracteres ASCII dont le code est inferieur ou egal a 127
#            - binning   : caracteres autorises dans un binning (1x1, 2x2, 3x5, ...)
#            - boolean   : booleen ( 0, 1, false, true, no, yes , off , on)
#            - fits      : caracteres autorises dans un mot cle FITS
#            - wordchar  : caracteres alphabetiques ou numeriques ou underscore
#            - wordchar1 : caracteres de wordchar avec "-", sans "\" et "µ"
#            - wordchar2 : caracteres de wordchar avec "-" et ".", sans "\" et ""µ"
#            - xdigit    : caracteres hexadecimaux
# @param  minLength      : longueur minimale de la chaine
# @param  maxLength      : longueur maximale de la chaine
# @param  errorVariable  : nom de la variable d'erreur associee au widget
#
# @return
#   - 1 si OK
#   - 0 si erreur
# @private
#----------------------------------------------------------------------------
proc ::tkutil::validateString { win event newValue oldValue class minLength maxLength { errorVariable "" } } {
   variable widget

   set result 0
   set charIndex -1
   if { $event == "key" || $event == "focusout" } {
      #--- je verifie la classe
      if { $class == "fits" } {
         set classCheck [string is ascii -failindex charIndex $newValue]
        ### set classCheck [expr [[regexp -all {[\u0000-\u0029]|[\u007F-\u00FF]} $newValue ] != 0 ] ]
      } elseif { $class == "binning" } {
         set binx ""
         set biny ""
         set ctrl [ scan $newValue "%dx%d" binx biny ]
         set ctrlValue [ format $binx%s$biny x ]
         if { $ctrlValue != $newValue } {
            set classCheck 0
            set charIndex  ""
         } else {
            set classCheck 1
         }
      } elseif { $class == "wordchar1" } {
         set charIndex [string first "\\" $newValue]
         if { $charIndex != -1} {
            #--- je refuse le caractere antislash
            set classCheck 0
         } else {
            set charIndex [string first "µ" $newValue]
            if { $charIndex != -1} {
               #--- je refuse le caractere machin
               set classCheck 0
            } else {
               #--- je supprime le caractere "-"  de la chaine car il est autorise
               set newValue2 [string map { "-" "" } $newValue ]
               #--- je verifie les caracteres restant
               set classCheck [string is wordchar -failindex charIndex $newValue2]
            }
         }
      } elseif { $class == "wordchar2" } {
         set charIndex [string first "\\" $newValue]
         if { $charIndex != -1} {
            #--- je refuse le caractere antislash
            set classCheck 0
         } else {
            set charIndex [string first "µ" $newValue]
            if { $charIndex != -1} {
               #--- je refuse le caractere machin
               set classCheck 0
            } else {
               #--- je supprime les caracteres "-" et "." de la chaine car ils sont autorises
               set newValue2 [string map { "-" "" "." "" } $newValue ]
               #--- je verifie les caracteres restant
               set classCheck [string is wordchar -failindex charIndex $newValue2]
            }
         }
      }
      if { $classCheck == 0} {
         if { $charIndex != -1 && $errorVariable != ""  } {
            set $errorVariable [format $::caption(tkutil,badCharacter) "\"$newValue\"" "\"[string range $newValue $charIndex $charIndex]\"" ]
         }
         set result 0
     } else {
         #--- je verifie la longueur de la chaine
         if {$minLength > $maxLength} {
            #--- je verifie l'ordre des bornes de longueur
            set tmp $minLength; set minLength $maxLength; set maxLength $tmp
         }
         set xLength [string length $newValue]
         if { $xLength < $minLength } {
            if { $errorVariable != "" } {
               set $errorVariable [format $::caption(tkutil,stringTooShort) "\"$newValue\"" $minLength]
            }
            set result 0
         } elseif { $xLength > $maxLength } {
            if { $errorVariable != "" } {
               set $errorVariable [format $::caption(tkutil,stringTooLarge) "\"$newValue\"" $maxLength]
            }
            set result 0
         } else {
            if { $errorVariable != "" } {
               if { [info exists $errorVariable] } {
                  unset $errorVariable
               }
            }
            set result 1
         }
      }
      #--- je change de couleur si la longueur est incorrecte
      if { $result == 0 } {
         #--- j'affiche en inverse video
         ###$win configure -bg $::color(lightred) -fg $::audace(color,entryTextColor)
         bell
      } else {
         #--- j'affiche normalement
         ###$win configure -bg $::audace(color,entryBackColor) -fg $::audace(color,entryTextColor)
      }
   } else {
      #--- je ne traite pas l'evenement
      set result 1
   }
   return $result
}

