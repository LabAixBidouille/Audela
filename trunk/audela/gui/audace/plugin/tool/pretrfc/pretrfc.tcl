#
# Fichier : pretrfc.tcl
# Description : Module de pretraitement automatique
# Auteurs : François COCHARD et Jacques MICHELET
# Date de mise a jour : 18 novembre 2005
#

#=====================================================================
#   Declaration du Namespace pretraitFC
#=====================================================================

package provide pretrfc 1.40

namespace eval ::pretraitFC {
   variable This
   variable fichier_log
   variable numero_version
   global audace

   source [ file join $audace(rep_plugin) tool pretrfc pretrfc.cap ]

   # Numéro de la version du logiciel
   set numero_version "1.40"

#***** Procédure DemarragePretraitFC *********************************
   proc DemarragePretraitFC { } {
	variable fichier_log
      variable log_id
      variable numero_version
	global audace caption

      # Lecture du fichier de configuration
      ::pretraitFC::RecuperationParametres

	# Gestion du fichier de log
	# Creation du nom de fichier log
      set nom_generique pretrfc
      # Heure à partir de laquelle on passe sur un nouveau fichier de log...
      set heure_nouveau_fichier 4
      set heure_courante [lindex [split $audace(tu,format,hmsint) h] 0]
      if {$heure_courante < $heure_nouveau_fichier} {
         # Si avant l'heure de changement... Je prends la date de la veille
         set formatdate [clock format [expr {[clock seconds] - 86400}] -format "%Y-%m-%d"]
      } else {
         # Sinon, je prends la date du jour
         set formatdate [clock format [clock seconds] -format "%Y-%m-%d"]
      }
    	set fichier_log $audace(rep_images)
    	append fichier_log "/" $nom_generique $formatdate ".log"

	# Ouverture
	if {[catch {open $fichier_log a} log_id]} {
	   Message console $caption(pretrfc,pbouvfichcons)
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
		-message $caption(pretrfc,pbouvfich)
# Note importante: Je détecte si j'ai un pb à l'ouverture du fichier, mais je ne sais
# pas traiter ce cas: Il faudrait interdire l'ouverture du panneau, mais le processus
# est déjà lancé à ce stade... Tout ce que je fais, c'est inviter l'utilisateur à
# changer d'outil !
      } else {
         # Entête du fichier
	   Message log $caption(pretrfc,ouvsess) $numero_version
  	   set date [clock format [clock seconds] -format "%A %d %B %Y"]
         set heure $audace(tu,format,hmsint)
	   Message log $caption(pretrfc,affheure) $date $heure
      }
   }
#***** Fin de la procédure DemarragePretraitFC ***********************

#***** Procédure ArretPretraitFC *************************************
   proc ArretPretraitFC { } {
	variable log_id
	global audace caption conf_pt_fc panneau

	# Fermeture du fichier de log
      set heure $audace(tu,format,hmsint)
# Je m'assure que le fichier se termine correctement, en particulier pour le cas où il y
# a eu un problème à l'ouverture (C'est un peu une rustine...)
      if {[catch {Message log $caption(pretrfc,finsess) $heure} bug]} {
	   Message console $caption(pretrfc,pbfermfichcons)
      } else {
         catch { close $log_id }
      }

      # Récupération de la position de la fenêtre de réglages
      ::pretraitFC::recup_position
      set conf_pt_fc(fenetrePretr,position) $panneau(pretraitFC,position)
      # Sauvegarde des paramètres dans le fichier de config
      ::pretraitFC::SauvegardeParametres
      # Fermeture de la fenêtre de prétraitement
      destroy $audace(base).fenetrePretr
   }
#***** Fin de la procédure ArretPretraitFC ***************************

#***** Procédure Init ************************************************
   proc Init { { in "" } } {
      createPanel $in.pretraitFC
   }
#***** Fin de la procédure Init **************************************

#***** Procédure createPanel *****************************************
   proc createPanel { this } {
      variable This
      global caption panneau

      set This $this
      #--- Largeur de l'outil en fonction de l'OS
      if { $::tcl_platform(os) == "Linux" } {
         set panneau(pretraitFC,largeur_outil) "130"
      } elseif { $::tcl_platform(os) == "Darwin" } {
         set panneau(pretraitFC,largeur_outil) "130"
      } else {
         set panneau(pretraitFC,largeur_outil) "101"
      }
      #---
      set panneau(menu_name,pretraitFC) $caption(pretrfc,menu)

      pretraitFCBuildIF $This
   }
#***** Fin de la procédure createPanel *******************************

#***** Procedure pack ************************************************
   proc pack { } {
      variable This
      global unpackFunction

      set unpackFunction ::pretraitFC::unpack
      set a_executer "pack $This -anchor center -expand 0 -fill y -side left"
      uplevel #0 $a_executer
   }
#***** Fin de la procedure pack **************************************

#***** Procedure unpack **********************************************
   proc unpack { } {
      variable This

      set a_executer "pack forget $This"
      uplevel #0 $a_executer
   }
#***** Fin de la procedure unpack ************************************

#***** Procedure recup_position **************************************
   proc recup_position { } {
      global audace panneau

      set panneau(pretraitFC,geometry) [ wm geometry $audace(base).fenetrePretr ]
      set deb [ expr 1 + [ string first + $panneau(pretraitFC,geometry) ] ]
      set fin [ string length $panneau(pretraitFC,geometry) ]
      set panneau(pretraitFC,position) "+[string range $panneau(pretraitFC,geometry) $deb $fin]"     
   }	
#***** Fin de la procedure recup_position ****************************

#***** Procédure fenetrePretr ****************************************
   proc fenetrePretr { } {
      global audace caption conf_pt_fc panneau

      if {[winfo exists $audace(base).fenetrePretr] == 0} {
         DemarragePretraitFC

         #---
         if { ! [ info exists conf_pt_fc(fenetrePretr,position) ] } { set conf_pt_fc(fenetrePretr,position) "+100+5" }

         set panneau(pretraitFC,position) $conf_pt_fc(fenetrePretr,position)

         if { [ info exists panneau(pretraitFC,geometry) ] } {
            set deb [ expr 1 + [ string first + $panneau(pretraitFC,geometry) ] ]
            set fin [ string length $panneau(pretraitFC,geometry) ]
            set panneau(pretraitFC,position) "+[string range $panneau(pretraitFC,geometry) $deb $fin]"     
         }

         #---
   	   toplevel $audace(base).fenetrePretr -class Toplevel -borderwidth 2 -relief groove
         wm geometry $audace(base).fenetrePretr $panneau(pretraitFC,position)
         wm resizable $audace(base).fenetrePretr 1 1
	   wm title $audace(base).fenetrePretr $caption(pretrfc,titrelong)

         wm protocol $audace(base).fenetrePretr WM_DELETE_WINDOW ::pretraitFC::ArretPretraitFC

         creeFenetrePrFC
      } else {
         focus $audace(base).fenetrePretr
      }
   }
#***** Fin de la procedure fenetrePretr ******************************

#***** Procedure RecuperationParametres ******************************
   proc RecuperationParametres { } {
      global audace conf_pt_fc

      # Initialisation
      if {[info exists conf_pt_fc]} {unset conf_pt_fc}
      # Ouverture du fichier de paramètres
      set fichier [file join $audace(rep_plugin) tool pretrfc pretrfc.ini]
      if {[file exists $fichier]} {source $fichier}
      # Creation des variables si elles n'existent pas
      if { ! [ info exists conf_pt_fc(nbPLU) ]  }          { set conf_pt_fc(nbPLU)           "5" }
      if { ! [ info exists conf_pt_fc(nbNrPLU) ] }         { set conf_pt_fc(nbNrPLU)         "5" }
      if { ! [ info exists conf_pt_fc(modeBrut) ] }        { set conf_pt_fc(modeBrut)        "simple" }
      if { ! [ info exists conf_pt_fc(nmBrutRes) ] }       { set conf_pt_fc(nmBrutRes)       "objet_result" }
      if { ! [ info exists conf_pt_fc(cosmNoir) ] }        { set conf_pt_fc(cosmNoir)        "1" }
      if { ! [ info exists conf_pt_fc(nmBrutSce) ] }       { set conf_pt_fc(nmBrutSce)       "objet" }
      if { ! [ info exists conf_pt_fc(cosmPLU) ] }         { set conf_pt_fc(cosmPLU)         "1" }
      if { ! [ info exists conf_pt_fc(cosmNrPLU) ] }       { set conf_pt_fc(cosmNrPLU)       "1" }
      if { ! [ info exists conf_pt_fc(nbNoirs) ] }         { set conf_pt_fc(nbNoirs)         "5" }
      if { ! [ info exists conf_pt_fc(nbBrut) ] }          { set conf_pt_fc(nbBrut)          "5" }
      if { ! [ info exists conf_pt_fc(nmNoirRes) ] }       { set conf_pt_fc(nmNoirRes)       "noir30s_result" }
      if { ! [ info exists conf_pt_fc(modePLU) ] }         { set conf_pt_fc(modePLU)         "simple" }
      if { ! [ info exists conf_pt_fc(nmNrSce) ] }         { set conf_pt_fc(nmNrSce)         "noir30s" }
      if { ! [ info exists conf_pt_fc(filtrage) ] }        { set conf_pt_fc(filtrage)        "1" }
      if { ! [ info exists conf_pt_fc(nmNrPLURes) ] }      { set conf_pt_fc(nmNrPLURes)      "noir25s_result" }
      if { ! [ info exists conf_pt_fc(nmPLURes) ] }        { set conf_pt_fc(nmPLURes)        "flat_result" }
      if { ! [ info exists conf_pt_fc(nmPrechRes) ] }      { set conf_pt_fc(nmPrechRes)      "offset_result" }
      if { ! [ info exists conf_pt_fc(nmNrPLUSce) ] }      { set conf_pt_fc(nmNrPLUSce)      "noir25s" }
      if { ! [ info exists conf_pt_fc(nmPLUSce) ] }        { set conf_pt_fc(nmPLUSce)        "flat" }
      if { ! [ info exists conf_pt_fc(cosmBrut) ] }        { set conf_pt_fc(cosmBrut)        "1" }
      if { ! [ info exists conf_pt_fc(nmPrechSce) ] }      { set conf_pt_fc(nmPrechSce)      "offset" }
      if { ! [ info exists conf_pt_fc(medFiltree) ] }      { set conf_pt_fc(medFiltree)      "0" }
      if { ! [ info exists conf_pt_fc(nbPrech) ] }         { set conf_pt_fc(nbPrech)         "7" }
      if { ! [ info exists conf_pt_fc(procCorr) ] }        { set conf_pt_fc(procCorr)        "corrige" }
      if { ! [ info exists conf_pt_fc(cosmPrech) ] }       { set conf_pt_fc(cosmPrech)       "1" }
      if { ! [ info exists conf_pt_fc(NrContientPrech) ] } { set conf_pt_fc(NrContientPrech) "1" }
      if { ! [ info exists conf_pt_fc(FichScript) ] }      { set conf_pt_fc(FichScript)      "correction" }
   }
#***** Fin de la procedure RecuperationParametres ********************

#***** Procedure SauvegardeParametres ********************************
    proc SauvegardeParametres { } {
       global audace conf_pt_fc

       catch {
	    set nom_fichier [file join $audace(rep_plugin) tool pretrfc pretrfc.ini]
	    if [catch {open $nom_fichier w} fichier] {
             Message console "%s\n" $caption(pretrfc,PbSauveConfig)
          } else {
             foreach {a b} [array get conf_pt_fc] {
                puts $fichier "set conf_pt_fc($a) \"$b\""
             }
             close $fichier
          }
       }
    }
#***** Fin de la procedure SauvegardeParametres **********************

#***** Procédure rechargeCosm ****************************************
   proc rechargeCosm { } {
      # Cette procédure a pour fonction de recharger le script de correction
      #    cosmétique (pour permettre à l'utilisateur de faire du debug sans
      #    sortir de Audela !
      global conf_pt_fc audace caption

      # Vérifie validité du nom du fichier de script
      if {[TestNomFichier $conf_pt_fc(FichScript)] == 0} {
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNomFichScr)
      } else {
         # Teste si le fichier de script existe
         set nomFich $audace(rep_scripts)
         append nomFich "/" $conf_pt_fc(FichScript) ".tcl"
         if {[file exists $nomFich] == 0} {
            set integre(cosm) non
            tk_messageBox -title $caption(pretrfc,pb) -type ok \
               -message $caption(pretrfc,FichScrAbs)
         } else {
            # Alors dans ce cas, je charge le fichier
            source $nomFich
         }
      }
   }
#***** Fin de la procedure rechargeCosm ******************************

#***** Procédure goCosm***********************************************
   proc goCosm { } {
      global caption integre

      # Dans un premier temps, je teste l'intégrité de l'opération
	testCosm
      # Si tout est Ok, je lance le traitement
      if {$integre(cosm) == "oui"} {
         traiteCosm
      }
   }
