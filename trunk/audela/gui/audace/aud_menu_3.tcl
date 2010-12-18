#
# Fichier : aud_menu_3.tcl
# Description : Script regroupant les fonctionnalites du menu Pretraitement
# Mise à jour $Id: aud_menu_3.tcl,v 1.74 2010-12-18 15:35:45 robertdelmas Exp $
#

namespace eval ::pretraitement {

   #
   # ::pretraitement::parcourir In_Out
   # Ouvre un explorateur pour choisir un fichier
   #
   proc parcourir { In_Out } {
      global audace caption pretraitement

      #--- Fenetre parent
      set fenetre "$audace(base).pretraitement"
      #--- Ouvre la fenetre de choix des images
      set filename [ ::tkutil::box_load $fenetre $audace(rep_images) $audace(bufNo) "1" ]
      #--- Le fichier selectionne doit imperativement etre dans le repertoire des images
      if { [ file dirname $filename ] != $audace(rep_images) } {
         tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
            -message "$caption(pretraitement,rep-images)"
         return
      }
      #--- Extraction du nom du fichier
      if { $In_Out == "1" } {
         if { $pretraitement(choix_mode) == "2" } {
            set pretraitement(info_filename_in)  [ ::pretraitement::afficherNomGenerique [ file tail $filename ] ]
            set pretraitement(in)                [ lindex $pretraitement(info_filename_in) 0 ]
            set pretraitement(nb)                [ lindex $pretraitement(info_filename_in) 1 ]
            set pretraitement(valeur_indice)     [ lindex $pretraitement(info_filename_in) 2 ]
         } else {
            set pretraitement(in)                [ file rootname [ file tail $filename ] ]
         }
      } elseif { $In_Out == "2" } {
         if { $pretraitement(choix_mode) == "2" } {
            set pretraitement(info_filename_out) [ ::pretraitement::afficherNomGenerique [ file tail $filename ] ]
            set pretraitement(out)               [ lindex $pretraitement(info_filename_out) 0 ]
         } else {
            set pretraitement(out)               [ file rootname [ file tail $filename ] ]
         }
      } elseif { $In_Out == "3" } {
         set pretraitement(img_operand)          [ file rootname [ file tail $filename ] ]
      } elseif { $In_Out == "4" } {
         set pretraitement(dark)                 [ file rootname [ file tail $filename ] ]
      } elseif { $In_Out == "5" } {
         set pretraitement(offset)               [ file rootname [ file tail $filename ] ]
      }
   }

   #
   # ::pretraitement::afficherNomGenerique
   # Affiche le nom generique des fichiers d'une serie si c'en est une, le nombre
   # d'elements de la serie et le premier indice de la serie s'il est different de 1
   # Renumerote la serie s'il y a des trous ou si elle debute par un 0
   #
   proc afficherNomGenerique { filename { animation 0 } } {
      global audace caption conf

      #--- Est-ce un nom generique de fichiers ?
      set nom_generique  [ lindex [ decomp $filename ] 1 ]
      set index_serie    [ lindex [ decomp $filename ] 2 ]
      set ext_serie      [ lindex [ decomp $filename ] 3 ]
      #--- J'extrais la liste des index de la serie
      set error [ catch { lsort -integer [ liste_index $nom_generique ] } msg ]
      if { $error == "0" } {
         #--- Pour une serie du type 1 - 2 - 3 - etc.
         set liste_serie [ lsort -integer [ liste_index $nom_generique ] ]
      } else {
         #--- Pour une serie du type 01 - 02 - 03 - etc.
         set liste_serie [ lsort -ascii [ liste_index $nom_generique ] ]
      }
      #--- Longueur de la liste des index
      set longueur_serie [ llength $liste_serie ]
      if { $index_serie != "" && $longueur_serie >= "1" } {
         ::console::disp "$caption(pretraitement,nom_generique_ok)\n\n"
      } else {
         tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
            -message "$caption(pretraitement,nom_generique_ko)"
         #--- Ce n'est pas un nom generique, sortie anticipee
         set nom_generique  ""
         set longueur_serie ""
         set indice_min     "1"
         return [ list $nom_generique $longueur_serie $indice_min ]
      }
      #--- Identification du type de numerotation
      set error [ catch { lsort -integer [ liste_index $nom_generique ] } msg ]
      if { $error == "0" } {
         #--- Pour une serie du type 1 - 2 - 3 - etc.
         set liste_serie [ lsort -integer [ liste_index $nom_generique ] ]
      } else {
         #--- Pour une serie du type 01 - 02 - 03 - etc.
         set liste_serie [ lsort -ascii [ liste_index $nom_generique ] ]
      }
      #--- Longueur de la serie
      set longueur_serie [ llength $liste_serie ]
      #--- Premier indice de la serie
      set indice_min [ lindex $liste_serie 0 ]
      #--- La serie ne commence pas par 0
      if { $indice_min != "0" } {
         set new_indice_min [ string trimleft $indice_min 0 ]
         #--- La serie commence par 1
         if { $new_indice_min == "1" } {
            #--- Est-ce une serie avec des fichiers manquants ?
            set etat_serie [ numerotation_usuelle $nom_generique ]
            if { $etat_serie == "0" } {
               #--- Il manque des fichiers dans la serie, je propose de renumeroter la serie
               set choix [ tk_messageBox -title "$caption(pretraitement,attention)" \
                  -message "$caption(pretraitement,fichier_manquant)\n$caption(pretraitement,renumerotation)" \
                  -icon question -type yesno ]
               if { $choix == "yes" } {
                  renumerote $nom_generique -rep "$audace(rep_images)" -ext "$ext_serie"
                  ::console::disp "$caption(pretraitement,renumerote_termine)\n\n"
               } else {
                  tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
                     -message "$caption(pretraitement,pas_renumerotation)"
                  #--- Sortie anticipee
                  set nom_generique  ""
                  set longueur_serie ""
                  set indice_min     "1"
                  return [ list $nom_generique $longueur_serie $indice_min ]
               }
            } else {
               #--- Il ne manque pas de fichiers dans la serie
               ::console::disp "$caption(pretraitement,numerotation_ok)\n$caption(pretraitement,pas_fichier_manquant)\n\n"
            }
         #--- La serie ne commence pas par 1
         } else {
            #--- J'extrais la liste des index de la serie
            set error [ catch { lsort -integer [ liste_index $nom_generique ] } msg ]
            if { $error == "0" } {
               #--- Pour une serie du type 1 - 2 - 3 - etc.
               set liste_serie [ lsort -integer [ liste_index $nom_generique ] ]
            } else {
               #--- Pour une serie du type 01 - 02 - 03 - etc.
               set liste_serie [ lsort -ascii [ liste_index $nom_generique ] ]
            }
            #--- J'extrais la longueur, le premier et le dernier indice de la serie
            set longueur_serie [ llength $liste_serie ]
            set indice_min [ lindex $liste_serie 0 ]
            set indice_max [ lindex $liste_serie [ expr $longueur_serie - 1 ] ]
            #--- Je signale l'absence d'index autre que 1
            if { $animation == "0" } {
               if { [ expr $indice_max - $indice_min + 1 ] != $longueur_serie } {
                  tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
                     -message "$caption(pretraitement,renumerote_manuel)"
                  #--- Sortie anticipee
                  set nom_generique  ""
                  set longueur_serie ""
                  set indice_min     "1"
                  return [ list $nom_generique $longueur_serie $indice_min ]
               }
            } elseif { $animation == "1" } {
               #--- J'extrais la liste des index de la serie
               set error [ catch { lsort -integer [ liste_index $nom_generique ] } msg ]
               if { $error == "0" } {
                  #--- Pour une serie du type 1 - 2 - 3 - etc.
                  set liste_serie [ lsort -integer [ liste_index $nom_generique ] ]
               } else {
                  #--- Pour une serie du type 01 - 02 - 03 - etc.
                  set liste_serie [ lsort -ascii [ liste_index $nom_generique ] ]
               }
               #--- J'extrais la longueur et le premier indice de la serie
               set longueur_serie [ llength $liste_serie ]
               set indice_min [ lindex $liste_serie 0 ]
               ::console::disp "$caption(pretraitement,liste_serie) $liste_serie \n\n"
               ::console::disp "$caption(pretraitement,nom_generique) $nom_generique \n"
               ::console::disp "$caption(pretraitement,image_nombre) $longueur_serie \n"
               ::console::disp "$caption(pretraitement,image_premier_indice) $indice_min \n\n"
               return [ list $nom_generique $longueur_serie $indice_min $liste_serie ]
            }
         }
      #--- La serie commence par 0
      } else {
         #--- Je recherche le dernier indice de la liste
         set dernier_indice [ expr [ lindex $liste_serie [ expr $longueur_serie - 1 ] ] + 1 ]
         #--- Je renumerote le fichier portant l'indice 0
         set buf_pretrait [ ::buf::create ]
         buf$buf_pretrait extension $conf(extension,defaut)
         buf$buf_pretrait load [ file join $audace(rep_images) $nom_generique$indice_min$ext_serie ]
         buf$buf_pretrait save [ file join $audace(rep_images) $nom_generique$dernier_indice$ext_serie ]
         ::buf::delete $buf_pretrait
         file delete [ file join $audace(rep_images) $nom_generique$indice_min$ext_serie ]
         #--- Est-ce une serie avec des fichiers manquants ?
         set etat_serie [ numerotation_usuelle $nom_generique ]
         if { $etat_serie == "0" } {
            #--- Il manque des fichiers dans la serie, je propose de renumeroter la serie
            set choix [ tk_messageBox -title "$caption(pretraitement,attention)" \
               -message "$caption(pretraitement,indice_pas_1)\n$caption(pretraitement,fichier_manquant)\n$caption(pretraitement,renumerotation)" \
               -icon question -type yesno ]
            if { $choix == "yes" } {
               renumerote $nom_generique -rep "$audace(rep_images)" -ext "$ext_serie"
               ::console::disp "$caption(pretraitement,renumerote_termine)\n$caption(pretraitement,fichier_indice_0)\n\n"
            } else {
               tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
                  -message "$caption(pretraitement,pas_renumerotation)\n$caption(pretraitement,fichier_indice_0)"
               #--- Sortie anticipee
               set nom_generique  ""
               set longueur_serie ""
               set indice_min     "1"
               return [ list $nom_generique $longueur_serie $indice_min ]
            }
         } else {
            #--- Il ne manque pas de fichiers dans la serie
            ::console::disp "$caption(pretraitement,indice_pas_1)\n$caption(pretraitement,pas_fichier_manquant)\n$caption(pretraitement,fichier_indice_0)\n\n"
         }
      }
      #--- J'extrais la liste des index de la serie
      set error [ catch { lsort -integer [ liste_index $nom_generique ] } msg ]
      if { $error == "0" } {
         #--- Pour une serie du type 1 - 2 - 3 - etc.
         set liste_serie [ lsort -integer [ liste_index $nom_generique ] ]
      } else {
         #--- Pour une serie du type 01 - 02 - 03 - etc.
         set liste_serie [ lsort -ascii [ liste_index $nom_generique ] ]
      }
      #--- J'extrais la longueur et le premier indice de la serie
      set longueur_serie [ llength $liste_serie ]
      set indice_min [ lindex $liste_serie 0 ]
      ::console::disp "$caption(pretraitement,liste_serie) $liste_serie \n\n"
      ::console::disp "$caption(pretraitement,nom_generique) $nom_generique \n"
      ::console::disp "$caption(pretraitement,image_nombre) $longueur_serie \n"
      ::console::disp "$caption(pretraitement,image_premier_indice) $indice_min \n\n"
      return [ list $nom_generique $longueur_serie $indice_min $liste_serie ]
   }

}

########################## Fin du namespace pretraitement ##########################

namespace eval ::conv2 {

# Auteur : Raymond ZACHANTKE

   #########################################################################
   # Lance le script des conversion                                        #
   #########################################################################
   proc run { { type_conversion "" } } {
      variable this
      variable private
      variable widget
      variable CONVERSION
      global audace caption

      #--- icone hourglass
      set private(conv2,hourglass) [ image create photo imagehourglass -data {
         R0lGODlhGAAYAIIAMVQYGKmkKvr8BFlbTKKkp7kDBJprPt7d3ywAAAAAGAAY
         AAIDZii63P4wyklVuEHkW4UpgfEVJJBVwDAALGt0GnEcRA28nTzPhAoHO1oP
         VwnIDCrVqQPsDWGLpgkanQ2IP9ngcIUCebRpbjeo+Zgz5LWbq/WSA1hK1bp1
         DDd6AbBfTjCAHFSDhIUMCQA7
      } ]

      #--- icone info
      set private(conv2,info) [ image create photo imageinfo -data {
         R0lGODlhGAAYAIIAMS4tNpKSpvD4Nfj5+l1eUHd30goI+66vqiwAAAAAGAAY
         AAIDkyi6GnHvsTnhGTgfS9nLILh1wgUWRhoeBGWCaVqs7RKEGKriQb3hQBzg
         ILjxCoVA4SUClIAHnWGGOwyN1Rh1BfhAtdAudgWudovBcqhbQIcCsdR4QCBI
         BITVZfPL9HoMeUFvbBQAgkEsdncTBABDIY51BTUkDo+CBV2LJBVWF3V8nSR5
         AUOjo3UERKidh6ytlgEkCQA7
      } ]

      #--- icone nop
      set private(conv2,nop) [ image create photo imagenop -data {
         R0lGODlhGAAYAIIAMfoFB6WovKvU+e31+uSts3tkd+hSV98vMCwAAAAAGAAY
         AAIDoTi6GiMwyiCCY0rgvULhF4d5nCYyQvFhpgY9jzt4JnO5URyRRBUQlAzs
         Rax8LMgWbJgxhjo6idTYEAAt0eluhaTUWMPUs9HUbk2Ua1Y7W82Sa21hPBMW
         dwcA4HD5Yc0QBnqDBwRvdYAFg4sHaHEReQYHkoIAXChCD3sYBJZVSV0WewSk
         pIIHClcWc6GVi3puJxmvenyynHmDKrcbBAUHKisJADs=
      } ]

      #--- icone ok
      set private(conv2,ok) [ image create photo imageok -data {
         R0lGODlhGAAYAIIAMSE8ZASlBAV/C6SrpoKChfr8+hPWE2i5aCwAAAAAGAAY
         AAIDZ1i63P4wykmrjedcd4wY23IEAgBug0GWxXBSqSADLUG8bc4Y3lzYNkbH
         c4rJSgNgcKGSERS9mUvZ6AEIvCPgqnxWj4IVsuv9gqVJ6iOqNXUxx8CWTCFs
         512chLy08PV1QIAhhIWGDAkAOw==
      } ]

      #--- initialisation de variables
      ::conv2::initConf
      ::conv2::confToWidget

      set private(conv2,rep) "$audace(rep_images)"
      set private(conv2,conversion) "$type_conversion"
      #--   definit l'extension reelle des fichiers
      if {$::conf(fichier,compres) eq "1"} {
         set private(conv2,extension) "$::conf(extension,defaut).gz"
      } else {
         set private(conv2,extension) $::conf(extension,defaut)
      }

      #--- liste les libelles du menubutton
      set private(conv2,formules) "[dict keys $CONVERSION]"

      #--- liste les operations de conversion et les noms generiques
      foreach formule $private(conv2,formules) {
         set op "[dict get $CONVERSION $formule fun]"
         lappend private(conv2,operations) $op
         set private(conv2,$op,generique) "[dict get $CONVERSION $formule gen]"
      }

      #--- cherche la longueur maximale du libelle des formules
      #--- pour dimensionner la largeur du menuboutton
      set private(conv2,bwidth) "0"
      foreach formule $private(conv2,formules) {
         set private(conv2,bwidth) [ expr { max([ string length $formule ],$private(conv2,bwidth)) } ]
      }

      #--- classe et liste les fichiers convertibles par type de conversion
      #--- les sept listes sont contenues dans l'array bdd
      #--- ouvre la fenetre de selection de la conversion
      if { [ ::conv2::ListFiles ] != "0" } {
         #--- positionne sur l'operation demandee
         #set private(conv2,conversion) "$type_conversion"
         #--- ouvre la fenetre de conversion
         set this "$audace(base).dialog"
         if { [ winfo exists $this ] } {
            wm withdraw $this
            wm deiconify $this
            focus $this
            #--- selectionne la conversion
            set i [ lsearch -exact $private(conv2,formules) $private(conv2,conversion) ]
            incr i
            $this.but.menu invoke $i
        } else {
            if { [ info exists widget(geometry) ] } {
               set deb [ expr 1 + [ string first + $widget(geometry) ] ]
               set fin [ string length $widget(geometry) ]
               set widget(conv2,position) "+[string range $widget(geometry) $deb $fin]"
            }
            ::conv2::CreateDialog "$audace(base).dialog"
         }
         #--- initialise les listes de fichiers in & out
         #--- evite une erreur si on appuie sur 'Appliquer'
         lassign { "" "" } private(conv2,in) private(conv2,out)
      }
   }

