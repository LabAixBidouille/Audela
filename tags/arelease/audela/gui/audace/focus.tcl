#
# Fichier : focus.tcl
# Description : Centralise les commandes du focus du telescope
#
#    Gere les variables :
#       audace(focus,speed) 
#       audace(focus,labelspeed) 
#       audace(focus,nbpas1) 
#       audace(focus,nbpas2)
#    
# Date de mise a jour : 08 fevrier 2006
#

namespace eval ::focus {
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_caption) focus.cap ]

   proc init { } {
      global audace
      global caption

      set audace(focus,speed)      "1"
      set audace(focus,labelspeed) "$caption(focus,interro)"
      set audace(focus,nbpas1)     "00000"
      set audace(focus,nbpas2)     ""
   }   

   #------------------------------------------------------------
   #  move
   #     si command = "-" , demarre le mouvement du focus en intra focale
   #     si command = "+" , demarre le mouvement du focus en extra focale
   #     si command = "stop" , arrete le mouvement 
   #------------------------------------------------------------
   proc move { command } {
      global conf
      global audace
    
      if { [ ::tel::list ] != "" } {
         if { $audace(focus,labelspeed) != "?" } {
            if { $conf(audecom,inv_rot) == "0" } {
               if { $command == "-" } {
                 tel$audace(telNo) focus move - $audace(focus,speed)
               } elseif { $command == "+" } {
                 tel$audace(telNo) focus move + $audace(focus,speed)
               } elseif { $command == "stop" } {
                 tel$audace(telNo) focus stop
               }
            } else {
               if { $command == "-" } {
                 tel$audace(telNo) focus move + $audace(focus,speed)
               } elseif { $command == "+" } {
                 tel$audace(telNo) focus move - $audace(focus,speed)
               } elseif { $command == "stop" } {
                 tel$audace(telNo) focus stop
               }
            }
         }
      } else {
         if { $command != "stop" } {
            ::confTel::run 
           # tkwait window $audace(base).confTel
         }  
      }
   }

   #------------------------------------------------------------
   #  goto
   #     envoie le focus a la position audace(focus,nbpas2)
   #     et met la nouvelle valeur de la position dans la variable audace(focus,nbpas1)
   #------------------------------------------------------------
   proc goto { } {
      global conf
      global audace
   
      #--- Direction de focalisation prioritaire : extrafocale
      if { $conf(audecom,intra_extra) == "1" } {
         if { $audace(focus,nbpas2) > "$audace(focus,nbpas1)" } {
            #--- Envoie la foc a la consigne
            tel$audace(telNo) focus goto $audace(focus,nbpas2)
         } else {
            #--- Depasse la consigne de $conf(audecom,dep_val) pas pour le rattrapage des jeux
            #--- 250 pas correspondent a 1/2 tour du moteur de focalisation
            set nbpas3 [ expr $audace(focus,nbpas2)-$conf(audecom,dep_val) ]
            if { $nbpas3 < "-32767" } {
               set nbpas3 "-32767"
            }
            tel$audace(telNo) focus goto $nbpas3
            #--- Envoie la foc a la consigne
            tel$audace(telNo) focus goto $audace(focus,nbpas2)
         }
      #--- Direction de focalisation prioritaire : intrafocale
      } else {
         if { $audace(focus,nbpas2) < "$audace(focus,nbpas1)" } {
            #--- Envoie la foc a la consigne
            tel$audace(telNo) focus goto $audace(focus,nbpas2)
         } else {
            #--- Depasse la consigne de $conf(audecom,dep_val) pas pour le rattrapage des jeux
            #--- 250 pas correspondent a 1/2 tour du moteur de focalisation
            set nbpas3 [ expr $audace(focus,nbpas2) + $conf(audecom,dep_val) ]
            if { $nbpas3 > "32767" } {
               set nbpas3 "32767"
            }
            tel$audace(telNo) focus goto $nbpas3
            #--- Envoie la foc a la consigne
            tel$audace(telNo) focus goto $audace(focus,nbpas2)
         }
      }
      #--- Boucle tant que la foc n'est pas arretee
      set foc0 [ tel$audace(telNo) focus coord ]
      after 500
      set foc1 [ tel$audace(telNo) focus coord ]
      while { $foc0 != "$foc1" } {
         set foc0 $foc1
         after 500
         set foc1 [ tel$audace(telNo) focus coord ]
      }
      set audace(focus,nbpas1) $foc1
      split $audace(focus,nbpas1) "\n"
      set audace(focus,nbpas1) [ lindex $audace(focus,nbpas1) 0 ]
   }

   #------------------------------------------------------------
   #  incrementSpeed
   #     incremente la vitesse du focus et appelle la procedure setSpeed
   #------------------------------------------------------------
   proc incrementSpeed { } {
      global conf
      global audace

      if { [ ::tel::list ] != "" } {
         if { $conf(telescope) == "audecom" } {
            if { $audace(focus,speed) == "0" } {
               ::focus::setSpeed "1"
            } elseif { $audace(focus,speed) == "1" } {
               ::focus::setSpeed "0"
            } else {
               ::focus::setSpeed "1"
            }
         } elseif { $conf(telescope) == "lx200" } {
            if { $audace(focus,speed) == "0" } { 
               ::focus::setSpeed "1"
            } else { 
               ::focus::setSpeed "0"
            }
         } else  {
            #--- Inactif pour autres telescopes
            ::focus::setSpeed "0"
         }
      } else {
         ::confTel::run 
         tkwait window $audace(base).confTel
         set audace(focus,speed) "0"
      }
   }

   #------------------------------------------------------------
   #  setSpeed
   #     change la vitesse du focus 
   #     met a jour les variables audace(focus,speed), audace(focus,labelspeed)
   #     change la vitesse de mouvement du telescope 
   #------------------------------------------------------------
   proc setSpeed { { value "0" } } {
      global conf
      global audace
      global caption
      
      if { [ ::tel::list ] != "" } {
         if { $conf(telescope) == "audecom" } {
            if { $value == "1" } {
               set audace(focus,speed) "1"
               set audace(focus,labelspeed) "$caption(focus,x5)" 
               ::telescope::setSpeed "2"
            } else {
               set audace(focus,speed) "0"
               set audace(focus,labelspeed) "$caption(focus,x1)" 
               ::telescope::setSpeed "1"
            }
         } elseif { $conf(telescope) == "lx200" } {
            if { $value == "1" } { 
               set audace(focus,speed) "1"
               set audace(focus,labelspeed) "2" 
               ::telescope::setSpeed "3"
            } elseif { $value == "0" } { 
               set audace(focus,speed) "0"
               set audace(focus,labelspeed) "1" 
               ::telescope::setSpeed "2"
            }
         } else {
            set audace(focus,speed) "0"
            set audace(focus,labelspeed) "$caption(focus,interro)"
         }
      } else {
         ::confTel::run 
         tkwait window $audace(base).confTel
         set audace(focus,speed) "0"
      }
   }
   
   #------------------------------------------------------------
   #  possedeControleEtendu
   #     retourne 1 si le telescope possede un controle etendu du focus (AudeCom)
   #     retourne 0 sinon
   #------------------------------------------------------------
   proc possedeControleEtendu { } {
      global conf

      if { $conf(telescope) == "audecom"  } {
         set result "1"
      } else {
         set result "0"
      }
   }

}

::focus::init