#***** Fin de la procedure goCosm*************************************

#***** Procédure testCosm*********************************************
   proc testCosm { } {
      global audace caption conf_pt_fc integre

      desactiveBoutons
      set integre(cosm) oui

      if {[TestNomFichier $conf_pt_fc(procCorr)] == 0} {
         # Teste si le nom de la procédure est Ok (un seul champ, pas de caractère interdit...)
         set integre(cosm) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbProcCorr)
      } elseif {[info procs $conf_pt_fc(procCorr)] == ""} {
         # Teste si la procédure de correction cosmétique existe
         # Alors je dois regarder si j'ai de quoi charger le fichier contenant le script
         # Teste si le nom de fichier est Ok (un seul champ, pas de caractère interdit...)
         if {[TestNomFichier $conf_pt_fc(FichScript)] == 0} {
            set integre(cosm) non
            tk_messageBox -title $caption(pretrfc,pb) -type ok \
               -message $caption(pretrfc,pbNomFichScr)
         } else {
            # Teste si le fichier de script existe
            set nomFich $audace(rep_scripts)
            append nomFich "/" $conf_pt_fc(FichScript) ".tcl"
            if {[file exists $nomFich] == 0} {
               set integre(cosm) non
               tk_messageBox -title $caption(pretrfc,pb) -type ok \
                  -message $caption(pretrfc,FichScrAbs)
            } else {
               # Alors dans ce cas, je charge le fichier
               source $nomFich
               # et je me repose la question de l'existence de la procédure:
               if {[info procs $conf_pt_fc(procCorr)] == ""} {
                  tk_messageBox -title $caption(pretrfc,pb) -type ok \
                     -message $caption(pretrfc,procCorrIntrouv)
                  set integre(cosm) non
               }
            }
         }
      }
      activeBoutons
   }
#***** Fin de la procedure testCosm***********************************

#***** Procédure traiteCosm*******************************************
   proc traiteCosm { } {
      global caption conf_pt_fc integre

      desactiveBoutons
      # Applique la procédure de correction cosmétique à l'image en cours
      eval $conf_pt_fc(procCorr)
      activeBoutons
   }
#***** Fin de la procedure traiteCosm*********************************

#***** Procédure goPrecharge *****************************************
   proc goPrecharge { } {
      global caption integre

      # Dans un premier temps, je teste l'intégrité de l'opération
	testPrecharge
      # Si tout est Ok, je lance le traitement
      if {$integre(precharge) == "oui"} {
         traitePrecharge
      }
   }
#***** Fin de la procedure goPrecharge *******************************

#***** Procédure testPrecharge ***************************************
   proc testPrecharge { } {
      global audace caption conf_pt_fc integre

      # Initialisation du drapeau d'integrite
      set integre(precharge) oui

      # Enregistrement de l'extension des fichiers
      set ext [buf$audace(bufNo) extension]

      # Je commence par regarder si la correction cosmétique est demandée...
      if {$conf_pt_fc(cosmPrech) == 1} {
         # Alors je teste si la définition de la correction cosmétique est Ok
         testCosm
         if {$integre(cosm) != "oui"} {
            set integre(precharge) non
            return
         }
      }

       desactiveBoutons

	# Teste si le nom de fichier source est Ok (un seul champ, pas de caractère interdit...)
      if {[TestNomFichier $conf_pt_fc(nmPrechSce)] == 0} {
         set integre(precharge) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNomPrechSrce)
      } elseif {[TestNomFichier $conf_pt_fc(nmPrechRes)] == 0} {
         # Teste si le nom de fichier résultant est Ok (un seul champ, pas de caractère interdit...)
         set integre(noir) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNomPrechRes)
      } elseif {[TestEntier $conf_pt_fc(nbPrech)] == 0} {
         # Teste si le nombre est Ok
         set integre(precharge) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNbPrech)
      } else {
         # Teste si les fichiers sources existent
         for {set i 1} {$i <= $conf_pt_fc(nbPrech)} {incr i} {
            set nomFich $audace(rep_images)
            append nomFich "/" $conf_pt_fc(nmPrechSce) $i $ext
            if {[file exists $nomFich] == 0} {
               set integre(precharge) non
            }
         }
         if {$integre(precharge) == "non"} {
            tk_messageBox -title $caption(pretrfc,pb) -type ok \
               -message $caption(pretrfc,fichPrechAbs)
         } else {
            # Teste si le fichier résultant existe déja
            set nomFich $audace(rep_images)
            append nomFich "/" $conf_pt_fc(nmPrechRes) $ext
            if {[file exists $nomFich] == 1} {
               set confirmation [tk_messageBox -title $caption(pretrfc,conf) -type yesno \
                  -message $caption(pretrfc,fichPrechResDeja)]
               if {$confirmation == "no" } {
                  set integre(precharge) non
                  activeBoutons
                  return
               }
            }
            # Dans le cas où le filtrage est demandé, je vérifie que le nb est valide
            if {$conf_pt_fc(medFiltree) == 1} {
               if {[TestEntier $conf_pt_fc(filtrage)] == 0} {
                  tk_messageBox -title $caption(pretrfc,pb) -type ok \
                     -message $caption(pretrfc,pbNbFiltrage)
                  set integre(precharge) non
               }
            }
         }
      }
      activeBoutons
   }
#***** Fin de la procedure testPrecharge *****************************

#***** Procédure traitePrecharge *************************************
   proc traitePrecharge { } {
      global audace caption conf_pt_fc integre

      focus $audace(base)
      focus $audace(Console)

      desactiveBoutons
      # Affichage du message de démarrage du prétraitement des noirs
      Message consolog $caption(pretrfc,debPrech)

      # Enregistrement de l'extension des fichiers
      set ext [buf$audace(bufNo) extension]

      if {$conf_pt_fc(cosmPrech) == 1} {
         # Dans le cas où la correction cosmétique est demandée
         Message consolog $caption(pretrfc,lanceCosmPrech)
         for {set i 1} {$i <= $conf_pt_fc(nbPrech)} {incr i} {
            set instr "loadima $conf_pt_fc(nmPrechSce)$i"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            set instr "eval $conf_pt_fc(procCorr)"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            set instr "saveima $conf_pt_fc(nmPrechSce)$i"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
         }
      }
      # Affichage de la première image de noir
      set nomFich $conf_pt_fc(nmPrechSce)
      append nomFich "1"
      Message consolog $caption(pretrfc,chargPremPrech)
      set instr "loadima "
      append instr $nomFich
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Calcul de la médiane des images
      set instr "smedian $conf_pt_fc(nmPrechSce) $conf_pt_fc(nmPrechRes) $conf_pt_fc(nbPrech)"
      Message consolog $caption(pretrfc,CalcMedPrech)
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Opération éventuelle de filtrage
      if {$conf_pt_fc(medFiltree) == 1} {
         Message consolog $caption(pretrfc,filtrage)
         set taille $conf_pt_fc(filtrage)
         set instr "ttscript2 \"IMA/SERIES \"$audace(rep_images)\" \"$conf_pt_fc(nmPrechRes)\" . . \"$ext\" \
            \"$audace(rep_images)\" \"$conf_pt_fc(nmPrechRes)\" . \"$ext\" FILTER threshold=0 type_threshold=0 \
            kernel_width=$taille kernel_type=fb kernel_coef=0 nullpixel=-5000 \""
         Message consolog $instr
         Message consolog "\n"
         eval $instr
      }

      # Affichage de l'image de précharge résultante
      set nomFich $conf_pt_fc(nmPrechRes)
      Message consolog $caption(pretrfc,chargPrechRes)
      set instr "loadima $nomFich"
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Affichage du message de fin du prétraitement de la précharge
      Message consolog $caption(pretrfc,finPrech)

      activeBoutons
      focus $audace(base).fenetrePretr
   }
#***** Fin de la procedure traitePrecharge ***************************

#***** Procédure goNoir **********************************************
   proc goNoir { } {
      global caption integre

      # Dans un premier temps, je teste l'intégrité de l'opération
	testNoir
      # Si tout est Ok, je lance le traitement
      if {$integre(noir) == "oui"} {
         traiteNoir
      }
   }
#***** Fin de la procedure goNoir ************************************

#***** Procédure testNoir ********************************************
   proc testNoir { } {
      global audace caption conf_pt_fc integre

      # Initialisation du drapeau d'integrite
      set integre(noir) oui

      # Enregistrement de l'extension des fichiers
      set ext [buf$audace(bufNo) extension]

      # Je commence par regarder si la correction cosmétique est demandée...
      if {$conf_pt_fc(cosmNoir) == 1} {
         # Alors je teste si la définition de la correction cosmétique est Ok
         testCosm
         if {$integre(cosm) != "oui"} {
            set integre(noir) non
            return
         }
      }

      desactiveBoutons

	# Teste si le nom de fichier source est Ok (un seul champ, pas de caractère interdit...)
      if {[TestNomFichier $conf_pt_fc(nmNrSce)] == 0} {
         set integre(noir) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNomNoirSrce)
      } elseif {[TestNomFichier $conf_pt_fc(nmNoirRes)] == 0} {
         # Teste si le nom de fichier résultant est Ok (un seul champ, pas de caractère interdit...)
         set integre(noir) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNomNoirRes)
      } elseif {[TestEntier $conf_pt_fc(nbNoirs)] == 0} {
         # Teste si le nombre est Ok
         set integre(noir) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNbNr)
      } else {
         # Teste si les fichiers sources existent
         for {set i 1} {$i <= $conf_pt_fc(nbNoirs)} {incr i} {
            set nomFich $audace(rep_images)
            append nomFich "/" $conf_pt_fc(nmNrSce) $i $ext
            if {[file exists $nomFich] == 0} {
               set integre(noir) non
            }
         }
         if {$integre(noir) == "non"} {
            tk_messageBox -title $caption(pretrfc,pb) -type ok \
               -message $caption(pretrfc,fichNoirAbs)
         } else {
            # Teste si le fichier résultant existe déja
            set nomFich $audace(rep_images)
            append nomFich "/" $conf_pt_fc(nmNoirRes) $ext
            if {[file exists $nomFich] == 1} {
               set confirmation [tk_messageBox -title $caption(pretrfc,conf) -type yesno \
                  -message $caption(pretrfc,fichNoirResDeja)]
               if {$confirmation == "no" } {
                  set integre(noir) non
               }
            }
         }
      }
      activeBoutons
   }
#***** Fin de la procedure testNoir **********************************

#***** Procédure traiteNoir ******************************************
   proc traiteNoir { } {
      global audace caption conf_pt_fc integre

      focus $audace(base)
      focus $audace(Console)

      desactiveBoutons
      # Affichage du message de démarrage du prétraitement des noirs
      Message consolog $caption(pretrfc,debNoir)

      if {$conf_pt_fc(cosmNoir) == 1} {
         # Dans le cas où la correction cosmétique est demandée
         Message consolog $caption(pretrfc,lanceCosmNoir)
         for {set i 1} {$i <= $conf_pt_fc(nbNoirs)} {incr i} {
            set instr "loadima $conf_pt_fc(nmNrSce)$i"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            set instr "eval $conf_pt_fc(procCorr)"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            set instr "saveima $conf_pt_fc(nmNrSce)$i"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
         }
      }
      # Affichage de la première image de noir
      set nomFich $conf_pt_fc(nmNrSce)
      append nomFich "1"
      Message consolog $caption(pretrfc,chargPremNoir)
      set instr "loadima "
      append instr $nomFich
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Calcul de la médiane des images
      set instr "smedian $conf_pt_fc(nmNrSce) $conf_pt_fc(nmNoirRes) $conf_pt_fc(nbNoirs)"
      Message consolog $caption(pretrfc,CalcMedNoir)
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Affichage de l'image noire résultante
      set nomFich $conf_pt_fc(nmNoirRes)
      Message consolog $caption(pretrfc,chargNoirRes)
      set instr "loadima $nomFich"
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Affichage du message de fin du prétraitement des noirs
      Message consolog $caption(pretrfc,finNoir)

      activeBoutons
      focus $audace(base).fenetrePretr
   }
#***** Fin de la procedure traiteNoir ********************************

#***** Procédure goNoirDePLU *****************************************
   proc goNoirDePLU { } {
      global caption integre

      # Dans un premier temps, je teste l'intégrité de l'opération
	testNoirDePLU
      # Si tout est Ok, je lance le traitement
      if {$integre(noir_PLU) == "oui"} {
         traiteNoirDePLU
      }
   }
#***** Fin de la procedure goNoirDePLU *******************************

