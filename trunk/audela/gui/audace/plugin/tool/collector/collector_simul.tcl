#
# Fichier : collector_simul.tcl
# Description :
# Auteur : Raymond Zachantke
# Mise à jour $Id$
#

   #--   Liste des proc liees a la simulation
   # nom proc                       utilisee par
   # ::collector::synthetiser       Commande du bouton 'Synthetiser' et magic
   # ::collector::createSpecial     Commande du bouton 'Baguette magique'
   # ::collector::createImg         synthetiser
   # ::collector::magic             createSpecial
   # ::collector::createKeywords    magic et setKeywords
   # ::collector::formatKeyword     createKeywords
   # ::collector::setKeywords       magic
   # ::collector::calibrationAstro  magic et updateDSSData
   # ::collector::editKeywords      Commande du bouton 'Editer les mots cles dans la console'


   #---------------------------------------------------------------------------
   #  synthetiser
   #  Commande du bouton 'Synthetiser'
   #---------------------------------------------------------------------------
   proc synthetiser { visuNo } {
      variable private

      #--   inhibe les boutons
      configButtons disabled
      update

      #--   force Observer
      set private(observer) "Simulimage"

      lassign $private(match_wcs) match_wcs ra dec pixsize1 pixsize2 foclen

      if {$match_wcs != 0} {
         if {[catch {createImg $ra $dec $pixsize1 $pixsize2 $foclen $private(fwhm) $private(catname) $private(catAcc) } ErrInfo]} {
            #--   efface le buffer
            ::confVisu::deleteImage $visuNo
            ::console::affiche_resultat "$ErrInfo"
         }
      }

      #--   desinhibe les boutons
      configButtons !disabled
      update
   }

   #---------------------------------------------------------------------------
   #  createSpecial
   #  Commande du bouton 'Baguette magique'
   #---------------------------------------------------------------------------
   proc createSpecial { visuNo w } {
      variable private

      $w configure -image $private(chaudron)
      update

      magic $visuNo

      $w configure -image $private(baguette)
      configButtons !disabled
      update
   }

   #---------------------------------------------------------------------------
   #  createImg
   #  Cree la creation de l'image de synthese
   #---------------------------------------------------------------------------
   proc createImg { Angle_ra Angle_dec valpixsize1 valpixsize2 valfoclen fwhm cat_format cat_folder } {
      global audace conf

      set shutter_mode 1
      set bias_level 0
      set flat_type 0

      simulimage $Angle_ra $Angle_dec $valpixsize1 $valpixsize2 $valfoclen \
         $cat_format $cat_folder $audace(etc,input,ccd,t) $fwhm $audace(etc,param,optic,D) \
         $audace(etc,param,object,band) $audace(etc,param,local,msky) \
         $audace(etc,param,ccd,eta) $audace(etc,param,ccd,G) \
         $audace(etc,param,ccd,N_ro) $shutter_mode $bias_level \
         $audace(etc,param,ccd,C_th) $audace(etc,comp1,Tatm) \
         $audace(etc,param,optic,Topt) $audace(etc,param,ccd,Em) $flat_type

      #--   sauve l'image myImg
      saveima [file join $audace(rep_images) myImg$::conf(extension,defaut)]
   }

   #--------------------------------------------------------------------------
   #  magic
   #  Gere la creation de l'image
   #--------------------------------------------------------------------------
   proc magic { visuNo } {
      variable private
      variable myKeywords
      global audace conf caption

      set bufNo [visu$audace(visuNo) buf]
      set ext $conf(extension,defaut)
      set naxis1 $private(naxis1)
      set naxis2 $private(naxis2)
      set img_name [file join $audace(rep_images) myImg$ext]

      createKeywords

      visu$audace(visuNo) clear
      ::confVisu::setZoom 1 0.5

      buf$bufNo setpixels CLASS_GRAY $naxis1 $naxis2 FORMAT_USHORT COMPRESS_NONE 0
      setKeywords $bufNo

      saveima $img_name
      ::confVisu::setFileName $visuNo $img_name
      #visu$audace(visuNo) disp

      set private(match_wcs) [list 2 * * * * * ]

      synthetiser $visuNo

      #--   Reinhibe les boutons
      configButtons disabled
      update

      #--   pm simulimage cree les mots cles EQUINOX RADESYS CTYPE1 CTYPE2 CUNIT1 CUNIT2 LONPOLE CATASTAR
      #--   pb avec RADESYS dans surchaud
      catch {buf$bufNo delkwd RADESYS}
      calibrationAstro $bufNo $ext $private(catAcc) $private(catname)
   }

   #--------------------------------------------------------------------------
   #  createKeywords
   #  Cree un array avec tous les mots cles
   #--------------------------------------------------------------------------
   proc createKeywords { } {
      variable private
      variable myKeywords

      set list_of_kwd [list BIN1 BIN2 NAXIS1 NAXIS2 RA DEC CRVAL1 CRVAL2 CRPIX1 CRPIX2 \
         DATE-OBS MJD-OBS EXPOSURE FOCLEN CROTA2 FILTER FILTERNU FWHM \
         PIXSIZE1 PIXSIZE2 CDELT1 CDELT2 CD1_1 CD1_2 CD2_1 CD2_2 \
         AIRPRESS TEMPAIR DETNAM CONFNAME IMAGETYP OBJNAME SWCREATE]

      #--   raccourcis
      foreach var [list ra dec gps t tu jd tsl telescop aptdia foclen fwhm \
         bin1 bin2 naxis1 naxis2 cdelt1 cdelt2 crota2 filter \
         detnam photocell1 photocell2 isospeed pixsize1 pixsize2 \
         crval1 crval2 crpix1 crpix2 \
         airpress tempair temprose hygro winddir windsp \
         observer sitename origin iau_code imagetyp objname] {
         set $var $private($var)
         #::console::affiche_resultat "$var \"$private($var)\"\n"
      }

      set ra [mc_angle2deg $ra]
      set dec [mc_angle2deg $dec]
      set airpress [expr { $airpress / 100. }]

      #--   passe de arcsec en degres
      set cdelt1 [expr { $cdelt1 / 3600. }]
      set cdelt2 [expr { $cdelt2 / 3600. }]

      set filternu 1

      if {$gps ne "-"} {
         lassign $gps -> obs-long sens obs-lat obs-elev
         if {$sens eq "W"} {
            set obs-long -${obs-long}
         }
         lassign [obsCoord2SiteCoord "$gps"] sitelong sitelat siteelev
         set geodsys WGS84
         lappend list_of_kwd OBS-ELEV OBS-LAT OBS-LONG SITELONG SITELAT SITEELEV GEODSYS
      }

      set date-obs $tu
      set mjd-obs [expr { $jd-2400000.5 }]
      set exposure $t

      lassign [mc_radec2altaz $ra $dec $gps ${date-obs}] elev
      lassign [getCD $cdelt1 $cdelt2 $crota2] cd1_1 cd1_2 cd2_1 cd2_2

      set swcreate "[::audela::getPluginTitle] $::audela(version)"
      set confname "myConf"

      #--   complete la liste des mots cles si leur valeur significative
      set optKwd [list aptdia "-" isospeed "-" hygro "-" iau_code "" \
         observer "-" origin "" sitename "-" telescop "-" temprose "-" \
         winddir "-" windsp "-"]
      foreach {var val} $optKwd {
         if {[set $var] ne "$val"} {
            lappend list_of_kwd [string toupper $var]
         }
      }

      #--   liste les caracteres a substituer
      set entities [list à a â a ç c é e è e ê e ë e î i ï i ô o ö o û u ü u ü u ' ""]

      foreach kwd $list_of_kwd {
         set val [set [string tolower ${kwd}]]
         set sentence [formatKeyword $kwd]
         if {[lindex $sentence 2] eq "string"} {
            #--   remplace la caracteres accentues par les non accentues
            #--   et transforme le string en liste
            set val [list [string map -nocase $entities $val]]
         }
         array set myKeywords [list $kwd [format $sentence $val] ]
      }
   }

   #--------------------------------------------------------------------------
   #  formatKeyword
   #--------------------------------------------------------------------------
   proc formatKeyword { {kwd " "} } {

      dict set dicokwd AIRPRESS  {AIRPRESS %s float {[hPa] Atmospheric Pressure} hPa}
      dict set dicokwd APTDIA    {APTDIA %s float Diameter m}
      dict set dicokwd BIN1      {BIN1 %s int {} {}}
      dict set dicokwd BIN2      {BIN2 %s int {} {}}
      dict set dicokwd CD1_1     {CD1_1 %s double {Coord. transf. matrix CD11} deg/pixel}
      dict set dicokwd CD1_2     {CD1_2 %s double {Coord. transf. matrix CD12} deg/pixel}
      dict set dicokwd CD2_1     {CD2_1 %s double {Coord. transf. matrix CD21} deg/pixel}
      dict set dicokwd CD2_2     {CD2_2 %s double {Coord. transf. matrix CD22} deg/pixel}
      dict set dicokwd CDELT1    {CDELT1 %s double {Scale along Naxis1} deg/pixel}
      dict set dicokwd CDELT2    {CDELT2 %s double {Scale along Naxis2} deg/pixel}
      dict set dicokwd CONFNAME  {CONFNAME %s string {Instrument Setup} {}}
      dict set dicokwd CROTA2    {CROTA2 %s float {Position angle of North} deg}
      dict set dicokwd CRPIX1    {CRPIX1 %s float {Reference pixel for Naxis1} pixel}
      dict set dicokwd CRPIX2    {CRPIX2 %s float {Reference pixel for Naxis2} pixel}
      dict set dicokwd CRVAL1    {CRVAL1 %s double {Reference coordinate for Naxis1} deg}
      dict set dicokwd CRVAL2    {CRVAL2 %s double {Reference coordinate for Naxis2} deg}
      dict set dicokwd DATE-OBS  {DATE-OBS %s string {Start of exposure.FITS standard} {ISO 8601}}
      dict set dicokwd DEC       {DEC %s float {Expected DEC asked to telescope} {deg}}
      dict set dicokwd DETNAM    {DETNAM %s string {Camera used} {}}
      dict set dicokwd EGAIN     {EGAIN %s float {electronic gain in} {e/ADU}}
      dict set dicokwd EQUINOX   {EQUINOX %s float {System of equatorial coordinates} {}}
      dict set dicokwd EXPOSURE  {EXPOSURE %s float {Total time of exposure} s}
      dict set dicokwd EXPTIME   {EXPTIME %s float {Exposure Time} s}
      dict set dicokwd FILTER    {FILTER %s string {C U B V R I J H K z} {}}
      dict set dicokwd FILTERNU  {FILTERNU %s int {Filter number} {}}
      dict set dicokwd FOCLEN    {FOCLEN %s float {Resulting Focal length} m}
      dict set dicokwd FWHM      {FWHM %s float {Full Width at Half Maximum} pixels}
      dict set dicokwd GEODSYS   {GEODSYS %s string {Geodetic datum for observatory position} {}}
      dict set dicokwd HYGRO     {HYGRO %s int {Hydrometry} percent}
      dict set dicokwd IAU_CODE  {IAU_CODE %s string {IAU Code for the observatory} {}}
      dict set dicokwd IMAGETYP  {IMAGETYP %s string {Image Type} {}}
      dict set dicokwd INSTRUME  {INSTRUME %s string {Camera used} {}}
      dict set dicokwd ISOSPEED  {ISOSPEED %s int {ISO camera setting} {ISO}}
      dict set dicokwd MJD-OBS   {MJD-OBS %s double {Start of exposure} d}
      dict set dicokwd NAXIS1    {NAXIS1 %s int {Length of data axis 1} {}}
      dict set dicokwd NAXIS2    {NAXIS2 %s int {Length of data axis 2} {}}
      dict set dicokwd NBSTARS   {NBSTARS %s int {Nb of stars detected by Sextractor} {}}
      dict set dicokwd OBJECT    {OBJECT %s string {Object observed} {}}
      dict set dicokwd OBJEKEY   {OBJEKEY %s string {Link key for objefile} {}}
      dict set dicokwd OBJNAME   {OBJNAME %s string {Object Name} {}}
      dict set dicokwd OBS-ELEV  {OBS-ELEV %s float {Elevation above sea of observatory} m}
      dict set dicokwd OBS-LAT   {OBS-LAT %s float {Geodetic observatory latitude} deg}
      dict set dicokwd OBS-LONG  {OBS-LONG %s float {East-positive observatory longitude} deg}
      dict set dicokwd OBSERVER  {OBSERVER %s string {Observers Names} {}}
      dict set dicokwd ORIGIN    {ORIGIN %s string {Organization Name} {}}
      dict set dicokwd PEDESTAL  {PEDESTAL %s int {add this value to each pixel value} {}}
      dict set dicokwd PIXSIZE1  {PIXSIZE1 %s double {Pixel Width (with binning)} mum}
      dict set dicokwd PIXSIZE2  {PIXSIZE2 %s double {Pixel Height (with binning)} mum}
      dict set dicokwd RA        {RA %s float {Expected RA asked to telescope} {deg}}
      dict set dicokwd RADECSYS  {RADECSYS %s string {Mean Place IAU 1984 system} {}}
      dict set dicokwd SEING     {SEING %s double {Average FWHM} pixels}
      dict set dicokwd SITENAME  {SITENAME %s string {Observatory Name} {}}
      dict set dicokwd SITEELEV  {SITEELEV %s float {Elevation above sea of observatory} m}
      dict set dicokwd SITELAT   {SITELAT %s string {Geodetic observatory latitude} deg}
      dict set dicokwd SITELONG  {SITELONG %s string {East-positive observatory longitude} deg}
      dict set dicokwd SWCREATE  {SWCREATE %s string {Acquisition Software} {}}
      dict set dicokwd TELESCOP  {TELESCOP %s string {Telescope (name barlow reducer)} {}}
      dict set dicokwd TEMPAIR   {TEMPAIR %s float {Air temperature} Celsius}
      dict set dicokwd TEMPROSE  {TEMPROSE %s float {Dew temperature} Celsius}
      dict set dicokwd WINDDIR   {WINDDIR %s float {Wind direction (0=S 90=W 180=N 270=E)} deg}
      dict set dicokwd WINDSP    {WINDSP %s float {Windspeed} {m/s}}

      set kwd_list [dict keys $dicokwd]
      if {$kwd eq " "} {return $kwd_list}
      if {$kwd ni "$kwd_list"} {return "keyword \"$kwd\" {not in dictionnary}"}
      return [dict get $dicokwd $kwd]
   }

   #--------------------------------------------------------------------------
   #  setKeywords : dans l'entete de l'image
   #  pm simulimage cree les mots cles EQUINOX RADECSYS CTYPE1 CTYPE2 CUNIT1 CUNIT2 LONPOLE CATASTAR
   #--------------------------------------------------------------------------
   proc setKeywords { {bufNo 1} } {
      variable myKeywords

      #--   pour l'appel de cette proc a partir d'un autre plugin
      #     si collector est ouvert
      #--   cree l'array s'il existe pas
      if {[array exists myKeywords] == 0} {
         createKeywords
      }

      if {[buf$bufNo imageready]} {
         foreach kwd [lsort -dictionary [array names myKeywords]] {
            if {[catch {
               buf$bufNo setkwd [lindex [array get myKeywords $kwd] 1]
            } ErrInfo]} {
               ::console::affiche_resultat "$kwd $ErrInfo\n"
            }
         }
      }
   }

   #--------------------------------------------------------------------------
   #  calibrationAstro
   #  Inscrit le nombre d'etoiles et les coefficients secondaires dans l'en-tete
   #--------------------------------------------------------------------------
   proc calibrationAstro { bufNo ext cdpath cattype } {
      global audace

      set rep $audace(rep_images)
      set mypath "."
      set sky0 dummy0
      set sky dummy
      catch {buf$bufNo delkwd CATASTAR}
      buf$bufNo save [ file join ${mypath} ${sky0}$ext ]
      createFileConfigSextractor
      buf$bufNo save [ file join ${mypath} ${sky}$ext ]
      sextractor [ file join $mypath $sky0$ext ] -c [ file join $mypath config.sex ]
      ttscript2 "IMA/SERIES \"$mypath\" \"$sky\" . . \"$ext\" \"$mypath\" \"$sky\" . \"$ext\" CATCHART \"path_astromcatalog=$cdpath\" astromcatalog=$cattype \"catafile=${mypath}/c$sky$ext\" "
      ttscript2 "IMA/SERIES \"$mypath\" \"$sky\" . . \"$ext\" \"$mypath\" \"$sky\" . \"$ext\" ASTROMETRY objefile=catalog.cat nullpixel=-10000 delta=5 epsilon=0.0002 file_ascii=ascii.txt"
      buf$bufNo load [file join ${mypath} ${sky}$ext ]

      #--   provisoire, en attendant la correction de simulimage
      buf$bufNo delkwd RADESYS
      buf$bufNo setkwd [list EQUINOX J2000.0 string "System of equatorial coordinates" ""]

      #--   supprime les fichiers intermediaires
      set fileList [list ascii.txt catalog.cat com.lst dif.lst \
         eq.lst matrix.txt obs.lst pointzero.lst usno.lst  \
         signal.sex xy.lst config.param config.sex default.nnw]

      foreach file $fileList {
         if {[file exists [file join $rep $file]]} {
            file delete [file join $rep $file]
         }
      }

      #--   Suppression des fichiers 'dummy'
      foreach file [list ${sky} c${sky} ${sky}0] {
         if {[file exists [file join $mypath $file$ext ] ] } {
            file delete [ file join $mypath $file$ext ]
         }
      }
   }

   #--------------------------------------------------------------------------
   #  editKeywords
   #  Edite le contenu des mots cles dans la console
   #  Commande du bouton 'Editer les mots cles'
   #--------------------------------------------------------------------------
   proc editKeywords {} {
      variable myKeywords
      variable private
      global caption conf

      set This $private(This).kwd

      if {[winfo exists $This]} {destroy $This}
      if {![info exists conf(collector,kwdposition)]} {
         set conf(collector,kwdposition) "400x115+100+100"
      }

      toplevel $This
      wm resizable $This 1 1
      wm title $This "$caption(collector,kwds)"
      wm minsize $This 400 115
      wm transient $This $private(This)
      wm geometry $This $conf(collector,kwdposition)
      wm protocol $This WM_DELETE_WINDOW "::collector::close $This"

      frame $This.usr -borderwidth 0 -relief raised
      pack $This.usr -fill both -expand 1

      set tbl $This.usr.choix
      scrollbar $This.usr.vscroll -command "$tbl yview"
      scrollbar $This.usr.hscroll -orient horizontal -command "$tbl xview"

      #--- definit la structure et les caracteristiques de la tablelist des mots cles
      ::tablelist::tablelist $tbl -borderwidth 2 \
         -columns [list \
            0 "$caption(collector,kwds)" left \
            0 "$caption(collector,kwdvalue)" left \
            0 "$caption(collector,kwdtype)" center \
            0 "$caption(collector,kwdcmt)" left \
            0 "$caption(collector,kwdunit)" center] \
         -xscrollcommand [list $This.usr.hscroll set] \
         -yscrollcommand [list $This.usr.vscroll set] \
         -exportselection 0 -setfocus 1 \
         -activestyle none -stretch {1}

      #--   positionne et formate les widgets
      grid $tbl -row 0 -column 0 -sticky news
      #--   seule la liste occupe l'espace disponible
      grid columnconfigure $This.usr 0 -weight 1
      grid rowconfigure $This.usr 0 -weight 1
      #--   contraint les dimensions
      grid $This.usr.vscroll -row 0 -column 1 -sticky ns
      grid columnconfigure $This.usr 1 -minsize 18
      grid $This.usr.hscroll -row 1 -column 0 -sticky news
      grid rowconfigure $This.usr 1 -minsize 18

      #--   remplit la tablelist
      foreach cible [lsort -dictionary [array names myKeywords]] {
         $tbl insert end [lindex [array get myKeywords $cible] 1]
      }

      #--- Focus
      focus $This

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   proc close { This } {
      global conf

      set conf(collector,kwdposition) [wm geometry $This]
      destroy $This
   }