   #########################################################################
   # Liste les images par nature (raw cfa rgb plan_coul all_files)         #
   # et cree l'array bdd des listes des noms courts de fichiers            #
   #########################################################################
   proc ListFiles { } {
      variable private
      variable bdd
      global caption

      #--- initialise les listes
      lassign { "" "" "" "" "" "" "" "" ""} fits raw cfa rgb plan_coul assign_r assign_g assign_b ::conv2::maj_header

      #--- etape 1 : recherche les fichiers raw convertibles
      if { $::tcl_platform(platform) == "windows" } {
         #--- la recherche de l'extension est insensible aux minuscules/majuscules ... sous windows uniquement
         foreach extension { ARW CR2 CRW DNG ERF MRW NEF ORF RAF RW2 SR2 TIFF X3F } {
            set raw [ concat $raw [ glob -nocomplain -type f -join $private(conv2,rep) *.$extension ] ]
         }
      } else {
         #--- la recherche de l'extension est _sensible_ aux minuscules/majuscules dans tous les autres cas
         foreach extension { ARW CR2 CRW DNG ERF MRW NEF ORF RAF RW2 SR2 TIFF X3F \
                             arw cr2 crw dng erf mrw nef orf raf rw2 sr2 tiff x3f } {
            set raw [ concat $raw [ glob -nocomplain -type f -join $private(conv2,rep) *.$extension ] ]
         }
      }

      #--- remplace le nom par le nom court
      foreach fi $raw {
         set i [ lsearch -exact $raw $fi ]
         set raw [ lreplace $raw $i $i [ file tail $fi ] ]
      }

      #--- etape 2 : recherche les fichiers d'extensions par defaut
      if { $::tcl_platform(platform) eq "windows" } {
         set pattern "\{$private(conv2,extension)\}"
      } else {
         #--   pour Linux
         set pattern "\{[string tolower $private(conv2,extension)] [string toupper $private(conv2,extension)]\}"
      }
      #--   remplace les espaces par une virgule
      regsub -all " " $pattern "," pattern
      set files [glob -nocomplain -type f -join $private(conv2,rep) *$pattern]
      foreach fichier $files {
         #--- capture les kwds
         if ![ catch { set kwds_list [ fitsheader $fichier ] } ] {

            #--- cree un array des kwds
            #--- detecte les erreurs dans les mots-cles
            set error "0"
            foreach kwd $kwds_list {

               set err1 [ catch { set nom [ lindex $kwd 0 ] } ]
               set err2 [ catch { set valeur [ lindex $kwd 1 ] } ]

               if { $err1 == "0" && $err2 == "0" } {
                  array set kwds [ list $nom $valeur ]
               } else {
                  set error "1"
               }
            }

            if { $error == "0" } {

               #--- recherche des anciens mots-cles
               set data ""
               lappend data [ array get kwds "RAW_COLORS" ] [ array get kwds "RAW_FILTER" ] \
                  [ array get kwds "RAW_BLACK" ] [ array get kwds "RAW_MAXIMUM" ]
               if { $data != "{} {} {none} {} {}" } {
                  #--- si l'image contient un seul de ces mots cles elle est mise dans la liste
                  lappend ::conv2::maj_header "$fichier"
               }

               #--- extrait les kwd en vue des tests de classification
               set data [ list [ lindex [array get kwds "NAXIS" ] 1 ] \
                  [ lindex [ array get kwds "NAXIS3" ] 1 ] \
                  [ lindex [ array get kwds "RGBFILTR" ] 1 ] \
                  [ lindex [ array get kwds "RAWFILTE" ] 1 ] \
                  [ lindex [ array get kwds "RAW_FILTER" ] 1 ] ]
               lassign $data naxis naxis3 rgbfiltr rawfilte raw_filter
               set file [file tail $fichier ]

               #--- classe les fichiers en fonction de leur nature
               if { $naxis == "3" && $naxis3 == "3" } {
                  lappend rgb "$file"
               } elseif { $naxis == "2" && $rgbfiltr =="" && ( $rawfilte != "" || $raw_filter != "" ) } {
                  lappend cfa "$file"
               } elseif { $naxis == "2" && $rgbfiltr !="" } {
                  #--- enleve l'extension
                  set file [ file rootname $file ]
                  set term [ string range $file end end ]
                  if {$term eq "[ string tolower $rgbfiltr ]" } {
                     #--- isole la racine du nom (index compris)
                     set racine [ string range $file 0 end-1 ]
                     #--- cree une ligne de dictionary
                     dict set plans $racine couleur $rgbfiltr $file
                  } else {
                     #--   assimiles a des plans N&B si discordance entre RGBFILTR et indice terminal
                     lappend assign_r "$file"
                     lappend assign_g "$file"
                     lappend assign_b "$file"
                  }
               } else {
                  #--   vrais plans N&B
                  lappend assign_r "$file"
                  lappend assign_g "$file"
                  lappend assign_b "$file"
               }
            } else {
               ::console::affiche_erreur "$fichier $caption(pretraitement,err_entete) $::errorInfo\n\n"
            }
            array unset kwds
         } else {
            ::console::affiche_erreur "$fichier $caption(pretraitement,err_analyse) $::errorInfo\n\n"
         }
      }

      #--- etape 3 selectionne les triades R  G  B de plans couleurs
      #--- s'il n'y a que un ou deux plans l'image n'est pas selectionnee
      catch { dict for { id info } $plans {
            dict with info {
               if { [ expr {[ llength $couleur ]/2} ] == "3" } {
                  lappend plan_coul "$id"
               }
            }
         }
      }

      #--- etape 4 : construit la base de donnees (conversion,liste des fichiers)
      foreach op $private(conv2,operations) liste [list $raw $cfa $rgb $plan_coul $assign_r $assign_g $assign_b] {
         set private(conv2,$op,no_file) ""
         if { $liste == "" } {
            set liste [ list $caption(pretraitement,no_file) ]
            set private(conv2,$op,no_file) $liste
         } else {
            set private(conv2,$op,no_file) ""
         }
         set private(conv2,$op,state) "normal"
         if { [ llength $liste ] != "0" } {
            array set bdd [ list $op $liste ]
         }
      }

      return [ array size bdd ]
   }

   #########################################################################
   # Recupere la position de la fenetre                                    #
   #########################################################################
   proc recupPosition { } {
      variable this
      variable widget

      set widget(geometry) [wm geometry $this]
      set deb [ expr 1 + [ string first + $widget(geometry) ] ]
      set fin [ string length $widget(geometry) ]
      set widget(conv2,position) "+[string range $widget(geometry) $deb $fin]"
      #---
      ::conv2::widgetToConf
   }

   #########################################################################
   # Charge les variables de configuration dans des variables locales      #
   #########################################################################
   proc confToWidget { } {
      variable widget
      global conf

      set widget(conv2,position) "$conf(conv2,position)"
   }

   #########################################################################
   # Charge les variables locales dans des variables de configuration      #
   #########################################################################
   proc widgetToConf { } {
      variable widget
      global conf

      set conf(conv2,position) "$widget(conv2,position)"
   }

   #########################################################################
   # Initialisation des variables de configuration                         #
   #########################################################################
   proc initConf { } {
      global conf

      if { ! [ info exists conf(conv2,position) ] } { set conf(conv2,position) "+350+75" }

      return
   }

   #########################################################################
   # Cree la fenetre de dialogue                                           #
   #########################################################################
   proc CreateDialog { this } {
      variable private
      variable widget
      global caption color conf

      set private(conv2,This) $this
      if [ winfo exists $this ] { destroy $this }
      toplevel $this
      wm resizable $this 0 0
      wm minsize $this 250 150
      wm deiconify $this
      wm title $this "$::caption(audace,menu,preprocess) - $caption(audace,menu,convertir)"
      wm geometry $this $widget(conv2,position)
      wm protocol $this WM_DELETE_WINDOW ::conv2::Fermer

      ::blt::table $this
      #--- rappel du repertoire
      Label $this.info -justify left\
          -text "$caption(pretraitement,repertoire) ../[ file tail $private(conv2,rep) ]"

      #--- bouton de menu
      menubutton $this.but -relief raised -textvariable conversion \
         -menu $this.but.menu -width $private(conv2,bwidth)

      #--- menu du bouton
      set m [ menu $this.but.menu -tearoff "1" ]
      foreach form $private(conv2,formules) {
         $m add radiobutton -label "$form" -indicatoron "1" -value "$form" \
            -variable conversion
      }

      ::conv2::MenuUpdate

      set tbl $this.tl
      set private(conv2,tbl) $tbl

      #--- definit la structure et les caracteristiques
      ::tablelist::tablelist $tbl \
         -height 9 -width 50 -stretch all -borderwidth 2 \
         -columns [ list 0 "" center \
            0 $caption(pretraitement,src) left \
            0 "" center \
            0 $caption(pretraitement,output) left \
            0 $caption(pretraitement,done) center ] \
         -xscrollcommand [ list $this.hscroll set ] \
         -yscrollcommand [ list $this.vscroll set ] \
         -editendcommand { ::conv2::applyValue } \
         -exportselection 0 -setfocus 1 -activestyle none

      #--- nomme les colonnes
      foreach col { 1 3 4 } name { src dest done } {
         $tbl columnconfigure $col -name $name
      }

      scrollbar $this.hscroll -orient horizontal -command [ list $tbl xview ]
      scrollbar $this.vscroll -command [ list $tbl yview ]

      #--- frame du message
      Label $this.labURLmsg -justify center -borderwidth 1 -relief raised -fg $color(blue)

      #--- frame avec les options
      Label $this.label -text "$caption(pretraitement,options)"

      #--- cree 4 checkbuttons
      foreach child { all renum chg destroy_src } { ::conv2::CheckButton $this $child }
      $this.all configure -command "::conv2::SelectAll"
      #--- pour annuler la cmd
      $this.destroy_src configure -command { }

      #--- cree l'entree pour le nom generique
      Entry $this.generique -width 15 -relief sunken \
         -justify right -state normal -textvariable ::conv2::private(conv2,new_name) \
         -command "::conv2::EntryCtrl"

      #--- les boutons de commandes
      frame $this.cmd -borderwidth 1 -relief raised
         button $this.cmd.ok -text "$caption(aud_menu_3,ok)" -width 7 \
            -command "::conv2::cmdOk"
         if { $conf(ok+appliquer)=="1" } {
            pack $this.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }
         button $this.cmd.appliquer -text "$caption(aud_menu_3,appliquer)" -width 8 \
            -command "::conv2::Process"
         pack $this.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
         button $this.cmd.fermer -text "$caption(aud_menu_3,fermer)" -width 7 \
            -command "::conv2::Fermer"
         pack $this.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         button $this.cmd.aide -text "$caption(aud_menu_3,aide)" -width 7 \
            -command "::conv2::afficheAide"
         pack $this.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x
      pack $this.cmd -side top -fill x

      #--- positionne les elements dans la table
      ::blt::table $this \
         $this.info 0,1 -cspan 2 -anchor w -padx { 10 5 } -pady { 5 5 } -height 1c \
         $this.but 0,3 -cspan 2 -anchor e -height 1c \
         $this.tl 1,0 -cspan 5 -fill both \
         $this.vscroll 1,5 -fill y -width $this.vscroll \
         $this.hscroll 2,0 -cspan 5 -fill x -height $this.hscroll \
         $this.labURLmsg 3,0 -fill x -cspan 6 -height 1c \
         $this.label 4,1 -rspan 4 -fill x -height 3c\
         $this.all 4,2 -anchor w \
         $this.renum 5,2 -anchor w \
         $this.chg 6,2 -cspan 3 -anchor w \
         $this.generique 6,4 -anchor w \
         $this.destroy_src 7,2 -anchor w \
         $this.cmd 8,0 -cspan 6 -fill both -height 1c

      #--- selectionne la conversion
      set i [ lsearch -exact $private(conv2,formules) $private(conv2,conversion) ]
      incr i
      $this.but.menu invoke $i

      #--- focus
      focus $this

      #--- raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $this <Key-F1> { ::console::GiveFocus }

      #--- mise a jour dynamique des couleurs
      ::confColor::applyColor $this
   }

   #########################################################################
   # Affiche la liste des fichiers convertibles                            #
   #########################################################################
   proc Select { op } {
      variable private
      variable bdd
      global caption

      #--- memorise l'operation
      set private(conv2,conversion) "$op"

      #--- efface l'ancienne liste
      catch { $private(conv2,tbl) delete 0 [ $private(conv2,tbl) size ] }

      #--- extrait la liste des fichiers RAW, CFA, RGB ou R G B, ou indifferencies de bdd
      set private(conv2,liste_cibles) [ lsort -dictionary -index 0 [ lindex [ array get bdd $op ] 1 ] ]

      set private(conv2,nb) [ llength $private(conv2,liste_cibles) ]

      #--- cree une ligne par fichier convertible
      for { set i 0 } { $i < $private(conv2,nb) } { incr i } {
         set cible [ lindex $private(conv2,liste_cibles) $i ]

         #--- adapte le texte a afficher (premier chargement)
         switch -exact $op {
            "raw2fits"     {  set out "[ file rootname $cible ]$private(conv2,extension)" }
            "cfa2rgb"      {  set cible "[ file rootname $cible ]"
                              set out "[ file rootname $cible ]" }
            "rgb2r+g+b"    {  set cible "[ file rootname $cible ]"
                              set out "${cible}r + ${cible}g + ${cible}b"
                           }
            "r+g+b2rgb"    {  set out $cible
                              set cible "${cible}r + ${cible}g + ${cible}b"
                           }
            "assigner_r"   {  set cible "[ file rootname $cible ]"
                              set out "[ file rootname [string range $cible 0 end-1] ]r"
                           }
            "assigner_g"   {  set cible "[ file rootname $cible ]"
                              set out "[ file rootname [string range $cible 0 end-1] ]g"
                           }
            "assigner_b"   {  set cible "[ file rootname $cible ]"
                              set out "[ file rootname [string range $cible 0 end-1] ]b"
                           }
         }

         #--- insere la nouvelle ligne
         if { $cible == "$caption(pretraitement,no_file)" } {
            $private(conv2,tbl) insert end [ list "" "$cible" ]
            set private(conv2,nb) "0"
         } elseif { $cible == "$caption(pretraitement,no_file)r + $caption(pretraitement,no_file)g + $caption(pretraitement,no_file)b" } {
            $private(conv2,tbl) insert end [ list "" "$caption(pretraitement,no_file)" ]
            set private(conv2,nb) "0"
         } else {
            $private(conv2,tbl) insert end [ list "" "$cible" "-->" "$out" "" ]
            #--- insere le checkbutton
            $private(conv2,tbl) cellconfigure end,0 -window [ list ::conv2::CreateCheckButton $i ]
         }
      }

      ::conv2::WindowConfigure $op

      focus $private(conv2,This)
   }

   #########################################################################
   # Cree les listes de fichiers selectionnes (entree et sortie)           #
   # en conformite avec les processus de traitement                        #
   # les fichiers peuvent etre renommes et/ou renumerotes                  #
   # de maniere a pouvoir etre pretraites (offset, dark et flat)           #
   #########################################################################
   proc UpdateDialog { } {
      variable private

      #--- initialise les listes de fichiers in & out
      lassign { "" "" } private(conv2,in) private(conv2,out)

      #--- recupere la valeur de la commande de renumerotation
      set renumerote $::conv2::private(conv2,renum)

      #--- recupere la valeur de la commande de modification du nom generique
      set chg_generique $::conv2::private(conv2,chg)
      set this $private(conv2,This).generique
      if { $chg_generique == 0 } {
         set private(conv2,new_name) ""
         $this configure -state disabled
      } else {
         if { $private(conv2,new_name) == "" } {
            set op $private(conv2,conversion)
            set private(conv2,new_name) $private(conv2,$op,generique)
         }
         $this configure -state normal
      }

      for { set i 0 } { $i < $private(conv2,nb) } { incr i } {

         set in [ lindex $private(conv2,liste_cibles) $i ]
         set out [ file rootname $in ]

         #--- efface le contenu de la cellule REMARQUE
         $private(conv2,tbl) cellconfigure $i,done -image ""

         #--- configure l'affichage des fichiers selectionnes en fonction des options
         if { $::conv2::private(conv2,file_$i) == "1" } {

            #--- decompose le nom en generique et index
            lassign [ decomp $in ] rep generique_in index_out

            #--- change le generique
            set out $generique_in
            if { $chg_generique == "1" } { set out $private(conv2,new_name) }

            #--- modifie l'indexation des fichiers de sortie
            if { $renumerote == "1" } { set index_out [ expr { [ llength $private(conv2,out) ]+1} ] }

            #--- reconstitue le nom de sortie
            set out "$out$index_out"

            #--- verifie s'il y a collision avec un fichier exsitant ou a creer
            if [ ::conv2::Collision "$in" "$out" ] {
               #--- deselectionne le checkbutton
               set w [ $private(conv2,tbl) windowpath $i,0 ]
               $w deselect
               #--- affiche le symbole interdit
               ::conv2::Avancement nop $i
            }
         }

         #--- rafraichissement du nom 'out' sans extension sauf pour raw2fits
         switch -exact $private(conv2,conversion) {
            "raw2fits"     { set texte "$out$private(conv2,extension)" }
            "r+g+b2rgb"    { set texte "$out" }
            "rgb2r+g+b"    { set texte "${out}r + ${out}g + ${out}b" }
            "cfa2rgb"      { set texte "$out" }
            "assigner_r"   { set texte "${out}r" }
            "assigner_g"   { set texte "${out}g" }
            "assigner_b"   { set texte "${out}b" }
         }

         #--- actualise l'affichage dans la tablelist
         $private(conv2,tbl) cellconfigure $i,dest -text $texte
      }
      ::conv2::WindowUpdate
   }