#***** Procédure testNoirDePLU ***************************************
   proc testNoirDePLU { } {
      global audace caption conf_pt_fc integre

      # Initialisation du drapeau d'integrite
      set integre(noir_PLU) oui

      # Enregistrement de l'extension des fichiers
      set ext [buf$audace(bufNo) extension]

      # Je commence par regarder si la correction cosmétique est demandée...
      if {$conf_pt_fc(cosmNrPLU) == 1} {
         # Alors je teste si la définition de la correction cosmétique est Ok
         testCosm
         if {$integre(cosm) != "oui"} {
            set integre(noir_PLU) non
            return
         }
      }

      desactiveBoutons

	# Teste si le nom de fichier source est Ok (un seul champ, pas de caractère interdit...)
      if {[TestNomFichier $conf_pt_fc(nmNrPLUSce)] == 0} {
         set integre(noir_PLU) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNomNrPLUSrce)
      } elseif {[TestNomFichier $conf_pt_fc(nmNrPLURes)] == 0} {
         # Teste si le nom de fichier résultant est Ok (un seul champ, pas de caractère interdit...)
         set integre(noir_PLU) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNomNrPLURes)
      } elseif {[TestEntier $conf_pt_fc(nbNrPLU)] == 0} {
         # Teste si le nombre est Ok
         set integre(noir_PLU) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNbNrPLU)
      } else {
         # Teste si les fichiers sources existent
         for {set i 1} {$i <= $conf_pt_fc(nbNrPLU)} {incr i} {
            set nomFich $audace(rep_images)
            append nomFich "/" $conf_pt_fc(nmNrPLUSce) $i $ext
            if {[file exists $nomFich] == 0} {
               set integre(noir_PLU) non
            }
         }
         if {$integre(noir_PLU) == "non"} {
            tk_messageBox -title $caption(pretrfc,pb) -type ok \
               -message $caption(pretrfc,fichNrPLUAbs)
         } else {
            # Teste si le fichier résultant existe déja
            set nomFich $audace(rep_images)
            append nomFich "/" $conf_pt_fc(nmNrPLURes) $ext
            if {[file exists $nomFich] == 1} {
               set confirmation [tk_messageBox -title $caption(pretrfc,conf) -type yesno \
                  -message $caption(pretrfc,fichNrPLUResDeja)]
               if {$confirmation == "no" } {
                  set integre(noir_PLU) non
               }
            }
         }
      }
      activeBoutons
   }
#***** Fin de la procedure testNoirDePLU *****************************

#***** Procédure traiteNoirDePLU *************************************
   proc traiteNoirDePLU { } {
      global audace caption conf_pt_fc integre

      focus $audace(base)
      focus $audace(Console)

      desactiveBoutons
      # Affichage du message de démarrage du prétraitement des noir de PLU
      Message consolog $caption(pretrfc,debNrPLU)

      if {$conf_pt_fc(cosmNrPLU) == 1} {
         # Dans le cas où la correction cosmétique est demandée
         Message consolog $caption(pretrfc,cosmNoirDePLU)
         for {set i 1} {$i <= $conf_pt_fc(nbNrPLU)} {incr i} {
            set instr "loadima $conf_pt_fc(nmNrPLUSce)$i"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            set instr "eval $conf_pt_fc(procCorr)"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            set instr "saveima $conf_pt_fc(nmNrPLUSce)$i"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
         }
      }

      # Affichage de la première image de noir de PLU
      set nomFich $conf_pt_fc(nmNrPLUSce)
      append nomFich "1"
      Message consolog $caption(pretrfc,chargPremNrPLU)
      set instr "loadima $nomFich"
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Calcul de la médiane des images
      set instr "smedian $conf_pt_fc(nmNrPLUSce) $conf_pt_fc(nmNrPLURes) $conf_pt_fc(nbNrPLU)"
      Message consolog $caption(pretrfc,CalcMedNrPLU)
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Affichage de l'image de noir de PLU résultante
      set nomFich $conf_pt_fc(nmNrPLURes)
      Message consolog $caption(pretrfc,chargNrPLURes)
      set instr "loadima $nomFich"
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Affichage du fin de démarrage du prétraitement des noirs de PLU
      Message consolog $caption(pretrfc,finNrPLU)
      activeBoutons
      focus $audace(base).fenetrePretr
   }
#***** Fin de la procedure traiteNoirDePLU ***************************

#***** Procédure goPLU ***********************************************
   proc goPLU { } {
      global caption integre

      # Dans un premier temps, je teste l'intégrité de l'opération
	testPLU
      # Si tout est Ok, je lance le traitement
      if {$integre(PLU) == "oui"} {
         traitePLU
      }
   }
#***** Fin de la procedure goPLU *************************************

#***** Procédure testPLU *********************************************
   proc testPLU { } {
      global audace caption conf_pt_fc integre

      # Initialisation du drapeau d'integrite
      set integre(PLU) oui

      # Enregistrement de l'extension des fichiers
      set ext [buf$audace(bufNo) extension]

      # Je commence par regarder si la correction cosmétique est demandée...
      if {$conf_pt_fc(cosmPLU) == 1} {
         # Alors je teste si la définition de la correction cosmétique est Ok
         testCosm
         if {$integre(cosm) != "oui"} {
            set integre(PLU) non
            return
         }
      }
      desactiveBoutons
      set conf_pt_fc(fich_pour_PLU_ok) non
      set conf_pt_fc(noir_de_PLU_a_faire_pl) non
      set conf_pt_fc(precharge_a_faire_pl) non
      set conf_pt_fc(noir_a_faire_pl) non

	# Teste si le nom de fichier source est Ok (un seul champ, pas de caractère interdit...)
      if {[TestNomFichier $conf_pt_fc(nmPLUSce)] == 0} {
         set integre(PLU) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNomPLUSrce)
      } elseif {[TestNomFichier $conf_pt_fc(nmPLURes)] == 0} {
         # Teste si le nom de fichier résultant est Ok (un seul champ, pas de caractère interdit...)
         set integre(PLU) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNomPLURes)
      } elseif {[TestEntier $conf_pt_fc(nbPLU)] == 0} {
         # Teste si le nombre est Ok
         set integre(PLU) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNbPLU)
      } else {
         # Teste si les fichiers sources existent
         for {set i 1} {$i <= $conf_pt_fc(nbPLU)} {incr i} {
            set nomFich $audace(rep_images)
            append nomFich "/" $conf_pt_fc(nmPLUSce) $i $ext
            if {[file exists $nomFich] == 0} {
               set integre(PLU) non
            }
         }
         if {$integre(PLU) == "non"} {
            tk_messageBox -title $caption(pretrfc,pb) -type ok \
               -message $caption(pretrfc,fichPLUAbs)
         } else {
            # Teste si le fichier résultant existe déja
            set nomFich $audace(rep_images)
            append nomFich "/" $conf_pt_fc(nmPLURes) $ext
            if {[file exists $nomFich] == 1} {
               set confirmation [tk_messageBox -title $caption(pretrfc,conf) -type yesno \
                  -message $caption(pretrfc,fichPLUResDeja)]
               if {$confirmation == "no"} {
                  set integre(PLU) non
                  activeBoutons
                  return
               }
            }
            if {$conf_pt_fc(modePLU) == "simple"} {
               # A partir de là, c'est selon le mode de traitement de la PLU retenue
               # Teste si le fichier de noir de PLU existe bien
               set nomFich $audace(rep_images)
               append nomFich "/" $conf_pt_fc(nmNrPLURes) $ext
               if {[file exists $nomFich] == 0} {
                  testNoirDePLU
                  if {$integre(noir_PLU) == "non"} {
                     tk_messageBox -title $caption(pretrfc,pb) -type ok \
                        -message $caption(pretrfc,fichNrPLUPLUAbs)
                     set integre(PLU) non
                     set conf_pt_fc(fich_pour_PLU_ok) non
                  } else {
                     # J'ai tout pour faire le noir de PLU
                     set conf_pt_fc(fich_pour_PLU_ok) oui
                     # Alors je mémorise que je dois le faire
                     set conf_pt_fc(noir_de_PLU_a_faire_pl) oui
                  }
               } else {
                  set conf_pt_fc(fich_pour_PLU_ok) oui
               }
            } elseif {$conf_pt_fc(modePLU) != ""} {
               # Dans ce cas, on a choisit les options rapp tps pose ou optimisation
               # Teste si le fichier de précharge existe bien
               set nomFich $audace(rep_images)
               append nomFich "/" $conf_pt_fc(nmPrechRes) $ext
               if {[file exists $nomFich] == 0} {
                  testPrecharge
                  if {$integre(precharge) == "non"} {
                     tk_messageBox -title $caption(pretrfc,pb) -type ok \
                        -message $caption(pretrfc,fichPrechPLUAbs)
                     set integre(PLU) non
                     set conf_pt_fc(fich_pour_PLU_ok) non
                  } else {
                     # J'ai tout pour faire la précharge
                     set conf_pt_fc(fich_pour_PLU_ok) oui
                     # Alors je mémorise que je dois le faire
                     set conf_pt_fc(precharge_a_faire_pl) oui
                  }
               } else {
                   set conf_pt_fc(fich_pour_PLU_ok) oui
               }
               if {$conf_pt_fc(fich_pour_PLU_ok) == "oui"} {
                  # Teste si le fichier de noir existe bien
                  set nomFich $audace(rep_images)
                  append nomFich "/" $conf_pt_fc(nmNoirRes) $ext
                  if {[file exists $nomFich] == 0} {
                     testNoir
                     if {$integre(noir) == "non"} {
                        tk_messageBox -title $caption(pretrfc,pb) -type ok \
                           -message $caption(pretrfc,fichNrtoPLUAbs)
                        set integre(PLU) non
                        set conf_pt_fc(fich_pour_PLU_ok) non
                     } else {
                        # J'ai tout pour faire le noir
                        set conf_pt_fc(fich_pour_PLU_ok) oui
                        # Alors je mémorise que je dois le faire
                        set conf_pt_fc(noir_a_faire_pl) oui
	               }
                  } else {
                     set conf_pt_fc(fich_pour_PLU_ok) oui
                  }
               }
            } else {
               # Vérifie qu'un mode de traitement est bien sélectionné
               tk_messageBox -title $caption(pretrfc,pb) -type ok \
                  -message $caption(pretrfc,choisir_mode_PLU)
               set integre(PLU) non
            }
         }
      }
      activeBoutons
   }
#***** Fin de la procedure testPLU ***********************************

