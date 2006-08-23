#
# Fichier : tkutil.tcl
# Description : Regroupement d'utilitaires
# Auteur : Robert DELMAS
# Mise a jour $Id: tkutil.tcl,v 1.5 2006-08-23 19:51:54 robertdelmas Exp $
#

namespace eval tkutil {
   global audace
   global tkutil

   #--- Chargement des captions
   source [ file join $audace(rep_caption) tkutil.cap ]

   #
   # tkutil::getOpenFileType
   # Gere les differentes extensions des fichiers images, ainsi que le cas ou l'extension
   # des fichiers FITS est differente de .fit
   #
   proc getOpenFileType { } {
      variable openFileType
      global audace
      global caption

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
         [ list "$caption(tkutil,image_file)"       {.bmp}       ] \
         [ list "$caption(tkutil,image_file)"       {.gif}       ] \
         [ list "$caption(tkutil,image_file)"       {.jpeg .jpg} ] \
         [ list "$caption(tkutil,image_file)"       {.png}       ] \
         [ list "$caption(tkutil,image_file)"       {.tiff .tif} ] \
         [ list "$caption(tkutil,image_file)"       {.xbm}       ] \
         [ list "$caption(tkutil,image_file)"       {.xpm}       ] \
         [ list "$caption(tkutil,image_file)"       {.ps .eps}   ] \
         [ list "$caption(tkutil,image_file)"       {.crw .nef .cr2 .dng} ] \
         [ list "$caption(tkutil,image_file)"       {.ps .eps}   ] \
         [ list "$caption(tkutil,image_fits)"       {.fit}       ] \
         [ list "$caption(tkutil,image_fits)"       {.fit.gz}    ] \
         [ list "$caption(tkutil,image_fits)"       {.fts}       ] \
         [ list "$caption(tkutil,image_fits)"       {.fts.gz}    ] \
         [ list "$caption(tkutil,image_fits)"       {.fits}      ] \
         [ list "$caption(tkutil,image_fits)"       {.fits.gz}   ] \
         [ list "$caption(tkutil,image_bmp)"        {.bmp}       ] \
         [ list "$caption(tkutil,image_gif)"        {.gif}       ] \
         [ list "$caption(tkutil,image_jpeg)"       {.jpeg .jpg} ] \
         [ list "$caption(tkutil,image_png)"        {.png}       ] \
         [ list "$caption(tkutil,image_tiff)"       {.tiff .tif} ] \
         [ list "$caption(tkutil,image_xbm)"        {.xbm}       ] \
         [ list "$caption(tkutil,image_xpm)"        {.xpm}       ] \
         [ list "$caption(tkutil,image_postscript)" {.ps .eps}   ] \
         [ list "$caption(tkutil,image_gif)"        {}      GIFF ] \
         [ list "$caption(tkutil,image_jpeg)"       {}      JPEG ] \
         [ list "$caption(tkutil,image_png)"        {}      PNGF ] \
         [ list "$caption(tkutil,image_tiff)"       {}      TIFF ] \
         [ list "$caption(tkutil,image_raw)"        {.crw .nef}  ] \
         [ list "$caption(tkutil,fichier_tous)"     *            ]
   }