   #########################################################################
   # Detecte les collisions avec des fichiers existants ou a creer         #
   # Constitue les listes de fichiers a convertir in & out                 #
   # Parametres : nom entrant, nom sortant                                 #
   # Sorties : listes de fichiers in & out, 1 si collision sinon 0         #
   #########################################################################
   proc Collision { in out } {
      variable private

      set ext $private(conv2,extension)
      switch -exact $private(conv2,conversion) {
         "raw2fits"     { set file_out $out$ext
                          set explore [ list "$file_out" ]
                        }
         "r+g+b2rgb"    { set file_out "$out"
                          set explore [ list "$out$ext" ]
                        }
         "rgb2r+g+b"    { set file_out "$out"
                          foreach i { r g b } {
                           set name$i $out
                           append name$i  "$i$ext"
                          }
                          set explore [ list $namer $nameg $nameb ]
                        }
         "cfa2rgb"      { set file_out "$out$ext"
                          set explore [ list "$file_out" ]
                        }
         "assigner_r"   { set file_out "${out}r$ext"
                          set explore [ list "$file_out"]
                        }
         "assigner_g"   { set file_out "${out}g$ext"
                          set explore [ list "$file_out"]
                        }
         "assigner_b"   { set file_out "${out}b$ext"
                          set explore [ list "$file_out"]
                        }
      }

      #--- detecte un fichier out pre-existant ou a venir
      set err "0"
      foreach f $explore {
         #--- file exists retourne 1 si le fichier teste existe dans le repertoire
         set err [ expr { $err + [ file exists [ file join $private(conv2,rep) $f ] ] } ]

         #--- incremente le nombre d'erreur si le nom du fichier existe dans la liste des fichiers a creer
         if { $private(conv2,out) != "" && ($f in $private(conv2,out)) } { incr err }
      }

      if { $err == "0" } {
         #--- complete les listes de fichiers entrant et sortant
         lappend private(conv2,in) "$in"
         lappend private(conv2,out) $file_out
      }

     return $err
   }

   #------------------------ pilote de conversion --------------------------

   #########################################################################
   # Pilote les conversions a partir des listes in & out                   #
   #########################################################################
   proc cmdOk { } {
      ::conv2::Process
      ::conv2::Fermer
   }

   #########################################################################
   # Procedure correspondant a l'appui sur le bouton Aide                  #
   #########################################################################
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,pretrait)" "1020conversion_couleurs.htm"
   }

   #########################################################################
   # Pilote les conversions a partir des listes in & out                   #
   #########################################################################
   proc Process { } {
      variable private
      global caption

      #--- elimine les caracteres non autorises dans le nom
      ::conv2::EntryCtrl

      set l [ llength $private(conv2,in) ]
      #--- arrete si aucune selection
      if { $l == "0" } {
         ::conv2::Error "$caption(pretraitement,no_selection)"
         return
      }

      #--- change l'etat des boutons et appelle la console
      #--- pour les eventuels messages d'erreur
      ::conv2::WindowActive disabled
      ::console::GiveFocus
      update

      for { set i 0 } { $i < $l } { incr i } {

         #--- cherche le rang du fichier traite dans la liste initiale
         set j [ lsearch -exact $private(conv2,liste_cibles) [ lindex $private(conv2,in) $i ] ]

         #--- definit les noms complets in et out
         set in [ file join $private(conv2,rep) [ lindex $private(conv2,in) $i ] ]
         set out [ file join $private(conv2,rep) [ lindex $private(conv2,out) $i ] ]

         #--- amene la cellule dans la zone visible
         $private(conv2,tbl) seecell $j,done
         ::conv2::Avancement "hourglass" $j
         update

         #--- convertit chaque fichier
         switch [ Do_$private(conv2,conversion) $in $out ] {
            0  { ::conv2::Avancement ok $j }
            1  { ::console::affiche_erreur "$private(conv2,msg)\n\n"
                 ::conv2::Avancement info $j
               }
         }
         update

         #--- si demande, detruit l'image-source
         if { $private(conv2,destroy_src) == "1" } {
            foreach f $private(conv2,to_destroy) {
               file delete $f
            }
         }

         #--- detruit le message d'erreur existant
         catch { unset private(conv2,msg) }
      }

      #--- met a jour la base de donnees des fichiers
      ::conv2::ListFiles

      #--- met a jour les commandes du menu
      ::conv2::MenuUpdate

      #--- change l'etat des boutons
      ::conv2::WindowActive normal

      #--- recupere la position de la fenetre
      ::conv2::recupPosition
   }

   #------------------ sept routines de conversion -----------------------
   #########################################################################
   # Do_assigner_r                                                         #
   #########################################################################
   proc Do_assigner_r { in out } {
      global audace

      set buf "buf$audace(bufNo)"
      set err [ catch {
         $buf load $in
         $buf setkwd [ list RGBFILTR R string "Color extracted (red)" "" ]
         $buf save $out
      } ]

      if { $err == "1" } {
         set private(conv2,msg) [ format $caption(pretraitement,echec) $in $::errorInfo ]
      }
      return $err
   }

   #########################################################################
   # Do_assigner_g                                                         #
   #########################################################################
   proc Do_assigner_g { in out } {
      global audace


      set buf "buf$audace(bufNo)"
      set err [ catch {
         $buf load $in
         $buf setkwd [ list RGBFILTR G string "Color extracted (green)" "" ]
         $buf save $out
      } ]

      if { $err == "1" } {
         set private(conv2,msg) [ format $caption(pretraitement,echec) $in $::errorInfo ]
      }
      return $err

   }

   #########################################################################
   # Do_assigner_b                                                         #
   #########################################################################
   proc Do_assigner_b { in out } {
      global audace

      set buf "buf$audace(bufNo)"
      set err [ catch {
         $buf load $in
         $buf setkwd [ list RGBFILTR B string "Color extracted (blue)" "" ]
         $buf save $out
      } ]

      if { $err == "1" } {
         set private(conv2,msg) [ format $caption(pretraitement,echec) $in $::errorInfo ]
      }
      return $err
   }

   #########################################################################
   # Conversion R+G+B--> RGB                                               #
   #########################################################################
   proc Do_r+g+b2rgb { in out } {
      variable private
      global audace caption

      set buf "buf$audace(bufNo)"

      if {[info exists ::prtr::bitpix]} {
         set bitpix [::prtr::convertBitPix2BitPix $::prtr::bitpix]
         #--   convertit le reglage par defaut en valeur
         switch $::conf(format_fichier_image) {
            "0"   {set bitpix_defaut "ushort" }
            "1"   {set bitpix_defaut "float" }
         }
         if {$bitpix ne "$bitpix_defaut"} {$buf bitpix $bitpix}
      }

      if [ info exists private(conv2,extension) ] {
         set ext "$private(conv2,extension)"
      } else {
         set ext $::conf(extension,defaut)
      }

      set err [ catch {

         set filter ""
         set filternu ""

         #--- charge, modifie les en-tetes et sauve les trois images
         set private(conv2,to_destroy) ""
         foreach i { r g b } k { 1 2 3 } {

            #--- charge chaque image R, G et B
            $buf load ${in}$i$ext

            #--- si necessaire change les mots cles
            ::conv2::MajHeader ${in}$i$ext

            #--- au cas ou les seuils n'existeraient pas
            $buf stat

            #--- construit les en-tetes des seuils couleurs
            set color [ string toupper $i ]
            foreach kwd { MIPS-HI MIPS-LO } level [ list "Low" "Hight" ] {
               set val [ lindex [ $buf getkwd $kwd ] 1 ]
               switch $color {
                  R  {  set $kwd$color [ list $kwd$color $val float "Red $level Cut" "adu" ] }
                  G  {  set $kwd$color [ list $kwd$color $val float "Green $level Cut" "adu" ] }
                  B  {  set $kwd$color [ list $kwd$color $val float "Blue $level Cut" "adu" ] }
               }
            }

            #--   recupere le contenu des mots-cles FILTER et FILTERNU
            set filter [ concat $filter [ lindex [$buf getkwd FILTER ] 1 ] ]
            set filternu [ concat $filternu [ lindex [$buf getkwd FILTERNU ] 1 ] ]

            #--- memorise les fichiers a detruire
            lappend private(conv2,to_destroy) ${in}$i$ext

            #--- sauve les images avec un index numerique
            $buf save ${in}$k$ext
         }

         #--- conversion en une image
         fitsconvert3d $in 3 $ext $out
         $buf load $out$ext
         $buf delkwd "RGBFILTR"

         #--- inscrit les seuils couleurs dans l'en-tete
         foreach kwd [ list MIPS-LOR MIPS-HIR MIPS-LOG MIPS-HIG MIPS-LOB MIPS-HIB ] {
            $buf setkwd [ set $kwd ]
         }
         $buf stat

         #---  met a jour FILTER et FILTERNU
         foreach f {FILTER FILTERNU} content [ list $filter $filternu ] {
            if { $content ne "" } {
               set kwd [ $buf getkwd $f ]
               set kwd [ lreplace $kwd 1 2 "sum of \{$content\}" "string" ]
               $buf setkwd $kwd
            }
         }

         #--- sauve l'image couleur
         $buf save $out$ext

         #--- supprime les images avec un index numerique
         foreach i { 1 2 3 } { file delete ${in}$i$ext }
      } ]

      if { $err == "1" } {
         set private(conv2,msg) [ format $caption(pretraitement,echec) $in $::errorInfo ]
      }
      return $err
   }

   #########################################################################
   # Conversion RGB-->R+G+B                                                #
   #########################################################################
   proc Do_rgb2r+g+b { in out } {
      variable private
      global audace caption

      set buf "buf$audace(bufNo)"
      set private(conv2,to_destroy) [ list $in ]

      set err [ catch {

         #--- charge l'image
         $buf load $in

         #--- si necessaire change les mots cles et sauve l'image
         ::conv2::MajHeader $in

         #--- je fixe NAXIS a 2
         set kwdNaxis [ $buf getkwd NAXIS ]
         set kwdNaxis [ lreplace $kwdNaxis 1 1 "2" ]
         $buf setkwd $kwdNaxis

         #--- extrait les seuils bas et haut une seule fois
         foreach kwd [ list MIPS-LO MIPS-HI FILTER FILTERNU ] {
            set $kwd [ $buf getkwd $kwd ]
         }

         #--   textrait les valeurs des mots-cles FILTER et FILTERNU
         if {$FILTER ne "" && $FILTERNU ne ""} {
            regsub {(sum of \{)} [lindex $FILTER 1] "" liste_filter
            regsub \} $liste_filter "" liste_filter
            regsub {(sum of \{)} [lindex $FILTERNU 1] "" liste_filternu
            regsub \} $liste_filternu "" liste_filternu
         }

         foreach indice { 1 2 3 } c { r g b } {

            #--- definit le symbole du plan couleur
            set s [ string toupper $c ]
            switch $s {
               R  { set color Red }
               G  { set color Green }
               B  { set color Blue }
            }
            set filter [ list RGBFILTR $s string "Color extracted ($color)" "" ]
            $buf setkwd $filter

            foreach kwd { MIPS-LO MIPS-HI} {
               #--- cherche le seuil du plan couleur
               set seuil [ $buf getkwd $kwd$s ]
               #--- extrait la valeur
               set valeur [ lindex $seuil 1 ]
               #--- la replace dans le MIPS correspondant
               set $kwd [ lreplace [ set $kwd ] 1 1 $valeur ]
               #--- sauvegarde le seuil
               $buf setkwd [ set $kwd ]
            }

            if {$liste_filter ne "" && $liste_filternu ne "" } {
               set k [expr {$indice-1}]
               set FILTER [lreplace $FILTER 1 1 [lindex $liste_filter $k]]
               $buf setkwd $FILTER
               set FILTERNU [lreplace $FILTERNU 1 2 [lindex $liste_filternu $k] int]
               $buf setkwd $FILTERNU
            }

            #--- sauve le plan couleur
            $buf save3d ${out}$c 3 $indice $indice

         }
      } ]

      if { $err == "1" } {
         set private(conv2,msg) [ format $caption(pretraitement,echec) $in $::errorInfo ]
      }
      return $err
   }

   #########################################################################
   # Conversion CFA --> RGB                                                #
   #########################################################################
   proc Do_cfa2rgb { in out } {
      variable private
      global audace caption

      set buf "buf$audace(bufNo)"
      set ext [ file extension $out ]
      set dir [ file dirname $out]
      set generique [ file rootname $out ]
      set nom [ file tail $generique ]
      set private(conv2,to_destroy) [ list $in ]

      set err [ catch {

         #--- charge l'image
         $buf load $in

         #--- si necessaire change les mots cles et sauve l'image
         ::conv2::MajHeader $in

         #--- convertit en couleurs
         $buf cfa2rgb 1

         #--- permet le calcul les seuils
         $buf stat

         #--- sauve l'image
         $buf save $out

         #--- decompose l'image couleurs en 3 plans pour calculer les seuils
         #--- memorise NAXIS
         set kwdNaxis [ $buf getkwd NAXIS ]
         #--- fixe NAXIS a 2
         $buf setkwd [ lreplace $kwdNaxis 1 1 "2" ]

         foreach indice { 1 2 3 } {
            #--- definit le filtre RGBFILTR de chaque plan
            switch $indice {
                  1  {  set filter [ list RGBFILTR R string "Color extracted (Red)" "" ] }
                  2  {  set filter [ list RGBFILTR G string "Color extracted (Green)" "" ] }
                  3  {  set filter [ list RGBFILTR B string "Color extracted (Blue)" "" ] }
            }
            #--- change l'en-tete
            $buf setkwd $filter
            #--- sauve le plan couleur
            $buf save3d ${generique}$indice$ext 3 $indice $indice
         }

         #--- fait les stat sur les 3 plans couleurs
         ttscript2 "IMA/SERIES \"$dir\" $nom 1 3 $ext \"$dir\" $nom 1 $ext STAT"

         #--- reprend chaque plan couleur
         foreach file [ list ${generique}1 ${generique}2 ${generique}3 ] color { R G B } {
            #--- extrait les kwd
            set kwds_list [ fitsheader $file$ext ]

            foreach kwd [ list "MIPS-LO" "MIPS-HI" ] level [ list "Low" "Hight" ] {
               #--- cherche l'index du mot cle
               set index [ lsearch -index 0 $kwds_list $kwd ]
               #--- isole la valeur
               set val [ lindex [ lindex $kwds_list $index ] 1 ]
               #--- memorise le seuil couleur
               switch $color {
                  R  {  set $kwd$color [ list $kwd$color $val float "Red $level Cut" "adu" ] }
                  G  {  set $kwd$color [ list $kwd$color $val float "Green $level Cut" "adu" ] }
                  B  {  set $kwd$color [ list $kwd$color $val float "Blue $level Cut" "adu" ] }
               }
            }
         }

         #--- efface la mention du plan couleur
         $buf delkwd RGBFILTR

         #--- retablit naxis=3
         $buf setkwd $kwdNaxis

         #--- inscrit les seuils couleurs dans l'en-tete
         foreach kwd [ list MIPS-LOR MIPS-HIR MIPS-LOG MIPS-HIG MIPS-LOB MIPS-HIB ] {
            $buf setkwd [ set $kwd ]
         }

         #--- sauve l'image
         $buf save $out

         #--- efface les plans couleurs
         ttscript2 "IMA/SERIES \"$dir\" $nom 1 3 $ext . . . . DELETE"

      } ]

      if { $err == "1" } {
         set private(conv2,msg) [ format $caption(pretraitement,echec) $in $::errorInfo ]
      }
      return $err
   }

   #########################################################################
   # Conversion RAW --> FITS                                               #
   #########################################################################
   proc Do_raw2fits { in out } {
      variable private
      global audace caption

      set err [ catch {
         buf$audace(bufNo) load $in
         #buf$audace(bufNo) stat
         buf$audace(bufNo) save $out
      } ]

      if { $err == "1" } {
         set private(conv2,msg) [ format $caption(pretraitement,echec) $in $::errorInfo ]
      }
      return $err
   }

   #------------------------- fonctions diverses ---------------------------

   #########################################################################
   # Mise a jour des mots-cles : pour les CFA et les RGB                   #
   # la conversion se fait apres modification  des mots-cles               #
   # et sauvegarde de l'image                                              #
   # pour R+G+B il faut charger, modifier et sauver les trois images       #
   #########################################################################
   proc MajHeader { file } {
      global audace

      if ![ info exists ::conv2::maj_header ] {
         set ::conv2::maj_header ""
      }

      #--- teste si l'image est dans la liste des fichiers contenant un ancien mot cle
      if { [ lsearch -regexp $::conv2::maj_header $file ] != "-1" } {

         set old_kwds [ list RAW_COLORS RAW_FILTER RAW_BLACK RAW_MAXIMUM ]
         set new_kwds [ list RAWCOLOR RAWFILTE RAWBLACK RAWMAXI ]
         set mot_vide "{} {} {none} {} {}"

         foreach old $old_kwds new $new_kwds {

            #--- copie l'ancien mot cle
            set data [ buf$audace(bufNo) getkwd $old ]

            if { $data != $mot_vide } {

               #--- remplace l'ancien mot par le nouveau
               set data [ lreplace $data 0 0 "$new" ]

               #--- ecrit le nouveau mot-cle
               buf$audace(bufNo) setkwd $data

               #--- detruit l'ancien mot-cle
               buf$audace(bufNo) delkwd $old

               #--- sauve l'image modifiee
               buf$audace(bufNo) save $file
            }
         }
      }
   }

   #########################################################################
   # Gere l'image affichee dans la colonne REM                             #
   #########################################################################
   proc Avancement { img j } {
      variable private

      $private(conv2,tbl) cellconfigure $j,done -image $private(conv2,$img)
   }

   #########################################################################
   # Active/desactive les commandes                                        #
   #########################################################################
   proc WindowActive { etat } {
      variable private
      global caption

      set this $private(conv2,This)

      #--   le bouton 'Appliquer' et le message
      if { $etat == "disabled" } {
         $this.labURLmsg configure -text $caption(pretraitement,en_cours)
         $this.cmd.appliquer configure -relief sunken
      } else {
         #--- actualise le message concernant le nombre de selection
         $this.labURLmsg configure -text $caption(pretraitement,fin_traitement)
         $this.cmd.appliquer configure -relief raised
      }

      #--   les autres commandes
      set frames { but chg generique renum all cmd.ok cmd.appliquer cmd.aide cmd.fermer }
      #--   ne propose pas la destruction pour ces fonctions
      set filtres [list "raw2fits" "assigner_r" "assigner_g" "assigner_b"]
      if { $private(conv2,conversion) ni $filtres } {

         lappend frames "destroy_src"
      }
      foreach frame $frames { $this.$frame configure -state $etat }

      #---  tous les checkbuttons des series
      for { set i 0 } { $i < $private(conv2,nb) } { incr i } {
         set w [ $private(conv2,tbl) windowpath $i,0 ]
         $w configure -state $etat
      }
      update
   }

   #########################################################################
   # Gere la fenetre lors de la selection d'une conversion                 #
   #########################################################################
   proc WindowConfigure { op } {
      variable private
      global caption

      #--- dimensionne la largeur des colonnes
      foreach col {0 1 2 3 4 } wi [ list 3 0 3 0 4 ] {
         $private(conv2,tbl) columnconfigure $col -width $wi
      }

      set this $private(conv2,This)
      #--- actualise le message
      if { $private(conv2,nb) != "0" } {
         $this.labURLmsg configure -text "$caption(pretraitement,nb_select) 0/[ $private(conv2,tbl) size ]"
      } else {
         $this.labURLmsg configure -text "$caption(pretraitement,nb_select) 0/$private(conv2,nb)"
      }

      #--- decoche toutes les options
      foreach child { all renum chg destroy_src } {$this.$child deselect}

      #--- affiche le texte generique
      set filtres [list "raw2fits" "assigner_r" "assigner_g" "assigner_b"]
      if { $op in $filtres } {
         $this.chg toggle
         set private(conv2,new_name) $private(conv2,$op,generique)
         $this.generique configure -state normal
      } else {
         set private(conv2,new_name) ""
         $this.generique configure -state disabled
      }

      #--- interdit ces widgets s'il n'y a pas de fichiers a convertir
      if { $private(conv2,$op,no_file) == [ list $::caption(pretraitement,no_file) ] } {
         set state disabled
      } else {
         set state normal
      }
      $this.all configure -state $state
      $this.renum configure -state $state
      $this.chg configure -state $state
      $this.generique configure -state $state
      if { $op ni $filtres} {$this.destroy_src configure -state $state}

      #--- interdit la destruction des sources raw ou en cas d'assignation des plans
      if { $op in $filtres } {  set state disabled }
      $this.destroy_src configure -state $state
   }

   #########################################################################
   # Met a jour la fenetre lors de la selection d'un fichier               #
   #########################################################################
   proc WindowUpdate { } {
      variable private
      global caption

      set l [ llength $private(conv2,in) ]
      #--- actualise la case a cocher de l'option 'Tout convertir'
      if { $private(conv2,nb) == $l } {
         $private(conv2,This).all select
      } else {
         $private(conv2,This).all deselect
      }

      #--- actualise le message concernant le nombre de selections
      set affiche "$caption(pretraitement,nb_select) $l/$private(conv2,nb)"
      $private(conv2,This).labURLmsg configure -text $affiche
   }

   #########################################################################
   # Configure le menu en fonction des listes                              #
   #########################################################################
   proc MenuUpdate { } {
      variable private

      #--- modifie les commandes liees au menu
      foreach op $private(conv2,operations) {
         set k [ lsearch -exact $private(conv2,operations) $op ]
         incr k
         $private(conv2,This).but.menu entryconfigure $k \
            -state $private(conv2,$op,state) \
            -command [ list ::conv2::Select $op ]
      }
   }

   #########################################################################
   # Selectionne/deselectionne tous les checkbuttons de la tablelist       #
   #########################################################################
   proc SelectAll { } {
      variable private

      set cmd "deselect"
      if { $::conv2::private(conv2,all) == 1 } { set cmd "select" }
      for { set i 0 } { $i < $private(conv2,nb) } { incr i } {
         set w [ $private(conv2,tbl) windowpath $i,0 ]
         $w $cmd
      }
      ::conv2::UpdateDialog
   }

   #########################################################################
   # Elimine les caracteres non autorises dans le nom                      #
   #########################################################################
   proc EntryCtrl { } {
      variable private

      regsub -all {[^\w\-_]} $private(conv2,new_name) {} private(conv2,new_name)
      ::conv2::UpdateDialog
   }


   #########################################################################
   # Affiche une fenetre d'erreur                                          #
   # parametre : contenu du message a afficher                             #
   #########################################################################
   proc Error { msg } {
      global caption

      tk_messageBox -title $caption(pretraitement,attention)\
         -icon error -type ok -message $msg
   }

   #########################################################################
   # Cree un checkbutton pour inserer dans une tablelist                   #
   # parametres : index de la ligne de la tablelist                        #
   # tbl row col et w sont completes automatiquement                       #
   #########################################################################
   proc CreateCheckButton { index tbl row col w } {
      variable private

      checkbutton $w -height 1 -indicatoron 1 -onvalue "1" -offvalue "0" \
         -variable ::conv2::private(conv2,file_$index) \
         -command "::conv2::UpdateDialog"
      $w deselect
   }

   #########################################################################
   # Cree un checkbutton normal                                            #
   # parametres : fenetre parent, variable associee                        #
   #########################################################################
   proc CheckButton { f var } {
      variable private
      global caption

      checkbutton $f.$var -indicatoron 1 -onvalue "1" -offvalue "0" \
         -text "$caption(pretraitement,$var)" \
         -variable ::conv2::private(conv2,$var) \
         -command "::conv2::UpdateDialog"
      $f.$var deselect
   }

   #########################################################################
   # Fermeture de le fenetre et destruction du namespace                   #
   #########################################################################
   proc Fermer { } {
      variable private
      variable bdd

      ::conv2::recupPosition
      catch {
         unset bdd
         destroy $private(conv2,This)
      }
      unset private
   }

   #--------------------------------------------------------------------------
   #  ::conv2::CONVERSIONFunctions {0|nom_de_fonction}
   #  Cree le dictionnaire des fonctions de conversion
   #  Retourne la liste des fonctions ou les parametres d'une fonction
   #--------------------------------------------------------------------------
   proc CONVERSIONFunctions {function} {
      variable CONVERSION
      global caption help

      #--- definit le nom generique propose pour le fichier de sortie des RAW
      set dir "[ file tail [ file rootname "$::audace(rep_images)" ] ]_"

      #--- remplace les caracteres
      regsub -all {[^\w_-]} $dir {} dir

      dict set CONVERSION "$caption(audace,menu,raw2fits)"     fun "raw2fits"
      dict set CONVERSION "$caption(audace,menu,raw2fits)"     gen "$dir"
      dict set CONVERSION "$caption(audace,menu,cfa2rvb)"      fun "cfa2rgb"
      dict set CONVERSION "$caption(audace,menu,cfa2rvb)"      gen "rgb_"
      dict set CONVERSION "$caption(audace,menu,rvb2r+v+b)"    fun "rgb2r+g+b"
      dict set CONVERSION "$caption(audace,menu,rvb2r+v+b)"    gen "plan_"
      dict set CONVERSION "$caption(audace,menu,r+v+b2rvb)"    fun "r+g+b2rgb"
      dict set CONVERSION "$caption(audace,menu,r+v+b2rvb)"    gen "img3d_"
      dict set CONVERSION "$caption(audace,menu,assigner_r)"   fun "assigner_r"
      dict set CONVERSION "$caption(audace,menu,assigner_r)"   gen "plan_"
      dict set CONVERSION "$caption(audace,menu,assigner_g)"   fun "assigner_g"
      dict set CONVERSION "$caption(audace,menu,assigner_g)"   gen "plan_"
      dict set CONVERSION "$caption(audace,menu,assigner_b)"   fun "assigner_b"
      dict set CONVERSION "$caption(audace,menu,assigner_b)"   gen "plan_"

      if {$function ne "0"} {
         foreach key {fun hlp gen} {
            lappend result "[dict get $CONVERSION $function $key]"
         }
      } else {
         set result "[dict keys $CONVERSION]"
      }
      return $result
   }

}