#***** Procédure traitePLU *******************************************
   proc traitePLU { } {
      global audace caption conf_pt_fc integre

      if {$conf_pt_fc(noir_de_PLU_a_faire_pl) == "oui"} {
         traiteNoirDePLU
      }
      if {$conf_pt_fc(precharge_a_faire_pl) == "oui"} {
         traitePrecharge
      }
      if {$conf_pt_fc(noir_a_faire_pl) == "oui"} {
         traiteNoir
      }

      focus $audace(base)
      focus $audace(Console)
      update idletasks

      # Enregistrement de l'extension des fichiers
      set ext [buf$audace(bufNo) extension]

      desactiveBoutons

      # Affichage du message de démarrage du prétraitement des noirs
      Message consolog $caption(pretrfc,debPLU)
      switch -exact $conf_pt_fc(modePLU) {
         simple {
            Message consolog $caption(pretrfc,ModePLUSimple)
         }
         rapTps {
            Message consolog $caption(pretrfc,ModePLURapTps)
         }
         opt {
            Message consolog $caption(pretrfc,ModePLUOpt)
         }
      }

      if {$conf_pt_fc(cosmPLU) == 1} {
         # Dans le cas où la correction cosmétique est demandée
         Message consolog $caption(pretrfc,lanceCosmPLU)
         for {set i 1} {$i <= $conf_pt_fc(nbPLU)} {incr i} {
            set instr "loadima $conf_pt_fc(nmPLUSce)$i"
            Message consolog "%s\n" $instr
            eval $instr
            set instr "eval $conf_pt_fc(procCorr)"
            Message consolog "%s\n" $instr
            eval $instr
            set instr "saveima $conf_pt_fc(nmPLUSce)$i"
            Message consolog "%s\n" $instr
            eval $instr
         }
      }

      # Affichage de la première image de PLU
      set nomFich $conf_pt_fc(nmPLUSce)
      append nomFich "1"
      Message consolog $caption(pretrfc,chargPremPLU)
      set instr "loadima $nomFich"
      Message consolog "%s\n" $instr
      eval $instr

      # Traitement proprement dit des PLU, selon le mode choisi
      switch -exact $conf_pt_fc(modePLU) {
         simple {
            # Soustraction du noir de PLU de chaque image de PLU
            set instr "sub2 $conf_pt_fc(nmPLUSce) $conf_pt_fc(nmNrPLURes) $conf_pt_fc(nmPLUSce)"
            append instr "_moinsnoir_ 0 $conf_pt_fc(nbPLU)"
            Message consolog $caption(pretrfc,SoustrNrPLUPLU)
            Message consolog "%s\n" $instr
            eval $instr
         }
         rapTps {
            # Lecture du temps de pose de l'image PLU
            # Je vérifie que le champ exposure est bien présent dans l'entête FITS
            if {[lsearch [buf$audace(bufNo) getkwds] EXPOSURE] != -1} {
               set motCle EXPOSURE
            } else {
               set motCle EXPTIME
            }
		set instr "set temps_plu [lindex [buf$audace(bufNo) getkwd $motCle] 1]"
            Message consolog $caption(pretrfc,LitTpsPLU)
            Message consolog "%s\n" $instr
            eval $instr
            # Chargement de l'image de noir
            set instr "loadima $conf_pt_fc(nmNoirRes)"
            Message consolog $caption(pretrfc,ChargeNoir)
            Message consolog "%s\n" $instr
            eval $instr
            # Lecture du temps de pose du noir
            # Je vérifie que le champ exposure est bien présent dans l'entête FITS
            if {[lsearch [buf$audace(bufNo) getkwds] EXPOSURE] != -1} {
               set motCle EXPOSURE
            } else {
               set motCle EXPTIME
            }
		set instr "set temps_noir [lindex [buf$audace(bufNo) getkwd $motCle] 1]"
            Message consolog $caption(pretrfc,LitTpsNoir)
            Message consolog "%s\n" $instr
            eval $instr
            # Calcul du rapport de temps entre noir et PLU
		set instr "set rapport [expr double($temps_plu) / double($temps_noir)]"
            Message consolog $caption(pretrfc,calcRapp)
            Message consolog "%s\n" $instr
            eval $instr
            # Retire l'offset du noir (si besoin)
            if {$conf_pt_fc(NrContientPrech) == 1} {
               set instr "sub $conf_pt_fc(nmPrechRes) 0"
               Message consolog $caption(pretrfc,soustrPrechDuNoir)
               Message consolog "%s\n" $instr
               eval $instr
            }
            # Multiplie le noir par le rapport de tps d'exp.
            set instr "mult $rapport"
            Message consolog $caption(pretrfc,multNoir)
            Message consolog "%s\n" $instr
            eval $instr
            # Sauvegarde le noir pondéré
            set instr "saveima noir_pondere_temp"
            Message consolog $caption(pretrfc,SauveNoirPond)
            Message consolog "%s\n" $instr
            eval $instr
            # Retire l'offset de toutes les images de PLU
            set nom_fich $conf_pt_fc(nmPLUSce)
            append nom_fich "_moinsnoir_"
            set instr "sub2 $conf_pt_fc(nmPLUSce) $conf_pt_fc(nmPrechRes) $nom_fich 0 $conf_pt_fc(nbPLU)"
            Message consolog $caption(pretrfc,SoustrPrechPLUProv)
            Message consolog "%s\n" $instr
            eval $instr
            # Retire le noir pondéré de toutes les images de PLU
            set instr "sub2 $nom_fich noir_pondere_temp $nom_fich 0 $conf_pt_fc(nbPLU)"
            Message consolog $caption(pretrfc,SoustrNoirPondPLU)
            Message consolog "%s\n" $instr
            eval $instr
         }
         opt {
            if {$conf_pt_fc(NrContientPrech) == 0} {
               # Chargement de l'image de noir
               set instr "loadima $conf_pt_fc(nmNoirRes)"
               Message consolog $caption(pretrfc,ChargeNoir)
               Message consolog "%s\n" $instr
               eval $instr
               # Addition de la précharge
               set instr "add $conf_pt_fc(nmPrechRes) 0"
               Message consolog $caption(pretrfc,ajoutePrechNoir)
               Message consolog "%s\n" $instr
               eval $instr
               # Sauvegarde le noir contenant la précharge
               set instr "saveima noir_avec_prech"
               Message consolog $caption(pretrfc,SauveNoirAvecPrech)
               Message consolog "%s\n" $instr
               eval $instr
               # Astuce pour traiter correctement les fichiers de noir...
               set noir_avec_prech noir_avec_prech
               } else {
               # Suite et fin de l'astuce pour traiter correctement les fichiers de noir...
               set noir_avec_prech $conf_pt_fc(nmNoirRes)
            }
            set nom_fich_sortie $conf_pt_fc(nmPLUSce)
            append nom_fich_sortie "_moinsnoir_"
            set instr "opt2 $conf_pt_fc(nmPLUSce) $noir_avec_prech $conf_pt_fc(nmPrechRes) \
               $nom_fich_sortie $conf_pt_fc(nbPLU)"
            Message consolog $caption(pretrfc,OptPLU)
            Message consolog "%s\n" $instr
            eval $instr
         }
      }

      # Affichage de la première image de PLU, corrigée du noir
      set nomFich $conf_pt_fc(nmPLUSce)
      append nomFich "_moinsnoir_1"
      Message consolog $caption(pretrfc,chargPremPLUCorrNrPLU)
      set instr "loadima "
      append instr $nomFich
      Message consolog "%s\n" $instr
      eval $instr

      # Calcul de la valeur moyenne de la première image:
      set instr "set valMoyenne \[lindex \[stat\] 4\]"
      Message consolog $caption(pretrfc,calcMoyPremIm)
      Message consolog "%s\n" $instr
      eval $instr

      # Mise au même niveau de tous les PLU
      set instr "ngain2 "
      append instr $conf_pt_fc(nmPLUSce)
      append instr "_moinsnoir_ "
      append instr $conf_pt_fc(nmPLUSce)
      append instr "_auniveau " $valMoyenne " " $conf_pt_fc(nbPLU)
      Message consolog $caption(pretrfc,MiseNiveauPLU)
      Message consolog "%s\n" $instr
      eval $instr

      # Calcul de la médiane des images
      set instr "smedian "
      append instr $conf_pt_fc(nmPLUSce)
      append instr _auniveau " " $conf_pt_fc(nmPLURes) " " $conf_pt_fc(nbPLU)
      Message consolog $caption(pretrfc,CalcMedPLU)
      Message consolog "%s\n" $instr
      eval $instr

      # Affichage de l'image noire résultante
      set nomFich $conf_pt_fc(nmPLURes)
      Message consolog $caption(pretrfc,chargPLURes)
      set instr "loadima $nomFich"
      Message consolog "%s\n" $instr
      eval $instr

      # Effacement du disque des images générées par le prétraitement:
      Message consolog $caption(pretrfc,effacePLUInter)
      for {set i 1} {$i <= $conf_pt_fc(nbPLU)} {incr i} {
         set nomFich $audace(rep_images)
         append nomFich "/" $conf_pt_fc(nmPLUSce) "_moinsnoir_" $i $ext
         file delete $nomFich
         set nomFich $audace(rep_images)
         append nomFich "/" $conf_pt_fc(nmPLUSce) "_auniveau" $i $ext
         file delete $nomFich
      }
      set nomFich $audace(rep_images)
      append nomFich "/" "noir_pondere_temp$ext"
      if {[file exists $nomFich]} {
         file delete $nomFich
      }
      set nomFich $audace(rep_images)
      append nomFich "/" "noir_avec_prech$ext"
      if {[file exists $nomFich]} {
         file delete $nomFich
      }

      # Affichage du message de fin du prétraitement des noirs
      Message consolog $caption(pretrfc,finPLU)
      activeBoutons
      focus $audace(base).fenetrePretr
   }
#***** Fin de la procedure traitePLU *********************************

#***** Procédure goBrut **********************************************
   proc goBrut { } {
      global caption integre

      # Dans un premier temps, je teste l'intégrité de l'opération
	testBrut
      # Si tout est Ok, je lance le traitement
      if {$integre(brut) == "oui"} {
         traiteBrut
      }
   }
#***** Fin de la procedure goBrut ************************************

#***** Procédure testBrut ********************************************
   proc testBrut { } {
      global audace caption conf_pt_fc integre

      # Initialisation du drapeau d'integrite
      set integre(brut) oui

      # Enregistrement de l'extension des fichiers
      set ext [buf$audace(bufNo) extension]

      # Je commence par regarder si la correction cosmétique est demandée...
      if {$conf_pt_fc(cosmBrut) == 1} {
         # Alors je teste si la définition de la correction cosmétique est Ok
         testCosm
         if {$integre(cosm) != "oui"} {
            set integre(brut) non
            return
         }
      }
      desactiveBoutons
      set conf_pt_fc(noir_a_faire_br) non
      set conf_pt_fc(PLU_a_faire_br) non
      set conf_pt_fc(precharge_a_faire_br) non
      set conf_pt_fc(noir_ok) non
      set conf_pt_fc(PLU_ok) non
      set conf_pt_fc(precharge_ok) non

	# Teste si le nom de fichier source est Ok (un seul champ, pas de caractère interdit...)
      if {[TestNomFichier $conf_pt_fc(nmBrutSce)] == 0} {
         set integre(brut) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNomBrutSrce)
      } elseif {[TestNomFichier $conf_pt_fc(nmBrutRes)] == 0} {
         # Teste si le nom de fichier résultant est Ok (un seul champ, pas de caractère interdit...)
         set integre(brut) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNomBrutRes)
      } elseif {[TestEntier $conf_pt_fc(nbBrut)] == 0} {
         # Teste si le nombre est Ok
         set integre(brut) non
         tk_messageBox -title $caption(pretrfc,pb) -type ok \
            -message $caption(pretrfc,pbNbBrut)
      } else {
         # Teste si les fichiers sources existent
         for {set i 1} {$i <= $conf_pt_fc(nbBrut)} {incr i} {
            set nomFich $audace(rep_images)
            append nomFich "/" $conf_pt_fc(nmBrutSce) $i $ext
            if {[file exists $nomFich] == 0} {
               set integre(brut) non
            }
         }
         if {$integre(brut) == "non"} {
            tk_messageBox -title $caption(pretrfc,pb) -type ok \
               -message $caption(pretrfc,fichBrutAbs)
         } else {
            # Teste si le fichier de noir existe bien
            set nomFich $audace(rep_images)
            append nomFich "/" $conf_pt_fc(nmNoirRes) $ext
            if {[file exists $nomFich] == 0} {
               # Dans ce cas, je regarde si je peux calculer le noir...
               testNoir
               if {$integre(noir) == "non"} {
                  # Je n'ai pas les éléments pour faire le noir
                  tk_messageBox -title $caption(pretrfc,pb) -type ok \
                     -message $caption(pretrfc,fichNoirBrutAbs)
                  set integre(brut) non
                  set conf_pt_fc(noir_ok) non
                  } else {
                  # Alors je dois prévoir de faire le calcul du noir pendant le traitement
                  set conf_pt_fc(noir_a_faire_br) oui
                  # Et je memorise que c'est Ok pour les noirs
                  set conf_pt_fc(noir_ok) oui
               }
            } else {
               set conf_pt_fc(noir_ok) oui
            }
            if {$conf_pt_fc(noir_ok) == "oui"} {
               # Teste si le fichier de PLU existe bien
               set nomFich $audace(rep_images)
               append nomFich "/" $conf_pt_fc(nmPLURes) $ext
               if {[file exists $nomFich] == 0} {
                  # Dans ce cas, je regarde si je peux calculer le PLU...
                  testPLU
                  if {$integre(PLU) == "non"} {
                  # Je n'ai pas les éléments pour faire le PLU
                     tk_messageBox -title $caption(pretrfc,pb) -type ok \
                        -message $caption(pretrfc,fichPLUBrutAbs)
                     set integre(brut) non
                     set conf_pt_fc(PLU_ok) non
                  } else {
                     # Alors je dois prévoir de faire le calcul du PLU pendant le traitement
                     set conf_pt_fc(PLU_a_faire_br) oui
                     set conf_pt_fc(PLU_ok) oui
                  }
               } else {
                  set conf_pt_fc(PLU_ok) oui
               }
            }
            if {$conf_pt_fc(PLU_ok) == "oui" && $conf_pt_fc(noir_ok) == "oui"} {
               # Teste si les fichiers résultants existent déja
               for {set i 1} {$i <= $conf_pt_fc(nbBrut)} {incr i} {
                  set nomFich $audace(rep_images)
                  append nomFich "/" $conf_pt_fc(nmBrutRes) $i $ext
                  if {[file exists $nomFich] == 1} {
                     set integre(brut) non
                  }
               }
               if {$integre(brut) == "non"} {
                  set confirmation [tk_messageBox -title $caption(pretrfc,conf) -type yesno \
                     -message $caption(pretrfc,fichBrutResDeja)]
                  if {$confirmation == "yes" } {
                     set integre(brut) oui
                  }
               }
            }
            if {$conf_pt_fc(PLU_ok) == "oui" && $conf_pt_fc(noir_ok) == "oui"} {
               if {$conf_pt_fc(modeBrut) != "simple" || $conf_pt_fc(NrContientPrech) == 0} {
                  # Teste si le fichier de précharge existe bien (dans le cas où l'option
                  #   retenue est optimisation ou rapp. tps de pose) ou bien si le noir
                  #   ne contient pas la précharge: J'ai alors besoin de la précharge
                  set nomFich $audace(rep_images)
                  append nomFich "/" $conf_pt_fc(nmPrechRes) $ext
                  if {[file exists $nomFich] == 0} {
                     # Dans ce cas, je regarde si je peux calculer la précharge...
                     testPrecharge
                     if {$integre(precharge) == "non"} {
                     # Je n'ai pas les éléments pour faire la précharge
                        tk_messageBox -title $caption(pretrfc,pb) -type ok \
                           -message $caption(pretrfc,fichPrechBrutAbs)
                        set integre(brut) non
                        set conf_pt_fc(precharge_ok) non
                        } else {
                        # Alors je dois prévoir de faire le calcul du PLU pendant le traitement
                        set conf_pt_fc(precharge_a_faire_br) oui
                        set conf_pt_fc(precharge_ok) oui
                     }
                  } else {
                     set conf_pt_fc(precharge_ok) oui
                  }
               }
            }
            # Teste qu'un mode est bien sélectionné
            if {$conf_pt_fc(modeBrut) == ""} {
               tk_messageBox -title $caption(pretrfc,pb) -type ok \
                  -message $caption(pretrfc,fichModeBrutAbs)
               set integre(brut) non
            }
         }
      }
      activeBoutons
   }