   #
   # tkutil::box_load parent initialdir numero_buffer type
   # Ouvre la fenetre de selection des fichiers a proposer au chargement (hors fichiers html)
   #
   proc box_load { { parent } { initialdir } { numero_buffer } { type } { visuNo "1" } } {
      variable openFileType
      global audace
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
      }
      set filename [ tk_getOpenFile -title $title -filetypes $filetypes -initialdir $initialdir -parent $parent ]
      #---
      catch {
         #--- Je detruis la boite de dialogue cree par tk_getOpenFile
         #--- Car sous Linux la fenetre n'est pas detruite a la fin de l'utilisation (bug de linux ?)
        ### ::console::disp "box_load  [ winfo children .audace.__tk_filedialog.f2 ] \n" 
         destroy $parent.__tk_filedialog
      }
      #---
      return $filename
   }

   #
   # tkutil::box_load_html parent initialdir numero_buffer type
   # Ouvre la fenetre de selection des fichiers html a proposer au chargement
   #
   proc box_load_html { { parent } { initialdir } { numero_buffer } { type } } {
      global audace
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
         #--- Car sous Linux la fenetre n'est pas detruite a la fin de l'utilisation (bug de linux ?)
        ### ::console::disp "box_load  [ winfo children .audace.__tk_filedialog.f2 ] \n" 
         destroy $parent.__tk_filedialog
      }
      #---
      return $filename
   }

   #
   # tkutil::getSaveFileType
   # Gere les differentes extensions des fichiers images, ainsi que le cas ou l'extension
   # des fichiers FITS est differente de .fit, de .fts et de .fits
   #
   proc getSaveFileType { } {
      variable saveFileType
      global audace
      global caption

      #---
      set saveFileType [ list ]
      #---
      if { ( [ buf$audace(bufNo) extension ] != ".fit" ) && ( [ buf$audace(bufNo) extension ] != ".fts" ) &&
         ( [ buf$audace(bufNo) extension ] != ".fits" ) } {
         lappend saveFileType \
            [ list "$caption(tkutil,image_fits)"       [ buf$audace(bufNo) extension ] ] \
            [ list "$caption(tkutil,image_fits) gz"    [ buf$audace(bufNo) extension ].gz ]
      }
      #---
      lappend saveFileType \
         [ list "$caption(tkutil,image_fits) "      {.fit}       ] \
         [ list "$caption(tkutil,image_fits) 1"     {.fit.gz}    ] \
         [ list "$caption(tkutil,image_fits) 2"     {.fts}       ] \
         [ list "$caption(tkutil,image_fits) 3"     {.fts.gz}    ] \
         [ list "$caption(tkutil,image_fits) 4"     {.fits}      ] \
         [ list "$caption(tkutil,image_fits) 5"     {.fits.gz}   ] \
         [ list "$caption(tkutil,image_bmp)"        {.bmp}       ] \
         [ list "$caption(tkutil,image_gif)"        {.gif}       ] \
         [ list "$caption(tkutil,image_jpeg)"       {.jpg}       ] \
         [ list "$caption(tkutil,image_png)"        {.png}       ] \
         [ list "$caption(tkutil,image_tiff)"       {.tif}       ] \
         [ list "$caption(tkutil,image_xbm)"        {.xbm}       ] \
         [ list "$caption(tkutil,image_xpm)"        {.xpm}       ] \
         [ list "$caption(tkutil,image_postscript)" {.eps}       ] \
         [ list "$caption(tkutil,image_gif)"        {}      GIFF ] \
         [ list "$caption(tkutil,image_jpeg)"       {}      JPEG ] \
         [ list "$caption(tkutil,image_png)"        {}      PNGF ] \
         [ list "$caption(tkutil,image_tiff)"       {}      TIFF ] \
         [ list "$caption(tkutil,image_raw)"        {.crw }      ] \
         [ list "$caption(tkutil,image_raw) "       {.nef}       ]
   }

   #
   # tkutil::box_save parent initialdir numero_buffer type
   # Ouvre la fenetre de selection des fichiers a proposer au chargement
   #
   proc box_save { { parent } { initialdir } { numero_buffer } { type } { visuNo "" } } {
      variable saveFileType
      global audace
      global caption

      #--- Ouvre la fenetre de choix des fichiers
      if { $type == "1" } {
         set title "$caption(tkutil,sauver_image) (visu$visuNo)"
         ::tkutil::getSaveFileType
         set filetypes "$saveFileType"
      } elseif { $type == "2" } {
         set title "$caption(tkutil,sauver_image_jpeg) (visu1)"
         set filetypes [ list [ list "$caption(tkutil,image_jpeg)" ".jpg" ] ]
      }
      set filename [ tk_getSaveFile -title $title -filetypes $filetypes -initialdir $initialdir -parent $parent ]
      if { $filename == "" } {
         return
      }
      return $filename
   }

   #
   # tkutil::coord_eph_vrai
   # Transforme les coordonnees equatoriales des ephemerides pour une equinoxe donnee en coordonnees vraies
   # en prenant en compte les corrections d'aberration, de precession et de nutation
   #
   proc coord_eph_vrai { ad_eph dec_eph equinox date } {
      global audace

      #--- Correction de l'aberration annuelle
      set radec [ mc_aberrationradec annual [ list $ad_eph $dec_eph ] $date ]
      #--- Correction de la precession
      set radec [ mc_precessradec $radec $equinox $date ]
      #--- Correction de la nutation
      set radec [ mc_nutationradec $radec $date ]
      #--- Correction de l'aberration diurne
      set radec [ mc_aberrationradec diurnal $radec $date $audace(posobs,observateur,gps) ]
      #--- Calcul de l'angle horaire vraie
      set ad_vrai [ lindex $radec 0 ]
      set ad_vrai [ mc_angle2hms $ad_vrai 360 nozero 1 auto string ]
      set dec_vrai [ lindex $radec 1 ]
      set dec_vrai [ mc_angle2dms $dec_vrai 90 nozero 0 + string ]

      return [ list $ad_vrai $dec_vrai ]
   }

}

