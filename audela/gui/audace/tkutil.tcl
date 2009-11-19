#
# Fichier : tkutil.tcl
# Description : Regroupement d'utilitaires
# Auteur : Robert DELMAS
# Mise a jour $Id: tkutil.tcl,v 1.20 2009-11-19 22:16:49 robertdelmas Exp $
#

namespace eval tkutil:: {
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_caption) tkutil.cap ]
}

#
# getOpenFileType
#    Gere les differentes extensions des fichiers images, ainsi que le cas ou l'extension
#    des fichiers FITS est differente de .fit
#
proc ::tkutil::getOpenFileType { } {
   variable openFileType
   global audace caption

   #---
   set openFileType [ list ]
   #---
   if { ( [ buf$audace(bufNo) extension ] != ".fit" ) && ( [ buf$audace(bufNo) extension ] != ".fts" ) &&
      ( [ buf$audace(bufNo) extension ] != ".fits" ) } {
      lappend openFileType \
         [ list "$caption(tkutil,image_file)"       [ buf$audace(bufNo) extension ] ] \
         [ list "$caption(tkutil,image_file)"       [ buf$audace(bufNo) extension ].gz ] \
         [ list "$caption(tkutil,image_fits)"       [ buf$audace(bufNo) extension ] ] \
         [ list "$caption(tkutil,image_fits)"       [ buf$audace(bufNo) extension ].gz ]
   }

   #---
   lappend openFileType \
      [ list "$caption(tkutil,image_file)"       {.fit}       ] \
      [ list "$caption(tkutil,image_file)"       {.fit.gz}    ] \
      [ list "$caption(tkutil,image_file)"       {.fts}       ] \
      [ list "$caption(tkutil,image_file)"       {.fts.gz}    ] \
      [ list "$caption(tkutil,image_file)"       {.fits}      ] \
      [ list "$caption(tkutil,image_file)"       {.fits.gz}   ] \
      [ list "$caption(tkutil,image_file)"       {.jpeg .jpg} ] \
      [ list "$caption(tkutil,image_file)"       {.crw .cr2 .nef .dng} ] \
      [ list "$caption(tkutil,image_file)"       {.CRW .CR2 .NEF .DNG} ] \
      [ list "$caption(tkutil,image_fits)"       {.fit}       ] \
      [ list "$caption(tkutil,image_fits)"       {.fit.gz}    ] \
      [ list "$caption(tkutil,image_fits)"       {.fts}       ] \
      [ list "$caption(tkutil,image_fits)"       {.fts.gz}    ] \
      [ list "$caption(tkutil,image_fits)"       {.fits}      ] \
      [ list "$caption(tkutil,image_fits)"       {.fits.gz}   ] \
      [ list "$caption(tkutil,image_jpeg)"       {.jpeg .jpg} ] \
      [ list "$caption(tkutil,image_raw)"        {.crw .cr2 .nef .dng} ] \
      [ list "$caption(tkutil,image_raw)"        {.CRW .CR2 .NEF .DNG} ] \
      [ list "$caption(tkutil,fichier_tous)"     *            ]
}