#***** Fin de la procedure testBrut **********************************

#***** Procédure traiteBrut ******************************************
   proc traiteBrut { } {
      global audace caption conf_pt_fc integre

      # Enregistrement de l'extension des fichiers
      set ext [buf$audace(bufNo) extension]

      # Le cas échéant, je lance les opération préliminéires
      if {$conf_pt_fc(PLU_a_faire_br) == "oui"} {
         traitePLU
      }
      if {$conf_pt_fc(precharge_a_faire_br) == "oui"} {
         # Je vérifie que le fichier n'existe pas déjà (il a pu être crée par le traitement de PLU...)
         set nomFich $audace(rep_images)
         append nomFich "/" $conf_pt_fc(nmPrechRes) $ext
         if {[file exists $nomFich] == 0} {
            traitePrecharge
         }
      }
      if {$conf_pt_fc(noir_a_faire_br) == "oui"} {
         # Je vérifie que le fichier n'existe pas déjà (il a pu être crée par le traitement de PLU...)
         set nomFich $audace(rep_images)
         append nomFich "/" $conf_pt_fc(nmNoirRes) $ext
         if {[file exists $nomFich] == 0} {
            traiteNoir
         }
      }

      focus $audace(base)
      focus $audace(Console)

      desactiveBoutons

      # Affichage du message de démarrage du prétraitement des noirs
      Message consolog $caption(pretrfc,debBrut)
      switch -exact $conf_pt_fc(modeBrut) {
         simple {
            Message consolog $caption(pretrfc,ModeBrutSimple)
         }
         rapTps {
            Message consolog $caption(pretrfc,ModeBrutRapTps)
         }
         opt {
            Message consolog $caption(pretrfc,ModeBrutOpt)
         }
      }

      if {$conf_pt_fc(cosmBrut) == 1} {
         # Dans le cas où la correction cosmétique est demandée
         Message consolog $caption(pretrfc,lanceCosmStellaire)
         for {set i 1} {$i <= $conf_pt_fc(nbBrut)} {incr i} {
            set instr "loadima $conf_pt_fc(nmBrutSce)$i"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            set instr "eval $conf_pt_fc(procCorr)"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            set instr "saveima $conf_pt_fc(nmBrutSce)$i"
            Message consolog $instr
            Message consolog "\n"
            eval $instr
         }
      }

      # Affichage de la première image stellaire
      set nomFich $conf_pt_fc(nmBrutSce)
      append nomFich "1"
      Message consolog $caption(pretrfc,chargPremBrut)
      set instr "loadima $nomFich"
      Message consolog "%s\n" $instr
      eval $instr
      # Soustraction du noir, selon le mode choisi
      switch -exact $conf_pt_fc(modeBrut) {
         simple {
            # Soustraction du noir de chaque image stellaire
            set instr "sub2 $conf_pt_fc(nmBrutSce) $conf_pt_fc(nmNoirRes) $conf_pt_fc(nmBrutSce)"
            append instr "_moinsnoir_ 0 $conf_pt_fc(nbBrut)"
            Message consolog $caption(pretrfc,SoustrNoirBrut)
            Message consolog $instr
            Message consolog "\n"
            eval $instr
            # Si le noir ne contient pas la précharge, soustraction de la précharge
            if {$conf_pt_fc(NrContientPrech) == 0} {
               set instr "sub2 $conf_pt_fc(nmBrutSce)"
               append instr "_moinsnoir_ $conf_pt_fc(nmPrechRes) $conf_pt_fc(nmBrutSce)"
               append instr "_moinsnoir_ 0 $conf_pt_fc(nbBrut)"
               Message consolog $caption(pretrfc,SoustrPrechBrut)
               Message consolog $instr
               Message consolog "\n"
               eval $instr
            }
         }
         rapTps {
            # Lecture du temps de pose des images stellaires
            # Je vérifie que le champ exposure est bien présent dans l'entête FITS
            if {[lsearch [buf$audace(bufNo) getkwds] EXPOSURE] != -1} {
               set motCle EXPOSURE
            } else {
               set motCle EXPTIME
            }
		set instr "set temps_stellaire [lindex [buf$audace(bufNo) getkwd $motCle] 1]"
            Message consolog $caption(pretrfc,LitTpsStellaire)
            Message consolog "%s\n" $instr
            eval $instr
            # Chargement de l'image de noir
            set instr "loadima $conf_pt_fc(nmNoirRes)"
            Message consolog $caption(pretrfc,ChargeNoir)
            Message consolog "%s\n" $instr
            eval $instr
            # Lecture du temps de pose du noir
            # Je vérifie que le champ exposure est bien présent dans l'entête FITS
            if {[lsearch [buf$audace(bufNo) getkwds] EXPOSURE] != -1} {
               set motCle EXPOSURE
            } else {
               set motCle EXPTIME
            }
		set instr "set temps_noir [lindex [buf$audace(bufNo) getkwd $motCle] 1]"
            Message consolog $caption(pretrfc,LitTpsNoir)
            Message consolog "%s\n" $instr
            eval $instr
            # Calcul du rapport de temps entre noir et PLU
		set instr "set rapport [expr double($temps_stellaire) / double($temps_noir)]"
            Message consolog $caption(pretrfc,calcRapp)
            Message consolog "%s\n" $instr
            eval $instr
            # Retire l'offset du noir (si besoin)
            if {$conf_pt_fc(NrContientPrech) == 1} {
               set instr "sub $conf_pt_fc(nmPrechRes) 0"
               Message consolog $caption(pretrfc,soustrPrechDuNoir)
               Message consolog "%s\n" $instr
               eval $instr
            }
            # Multiplie le noir par le rapport de tps d'exp.
            set instr "mult $rapport"
            Message consolog $caption(pretrfc,multNoir)
            Message consolog "%s\n" $instr
            eval $instr
            # Sauvegarde le noir pondéré
            set instr "saveima noir_pondere_temp"
            Message consolog $caption(pretrfc,SauveNoirPond)
            Message consolog "%s\n" $instr
            eval $instr
            # Retire l'offset de toutes les images stellaires
            set nom_fich $conf_pt_fc(nmBrutSce)
            append nom_fich "_moinsnoir_"
            set instr "sub2 $conf_pt_fc(nmBrutSce) $conf_pt_fc(nmPrechRes) $nom_fich 0 $conf_pt_fc(nbBrut)"
            Message consolog $caption(pretrfc,SoustrPrechStelProv)
            Message consolog "%s\n" $instr
            eval $instr
            # Retire le noir pondéré de toutes les images stellaires
            set instr "sub2 $nom_fich noir_pondere_temp $nom_fich 0 $conf_pt_fc(nbBrut)"
            Message consolog $caption(pretrfc,SoustrNoirPondStel)
            Message consolog "%s\n" $instr
            eval $instr
         }
         opt {
            # Vérifie si le noir contient la précharge... et agit en conséquence
            if {$conf_pt_fc(NrContientPrech) == 0} {
               # Si offset non inclus... chargement de l'image de noir
               set instr "loadima $conf_pt_fc(nmNoirRes)"
               Message consolog $caption(pretrfc,ChargeNoir)
               Message consolog "%s\n" $instr
               eval $instr
               # Addition de la précharge
               set instr "add $conf_pt_fc(nmPrechRes) 0"
               Message consolog $caption(pretrfc,ajoutePrechNoir)
               Message consolog "%s\n" $instr
               eval $instr
               # Sauvegarde le noir contenant la précharge
               set instr "saveima noir_avec_prech"
               Message consolog $caption(pretrfc,SauveNoirAvecPrech)
               Message consolog "%s\n" $instr
               eval $instr
               # Astuce pour traiter correctement les fichiers de noir...
               set noir_avec_prech noir_avec_prech
            } else {
               # Suite et fin de l'astuce pour traiter correctement les fichiers de noir...
               set noir_avec_prech $conf_pt_fc(nmNoirRes)
            }
            set nom_fich_sortie $conf_pt_fc(nmBrutSce)
            append nom_fich_sortie "_moinsnoir_"
            # Lancement de l'optimisation; le noir doit contenir la précharge !
            set instr "opt2 $conf_pt_fc(nmBrutSce) $noir_avec_prech $conf_pt_fc(nmPrechRes) \
               $nom_fich_sortie $conf_pt_fc(nbBrut)"
            Message consolog $caption(pretrfc,OptBrutes)
            Message consolog "%s\n" $instr
            eval $instr
         }
      }

      # Affichage de la PLU
      set nomFich $conf_pt_fc(nmPLURes)
      Message consolog $caption(pretrfc,chargePLU)
      set instr "loadima $nomFich"
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Calcul de la valeur moyenne de la PLU
      set instr "set valMoyenne \[lindex \[stat\] 4\]"
      Message consolog $caption(pretrfc,calcMoyPLU)
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Division des images par le PLU
      set instr "div2 $conf_pt_fc(nmBrutSce)"
      append instr "_moinsnoir_ $conf_pt_fc(nmPLURes)\
         $conf_pt_fc(nmBrutRes) $valMoyenne $conf_pt_fc(nbBrut)"
      Message consolog $caption(pretrfc,divBrutPLU)
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Affichage de la première image résultante
      set nomFich $conf_pt_fc(nmBrutRes)
      append nomFich "1"
      Message consolog $caption(pretrfc,chargBrutRes)
      set instr "loadima $nomFich"
      Message consolog $instr
      Message consolog "\n"
      eval $instr

      # Effacement du disque des images générées par le prétraitement:
      Message consolog $caption(pretrfc,effaceBrutsInter)
      for {set i 1} {$i <= $conf_pt_fc(nbBrut)} {incr i} {
         set nomFich $audace(rep_images)
         append nomFich "/" $conf_pt_fc(nmBrutSce) "_moinsnoir_" $i $ext
         file delete $nomFich
      }
      set nomFich $audace(rep_images)
      append nomFich "/" "noir_pondere_temp$ext"
      if {[file exists $nomFich]} {
         file delete $nomFich
      }
      set nomFich $audace(rep_images)
      append nomFich "/" "noir_avec_prech$ext"
      if {[file exists $nomFich]} {
         file delete $nomFich
      }

      # Affichage du message de fin du prétraitement des noirs
      Message consolog $caption(pretrfc,finBrut)
      activeBoutons
      focus $audace(base).fenetrePretr
   }
#***** Fin de la procedure traiteBrut ********************************

