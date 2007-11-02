#
# Fichier : apncode.tcl
# Description : Transcodage des variables de commande des APN
# Auteur : Raymond ZACHANTKE
# Mise a jour $Id: apncode.tcl,v 1.7 2007-11-02 23:20:40 michelpujol Exp $
#

#::acqapn::VerifData
#--- Vérification des valeurs
#
proc VerifData { reglage } {
   variable private

   switch -exact $reglage {
      lens        { set private(dzoom)         [::acqapn::Dzoom $private(lens)] }
      metering    { set private(code_metering) [::acqapn::Metering $private(metering)] }
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
   variable private

   #--- La combinaison format+compression est vérifiée
   set cmdresol "$private(format)-$private(compression)"
   switch -exact $cmdresol {
      VGA-Basic   { set private(resolution) "1" }
      VGA-Normal  { set private(resolution) "2" }
      VGA-Fine    { set private(resolution) "3" }
      XGA-Basic   { set private(resolution) "7" }
      XGA-Normal  { set private(resolution) "8" }
      XGA-Fine    { set private(resolution) "9" }
      SXGA-Basic  { set private(resolution) "4" }
      SXGA-Normal { set private(resolution) "5" }
      SXGA-Fine   { set private(resolution) "6" }
      UXGA-Basic  { set private(resolution) "10" }
      UXGA-Normal { set private(resolution) "11" }
      UXGA-Fine   { set private(resolution) "12" }
      3:2-Basic   { set private(resolution) "26" }
      3:2-Normal  { set private(resolution) "27" }
      3:2-Fine    { set private(resolution) "28" }
      3:2-Hi      { set private(resolution) "38" }
      MAX-Basic   { set private(resolution) "29" }
      MAX-Normal  { set private(resolution) "30" }
      MAX-Fine    { set private(resolution) "31" }
      MAX-Hi      { set private(resolution) "33" }
      MAX-Raw     { set private(resolution) "55" }
      default     { set private(resolution) "-1" ; ::acqapn::ErrComm 3 }
   }
}

#
#::acqapn::ReverseDzoom
#--- Décodage du digital zoom en lens
#
proc ReverseDzoom { } {
   variable private

   switch -exact $private(dzoom) {
      0       { set private(lens) "Telephoto" ; set private(dzoom) "8" }
      2       { set private(lens) "Wide" }
      4       { set private(lens) "FishEye" }
      default { ::acqapn::ErrComm 4 }
   }
}

#
#::acqapn::ReverseResolution
#---Définition du format et de la compresion en fonction de la résolution
#
proc ReverseResolution { } {
   variable private

   switch -exact $private(init,resolution) {
      1       { set private(init,format) "VGA"  ; set private(init,compression) "Basic" }
      2       { set private(init,format) "VGA"  ; set private(init,compression) "Normal" }
      3       { set private(init,format) "VGA"  ; set private(init,compression) "Fine" }
      4       { set private(init,format) "SXGA" ; set private(init,compression) "Basic" }
      5       { set private(init,format) "SXGA" ; set private(init,compression) "Normal" }
      6       { set private(init,format) "SXGA" ; set private(init,compression) "Fine" }
      7       { set private(init,format) "XGA"  ; set private(init,compression) "Basic" }
      8       { set private(init,format) "XGA"  ; set private(init,compression) "Normal" }
      9       { set private(init,format) "XGA"  ; set private(init,compression) "Fine" }
      10      { set private(init,format) "UXGA" ; set private(init,compression) "Basic" }
      11      { set private(init,format) "UXGA" ; set private(init,compression) "Normal" }
      12      { set private(init,format) "UXGA" ; set private(init,compression) "Fine" }
      26      { set private(init,format) "3:2"  ; set private(init,compression) "Basic" }
      27      { set private(init,format) "3:2"  ; set private(init,compression) "Normal" }
      28      { set private(init,format) "3:2"  ; set private(init,compression) "Fine" }
      29      { set private(init,format) "MAX"  ; set private(init,compression) "Basic" }
      30      { set private(init,format) "MAX"  ; set private(init,compression) "Normal" }
      31      { set private(init,format) "MAX"  ; set private(init,compression) "Fine" }
      33      { set private(init,format) "MAX"  ; set private(init,compression) "Hi" }
      38      { set private(init,format) "3:2"  ; set private(init,compression) "Hi" }
      55      { set private(init,format) "MAX"  ; set private(init,compression) "Raw" }
      default { ::acqapn::ErrComm 5 }
   }
}

#
#::acqapn::Exposure
#--- Cette commande est appelée pour définir la comande et la valeur d'exposition
#
proc Exposure { var exposure } {
   variable private
   global panneau

   set valeur [expr int($exposure*10)]
   set code_exposure [expr abs($valeur)]
   set exposurecmd  "exposure+"
   if { $valeur < "0" } { set exposurecmd "exposure-" }
   set panneau(coolpix$var,exposurecmd) $exposurecmd
   set private($var,code_exposure) $code_exposure
}

