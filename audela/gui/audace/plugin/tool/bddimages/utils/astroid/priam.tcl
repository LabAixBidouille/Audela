#--------------------------------------------------
# source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/priam/priam.tcl
#--------------------------------------------------
#
# Fichier        : priam.tcl
# Description    : Utilisation de Priam pour faire l astrometrie
# Auteur         : Frederic Vachier
# Mise à jour $Id: priam.tcl 6795 2011-02-26 16:05:27Z fredvachier $
#

namespace eval ::priam {


# ** Exemple du fichier science.mes

# #? Centroid measures formatted for Priam
# #?   Source: Tasp/idl - mai 2004
# #? Object: 1446 Sillanpaa 
# #
# #> orientation: wn
# #
# #! Frame: /observ/ohp/T120/2009/test/n1/p68484f1.fits
# 2454908.5137460064   20.00 1013.500  35.0   0.57000
# S 2.618036E+02 6.804010E-02 6.224708E+02 8.501132E-02 4.471942E+00 3.288280E+00 1.769230E+01 NewObj
# R 6.797814E+02 3.830099E-03 8.745620E+02 4.537117E-03 3.725335E+00 4.525925E+00 1.185362E+01 Star_1

# ** Exemple fichier local.cat

# 2MASS_12585626+0052218    12 58 56.261520 +00 52 21.87840 0.00 0.00 2451545.50  100.0 100.0  0.00  0.00  16.083 ?    0.00 0.0

# ** Exemple fichier cnd.obs

# #
# # Conditions observationnelles
# # 
# # objet : astrometrie de 2008 FU6 au T1m Pic du midi
# # date  : 11 avril 2011
# #
#   code           : 586
# lieu           : Pic du midi
# station        : 0.0 0.0 0.0
# observateurs   : F. Vachier
# reduction      : F. Vachier & J. Berthier
# #
# # Instrumentation
# #
#   type           : T1m
# focale         : 12.5
# diametre       : 1.0
# echelle        : 0.44
# orientation    : 0.00 
# taille CCD     : 1024 1024
# #

# {IMG {105.94394 4.34557 5 +14.0326 0.036} 
#      {4133 3 1455.26 1236.98 +12.432 0.036 2483.4 81.3 105.94394 4.34557 +14.0326 +13.8275 0.3848 +13.8527 0.3839 221 150 994.2 +0.63 -0.08 -0.16 +1.29 +0.94 -12.1 3.26 0}} 
#      {USNOA2 {105.94394 4.34557 5.0 +14.0326 0.3848} {}} 
#      {PHOTOM {} {1455.214748 1237.066546 2.946869 2.521896 2.7343825 1467.000000 0 1239.000000 227.0 38.759163 37.8491145436 5.85667961922 3.26 0.0976624473377}}
   

proc ::priam::create_file_oldformat { listsources science stars } {

   global bddconf audace

   # constantes provisoires
   set axes "wn"
   set imagefilename "toto.gif"
   set dateobsjd 2454908.5137460064
   set temperature 20.00
   set pression 1013.500
   set humidity 35.0
   set bandwith 0.57000

   # creation du fichier de conditions initiales (cnd.obs)
   set filecnd [ file join $audace(rep_travail) cnd.obs ]
   set chan0 [open $filecnd w]
   puts $chan0 "#? Centroid measures formatted for Priam"
   puts $chan0 "# Conditions observationnelles"
   puts $chan0 "# objet : astrometrie de 2008 FU6 au T1m Pic du midi"
   puts $chan0 "# date  : 11 avril 2011"
   puts $chan0 "#"
   puts $chan0 "code           : 586"
   puts $chan0 "lieu           : Pic du midi"
   puts $chan0 "station        : 0.0 0.0 0.0"
   puts $chan0 "observateurs   : F. Vachier"
   puts $chan0 "reduction      : F. Vachier & J. Berthier"
   puts $chan0 "#"
   puts $chan0 "# Instrumentation"
   puts $chan0 "#"
   puts $chan0 "type           : T1m"
   puts $chan0 "focale         : 12.5"
   puts $chan0 "diametre       : 1.0"
   puts $chan0 "echelle        : 0.44"
   puts $chan0 "orientation    : 0.00"
   puts $chan0 "taille CCD     : 1024 1024"
   close $chan0

   # creation du fichier d'exec de priam (cmd.priam)
   set formatfile bddimages
   
   set filepriam [ file join $audace(rep_travail) cmd.priam ]
   set chan0 [open $filepriam w]
   puts $chan0 "#!/bin/sh"
   puts $chan0 "LD_LIBRARY_PATH=/usr/local/lib:$::tools_astrometry::ifortlib"
   puts $chan0 "export LD_LIBRARY_PATH"
   puts $chan0 "priam -lang en -format priam -m 1 -fc cnd.obs -fm science.mes -r ./ -fcat local.cat -rcat ./ -s fichier:$formatfile -te 1"
   close $chan0

   set filenametmp [ file join $audace(rep_travail) science.mes ]
   # creation du fichier de mesures
   set filemes [ file join $audace(rep_travail) science.mes ]
   set chan0 [open $filemes w]
   puts $chan0 "#? Centroid measures formatted for Priam"
   puts $chan0 "#?   Source: Astroid - jan. 2012"
   puts $chan0 "#? Object: $science"
   puts $chan0 "#"
   puts $chan0 "#> orientation: $axes"
   puts $chan0 "#"
   puts $chan0 "#! Frame: $imagefilename"
   puts $chan0 "$dateobsjd $temperature $pression  $humidity $bandwith"

   # creation du fichier stellaire
   set filelocal [ file join $audace(rep_travail) local.cat ]
   set chan1 [open $filelocal w]

   set index 0
   set indexsc 0
   set newsources {}
   set sources [lindex $listsources 1]
   foreach s $sources {
      foreach cata $s {
         gren_info "CATA = [lindex $cata 0]\n"
         if {[lindex $cata 0] == $stars} {
            foreach u $s {
               gren_info "PHOTOM ? = $u\n"
               if {[lindex $u 0] == "PHOTOM"} {
                  set odata [lindex $u 2]
                  incr index
                  set xsm [lindex $odata 0]
                  set ysm [lindex $odata 1]
                  set xsmerr 0.01
                  set ysmerr 0.01
                  set fwhmx [lindex $odata 2]
                  set fwhmy [lindex $odata 3]
                  set fluxintegre [lindex $odata 5]
                  puts $chan0 "R $xsm $xsmerr $ysm $ysmerr $fwhmx $fwhmy $fluxintegre ${stars}_${index}"

                  set data [lindex $cata 2]
                  set ra  [mc_angle2hms [lindex $data 0]] 
                  set dec [mc_angle2dms [lindex $data 1]]
                  set mag [lindex $data 3]
                  puts $chan1 "${stars}_${index} $ra $dec 0.00 0.00 2451545.50  100.0 100.0  0.00  0.00  $mag ?    0.00 0.0"
               }
            }
         }
         if {[lindex $cata 0] == $science} {
            foreach u $s {
               if {[lindex $u 0] == "PHOTOM"} {
                  set odata [lindex $u 2]
                  incr indexsc
                  set xsm [lindex $odata 0]
                  set ysm [lindex $odata 1]
                  set xsmerr 0.01
                  set ysmerr 0.01
                  set fwhmx [lindex $odata 2]
                  set fwhmy [lindex $odata 3]
                  set fluxintegre [lindex $odata 5]
                  puts $chan0 "S $xsm $xsmerr $ysm $ysmerr $fwhmx $fwhmy $fluxintegre ${science}_${indexsc}"
               }
            }
         }
         
      }
   }

   close $chan0
   close $chan1
}


}