#***** Procédure de désactivation des boutons de la fenêtre **********
   proc desactiveBoutons { } {
      global audace

      $audace(base).fenetrePretr.et1.test configure -state disabled
      $audace(base).fenetrePretr.et1.recharge configure -state disabled
      $audace(base).fenetrePretr.et1.ligne1.entnmFichScr configure -state disabled
      $audace(base).fenetrePretr.et1.ligne2.ent1 configure -state disabled
      $audace(base).fenetrePretr.et2.titre.case configure -state disabled
      $audace(base).fenetrePretr.et2.go configure -state disabled
      $audace(base).fenetrePretr.et2.ligne1.entnmPrechSce configure -state disabled
      $audace(base).fenetrePretr.et2.ligne1.entNbPrech configure -state disabled
      $audace(base).fenetrePretr.et2.ligne2.ent1 configure -state disabled
      $audace(base).fenetrePretr.et2.ligne2.case configure -state disabled
      $audace(base).fenetrePretr.et2.ligne2.ent2 configure -state disabled
      $audace(base).fenetrePretr.et3.titre.case configure -state disabled
      $audace(base).fenetrePretr.et3.go configure -state disabled
      $audace(base).fenetrePretr.et3.ligne1.entnmNrSce configure -state disabled
      $audace(base).fenetrePretr.et3.ligne1.entNbNr configure -state disabled
      $audace(base).fenetrePretr.et3.ligne2.ent1 configure -state disabled
      $audace(base).fenetrePretr.et3.ligne2.case configure -state disabled
      $audace(base).fenetrePretr.et4.titre.case configure -state disabled
      $audace(base).fenetrePretr.et4.go configure -state disabled
      $audace(base).fenetrePretr.et4.ligne1.entnmNrPLUSce configure -state disabled
      $audace(base).fenetrePretr.et4.ligne1.entNbNrPLU configure -state disabled
      $audace(base).fenetrePretr.et4.ligne2.ent1 configure -state disabled
      $audace(base).fenetrePretr.et5.titre.case configure -state disabled
      $audace(base).fenetrePretr.et5.go configure -state disabled
      $audace(base).fenetrePretr.et5.ligne1.entnmPLUSce configure -state disabled
      $audace(base).fenetrePretr.et5.ligne1.entNbPLU configure -state disabled
      $audace(base).fenetrePretr.et5.ligne2.ent1 configure -state disabled
      $audace(base).fenetrePretr.et5.ligne3.rad1 configure -state disabled
      $audace(base).fenetrePretr.et5.ligne3.rad2 configure -state disabled
      $audace(base).fenetrePretr.et5.ligne3.rad3 configure -state disabled
      $audace(base).fenetrePretr.et6.titre.case configure -state disabled
      $audace(base).fenetrePretr.et6.go configure -state disabled
      $audace(base).fenetrePretr.et6.ligne1.entnmBrutSce configure -state disabled
      $audace(base).fenetrePretr.et6.ligne1.entNbBrut configure -state disabled
      $audace(base).fenetrePretr.et6.ligne2.ent1 configure -state disabled
      $audace(base).fenetrePretr.et6.ligne3.rad1 configure -state disabled
      $audace(base).fenetrePretr.et6.ligne3.rad2 configure -state disabled
      $audace(base).fenetrePretr.et6.ligne3.rad3 configure -state disabled
   }
#***** Fin procédure de désactivation des boutons de la fenêtre ******

#***** Procédure d'activation des boutons de la fenêtre **************
   proc activeBoutons { } {
      global audace

      $audace(base).fenetrePretr.et1.test configure -state normal
      $audace(base).fenetrePretr.et1.recharge configure -state normal
      $audace(base).fenetrePretr.et1.ligne1.entnmFichScr configure -state normal
      $audace(base).fenetrePretr.et1.ligne2.ent1 configure -state normal
      $audace(base).fenetrePretr.et2.titre.case configure -state normal
      $audace(base).fenetrePretr.et2.go configure -state normal
      $audace(base).fenetrePretr.et2.ligne1.entnmPrechSce configure -state normal
      $audace(base).fenetrePretr.et2.ligne1.entNbPrech configure -state normal
      $audace(base).fenetrePretr.et2.ligne2.ent1 configure -state normal
      $audace(base).fenetrePretr.et2.ligne2.case configure -state normal
      $audace(base).fenetrePretr.et2.ligne2.ent2 configure -state normal
      $audace(base).fenetrePretr.et3.titre.case configure -state normal
      $audace(base).fenetrePretr.et3.go configure -state normal
      $audace(base).fenetrePretr.et3.ligne1.entnmNrSce configure -state normal
      $audace(base).fenetrePretr.et3.ligne1.entNbNr configure -state normal
      $audace(base).fenetrePretr.et3.ligne2.ent1 configure -state normal
      $audace(base).fenetrePretr.et3.ligne2.case configure -state normal
      $audace(base).fenetrePretr.et4.titre.case configure -state normal
      $audace(base).fenetrePretr.et4.go configure -state normal
      $audace(base).fenetrePretr.et4.ligne1.entnmNrPLUSce configure -state normal
      $audace(base).fenetrePretr.et4.ligne1.entNbNrPLU configure -state normal
      $audace(base).fenetrePretr.et4.ligne2.ent1 configure -state normal
      $audace(base).fenetrePretr.et5.titre.case configure -state normal
      $audace(base).fenetrePretr.et5.go configure -state normal
      $audace(base).fenetrePretr.et5.ligne1.entnmPLUSce configure -state normal
      $audace(base).fenetrePretr.et5.ligne1.entNbPLU configure -state normal
      $audace(base).fenetrePretr.et5.ligne2.ent1 configure -state normal
      $audace(base).fenetrePretr.et5.ligne3.rad1 configure -state normal
      $audace(base).fenetrePretr.et5.ligne3.rad2 configure -state normal
      $audace(base).fenetrePretr.et5.ligne3.rad3 configure -state normal
      $audace(base).fenetrePretr.et6.titre.case configure -state normal
      $audace(base).fenetrePretr.et6.go configure -state normal
      $audace(base).fenetrePretr.et6.ligne1.entnmBrutSce configure -state normal
      $audace(base).fenetrePretr.et6.ligne1.entNbBrut configure -state normal
      $audace(base).fenetrePretr.et6.ligne2.ent1 configure -state normal
      $audace(base).fenetrePretr.et6.ligne3.rad1 configure -state normal
      $audace(base).fenetrePretr.et6.ligne3.rad2 configure -state normal
      $audace(base).fenetrePretr.et6.ligne3.rad3 configure -state normal
   }
#***** Fin de la procédure d'activation des boutons de la fenêtre ****

#***** Procedure de test de validité d'un nom de fichier *************
# Cette procédure (copiée de Methking) vérifie que la chaine passée en argument est un
# nom de fichier valide.
   proc TestNomFichier { valeur } {
      set test 1
      # Teste qu'il y a bien un nom de fichier
      if {$valeur == ""} {
         set test 0
      }
      # Teste que le nom de fichier n'a pas d'espace
      if {[llength $valeur] > 1} {
         set test 0
      }
      # Teste que le nom des images ne contient pas de caractèrs interdits
      if {[TestChaine $valeur] == 0} {
         set test 0
      }
      return $test
   }
#***** Fin de la procedure de test de validité d'un nom de fichier ***

#***** Procedure de test de validité d'un entier *********************
# Cette procédure (copiée de Methking) vérifie que la chaine passée en argument décrit
# bien un entier. Elle retourne 1 si c'est la cas, et 0 si ce n'est pas un entier.
   proc TestEntier { valeur } {
      set test 1
      if {$valeur == ""} {
         set test 0
      }
      for {set i 0} {$i < [string length $valeur]} {incr i} {
         set a [string index $valeur $i]
	   if {![string match {[0-9]} $a]} {
            set test 0
         }
      }
      return $test
   }
#***** Fin de la procedure de test de validité d'un entier ***********

#***** Procedure de test de validité d'une chaine de caractères ******
# Cette procédure vérifie que la chaine passée en argument ne contient que des caractères
# valides. Elle retourne 1 si c'est la cas, et 0 si ce n'est pas valable.
   proc TestChaine { valeur } {
      set test 1
      for {set i 0} {$i < [string length $valeur]} {incr i} {
         set a [string index $valeur $i]
	   if {![string match {[-a-zA-Z0-9_]} $a]} {
            set test 0
         }
      }
      return $test
   }
#***** Fin procedure de test de validité d'une chaine de caractères **

#***** Procedure de test de validité d'un nombre réel ****************
# Cette procédure (inspirée de Methking) vérifie que la chaine passée en argument décrit
# bien un réel. Elle retourne 1 si c'est la cas, et 0 si ce n'est pas un entier.
   proc TestReel { valeur } {
      set test 1
      for {set i 0} {$i < [string length $valeur]} {incr i} {
         set a [string index $valeur $i]
	   if {![string match {[0-9.]} $a]} {
            set test 0
         }
      }
      return $test
   }
#***** Fin de la procedure de test de validité d'un nombre réel ******

#***** Procedure d'affichage des messages ****************************
# Cette procédure est recopiée de Methking.tcl. Elle permet l'affichage de differents
# messages (dans la console, le fichier log, etc...)
   proc Message { niveau args } {
      variable This
      global caption conf

      switch -exact -- $niveau {
         console {
            ::console::disp [eval [concat {format} $args]]
            update idletasks
         }
         log {
		set temps [clock format [clock seconds] -format %H:%M:%S]
		append temps " "
		catch { puts -nonewline $::pretraitFC::log_id [eval [concat {format} $args]] }
            #--- Force l'ecriture immediate sur le disque
            flush $::pretraitFC::log_id
         }
         consolog {
            if { [ info exists conf(messages_console_pretrfc) ] == "0" } {
               set conf(messages_console_pretrfc) "1"
            }
            if { $conf(messages_console_pretrfc) == "1" } {
		   ::console::disp [eval [concat {format} $args]]
		   update idletasks
            }
		set temps [clock format [clock seconds] -format %H:%M:%S]
		append temps " "
		catch { puts -nonewline $::pretraitFC::log_id [eval [concat {format} $args]] }
            #--- Force l'ecriture immediate sur le disque
            flush $::pretraitFC::log_id
         }
	   default {
            set b [ list "%s\n" $caption(pretrfc,pbmesserr) ]
            ::console::disp [ eval [ concat {format} $b ] ]
		update idletasks
         }
      }
   }
#***** Fin de la procedure d'affichage des messages ******************

}
#=====================================================================
#   Fin de la declaration du Namespace pretraitFC
#=====================================================================

#---------------------------------------------------------------------------------------------