############################# Fin du namespace conv2 #############################[

namespace eval ::traiteWindow {

   #
   # ::traiteWindow::run type_pretraitement this
   # Lance la fenetre de dialogue pour les pretraitements sur une images
   # this : Chemin de la fenetre
   #
   proc run { type_pretraitement this } {
      variable This
      variable widget
      global traiteWindow

      #---
      ::traiteWindow::initConf
      ::traiteWindow::confToWidget
      #---
      set traiteWindow(captionOperation) [ ::traiteWindow::fonctionCaption "$type_pretraitement" ]
      #---
      set This $this
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
      } else {
         if { [ info exists traiteWindow(geometry) ] } {
            set deb [ expr 1 + [ string first + $traiteWindow(geometry) ] ]
            set fin [ string length $traiteWindow(geometry) ]
            set widget(traiteWindow,position) "+[string range $traiteWindow(geometry) $deb $fin]"
         }
         ::traiteWindow::createDialog "$type_pretraitement"
      }
      #---
      set traiteWindow(operation) "$type_pretraitement"
   }

   #
   # ::traiteWindow::initConf
   # Initialisation des variables de configuration
   #
   proc initConf { } {
      global conf

      if { ! [ info exists conf(traiteWindow,position) ] } { set conf(traiteWindow,position) "+350+75" }

      return
   }

   #
   # ::traiteWindow::confToWidget
   # Charge les variables de configuration dans des variables locales
   #
   proc confToWidget { } {
      variable widget
      global conf

      set widget(traiteWindow,position) "$conf(traiteWindow,position)"
   }

   #
   # ::traiteWindow::widgetToConf
   # Charge les variables locales dans des variables de configuration
   #
   proc widgetToConf { } {
      variable widget
      global conf

      set conf(traiteWindow,position) "$widget(traiteWindow,position)"
   }

   #
   # ::traiteWindow::recupPosition
   # Recupere la position de la fenetre
   #
   proc recupPosition { } {
      variable This
      variable widget
      global traiteWindow

      set traiteWindow(geometry) [wm geometry $This]
      set deb [ expr 1 + [ string first + $traiteWindow(geometry) ] ]
      set fin [ string length $traiteWindow(geometry) ]
      set widget(traiteWindow,position) "+[string range $traiteWindow(geometry) $deb $fin]"
      #---
      ::traiteWindow::widgetToConf
   }

   #
   # ::traiteWindow::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { type_pretraitement } {
      variable This
      variable widget
      global audace caption color conf traiteWindow

      #--- Initialisation des variables principales
      set traiteWindow(in)            ""
      set traiteWindow(nb)            ""
      set traiteWindow(valeur_indice) "1"
      set traiteWindow(out)           ""
      set traiteWindow(sup_boite)     "0"
      set traiteWindow(disp)          "1"
      set traiteWindow(avancement)    ""

      #---
      toplevel $This
      wm resizable $This 0 0
      wm deiconify $This
      wm title $This "$caption(audace,menu,preprocess)"
      wm geometry $This $widget(traiteWindow,position)
      wm transient $This $audace(base)
      wm protocol $This WM_DELETE_WINDOW ::traiteWindow::cmdClose

      #---
      frame $This.usr -borderwidth 0 -relief raised

         frame $This.usr.0 -borderwidth 1 -relief raised
            label $This.usr.0.lab1 -textvariable "traiteWindow(formule)"
            pack $This.usr.0.lab1 -padx 10 -pady 5
        # pack $This.usr.0 -in $This.usr -side top -fill both

         frame $This.usr.4 -borderwidth 1 -relief raised
            frame $This.usr.4.1 -borderwidth 0 -relief flat
               label $This.usr.4.1.labURL1 -textvariable "traiteWindow(avancement)" -fg $color(blue)
               pack $This.usr.4.1.labURL1 -side top -padx 10 -pady 5
            pack $This.usr.4.1 -side top -fill both
        # pack $This.usr.4 -in $This.usr -side top -fill both

         frame $This.usr.3 -borderwidth 1 -relief raised
            frame $This.usr.3.1 -borderwidth 0 -relief flat
               checkbutton $This.usr.3.1.che1 -text "$caption(pretraitement,afficher_image_fin)" \
                  -variable traiteWindow(disp)
               pack $This.usr.3.1.che1 -side left -padx 10 -pady 5
            pack $This.usr.3.1 -side top -fill both
        # pack $This.usr.3 -in $This.usr -side top -fill both

         frame $This.usr.3a -borderwidth 1 -relief raised
            frame $This.usr.3a.1 -borderwidth 0 -relief flat
               checkbutton $This.usr.3a.1.che1 -text "$caption(pretraitement,afficher_der_image_fin)" \
                  -variable traiteWindow(disp)
               pack $This.usr.3a.1.che1 -side left -padx 10 -pady 5
            pack $This.usr.3a.1 -side top -fill both
        # pack $This.usr.3a -in $This.usr -side top -fill both

         frame $This.usr.2 -borderwidth 1 -relief raised
            frame $This.usr.2.1 -borderwidth 0 -relief flat
               label $This.usr.2.1.lab1 -textvariable "traiteWindow(image_A)"
               pack $This.usr.2.1.lab1 -side left -padx 5 -pady 5
               entry $This.usr.2.1.ent1 -textvariable traiteWindow(in)
               pack $This.usr.2.1.ent1 -side left -padx 10 -pady 5 -fill x -expand 1
               button $This.usr.2.1.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::traiteWindow::parcourir 1 }
               pack $This.usr.2.1.explore -side left -padx 10 -pady 5 -ipady 5
            pack $This.usr.2.1 -side top -fill both
            frame $This.usr.2.2 -borderwidth 0 -relief flat
               label $This.usr.2.2.lab2 -textvariable "traiteWindow(nombre)" -width 20
               pack $This.usr.2.2.lab2 -side left -padx 5 -pady 5
               entry $This.usr.2.2.ent2 -textvariable traiteWindow(nb) -width 7 -justify center
               pack $This.usr.2.2.ent2 -side left -padx 10 -pady 5
            pack $This.usr.2.2 -side top -fill both
            frame $This.usr.2.3 -borderwidth 0 -relief flat
               label $This.usr.2.3.lab3 -textvariable "traiteWindow(premier_indice)" -width 20
               pack $This.usr.2.3.lab3 -side left -padx 5 -pady 5
               entry $This.usr.2.3.ent3 -textvariable traiteWindow(valeur_indice) -width 7 -justify center
               pack $This.usr.2.3.ent3 -side left -padx 10 -pady 5
            pack $This.usr.2.3 -side top -fill both
            frame $This.usr.2.4 -borderwidth 0 -relief flat
               label $This.usr.2.4.lab4 -textvariable "traiteWindow(image_B)"
               pack $This.usr.2.4.lab4 -side left -padx 5 -pady 5
               entry $This.usr.2.4.ent4 -textvariable traiteWindow(out)
               pack $This.usr.2.4.ent4 -side left -padx 10 -pady 5 -fill x -expand 1
               button $This.usr.2.4.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::traiteWindow::parcourir 2 }
               pack $This.usr.2.4.explore -side left -padx 10 -pady 5 -ipady 5
            pack $This.usr.2.4 -side top -fill both
        # pack $This.usr.2 -in $This.usr -side top -fill both

         frame $This.usr.2a -borderwidth 1 -relief raised
            checkbutton $This.usr.2a.che1 -text "$caption(pretraitement,sup_boite)" \
               -variable traiteWindow(sup_boite)
            pack $This.usr.2a.che1 -side left -padx 10 -pady 5
        # pack $This.usr.2a -side top -fill both

         frame $This.usr.1 -borderwidth 1 -relief raised
            label $This.usr.1.lab1 -text "$caption(pretraitement,operation_serie)"
            pack $This.usr.1.lab1 -side left -padx 10 -pady 5
            #--- Liste des pretraitements disponibles
            set list_traiteWindow [ list $caption(audace,menu,mediane) $caption(audace,menu,somme) \
               $caption(audace,menu,moyenne) $caption(audace,menu,ecart_type) $caption(audace,menu,recentrer) ]
            #---
            menubutton $This.usr.1.but1 -textvariable traiteWindow(captionOperation) -menu $This.usr.1.but1.menu \
               -relief raised
            pack $This.usr.1.but1 -side right -padx 10 -pady 5 -ipady 5
            set m [menu $This.usr.1.but1.menu -tearoff 0]
            foreach pretrait $list_traiteWindow {
               $m add radiobutton -label "$pretrait" \
                -indicatoron "1" \
                -value "$pretrait" \
                -variable traiteWindow(captionOperation) \
                -command { ::traiteWindow::captionFonction $traiteWindow(captionOperation) }
            }
        # pack $This.usr.1 -in $This.usr -side top -fill both

      pack $This.usr -side top -fill both -expand 1

      #---
      frame $This.cmd -borderwidth 1 -relief raised

         button $This.cmd.ok -text "$caption(aud_menu_3,ok)" -width 7 \
            -command { ::traiteWindow::cmdOk }
         if { $conf(ok+appliquer)=="1" } {
            pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }

         button $This.cmd.appliquer -text "$caption(aud_menu_3,appliquer)" -width 8 \
            -command { ::traiteWindow::cmdApply }
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x

         button $This.cmd.fermer -text "$caption(aud_menu_3,fermer)" -width 7 \
            -command { ::traiteWindow::cmdClose }
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x

         button $This.cmd.aide -text "$caption(aud_menu_3,aide)" -width 7 \
            -command { ::traiteWindow::afficheAide }
         pack $This.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x

      pack $This.cmd -side top -fill x

      #---
      uplevel #0 trace variable traiteWindow(operation) w ::traiteWindow::change

      #---
      bind $This <Key-Return> {::traiteWindow::cmdOk}
      bind $This <Key-Escape> {::traiteWindow::cmdClose}

      #--- Focus
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # ::traiteWindow::fonctionCaption
   # Procedure qui associe a une fonction un caption
   #
   proc fonctionCaption { type_pretraitement } {
      global caption traiteWindow

      #---
      if { $type_pretraitement == "serie_mediane" } {
         #set traiteWindow(captionOperation) "$caption(audace,menu,mediane)"
      } elseif { $type_pretraitement == "serie_somme" } {
         #set traiteWindow(captionOperation) "$caption(audace,menu,somme)"
      } elseif { $type_pretraitement == "serie_moyenne" } {
         #set traiteWindow(captionOperation) "$caption(audace,menu,moyenne)"
      } elseif { $type_pretraitement == "serie_ecart_type" } {
         #set traiteWindow(captionOperation) "$caption(audace,menu,ecart_type)"
      } elseif { $type_pretraitement == "serie_recentrer" } {
         set traiteWindow(captionOperation) "$caption(audace,menu,recentrer)"
      }
   }

   #
   # ::traiteWindow::captionFonction
   # Procedure qui associe a un caption une fonction
   #
   proc captionFonction { type_pretraitement } {
      global caption traiteWindow

      #---
      if { $type_pretraitement == "$caption(audace,menu,mediane)" } {
         #set traiteWindow(operation) "serie_mediane"
      } elseif { $type_pretraitement == "$caption(audace,menu,somme)" } {
         #set traiteWindow(operation) "serie_somme"
      } elseif { $type_pretraitement == "$caption(audace,menu,moyenne)" } {
         #set traiteWindow(operation) "serie_moyenne"
      } elseif { $type_pretraitement == "$caption(audace,menu,ecart_type)" } {
         #set traiteWindow(operation) "serie_ecart_type"
      } elseif { $type_pretraitement == "$caption(audace,menu,recentrer)" } {
         set traiteWindow(operation) "serie_recentrer"
      }
   }

   #
   # ::traiteWindow::cmdOk
   # Procedure correspondant a l'appui sur le bouton OK
   #
   proc cmdOk { } {
      if { [ ::traiteWindow::cmdApply ] == "0" } { return }
      ::traiteWindow::cmdClose
   }

   #
   # ::traiteWindow::cmdApply
   # Procedure correspondant a l'appui sur le bouton Appliquer
   #
   proc cmdApply { } {
      variable This
      global audace caption traiteWindow

      #---
      set traiteWindow(avancement) "$caption(pretraitement,en_cours)"
      update
      #---

      set in    $traiteWindow(in)
      set nb    $traiteWindow(nb)
      set first $traiteWindow(valeur_indice)
      set out   $traiteWindow(out)

      #--- Tests sur les images d'entree, le nombre d'images et les images de sortie
      if { $traiteWindow(in) == "" } {
         tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
            -message "$caption(pretraitement,definir_entree_generique)"
         set traiteWindow(avancement) ""
         return 0
      }
      if { $traiteWindow(nb) == "" } {
         tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
            -message "$caption(pretraitement,choix_nbre_images)"
         set traiteWindow(avancement) ""
         return 0
      }
      if { [ TestEntier $traiteWindow(nb) ] == "0" } {
         tk_messageBox -title "$caption(pretraitement,attention)" -icon error \
           -message "$caption(pretraitement,nbre_entier)"
         set traiteWindow(avancement) ""
         return 0
      }
      if { $traiteWindow(valeur_indice) == "" } {
         tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
            -message "$caption(pretraitement,choix_premier_indice)"
         set traiteWindow(avancement) ""
         return 0
      }
      if { [ TestEntier $traiteWindow(valeur_indice) ] == "0" } {
         tk_messageBox -title "$caption(pretraitement,attention)" -icon error \
            -message "$caption(pretraitement,nbre_entier1)"
         set traiteWindow(avancement) ""
         return 0
      }
      if { $traiteWindow(out) == "" } {
         if { $traiteWindow(operation) != "serie_recentrer" } {
            tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
               -message "$caption(pretraitement,definir_image_sortie)"
         } else {
            tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
               -message "$caption(pretraitement,definir_sortie_generique)"
         }
         set traiteWindow(avancement) ""
         return 0
     }
      #--- Calcul du dernier indice de la serie
      set end [ expr $nb + ( $first - 1 ) ]

      #--- Switch
      switch $traiteWindow(operation) {
         "serie_mediane" {
            set catchError [ catch {
               ::console::affiche_resultat "Usage: smedian in out number ?first_index? ?tt_options?\n\n"
               smedian $in $out $nb $first
               if { $traiteWindow(disp) == 1 } {
                  loadima $out
               }
               set traiteWindow(avancement) "$caption(pretraitement,fin_traitement)"
            } m ]
            if { $catchError == "1" } {
               tk_messageBox -title "$caption(pretraitement,attention)" -icon error -message "$m"
               set traiteWindow(avancement) ""
            }
         }
         "serie_somme" {
            set catchError [ catch {
               ::console::affiche_resultat "Usage: sadd in out number ?first_index? ?tt_options?\n\n"
               sadd $in $out $nb $first
               if { $traiteWindow(disp) == 1 } {
                  loadima $out
               }
               set traiteWindow(avancement) "$caption(pretraitement,fin_traitement)"
            } m ]
            if { $catchError == "1" } {
               tk_messageBox -title "$caption(pretraitement,attention)" -icon error -message "$m"
               set traiteWindow(avancement) ""
            }
         }
         "serie_moyenne" {
            set catchError [ catch {
               ::console::affiche_resultat "Usage: smean in out number ?first_index? ?tt_options?\n\n"
               smean $in $out $nb $first
               if { $traiteWindow(disp) == 1 } {
                  loadima $out
               }
               set traiteWindow(avancement) "$caption(pretraitement,fin_traitement)"
            } m ]
            if { $catchError == "1" } {
               tk_messageBox -title "$caption(pretraitement,attention)" -icon error -message "$m"
               set traiteWindow(avancement) ""
            }
         }
         "serie_ecart_type" {
            set catchError [ catch {
               ::console::affiche_resultat "Usage: ssigma in out number ?first_index? bitpix=-32\n\n"
               ssigma $in $out $nb $first "bitpix=-32"
               if { $traiteWindow(disp) == 1 } {
                  loadima $out
               }
               set traiteWindow(avancement) "$caption(pretraitement,fin_traitement)"
            } m ]
            if { $catchError == "1" } {
               tk_messageBox -title "$caption(pretraitement,attention)" -icon error -message "$m"
               set traiteWindow(avancement) ""
            }
         }
         "serie_recentrer" {
            set catchError [ catch {
               ::console::affiche_resultat "Usage: registerbox in out number ?visuNo? ?first_index? ?tt_options?\n\n"
               #--- Un cadre trace avec la souris n'existe pas
               if { [ lindex [ list [ ::confVisu::getBox $audace(visuNo) ] ] 0 ] == "" } {
                  set coordWindow ""
                  loadima $in$first
                  tk_messageBox -title $caption(confVisu,attention) -type ok \
                     -message "$caption(pretraitement,tracer_boite)\n$caption(pretraitement,appuyer_ok)"
               }
               set coordWindow [ list [ ::confVisu::getBox $audace(visuNo) ] ]
               registerbox $in $out $nb $audace(visuNo) $first
               if { $traiteWindow(disp) == 1 } {
                  loadima $out$end
               }
               if { $traiteWindow(sup_boite) == 1 } {
                  ::confVisu::deleteBox $audace(visuNo)
               }
               set traiteWindow(avancement) "$caption(pretraitement,fin_traitement)"
            } m ]
            if { $catchError == "1" } {
               tk_messageBox -title "$caption(pretraitement,attention)" -icon error -message "$m"
               set traiteWindow(avancement) ""
            }
         }
      }
      ::traiteWindow::recupPosition
   }

   #
   # ::traiteWindow::cmdClose
   # Procedure correspondant a l'appui sur le bouton Fermer
   #
   proc cmdClose { } {
      variable This

      ::traiteWindow::recupPosition
      destroy $This
      unset This
   }

   #
   # ::traiteWindow::afficheAide
   # Procedure correspondant a l'appui sur le bouton Aide
   #
   proc afficheAide { } {
      global help traiteWindow

      #---
      if { $traiteWindow(operation) == "serie_mediane" } {
         set traiteWindow(page_web) "1150serie_mediane"
      } elseif { $traiteWindow(operation) == "serie_somme" } {
         set traiteWindow(page_web) "1160serie_somme"
      } elseif { $traiteWindow(operation) == "serie_moyenne" } {
         set traiteWindow(page_web) "1170serie_moyenne"
      } elseif { $traiteWindow(operation) == "serie_ecart_type" } {
         set traiteWindow(page_web) "1180serie_ecart_type"
      } elseif { $traiteWindow(operation) == "serie_recentrer" } {
         set traiteWindow(page_web) "1190serie_recentrer"
      }

      #---
      ::audace::showHelpItem "$help(dir,pretrait)" "$traiteWindow(page_web).htm"
   }

   #
   # ::traiteWindow::change n1 n2 op
   # Adapte l'interface graphique en fonction du choix
   #
   proc change { n1 n2 op } {
      variable This
      global traiteWindow

      #---
      set traiteWindow(avancement)    ""
      set traiteWindow(in)            ""
      set traiteWindow(nb)            ""
      set traiteWindow(valeur_indice) "1"
      set traiteWindow(out)           ""
      #---
      ::traiteWindow::formule
      #---
      switch $traiteWindow(operation) {
         "serie_mediane" {
            pack forget $This.usr.0
            pack $This.usr.4 -in $This.usr -side bottom -fill both
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.2a
            pack $This.usr.3 -in $This.usr -side top -fill both
            pack forget $This.usr.3a
         }
         "serie_somme" {
            pack $This.usr.0 -in $This.usr -side top -fill both
            pack $This.usr.4 -in $This.usr -side bottom -fill both
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.2a
            pack $This.usr.3 -in $This.usr -side top -fill both
            pack forget $This.usr.3a
         }
         "serie_moyenne" {
            pack $This.usr.0 -in $This.usr -side top -fill both
            pack $This.usr.4 -in $This.usr -side bottom -fill both
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.2a
            pack $This.usr.3 -in $This.usr -side top -fill both
            pack forget $This.usr.3a
         }
         "serie_ecart_type" {
            pack forget $This.usr.0
            pack $This.usr.4 -in $This.usr -side bottom -fill both
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.2a
            pack $This.usr.3 -in $This.usr -side top -fill both
            pack forget $This.usr.3a
         }
         "serie_recentrer" {
            pack forget $This.usr.0
            pack $This.usr.4 -in $This.usr -side bottom -fill both
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack $This.usr.2a -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack $This.usr.3a -in $This.usr -side top -fill both
         }
      }
   }

   #
   # ::traiteWindow::parcourir In_Out
   # Ouvre un explorateur pour choisir un fichier
   #
   proc parcourir { In_Out } {
      global audace caption traiteWindow

      #--- Fenetre parent
      set fenetre "$audace(base).traiteWindow"
      #--- Ouvre la fenetre de choix des images
      set filename [ ::tkutil::box_load $fenetre $audace(rep_images) $audace(bufNo) "1" ]
      #--- Le fichier selectionne doit imperativement etre dans le repertoire des images
      if { [ file dirname $filename ] != $audace(rep_images) } {
         tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
            -message "$caption(pretraitement,rep-images)"
         return
      }
      #--- Extraction du nom du fichier
      if { $In_Out == "1" } {
         set traiteWindow(info_filename_in) [ ::pretraitement::afficherNomGenerique [ file tail $filename ] ]
         set traiteWindow(in)               [ lindex $traiteWindow(info_filename_in) 0 ]
         set traiteWindow(nb)               [ lindex $traiteWindow(info_filename_in) 1 ]
         set traiteWindow(valeur_indice)    [ lindex $traiteWindow(info_filename_in) 2 ]
      } elseif { $In_Out == "2" } {
         if { $traiteWindow(operation) == "serie_recentrer" } {
            set traiteWindow(info_filename_out) [ ::pretraitement::afficherNomGenerique [ file tail $filename ] ]
            set traiteWindow(out)               [ lindex $traiteWindow(info_filename_out) 0 ]
         } else {
            set traiteWindow(out)               [ file rootname [ file tail $filename ] ]
         }
      }
   }

   #
   # ::traiteWindow::formule
   # Affiche les formules
   #
   proc formule { } {
      global caption traiteWindow

      if { $traiteWindow(operation) == "serie_somme" } {
         set traiteWindow(image_A)        "$caption(pretraitement,image_generique_entree-) ( A ) :"
         set traiteWindow(nombre)         "$caption(pretraitement,image_nombre-) ( n ) :"
         set traiteWindow(premier_indice) "$caption(pretraitement,image_premier_indice)"
         set traiteWindow(image_B)        "$caption(pretraitement,image_sortie-) ( B ) :"
         set traiteWindow(formule)        "$caption(pretraitement,formule) B = A1 + A2 + ... + An"
      } elseif { $traiteWindow(operation) == "serie_moyenne" } {
         set traiteWindow(image_A)        "$caption(pretraitement,image_generique_entree-) ( A ) :"
         set traiteWindow(nombre)         "$caption(pretraitement,image_nombre-) ( n ) :"
         set traiteWindow(premier_indice) "$caption(pretraitement,image_premier_indice)"
         set traiteWindow(image_B)        "$caption(pretraitement,image_sortie-) ( B ) :"
         set traiteWindow(formule)        "$caption(pretraitement,formule) B = ( A1 + A2 + ... + An ) / n"
      } elseif { $traiteWindow(operation) == "serie_recentrer" } {
         set traiteWindow(image_A)        "$caption(pretraitement,image_generique_entree)"
         set traiteWindow(nombre)         "$caption(pretraitement,image_nombre)"
         set traiteWindow(premier_indice) "$caption(pretraitement,image_premier_indice)"
         set traiteWindow(image_B)        "$caption(pretraitement,image_generique_sortie)"
         set traiteWindow(formule)        ""
      } else {
         set traiteWindow(image_A)        "$caption(pretraitement,image_generique_entree)"
         set traiteWindow(nombre)         "$caption(pretraitement,image_nombre)"
         set traiteWindow(premier_indice) "$caption(pretraitement,image_premier_indice)"
         set traiteWindow(image_B)        "$caption(pretraitement,image_sortie)"
         set traiteWindow(formule)        ""
      }
   }

}

