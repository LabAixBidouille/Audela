#
# Fichier : apncode.tcl
# Description : Transcodage des variables de commande des APN
# Auteurs : Raymond Zachantke
# Date de mise a jour : 25 octobre 2005
#

	#::AcqAPN::VerifData
	#--- Vérification des valeurs
	#
	proc VerifData { reglage } {
	   global confCam

		switch -exact $reglage {
			lens 		{ set confCam(apn,dzoom) [::AcqAPN::Dzoom $confCam(apn,lens)] }
			metering 	{ set confCam(apn,code_metering) [::AcqAPN::Metering $confCam(apn,metering)] }
			format	{ ::AcqAPN::Resolution }
			compression	{ ::AcqAPN::Resolution }
		}
	}

	#::AcqAPN::Dzoom
	#--- Codage du digital zoom à partir de lens
	#
	proc Dzoom { lens } {
		
		switch -exact $lens {
      		FishEye	{ set dzoom "2" }
			Wide    	{ set dzoom "4" }
			Telephoto	{ set dzoom "8" }
		}
		return $dzoom
	}

	#::AcqAPN::Metering
	#--- Codage du digital metering à partir de metering
	#
	proc Metering { metering } {
		
		switch -exact $metering {
      		Center		{ set code "2" }
			Spot     		{ set code "3" }
			Matrix		{ set code "5" }
			Spot-AF-Area	{ set code "6" }
		}
		return $code
	}

	#
   #::AcqAPN::Resolution
   #--- Cette commande est appelée pour définir la comande de résolution
   #--- en fonction du format et de la compression 
   #
   proc Resolution { } {
   	global confCam
        
      #--- La combinaison format+compression est vérifiée
      set cmdresol "$confCam(apn,format)-$confCam(apn,compression)"
     	switch -exact $cmdresol {
      	VGA-Basic		{ set confCam(apn,resolution) "1" }
      	VGA-Normal		{ set confCam(apn,resolution) "2" }
      	VGA-Fine 		{ set confCam(apn,resolution) "3" }
      	XGA-Basic		{ set confCam(apn,resolution) "7" }
      	XGA-Normal		{ set confCam(apn,resolution) "8" }
      	XGA-Fine		{ set confCam(apn,resolution) "9" }
      	SXGA-Basic		{ set confCam(apn,resolution) "4" }
      	SXGA-Normal		{ set confCam(apn,resolution) "5" }
      	SXGA-Fine		{ set confCam(apn,resolution) "6" }
      	UXGA-Basic		{ set confCam(apn,resolution) "10" }
      	UXGA-Normal		{ set confCam(apn,resolution) "11" }
      	UXGA-Fine		{ set confCam(apn,resolution) "12" }
      	3:2-Basic		{ set confCam(apn,resolution) "26" }
      	3:2-Normal		{ set confCam(apn,resolution) "27" }
      	3:2-Fine		{ set confCam(apn,resolution) "28" }
      	3:2-Hi		{ set confCam(apn,resolution) "38" }
      	MAX-Basic		{ set confCam(apn,resolution) "29" }
      	MAX-Normal		{ set confCam(apn,resolution) "30" }
      	MAX-Fine		{ set confCam(apn,resolution) "31" }
      	MAX-Hi		{ set confCam(apn,resolution) "33" }
      	MAX-Raw		{ set confCam(apn,resolution) "55" }
      	default		{ set confCam(apn,resolution) "-1" ; ::AcqAPN::ErrComm 3 }
		}
  	}
   	
  	#
	#::AcqAPN::ReverseDzoom
	#--- Décodage du digital zoom en lens
	#
	proc ReverseDzoom { } {
		global confCam
		
		switch -exact $confCam(apn,dzoom) {
			0		{ set confCam(apn,lens) "Telephoto" ; set confCam(apn,dzoom) "8" }
			2   		{ set confCam(apn,lens) "Wide" }      			
      		4		{ set confCam(apn,lens) "FishEye" }
			default	{ ::AcqAPN::ErrComm 4 }
		}
	}
	
	#
  	#::AcqAPN::ReverseResolution
  	#---Définition du format et de la compresion en fonction de la résolution 
  	#
	proc ReverseResolution { } {
		global confCam
		
		switch -exact $confCam(apn_init,resolution) {	
		1		{ set confCam(apn_init,format) "VGA" ; set confCam(apn_init,compression) "Basic" }
      	2		{ set confCam(apn_init,format) "VGA" ; set confCam(apn_init,compression) "Normal" }
      	3		{ set confCam(apn_init,format) "VGA" ; set confCam(apn_init,compression) "Fine" }
      	4		{ set confCam(apn_init,format) "SXGA" ; set confCam(apn_init,compression) "Basic" }
      	5		{ set confCam(apn_init,format) "SXGA" ; set confCam(apn_init,compression) "Normal" }
      	6		{ set confCam(apn_init,format) "SXGA" ; set confCam(apn_init,compression) "Fine" }
      	7		{ set confCam(apn_init,format) "XGA" ; set confCam(apn_init,compression) "Basic" }
      	8		{ set confCam(apn_init,format) "XGA" ; set confCam(apn_init,compression) "Normal" }
      	9		{ set confCam(apn_init,format) "XGA" ; set confCam(apn_init,compression) "Fine" }
      	10		{ set confCam(apn_init,format) "UXGA" ; set confCam(apn_init,compression) "Basic" }
      	11		{ set confCam(apn_init,format) "UXGA" ; set confCam(apn_init,compression) "Normal" }
      	12		{ set confCam(apn_init,format) "UXGA" ; set confCam(apn_init,compression) "Fine" }
      	26		{ set confCam(apn_init,format) "3:2" ; set confCam(apn_init,compression) "Basic" }
      	27		{ set confCam(apn_init,format) "3:2" ; set confCam(apn_init,compression) "Normal" }
      	28		{ set confCam(apn_init,format) "3:2" ; set confCam(apn_init,compression) "Fine" }
  		29		{ set confCam(apn_init,format) "MAX" ; set confCam(apn_init,compression) "Basic" }
      	30		{ set confCam(apn_init,format) "MAX" ; set confCam(apn_init,compression) "Normal" }
      	31		{ set confCam(apn_init,format) "MAX" ; set confCam(apn_init,compression) "Fine" }
    		33		{ set confCam(apn_init,format) "MAX" ; set confCam(apn_init,compression) "Hi" }      		
      	38		{ set confCam(apn_init,format) "3:2" ; set confCam(apn_init,compression) "Hi" }
       	55		{ set confCam(apn_init,format) "MAX" ; set confCam(apn_init,compression) "Raw" }
       	default	{ ::AcqAPN::ErrComm 5 }
     	}
   }
    	
  	#
  	#::AcqAPN::Exposure
  	#--- Cette commande est appelée pour définir la comande et la valeur d'exposition 
  	#
  	proc Exposure { var exposure } {
  	   global confCam panneau
  	   
      set valeur [expr int($exposure*10)] 
     	set code_exposure [expr abs($valeur)]  	
		set exposurecmd  "exposure+"
     	if { $valeur < "0" } { set exposurecmd  "exposure-" }   	
     	set panneau(apn$var,exposurecmd) $exposurecmd     	
     	set confCam(apn$var,code_exposure) $code_exposure
  	}