#
# box_load parent initialdir numero_buffer type
#    Ouvre la fenetre de selection des fichiers a proposer au chargement (hors fichiers html)
#
proc ::tkutil::box_load { { parent } { initialdir } { numero_buffer } { type } { visuNo "1" } } {
   variable openFileType
   global caption

   #--- Ouvre la fenetre de choix des fichiers
   if { $type == "1" } {
      set title "$caption(tkutil,charger_image) (visu$visuNo)"
      ::tkutil::getOpenFileType
      set filetypes "$openFileType"
   } elseif { $type == "2" } {
      set title "$caption(tkutil,editer_script)"
      set filetypes [ list [ list "$caption(tkutil,fichier_tcl)" ".tcl" ] \
         [ list "$caption(tkutil,fichier_txt)" ".txt" ] [ list "$caption(tkutil,fichier_tous)" "*" ] ]
   } elseif { $type == "3" } {
      set title "$caption(tkutil,lancer_script)"
      set filetypes [ list [ list "$caption(tkutil,fichier_tcl)" ".tcl" ] ]
   } elseif { $type == "4" } {
      set title "$caption(tkutil,editer_notice)"
      set filetypes [ list [ list "$caption(tkutil,fichier_pdf)" ".pdf" ] ]
   } elseif { $type == "5" } {
      set title "$caption(tkutil,editer_catalogue)"
      set filetypes [ list [ list "$caption(tkutil,fichier_txt)" ".txt" ] ]
   } elseif { $type == "6" } {
      set title "$caption(tkutil,editeur_script)"
      set filetypes [ list [ list "$caption(tkutil,fichier_tous)" "*" ] ]
   } elseif { $type == "7" } {
      set title "$caption(tkutil,editeur_pdf)"
      set filetypes [ list [ list "$caption(tkutil,fichier_tous)" "*" ] ]
   } elseif { $type == "8" } {
      set title "$caption(tkutil,editeur_page_web)"
      set filetypes [ list [ list "$caption(tkutil,fichier_tous)" "*" ] ]
   } elseif { $type == "9" } {
      set title "$caption(tkutil,editeur_image)"
      set filetypes [ list [ list "$caption(tkutil,fichier_tous)" "*" ] ]
   } elseif { $type == "10" } {
      set title "$caption(tkutil,editer_modpoi)"
      set filetypes [ list [ list "$caption(tkutil,fichier_txt)" ".txt" ] ]
   } elseif { $type == "11" } {
      set title "$caption(tkutil,editer_fichier)"
      set filetypes [ list [ list "$caption(tkutil,fichier_txt)" "*" ] ]
   } elseif { $type == "12" } {
      set title "$caption(tkutil,executable_java)"
      set filetypes [ list [ list "$caption(tkutil,fichier_tous)" "*" ] ]
   } elseif { $type == "13" } {
      set title "$caption(tkutil,executable_aladin)"
      if { $::tcl_platform(os) == "Linux" } {
         set filetypes [ list [ list "$caption(tkutil,fichier_jar)" ".jar" ] ]
      } else {
         set filetypes [ list [ list "$caption(tkutil,fichier_tous)" "*" ] ]
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
   global caption

   #--- Ouvre la fenetre de choix des fichiers
   if { $type == "1" } {
      set title "$caption(tkutil,editer_site_web)"
      set filetypes [ list [ list "$caption(tkutil,fichier_html)" ".htm" ] ]
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
   global audace caption conf

   #---
   set saveFileType [ list ]
   #---
   if { ( [ buf$audace(bufNo) extension ] != ".fit" ) && ( [ buf$audace(bufNo) extension ] != ".fts" ) &&
      ( [ buf$audace(bufNo) extension ] != ".fits" ) && ( [ buf$audace(bufNo) extension ] != ".jpg" ) &&
      ( [ buf$audace(bufNo) extension ] != ".crw" ) && ( [ buf$audace(bufNo) extension ] != ".CRW" ) &&
      ( [ buf$audace(bufNo) extension ] != ".cr2" ) && ( [ buf$audace(bufNo) extension ] != ".CR2" ) &&
      ( [ buf$audace(bufNo) extension ] != ".nef" ) && ( [ buf$audace(bufNo) extension ] != ".NEF" ) &&
      ( [ buf$audace(bufNo) extension ] != ".dng" ) && ( [ buf$audace(bufNo) extension ] != ".DNG" ) } {
      if { $conf(fichier,compres) == "0" } {
         lappend saveFileType \
            [ list "$caption(tkutil,image_fits)"       [ buf$audace(bufNo) extension ] ] \
            [ list "$caption(tkutil,image_fits) gz"    [ buf$audace(bufNo) extension ].gz ]
      } elseif { $conf(fichier,compres) == "1" } {
         lappend saveFileType \
            [ list "$caption(tkutil,image_fits) gz"    [ buf$audace(bufNo) extension ].gz ] \
            [ list "$caption(tkutil,image_fits)"       [ buf$audace(bufNo) extension ] ]
      }
   }
   #---
   set a [ list "$caption(tkutil,image_fits) "      {.fit}       ]
   set b [ list "$caption(tkutil,image_fits) 1"     {.fit.gz}    ]
   set c [ list "$caption(tkutil,image_fits) 2"     {.fts}       ]
   set d [ list "$caption(tkutil,image_fits) 3"     {.fts.gz}    ]
   set e [ list "$caption(tkutil,image_fits) 4"     {.fits}      ]
   set f [ list "$caption(tkutil,image_fits) 5"     {.fits.gz}   ]
   set g [ list "$caption(tkutil,image_jpeg)"       {.jpg}       ]
   set h [ list "$caption(tkutil,image_raw)."       {.crw }      ]
   set i [ list "$caption(tkutil,image_raw).1"      {.CRW }      ]
   set j [ list "$caption(tkutil,image_raw) 2"      {.cr2}       ]
   set k [ list "$caption(tkutil,image_raw) 3"      {.CR2}       ]
   set l [ list "$caption(tkutil,image_raw) 4"      {.nef }      ]
   set m [ list "$caption(tkutil,image_raw) 5"      {.NEF }      ]
   set n [ list "$caption(tkutil,image_raw) 6"      {.dng}       ]
   set o [ list "$caption(tkutil,image_raw) 7"      {.DNG}       ]

   if { [ buf$audace(bufNo) extension ] == ".fit" } {
      if { $conf(fichier,compres) == "0" } {
         lappend saveFileType $a $b $c $d $e $f $g $h $i $j $k $l $m $n $o
      } elseif { $conf(fichier,compres) == "1" } {
         lappend saveFileType $b $a $c $d $e $f $g $h $i $j $k $l $m $n $o
      }
   } elseif { [ buf$audace(bufNo) extension ] == ".fts" } {
      if { $conf(fichier,compres) == "0" } {
         lappend saveFileType $c $d $a $b $e $f $g $h $i $j $k $l $m $n $o
      } elseif { $conf(fichier,compres) == "1" } {
         lappend saveFileType $d $c $a $b $e $f $g $h $i $j $k $l $m $n $o
      }
   } elseif { [ buf$audace(bufNo) extension ] == ".fits" } {
      if { $conf(fichier,compres) == "0" } {
         lappend saveFileType $e $f $a $b $c $d $g $h $i $j $k $l $m $n $o
      } elseif { $conf(fichier,compres) == "1" } {
         lappend saveFileType $f $e $a $b $c $d $g $h $i $j $k $l $m $n $o
      }
   } elseif { [ buf$audace(bufNo) extension ] == ".jpg" } {
      lappend saveFileType $g $a $b $c $d $e $f $h $i $j $k $l $m $n $o
   } elseif { [ buf$audace(bufNo) extension ] == ".crw" } {
      lappend saveFileType $h $i $j $k $l $m $n $o $a $b $c $d $e $f $g
   } elseif { [ buf$audace(bufNo) extension ] == ".CRW" } {
      lappend saveFileType $i $h $j $k $l $m $n $o $a $b $c $d $e $f $g
   } elseif { [ buf$audace(bufNo) extension ] == ".cr2" } {
      lappend saveFileType $j $k $h $i $l $m $n $o $a $b $c $d $e $f $g
   } elseif { [ buf$audace(bufNo) extension ] == ".CR2" } {
      lappend saveFileType $k $j $h $i $l $m $n $o $a $b $c $d $e $f $g
   } elseif { [ buf$audace(bufNo) extension ] == ".nef" } {
      lappend saveFileType $l $m $h $i $j $k $n $o $a $b $c $d $e $f $g
   } elseif { [ buf$audace(bufNo) extension ] == ".NEF" } {
      lappend saveFileType $m $l $h $i $j $k $n $o $a $b $c $d $e $f $g
   } elseif { [ buf$audace(bufNo) extension ] == ".dng" } {
      lappend saveFileType $n $o $h $i $j $k $l $m $a $b $c $d $e $f $g
   } elseif { [ buf$audace(bufNo) extension ] == ".DNG" } {
      lappend saveFileType $o $n $h $i $j $k $l $m $a $b $c $d $e $f $g
   }
}

#
# box_save parent initialdir numero_buffer type
#    Ouvre la fenetre de selection des fichiers a proposer a la sauvegarde
#
proc ::tkutil::box_save { { parent } { initialdir } { numero_buffer } { type } { visuNo "" } } {
   variable saveFileType
   global caption conf

   #--- Ouvre la fenetre de choix des fichiers
   if { $type == "1" } {
      set title "$caption(tkutil,sauver_image) (visu$visuNo)"
      ::tkutil::getSaveFileType
      set filetypes "$saveFileType"
      set filename [ tk_getSaveFile -title $title -filetypes $filetypes -initialdir $initialdir -parent $parent ]
   } elseif { $type == "2" } {
      set title "$caption(tkutil,sauver_image_jpeg) (visu1)"
      set filetypes [ list [ list "$caption(tkutil,image_jpeg)" ".jpg" ] ]
      set filename [ tk_getSaveFile -title $title -filetypes $filetypes -initialdir $initialdir -parent $parent ]
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