########################### Fin du namespace traiteWindow ###########################

namespace eval ::faireImageRef {

   #
   # ::faireImageRef::run type_image_reference this
   # Lance la fenetre de dialogue pour les pretraitements sur une images
   # this : Chemin de la fenetre
   #
   proc run { type_image_reference this } {
      variable This
      variable widget
      global faireImageRef

      #---
      ::faireImageRef::initConf
      ::faireImageRef::confToWidget
      #---
      set faireImageRef(captionOperation) [ ::faireImageRef::fonctionCaption "$type_image_reference" ]
      #---
      set This $this
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
      } else {
         if { [ info exists faireImageRef(geometry) ] } {
            set deb [ expr 1 + [ string first + $faireImageRef(geometry) ] ]
            set fin [ string length $faireImageRef(geometry) ]
            set widget(faireImageRef,position) "+[string range $faireImageRef(geometry) $deb $fin]"
         }
         ::faireImageRef::createDialog $type_image_reference
      }
      #---
      set faireImageRef(operation) "$type_image_reference"
   }

   #
   # ::faireImageRef::initConf
   # Initialisation des variables de configuration
   #
   proc initConf { } {
      global conf

      if { ! [ info exists conf(faireImageRef,position) ] } { set conf(faireImageRef,position) "+350+75" }

      return
   }

   #
   # ::faireImageRef::confToWidget
   # Charge les variables de configuration dans des variables locales
   #
   proc confToWidget { } {
      variable widget
      global conf

      set widget(faireImageRef,position) "$conf(faireImageRef,position)"
   }

   #
   # ::faireImageRef::widgetToConf
   # Charge les variables locales dans des variables de configuration
   #
   proc widgetToConf { } {
      variable widget
      global conf

      set conf(faireImageRef,position) "$widget(faireImageRef,position)"
   }

   #
   # ::faireImageRef::recupPosition
   # Recupere la position de la fenetre
   #
   proc recupPosition { } {
      variable This
      variable widget
      global faireImageRef

      set faireImageRef(geometry) [wm geometry $This]
      set deb [ expr 1 + [ string first + $faireImageRef(geometry) ] ]
      set fin [ string length $faireImageRef(geometry) ]
      set widget(faireImageRef,position) "+[string range $faireImageRef(geometry) $deb $fin]"
      #---
      ::faireImageRef::widgetToConf
   }

   #
   # ::faireImageRef::createDialog
   # Creation de l'interface graphique
   #
   proc createDialog { type_image_reference } {
      variable This
      variable widget
      global audace caption color conf faireImageRef

      #--- Initialisation des variables principales
      set faireImageRef(in)                          ""
      set faireImageRef(nb)                          ""
      set faireImageRef(valeur_indice)               "1"
      set faireImageRef(out)                         ""
      set faireImageRef(offset)                      ""
      set faireImageRef(dark)                        ""
      set faireImageRef(opt)                         "0"
      set faireImageRef(flat-field)                  ""
      set faireImageRef(methode)                     "2"
      set faireImageRef(norm)                        ""
      set faireImageRef(disp)                        "1"
      set faireImageRef(afficher_image)              "$caption(pretraitement,afficher_image_fin)"
      set faireImageRef(avancement)                  ""
      set faireImageRef(dark,no-offset)              "0"
      set faireImageRef(flat-field,no-offset)        "0"
      set faireImageRef(flat-field,no-dark)          "0"
      set faireImageRef(pretraitement,no-offset)     "0"
      set faireImageRef(pretraitement,no-dark)       "0"
      set faireImageRef(pretraitement,no-flat-field) "0"
      set faireImageRef(pretraitement,norm-auto)     "0"

      #--- Toutes les images (offset, dark et flat) sont diponibles
      set faireImageRef(option)                      "000"

      #---
      toplevel $This
      wm resizable $This 0 0
      wm deiconify $This
      wm title $This "$caption(audace,menu,preprocess) - $caption(audace,menu,faire_image)"
      wm geometry $This $widget(faireImageRef,position)
      wm transient $This $audace(base)
      wm protocol $This WM_DELETE_WINDOW ::faireImageRef::cmdClose

      #---
      frame $This.usr -borderwidth 0 -relief raised

         frame $This.usr.8 -borderwidth 1 -relief raised
            frame $This.usr.8.1 -borderwidth 0 -relief flat
               label $This.usr.8.1.labURL1 -textvariable "faireImageRef(avancement)" \
                  -fg $color(blue)
               pack $This.usr.8.1.labURL1 -side top -padx 10 -pady 5
            pack $This.usr.8.1 -side top -fill both
        # pack $This.usr.8 -side bottom -fill both

         frame $This.usr.7 -borderwidth 1 -relief raised
            frame $This.usr.7.1 -borderwidth 0 -relief flat
               checkbutton $This.usr.7.1.che1 -text "$caption(pretraitement,aucune)" \
                  -variable faireImageRef(pretraitement,no-offset) -command { ::faireImageRef::griserActiver_1 }
               pack $This.usr.7.1.che1 -side left -padx 10 -pady 5
               label $This.usr.7.1.lab6 -text "$caption(pretraitement,image_offset)"
               pack $This.usr.7.1.lab6 -side left -padx 5 -pady 5
               entry $This.usr.7.1.ent6 -textvariable faireImageRef(offset)
               pack $This.usr.7.1.ent6 -side left -padx 10 -pady 5 -fill x -expand 1
               button $This.usr.7.1.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::faireImageRef::parcourir 3 }
               pack $This.usr.7.1.explore -side right -padx 10 -pady 5 -ipady 5
            pack $This.usr.7.1 -side top -fill both
            frame $This.usr.7.2 -borderwidth 0 -relief flat
               checkbutton $This.usr.7.2.che1 -text "$caption(pretraitement,aucune)" \
                  -variable faireImageRef(pretraitement,no-dark) -command { ::faireImageRef::griserActiver_2 }
               pack $This.usr.7.2.che1 -side left -padx 10 -pady 5
               label $This.usr.7.2.lab6 -text "$caption(pretraitement,image_dark)"
               pack $This.usr.7.2.lab6 -side left -padx 5 -pady 5
               entry $This.usr.7.2.ent6 -textvariable faireImageRef(dark)
               pack $This.usr.7.2.ent6 -side left -padx 10 -pady 5 -fill x -expand 1
               button $This.usr.7.2.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::faireImageRef::parcourir 4 }
               pack $This.usr.7.2.explore -side right -padx 10 -pady 5 -ipady 5
            pack $This.usr.7.2 -side top -fill both
            frame $This.usr.7.3 -borderwidth 0 -relief flat
               checkbutton $This.usr.7.3.opt -text "$caption(audace,menu,opt_noir)" -variable faireImageRef(opt)
               pack $This.usr.7.3.opt -side right -padx 80 -pady 5
            pack $This.usr.7.3 -side top -fill both
            frame $This.usr.7.4 -borderwidth 0 -relief flat
               checkbutton $This.usr.7.4.che1 -text "$caption(pretraitement,aucune)" \
                  -variable faireImageRef(pretraitement,no-flat-field) -command { ::faireImageRef::griserActiver_3 }
               pack $This.usr.7.4.che1 -side left -padx 10 -pady 5
               label $This.usr.7.4.lab6 -text "$caption(pretraitement,image_flat-field)"
               pack $This.usr.7.4.lab6 -side left -padx 5 -pady 5
               entry $This.usr.7.4.ent6 -textvariable faireImageRef(flat-field)
               pack $This.usr.7.4.ent6 -side left -padx 10 -pady 5 -fill x -expand 1
               button $This.usr.7.4.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::faireImageRef::parcourir 5 }
               pack $This.usr.7.4.explore -side right -padx 10 -pady 5 -ipady 5
            pack $This.usr.7.4 -side top -fill both
            frame $This.usr.7.6 -borderwidth 0 -relief flat
               checkbutton $This.usr.7.6.che1 -text "$caption(pretraitement,auto)" \
                  -variable faireImageRef(pretraitement,norm-auto) -command { ::faireImageRef::griserActiver_4 }
               pack $This.usr.7.6.che1 -side left -padx 10 -pady 5
               label $This.usr.7.6.lab6 -textvariable "faireImageRef(normalisation)"
               pack $This.usr.7.6.lab6 -side left -padx 5 -pady 5
               entry $This.usr.7.6.ent6 -textvariable faireImageRef(norm) -width 10 -justify center
               pack $This.usr.7.6.ent6 -side left -padx 10 -pady 5
            pack $This.usr.7.6 -side top -fill both
        # pack $This.usr.7 -side top -fill both

         frame $This.usr.6 -borderwidth 1 -relief raised
            frame $This.usr.6.1 -borderwidth 0 -relief flat
               checkbutton $This.usr.6.1.che1 -text "$faireImageRef(afficher_image)" \
                  -variable faireImageRef(disp)
               pack $This.usr.6.1.che1 -side left -padx 10 -pady 5
            pack $This.usr.6.1 -side top -fill both
        # pack $This.usr.6 -side top -fill both

         frame $This.usr.5 -borderwidth 1 -relief raised
            frame $This.usr.5.1 -borderwidth 0 -relief flat
               label $This.usr.5.1.lab9 -text "$caption(pretraitement,methode)"
               pack $This.usr.5.1.lab9 -side left -padx 10 -pady 5
               radiobutton $This.usr.5.1.rad0 -highlightthickness 0 -padx 0 -pady 0 -state normal \
                  -text "$caption(audace,menu,somme)" -value 0 -variable faireImageRef(methode)
               pack $This.usr.5.1.rad0 -side left -padx 10 -pady 5
               radiobutton $This.usr.5.1.rad1 -highlightthickness 0 -padx 0 -pady 0 -state normal \
                  -text "$caption(audace,menu,moyenne)" -value 1 -variable faireImageRef(methode)
               pack $This.usr.5.1.rad1 -side left -padx 10 -pady 5
               radiobutton $This.usr.5.1.rad2 -highlightthickness 0 -padx 0 -pady 0 -state normal \
                  -text "$caption(audace,menu,mediane)" -value 2 -variable faireImageRef(methode)
               pack $This.usr.5.1.rad2 -side left -padx 10 -pady 5
            pack $This.usr.5.1 -side top -fill both
        # pack $This.usr.5 -side top -fill both

         frame $This.usr.4 -borderwidth 1 -relief raised
            frame $This.usr.4.1 -borderwidth 0 -relief flat
               checkbutton $This.usr.4.1.che1 -text "$caption(pretraitement,aucune)" \
                  -variable faireImageRef(flat-field,no-offset) \
                  -command { ::faireImageRef::griserActiver_5 }
               pack $This.usr.4.1.che1 -side left -padx 10 -pady 5
               label $This.usr.4.1.lab6 -text "$caption(pretraitement,image_offset)"
               pack $This.usr.4.1.lab6 -side left -padx 5 -pady 5
               entry $This.usr.4.1.ent6 -textvariable faireImageRef(offset)
               pack $This.usr.4.1.ent6 -side left -padx 10 -pady 5 -fill x -expand 1
               button $This.usr.4.1.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::faireImageRef::parcourir 3 }
               pack $This.usr.4.1.explore -side left -padx 10 -pady 5 -ipady 5
            pack $This.usr.4.1 -side top -fill both

            frame $This.usr.4.2 -borderwidth 0 -relief flat
               checkbutton $This.usr.4.2.che1 -text "$caption(pretraitement,aucune)" \
                  -variable faireImageRef(flat-field,no-dark) \
                  -command { ::faireImageRef::griserActiver_6 }
               pack $This.usr.4.2.che1 -side left -padx 10 -pady 5
               label $This.usr.4.2.lab6 -text "$caption(pretraitement,image_dark)"
               pack $This.usr.4.2.lab6 -side left -padx 5 -pady 5
               entry $This.usr.4.2.ent6 -textvariable faireImageRef(dark)
               pack $This.usr.4.2.ent6 -side left -padx 10 -pady 5 -fill x -expand 1
               button $This.usr.4.2.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::faireImageRef::parcourir 4 }
               pack $This.usr.4.2.explore -side left -padx 10 -pady 5 -ipady 5
            pack $This.usr.4.2 -side top -fill both

            frame $This.usr.4.3 -borderwidth 0 -relief flat
               entry $This.usr.4.3.ent7 -textvariable faireImageRef(norm) -width 7 -justify center
               pack $This.usr.4.3.ent7 -side right -padx 10 -pady 5
               label $This.usr.4.3.lab7 -textvariable "faireImageRef(normalisation)"
               pack $This.usr.4.3.lab7 -side right -padx 5 -pady 5
            pack $This.usr.4.3 -side top -fill both -padx 60
        # pack $This.usr.4 -side top -fill both

         frame $This.usr.3 -borderwidth 1 -relief raised
            frame $This.usr.3.1 -borderwidth 0 -relief flat
               checkbutton $This.usr.3.1.che1 -text "$caption(pretraitement,aucune)" \
                  -variable faireImageRef(dark,no-offset) -command { ::faireImageRef::griserActiver_8 }
               pack $This.usr.3.1.che1 -side left -padx 10 -pady 5
               label $This.usr.3.1.lab6 -text "$caption(pretraitement,image_offset)"
               pack $This.usr.3.1.lab6 -side left -padx 5 -pady 5
               entry $This.usr.3.1.ent6 -textvariable faireImageRef(offset)
               pack $This.usr.3.1.ent6 -side left -padx 10 -pady 5 -fill x -expand 1
               button $This.usr.3.1.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::faireImageRef::parcourir 3 }
               pack $This.usr.3.1.explore -side left -padx 10 -pady 5 -ipady 5
            pack $This.usr.3.1 -side top -fill both
        # pack $This.usr.3 -side top -fill both

         frame $This.usr.2 -borderwidth 1 -relief raised
            frame $This.usr.2.1 -borderwidth 0 -relief flat
               label $This.usr.2.1.lab1 -textvariable "faireImageRef(image_generique)"
               pack $This.usr.2.1.lab1 -side left -padx 5 -pady 5
               entry $This.usr.2.1.ent1 -textvariable faireImageRef(in)
               pack $This.usr.2.1.ent1 -side left -padx 10 -pady 5 -fill x -expand 1
               button $This.usr.2.1.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::faireImageRef::parcourir 1 }
               pack $This.usr.2.1.explore -side right -padx 10 -pady 5 -ipady 5
            pack $This.usr.2.1 -side top -fill both
            frame $This.usr.2.2 -borderwidth 0 -relief flat
               label $This.usr.2.2.lab2 -textvariable "faireImageRef(nombre)" -width 20
               pack $This.usr.2.2.lab2 -side left -padx 5 -pady 5
               entry $This.usr.2.2.ent2 -textvariable faireImageRef(nb) -width 7 -justify center
               pack $This.usr.2.2.ent2 -side left -padx 10 -pady 5
            pack $This.usr.2.2 -side top -fill both
            frame $This.usr.2.3 -borderwidth 0 -relief flat
               label $This.usr.2.3.lab3 -textvariable "faireImageRef(premier_indice)" -width 20
               pack $This.usr.2.3.lab3 -side left -padx 5 -pady 5
               entry $This.usr.2.3.ent3 -textvariable faireImageRef(valeur_indice) -width 7 -justify center
               pack $This.usr.2.3.ent3 -side left -padx 10 -pady 5
            pack $This.usr.2.3 -side top -fill both
            frame $This.usr.2.4 -borderwidth 0 -relief flat
               label $This.usr.2.4.lab4 -textvariable "faireImageRef(image_sortie)"
               pack $This.usr.2.4.lab4 -side left -padx 5 -pady 5
               entry $This.usr.2.4.ent4 -textvariable faireImageRef(out)
               pack $This.usr.2.4.ent4 -side left -padx 10 -pady 5 -fill x -expand 1
               button $This.usr.2.4.explore -text "$caption(pretraitement,parcourir)" -width 1 \
                  -command { ::faireImageRef::parcourir 2 }
               pack $This.usr.2.4.explore -side right -padx 10 -pady 5 -ipady 5
            pack $This.usr.2.4 -side top -fill both
        # pack $This.usr.2 -side top -fill both

         frame $This.usr.1 -borderwidth 1 -relief raised
            #--- Liste des pretraitements disponibles
            set list_faireImageRef [ list $caption(audace,menu,faire_offset) $caption(audace,menu,faire_dark) \
               $caption(audace,menu,faire_flat_field) $caption(audace,menu,faire_pretraitee) ]
            #---
            menubutton $This.usr.1.but1 -textvariable faireImageRef(captionOperation) -menu $This.usr.1.but1.menu \
               -relief raised
            pack $This.usr.1.but1 -side right -padx 10 -pady 5 -ipady 5
            set m [menu $This.usr.1.but1.menu -tearoff 0]
            foreach pretrait $list_faireImageRef {
               $m add radiobutton -label "$pretrait" \
                -indicatoron "1" \
                -value "$pretrait" \
                -variable faireImageRef(captionOperation) \
                -command { ::faireImageRef::captionFonction $faireImageRef(captionOperation) }
            }
        # pack $This.usr.1 -side top -fill both -ipady 5

      pack $This.usr -side top -fill both -expand 1

      frame $This.cmd -borderwidth 1 -relief raised
         button $This.cmd.ok -text "$caption(aud_menu_3,ok)" -width 7 \
            -command { ::faireImageRef::cmdOk }
         if { $conf(ok+appliquer)=="1" } {
            pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }
         button $This.cmd.appliquer -text "$caption(aud_menu_3,appliquer)" -width 8 \
            -command { ::faireImageRef::cmdApply }
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.fermer -text "$caption(aud_menu_3,fermer)" -width 7 \
            -command { ::faireImageRef::cmdClose }
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.aide -text "$caption(aud_menu_3,aide)" -width 7 \
            -command { ::faireImageRef::afficheAide }
         pack $This.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x
      pack $This.cmd -side top -fill x

      #---
      uplevel #0 trace variable faireImageRef(operation) w ::faireImageRef::change

      #---
      bind $This <Key-Return> {::faireImageRef::cmdOk}
      bind $This <Key-Escape> {::faireImageRef::cmdClose}

      #--- Focus
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # ::faireImageRef::fonctionCaption
   # Procedure qui associe a une fonction un caption
   #
   proc fonctionCaption { type_image_reference } {
      global caption faireImageRef

      #---
      if { $type_image_reference == "faire_offset" } {
         set faireImageRef(captionOperation) "$caption(audace,menu,faire_offset)"
      } elseif { $type_image_reference == "faire_dark" } {
         set faireImageRef(captionOperation) "$caption(audace,menu,faire_dark)"
      } elseif { $type_image_reference == "faire_flat_field" } {
         set faireImageRef(captionOperation) "$caption(audace,menu,faire_flat_field)"
      } elseif { $type_image_reference == "pretraitement" } {
         set faireImageRef(captionOperation) "$caption(audace,menu,faire_pretraitee)"
      }
   }

   #
   # ::faireImageRef::captionFonction
   # Procedure qui associe a un caption une fonction
   #
   proc captionFonction { type_image_reference } {
      global caption faireImageRef

      #---
      if { $type_image_reference == "$caption(audace,menu,faire_offset)" } {
         set faireImageRef(operation) "faire_offset"
      } elseif { $type_image_reference == "$caption(audace,menu,faire_dark)" } {
         set faireImageRef(operation) "faire_dark"
      } elseif { $type_image_reference == "$caption(audace,menu,faire_flat_field)" } {
         set faireImageRef(operation) "faire_flat_field"
      } elseif { $type_image_reference == "$caption(audace,menu,faire_pretraitee)" } {
         set faireImageRef(operation) "pretraitement"
      }
   }

   #
   # ::faireImageRef::cmdOk
   # Procedure correspondant a l'appui sur le bouton OK
   #
   proc cmdOk { } {
      if { [ ::faireImageRef::cmdApply ] == "0" } { return }
      ::faireImageRef::cmdClose
   }

   #
   # ::faireImageRef::cmdApply
   # Procedure correspondant a l'appui sur le bouton Appliquer
   #
   proc cmdApply { } {
      global audace caption conf faireImageRef

      #---
      set faireImageRef(avancement) "$caption(pretraitement,en_cours)"
      update

      #---
      set in    $faireImageRef(in)
      set nb    $faireImageRef(nb)
      set first $faireImageRef(valeur_indice)
      set out   $faireImageRef(out)

      #--- Tests sur les images d'entree, le nombre d'images et les images de sortie
      if { $faireImageRef(in) == "" } {
          tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
             -message "$caption(pretraitement,definir_entree_generique)"
          set faireImageRef(avancement) ""
          return 0
      }
      if { $faireImageRef(nb) == "" } {
          tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
             -message "$caption(pretraitement,choix_nbre_images)"
          set faireImageRef(avancement) ""
          return 0
      }
      if { [ TestEntier $faireImageRef(nb) ] == "0" } {
         tk_messageBox -title "$caption(pretraitement,attention)" -icon error \
            -message "$caption(pretraitement,nbre_entier)"
          set faireImageRef(avancement) ""
         return 0
      }
      if { $faireImageRef(valeur_indice) == "" } {
         tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
            -message "$caption(pretraitement,choix_premier_indice)"
         set faireImageRef(avancement) ""
         return 0
      }
      if { [ TestEntier $faireImageRef(valeur_indice) ] == "0" } {
         tk_messageBox -title "$caption(pretraitement,attention)" -icon error \
            -message "$caption(pretraitement,nbre_entier1)"
         set faireImageRef(avancement) ""
         return 0
      }
      if { $faireImageRef(out) == "" } {
         if { $faireImageRef(operation) == "pretraitement" } {
             tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
                -message "$caption(pretraitement,definir_sortie_generique)"
             set faireImageRef(avancement) ""
             return 0
         } else {
             tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
                -message "$caption(pretraitement,definir_image_sortie)"
             set faireImageRef(avancement) ""
            return 0
         }
      }
      #--- Calcul du dernier indice de la serie
      set end [ expr $nb + ( $first - 1 ) ]

      #--- Switch
      switch $faireImageRef(operation) {
         "faire_offset" {
            set catchError [ catch {
               smedian $in $out $nb $first
               if { $faireImageRef(disp) == 1 } {
                  loadima $out
               }
               set faireImageRef(avancement) "$caption(pretraitement,fin_traitement)"
            } m ]
            if { $catchError == "1" } {
               tk_messageBox -title "$caption(pretraitement,attention)" -icon error -message "$m"
               set faireImageRef(avancement) ""
            }
         }
         "faire_dark" {
            set catchError [ catch {
               #--- Test sur l'offset
               if { $faireImageRef(dark,no-offset) == "0" } {
                  if { $faireImageRef(offset) == "" } {
                     tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
                        -message "$caption(pretraitement,definir_offset)"
                     set faireImageRef(avancement) ""
                     return 0
                  }
               }
               #---
               set offset $faireImageRef(offset)
               set const "0"
               set temp "temp"
               if { $faireImageRef(dark,no-offset) == "0" } {
                  sub2 $in $offset $temp $const $nb $first
                  if { $faireImageRef(methode) == "0" } {
                     #--- Somme
                     #--- Attention sub2 a cree les images temp a partir de 1
                     sadd $temp $out $nb 1
                  } elseif { $faireImageRef(methode) == "1" } {
                     #--- Moyenne
                     #--- Attention sub2 a cree les images temp a partir de 1
                     smean $temp $out $nb 1
                  } elseif { $faireImageRef(methode) == "2" } {
                     #--- Mediane
                     #--- Attention sub2 a cree les images temp a partir de 1
                     smedian $temp $out $nb 1
                  }
                  delete2 $temp $nb
               } elseif { $faireImageRef(dark,no-offset) == "1" } {
                  if { $faireImageRef(methode) == "0" } {
                     #--- Somme
                     sadd $in $out $nb $first
                  } elseif { $faireImageRef(methode) == "1" } {
                     #--- Moyenne
                     smean $in $out $nb $first
                  } elseif { $faireImageRef(methode) == "2" } {
                     #--- Mediane
                     smedian $in $out $nb $first
                  }
               }
               if { $faireImageRef(disp) == 1 } {
                  loadima $out
               }
               set faireImageRef(avancement) "$caption(pretraitement,fin_traitement)"
            } m ]
            if { $catchError == "1" } {
               tk_messageBox -title "$caption(pretraitement,attention)" -icon error -message "$m"
               set faireImageRef(avancement) ""
            }
         }
         "faire_flat_field" {
            set catchError [ catch {
               #--- Test sur l'offset
               if { $faireImageRef(flat-field,no-offset) == "0" } {
                  if { $faireImageRef(offset) == "" } {
                     tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
                        -message "$caption(pretraitement,definir_offset)"
                     set faireImageRef(avancement) ""
                     return 0
                  }
               }
               #--- Test sur le dark
               if { $faireImageRef(flat-field,no-dark) == "0" } {
                  if { $faireImageRef(dark) == "" } {
                     tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
                        -message "$caption(pretraitement,definir_noir)"
                     set faireImageRef(avancement) ""
                     return 0
                  }
               }
               #--- Tests sur la valeur de normalisation
               if { $faireImageRef(flat-field,no-offset) == "1" && $faireImageRef(flat-field,no-dark) == "1" } {
               } else {
                  if { $faireImageRef(norm) == "" } {
                     tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
                        -message "$caption(pretraitement,definir_cte)"
                     set faireImageRef(avancement) ""
                     return 0
                  }
                  if { [ string is double -strict $faireImageRef(norm) ] == "0" } {
                     tk_messageBox -title "$caption(pretraitement,attention)" -icon error \
                        -message "$caption(pretraitement,cte_invalide)"
                     set faireImageRef(avancement) ""
                     return 0
                  }
               }
               #---
               set offset $faireImageRef(offset)
               set dark   $faireImageRef(dark)
               set norm   $faireImageRef(norm)
               set const  "0"
               set temp   "temp"
               set tempo  "tempo"
               if { $faireImageRef(flat-field,no-offset) == "0" && $faireImageRef(flat-field,no-dark) == "0" } {
                  #--- Realisation de l'image ( Offset + Dark )
                  set buf_pretrait [ ::buf::create ]
                  buf$buf_pretrait extension $conf(extension,defaut)
                  buf$buf_pretrait load [ file join $audace(rep_images) $offset ]
                  buf$buf_pretrait add [ file join $audace(rep_images) $dark ] $const
                  buf$buf_pretrait save [ file join $audace(rep_images) offset+dark ]
                  ::buf::delete $buf_pretrait
                  #---
                  sub2 $in offset+dark $temp $const $nb $first
                  noffset2 $temp $tempo $norm $nb 1 ; #--- Attention sub2 a cree les images temp a partir de 1
                  smedian $tempo $out $nb 1 ; #--- Attention sub2 a cree les images temp a partir de 1
                  #--- Suppression des fichiers intermediaires
                  file delete [ file join $audace(rep_images) offset+dark$conf(extension,defaut) ]
                  delete2 $temp $nb
                  delete2 $tempo $nb
               } elseif { $faireImageRef(flat-field,no-offset) == "1" && $faireImageRef(flat-field,no-dark) == "0" } {
                  #---
                  sub2 $in $dark $temp $const $nb $first
                  noffset2 $temp $tempo $norm $nb 1 ; #--- Attention sub2 a cree les images temp a partir de 1
                  smedian $tempo $out $nb 1 ; #--- Attention sub2 a cree les images temp a partir de 1
                  #--- Suppression des fichiers intermediaires
                  delete2 $temp $nb
                  delete2 $tempo $nb
               } elseif { $faireImageRef(flat-field,no-offset) == "0" && $faireImageRef(flat-field,no-dark) == "1" } {
                  #---
                  sub2 $in $offset $temp $const $nb $first
                  noffset2 $temp $tempo $norm $nb 1 ; #--- Attention sub2 a cree les images temp a partir de 1
                  smedian $tempo $out $nb 1 ; #--- Attention sub2 a cree les images temp a partir de 1
                  #--- Suppression des fichiers intermediaires
                  delete2 $temp $nb
                  delete2 $tempo $nb
               } elseif { $faireImageRef(flat-field,no-offset) == "1" && $faireImageRef(flat-field,no-dark) == "1" } {
                  #---
                  smedian $in $out $nb $first
               }
               if { $faireImageRef(disp) == 1 } {
                  loadima $out
               }
               set faireImageRef(avancement) "$caption(pretraitement,fin_traitement)"
            } m ]
            if { $catchError == "1" } {
               tk_messageBox -title "$caption(pretraitement,attention)" -icon error -message "$m"
               set faireImageRef(avancement) ""
            }
         }
         "pretraitement" {
            set catchError [ catch {
               #--- Test sur l'offset
               if { $faireImageRef(pretraitement,no-offset) == "0" } {
                  if { $faireImageRef(offset) == "" } {
                     tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
                        -message "$caption(pretraitement,definir_offset)"
                     set faireImageRef(avancement) ""
                     return 0
                  }
               }
               #--- Test sur le dark
               if { $faireImageRef(pretraitement,no-dark) == "0" } {
                  if { $faireImageRef(dark) == "" } {
                     tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
                        -message "$caption(pretraitement,definir_noir)"
                     set faireImageRef(avancement) ""
                     return 0
                  }
               }
               #--- Test sur le flat-field
               if { $faireImageRef(pretraitement,no-flat-field) == "0" } {
                  if { $faireImageRef(flat-field) == "" } {
                     tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
                        -message "$caption(pretraitement,definir_flat-field)"
                     set faireImageRef(avancement) ""
                     return 0
                  }
               }
               #--- Tests sur la valeur de normalisation
               if { $faireImageRef(pretraitement,no-flat-field) == "0" } {
                  if { $faireImageRef(pretraitement,norm-auto) == "0" } {
                     if { $faireImageRef(norm) == "" } {
                        tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
                           -message "$caption(pretraitement,definir_cte)"
                        set faireImageRef(avancement) ""
                        return 0
                     }
                     if { [ string is double -strict $faireImageRef(norm) ] == "0" } {
                        tk_messageBox -title "$caption(pretraitement,attention)" -icon error \
                           -message "$caption(pretraitement,cte_invalide)"
                        set faireImageRef(avancement) ""
                        return 0
                     }
                  }
               }
               #--- Calcul automatique de la constante multiplicative
               if { $faireImageRef(pretraitement,norm-auto) == "1" } {
                  ::faireImageRef::calculCsteMult
               }
               #---
               set offset $faireImageRef(offset)
               set dark   $faireImageRef(dark)
               set flat   $faireImageRef(flat-field)
               set norm   $faireImageRef(norm)
               set const  "0"
               set temp   "temp"
               set tempo  "tempo"
               #--- Formule : Generique de sortie = K * [ Generique d'entree - ( Offset + Dark ) ] / Flat-field
               #--- Deux familles de pretraitement : Sans ou avec optimisation du noir
               if { $faireImageRef(opt) == "0" } {
                  #--- Sans optimisation du noir - Offset, dark et flat disponibles
                  if { $faireImageRef(option) == "000" } {
                     #--- Realisation de X = ( Offset + Dark )
                     set buf_pretrait [ ::buf::create ]
                     buf$buf_pretrait extension $conf(extension,defaut)
                     buf$buf_pretrait load [ file join $audace(rep_images) $offset ]
                     buf$buf_pretrait add [ file join $audace(rep_images) $dark ] $const
                    buf$buf_pretrait save [ file join $audace(rep_images) offset+dark ]
                     ::buf::delete $buf_pretrait
                     #--- Realisation de Y = [ Generique d'entree - ( X ) ]
                     sub2 $in offset+dark $temp $const $nb $first
                     #--- Realisation de Z = K * Y / Flat-field
                     if { $first == "1" } {
                        div2 $temp $flat $out $norm $nb 1 ; #--- Attention sub2 a cree les images temp a partir de 1
                     } else {
                        div2 $temp $flat $tempo $norm $nb 1 ; #--- Attention sub2 a cree les images temp a partir de 1
                     }
                     #--- Suppression des fichiers intermediaires
                     file delete [ file join $audace(rep_images) offset+dark$conf(extension,defaut) ]
                     delete2 $temp $nb
                  #--- Sans optimisation du noir - Offset et dark disponibles - Manque les flats
                  } elseif { $faireImageRef(option) == "001" } {
                     #--- Realisation de X = ( Offset + Dark )
                     set buf_pretrait [ ::buf::create ]
                     buf$buf_pretrait extension $conf(extension,defaut)
                     buf$buf_pretrait load [ file join $audace(rep_images) $offset ]
                     buf$buf_pretrait add [ file join $audace(rep_images) $dark ] $const
                     buf$buf_pretrait save [ file join $audace(rep_images) offset+dark ]
                     ::buf::delete $buf_pretrait
                     #--- Realisation de Z = [ Generique d'entree - ( X ) ]
                     if { $first == "1" } {
                        sub2 $in offset+dark $out $const $nb $first
                     } else {
                        sub2 $in offset+dark $tempo $const $nb $first
                     }
                     #--- Suppression du fichier intermediaire
                     file delete [ file join $audace(rep_images) offset+dark$conf(extension,defaut) ]
                  #--- Sans optimisation du noir - Offset et flat disponibles - Manque les darks
                  } elseif { $faireImageRef(option) == "010" } {
                     #--- Realisation de Y = [ Generique d'entree - Offset ]
                     sub2 $in $offset $temp $const $nb $first
                     #--- Realisation de Z = K * Y / Flat-field
                     if { $first == "1" } {
                        div2 $temp $flat $out $norm $nb 1 ; #--- Attention sub2 a cree les images temp a partir de 1
                     } else {
                        div2 $temp $flat $tempo $norm $nb 1 ; #--- Attention sub2 a cree les images temp a partir de 1
                     }
                     #--- Suppression des fichiers temporaires
                     delete2 $temp $nb
                  #--- Sans optimisation du noir - Offset disponible - Manque les darks et les flats
                  } elseif { $faireImageRef(option) == "011" } {
                     #--- Realisation de Z = [ Generique d'entree - Offset ]
                     if { $first == "1" } {
                        sub2 $in $offset $out $const $nb $first
                     } else {
                        sub2 $in $offset $tempo $const $nb $first
                     }
                  #--- Sans optimisation du noir - Dark et flat disponibles - Manque les offsets
                  } elseif { $faireImageRef(option) == "100" } {
                     #--- Realisation de Y = [ Generique d'entree - Dark ]
                     sub2 $in $dark $temp $const $nb $first
                     #--- Realisation de Z = K * Y / Flat-field
                     if { $first == "1" } {
                        div2 $temp $flat $out $norm $nb 1 ; #--- Attention sub2 a cree les images temp a partir de 1
                     } else {
                        div2 $temp $flat $tempo $norm $nb 1 ; #--- Attention sub2 a cree les images temp a partir de 1
                     }
                     #--- Suppression des fichiers temporaires
                     delete2 $temp $nb
                  #--- Sans optimisation du noir - Dark disponible - Manque les offsets et les flats
                  } elseif { $faireImageRef(option) == "101" } {
                     #--- Realisation de Z = [ Generique d'entree - Dark ]
                     if { $first == "1" } {
                        sub2 $in $dark $out $const $nb $first
                     } else {
                        sub2 $in $dark $tempo $const $nb $first
                     }
                  #--- Sans optimisation du noir - Flat disponible - Manque les offsets et les darks
                  } elseif { $faireImageRef(option) == "110" } {
                     #--- Realisation de Z = K * Y / Flat-field
                     if { $first == "1" } {
                        div2 $in $flat $out $norm $nb $first
                     } else {
                        div2 $in $flat $tempo $norm $nb $first
                     }
                     #--- Suppression des fichiers temporaires
                     delete2 $temp $nb
                  #--- Sans optimisation du noir - Aucun - Manque les offsets, les darks et les flats
                  } elseif { $faireImageRef(option) == "111" } {
                     #--- Ce cas n'est pas envisageable
                     tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
                        -message "$caption(pretraitement,non_valide)"
                     ::faireImageRef::degriserActiver
                     set faireImageRef(avancement) ""
                     return 0
                  }
               } elseif { $faireImageRef(opt) == "1" } {
                  #--- Optimisation du noir - Offset, dark et flat disponibles
                  if { $faireImageRef(option) == "000" } {
                     #--- Optimisation du noir
                     opt2 $in $dark $offset $temp $nb $first
                     #--- Division par le flat et multiplication par la constante K
                     if { $first == "1" } {
                        div2 $temp $flat $out $norm $nb 1 ; #--- Attention opt2 a cree les images temp a partir de 1
                     } else {
                        div2 $temp $flat $tempo $norm $nb 1 ; #--- Attention opt2 a cree les images temp a partir de 1
                     }
                     #--- Suppression des fichiers temporaires
                     delete2 $temp $nb
                  #--- Optimisation du noir - Offset et dark disponibles - Manque les flats
                  } elseif { $faireImageRef(option) == "001" } {
                     #--- Optimisation du noir
                     if { $first == "1" } {
                        opt2 $in $dark $offset $out $nb $first
                     } else {
                        opt2 $in $dark $offset $tempo $nb $first
                     }
                  #--- Optimisation du noir - Offset et flat disponibles - Manque les darks
                  } elseif { $faireImageRef(option) == "010" } {
                     #--- Ce cas n'est pas envisageable
                     set faireImageRef(avancement) ""
                     return 0
                  #--- Optimisation du noir - Offset disponible - Manque les darks et les flats
                  } elseif { $faireImageRef(option) == "011" } {
                     #--- Ce cas n'est pas envisageable
                     set faireImageRef(avancement) ""
                     return 0
                  #--- Optimisation du noir - Dark et flat disponibles - Manque les offsets
                  } elseif { $faireImageRef(option) == "100" } {
                     #--- Ce cas n'est pas envisageable
                     set faireImageRef(avancement) ""
                     return 0
                  #--- Optimisation du noir - Dark disponible - Manque les offsets et les flats
                  } elseif { $faireImageRef(option) == "101" } {
                     #--- Ce cas n'est pas envisageable
                     set faireImageRef(avancement) ""
                     return 0
                  #--- Optimisation du noir - Flat disponible - Manque les offsets et les darks
                  } elseif { $faireImageRef(option) == "110" } {
                     #--- Ce cas n'est pas envisageable
                     set faireImageRef(avancement) ""
                     return 0
                  #--- Optimisation du noir - Aucun - Manque les offsets, les darks et les flats
                  } elseif { $faireImageRef(option) == "111" } {
                     #--- Ce cas n'est pas envisageable
                     set faireImageRef(avancement) ""
                     return 0
                  }
               }
               #--- Renomme les fichiers image si 'first_index' est different de 1
               if { $first != "1" } {
                  for { set index "1" } { $index <= $nb } { incr index } {
                     set new_index [ expr $index + ( $first - 1 ) ]
                     file rename -force [ file join $audace(rep_images) $tempo$index$conf(extension,defaut) ] [ file join $audace(rep_images) $out$new_index$conf(extension,defaut) ]
                  }
               }
               #---
               if { $faireImageRef(disp) == 1 } {
                  loadima $out$end
               }
               set faireImageRef(avancement) "$caption(pretraitement,fin_traitement)"
            } m ]
            if { $catchError == "1" } {
               tk_messageBox -title "$caption(pretraitement,attention)" -icon error -message "$m"
               set faireImageRef(avancement) ""
            }
         }
      }
      ::faireImageRef::recupPosition
   }

   #
   # ::faireImageRef::cmdClose
   # Procedure correspondant a l'appui sur le bouton Fermer
   #
   proc cmdClose { } {
      variable This

      ::faireImageRef::recupPosition
      destroy $This
      unset This
   }

   #
   # ::faireImageRef::afficheAide
   # Procedure correspondant a l'appui sur le bouton Aide
   #
   proc afficheAide { } {
      global help faireImageRef

      #---
      if { $faireImageRef(operation) == "faire_offset" } {
         set faireImageRef(page_web) "1200faire_offset"
      } elseif { $faireImageRef(operation) == "faire_dark" } {
         set faireImageRef(page_web) "1210faire_dark"
      } elseif { $faireImageRef(operation) == "faire_flat_field" } {
         set faireImageRef(page_web) "1220faire_flat_field"
      } elseif { $faireImageRef(operation) == "pretraitement" } {
         set faireImageRef(page_web) "1230pretraitement"
      }

      #---
      ::audace::showHelpItem "$help(dir,pretrait)" "$faireImageRef(page_web).htm"
   }

   #
   # ::faireImageRef::change n1 n2 op
   # Adapte l'interface graphique en fonction du choix
   #
   proc change { n1 n2 op } {
      variable This
      global caption faireImageRef

      #---
      if { $faireImageRef(operation) == "pretraitement" } {
         set faireImageRef(afficher_image) "$caption(pretraitement,afficher_der_image_fin)"
      } else {
         set faireImageRef(afficher_image) "$caption(pretraitement,afficher_image_fin)"
      }
      $This.usr.6.1.che1 configure -text "$faireImageRef(afficher_image)"
      #---
      set faireImageRef(avancement)    ""
      set faireImageRef(in)            ""
      set faireImageRef(nb)            ""
      set faireImageRef(valeur_indice) "1"
      #---
      ::faireImageRef::formule
      #---
      switch $faireImageRef(operation) {
         "faire_offset" {
            set faireImageRef(out)           "offset"
            set faireImageRef(offset)        ""
            set faireImageRef(dark)          ""
            set faireImageRef(flat-field)    ""
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack forget $This.usr.4
            pack forget $This.usr.5
            pack $This.usr.6 -in $This.usr -side top -fill both
            pack forget $This.usr.7
            pack $This.usr.8 -in $This.usr -side bottom -fill both
         }
         "faire_dark" {
            set faireImageRef(out)           "dark"
            set faireImageRef(offset)        "offset"
            set faireImageRef(dark)          ""
            set faireImageRef(flat-field)    ""
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack $This.usr.3 -in $This.usr -side top -fill both
            pack forget $This.usr.4
            pack $This.usr.5 -in $This.usr -side top -fill both
            pack $This.usr.6 -in $This.usr -side top -fill both
            pack forget $This.usr.7
            pack $This.usr.8 -in $This.usr -side bottom -fill both
         }
         "faire_flat_field" {
            set faireImageRef(out)           "flat"
            set faireImageRef(offset)        "offset"
            set faireImageRef(dark)          "dark-flat"
            set faireImageRef(flat-field)    ""
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack $This.usr.4 -in $This.usr -side top -fill both
            pack forget $This.usr.5
            pack $This.usr.6 -in $This.usr -side top -fill both
            pack forget $This.usr.7
            pack $This.usr.8 -in $This.usr -side bottom -fill both
         }
         "pretraitement" {
            set faireImageRef(out)           ""
            set faireImageRef(offset)        "offset"
            set faireImageRef(dark)          "dark"
            set faireImageRef(flat-field)    "flat"
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack forget $This.usr.3
            pack forget $This.usr.4
            pack forget $This.usr.5
            pack $This.usr.7 -in $This.usr -side top -fill both
            pack $This.usr.6 -in $This.usr -side top -fill both
            pack $This.usr.8 -in $This.usr -side bottom -fill both
         }
      }
   }

   #
   # ::faireImageRef::parcourir In_Out
   # Ouvre un explorateur pour choisir un fichier
   #
   proc parcourir { In_Out } {
      global audace caption faireImageRef

      #--- Fenetre parent
      set fenetre "$audace(base).faireImageRef"
      #--- Ouvre la fenetre de choix des images
      set filename [ ::tkutil::box_load $fenetre $audace(rep_images) $audace(bufNo) "1" ]
      #--- Le fichier selectionne doit imperativement etre dans le repertoire des images
      if { [ file dirname $filename ] != $audace(rep_images) } {
        tk_messageBox -title "$caption(pretraitement,attention)" -type ok \
           -message "$caption(pretraitement,rep-images)"
        return
      }
      #--- Extraction du nom du fichier
      if { $In_Out == "1" } {
         set faireImageRef(info_filename_in)  [ ::pretraitement::afficherNomGenerique [ file tail $filename ] ]
         set faireImageRef(in)                [ lindex $faireImageRef(info_filename_in) 0 ]
         set faireImageRef(nb)                [ lindex $faireImageRef(info_filename_in) 1 ]
         set faireImageRef(valeur_indice)     [ lindex $faireImageRef(info_filename_in) 2 ]
      } elseif { $In_Out == "2" } {

         if { $faireImageRef(operation) == "pretraitement" } {
            set faireImageRef(info_filename_out) [ ::pretraitement::afficherNomGenerique [ file tail $filename ] ]
            set faireImageRef(out)               [ lindex $faireImageRef(info_filename_out) 0 ]

         } else {
            set faireImageRef(out)               [ file rootname [ file tail $filename ] ]
         }
      } elseif { $In_Out == "3" } {
         set faireImageRef(offset) [ file rootname [ file tail $filename ] ]
      } elseif { $In_Out == "4" } {
         set faireImageRef(dark) [ file rootname [ file tail $filename ] ]
      } elseif { $In_Out == "5" } {
         set faireImageRef(flat-field) [ file rootname [ file tail $filename ] ]
      }
   }

   #
   # ::faireImageRef::formule
   # Affiche les formules
   #
   proc formule { } {
      global caption faireImageRef

      if { $faireImageRef(operation) == "faire_dark" } {
         set faireImageRef(image_generique) "$caption(pretraitement,image_generique_entree)"
         set faireImageRef(nombre)          "$caption(pretraitement,image_nombre)"
         set faireImageRef(premier_indice)  "$caption(pretraitement,image_premier_indice)"
         set faireImageRef(image_sortie)    "$caption(pretraitement,image_sortie)"
         set faireImageRef(offset)          "$caption(pretraitement,image_offset)"
      } elseif { $faireImageRef(operation) == "faire_flat_field" } {
         set faireImageRef(image_generique) "$caption(pretraitement,image_generique_entree)"
         set faireImageRef(nombre)          "$caption(pretraitement,image_nombre)"
         set faireImageRef(premier_indice)  "$caption(pretraitement,image_premier_indice)"
         set faireImageRef(image_sortie)    "$caption(pretraitement,image_sortie)"
         set faireImageRef(offset)          "$caption(pretraitement,image_offset)"
         set faireImageRef(dark)            "$caption(pretraitement,image_dark)"
         set faireImageRef(normalisation)   "$caption(pretraitement,valeur_normalisation)"
      } elseif { $faireImageRef(operation) == "pretraitement" } {
         set faireImageRef(image_generique) "$caption(pretraitement,image_generique_entree)"
         set faireImageRef(nombre)          "$caption(pretraitement,image_nombre)"
         set faireImageRef(premier_indice)  "$caption(pretraitement,image_premier_indice)"
         set faireImageRef(image_sortie)    "$caption(pretraitement,image_generique_sortie)"
         set faireImageRef(offset)          "$caption(pretraitement,image_offset)"
         set faireImageRef(dark)            "$caption(pretraitement,image_dark)"
         set faireImageRef(flat-field)      "$caption(pretraitement,image_flat-field)"
         set faireImageRef(normalisation)   "$caption(pretraitement,cte_mult)"
      } else {
         set faireImageRef(image_generique) "$caption(pretraitement,image_generique_entree)"
         set faireImageRef(nombre)          "$caption(pretraitement,image_nombre)"
         set faireImageRef(premier_indice)  "$caption(pretraitement,image_premier_indice)"
         set faireImageRef(image_sortie)    "$caption(pretraitement,image_sortie)"
      }
   }

   #
   # ::faireImageRef::calculCsteMult
   # Fonction destinee a calculer la valeur moyenne de l'image de flat (constante multiplicative)
   #
   proc calculCsteMult { } {
      global audace conf faireImageRef

      #--- Creation d'un buffer temporaire et chargement du flat
      set buf_pretrait [ ::buf::create ]
      buf$buf_pretrait extension $conf(extension,defaut)
      buf$buf_pretrait load [ file join $audace(rep_images) $faireImageRef(flat-field) ]
      #--- Fenetre a la dimension de l'image du flat
      set naxis1 [ expr [ lindex [ buf$buf_pretrait getkwd NAXIS1 ] 1 ]-0 ]
      set naxis2 [ expr [ lindex [ buf$buf_pretrait getkwd NAXIS2 ] 1 ]-0 ]
      set box [ list 1 1 $naxis1 $naxis2 ]
      #--- Lecture des statistiques dans la fenetre et extraction de la moyenne du flat
      set valeurs [ buf$buf_pretrait stat $box ]
      set moyenne [ lindex $valeurs 4 ]
      set faireImageRef(norm) $moyenne
      #--- Destruction du buffer temporaire
      ::buf::delete $buf_pretrait
   }

   #
   # ::faireImageRef::griserActiver_1
   # Fonction destinee a inhiber ou a activer l'affichage du champ offset de la fenetre pretraitement
   #
   proc griserActiver_1 { } {
      variable This
      global faireImageRef

      #--- Cas particulier des images d'offset qui manquent "100"
      set faireImageRef(option) "$faireImageRef(pretraitement,no-offset)$faireImageRef(pretraitement,no-dark)$faireImageRef(pretraitement,no-flat-field)"
      #--- Modification des widgets
      if { $faireImageRef(pretraitement,no-offset) == "0" } {
         $This.usr.7.1.explore configure -state normal
         $This.usr.7.1.ent6 configure -state normal
         $This.usr.7.3.opt configure -state normal
      } else {
         $This.usr.7.1.explore configure -state disabled
         $This.usr.7.1.ent6 configure -state disabled
         $This.usr.7.3.opt configure -state disabled
         set faireImageRef(opt) "0"
      }
   }

   #
   # ::faireImageRef::griserActiver_2
   # Fonction destinee a inhiber ou a activer l'affichage du champ dark de la fenetre pretraitement
   #
   proc griserActiver_2 { } {
      variable This
      global faireImageRef

      #--- Cas particulier des images de dark qui manquent "010"
      set faireImageRef(option) "$faireImageRef(pretraitement,no-offset)$faireImageRef(pretraitement,no-dark)$faireImageRef(pretraitement,no-flat-field)"
      #--- Modification des widgets
      if { $faireImageRef(pretraitement,no-dark) == "0" } {
         $This.usr.7.2.explore configure -state normal
         $This.usr.7.2.ent6 configure -state normal
         $This.usr.7.3.opt configure -state normal
      } else {
         $This.usr.7.2.explore configure -state disabled
         $This.usr.7.2.ent6 configure -state disabled
         $This.usr.7.3.opt configure -state disabled
         set faireImageRef(opt) "0"
      }
   }

   #
   # ::faireImageRef::griserActiver_3
   # Fonction destinee a inhiber ou a activer l'affichage du champ flat-field de la fenetre pretraitement
   #
   proc griserActiver_3 { } {
      variable This
      global faireImageRef

      #--- Cas particulier des images de flat qui manquent "001"
      set faireImageRef(option) "$faireImageRef(pretraitement,no-offset)$faireImageRef(pretraitement,no-dark)$faireImageRef(pretraitement,no-flat-field)"
      #--- Modification des widgets
      if { $faireImageRef(pretraitement,no-flat-field) == "0" } {
         $This.usr.7.4.explore configure -state normal
         $This.usr.7.4.ent6 configure -state normal
         $This.usr.7.6.ent6 configure -state normal
         $This.usr.7.6.che1 configure -state normal
      } else {
         $This.usr.7.4.explore configure -state disabled
         $This.usr.7.4.ent6 configure -state disabled
         $This.usr.7.6.ent6 configure -state disabled
         $This.usr.7.6.che1 configure -state disabled
         set faireImageRef(pretraitement,norm-auto) "0"
      }
   }

   #
   # ::faireImageRef::griserActiver_4
   # Fonction destinee a inhiber ou a activer l'affichage du champ cste de normalisation de la fenetre pretraitement
   #
   proc griserActiver_4 { } {
      variable This
      global faireImageRef

      if { $faireImageRef(pretraitement,norm-auto) == "0" } {
         $This.usr.7.6.ent6 configure -state normal
      } else {
         $This.usr.7.6.ent6 configure -state disabled
      }
   }

   #
   # ::faireImageRef::griserActiver_5
   # Fonction destinee a inhiber ou a activer l'affichage du champ offset de la fenetre flat-field
   #
   proc griserActiver_5 { } {
      variable This
      global faireImageRef

     if { $faireImageRef(flat-field,no-offset) == "0" } {
         $This.usr.4.1.explore configure -state normal
         $This.usr.4.1.ent6 configure -state normal
      } else {
         $This.usr.4.1.explore configure -state disabled
         $This.usr.4.1.ent6 configure -state disabled
      }
      ::faireImageRef::griserActiver_7
   }

   #
   # ::faireImageRef::griserActiver_6
   # Fonction destinee a inhiber ou a activer l'affichage du champ dark de la fenetre flat-field
   #
   proc griserActiver_6 { } {
      variable This
      global faireImageRef

      if { $faireImageRef(flat-field,no-dark) == "0" } {
         $This.usr.4.2.explore configure -state normal
         $This.usr.4.2.ent6 configure -state normal
      } else {
         $This.usr.4.2.explore configure -state disabled
         $This.usr.4.2.ent6 configure -state disabled
      }
      ::faireImageRef::griserActiver_7
   }

   #
   # ::faireImageRef::griserActiver_7
   # Fonction destinee a inhiber ou a activer l'affichage du champ cste de normalisation de la fenetre flat-field
   #
   proc griserActiver_7 { } {
      variable This
      global faireImageRef

      if { $faireImageRef(flat-field,no-offset) == "1" && $faireImageRef(flat-field,no-dark) == "1" } {
         $This.usr.4.3.ent7 configure -state disabled
      } else {
         $This.usr.4.3.ent7 configure -state normal
      }
   }

   #
   # ::faireImageRef::griserActiver_8
   # Fonction destinee a inhiber ou a activer l'affichage du champ offset de la fenetre dark
   #
   proc griserActiver_8 { } {
      variable This
      global faireImageRef

      if { $faireImageRef(dark,no-offset) == "0" } {
         $This.usr.3.1.explore configure -state normal
         $This.usr.3.1.ent6 configure -state normal
      } else {
         $This.usr.3.1.explore configure -state disabled
         $This.usr.3.1.ent6 configure -state disabled
      }
   }

   #
   # ::faireImageRef::degriserActiver
   # Fonction destinee a activer l'affichage des champs offset, dark et flat-field de la fenetre pretraitement
   #
   proc degriserActiver { } {
      variable This
      global faireImageRef

      set faireImageRef(pretraitement,no-offset)     "0"
      set faireImageRef(pretraitement,no-dark)       "0"
      set faireImageRef(pretraitement,no-flat-field) "0"
      set faireImageRef(option)                      "000"
      $This.usr.7.1.explore configure -state normal
      $This.usr.7.1.ent6 configure -state normal
      $This.usr.7.2.explore configure -state normal
      $This.usr.7.2.ent6 configure -state normal
      $This.usr.7.3.opt configure -state normal
      $This.usr.7.4.explore configure -state normal
      $This.usr.7.4.ent6 configure -state normal
      $This.usr.7.6.ent6 configure -state normal
      $This.usr.7.6.che1 configure -state normal
   }

}

########################## Fin du namespace faireImageRef ##########################

