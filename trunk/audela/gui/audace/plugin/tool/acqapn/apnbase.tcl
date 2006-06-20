#
# Fichier : apnbase.tcl
# Description : Base de donn�es d'APN CoolPix de Nikon
# Auteurs : Raymond ZACHANTKE
# Mise a jour $Id: apnbase.tcl,v 1.2 2006-06-20 20:32:55 robertdelmas Exp $
#

#--- Liste des APN
set apn_base(model) "Coolpix-775 Coolpix-880 Coolpix-885 Coolpix-950 Coolpix-990 Coolpix-995 Coolpix-2500 Coolpix-3100 Coolpix-3500 Coolpix-4300 Coolpix-4500 Coolpix-5000 Coolpix-5700"

#--- R�glages panneau li�s au choix du mod�le
set apn_base(ccd_size) "1600x1200 2048x1536 2048x1536 1600x1200 2048x1536 2048x1536 1600x1200 2048x1536 2048x1536 2272x1704 2272x1704 2560x1920 2560x1920"
set apn_base(pixel_size) "3.300 3.563 3.559 3.955 3.531 3.559 3.275 2.578 2.578 3.211 3.148 3.409 3.406"
set apn_base(H_focus) "5.8 20.0 24.0 21.0 24.0 32.0 16.8 17.4 16.8 24.0 32.0 21.4 70.7"
set apn_base(L_focus) "5.8 8.0 8.0 7.0 8.0 8.0 5.6 5.8 5.6 8.0 7.85 7.1 8.8"

#--- Liste ordonn�e des variables affich�es dans le combobox 'variables'
set apn_base(variables) "lens flash mode format compression focus metering whitebalance adjust"

#--- Liste des options sp�cifiques � chaque variable
#--- Ajustement des images
set apn_base(adjust) "Standard Contrast+ Contrast- Brightness+ Brightness-"
#--- Compression des images
set apn_base(compression) "Basic Normal Fine Hi Raw"
#--- R�glages du flash
set apn_base(flash) "Auto Off Force AntiRedeye SlowSync"
#--- Mode de focalisation
set apn_base(focus) "Normal Infinity Macro"
#--- Format des images
set apn_base(format) "VGA XGA SXGA UXGA 3:2 MAXI"
#--- Objectif
set apn_base(lens) "Telephoto FishEye Wide"
#--- Mode de mesure de la lumi�re
set apn_base(metering) "Center Spot Matrix Spot-AF-Area"
#--- Options concernant l'affichage sur le LCD
set apn_base(mode) "Record Play Thumbnail Off"
#--- Balance des blancs
set apn_base(whitebalance) "Auto Sunny Incandescent Fluorescent Flash Preset Cloudy"

