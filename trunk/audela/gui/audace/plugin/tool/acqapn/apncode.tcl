#
# Fichier : apncode.tcl
# Description : Transcodage des variables de commande des APN
# Auteur : Raymond ZACHANTKE
# Mise a jour $Id: apncode.tcl,v 1.6 2007-05-16 20:50:29 robertdelmas Exp $
#

#::acqapn::VerifData
#--- Vérification des valeurs
#
proc VerifData { reglage } {
   global confCam

   switch -exact $reglage {
      lens        { set confCam(coolpix,dzoom)         [::acqapn::Dzoom $confCam(coolpix,lens)] }
      metering    { set confCam(coolpix,code_metering) [::acqapn::Metering $confCam(coolpix,metering)] }
      format      { ::acqapn::Resolution }
      compression { ::acqapn::Resolution }
   }
}

#::acqapn::Dzoom
#--- Codage du digital zoom à partir de lens
#
proc Dzoom { lens } {
   switch -exact $lens {
      FishEye   { set dzoom "2" }
      Wide      { set dzoom "4" }
      Telephoto { set dzoom "8" }
   }
   return $dzoom
}

#::acqapn::Metering
#--- Codage du digital metering à partir de metering
#
proc Metering { metering } {
   switch -exact $metering {
      Center       { set code "2" }
      Spot         { set code "3" }
      Matrix       { set code "5" }
      Spot-AF-Area { set code "6" }
   }
   return $code
}

#
#::acqapn::Resolution
#--- Cette commande est appelée pour définir la comande de résolution
#--- en fonction du format et de la compression
#
proc Resolution { } {
   global confCam

   #--- La combinaison format+compression est vérifiée
   set cmdresol "$confCam(coolpix,format)-$confCam(coolpix,compression)"
   switch -exact $cmdresol {
      VGA-Basic   { set confCam(coolpix,resolution) "1" }
      VGA-Normal  { set confCam(coolpix,resolution) "2" }
      VGA-Fine    { set confCam(coolpix,resolution) "3" }
      XGA-Basic   { set confCam(coolpix,resolution) "7" }
      XGA-Normal  { set confCam(coolpix,resolution) "8" }
      XGA-Fine    { set confCam(coolpix,resolution) "9" }
      SXGA-Basic  { set confCam(coolpix,resolution) "4" }
      SXGA-Normal { set confCam(coolpix,resolution) "5" }
      SXGA-Fine   { set confCam(coolpix,resolution) "6" }
      UXGA-Basic  { set confCam(coolpix,resolution) "10" }
      UXGA-Normal { set confCam(coolpix,resolution) "11" }
      UXGA-Fine   { set confCam(coolpix,resolution) "12" }
      3:2-Basic   { set confCam(coolpix,resolution) "26" }
      3:2-Normal  { set confCam(coolpix,resolution) "27" }
      3:2-Fine    { set confCam(coolpix,resolution) "28" }
      3:2-Hi      { set confCam(coolpix,resolution) "38" }
      MAX-Basic   { set confCam(coolpix,resolution) "29" }
      MAX-Normal  { set confCam(coolpix,resolution) "30" }
      MAX-Fine    { set confCam(coolpix,resolution) "31" }
      MAX-Hi      { set confCam(coolpix,resolution) "33" }
      MAX-Raw     { set confCam(coolpix,resolution) "55" }
      default     { set confCam(coolpix,resolution) "-1" ; ::acqapn::ErrComm 3 }
   }
}

#
#::acqapn::ReverseDzoom
#--- Décodage du digital zoom en lens
#
proc ReverseDzoom { } {
   global confCam

   switch -exact $confCam(coolpix,dzoom) {
      0       { set confCam(coolpix,lens) "Telephoto" ; set confCam(coolpix,dzoom) "8" }
      2       { set confCam(coolpix,lens) "Wide" }
      4       { set confCam(coolpix,lens) "FishEye" }
      default { ::acqapn::ErrComm 4 }
   }
}

#
#::acqapn::ReverseResolution
#---Définition du format et de la compresion en fonction de la résolution
#
proc ReverseResolution { } {
   global confCam

   switch -exact $confCam(coolpix_init,resolution) {
      1       { set confCam(coolpix_init,format) "VGA"  ; set confCam(coolpix_init,compression) "Basic" }
      2       { set confCam(coolpix_init,format) "VGA"  ; set confCam(coolpix_init,compression) "Normal" }
      3       { set confCam(coolpix_init,format) "VGA"  ; set confCam(coolpix_init,compression) "Fine" }
      4       { set confCam(coolpix_init,format) "SXGA" ; set confCam(coolpix_init,compression) "Basic" }
      5       { set confCam(coolpix_init,format) "SXGA" ; set confCam(coolpix_init,compression) "Normal" }
      6       { set confCam(coolpix_init,format) "SXGA" ; set confCam(coolpix_init,compression) "Fine" }
      7       { set confCam(coolpix_init,format) "XGA"  ; set confCam(coolpix_init,compression) "Basic" }
      8       { set confCam(coolpix_init,format) "XGA"  ; set confCam(coolpix_init,compression) "Normal" }
      9       { set confCam(coolpix_init,format) "XGA"  ; set confCam(coolpix_init,compression) "Fine" }
      10      { set confCam(coolpix_init,format) "UXGA" ; set confCam(coolpix_init,compression) "Basic" }
      11      { set confCam(coolpix_init,format) "UXGA" ; set confCam(coolpix_init,compression) "Normal" }
      12      { set confCam(coolpix_init,format) "UXGA" ; set confCam(coolpix_init,compression) "Fine" }
      26      { set confCam(coolpix_init,format) "3:2"  ; set confCam(coolpix_init,compression) "Basic" }
      27      { set confCam(coolpix_init,format) "3:2"  ; set confCam(coolpix_init,compression) "Normal" }
      28      { set confCam(coolpix_init,format) "3:2"  ; set confCam(coolpix_init,compression) "Fine" }
      29      { set confCam(coolpix_init,format) "MAX"  ; set confCam(coolpix_init,compression) "Basic" }
      30      { set confCam(coolpix_init,format) "MAX"  ; set confCam(coolpix_init,compression) "Normal" }
      31      { set confCam(coolpix_init,format) "MAX"  ; set confCam(coolpix_init,compression) "Fine" }
      33      { set confCam(coolpix_init,format) "MAX"  ; set confCam(coolpix_init,compression) "Hi" }
      38      { set confCam(coolpix_init,format) "3:2"  ; set confCam(coolpix_init,compression) "Hi" }
      55      { set confCam(coolpix_init,format) "MAX"  ; set confCam(coolpix_init,compression) "Raw" }
      default { ::acqapn::ErrComm 5 }
   }
}

#
#::acqapn::Exposure
#--- Cette commande est appelée pour définir la comande et la valeur d'exposition
#
proc Exposure { var exposure } {
   global confCam panneau

   set valeur [expr int($exposure*10)]
   set code_exposure [expr abs($valeur)]
   set exposurecmd  "exposure+"
   if { $valeur < "0" } { set exposurecmd "exposure-" }
   set panneau(coolpix$var,exposurecmd) $exposurecmd
   set confCam(coolpix$var,code_exposure) $code_exposure
}