proc pretraitFCBuildIF { This } {
   global audace panneau caption

   #--- Trame du panneau
   frame $This -borderwidth 2 -relief groove -height 75 -width $panneau(pretraitFC,largeur_outil)

      #--- Trame du titre du panneau
      frame $This.titre -borderwidth 2 -relief groove

        Button $This.titre.but -borderwidth 2 -text $caption(pretrfc,titre) \
           -command {
              ::audace::showHelpPlugin tool pretrfc pretrfc.htm
           }
        pack $This.titre.but -in $This.titre -anchor center -expand 1 -fill both -side top
        DynamicHelp::add $This.titre.but -text $caption(pretrfc,help,titre)

      place $This.titre -x 4 -y 4 -height 22 -width [ expr $panneau(pretraitFC,largeur_outil) - 9 ] -anchor nw \
         -bordermode ignore

      #--- Trame du bouton Lancement
      frame $This.go_stop -borderwidth 1 -relief groove

         button $This.go_stop.but -text $caption(pretrfc,lance) \
            -borderwidth 2 -command ::pretraitFC::fenetrePretr
         pack $This.go_stop.but -in $This.go_stop -anchor center -fill none -padx 5 -pady 5 -ipadx 5 -ipady 5

      place $This.go_stop -x 4 -y 32 -height 42 -width [ expr $panneau(pretraitFC,largeur_outil) - 9 ] -anchor nw \
         -bordermode ignore

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

#---------------------------------------------------------------------------------------------
proc creeFenetrePrFC { } {
   global audace caption conf_pt_fc panneau

# Note du 21 mars 2002: Comme j'ajoute la partie offset, je mets un peu le bazar
# dans les numérotations...

   #--- Trame de l'étape 1
   frame $audace(base).fenetrePretr.et1 -borderwidth 2 -relief groove
      #--- Titre de l'étape 1: Prétraitement des noirs & option cosmétique
      frame $audace(base).fenetrePretr.et1.titre -borderwidth 1 -relief groove
         # Affichage du titre
         label $audace(base).fenetrePretr.et1.titre.nom -text $caption(pretrfc,titret1) \
            -font $audace(font,arial_10_b) -justify left
         pack $audace(base).fenetrePretr.et1.titre.nom -side left -in $audace(base).fenetrePretr.et1.titre
      pack $audace(base).fenetrePretr.et1.titre -side top -fill x
      #--- Bouton TEST
      button $audace(base).fenetrePretr.et1.test -borderwidth 2 -width 4 -text $caption(pretrfc,test) \
         -font $audace(font,arial_12_n) -command {
            # Sauvegarde des paramètres dans le fichier de config
            ::pretraitFC::SauvegardeParametres
            # Traitement etape 1
            ::pretraitFC::goCosm
         }
      pack $audace(base).fenetrePretr.et1.test -side right -anchor sw -in $audace(base).fenetrePretr.et1
      #--- Bouton Recharge
      button $audace(base).fenetrePretr.et1.recharge -borderwidth 2 -text $caption(pretrfc,recharge) \
         -font $audace(font,arial_12_n) -command {
            # Sauvegarde des paramètres dans le fichier de config
            ::pretraitFC::SauvegardeParametres
            # Traitement etape 1
            ::pretraitFC::rechargeCosm
         }
      pack $audace(base).fenetrePretr.et1.recharge -side right -anchor sw -in $audace(base).fenetrePretr.et1
      #--- Première ligne de l'étape 1
      frame $audace(base).fenetrePretr.et1.ligne1
         # Affichage du label "Fichier du script"
         label $audace(base).fenetrePretr.et1.ligne1.nmFichScr -text $caption(pretrfc,FichScript) \
            -font $audace(font,arial_10_n) -width 29
         pack $audace(base).fenetrePretr.et1.ligne1.nmFichScr -side left
         # Affichage du champ de saisie "Fichier du script"
         entry $audace(base).fenetrePretr.et1.ligne1.entnmFichScr -width 16 -font $audace(font,arial_10_b) -relief flat \
            -textvariable conf_pt_fc(FichScript) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetrePretr.et1.ligne1.entnmFichScr -side left
      pack $audace(base).fenetrePretr.et1.ligne1 -side top -fill x
      #--- Seconde ligne de l'étape 1
      frame $audace(base).fenetrePretr.et1.ligne2
         # Affichage du label "Procédure de correction cosmétique"
         label $audace(base).fenetrePretr.et1.ligne2.lab1 -text $caption(pretrfc,procCorr) \
            -font $audace(font,arial_10_n) -width 29 -justify right
         pack $audace(base).fenetrePretr.et1.ligne2.lab1 -side left
         # Affichage du champ de saisie "Procédure de correction cosmétique"
         entry $audace(base).fenetrePretr.et1.ligne2.ent1 -width 16 -font $audace(font,arial_10_b) -relief flat\
            -textvariable conf_pt_fc(procCorr) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetrePretr.et1.ligne2.ent1 -side left
      pack $audace(base).fenetrePretr.et1.ligne2 -side top -fill x
   pack $audace(base).fenetrePretr.et1 -side top -fill x

   #--- Trame de l'étape 2
   frame $audace(base).fenetrePretr.et2 -borderwidth 2 -relief groove
      #--- Titre de l'étape 2: Prétraitement des noirs & option cosmétique
      frame $audace(base).fenetrePretr.et2.titre -borderwidth 1 -relief groove
         # Affichage du titre
         label $audace(base).fenetrePretr.et2.titre.nom -text $caption(pretrfc,titret2) \
            -font $audace(font,arial_10_b) -justify left
         pack $audace(base).fenetrePretr.et2.titre.nom -side left -in $audace(base).fenetrePretr.et2.titre
         # Affichage de la case à cocher pour l'activation de la correction cosmétique
         checkbutton $audace(base).fenetrePretr.et2.titre.case -text $caption(pretrfc,corcosm) \
            -font $audace(font,arial_10_n) -variable conf_pt_fc(cosmPrech)
         pack $audace(base).fenetrePretr.et2.titre.case -side right -in $audace(base).fenetrePretr.et2.titre
      pack $audace(base).fenetrePretr.et2.titre -side top -fill x
      #--- Bouton GO
      button $audace(base).fenetrePretr.et2.go -borderwidth 2 -width 4 -text $caption(pretrfc,goet) \
         -font $audace(font,arial_12_n) -command {
            # Sauvegarde des paramètres dans le fichier de config
            ::pretraitFC::SauvegardeParametres
            # Traitement etape 2
            ::pretraitFC::goPrecharge
         }
      pack $audace(base).fenetrePretr.et2.go -side right -anchor sw -in $audace(base).fenetrePretr.et2
      #--- Première ligne de l'étape 2
      frame $audace(base).fenetrePretr.et2.ligne1
         # Affichage du label "Nom des fichiers source"
         label $audace(base).fenetrePretr.et2.ligne1.nmPrechSce -text $caption(pretrfc,nmPrechSce) \
            -font $audace(font,arial_10_n) -width 29
         pack $audace(base).fenetrePretr.et2.ligne1.nmPrechSce -side left
         # Affichage du champ de saisie "Nom des fichiers source"
         entry $audace(base).fenetrePretr.et2.ligne1.entnmPrechSce -width 16 -font $audace(font,arial_10_b) -relief flat\
            -textvariable conf_pt_fc(nmPrechSce) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetrePretr.et2.ligne1.entnmPrechSce -side left
         # Affichage du label "Nombre de fichiers source"
         label $audace(base).fenetrePretr.et2.ligne1.nbPrech -text $caption(pretrfc,nb) -font $audace(font,arial_10_n)
         pack $audace(base).fenetrePretr.et2.ligne1.nbPrech -side left
         # Affichage du champ de saisie "Nombre de fichiers source"
         entry $audace(base).fenetrePretr.et2.ligne1.entNbPrech -width 3 -font $audace(font,arial_10_b) -relief flat\
            -textvariable conf_pt_fc(nbPrech) -justify center -borderwidth 1 -relief groove
         pack $audace(base).fenetrePretr.et2.ligne1.entNbPrech -side left
      pack $audace(base).fenetrePretr.et2.ligne1 -side top -fill x
      #--- Seconde ligne de l'étape 2
      frame $audace(base).fenetrePretr.et2.ligne2
         # Affichage du label "Nom du fichier destination"
         label $audace(base).fenetrePretr.et2.ligne2.lab1 -text $caption(pretrfc,nmPrechRes) \
            -font $audace(font,arial_10_n) -width 29 -justify right
         pack $audace(base).fenetrePretr.et2.ligne2.lab1 -side left
         # Affichage du champ de saisie "Nom du fichier destination"
         entry $audace(base).fenetrePretr.et2.ligne2.ent1 -width 16 -font $audace(font,arial_10_b) -relief flat\
            -textvariable conf_pt_fc(nmPrechRes) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetrePretr.et2.ligne2.ent1 -side left
         # Affichage de la case à cocher pour filtrer la médiane
         checkbutton $audace(base).fenetrePretr.et2.ligne2.case -text $caption(pretrfc,medFiltree) \
            -font $audace(font,arial_10_n) -variable conf_pt_fc(medFiltree)
         pack $audace(base).fenetrePretr.et2.ligne2.case -side left -in $audace(base).fenetrePretr.et2.ligne2
         # Affichage du champ de saisie "Filtrage"
         entry $audace(base).fenetrePretr.et2.ligne2.ent2 -width 3 -font $audace(font,arial_10_b) -relief flat\
            -textvariable conf_pt_fc(filtrage) -justify center -borderwidth 1 -relief groove
         pack $audace(base).fenetrePretr.et2.ligne2.ent2 -side left
      pack $audace(base).fenetrePretr.et2.ligne2 -side top -fill x
   pack $audace(base).fenetrePretr.et2 -side top -fill x

   #--- Trame de l'étape 3
   frame $audace(base).fenetrePretr.et3 -borderwidth 2 -relief groove
      #--- Titre de l'étape 3: Prétraitement des noirs & option cosmétique
      frame $audace(base).fenetrePretr.et3.titre -borderwidth 1 -relief groove
         # Affichage du titre
         label $audace(base).fenetrePretr.et3.titre.nom -text $caption(pretrfc,titret3) \
            -font $audace(font,arial_10_b) -justify left
         pack $audace(base).fenetrePretr.et3.titre.nom -side left -in $audace(base).fenetrePretr.et3.titre
         # Affichage de la case à cocher pour l'activation de la correction cosmétique
         checkbutton $audace(base).fenetrePretr.et3.titre.case -text $caption(pretrfc,corcosm) \
            -font $audace(font,arial_10_n) -variable conf_pt_fc(cosmNoir)
         pack $audace(base).fenetrePretr.et3.titre.case -side right -in $audace(base).fenetrePretr.et3.titre
      pack $audace(base).fenetrePretr.et3.titre -side top -fill x
      #--- Bouton GO
      button $audace(base).fenetrePretr.et3.go -borderwidth 2 -width 4 -text $caption(pretrfc,goet) \
         -font $audace(font,arial_12_n) -command {
            # Sauvegarde des paramètres dans le fichier de config
            ::pretraitFC::SauvegardeParametres
            # Traitement etape 3
            ::pretraitFC::goNoir
         }
      pack $audace(base).fenetrePretr.et3.go -side right -anchor sw -in $audace(base).fenetrePretr.et3
      #--- Première ligne de l'étape 3
      frame $audace(base).fenetrePretr.et3.ligne1
         # Affichage du label "Nom des fichiers source"
         label $audace(base).fenetrePretr.et3.ligne1.nmNrSce -text $caption(pretrfc,nmNrSce) \
            -font $audace(font,arial_10_n) -width 29
         pack $audace(base).fenetrePretr.et3.ligne1.nmNrSce -side left
         # Affichage du champ de saisie "Nom des fichiers source"
         entry $audace(base).fenetrePretr.et3.ligne1.entnmNrSce -width 16 -font $audace(font,arial_10_b) -relief flat \
            -textvariable conf_pt_fc(nmNrSce) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetrePretr.et3.ligne1.entnmNrSce -side left
         # Affichage du label "Nombre de fichiers source"
         label $audace(base).fenetrePretr.et3.ligne1.nbNr -text $caption(pretrfc,nbNr) -font $audace(font,arial_10_n)
         pack $audace(base).fenetrePretr.et3.ligne1.nbNr -side left
         # Affichage du champ de saisie "Nombre de fichiers source"
         entry $audace(base).fenetrePretr.et3.ligne1.entNbNr -width 3 -font $audace(font,arial_10_b) -relief flat\
            -textvariable conf_pt_fc(nbNoirs) -justify center -borderwidth 1 -relief groove
         pack $audace(base).fenetrePretr.et3.ligne1.entNbNr -side left
      pack $audace(base).fenetrePretr.et3.ligne1 -side top -fill x
      #--- Seconde ligne de l'étape 3
      frame $audace(base).fenetrePretr.et3.ligne2
         # Affichage du label "Nom du fichier destination"
         label $audace(base).fenetrePretr.et3.ligne2.lab1 -text $caption(pretrfc,nmNrRes) \
            -font $audace(font,arial_10_n) -width 29 -justify right
         pack $audace(base).fenetrePretr.et3.ligne2.lab1 -side left
         # Affichage du champ de saisie "Nom du fichier source"
         entry $audace(base).fenetrePretr.et3.ligne2.ent1 -width 16 -font $audace(font,arial_10_b) -relief flat\
            -textvariable conf_pt_fc(nmNoirRes) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetrePretr.et3.ligne2.ent1 -side left
         # Affichage de la case à cocher pour indiquer si le noir contient la précharge
         checkbutton $audace(base).fenetrePretr.et3.ligne2.case -text $caption(pretrfc,NrContientPrech) \
            -font $audace(font,arial_10_n) -variable conf_pt_fc(NrContientPrech)
         pack $audace(base).fenetrePretr.et3.ligne2.case -side left -in $audace(base).fenetrePretr.et3.ligne2
      pack $audace(base).fenetrePretr.et3.ligne2 -side top -fill x
   pack $audace(base).fenetrePretr.et3 -side top -fill x

   #--- Trame de l'étape 4
   frame $audace(base).fenetrePretr.et4 -borderwidth 2 -relief groove
      #--- Titre de l'étape 4: Prétraitement des noirs & option cosmétique
      frame $audace(base).fenetrePretr.et4.titre -borderwidth 1 -relief groove
         # Affichage du titre
         label $audace(base).fenetrePretr.et4.titre.nom -text $caption(pretrfc,titret4) \
            -font $audace(font,arial_10_b) -justify left
         pack $audace(base).fenetrePretr.et4.titre.nom -side left -in $audace(base).fenetrePretr.et4.titre
         # Affichage de la case à cocher pour l'activation de la correction cosmétique
         checkbutton $audace(base).fenetrePretr.et4.titre.case -text $caption(pretrfc,corcosm) \
            -font $audace(font,arial_10_n) -variable conf_pt_fc(cosmNrPLU)
         pack $audace(base).fenetrePretr.et4.titre.case -side right -in $audace(base).fenetrePretr.et4.titre
      pack $audace(base).fenetrePretr.et4.titre -side top -fill x
      #--- Bouton GO
      button $audace(base).fenetrePretr.et4.go -borderwidth 2 -width 4 -text $caption(pretrfc,goet) \
         -font $audace(font,arial_12_n) -command {
            # Sauvegarde des paramètres dans le fichier de config
            ::pretraitFC::SauvegardeParametres
            # Traitement etape 4
            ::pretraitFC::goNoirDePLU
         }
      pack $audace(base).fenetrePretr.et4.go -side right -anchor sw -in $audace(base).fenetrePretr.et4
      #--- Première ligne de l'étape 4
      frame $audace(base).fenetrePretr.et4.ligne1
         # Affichage du label "Nom des fichiers source"
         label $audace(base).fenetrePretr.et4.ligne1.nmNrPLUSce -text $caption(pretrfc,nmNrPLUSce) \
            -font $audace(font,arial_10_n) -width 29
         pack $audace(base).fenetrePretr.et4.ligne1.nmNrPLUSce -side left
         # Affichage du champ de saisie "Nom des fichiers source"
         entry $audace(base).fenetrePretr.et4.ligne1.entnmNrPLUSce -width 16 -font $audace(font,arial_10_b) -relief flat\
            -textvariable conf_pt_fc(nmNrPLUSce) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetrePretr.et4.ligne1.entnmNrPLUSce -side left
         # Affichage du label "Nombre de fichiers source"
         label $audace(base).fenetrePretr.et4.ligne1.nbNrPLU -text $caption(pretrfc,nb) -font $audace(font,arial_10_n)
         pack $audace(base).fenetrePretr.et4.ligne1.nbNrPLU -side left
         # Affichage du champ de saisie "Nombre de fichiers source"
         entry $audace(base).fenetrePretr.et4.ligne1.entNbNrPLU -width 3 -font $audace(font,arial_10_b) -relief flat\
            -textvariable conf_pt_fc(nbNrPLU) -justify center -borderwidth 1 -relief groove
         pack $audace(base).fenetrePretr.et4.ligne1.entNbNrPLU -side left
      pack $audace(base).fenetrePretr.et4.ligne1 -side top -fill x
      #--- Seconde ligne de l'étape 4
      frame $audace(base).fenetrePretr.et4.ligne2
         # Affichage du label "Nom du fichier destination"
         label $audace(base).fenetrePretr.et4.ligne2.lab1 -text $caption(pretrfc,nmNrPLURes) \
            -font $audace(font,arial_10_n) -width 29 -justify right
         pack $audace(base).fenetrePretr.et4.ligne2.lab1 -side left
         # Affichage du champ de saisie "Nom du fichier destination"
         entry $audace(base).fenetrePretr.et4.ligne2.ent1 -width 16 -font $audace(font,arial_10_b) -relief flat\
            -textvariable conf_pt_fc(nmNrPLURes) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetrePretr.et4.ligne2.ent1 -side left
         # Affichage des boutons radio pour le mode de noir
      pack $audace(base).fenetrePretr.et4.ligne2 -side top -fill x
   pack $audace(base).fenetrePretr.et4 -side top -fill x

   #--- Trame de l'étape 5
   frame $audace(base).fenetrePretr.et5 -borderwidth 2 -relief groove
      #--- Titre de l'étape 5: Prétraitement des PLU
      frame $audace(base).fenetrePretr.et5.titre -borderwidth 1 -relief groove
         # Affichage du titre
         label $audace(base).fenetrePretr.et5.titre.nom -text $caption(pretrfc,titret5) \
            -font $audace(font,arial_10_b) -justify left
         pack $audace(base).fenetrePretr.et5.titre.nom -side left -in $audace(base).fenetrePretr.et5.titre
         # Affichage de la case à cocher pour l'activation de la correction cosmétique
         checkbutton $audace(base).fenetrePretr.et5.titre.case -text $caption(pretrfc,corcosm) \
            -font $audace(font,arial_10_n) -variable conf_pt_fc(cosmPLU)
         pack $audace(base).fenetrePretr.et5.titre.case -side right -in $audace(base).fenetrePretr.et5.titre
      pack $audace(base).fenetrePretr.et5.titre -side top -fill x
      #--- Bouton GO
      button $audace(base).fenetrePretr.et5.go -borderwidth 2 -width 4 -text $caption(pretrfc,goet) \
         -font $audace(font,arial_12_n) -command {
            # Sauvegarde des paramètres dans le fichier de config
            ::pretraitFC::SauvegardeParametres
            # Traitement etape 5
            ::pretraitFC::goPLU
         }
      pack $audace(base).fenetrePretr.et5.go -side right -anchor sw -in $audace(base).fenetrePretr.et5
      #--- Première ligne de l'étape 5
      frame $audace(base).fenetrePretr.et5.ligne1
         # Affichage du label "Nom des fichiers source"
         label $audace(base).fenetrePretr.et5.ligne1.nmPLUSce -text $caption(pretrfc,nmPLUSce) \
            -font $audace(font,arial_10_n) -width 29
         pack $audace(base).fenetrePretr.et5.ligne1.nmPLUSce -side left
         # Affichage du champ de saisie "Nom des fichiers source"
         entry $audace(base).fenetrePretr.et5.ligne1.entnmPLUSce -width 16 -font $audace(font,arial_10_b) -relief flat\
            -textvariable conf_pt_fc(nmPLUSce) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetrePretr.et5.ligne1.entnmPLUSce -side left
         # Affichage du label "Nombre de fichiers source"
         label $audace(base).fenetrePretr.et5.ligne1.nbPLU -text $caption(pretrfc,nb) -font $audace(font,arial_10_n)
         pack $audace(base).fenetrePretr.et5.ligne1.nbPLU -side left
         # Affichage du champ de saisie "Nombre de fichiers source"
         entry $audace(base).fenetrePretr.et5.ligne1.entNbPLU -width 3 -font $audace(font,arial_10_b) -relief flat\
            -textvariable conf_pt_fc(nbPLU) -justify center -borderwidth 1 -relief groove
         pack $audace(base).fenetrePretr.et5.ligne1.entNbPLU -side left
      pack $audace(base).fenetrePretr.et5.ligne1 -side top -fill x
      #--- Seconde ligne de l'étape 5
      frame $audace(base).fenetrePretr.et5.ligne2
         # Affichage du label "Nom du fichier résultant"
         label $audace(base).fenetrePretr.et5.ligne2.lab1 -text $caption(pretrfc,nmPLURes) \
            -font $audace(font,arial_10_n) -width 29 -justify right
         pack $audace(base).fenetrePretr.et5.ligne2.lab1 -side left
         # Affichage du champ de saisie "Nom du fichier résultant"
         entry $audace(base).fenetrePretr.et5.ligne2.ent1 -width 16 -font $audace(font,arial_10_b) -relief flat\
            -textvariable conf_pt_fc(nmPLURes) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetrePretr.et5.ligne2.ent1 -side left
      pack $audace(base).fenetrePretr.et5.ligne2 -side top -fill x
      #--- Troisième ligne de l'étape 5
      frame $audace(base).fenetrePretr.et5.ligne3
         label $audace(base).fenetrePretr.et5.ligne3.lab1 -text $caption(pretrfc,SoustrNrPLU) \
            -font $audace(font,arial_10_n)
         pack $audace(base).fenetrePretr.et5.ligne3.lab1 -side left
         radiobutton $audace(base).fenetrePretr.et5.ligne3.rad1 -variable conf_pt_fc(modePLU) \
            -text $caption(pretrfc,NrPLUBut1) -value simple -font $audace(font,arial_10_n)
         pack $audace(base).fenetrePretr.et5.ligne3.rad1 -side left
         radiobutton $audace(base).fenetrePretr.et5.ligne3.rad2 -variable conf_pt_fc(modePLU) \
            -text $caption(pretrfc,NrPLUBut2) -value rapTps -font $audace(font,arial_10_n)
         pack $audace(base).fenetrePretr.et5.ligne3.rad2 -side left
         radiobutton $audace(base).fenetrePretr.et5.ligne3.rad3 -variable conf_pt_fc(modePLU) \
            -text $caption(pretrfc,NrPLUBut3) -value opt -font $audace(font,arial_10_n)
         pack $audace(base).fenetrePretr.et5.ligne3.rad3 -side left
      pack $audace(base).fenetrePretr.et5.ligne3 -side top -fill x
   pack $audace(base).fenetrePretr.et5 -side top -fill x

   #--- Trame de l'étape 6
   frame $audace(base).fenetrePretr.et6 -borderwidth 2 -relief groove
      #--- Titre de l'étape 6: Prétraitement des PLU
      frame $audace(base).fenetrePretr.et6.titre -borderwidth 1 -relief groove
         # Affichage du titre
         label $audace(base).fenetrePretr.et6.titre.nom -text $caption(pretrfc,titret6) \
            -font $audace(font,arial_10_b) -justify left
         pack $audace(base).fenetrePretr.et6.titre.nom -side left -in $audace(base).fenetrePretr.et6.titre
         # Affichage de la case à cocher pour l'activation de la correction cosmétique
         checkbutton $audace(base).fenetrePretr.et6.titre.case -text $caption(pretrfc,corcosm) \
            -font $audace(font,arial_10_n) -variable conf_pt_fc(cosmBrut)
         pack $audace(base).fenetrePretr.et6.titre.case -side right -in $audace(base).fenetrePretr.et6.titre
      pack $audace(base).fenetrePretr.et6.titre -side top -fill x
      #--- Bouton GO
      button $audace(base).fenetrePretr.et6.go -borderwidth 2 -width 5 -text $caption(pretrfc,goet) \
         -font $audace(font,arial_15_b) -command {
            # Sauvegarde des paramètres dans le fichier de config
            ::pretraitFC::SauvegardeParametres
            # Traitement etape 6
            ::pretraitFC::goBrut
         }
      pack $audace(base).fenetrePretr.et6.go -side right -anchor sw -in $audace(base).fenetrePretr.et6
      #--- Première ligne de l'étape 6
      frame $audace(base).fenetrePretr.et6.ligne1
         # Affichage du label "Nom des fichiers source"
         label $audace(base).fenetrePretr.et6.ligne1.nmBrutSce -text $caption(pretrfc,nmBrutSce) \
            -font $audace(font,arial_10_n) -width 29
         pack $audace(base).fenetrePretr.et6.ligne1.nmBrutSce -side left
         # Affichage du champ de saisie "Nom des fichiers source"
         entry $audace(base).fenetrePretr.et6.ligne1.entnmBrutSce -width 16 -font $audace(font,arial_10_b) -relief flat\
            -textvariable conf_pt_fc(nmBrutSce) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetrePretr.et6.ligne1.entnmBrutSce -side left
         # Affichage du label "Nombre de fichiers source"
         label $audace(base).fenetrePretr.et6.ligne1.nbBrut -text $caption(pretrfc,nb) -font $audace(font,arial_10_n)
         pack $audace(base).fenetrePretr.et6.ligne1.nbBrut -side left
         # Affichage du champ de saisie "Nombre de fichiers source"
         entry $audace(base).fenetrePretr.et6.ligne1.entNbBrut -width 3 -font $audace(font,arial_10_b) -relief flat\
            -textvariable conf_pt_fc(nbBrut) -justify center -borderwidth 1 -relief groove
         pack $audace(base).fenetrePretr.et6.ligne1.entNbBrut -side left
      pack $audace(base).fenetrePretr.et6.ligne1 -side top -fill x
      #--- Seconde ligne de l'étape 6
      frame $audace(base).fenetrePretr.et6.ligne2
         # Affichage du label "Nom du fichier résultant"
         label $audace(base).fenetrePretr.et6.ligne2.lab1 -text $caption(pretrfc,nmBrutRes) \
            -font $audace(font,arial_10_n) -width 29 -justify right
         pack $audace(base).fenetrePretr.et6.ligne2.lab1 -side left
         # Affichage du champ de saisie "Nom du fichier résultant"
         entry $audace(base).fenetrePretr.et6.ligne2.ent1 -width 16 -font $audace(font,arial_10_b) -relief flat\
            -textvariable conf_pt_fc(nmBrutRes) -justify left -borderwidth 1 -relief groove
         pack $audace(base).fenetrePretr.et6.ligne2.ent1 -side left
      pack $audace(base).fenetrePretr.et6.ligne2 -side top -fill x
      #--- Troisième ligne de l'étape 6
      frame $audace(base).fenetrePretr.et6.ligne3
         label $audace(base).fenetrePretr.et6.ligne3.lab1 -text $caption(pretrfc,SoustrNr) -font $audace(font,arial_10_n)
         pack $audace(base).fenetrePretr.et6.ligne3.lab1 -side left
         radiobutton $audace(base).fenetrePretr.et6.ligne3.rad1 -variable conf_pt_fc(modeBrut) \
            -text $caption(pretrfc,NrBut1) -value simple -font $audace(font,arial_10_n)
         pack $audace(base).fenetrePretr.et6.ligne3.rad1 -side left
         radiobutton $audace(base).fenetrePretr.et6.ligne3.rad2 -variable conf_pt_fc(modeBrut) \
            -text $caption(pretrfc,NrBut2) -value rapTps -font $audace(font,arial_10_n)
         pack $audace(base).fenetrePretr.et6.ligne3.rad2 -side left
         radiobutton $audace(base).fenetrePretr.et6.ligne3.rad3 -variable conf_pt_fc(modeBrut) \
            -text $caption(pretrfc,NrBut3) -value opt -font $audace(font,arial_10_n)
         pack $audace(base).fenetrePretr.et6.ligne3.rad3 -side left
      pack $audace(base).fenetrePretr.et6.ligne3 -side top -fill x
   pack $audace(base).fenetrePretr.et6 -side top -fill x

   focus $audace(base).fenetrePretr

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $audace(base).fenetrePretr
}

#---------------------------------------------------------------------------------------------

::pretraitFC::Init $audace(base)

#---------------------------------------------------------------------------------------------
# Fin du fichier pretraitFC.tcl
#---------------------------------------------------------------------------------------------

