#
# Fichier : confvisu.tcl
# Description : Gestionnaire des visu
# Auteur : Michel PUJOL
# Mise à jour $Id: confvisu.tcl,v 1.166 2010-12-18 15:37:34 robertdelmas Exp $
#

namespace eval ::confVisu {

   #------------------------------------------------------------
   ## init
   #    initialise le namespace confVisu
   # @return rien
   #------------------------------------------------------------
   proc init { } {
      variable private
      global conf

      #--- je charge la librairie libfitstcl
      set oldPath "[pwd]"
      set catchResult [ catch {
         cd $::audela_start_dir
         load libfitstcl[info sharedlibextension]
      } ]
      cd "$oldPath"
      if { $catchResult == 1 } {
         ::console::affiche_erreur "::confVisu::init $::errorInfo\n"
      }

      #--- icone pour ouvrir
      set private(openIcon) [image create photo openIcon -data {
         R0lGODlhEQAPAKEDAAAAAAL/AP//mf///yH5BAEKAAMALAAAAAARAA8AAAIx
         nI+pCr18wJCP0eYWNkB4DDLeSFJIR5biCLYXG8Sy/ArAjJvdjdMn3wuYOK5Q
         5WgoAAA7
      }]

      #--- icone pour enregistrer
      set private(saveIcon) [image create photo saveIcon -data {
         R0lGODlhEAAQAMIEAAABAQCZ/wD9/fb/9////////////////yH5BAEKAAQA
         LAAAAAAQABAAAAM6SLrcCjBK+QIYOGMgQL1aFn2haJHlAJzECpYuCrOrNUEB
         ne/87rW5W0Rnk2yIt+OvllSxWsKJY8pIAAA7
      }]

      #--- icone pour enregistrer sous
      set private(saveAsIcon) [image create photo saveAsIcon -data {
         R0lGODlhEgASAMIEAAAAAACZ/wD9/dz//////////////////yH5BAEKAAcA
         LAAAAAASABIAAANJeLrcDDBK+QIYOGMgQL1aFn2haJHlAJzLCpYuCrPKak1Q
         QB+27v87Gy4S1OE2xeGwZiEQBM6o1FMDOK3S6cMJzUapVSXFQW4kAAA7
      }]

      #--- icone pour fermer
      set private(closeIcon) [image create photo closeIcon -data {
         R0lGODlhEQAQAKEDAAAAAACqAL//v////yH5BAEKAAMALAAAAAARABAAAAIy
         nI+pO+B8QIuwyYrczRobIITaqIDheW4RyqofOsaXKQDBjeOzmPcbaOvpOMIh
         R9bxQAoAOw==
      }]

      #--- icone pour nouvelle visu
      set private(newVisuIcon) [image create photo newVisuIcon -data {
         R0lGODlhEQAQAMIDAAAAAAAAgADh/////////////////////yH5BAEKAAAA
         LAAAAAARABAAAAM1CLrcKzBKB0S4GFPJwx5gCHqOIIpkY4Ycp6yglWWv2Eak
         fMFnyvCoz2kkHPoeQ2JpRqM4FQkAOw==
      }]

      #--- icone pour miroir horizontal
      set private(mirrorHIcon) [image create photo mirrorHIcon -data {
         R0lGODlhDwARAMIDAAAAAAAAgICA/////////////////////yH5BAEKAAQA
         LAAAAAAPABEAAAMvSLrcGjDK0IK4WFBn83ZEp4GM9ZEPqjJA677uKp9oMNDc
         oOOLre8g3w9YmkxkjQQAOw==
      }]

      #--- icone pour miroir vertical
      set private(mirrorVIcon) [image create photo mirrorVIcon -data {
         R0lGODlhEQAPAMIDAAAAAAAAgICA/////////////////////yH5BAEKAAQA
         LAAAAAARAA8AAAM7SLrczuCp4GKjJOBll57CRnTZgAVCyHmDCaaYFbRulsJj
         SZ93PO2vTWdWQ4lIs5Mox/hkKo4lREKVJAAAOw==
      }]

      #--- icone pour sommaire de l'aide
      set private(contentsIcon) [image create photo contentsIcon -data {
         R0lGODlhEgASAOMIAAAzZgAzmQBmZgBmmQBmzEC/////APb/9///////////
         /////////////////////yH5BAEKAA8ALAAAAAASABIAAARa8MlJq60ElHsz
         GQBHeUQJiqRhlF+IAeVKyKUrkezMAsKEz6qdgHADwHS5jABBfBAOgQEwx2Nu
         nAeEIEpdEq4PWFbLrX5fh7HADEZnvW2LJ3sW+WBxe93On0QAADs=
      }]

      #--- icone pour a propos de
      set private(aboutIcon) [image create photo aboutIcon -data {
         R0lGODlhDAAQAMIEAAAzZgCamgDM//b/9////////////////yH5BAEKAAQA
         LAAAAAAMABAAAAMqSLrc8C84QSmQCthnsb7D8HkCqJUYYXaNyrZjm6Gye9Uq
         gJ83/MI9XCMBADs=
      }]

   }

   #------------------------------------------------------------
   ## create
   #    cree une nouvelle visu
   # parametres :
   # @param  base : fenetre Toplevel dans laquelle est cree la visu
   #           si base est vide, la fonction cree une nouvelle Toplevel
   # @return
   #    retourne une exception en cas d'erreur
   #------------------------------------------------------------
   proc create { { base "" } } {
      variable private
      global audace conf

      #--- je cherche le premier numero de visu disponible
      set visuNo 1
      while { [info command visu$visuNo] != "" } {
         incr visuNo
      }
      #--- je cree le buffer qui va etre associe a la visu
      set bufNo [::buf::create ]
      #--- je cree la photo qui va etre associee a la visu
      image create photo imagevisu$visuNo
      #--- je cree la visu associee au buffer bufNo et a l'image imagevisu$visuNo
      set visuNo [::visu::create $bufNo $visuNo]

      #--- cree les variables dans conf(..) si elles n'existent pas
      if { ! [ info exists conf(audace,visu$visuNo,wmgeometry) ] } {
         set conf(audace,visu$visuNo,wmgeometry) "600x400+0+0"
      }
      if { ! [ info exists conf(audace,visu$visuNo,zoom) ] } {
         set conf(audace,visu$visuNo,zoom) "1"
      }
      if { ! [ info exists conf(seuils,visu$visuNo,intervalleSHSB) ] } {
         set conf(seuils,visu$visuNo,intervalleSHSB) "1"
      }
      if { ! [ info exists conf(seuils,visu$visuNo,mode) ] } {
         set conf(seuils,visu$visuNo,mode) "loadima"
      }
      if { ! [ info exists conf(visu,crosshairstate) ] } {
         set conf(visu,crosshairstate) "0"
      }
      if { ! [ info exists conf(visu_palette,visu$visuNo,mode) ] } {
         set conf(visu_palette,visu$visuNo,mode) "1"
      }
      if { ! [ info exists conf(fonction_transfert,visu$visuNo,position) ] } {
         set conf(fonction_transfert,visu$visuNo,position) "+0+0"
      }
      if { ! [ info exists conf(fonction_transfert,visu$visuNo,mode) ] } {
         set conf(fonction_transfert,visu$visuNo,mode) "1"
      }

      if { $base != "" } {
         set private($visuNo,This) $base
         #--- pas besoin de creer de toplevel (visu principale)
      } else {
         #--- creation de la fenetre toplevel (visu secondaires)
         set private($visuNo,This) ".visu$visuNo"
         ::confVisu::createToplevel $visuNo $private($visuNo,This)
      }

      #--- Position de l'image dans la fenetre principale
      set private($visuNo,labcoord_type)   "xy"
      set private($visuNo,picture_w)       "0"
      set private($visuNo,picture_h)       "0"
      set private($visuNo,applyThickness)  "0"
      set private($visuNo,lastFileName)    ""
      set private($visuNo,autovisuEnCours) "0"
      set private($visuNo,fitsHduList)     ""
      set private($visuNo,currentHduNo)    1
      set private($visuNo,maxdyn)          "32767"
      set private($visuNo,mindyn)          "-32768"
      set private($visuNo,intervalleSHSB)  "$conf(seuils,visu$visuNo,intervalleSHSB)"
      set private($visuNo,a)               "0"
      set private($visuNo,b)               "1"
      set private($visuNo,hCanvas)         $private($visuNo,This).can1.canvas
      set private($visuNo,hCrosshairH)     $private($visuNo,hCanvas).crosshairH
      set private($visuNo,hCrosshairV)     $private($visuNo,hCanvas).crosshairV
      set private($visuNo,crosshairstate)  $conf(visu,crosshairstate)
      set private($visuNo,menu)            ""
      set private($visuNo,mode)            "image"

      #--- Initialisation des variables utilisees par les menus
      set private($visuNo,mirror_x)           "0"
      set private($visuNo,mirror_y)           "0"
      set private($visuNo,window)             "0"
      set private($visuNo,fullscreen)         "0"
      set private($visuNo,zoomList)           [list 0.125 0.25 0.5 1 2 4 8]
      set private($visuNo,zoom)               "1"
      set private($visuNo,currentTool)        ""
      set private($visuNo,pluginInstanceList) [list ]

      #--- Initialisation de variables pour le trace de repere
      set private($visuNo,boxSize)      ""
      set private($visuNo,hBox)         ""

      #--- Initialisation d'autres variables
      set private($visuNo,camItem)      ""
      set private($visuNo,intensity)    "1"
      set private($visuNo,closeEnCours) "0"

      #--- initialisation des bind de touches et de la souris
      set private($visuNo,MouseState) rien

      #--- Initialisation des variables utilisees par les listeners
      set private($visuNo,zoomListenerFlag)    ""
      set private($visuNo,mirrorXListenerFlag) ""
      set private($visuNo,mirrorYListenerFlag) ""
      set private($visuNo,windowListenerFlag)  ""

      #--- je cree la fenetre
      ::confVisu::createDialog $visuNo $private($visuNo,This)
      #--- configuration buffer
      buf$bufNo extension $conf(extension,defaut)
      #--- Fichiers image compresses ou non
      if { $conf(fichier,compres) == "0" } {
         buf$bufNo compress "none"
      } else {
         buf$bufNo compress "gzip"
      }
      #--- Format des fichiers image (entier ou flottant)
      if { $conf(format_fichier_image) == "0" } {
         buf$bufNo bitpix ushort
      } else {
         buf$bufNo bitpix float
      }

      #--- Creation de l'image associee a la visu dans le tag "display"
      $private($visuNo,hCanvas) create image 0 0 -anchor nw -tag display
      $private($visuNo,hCanvas) itemconfigure display -image imagevisu$visuNo

      #--- je cree le menu
      if { $base == "" } {
         ::confVisu::createMenu $visuNo
      }

      #--- je cree les bind
      ::confVisu::createBindDialog $visuNo

      #--- j'affiche le nom de la monture
      setMount $visuNo

      #--- je mets à jour couleurs et polices
      ::confColor::applyColor $private($visuNo,This)

      #--- j'applique le zoom de la session precedente (
      ::confVisu::setZoom $visuNo $::conf(audace,visu$visuNo,zoom)

      #--- j'initialise les glissieres RVB
      ::colorRGB::initConf $visuNo

      return $visuNo
   }

   #------------------------------------------------------------
   #  close
   #     ferme la visu
   #------------------------------------------------------------
   proc close { visuNo } {
      variable private
      global audace caption conf

      #--- je sors de la procedure si une fermeture est deja en cours
      if { $private($visuNo,closeEnCours) == "1" } {
         return
      }

      #--- je change la valeur de la variable de fermeture
      set private($visuNo,closeEnCours) "1"

      #--- je verifie que la visu existe
      if { [info commands "::visu$visuNo" ] == "::visu$visuNo" } {

         #--- je sauvegarde le namespace du plugin courant des visu secondaires
         if { $visuNo != "1" } {
            set currentNamespace($visuNo) [ ::confVisu::getTool $visuNo ]
            set conf(tool,visu$visuNo,currentNamespace) $currentNamespace($visuNo)
         }

         #--- je ferme le plugin courant des visu secondaires
         if { $visuNo != "1" } {
            if { [getTool $visuNo] != "" } {
               set result [stopTool $visuNo $private($visuNo,currentTool)]
               if { $result == "-1" } {
                  tk_messageBox -title "$caption(confVisu,attention)" -icon error \
                     -message [format $caption(confVisu,fermeture_impossible) [ [ ::confVisu::getTool $visuNo ]::getPluginTitle ] ]
                  set private($visuNo,closeEnCours) "0"
                  return
               }
            }
         }

         #--- je ferme la camera associee a la visu
         ::confCam::stopItem $private($visuNo,camItem)

         #--- je ferme la sous fenetre header (avec arret des listeners)
         ::keyword::closeHeader $visuNo

         #--- je memorise les variables dans conf(.)
         set conf(audace,visu$visuNo,wmgeometry)     [wm geometry $::confVisu::private($visuNo,This)]
         set conf(audace,visu$visuNo,zoom)           $private($visuNo,zoom)
         set conf(seuils,visu$visuNo,intervalleSHSB) $private($visuNo,intervalleSHSB)

         #--- je supprime les bind
         ::confVisu::deleteBindDialog $visuNo

         #--- je supprime le menubar et toutes ses entrees
         if { $private($visuNo,menu) != "" } {
            Menubar_Delete $visuNo
         }

         #--- je detruis tous les plugins
         if { "$private($visuNo,This)" != "$audace(base).select" } {
            foreach pluginInstance $private($visuNo,pluginInstanceList) {
               $pluginInstance\::deletePluginInstance $visuNo
            }
         }

         #--- je supprime l'image associee a la visu
         image delete imagevisu[visu$visuNo image]

         #--- je recupere le numero de buffer avant de suprimer la visu
         set bufNo [visu$visuNo buf]

         #--- je supprime la visu
         ::visu::delete $visuNo

         #--- je supprime le buffer associe a la visu
         ::buf::delete $bufNo

         #--- je supprime les graphes des coupes
         ::sectiongraph::closeToplevel $visuNo

      }

      #--- j'initialise la variable de fermeture
      set private($visuNo,closeEnCours) "0"

      #--- je supprime la fenetre et la variable
      destroy $private($visuNo,This)
      unset private($visuNo,This)

   }

   #------------------------------------------------------------
   # autovisu
   #     rafraichit l'affichage
   # parametres
   #  visuNo: numero de la visu
   #  force:  -dovisu : rafraichissement complet
   #          -no     : rafraichissement sans recalcul des seuils
   #          -novisu : pas de rafraichissement
   #          -clear  : efface l'image
   #  filename : nom du fichier contenant l'image
   #          Un nom de fichier FITS peut contenir le numero de HDU en extension apres un poitn virgule
   #          Exemple : vega.fit;3  signifie qu'il faut afficher le HDU numero 3 du fichier vega.fit
   #  retour: null
   #------------------------------------------------------------
   proc autovisu { visuNo { force "-no" } { fileName "" } { hduName "" } } {
      variable private
      global audace caption conf

      #--- petit raccourci pour la suite
      set bufNo [visu$visuNo buf]
      set hduNo 1
      if { [ image type imagevisu[visu$visuNo image] ] == "video" } {
         #--- je recupere la largeur et la hauteur de la video
         set camNo [::confCam::getCamNo $private($visuNo,camItem)]
         set videoSize [cam$camNo nbpix ]
         set private($visuNo,picture_w) [lindex $videoSize 0]
         set private($visuNo,picture_h) [lindex $videoSize 1]
         #--- je mets a jour la taille les scrollbars
         setScrollbarSize $visuNo
         #--- je mets a jour la taille du reticule
         ::confVisu::redrawCrosshair $visuNo
      } else {
         #--- je supprime l'item video s'il existe
         Movie::deleteMovieWindow $visuNo
         $private($visuNo,hCanvas) itemconfigure display -state normal

         if { $force != "-clear" } {
            if { $fileName != "" } {
               if { [string first ";" $fileName ] != -1 } {
                  #---- je separe le nom du fichier du numero de HDU
                  set fileName [split $fileName ";"]
                  set hduNo    [lindex $fileName 1]
                  set fileName [lindex $fileName 0]
               } else {
                  set hduNo 1
               }
               if { $fileName != [getFileName $visuNo] } {
                  #--- c'est un nouveau fichier
                  if { $hduName == "" } {
                     #--- je recupere le nom du HDU du fichier precedent
                     if { [llength $private($visuNo,fitsHduList) ] > 1 } {
                        set hduName [lindex [lindex $private($visuNo,fitsHduList) [expr $private($visuNo,currentHduNo) -1]] 0]
                     }
                  }
                  #--- je charge le fichier
                  set loadError [ catch {
                     buf$bufNo load $fileName
                  } ]
                  if { $loadError == 0 } {
                     #--- je recupere la liste des HDU du fichier
                     set private($visuNo,fitsHduList)  [initHduList $visuNo $fileName ]
                     #--- j'affiche liste des HDU s'il y en a plusieurs
                     if { [llength $private($visuNo,fitsHduList) ] > 1 } {
                        #--- j'affiche le meme HDU que celui du fichier precedent s'il existe
                        if { $hduName != "PRIMARY" } {
                           #--- je cherche un HDU avec le meme nom que celui de l'image precedente
                           set hduIndex [lsearch -regexp $private($visuNo,fitsHduList) $hduName]
                           if { $hduIndex != -1 } {
                              set hduInfo [lindex $private($visuNo,fitsHduList) $hduIndex ]
                              set hduType [lindex $hduInfo 1]
                              set hduNo   [expr $hduIndex + 1]
                              if { $hduType == "Image" } {
                                 #--- je charge le hdu
                                 if { $hduNo != "1" } {
                                    buf$bufNo load "$fileName;$hduNo"
                                 }
                              } else {
                                 #--- si c'est une table, je charge la table dans les variables columnNames et columnValues
                                 #--- j'utilise commande "fits open" car la commande "buf$bufno load" ne focntionne pas que pour les images
                                 set hFile ""
                                 set catchResult [catch {
                                    #--- je nettoie le buffer pour gagner de la place en memoire car il n'est pas utilise dans ce cas
                                    buf$bufNo clear
                                    #--- j'ouvre le fichier en mode lecture
                                    set hFile [fits open $fileName 0]
                                    $hFile move $hduNo
                                    #--- je charge le titre des colonnes
                                    set columnNames  [$hFile info column ]
                                    #--- je charge les valeurs de colonnes
                                    set columnValues [$hFile get table]
                                 } ]
                                 if { $hFile != "" } {
                                    $hFile close
                                 }
                                 if { $catchResult == 1 } {
                                    #--- je transmets l'erreur
                                    error $::errorInfo
                                 }
                              }
                           }
                        }
                        #--- je charge la liste dans la combobox de la toolbar
                        ::confVisu::showHduList $visuNo $hduNo
                        #--- j'affiche la toolbar
                        ::confVisu::showToolBar $visuNo 1
                     } else {
                        set hduType "Image"
                        ::confVisu::showToolBar $visuNo 0
                     }
                  } else {
                     #--- en cas d'erreur de chargement du fichier avec buf load
                     #--- je verifie si le fichier contient un deuxième HDU non vide
                     #--- je recupere la liste des HDU du fichier
                     if { [string first "#302:column number < 1 or > tfields" $::errorInfo] != -1 } {
                        set private($visuNo,fitsHduList) [initHduList $visuNo $fileName ]
                        if { [llength $private($visuNo,fitsHduList) ] > 1 } {
                           set hduIndex 1
                           set hduInfo [lindex $private($visuNo,fitsHduList) $hduIndex ]
                           set hduType [lindex $hduInfo 1]
                           set hduNo   [expr $hduIndex + 1]
                           if { $hduType == "Image" } {
                              #--- je charge le hdu
                              buf$bufNo load "$fileName;$hduNo"
                           } else {
                              #--- si c'est une table, je charge la table dans les variables columnNames et columnValues
                              #--- j'utilise commande "fits open" car la commande "buf$bufno load" ne focntionne pas que pour les images
                              set hFile ""
                              set catchResult [catch {
                                  #--- je nettoie le buffer pour gagner de la place en memoire car il n'est pas utilise dans ce cas
                                  buf$bufNo clear
                                  #--- j'ouvre le fichier en mode lecture
                                  set hFile [fits open $fileName 0]
                                  $hFile move $hduNo
                                  #--- je charge le titre des colonnes
                                  set columnNames  [$hFile info column ]
                                  #--- je charge les valeurs de colonnes
                                  set columnValues [$hFile get table]
                              } ]
                              if { $hFile != "" } {
                                 $hFile close
                              }
                              if { $catchResult == 1 } {
                                 #--- je transmets l'erreur
                                 error $::errorInfo
                              }
                           }
                        } else {
                           #--- en cas d'erreur de chargement du fichier
                           #--- je nettoie l'affichage
                           set private($visuNo,fitsHduList) ""
                           set fileName ""
                           buf$bufNo clear
                           visu$visuNo clear
                           #--- j'affiche l'erreur
                           ::console::affiche_erreur "$::errorInfo\n"
                        }
                     } else {
                        #--- je transmets l'erreur
                        error $::errorInfo
                     }
                  }
               } else {
                  #--- C'est le meme fichier, j'ai deja la liste des HDU
                  #--- je recupere le type de HDU pour savoir si les donnees
                  #--- doivent etre chargees avec "buf load" pour une image 1D ou 2D
                  #--- ou avec "fits open" pour une table
                  if { $private($visuNo,fitsHduList) != "" } {
                     set hduInfo [lindex $private($visuNo,fitsHduList) [expr $hduNo -1]]
                     set hduType [lindex $hduInfo 1]
                  } else {
                     set hduType "Image"
                  }
                  if { $hduType == "Image" } {
                     set loadError [catch {
                        #--- si c'est une image, je charge l'image dans le buffer
                        if { $hduNo != 1 } {
                           buf$bufNo load "$fileName;$hduNo"
                        } else {
                           buf$bufNo load "$fileName"
                        }
                     }]
                     if { $loadError != 0 } {
                        #--- en cas d'erreur de chargement du fichier
                        #--- je nettoie l'affichage
                        set private($visuNo,fitsHduList) ""
                        set fileName ""
                        buf$bufNo clear
                        visu$visuNo clear
                        #--- j'affiche l'erreur
                        ::console::affiche_erreur "$::errorInfo\n"
                     }
                  } else {
                     #--- si c'est une table, je charge la table dans les variables columnNames et columnValues
                     #--- j'utilise commande "fits open" car la commande "buf$bufno load" ne focntionne pas que pour les images
                     set hFile ""
                     set catchResult [catch {
                        #--- je nettoie le buffer pour gagner de la place en memoire car il n'est pas utilise dans ce cas
                        buf$bufNo clear
                        #--- j'ouvre le fichier en mode lecture
                        set hFile [fits open [getFileName $visuNo] 0]
                        $hFile move $hduNo
                        #--- je charge le titre des colonnes
                        set columnNames  [$hFile info column ]
                        #--- je charge les valeurs de colonnes
                        set columnValues [$hFile get table]
                     } ]
                     if { $hFile != "" } {
                        $hFile close
                     }
                     if { $catchResult == 1 } {
                        #--- je transmets l'erreur
                        error $::errorInfo
                     }
                  }
               }
               set private($visuNo,picture_w) [buf$bufNo getpixelswidth]
               set private($visuNo,picture_h) [buf$bufNo getpixelsheight]
            } else {
               #--- je mets à jour le nom du fichier meme quand l'image ne
               #--- provient pas d'un fichier, mais d'une camera
               #--- afin de permettre le rafraichissement des plugins
               #--- qui sont abonnes au listener addFilenameListener
               set hduNo $private($visuNo,currentHduNo)
               set private($visuNo,fitsHduList) ""
            }
         } else {
            #--- si force=-clear , j'efface l'image affichee
            set private($visuNo,fitsHduList) ""
            ::confVisu::setFileName $visuNo ""
            buf$bufNo clear
            visu$visuNo clear
            #--- j'efface la barre d'outils
            ::confVisu::showToolBar $visuNo 0
         }

         #--- on affiche l'image
         if { $force != "-novisu"} {
            #--- je determine le mode d'affichage en fonction du type d'image
            #---  si type=image2D alors mode=image
            #---  si type=image1D alors mode=graph
            #---  si type=table   alors mode=table
            if { $private($visuNo,fitsHduList) != "" } {
               #---
               set hduInfo [lindex $private($visuNo,fitsHduList) [expr $hduNo -1]]
               set hduName [lindex $hduInfo 0]
               set hduType [lindex $hduInfo 1]
               set hduNaxes [lindex $hduInfo 2]

               switch $hduType {
                  Image {
                     set naxes [llength $hduNaxes]
                     set naxis2  [lindex $hduNaxes 1]
                     if { $naxes == 1 || ($naxes == 2 && $naxis2 == 1) } {
                        #--- c'est une image 1D
                        set mode "graph"
                     } else {
                        #--- c'est une image 2D
                        set mode "image"
                     }
                  }
                  Binary {
                     #--- c'est une table
                     set mode "table"
                  }
               }
            } else {
               #--- je recupere la largeur et la hauteur de l'image
               set private($visuNo,picture_w) [buf$bufNo getpixelswidth]
               if { "$private($visuNo,picture_w)" == "" } {
                  set private($visuNo,picture_w) 0
               }
               if { $private($visuNo,picture_w) == 1 } {
                  #--- c'est un profil 1D
                  set mode "graph"
                  #--- la hauteur correspond a l'epaisseur affichee par la visu
                  set private($visuNo,applyThickness) "1"
                  set private($visuNo,picture_h) [visu$visuNo thickness]
               } else {
                  #--- c'est une image 2D
                  set mode "image"
                  #--- la hauteur est la hauteur retournee par le buffer
                  set private($visuNo,applyThickness) "0"
                  set private($visuNo,picture_h) [buf$bufNo getpixelsheight]
               }
            }

            #--- j'affiche les donnees dans la visu
            if { $mode == "image" } {
               #--- j'affiche une image 2D sous forme de courbe

               #--- je supprime le fenetrage si la fenetre deborde de la nouvelle image
               set windowBox [visu$visuNo window]
               if { [lindex $windowBox 2] > $private($visuNo,picture_w)
                  || [lindex $windowBox 3] > $private($visuNo,picture_h) } {
                  set private($visuNo,window) "0"
                  setWindow $visuNo
               }

               #--- Si le buffer contient une image on met a jour les seuils
               if { [ buf$bufNo imageready ] == "1" } {

                  #--- Mise à jour des seuils
                  switch -exact -- $conf(seuils,visu$visuNo,mode) {
                     disable {
                        if { $force == "-no" } {
                          visu $visuNo current
                        } else {
                           set window [visu$visuNo window]
                           if { $window == "full" } {
                              #--- je calcule la statistique sur l'image entiere
                              visu $visuNo [ lrange [ buf$bufNo stat ] 0 1 ]
                           } else {
                              #--- je calcule la statistique sur la fenetre
                              visu $visuNo [ lrange [ buf$bufNo stat $window ] 0 1 ]
                           }
                        }
                     }
                     loadima {
                        set window [visu$visuNo window]
                        if { $window == "full" } {
                           #--- je calcule la statistique sur l'image entiere
                           visu $visuNo [ lrange [ buf$bufNo stat ] 0 1 ]
                        } else {
                           #--- je calcule la statistique sur la fenetre
                           visu $visuNo [ lrange [ buf$bufNo stat $window ] 0 1 ]
                        }
                     }
                     iris {
                        set moyenne [ lindex [ buf$bufNo stat ] 4 ]
                        visu $visuNo [ list [ expr $moyenne + $conf(seuils,irisautohaut) ] [expr $moyenne - $conf(seuils,irisautobas) ] ]
                     }
                     histoauto {
                        set keytype FLOAT
                        buf$bufNo imaseries "CUTS lofrac=[expr 0.01*$conf(seuils,histoautobas)] hifrac=[expr 0.01*$conf(seuils,histoautohaut)] keytype=$keytype"
                        visu $visuNo [ list [ lindex [ buf$bufNo getkwd MIPS-HI ] 1 ] [ lindex [ buf$bufNo getkwd MIPS-LO ] 1 ] ]
                     }
                     initiaux {
                        buf$bufNo initialcut
                        if { [ lindex [ buf$bufNo getkwd NAXIS ] 1 ] == "3" } {
                           set mycuts [ list [ lindex [ buf$bufNo getkwd MIPS-HIR ] 1 ] [ lindex [ buf$bufNo getkwd MIPS-LOR ] 1 ] [ lindex [ buf$bufNo getkwd MIPS-HIG ] 1 ] [ lindex [ buf$bufNo getkwd MIPS-LOG ] 1 ] [ lindex [ buf$bufNo getkwd MIPS-HIB ] 1 ] [ lindex [ buf$bufNo getkwd MIPS-LOB ] 1 ] ]
                           #--- traite le cas des images jpg en couleur qui n'ont que 2 seuils (HI et LO) avec NAXIS = 3
                           if { $mycuts == "{} {} {} {} {} {}" } {
                              set mycuts [ list [ lindex [ buf$bufNo getkwd MIPS-HI ] 1 ] [ lindex [ buf$bufNo getkwd MIPS-LO ] 1 ] ]
                           }
                        } else {
                           set mycuts [ list [ lindex [ buf$bufNo getkwd MIPS-HI ] 1 ] [ lindex [ buf$bufNo getkwd MIPS-LO ] 1 ] ]
                        }
                        visu $visuNo $mycuts
                     }
                  }

                  #--- mise à jour des glissieres
                  if { [ lindex [ buf$bufNo getkwd NAXIS ] 1 ] == "3" } {
                     #--- cas d'une image couleur, j'affiche les glissieres R, V et B
                     #--- je repositionne les poignees
                     $private($visuNo,This).fra1.sca1 set 0.0
                     $private($visuNo,This).fra1.sca2 set 0.0
                     #--- je desactive le reglage des seuils
                     $private($visuNo,This).fra1.sca1 configure -state disabled \
                        -background $audace(color,backColor) \
                        -activebackground $audace(color,backColor)
                     $private($visuNo,This).fra1.sca2 configure -state disabled \
                        -background $audace(color,backColor) \
                        -activebackground $audace(color,backColor)
                     #--- j'affiche les glissieres R, V et B
                     ::colorRGB::run $visuNo
                  } else {
                     #--- cas d'une image N&B
                     #--- j'active le reglage des seuils
                     $private($visuNo,This).fra1.sca1 configure -state normal \
                        -background $audace(color,cursor_blue) \
                        -activebackground $audace(color,cursor_blue_actif)
                     $private($visuNo,This).fra1.sca2 configure -state normal \
                        -background $audace(color,cursor_blue) \
                        -activebackground $audace(color,cursor_blue_actif)
                     #--- je supprime les glissieres R, V et B
                     ::colorRGB::cmdClose $visuNo
                  }

               } else {
                  #--- nettoyage de l'affichage s'il n'y a pas d'image dans le buffer
                  set private($visuNo,picture_w) 0
                  set private($visuNo,picture_h) 0
                  visu $visuNo current
                  #--- je supprime les glissieres R, V et B
                  ::colorRGB::cmdClose $visuNo
               }

               #--- Suppression de la zone selectionnee avec la souris si elle est hors de l'image
               if { [ lindex [ list [ ::confVisu::getBox $visuNo ] ] 0 ] != "" } {
                  set box [ ::confVisu::getBox $visuNo ]
                  set x1 [lindex  [confVisu::getBox $visuNo ] 0]
                  set y1 [lindex  [confVisu::getBox $visuNo ] 1]
                  set x2 [lindex  [confVisu::getBox $visuNo ] 2]
                  set y2 [lindex  [confVisu::getBox $visuNo ] 3]
                  if { $x1 > $::confVisu::private($visuNo,picture_w)
                    || $y1 > $::confVisu::private($visuNo,picture_h)
                    || $y2 > $::confVisu::private($visuNo,picture_w)
                    || $y2 > $::confVisu::private($visuNo,picture_h) } {
                     ::confVisu::deleteBox $visuNo
                  }
               }

               #--- j'identifie si l'echelle RADEC est disponbible
               set calib 1
               if { [string compare [lindex [buf$bufNo getkwd CRPIX1] 0] ""] == 0 } {
                  set calib 0
               }
               if { [string compare [lindex [buf$bufNo getkwd CRPIX2] 0] ""] == 0 } {
                  set calib 0
               }
               if { [string compare [lindex [buf$bufNo getkwd CRVAL1] 0] ""] == 0 } {
                  set calib 0
               }
               if { [string compare [lindex [buf$bufNo getkwd CRVAL2] 0] ""] == 0 } {
                  set calib 0
               }
               set classic 0
               set nouveau 0
               if { [string compare [lindex [buf$bufNo getkwd CD1_1] 0] ""] != 0 } {
                  incr nouveau
               }
               if { [string compare [lindex [buf$bufNo getkwd CD1_2] 0] ""] != 0 } {
                  incr nouveau
               }
               if { [string compare [lindex [buf$bufNo getkwd CD2_1] 0] ""] != 0 } {
                  incr nouveau
               }
               if { [string compare [lindex [buf$bufNo getkwd CD2_2] 0] ""] != 0 } {
                  incr nouveau
               }
               if { [string compare [lindex [buf$bufNo getkwd CDELT1] 0] ""] != 0 } {
                  incr classic
               }
               if { [string compare [lindex [buf$bufNo getkwd CDELT2] 0] ""] != 0 } {
                  incr classic
               }
               if { [string compare [lindex [buf$bufNo getkwd CROTA1] 0] ""] != 0 } {
                  incr classic
               }
               if { [string compare [lindex [buf$bufNo getkwd CROTA2] 0] ""] != 0 } {
                  incr classic
               }
               if {(($calib == 1)&&($nouveau==4))||(($calib == 1)&&($classic>=3))} {
                  ::confVisu::setAvailableScale $visuNo "xy_radec"
               } else {
                  ::confVisu::setAvailableScale $visuNo "xy"
               }

               #--- je mets a jour la taille des scrollbars
               setScrollbarSize $visuNo

               #--- je mets a jour la taille du reticule
               ::confVisu::redrawCrosshair $visuNo
               ::confVisu::setMode $visuNo "image"

            } elseif { $mode == "graph" } {
               #--- j'affiche une image 1D sous forme de courbe

               #--- j'affiche le graphique
               set tkgraph [::confVisu::getGraph $visuNo]

               #--- je cree la courbe par defaut si elle n'existe pas
               if { [ $tkgraph element exists line$visuNo ] == 0 } {
                   $tkgraph element create line$visuNo -symbol none -smooth natural
               }

               #--- je recupere les mots cles
               set bufNo [getBufNo $visuNo]
               set size   [lindex [buf$bufNo getkwd NAXIS1] 1]
               set crval1 [lindex [buf$bufNo getkwd CRVAL1] 1]
               set cdelt1 [lindex [buf$bufNo getkwd CDELT1] 1]
               set crpix1 [lindex [buf$bufNo getkwd CRPIX1] 1]
               if { $crpix1 == "" } {
                  set crpix1 1
               }
               #--- je recupere le nom des unites des abcisses
               set private($visuNo,graph,xUnit) [lindex [buf$bufNo getkwd CUNIT1] 1]
               if { $private($visuNo,graph,xUnit) == "" } {
                  #--- si l'unite n'est pas précise, je choisis "pixel" par defaut
                  set private($visuNo,graph,xUnit) "pixel"
               }
               #--- je donne le nom des unites des ordonnees
               set private($visuNo,graph,yUnit) "ADU"

               #--- si l'image n'est pas calibree en longueur d'ondes
               if { $crval1 == "" } {
                  set crval1 0
               }
               if { $cdelt1 == "" } {
                  set cdelt1 1
               }

               #--- je recupere les ordonnees
               set ydata2 ""
               set abcisses ""
               for { set i 1 } { $i <= $size } { incr i } {
                  #--- je calcule les abcisses
                  lappend abcisses [expr $cdelt1 * ($i - $crpix1) + $crval1 ]
                  #--- je controle les ordonnees
                  ###set y [lindex $ydata $i]
                  set y [lindex [ buf$bufNo getpix [ list $i 1 ] ] 1]
                  if { $y == "NULL" || $y == "-1.#QNAN0" || $y == "-1.#IND00" } {
                     set y 0
                  }
                  lappend ydata2 $y
               }
               $tkgraph element configure line$visuNo -xdata $abcisses -ydata $ydata2

               #--- je supprime le zoom, au cas ou il aurait ete applique precedemement
               ::confVisu::onGraphUnzoom $visuNo

               ###$tkgraph axis configure x2 -hide true
               ###$tkgraph axis configure y2 -hide true
               ###$tkgraph configure  -plotbackground "white"

               #--- j'affiche le graphe
               ::confVisu::setMode $visuNo "graph"
               #--- je supprime les glissieres R, V et B
               ::colorRGB::cmdClose $visuNo

            } elseif { $mode == "table" } {

               #--- j'affiche une table
               set hFile ""
               set catchResult [catch {
                  #--- j'affiche la tkTable
                  ::confVisu::setMode $visuNo "table"
                  set tkTable [::confVisu::getTable $visuNo ]

                  #--- je vide la tkTable
                  $tkTable delete 0 end

                  #--- j'ajoute le nom des colonnes en titre
                  ###set colNames [$hFile info column ]
                  set columnList ""
                  foreach colName $columnNames {
                     lappend columnList 0 $colName center
                  }
                  $tkTable configure -columns $columnList

                  #--- j'ajoute le contenu des lignes
                  ###set values [$hFile get table]
                  foreach row $columnValues {
                     $tkTable insert end $row
                  }

               } ]

               if { $hFile != "" } {
                  $hFile close
               }
               #--- je supprime les glissieres R, V et B
               ::colorRGB::cmdClose $visuNo
            }
         }
         #--- j'affiche le nom du fichier
         #--- cette procedure declenche les procedures qui sont a l'ecoute du changement
         #--- de nom de fichier avec addFileNameListener
         if { $fileName != "" } {
            ::confVisu::setFileName $visuNo $fileName
         } else {
            ::confVisu::setFileName $visuNo [ getFileName $visuNo ]
         }

         #--- je mets a jour le numero du hdu
         #--- cette procedure declenche les procedures qui sont a l'ecoute du changement
         set private($visuNo,currentHduNo) $hduNo

      }
   }

   #
   # visu [l2i cuts]
   # Visualisation du buffer : Eventuellement on peut changer les seuils en passant
   # une liste de deux elements entiers par plan image, le seuil haut et le seuil bas
   # liste de 2 elements pour une image naxis 2 et de 6 elements pour une image naxis 3
   #
   # Exemple :
   # visu
   # visu {500 0}
   #
   proc visu { visuNo { cuts "autocuts" } } {
      variable private

      if { [llength $cuts] == 1 } {
         if { $cuts == "autocuts"} {
            set bufNo [visu$visuNo buf ]
            set cuts [ lrange [ buf$bufNo autocuts ] 0 1 ]
         } elseif { $cuts == "current" } {
            #--- on ne touche pas aux seuils
           # set cuts [ list [getHiCutDisplay $visuNo] [getLoCutDisplay $visuNo] ]
           # visu$visuNo cut $cuts
         } else {
            ::console::affiche_erreur "confVisu::visu inexptected value cuts = $cuts \n"
         }
      } elseif { [llength $cuts] >= 2 } {
         visu$visuNo cut $cuts
      }

      visu$visuNo clear
      ::confVisu::ComputeScaleRange $visuNo
      ::confVisu::ChangeCutsDisplay $visuNo

      #--- prise en compte de la palette prealablement choisie
      #::audace::MAJ_palette $visuNo

      #--- rafraichissement de l'affichage
      #--- La fonction audace::MAJ_palette appelle la fonction visu$visuNo pal, qui elle-meme
      #--- appelle l'equivalent de visu$visuNo disp
      #--- Il ne faut donc pas rappeler cette fonction une deuxieme fois
      while { 1 } {
         set catchResult [catch { ::audace::MAJ_palette $visuNo } msg ]
         if { $catchResult == 1 && $msg == "NO MEMORY FOR DISPLAY" } {
            #--- en cas d'erreur "NO MEMORY FOR DISPLAY", j'essaie avec un zoom inferieur
            set private($visuNo,zoom) [expr double($private($visuNo,zoom)) / 2]
            if { $private($visuNo,zoom) >= 1 } {
                set private($visuNo,zoom) [expr int($private($visuNo,zoom))]
            }
            visu$visuNo zoom $private($visuNo,zoom)
            ::console::affiche_erreur "WARNING: NO MEMORY FOR DISPLAY, visuNo=$visuNo zoom=$private($visuNo,zoom)\n"
         } else {
            break
         }
      }
   }

   #------------------------------------------------------------
   #  clear
   #    efface le contenu de la visu
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc clear { visuNo } {
      variable private

      #--- je masque la fenetre des films
      ::Movie::deleteMovieWindow $visuNo

      #--- je quitte la calibration astrometrique
      catch { ::astrometry::quit }

      #--- raz du buffer
      set bufNo [ visu$visuNo buf ]
      buf$bufNo clear
      ::confVisu::autovisu $visuNo -clear
      return
   }

   #------------------------------------------------------------
   #  setAvailableScale
   #     affiche les echelles de coordonnees autorisees
   #       "xy" :
   #
   #  parametres :
   #    visuNo: numero de la visu
   #    scales :  "xy"         coordonnes x,y uniquement
   #              "xy_radec"   coordonnes x,y  ou ra,dec
   #------------------------------------------------------------
   proc setAvailableScale { visuNo scales } {
      variable private
      global audace color

      if { $scales == "xy_radec" } {
         $private($visuNo,This).fra1.labURLX configure -fg $color(blue)
         $private($visuNo,This).fra1.labURLY configure -fg $color(blue)
        ### set private($visuNo,labcoord_type) "xy"
         bind $private($visuNo,This).fra1.labURLX <Button-1> "::confVisu::toogleCoordType $visuNo"
         bind $private($visuNo,This).fra1.labURLY <Button-1> "::confVisu::toogleCoordType $visuNo"
      } else {
         $private($visuNo,This).fra1.labURLX configure -fg $audace(color,textColor)
         $private($visuNo,This).fra1.labURLY configure -fg $audace(color,textColor)
         set private($visuNo,labcoord_type) "xy"
         #--- Annulation des bindings
         bind $private($visuNo,This).fra1.labURLX <Button-1> {}
         bind $private($visuNo,This).fra1.labURLY <Button-1> {}
      }
   }

   #------------------------------------------------------------
   #  toogleCoordType
   #     change l'echelle des coordonnees  (xy <=> radec)
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc toogleCoordType { visuNo } {
      variable private
      global caption

       if { $private($visuNo,labcoord_type) == "xy" } {
         set private($visuNo,labcoord_type) "radec"
         $private($visuNo,This).fra1.labURLX configure -text "$caption(confVisu,RA) $caption(confVisu,egale) $caption(confVisu,tiret)"
         $private($visuNo,This).fra1.labURLY configure -text "$caption(confVisu,DEC) $caption(confVisu,egale) $caption(confVisu,tiret)"
       } else {
         set private($visuNo,labcoord_type) "xy"
         $private($visuNo,This).fra1.labURLX configure -text "$caption(confVisu,X) $caption(confVisu,egale) $caption(confVisu,tiret)"
         $private($visuNo,This).fra1.labURLY configure -text "$caption(confVisu,Y) $caption(confVisu,egale) $caption(confVisu,tiret)"
       }
   }

   #------------------------------------------------------------
   #  getCanvasCenter
   #     retourne les coordonnees du centre du canvas (referentiel canvas)
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getCanvasCenter { visuNo } {
      variable private

      set box [grid bbox $private($visuNo,This).can1 0 0]
      set xScreenCenter [expr ([lindex $box 2] - [lindex $box 0])/2 ]
      set yScreenCenter [expr ([lindex $box 3] - [lindex $box 1])/2 ]

      return [::confVisu::screen2Canvas $visuNo [list $xScreenCenter $yScreenCenter]]
   }

   #------------------------------------------------------------
   #  getHiCutDisplay
   #     retourne le valeur du seuil haut
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getHiCutDisplay { visuNo } {
      variable private

      return [$private($visuNo,This).fra1.sca1 get]
   }

   #------------------------------------------------------------
   #  getLoCutDisplay
   #     retourne le valeur du seuil bas
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getLoCutDisplay { visuNo } {
      variable private

      return [$private($visuNo,This).fra1.sca2 get]
   }

   #------------------------------------------------------------
   # incrementZoom
   #    incremente les valeurs du zoom
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc incrementZoom { visuNo } {
      variable private

      if { $private($visuNo,zoom) != [ lindex $private($visuNo,zoomList) end ] } {
         set k [ lsearch $private($visuNo,zoomList) $private($visuNo,zoom) ]
         incr k
         set private($visuNo,zoom) [ lindex $private($visuNo,zoomList) $k ]
      }

      #--- j'applique le nouveau zoom
      ::confVisu::setZoom $visuNo $private($visuNo,zoom)
   }

   #------------------------------------------------------------
   # decrementZoom
   #    decremente les valeurs du zoom
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc decrementZoom { visuNo } {
      variable private

      if { $private($visuNo,zoom) != [ lindex $private($visuNo,zoomList) 0 ] } {
         set k [ lsearch $private($visuNo,zoomList) $private($visuNo,zoom) ]
         incr k "-1"
         set private($visuNo,zoom) [ lindex $private($visuNo,zoomList) $k ]
      }

      #--- j'applique le nouveau zoom
      ::confVisu::setZoom $visuNo $private($visuNo,zoom)
   }

   #------------------------------------------------------------
   #  setZoom
   #     change le zoom et rafraichit l'affichage
   #     conserve le centre de l'image au centre du canvas si possible
   #  parametres :
   #    visuNo: numero de la visu
   #    zoom  : valeur du zoom. Ce parametre est optionnel, le zoom
   #            courant est utilise s'il n'est pas reseigne.
   #  Exemple : afficher la visu 1 avec zoom = 0.5
   #    ::confVisu::setZoom 1 0.5
   #------------------------------------------------------------
   proc setZoom { visuNo { zoom "" } } {
      variable private

      #--- je modifie le zoom si une nouvelle valeur est donnee en parametre
      if { $zoom == "" } {
         #--- on prend la valeur de private($visuNo,zoom) selectionnee dans le menu
      } elseif { $zoom in $private($visuNo,zoomList) } {
         set private($visuNo,zoom) $zoom
      } else {
         ::console::affiche_erreur "confVisu::setZoom error : zoom $zoom not authorized\n"
      }
      #--- je calcule les coordonnées du centre de l'image avec l'ancien zoom
      set canvasCenterPrev [getCanvasCenter $visuNo]
      set pictureCenter [::confVisu::canvas2Picture $visuNo $canvasCenterPrev ]

      #--- je calcule la position du bord gauche et du bord haut
      set previousLeft [expr [lindex $canvasCenterPrev 0] - [lindex [$private($visuNo,hCanvas) xview] 0] * [lindex [$private($visuNo,hCanvas) cget -scrollregion ] 2] ]
      set previousTop  [expr [lindex $canvasCenterPrev 1] - [lindex [$private($visuNo,hCanvas) yview] 0] * [lindex [$private($visuNo,hCanvas) cget -scrollregion ] 3] ]

      #--- j'applique le nouveau zoom
      visu$visuNo zoom $private($visuNo,zoom)

      #--- rafraichissement de l'image avec le nouveau zoom
      visu$visuNo clear
      while { 1 } {
         set catchResult [catch { visu$visuNo disp } msg ]
         if { $catchResult == 1 && $msg == "NO MEMORY FOR DISPLAY" } {
            #--- en cas d'erreur "NO MEMORY FOR DISPLAY", j'essaie avec un zoom inferieur
            set private($visuNo,zoom) [expr double($private($visuNo,zoom)) / 2]
            if { $private($visuNo,zoom) >= 1 } {
                set private($visuNo,zoom) [expr int($private($visuNo,zoom))]
            }
            visu$visuNo zoom $private($visuNo,zoom)
            ::console::affiche_erreur "WARNING: NO MEMORY FOR DISPLAY, visuNo=$visuNo set zoom=$private($visuNo,zoom)\n"
         } else {
            break
         }
      }

      #--- je declenche les listeners
      set private($visuNo,zoomListenerFlag) ""

      #--- mise a jour du parametre scrollposition du canvas
      setScrollbarSize $visuNo

      #--- je calcule les coordonnes de l'ancien centre du canvas dans le nouveau repere
      set canvasCenter [::confVisu::picture2Canvas $visuNo $pictureCenter]

      #--- je calcule la nouvelle position du bord gauche et du haut pour garder le centre de l'image au meme endroit
      set newleft [expr [lindex $canvasCenter 0] - $previousLeft ]
      set newtop  [expr [lindex $canvasCenter 1] - $previousTop  ]

      #--- je corrige les deplacements si l'ancien centre du canvas n'est plus visible
      if { $newleft < 0 } { set newleft 0 }
      if { $newtop  < 0 } { set newtop  0 }

      #--- je centre le canvas
      set scrollRegion [$private($visuNo,hCanvas) cget -scrollregion]
      set leftRegion   [lindex $scrollRegion 0]
      set topRegion    [lindex $scrollRegion 1]
      set rightRegion  [lindex $scrollRegion 2]
      set bottomRegion [lindex $scrollRegion 3]

      if { $rightRegion != 0 } {
         $private($visuNo,hCanvas) xview moveto [ expr $newleft / ($rightRegion - $leftRegion) ]
      }

      if { $bottomRegion != 0 } {
         $private($visuNo,hCanvas) yview moveto [ expr $newtop / ($bottomRegion - $topRegion) ]
      }

      #--- je mets a jour la taille du reticule
      ::confVisu::redrawCrosshair $visuNo
   }

   #------------------------------------------------------------
   #  setMirrorX
   #     applique un miroir par rapport a l'axe des X
   #
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc setMirrorX { visuNo } {
      variable private

      #--- j'applique un miroir vertical (sur l'axe des x)
      visu$visuNo mirrorx $private($visuNo,mirror_x)
      ::confVisu::autovisu $visuNo
      #--- j'active le listener
      set private($visuNo,mirrorXListenerFlag) ""
   }

   #------------------------------------------------------------
   #  setMirrorY
   #     applique un miroir par rapport a l'axe des Y
   #
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc setMirrorY { visuNo } {
      variable private

      #--- j'applique un miroir horizontal (sur l'axe des y)
      visu$visuNo mirrory $private($visuNo,mirror_y)
      ::confVisu::autovisu $visuNo
      #--- j'active le listener
      set private($visuNo,mirrorYListenerFlag) ""

   }

   #------------------------------------------------------------
   #  setCamera
   #     memorise la camera associee a la visu
   #  parametres :
   #    visuNo  : numero de la visu
   #    camItem : instance de la camera, ou "" s'il n'y a pas de camera
   #    model   : modele de la camera (optionnel)
   #  exemple :
   #    setCamera 2 A
   #------------------------------------------------------------
   proc setCamera { visuNo camItem { model "" } } {
      variable private
      global caption

      if { [winfo exists $private($visuNo,This)] == 1} {
         if { $camItem == "" } {
            set description "$caption(confVisu,2points) $caption(confVisu,non_connecte)"
         } else {
            set camName [::confCam::getPluginProperty $camItem "name"]
            set description "$camItem $caption(confVisu,2points) $camName $model"
         }
         #--- j'affiche le nom de la camera
         $private($visuNo,This).fra1.labCam_name_labURL configure -text $description
         #--- je renseigne la dynamique de la camera
         set dynamic [ ::confCam::getPluginProperty $camItem "dynamic" ]
         ::confVisu::visuDynamix $visuNo [ lindex $dynamic 0 ] [ lindex $dynamic 1 ]
      }
      #--- je memorise le camItem associe a cette visu
      set private($visuNo,camItem) $camItem
   }

   #------------------------------------------------------------
   #  setMount
   #     associe une monture a la visu
   #  parametre :
   #    visuNo  : numero de la visu
   #------------------------------------------------------------
   proc setMount { visuNo } {
      variable private
      global audace caption color

      if { $audace(telNo) == "0" } {
         $private($visuNo,This).fra1.labTel_name_labURL configure -text "$caption(confVisu,2points) $caption(confVisu,non_connecte)" \
            -fg $color(blue)
      } else {
         $private($visuNo,This).fra1.labTel_name_labURL configure -text "$caption(confVisu,2points) [ tel$audace(telNo) name ]" \
            -fg $color(blue)
      }
   }

   #------------------------------------------------------------
   #  getCamItem
   #     retourne l'item de camera associee a la visu
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getCamItem { visuNo } {
      variable private

      #--- je teste l'existance de la variable au cas ou la visu n'existe pas
      if { [ info exists private($visuNo,camItem) ] == "1" } {
         return $private($visuNo,camItem)
      } else {
         return ""
      }
   }

   #------------------------------------------------------------
   #  getBufNo
   #     retourne le numero du buffer associe a la visu
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getBufNo { visuNo } {
      variable private

      return [visu$visuNo buf]
   }

   #------------------------------------------------------------
   #  getWindow
   #     retourne les coordonnees du rectangle de l'image visible dans la visu
   #     (refrentiel buffer)
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getWindow { visuNo } {
      variable private

      set bufNo [visu$visuNo buf]
      if { [ buf$bufNo imageready ] == "1" } {
         set windowBox [visu$visuNo window]
         if {$windowBox=="full"} {
            set x0 1
            set y0 1
            set x1 $private($visuNo,picture_w)
            set y1 $private($visuNo,picture_h)
         } else {
            set x0 [lindex $windowBox 0]
            set y0 [lindex $windowBox 1]
            set x1 [lindex $windowBox 2]
            set y1 [lindex $windowBox 3]
         }
         set result [list $x0 $y0 $x1 $y1]
      } else {
         set result [list  0 0 0 0 ]
      }
      return $result

   }

   #------------------------------------------------------------
   #  setWindow
   #     affiche une partie de l'image delimitee par private(visuNo,boxSize)
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc setWindow { visuNo } {
      variable private
      global caption

      set bufNo [visu$visuNo buf]
      if { [ buf$bufNo imageready ] == "1" } {
         if { $private($visuNo,window) == "0" } {
            visu$visuNo window full
            ::confVisu::autovisu $visuNo
         } else {
            if { $private($visuNo,boxSize) != "" } {
               visu$visuNo window $private($visuNo,boxSize)
               deleteBox $visuNo
               ::confVisu::autovisu $visuNo
               #--- je redessine le reticule
               redrawCrosshair $visuNo
            } else {
               tk_messageBox -title $caption(confVisu,attention) -type ok -message $caption(confVisu,tracer_boite)
               set private($visuNo,window) "0"
            }
         }
      } else {
         set private($visuNo,window) "0"
      }
      #--- j'active le listener
      set private($visuNo,windowListenerFlag) ""

   }

   #------------------------------------------------------------
   #  setFullScreen
   #     affiche la visu en plein ecran
   #  parametres :
   #    visuNo : numero de la visu
   #------------------------------------------------------------
   proc setFullScreen { visuNo } {
      variable private

      set directory [ file dirname $private($visuNo,lastFileName) ]
      set filename [ file tail $private($visuNo,lastFileName) ]
      set bufNo [visu$visuNo buf]
      if { [ buf$bufNo imageready ] == "1" } {
         if { $private($visuNo,fullscreen) == "1" } {
            ###if { [::Image::isAnimatedGIF "$private($visuNo,lastFileName)"] == 1 } {
            ###   #--- Ne fonctionne que pour des gif animes (type Image en dur dans le script), pas pour des videos
            ###   set private(gif_anime) "1"
            ###   ::FullScreen::showFiles $visuNo $private($visuNo,hCanvas) $directory [ list [ list $filename "Image" ] ]
            ###} else {
            ###}
            set private($visuNo,tempCrosshairState) $private($visuNo,crosshairstate)
            set private($visuNo,crosshairstate) "0"
            ::FullScreen::showBuffer $visuNo $private($visuNo,hCanvas)
         } else {
            set private($visuNo,crosshairstate) $private($visuNo,tempCrosshairState)
            ::FullScreen::closeWindow $visuNo
         }
         redrawCrosshair $visuNo
      } else {
         set private($visuNo,fullscreen) "0"
      }
   }

   #------------------------------------------------------------
   #  setScrollbarSize
   #     met a jour la taille des scrollbars
   #     si le parametre box n'est pas founi, la taille des scrollbars est determine
   #     a partir de l'image deja affichee
   #  parametres :
   #    visuNo: numero de la visu
   #    box   : coordonnee mini et maxi dans le repere image (facultatif)
   #------------------------------------------------------------
   proc setScrollbarSize { visuNo { box "" } } {
      variable private

      if { "$box" == "" } {
         set windowBox [visu$visuNo window]
         if {$windowBox=="full"} {
            set x0 1
            set y0 1
            set x1 $private($visuNo,picture_w)
            set y1 $private($visuNo,picture_h)
         } else {
            set x0 [lindex $windowBox 0]
            set y0 [lindex $windowBox 1]
            set x1 [lindex $windowBox 2]
            set y1 [lindex $windowBox 3]
         }
      } else {
         set x0 [lindex $box 0]
         set y0 [lindex $box 1]
         set x1 [lindex $box 2]
         set y1 [lindex $box 3]
      }
      #--- j'ajoute une unite en largeur et en hauteur pour que les scollbars
      #--- permettent de voir l'ensemble de l'image
      set x1 [expr $x1 + 1 ]
      set y0 [expr $y0 - 1 ]
      set coord0 [ picture2Canvas $visuNo [list $x0 $y0 ] ]
      set coord1 [ picture2Canvas $visuNo [list $x1 $y1 ] ]

      if { [lindex $coord0 0] < [lindex $coord1 0] } {
         set left  [lindex $coord0 0]
         set right [lindex $coord1 0]
      } else {
         set left  [lindex $coord1 0]
         set right [lindex $coord0 0]
      }

      #--- attention : il faut inverser y0 et y1 car l'origine de l'axe y est en haut dans le repere canvas
      if { [lindex $coord0 1] < [lindex $coord1 1] } {
         set top    [lindex $coord0 1]
         set bottom [lindex $coord1 1]
      } else {
         set top    [lindex $coord1 1]
         set bottom [lindex $coord0 1]
      }

      #--- j'elimine les erreur d'arrondi quand zoom <1
      if { $left < 0 } { set left 0 }
      if { $top < 0 }  { set top  0 }

      $private($visuNo,hCanvas) configure -scrollregion [list $left $top $right $bottom]
   }

   #------------------------------------------------------------
   #  setVideo
   #     active/desactive le mode video pour une camera pour afficher
   #     des films AVI
   #
   #  parametres :
   #    visuNo: numero de la visu
   #    state : 1= active le mode video, 0=desactive le mode video
   #------------------------------------------------------------
   proc setVideo { visuNo state } {
      variable private

      set imageNo [visu$visuNo image]
      set camNo   [::confCam::getCamNo $private($visuNo,camItem) ]

      if { $state == 1 } {
         #--- je supprime l'image precedente
         buf[visu$visuNo buf] clear
         #--- j'active le mode video
         visu$visuNo mode video

         #--- je connecte la sortie de la camera a l'image
         set result [ catch {
            if { [image type imagevisu$visuNo ] == "video" } {
               #--- je recupere le handle de l'image de la visu
               set windowHandle [imagevisu$visuNo  cget -owner]
               #--- je connecte le flux de la camera avec le handle l'image de la visu
               cam$camNo startvideoview  $visuNo $windowHandle
               #--- je configure le zoom de l'image video
               imagevisu$visuNo configure -zoom $private($visuNo,zoom)
            } else {
               error "Error connect webcam to imagevisu$visuNo : [image type imagevisu$visuNo ] wrong image type, must be video"
            }
         } ]
         if { $result == 1 } {
            #--- je restaure le mode photo
            visu$visuNo mode photo
            #--- j'active le reglage des seuils
            $private($visuNo,This).fra1.sca1 configure -state normal
            $private($visuNo,This).fra1.sca2 configure -state normal
            ::console::affiche_erreur "$::errorInfo\n"
            tk_messageBox -message "$::errorInfo. See console" -icon error
            return
         }

         #--- je desactive le reglage des seuils
         $private($visuNo,This).fra1.sca1 configure -state disabled
         $private($visuNo,This).fra1.sca2 configure -state disabled

      } else {
         #--- je deconnecte la sortie de la camera
         set result [ catch { cam$camNo stopvideoview $visuNo } msg ]
         #--- je desactive le mode video
         visu$visuNo mode photo
         #--- j'active le reglage des seuils
         $private($visuNo,This).fra1.sca1 configure -state normal
         $private($visuNo,This).fra1.sca2 configure -state normal
      }

      if { $result != 1 } {
         ::confVisu::autovisu $visuNo
      }

      return $result
   }

   #------------------------------------------------------------
   # addCameraListener
   #    ajoute une procedure a appeler si on change de camera
   #  parametres :
   #    visuNo: numero de la visu
   #    cmd : commande TCL a lancer quand la camera associee a la visu change
   #------------------------------------------------------------
   proc addCameraListener { visuNo cmd } {
      trace add variable ::confVisu::private($visuNo,camItem) write $cmd
   }

   #------------------------------------------------------------
   # removeCameraListener
   #    supprime une procedure a appeler si on change de camera
   #  parametres :
   #    visuNo: numero de la visu
   #    cmd : commande TCL a lancer quand la camera associee a la visu change
   #------------------------------------------------------------
   proc removeCameraListener { visuNo cmd } {
      trace remove variable ::confVisu::private($visuNo,camItem) write $cmd
   }

   #------------------------------------------------------------
   # addHduListener
   #   ajoute une procedure a appeler si on change de Hdu
   # parametres :
   #    visuNo: numero de la visu
   #    cmd : commande TCL a lancer
   #------------------------------------------------------------
   proc addHduListener { visuNo cmd } {
      trace add variable ::confVisu::private($visuNo,currentHduNo) write $cmd
   }

   #------------------------------------------------------------
   # removeHduListener
   #   supprime une procedure a appeler si on change de HDU
   # parametres :
   #    visuNo: numero de la visu
   #    cmd : commande TCL a lancer
   #------------------------------------------------------------
   proc removeHduListener { visuNo cmd } {
      trace remove variable ::confVisu::private($visuNo,currentHduNo) write $cmd
   }
   #------------------------------------------------------------
   # addFileNameListener
   #   ajoute une procedure a appeler si on change de nom de fichier image
   # parametres :
   #    visuNo: numero de la visu
   #    cmd : commande TCL a lancer quand le fichier change
   #------------------------------------------------------------
   proc addFileNameListener { visuNo cmd } {
      trace add variable ::confVisu::private($visuNo,lastFileName) write $cmd
   }

   #------------------------------------------------------------
   # removeFileNameListener
   #   supprime une procedure a appeler si on change de nom de fichier image
   # parametres :
   #    visuNo: numero de la visu
   #    cmd : commande TCL a lancer quand le fichier change
   #------------------------------------------------------------
   proc removeFileNameListener { visuNo cmd } {
      trace remove variable ::confVisu::private($visuNo,lastFileName) write $cmd
   }

   #------------------------------------------------------------
   # addMirrorListener
   #    ajoute une procedure a appeler si on change de mirroir
   # parametres :
   #    visuNo: numero de la visu
   #    cmd : commande TCL a lancer quand le zoom change
   #------------------------------------------------------------
   proc addMirrorListener { visuNo cmd } {
      trace add variable ::confVisu::private($visuNo,mirrorXListenerFlag) write $cmd
      trace add variable ::confVisu::private($visuNo,mirrorYListenerFlag) write $cmd
   }

   #------------------------------------------------------------
   # removeMirrorListener
   #   supprime une procedure a appeler si on change de mirroir
   # parametres :
   #    visuNo: numero de la visu
   #    cmd : commande TCL a lancer quand le fichier change
   #------------------------------------------------------------
   proc removeMirrorListener { visuNo cmd } {
      trace remove variable ::confVisu::private($visuNo,mirrorXListenerFlag) write $cmd
      trace remove variable ::confVisu::private($visuNo,mirrorYListenerFlag) write $cmd
   }

   #------------------------------------------------------------
   # addSubWindowListener
   #    ajoute une procedure a appeler si on change le fenetrage
   # parametres :
   #    visuNo: numero de la visu
   #    cmd : commande TCL a lancer quand le zoom change
   #------------------------------------------------------------
   proc addSubWindowListener { visuNo cmd } {
      trace add variable ::confVisu::private($visuNo,windowListenerFlag) write $cmd
   }

   #------------------------------------------------------------
   # removeSubWindowListener
   #   supprime une procedure a appeler si on change le fenetrage
   # parametres :
   #    visuNo: numero de la visu
   #    cmd : commande TCL a lancer quand le zoom change
   #------------------------------------------------------------
   proc removeSubWindowListener { visuNo cmd } {
      trace remove variable ::confVisu::private($visuNo,windowListenerFlag) write $cmd
   }

   #------------------------------------------------------------
   # addZoomListener
   #    ajoute une procedure a appeler si on change de zoom
   # parametres :
   #    visuNo: numero de la visu
   #    cmd : commande TCL a lancer quand le zoom change
   #------------------------------------------------------------
   proc addZoomListener { visuNo cmd } {
      trace add variable ::confVisu::private($visuNo,zoomListenerFlag) write $cmd

   }

   #------------------------------------------------------------
   # removeZoomListener
   #   supprime une procedure a appeler si on change de camera
   # parametres :
   #    visuNo: numero de la visu
   #    cmd : commande TCL a lancer quand le zoom change
   #------------------------------------------------------------
   proc removeZoomListener { visuNo cmd } {
      trace remove variable ::confVisu::private($visuNo,zoomListenerFlag) write $cmd
   }

   #------------------------------------------------------------
   #  stopTool
   #     arrete l'outil
   #     si le nom de l'outil n'est pas precise, arrete l'outil courant dans le panneau de la visu
   #     si l'outil est en cours de traitement, il n'est pas arrete
   #  @param  visuNo    numero de la visu
   #  @param  toolName  nom de l'outil a arreter
   #  @return 0= arret OK -1= arret non autorise (le plugin est en train de faire un traitement)
   #------------------------------------------------------------
   proc stopTool { visuNo { toolName ""} } {
      variable private
      if { $toolName == "" } {
         if { $private($visuNo,currentTool) != "" } {
            #--- si l'outil n'est pas precise , je choisis d'arreter l'outil courant
            #--- (pour compatibilite ascendante avec les anciennes versions)
            set toolName $private($visuNo,currentTool)
         } else {
            #--- s'il n'y a pas d'outil courant , je ne fais rien
            return 0
         }
      }
      if { $toolName != "" && $toolName != "::"} {
         #--- j'arrete l'outil
         set result [ $toolName\::stopTool $visuNo ]
         if { $result != "-1" } {
            #--- je masque le panneau de l'outil si c'est l'outil courant de la visu
            if { $private($visuNo,currentTool) == $toolName } {
               grid forget $private($visuNo,This).tool
            }
         }
         return $result
      } else {
         return 0
      }
   }

   #------------------------------------------------------------
   #  createPluginInstance
   #     cree une instance de l'outil
   #  @param  visuNo    numero de la visu
   #  @param  toolName  nom de l'outil a arreter
   #  @return void
   #------------------------------------------------------------
   proc createPluginInstance { visuNo toolName } {
      variable private

      if { $toolName != "" && $toolName != "::" } {
         #--- je verifie que le plugin n'a pas deja une instance cree
         if { [lsearch -exact $private($visuNo,pluginInstanceList) $toolName ] == -1 } {
            #--- je cree une instance du plugin
            set catchResult [catch {
               namespace inscope $toolName createPluginInstance $private($visuNo,This).tool $visuNo
            }]
            if { $catchResult == 1 } {
               ::console::affiche_erreur "$::errorInfo\n"
               tk_messageBox -message "$::errorInfo. See console" -icon error
               return
            }
            #--- j'ajoute cette intance dans la liste
            lappend private($visuNo,pluginInstanceList) $toolName
         } else {
            #--- rien a faire car il existe deja une instance du plugin dans cette visu
         }
      }
      return ""
   }

   #------------------------------------------------------------
   #  deletePluginInstance
   #     supprime l'instance du plugin
   #  @param  visuNo    numero de la visu
   #  @param  toolName  nom du plugin a supprimer
   #  @return void
   #------------------------------------------------------------
   proc deletePluginInstance { visuNo toolName } {
      variable private

      #--- j'arrete l'outil si ce n'est pas deja fait
      stopTool $visuNo $toolName
      #--- je mets a jour la variable currentTool si c'est l'outil courant dans le panneau de la visu
      if { $private($visuNo,currentTool) == $toolName } {
         set private($visuNo,currentTool) ""
      }

      #--- je supprime l'instance du plugin
      namespace inscope $toolName deletePluginInstance $visuNo

      #--- je supprime le plugin de la liste pluginInstanceList
      set index [lsearch -exact $private($visuNo,pluginInstanceList) $toolName]
      if { $index != -1 } {
          set private($visuNo,pluginInstanceList) [lreplace $private($visuNo,pluginInstanceList) $index $index]
      }
      return ""
   }

   #------------------------------------------------------------
   #  selectTool
   #     arrete le plugin courant si le nouveau plugin n'a pas la prop display=window"
   #     demarre le nouveau plugin
   #  parametres :
   #    visuNo: numero de la visu
   #    toolName : nom du plugin a lancer
   #  Remarque:
   #    si toolName="", alors le plugin courant est arrete. Aucun autre plugin n'est pas demarre.
   #------------------------------------------------------------
   proc selectTool { visuNo toolName } {
      variable private

      #--- j'arrete le plugin deja present
      set stopResult ""
      if { "$private($visuNo,currentTool)" != "" } {
         #--- Cela veut dire qu'il y a deja un plugin selectionne
         if { $toolName != "" && $toolName != "::"} {
            if { [$toolName\::getPluginProperty "display" ] != "window"
               && [$private($visuNo,currentTool)::getPluginProperty "display" ] != "window" } {
               #--- Cela veut dire que l'utilisateur selectionne un nouveau plugin
               #--- j'arrete le plugin courant
               set stopResult [stopTool $visuNo $private($visuNo,currentTool) ]
            }
         } else {
            #--- Cela veut dire que l'utilisateur veut arreter le plugin courant
            #--- j'arrete le plugin
            set stopResult [stopTool $visuNo $private($visuNo,currentTool) ]
         }
      }

      if { $stopResult == "-1" } {
         tk_messageBox -title "$::caption(confVisu,attention)" -icon error \
          -message [format $::caption(confVisu,fermeture_outil_impossible) [ [ ::confVisu::getTool $visuNo ]::getPluginTitle ] ]
         return
      }

      if { $toolName != "" && $toolName != "::" } {
         #--- je cree l'instance du plugin
         createPluginInstance $visuNo $toolName
         #--- je demarre le plugin
         namespace inscope $toolName startTool $visuNo

         #--- je memorise le nom du plugin en cours d'execution
         if { [$toolName\::getPluginProperty "display" ] != "window" } {
            #--- j'affiche le plugin dans la fenetre principale
            grid $private($visuNo,This).tool -row 0 -column 0 -rowspan 2 -sticky ns
            #--- je memorise le nom du plugin
            set private($visuNo,currentTool) $toolName
         }
      } else {
         set private($visuNo,currentTool) ""
      }
   }

   #------------------------------------------------------------
   #  getBase
   #     retourne le chemin de la toplevel de la visu
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getBase { visuNo } {
      variable private

      #--- je teste l'existance de la variable au cas ou la visu n'existe pas
      if { [ info exists private($visuNo,This) ] == "1" } {
         return $private($visuNo,This)
      } else {
         error "Visu$visuNo does not exit."
      }
   }

   #------------------------------------------------------------
   #  getFileName
   #     retourne le nom du fichier courant
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getFileName { visuNo } {
      variable private

      #--- je supprime le suffixe du HDU s'il est present
      set hduSuffix [string first ";" $private($visuNo,lastFileName)]
      if { $hduSuffix != -1 } {
         set fileName [string range $private($visuNo,lastFileName) 0 [expr $hduSuffix -1]]
      } else {
         set fileName $private($visuNo,lastFileName)
      }
      return $fileName
   }

   #------------------------------------------------------------
   #  getTool
   #     retourne  le nom du plugin courant
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getTool { visuNo } {
      variable private

      return [ string trimleft $private($visuNo,currentTool) "::" ]
   }

   #------------------------------------------------------------
   #  getZoom
   #     retourne  la valeur du zoom
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc getZoom { visuNo } {
      variable private

      return $private($visuNo,zoom)
   }

   #------------------------------------------------------------
   #  createToplevel
   #     cree une fentetre toplevel avec le canvas et la frame de seuils
   #     le numero de visu est copie dans son attribut "class"
   #  parametres :
   #     visuNo  : numero de la visu associee
   #     This    : chemin de la toplevel
   #  retour
   #
   #------------------------------------------------------------
   proc createToplevel { visuNo This } {
      global audace caption conf

      toplevel $This
      wm geometry $This $conf(audace,visu$visuNo,wmgeometry)
      wm maxsize $This [winfo screenwidth .] [winfo screenheight .]
      wm minsize $This 320 240
      wm resizable $This 1 1
      wm deiconify $This
      wm title $This "$caption(audace,titre) (visu$visuNo)"
      wm protocol $This WM_DELETE_WINDOW "::confVisu::close $visuNo"
      update
   }

   #------------------------------------------------------------
   #  createDialog
   #     cree une fentetre toplevel avec le canvas et la frame de seuils
   #
   #  parametres :
   #     visuNo  : numero de la visu associee
   #     This    : chemin de la toplevel contenant la dialog
   #  retour
   #     null
   #------------------------------------------------------------
   proc createDialog { visuNo This } {
      variable private
      global audace caption color conf

      #---- frame de la barre d'outils
      frame $This.bar -borderwidth 0
      createToolBar $visuNo

      #---- frame des outils
      frame $This.tool -borderwidth 0

      #--- frame du status (et des seuils)
      frame $This.fra1 -borderwidth 2 -cursor arrow -relief groove

         button $This.fra1.but_seuils_auto -text "$caption(confVisu,seuil_auto)" \
            -command "::confVisu::onCutLabelLeftClick $visuNo" -width 5
         grid configure $This.fra1.but_seuils_auto -column 0 -row 0 -rowspan 2 -sticky we \
            -in $This.fra1 -padx 5

         button $This.fra1.but_config_glissieres -text "$caption(confVisu,boite_seuil)" \
            -command "::seuilWindow::run $visuNo"
         grid configure $This.fra1.but_config_glissieres -column 1 -row 0 -rowspan 2 -sticky {} \
            -in $This.fra1 -padx 5

         scale $This.fra1.sca1 -orient horizontal -to 32767 -from -32768 -length 150 \
            -borderwidth 1 -showvalue 0 -width 10 -sliderlength 20 \
            -background $audace(color,cursor_blue) -activebackground $audace(color,cursor_blue_actif) \
            -relief raised
         grid configure $This.fra1.sca1 -column 2 -row 0 -sticky we -in $This.fra1 -pady 2

         scale $This.fra1.sca2 -orient horizontal -to 32767 -from -32768 -length 150 \
            -borderwidth 1 -showvalue 0 -width 10 -sliderlength 20 \
            -background $audace(color,cursor_blue) -activebackground $audace(color,cursor_blue_actif) \
            -relief raised
         grid configure $This.fra1.sca2 -column 2 -row 1 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.lab1 -width 10 -text "$caption(confVisu,seuil_haut)"
         grid configure $This.fra1.lab1 -column 3 -row 0 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.lab2 -width 10 -text "$caption(confVisu,seuil_bas)"
         grid configure $This.fra1.lab2 -column 3 -row 1 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.labURLX -width 16 -anchor w \
            -text "$caption(confVisu,X) $caption(confVisu,egale) $caption(confVisu,tiret)"
         grid configure $This.fra1.labURLX -column 4 -row 0 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.labURLY -width 16 -anchor w \
            -text "$caption(confVisu,Y) $caption(confVisu,egale) $caption(confVisu,tiret)"
         grid configure $This.fra1.labURLY -column 4 -row 1 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.labI -width 19 -anchor w \
            -text "$caption(confVisu,I) $caption(confVisu,egale) $caption(confVisu,tiret)"
         grid configure $This.fra1.labI -column 5 -row 0 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.labTime -width 19 -anchor w \
            -textvariable "audace(tu,format,dmyhmsint)"
         grid configure $This.fra1.labTime -column 5 -row 1 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.labCam_labURL -anchor w \
            -text "$caption(audace,menu,camera)" -fg $color(blue)
         grid configure $This.fra1.labCam_labURL -column 6 -row 0 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.labCam_name_labURL -anchor w \
            -text "$caption(confVisu,2points) $caption(confVisu,non_connecte)" -fg $color(blue)
         grid configure $This.fra1.labCam_name_labURL -column 7 -row 0 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.labTel_labURL -anchor w \
            -text "$caption(audace,menu,monture)" -fg $color(blue)
         grid configure $This.fra1.labTel_labURL -column 6 -row 1 -sticky we -in $This.fra1 -pady 2

         label $This.fra1.labTel_name_labURL -anchor w \
            -text "$caption(confVisu,2points) $caption(confVisu,non_connecte)" -fg $color(blue)
         grid configure $This.fra1.labTel_name_labURL -column 7 -row 1 -sticky we -in $This.fra1 -pady 2

         grid columnconfigure $This.fra1 5 -weight 1

      #--- Canvas de dessin de l'image
      Scrolled_Canvas $This.can1 -borderwidth 0 -relief flat \
         -width 300 -height 200 -scrollregion {0 0 0 0} -cursor crosshair
      $This.can1.canvas configure -borderwidth 0
      $This.can1.canvas configure -relief flat

      #--- creation du graphe
      ###createGraph $visuNo
      createTable $visuNo

      grid $This.tool -row 0 -column 0 -rowspan 2 -sticky ns
      grid $This.bar  -row 0 -column 1 -sticky ew
      grid $This.can1 -row 1 -column 1 -sticky nsew
      grid $This.fra1 -row 2 -column 0 -columnspan 2 -sticky ew

      grid rowconfig    $This 0 -weight 0
      grid rowconfig    $This 1 -weight 1
      grid rowconfig    $This 2 -weight 0
      grid columnconfig $This 0 -weight 0
      grid columnconfig $This 1 -weight 1

      #--- je masque la barre d'outils par defaut
      grid forget $This.bar

   }

   #------------------------------------------------------------
   #  createBindDialog
   #     cree les bind de la fenetre
   #
   #  parametres :
   #     visuNo : numero de la visu
   #------------------------------------------------------------
   proc createBindDialog { visuNo } {
      variable private

      update
      set This $private($visuNo,This)
      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- bind des labels des seuils
      bind $This.fra1.lab1 <ButtonPress-1> "::confVisu::onCutLabelLeftClick   $visuNo"
      bind $This.fra1.lab2 <ButtonPress-1> "::confVisu::onCutLabelLeftClick   $visuNo"
      bind $This.fra1.lab1 <ButtonPress-3> "::confVisu::onCutLabelRightClick  $visuNo"
      bind $This.fra1.lab2 <ButtonPress-3> "::confVisu::onCutLabelRightClick  $visuNo"

      #--- bind du label des intensites
      bind $This.fra1.labI <ButtonPress-1> "::confVisu::changeDisplayIntensity $visuNo"

      #--- bind des glissieres
      $This.fra1.sca1 configure -command "::confVisu::onHiCutCommand $visuNo"
      $This.fra1.sca2 configure -command "::confVisu::onLoCutCommand $visuNo"
      bind $This.fra1.sca1 <ButtonRelease> "::confVisu::onCutScaleRelease $visuNo"
      bind $This.fra1.sca2 <ButtonRelease> "::confVisu::onCutScaleRelease $visuNo"

      #--- bind du canvas avec la souris, j'active les valeurs par defaut
      ###createBindCanvas $visuNo <ButtonPress-1>   "default"
      ###createBindCanvas $visuNo <ButtonRelease-1> "default"
      ###createBindCanvas $visuNo <B1-Motion>       "default"
      ###createBindCanvas $visuNo <Motion>          "default"
      ###createBindCanvas $visuNo <ButtonPress-3>   "default"

      #--- bind de l'item "display" canvas avec la souris
      $private($visuNo,hCanvas) bind display <ButtonPress-1>   "::confVisu::onPressButton1 $visuNo %x %y"
      $private($visuNo,hCanvas) bind display <ButtonRelease-1> "::confVisu::onReleaseButton1 $visuNo %x %y"
      $private($visuNo,hCanvas) bind display <B1-Motion>       "::confVisu::onMotionButton1 $visuNo %x %y"
      $private($visuNo,hCanvas) bind display <Motion>          "::confVisu::onMotionMouse $visuNo %x %y"

      #--- bind pour l'ouverture de la boite de configuration des cameras
      bind $This.fra1.labCam_labURL <ButtonPress-1> {
         ::confCam::run
     }
      bind $This.fra1.labCam_name_labURL <ButtonPress-1> {
         ::confCam::run
      }

      #--- bind pour l'ouverture de la boite de configuration des montures
      bind $This.fra1.labTel_labURL <ButtonPress-1> {
         ::confTel::run
      }
      bind $This.fra1.labTel_name_labURL <ButtonPress-1> {
         ::confTel::run
      }
   }

   #------------------------------------------------------------
   #  deleteBindDialog
   #     supprime les bind de la fenetre
   #
   #  parametres :
   #     visuNo : numero de la visu
   #------------------------------------------------------------
   proc deleteBindDialog { visuNo } {
      variable private

      set This $private($visuNo,This)

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- bind des labels des seuils
      bind $This.fra1.lab1 <ButtonPress-1> ""
      bind $This.fra1.lab2 <ButtonPress-1> ""
      bind $This.fra1.lab1 <ButtonPress-3> ""
      bind $This.fra1.lab2 <ButtonPress-3> ""

      #--- Raccourci pour affichage du reticule
      bind $This <Key-C> ""
      bind $This <Key-c> ""

      #--- bind des glissieres
      bind $This.fra1.sca1 <ButtonRelease> ""
      bind $This.fra1.sca2 <ButtonRelease> ""

      #--- bind du canvas avec la souris
      ###createBindCanvas $visuNo <ButtonPress-1>   ""
      ###createBindCanvas $visuNo <ButtonRelease-1> ""
      ###createBindCanvas $visuNo <B1-Motion>       ""
      ###createBindCanvas $visuNo <Motion>          ""
      ###createBindCanvas $visuNo <ButtonPress-3>   ""

      #--- bind de l'item "display" canvas avec la souris
      $private($visuNo,hCanvas) bind display <ButtonPress-1>   ""
      $private($visuNo,hCanvas) bind display <ButtonRelease-1> ""
      $private($visuNo,hCanvas) bind display <B1-Motion>       ""
      $private($visuNo,hCanvas) bind display <Motion>          ""
      $private($visuNo,hCanvas) bind display <Button-3>   ""

      #--- bind pour l'ouverture de la boite de configuration des cameras
      bind $This.fra1.labCam_name_labURL <ButtonPress-1> ""
      bind $This.fra1.labCam_labURL <ButtonPress-1>      ""

      #--- bind pour l'ouverture de la boite de configuration des montures
      bind $This.fra1.labTel_name_labURL <ButtonPress-1> ""
      bind $This.fra1.labTel_labURL <ButtonPress-1>      ""

   }

   #------------------------------------------------------------
   #  createBindCanvas
   #     associe une sequence du canvas avec une commande
   #
   #  parametres :
   #     visuNo : numero de la visu
   #     sequence : evenement associe
   #     command  : command a executer si command="default"
   #                alors c'est la commande par defaut qui est associe
   #------------------------------------------------------------
   proc createBindCanvas { visuNo sequence { command "default" } } {
      variable private

      if { "$command" == "default" } {
         bind $private($visuNo,hCanvas) $sequence   ""
      }  else {
         bind $private($visuNo,hCanvas) $sequence $command
      }
   }

   #------------------------------------------------------------
   #  addBindDisplay
   #     ajoute une commande sur l'item "display" du canvas
   #
   #  @param   visuNo : numero de la visu
   #  @param   sequence : evenement associe
   #  @param   command  : command a executer
   #  @return  rien
   #------------------------------------------------------------
   proc addBindDisplay { visuNo sequence command } {
      variable private

      set commandList [split [$private($visuNo,hCanvas) bind display $sequence ] "\n"]
      set commandList [linsert $commandList 0 $command]
      $private($visuNo,hCanvas) bind display $sequence [join $commandList "\n"]
   }

   #------------------------------------------------------------
   #  removeBindDisplay
   #     supprime une commande de l'item "display" du canvas
   #
   #  @param   visuNo : numero de la visu
   #  @param   sequence : evenement associe
   #  @param   command  : command a supprimer
   #  @return  rien
   #------------------------------------------------------------
   proc removeBindDisplay { visuNo sequence command } {
      variable private

      set commandList [split [$private($visuNo,hCanvas) bind display $sequence ] "\n"]
      set commandIndex [lsearch $commandList $command]
      if { $commandIndex != -1 } {
         set commandList [lreplace $commandList $commandIndex $commandIndex]
         $private($visuNo,hCanvas) bind display $sequence [join $commandList "\n"]
      }
   }

   proc createMenu { visuNo } {
      variable private
      global audace caption conf panneau

      #--- Creation du menu contextuel
      ::confVisu::createPopupMenuButton3 $visuNo

      if { $visuNo == "1" } {

         #--- Initialisation
         set This                  $audace(base)
         set private($visuNo,menu) $This.menubar

         Menu_Setup $visuNo $private($visuNo,menu)

         Menu           $visuNo "$caption(audace,menu,file)"
         Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(audace,menu,charger)..." \
            "::audace::charger $visuNo" \
            -compound left -image $::confVisu::private(openIcon)
         Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(audace,menu,enregistrer)" \
            "::audace::enregistrer $visuNo" \
            -compound left -image $::confVisu::private(saveIcon)
         Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(audace,menu,enregistrer_sous)..." \
            "::audace::enregistrer_sous $visuNo" \
            -compound left -image $::confVisu::private(saveAsIcon)

         Menu_Separator $visuNo "$caption(audace,menu,file)"
         Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(audace,menu,entete)" "::keyword::header $visuNo"

         Menu_Separator $visuNo "$caption(audace,menu,file)"
         #--- Affichage des plugins de type tool et de fonction file du menu deroulant Fichier
         ::confChoixOutil::displayPlugins $visuNo file

         Menu_Separator $visuNo "$caption(audace,menu,file)"
         Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(audace,menu,nouveau_script)..." "::audace::newScript"
         Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(audace,menu,editer_script)..." "::audace::editScript"
         Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(audace,menu,lancer_script)..." "::audace::runScript"

         Menu_Separator $visuNo "$caption(audace,menu,file)"
         Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(audace,menu,quitter)" "::audace::quitter"

         Menu           $visuNo "$caption(audace,menu,display)"
         Menu_Command   $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,nouvelle_visu)" "::confVisu::create" \
            -compound left -image $::confVisu::private(newVisuIcon)

         Menu_Separator $visuNo "$caption(audace,menu,display)"
         Menu_Command   $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,pas_outil)" "::audace::pasOutil $visuNo"
         Menu_Command   $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,efface_image)" "::confVisu::clear $visuNo"

         Menu_Separator $visuNo "$caption(audace,menu,display)"
         Menu_Command_Radiobutton $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,palette_grise)" \
            "1" "conf(visu_palette,visu$visuNo,mode)" "::audace::MAJ_palette $visuNo"
         Menu_Command_Radiobutton $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,palette_inverse)" \
            "2" "conf(visu_palette,visu$visuNo,mode)" "::audace::MAJ_palette $visuNo"
         Menu_Command_Radiobutton $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,palette_iris)" \
            "3" "conf(visu_palette,visu$visuNo,mode)" "::audace::MAJ_palette $visuNo"
         Menu_Command_Radiobutton $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,palette_arc_en_ciel)" \
            "4" "conf(visu_palette,visu$visuNo,mode)" "::audace::MAJ_palette $visuNo"

         Menu_Separator $visuNo "$caption(audace,menu,display)"
         Menu_Cascade   $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,fcttransfert_titre)"
         Menu_Command_Radiobutton $visuNo "$caption(audace,menu,fcttransfert_titre)" "$caption(audace,menu,fcttransfert_lin)" \
            "1" "conf(fonction_transfert,visu$visuNo,mode)" "::audace::fonction_transfert $visuNo"
         Menu_Command_Radiobutton $visuNo "$caption(audace,menu,fcttransfert_titre)" "$caption(audace,menu,fcttransfert_log)" \
            "2" "conf(fonction_transfert,visu$visuNo,mode)" "::audace::fonction_transfert $visuNo"
         Menu_Command_Radiobutton $visuNo "$caption(audace,menu,fcttransfert_titre)" "$caption(audace,menu,fcttransfert_exp)" \
            "3" "conf(fonction_transfert,visu$visuNo,mode)" "::audace::fonction_transfert $visuNo"
         Menu_Command_Radiobutton $visuNo "$caption(audace,menu,fcttransfert_titre)" "$caption(audace,menu,fcttransfert_arc)" \
            "4" "conf(fonction_transfert,visu$visuNo,mode)" "::audace::fonction_transfert $visuNo"

         Menu_Separator $visuNo "$caption(audace,menu,display)"
         Menu_Command   $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,seuils)..." \
            "::seuilWindow::run $visuNo"
         Menu_Command   $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,balance_rvb)..." \
            "::seuilCouleur::run $visuNo"

         Menu_Separator $visuNo "$caption(audace,menu,display)"
         foreach zoom $private($visuNo,zoomList) {
            Menu_Command_Radiobutton $visuNo "$caption(audace,menu,display)" \
               "$caption(audace,menu,zoom) x $zoom" "$zoom" \
               "::confVisu::private($visuNo,zoom)" "::confVisu::setZoom $visuNo"
         }

         Menu_Separator $visuNo "$caption(audace,menu,display)"
         Menu_Check     $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,plein_ecran)" \
            "::confVisu::private($visuNo,fullscreen)" "::confVisu::setFullScreen $visuNo"

         Menu_Separator $visuNo "$caption(audace,menu,display)"
         Menu_Check     $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,miroir_x)" \
            "::confVisu::private($visuNo,mirror_x)" "::confVisu::setMirrorX $visuNo" \
            -compound left -image $::confVisu::private(mirrorVIcon)
         Menu_Check     $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,miroir_y)" \
            "::confVisu::private($visuNo,mirror_y)" "::confVisu::setMirrorY $visuNo" \
            -compound left -image $::confVisu::private(mirrorHIcon)
         Menu_Check     $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,window)" \
            "::confVisu::private($visuNo,window)" "::confVisu::setWindow $visuNo"

         Menu_Separator $visuNo "$caption(audace,menu,display)"
         Menu_Command_Radiobutton $visuNo "$caption(audace,menu,display)" \
            "$caption(audace,menu,vision_nocturne)" "1" "conf(confcolor,menu_night_vision)" \
            "::confColor::switchDayNight ; \
               if { [ winfo exists $audace(base).selectColor ] } { \
                  destroy $audace(base).selectColor \
                  ::confColor::run $visuNo \
               } \
            "

         Menu_Separator $visuNo "$caption(audace,menu,display)"
         #--- Affichage des plugins de type tool et de fonction display du menu deroulant Affichage
         ::confChoixOutil::displayPlugins $visuNo display
         Menu_Command   $visuNo "$caption(audace,menu,display)" "[ ::Crosshair::getLabel ]..." "::Crosshair::run $visuNo"

         Menu           $visuNo "$caption(audace,menu,preprocess)"
         Menu_Cascade   $visuNo "$caption(audace,menu,preprocess)" "$caption(audace,menu,transform)"
         set liste_des_fonctions [::prtr::TRANSFORMFunctions 0]
         for { set i 0} { $i < [llength $liste_des_fonctions] } {incr i} {
            set function [lindex $liste_des_fonctions $i]
            if { $function == $caption(audace,menu,miroir_x) } {
               Menu_Command $visuNo "$caption(audace,menu,transform)" "$function..." "::prtr::run \"$function\" " \
                  -compound left -image $::confVisu::private(mirrorVIcon)
            } elseif { $function == $caption(audace,menu,miroir_y) } {
               Menu_Command $visuNo "$caption(audace,menu,transform)" "$function..." "::prtr::run \"$function\" " \
                  -compound left -image $::confVisu::private(mirrorHIcon)
            } else {
               Menu_Command $visuNo "$caption(audace,menu,transform)" "$function..." "::prtr::run \"$function\" "
            }
         }

         Menu_Separator $visuNo "$caption(audace,menu,preprocess)"
         Menu_Cascade   $visuNo "$caption(audace,menu,preprocess)" "$caption(audace,menu,arithm)"
         set liste_des_fonctions [::prtr::ARITHMFunctions 0]
         for { set i 0} { $i < [llength $liste_des_fonctions] } {incr i} {
            set function [lindex $liste_des_fonctions $i]
            Menu_Command $visuNo "$caption(audace,menu,arithm)" "$function..." "::prtr::run \"$function\" "
         }

         Menu_Separator $visuNo "$caption(audace,menu,preprocess)"
         Menu_Cascade   $visuNo "$caption(audace,menu,preprocess)" "$caption(audace,menu,improve)"
         set liste_des_fonctions [::prtr::IMPROVEFunctions 0]
         for { set i 0} { $i < [llength $liste_des_fonctions] } {incr i} {
            set function [lindex $liste_des_fonctions $i]
            Menu_Command $visuNo "$caption(audace,menu,improve)" "$function..." "::prtr::run \"$function\" "
         }
         Menu_Command   $visuNo "$caption(audace,menu,improve)" "$caption(audace,menu,scar)" "scar $visuNo"

         Menu_Separator $visuNo "$caption(audace,menu,preprocess)"
         Menu_Cascade   $visuNo "$caption(audace,menu,preprocess)" "$caption(audace,menu,pile)"
         set liste_des_fonctions [::prtr::PILEFunctions 0]
         for { set i 0} { $i < [llength $liste_des_fonctions] } {incr i} {
            set function [lindex $liste_des_fonctions $i]
            Menu_Command $visuNo "$caption(audace,menu,pile)" "$function..." "::prtr::run \"$function\" "
         }

         Menu_Separator $visuNo "$caption(audace,menu,preprocess)"
         Menu_Cascade   $visuNo "$caption(audace,menu,preprocess)" "$caption(audace,menu,convertir)"
         set liste_des_fonctions [::conv2::CONVERSIONFunctions 0]
         for { set i 0} { $i < [llength $liste_des_fonctions] } {incr i} {
            set function [lindex $liste_des_fonctions $i]
            Menu_Command $visuNo "$caption(audace,menu,convertir)" "$function..." "::conv2::run \"$function\" "
         }

         Menu_Separator $visuNo "$caption(audace,menu,preprocess)"
         Menu_Cascade   $visuNo "$caption(audace,menu,preprocess)" "$caption(audace,menu,faire_image)"
         Menu_Command $visuNo "$caption(audace,menu,faire_image)" "$caption(audace,menu,faire_offset)..." \
            { ::faireImageRef::run "faire_offset" "$audace(base).faireImageRef" }
         Menu_Command $visuNo "$caption(audace,menu,faire_image)" "$caption(audace,menu,faire_dark)..." \
            { ::faireImageRef::run "faire_dark" "$audace(base).faireImageRef" }
         Menu_Command $visuNo "$caption(audace,menu,faire_image)" "$caption(audace,menu,faire_flat_field)..." \
            { ::faireImageRef::run "faire_flat_field" "$audace(base).faireImageRef" }
         Menu_Command $visuNo "$caption(audace,menu,faire_image)" "$caption(audace,menu,faire_pretraitee)..." \
            { ::faireImageRef::run "pretraitement" "$audace(base).faireImageRef" }

         Menu_Separator $visuNo "$caption(audace,menu,preprocess)"
         #--- Affichage des plugins de type tool et de fonction preprocess du menu deroulant Pretraitement
         ::confChoixOutil::displayPlugins $visuNo preprocess

         Menu_Separator $visuNo "$caption(audace,menu,preprocess)"
         Menu_Command   $visuNo "$caption(audace,menu,preprocess)" "$caption(audace,menu,recentrer)..." \
            { ::traiteWindow::run "serie_recentrer" "$audace(base).traiteWindow" }

         Menu           $visuNo "$caption(audace,menu,traitement)"
         Menu_Cascade   $visuNo "$caption(audace,menu,traitement)" "$caption(audace,menu,filtrer)"
         Menu_Command   $visuNo "$caption(audace,menu,filtrer)" "$caption(audace,menu,masque_flou)..." \
            { ::traiteFilters::run "$caption(audace,menu,masque_flou)" "$audace(base).traiteFilters" }
         Menu_Command   $visuNo "$caption(audace,menu,filtrer)" "$caption(audace,menu,filtre_passe-bas)..." \
            { ::traiteFilters::run "$caption(audace,menu,filtre_passe-bas)" "$audace(base).traiteFilters" }
         Menu_Command   $visuNo "$caption(audace,menu,filtrer)" "$caption(audace,menu,filtre_passe-haut)..." \
            { ::traiteFilters::run "$caption(audace,menu,filtre_passe-haut)" "$audace(base).traiteFilters" }
         Menu_Command   $visuNo "$caption(audace,menu,filtrer)" "$caption(audace,menu,filtre_median)..." \
            { ::traiteFilters::run "$caption(audace,menu,filtre_median)" "$audace(base).traiteFilters" }
         Menu_Command   $visuNo "$caption(audace,menu,filtrer)" "$caption(audace,menu,filtre_minimum)..." \
            { ::traiteFilters::run "$caption(audace,menu,filtre_minimum)" "$audace(base).traiteFilters" }
         Menu_Command   $visuNo "$caption(audace,menu,filtrer)" "$caption(audace,menu,filtre_maximum)..." \
            { ::traiteFilters::run "$caption(audace,menu,filtre_maximum)" "$audace(base).traiteFilters" }

         Menu_Separator $visuNo "$caption(audace,menu,traitement)"
         Menu_Cascade   $visuNo "$caption(audace,menu,traitement)" "$caption(audace,menu,amel)"
         set liste_des_fonctions [::prtr::AMELFunctions 0]
         for { set i 0} { $i < [llength $liste_des_fonctions] } {incr i} {
            set function [lindex $liste_des_fonctions $i]
            Menu_Command $visuNo "$caption(audace,menu,amel)" "$function..." "::prtr::run \"$function\" "
         }

         Menu_Separator $visuNo "$caption(audace,menu,traitement)"
         Menu_Cascade   $visuNo "$caption(audace,menu,traitement)" "$caption(audace,menu,convoluer)"
         Menu_Command   $visuNo "$caption(audace,menu,convoluer)" "$caption(audace,menu,tfd)..." \
            { ::traiteFilters::run "$caption(audace,menu,tfd)" "$audace(base).traiteFilters" }
         Menu_Command   $visuNo "$caption(audace,menu,convoluer)" "$caption(audace,menu,tfdi)..." \
            { ::traiteFilters::run "$caption(audace,menu,tfdi)" "$audace(base).traiteFilters" }
         Menu_Command   $visuNo "$caption(audace,menu,convoluer)" "$caption(audace,menu,acorr)..." \
            { ::traiteFilters::run "$caption(audace,menu,acorr)" "$audace(base).traiteFilters" }
         Menu_Command   $visuNo "$caption(audace,menu,convoluer)" "$caption(audace,menu,icorr)..." \
            { ::traiteFilters::run "$caption(audace,menu,icorr)" "$audace(base).traiteFilters" }
         Menu_Command   $visuNo "$caption(audace,menu,convoluer)" "$caption(audace,menu,convolution)..." \
             { ::traiteFilters::run "$caption(audace,menu,convolution)" "$audace(base).traiteFilters" }

         Menu           $visuNo "$caption(audace,menu,analysis)"
         Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,histo)" "::audace::Histo $visuNo"
         Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,coupe)" "::sectiongraph::init $visuNo"
         Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,statwin)" "statwin $visuNo"
         Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,fwhm)" "fwhm $visuNo"
         Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,fitgauss)" "fitgauss $visuNo"
         Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,centro)" "center $visuNo"
         Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,phot)" "photom $visuNo"
         Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,subfitgauss)" "subfitgauss $visuNo"

         Menu_Separator $visuNo "$caption(audace,menu,analysis)"
         Menu_Cascade   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,extract)"
         set liste_des_fonctions [::prtr::EXTRACTFunctions 0]
         for { set i 0} { $i < [llength $liste_des_fonctions] } {incr i} {
            set function [lindex $liste_des_fonctions $i]
            Menu_Command $visuNo "$caption(audace,menu,extract)" "$function..." "::prtr::run \"$function\" "
         }

         Menu_Separator $visuNo "$caption(audace,menu,analysis)"
         #--- Affichage des plugins de type tool et de fonction analysis du menu deroulant Analyse
         ::confChoixOutil::displayPlugins $visuNo analysis

         Menu_Separator $visuNo "$caption(audace,menu,analysis)"
         Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,carte)" \
            "::carte::showMapFromBuffer buf$audace(bufNo)"

         Menu           $visuNo "$caption(audace,menu,acquisition)"
         #--- Affichage des plugins de type tool et de fonction acquisition du menu deroulant Camera
         ::confChoixOutil::displayPlugin $visuNo acquisition

         Menu           $visuNo "$caption(audace,menu,aiming)"
         #--- Affichage des plugins de type tool et de fonction aiming du menu deroulant Telescope
         ::confChoixOutil::displayPlugin $visuNo aiming

         Menu           $visuNo "$caption(audace,menu,setup)"
         Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,langue)..." \
            { ::confLangue::run "$audace(base).confLangue" }
         Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,repertoire)..." \
            { ::cwdWindow::run "$audace(base).cwdWindow" }
         Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,logiciels_externes)..." \
            { ::confEditScript::run "$audace(base).confEditScript" }
         Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,temps)..." \
            { ::confTemps::run "$audace(base).confTemps" }
         Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,position)..." \
            { ::confPosObs::run "$audace(base).confPosObs" }
         Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,fichier_image)..." \
            { ::confFichierIma::run "$audace(base).confFichierIma" }
         Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,alarme)..." \
            { ::confAlarmeFinPose::run "$audace(base).confAlarmeFinPose" }
         Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,type_fenetre)..." \
            { ::confTypeFenetre::run "$audace(base).confTypeFenetre" }
         Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,apparence)..." \
            "::confColor::run $visuNo"
         Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,police)..." \
            "::confFont::run $visuNo"

         Menu_Separator $visuNo "$caption(audace,menu,setup)"
         Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,camera)..." \
            "::confCam::run"
         Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,monture)..." \
            "::confTel::run"
         Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,liaison)..." \
            "::confLink::run"
         Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,optique)..." \
            "::confOptic::run $visuNo"
         Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,equipement)..." \
            "::confEqt::run"

         Menu_Separator $visuNo "$caption(audace,menu,setup)"
         Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,raquette)..." \
            "::confPad::run"
         Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,carte)..." \
            "::confCat::run"

         Menu_Separator $visuNo "$caption(audace,menu,setup)"
         Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,choix_outils)..." \
            "::confChoixOutil::run $audace(base).confChoixOutil $visuNo"
         #--- Affichage des plugins de type tool et de fonction setup du menu deroulant Configuration
         ::confChoixOutil::displayPlugins $visuNo setup

         Menu_Separator $visuNo "$caption(audace,menu,setup)"
         Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,sauve_config)" \
            "::audace::enregistrerConfiguration $visuNo"

         Menu           $visuNo "$caption(audace,menu,aide)"
         Menu_Command   $visuNo "$caption(audace,menu,aide)" "$caption(audace,menu,sommaire)" \
            "::audace::showMain" \
            -compound left -image $::confVisu::private(contentsIcon)
         Menu_Command   $visuNo "$caption(audace,menu,aide)" "$caption(audace,menu,menu)" \
            "::audace::showMenus"
         Menu_Command   $visuNo "$caption(audace,menu,aide)" "$caption(audace,menu,fonctions)" \
            "::audace::showFunctions"
         Menu_Command   $visuNo "$caption(audace,menu,aide)" "$caption(audace,menu,tutorial)" \
            "::audace::Lance_Tutorial"
         Menu_Cascade   $visuNo "$caption(audace,menu,aide)" "$caption(audace,menu,site_audela)"
         Menu_Command   $visuNo "$caption(audace,menu,site_audela)" "$caption(audace,menu,site_internet)" \
            { set filename "$caption(en-tete,a_propos_de_site)" ; ::audace::Lance_Site_htm $filename }
         Menu_Command   $visuNo "$caption(audace,menu,site_audela)" "$caption(audace,menu,site_dd)..." \
            "::audace::editSiteWebAudeLA"
         Menu_Command   $visuNo "$caption(audace,menu,aide)" "$caption(audace,menu,notice_pdf)..." \
            "::audace::editNotice_pdf"
         Menu_Command   $visuNo "$caption(audace,menu,aide)" "$caption(audace,menu,a_propos_de)" \
            { ::confVersion::run "$audace(base).confVersion" } \
            -compound left -image $::confVisu::private(aboutIcon)

         #--- Exemple d'association d'une touche du clavier avec une option d'un menu deroulant ou un outil
         Menu_Bind $visuNo $This <Control-o> "$caption(audace,menu,file)" "$caption(audace,menu,charger)..." \
            "$caption(touche,controle,O)"
         bind $audace(Console) <Control-o> "focus $audace(base) ; ::audace::charger $visuNo"
         Menu_Bind $visuNo $This <Control-s> "$caption(audace,menu,file)" "$caption(audace,menu,enregistrer)" \
            "$caption(touche,controle,S)"
         bind $audace(Console) <Control-s> "focus $audace(base) ; ::audace::enregistrer"
         Menu_Bind $visuNo $This <Control-q> "$caption(audace,menu,file)" "$caption(audace,menu,quitter)" \
            "$caption(touche,controle,Q)"
         bind $audace(Console) <Control-q> "focus $audace(base) ; ::audace::quitter"
         Menu_Bind $visuNo $This <F12>       "$caption(audace,menu,display)" "$caption(audace,menu,pas_outil)" \
            "$caption(touche,F12)"
         bind $audace(Console) <F12> "focus $audace(base) ; ::audace::pasOutil $visuNo"

      } else {

         #--- Initialisation
         set This                  $private($visuNo,This)
         set private($visuNo,menu) $This.menubar

         Menu_Setup $visuNo $private($visuNo,menu)

         Menu           $visuNo "$caption(audace,menu,file)"
         Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(audace,menu,charger)..." \
            "::audace::charger $visuNo" \
            -compound left -image $::confVisu::private(openIcon)
         Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(audace,menu,enregistrer)" \
            "::audace::enregistrer $visuNo" \
            -compound left -image $::confVisu::private(saveIcon)
         Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(audace,menu,enregistrer_sous)..." \
            "::audace::enregistrer_sous $visuNo" \
            -compound left -image $::confVisu::private(saveAsIcon)

         Menu_Separator $visuNo "$caption(audace,menu,file)"
         Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(audace,menu,entete)" "::keyword::header $visuNo"

         #--- Affichage des plugins multivisu de type tool et de fonction file du menu deroulant Fichier
         Menu_Separator $visuNo "$caption(audace,menu,file)"
         set liste ""
         foreach m [array names panneau menu_name,*] {
            lappend liste [list "$panneau($m) " $m]
         }
         set liste [lsort -dictionary $liste]
         foreach m $liste {
            set m [lindex $m 1]
            scan "$m" "menu_name,%s" pluginName
            if { [ ::$pluginName\::getPluginProperty multivisu ] == "1" } {
               if { [ ::$pluginName\::getPluginProperty function ] == "file" } {
                  Menu_Command $visuNo "$caption(audace,menu,file)" "$panneau($m)" "::confVisu::selectTool $visuNo ::$pluginName"
               }
            }
         }

         Menu_Separator $visuNo "$caption(audace,menu,file)"
         Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(confVisu,fermer)" \
            "::confVisu::close $visuNo" \
            -compound left -image $::confVisu::private(closeIcon)

         Menu           $visuNo "$caption(audace,menu,display)"
         Menu_Command   $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,nouvelle_visu)" "::confVisu::create" \
            -compound left -image $::confVisu::private(newVisuIcon)

         Menu_Separator $visuNo "$caption(audace,menu,display)"
         Menu_Command   $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,pas_outil)" "::audace::pasOutil $visuNo"
         Menu_Command   $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,efface_image)" "::confVisu::deleteImage $visuNo"

         Menu_Separator $visuNo "$caption(audace,menu,display)"
         Menu_Command_Radiobutton $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,palette_grise)" \
            "1" "conf(visu_palette,visu$visuNo,mode)" "::audace::MAJ_palette $visuNo"
         Menu_Command_Radiobutton $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,palette_inverse)" \
            "2" "conf(visu_palette,visu$visuNo,mode)" "::audace::MAJ_palette $visuNo"
         Menu_Command_Radiobutton $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,palette_iris)" \
            "3" "conf(visu_palette,visu$visuNo,mode)" "::audace::MAJ_palette $visuNo"
         Menu_Command_Radiobutton $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,palette_arc_en_ciel)" \
            "4" "conf(visu_palette,visu$visuNo,mode)" "::audace::MAJ_palette $visuNo"

         Menu_Separator $visuNo "$caption(audace,menu,display)"
         Menu_Cascade   $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,fcttransfert_titre)"
         Menu_Command_Radiobutton $visuNo "$caption(audace,menu,fcttransfert_titre)" "$caption(audace,menu,fcttransfert_lin)" \
            "1" "conf(fonction_transfert,visu$visuNo,mode)" "::audace::fonction_transfert $visuNo"
         Menu_Command_Radiobutton $visuNo "$caption(audace,menu,fcttransfert_titre)" "$caption(audace,menu,fcttransfert_log)" \
            "2" "conf(fonction_transfert,visu$visuNo,mode)" "::audace::fonction_transfert $visuNo"
         Menu_Command_Radiobutton $visuNo "$caption(audace,menu,fcttransfert_titre)" "$caption(audace,menu,fcttransfert_exp)" \
            "3" "conf(fonction_transfert,visu$visuNo,mode)" "::audace::fonction_transfert $visuNo"
         Menu_Command_Radiobutton $visuNo "$caption(audace,menu,fcttransfert_titre)" "$caption(audace,menu,fcttransfert_arc)" \
            "4" "conf(fonction_transfert,visu$visuNo,mode)" "::audace::fonction_transfert $visuNo"

         Menu_Separator $visuNo "$caption(audace,menu,display)"
         Menu_Command   $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,seuils)..." \
            "::seuilWindow::run $visuNo"
         Menu_Command   $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,balance_rvb)..." \
            "::seuilCouleur::run $visuNo"

         Menu_Separator $visuNo "$caption(audace,menu,display)"
         foreach zoom $private($visuNo,zoomList) {
            Menu_Command_Radiobutton $visuNo "$caption(audace,menu,display)" \
               "$caption(audace,menu,zoom) x $zoom" "$zoom" \
               "::confVisu::private($visuNo,zoom)" "::confVisu::setZoom $visuNo"
         }

         Menu_Separator $visuNo "$caption(audace,menu,display)"
         Menu_Check     $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,plein_ecran)" \
            "::confVisu::private($visuNo,fullscreen)" "::confVisu::setFullScreen $visuNo"

         Menu_Separator $visuNo "$caption(audace,menu,display)"
         Menu_Check     $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,miroir_x)" \
            "::confVisu::private($visuNo,mirror_x)" "::confVisu::setMirrorX $visuNo" \
            -compound left -image $::confVisu::private(mirrorVIcon)
         Menu_Check     $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,miroir_y)" \
            "::confVisu::private($visuNo,mirror_y)" "::confVisu::setMirrorY $visuNo" \
            -compound left -image $::confVisu::private(mirrorHIcon)
         Menu_Check     $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,window)" \
            "::confVisu::private($visuNo,window)" "::confVisu::setWindow $visuNo"

         Menu_Separator $visuNo "$caption(audace,menu,display)"
         Menu_Command_Radiobutton $visuNo "$caption(audace,menu,display)" \
            "$caption(audace,menu,vision_nocturne)" "1" "conf(confcolor,menu_night_vision)" \
            "::confColor::switchDayNight ; \
               if { [ winfo exists $audace(base).selectColor ] } { \
                  destroy $audace(base).selectColor \
                  ::confColor::run $visuNo \
               } \
            "

         Menu_Separator $visuNo "$caption(audace,menu,display)"
         Menu_Command   $visuNo "$caption(audace,menu,display)" "[::Crosshair::getLabel]..." \
            "::Crosshair::run $visuNo"

         Menu           $visuNo "$caption(audace,menu,analysis)"
         Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,histo)" "::audace::Histo $visuNo"
         Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,coupe)" "::sectiongraph::init $visuNo"
         Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,statwin)" "statwin $visuNo"
         Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,fwhm)" "fwhm $visuNo"
         Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,fitgauss)" "fitgauss $visuNo"
         Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,centro)" "center $visuNo"
         Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,phot)" "photom $visuNo"
         Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,subfitgauss)" "subfitgauss $visuNo"

         #--- Lancement automatique du dernier plugin charge
         set firstTool ""
         if { [ info exists ::conf(tool,visu$visuNo,currentNamespace) ] } {
            set firstTool $::conf(tool,visu$visuNo,currentNamespace)
            ::confVisu::selectTool $visuNo ::$firstTool
         }

         Menu           $visuNo "$caption(audace,menu,acquisition)"
         #--- Affichage des plugins multivisu de type tool et de fonction acquisition du menu deroulant Camera
         foreach m $liste {
            set m [lindex $m 1]
            scan "$m" "menu_name,%s" pluginName
            if { [ ::$pluginName\::getPluginProperty multivisu ] == "1" } {
               #--- Lancement automatique du premier plugin
               if { $firstTool == "" } {
                  set firstTool $pluginName
                  ::confVisu::selectTool $visuNo ::$firstTool
               }
               if { [ ::$pluginName\::getPluginProperty function ] == "acquisition" } {
                  Menu_Command $visuNo "$caption(audace,menu,acquisition)" "$panneau($m)" "::confVisu::selectTool $visuNo ::$pluginName"
               }
            }
         }

         Menu           $visuNo "$caption(audace,menu,aiming)"
         #--- Affichage des plugins multivisu de type tool et de fonction aiming du menu deroulant Telescope
         foreach m $liste {
            set m [lindex $m 1]
            scan "$m" "menu_name,%s" pluginName
            if { [ ::$pluginName\::getPluginProperty multivisu ] == "1" } {
               if { [ ::$pluginName\::getPluginProperty function ] == "aiming" } {
                  Menu_Command $visuNo "$caption(audace,menu,aiming)" "$panneau($m)" "::confVisu::selectTool $visuNo ::$pluginName"
               }
            }
         }

      }

   }

   proc refreshMenu { visuNo } {
      variable private
      global audace caption conf panneau

      #--- Rafraichissement des menus de la visu principale (visuNo = 1)
      #--- Je supprime toutes les entrees du menu Fichier
      Menu_Delete $visuNo "$caption(audace,menu,file)" entries
      #--- Rafraichissement du menu Fichier
      Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(audace,menu,charger)..." \
         "::audace::charger $visuNo" \
         -compound left -image $::confVisu::private(openIcon)
      Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(audace,menu,enregistrer)" \
         "::audace::enregistrer $visuNo" \
         -compound left -image $::confVisu::private(saveIcon)
      Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(audace,menu,enregistrer_sous)..." \
         "::audace::enregistrer_sous $visuNo" \
         -compound left -image $::confVisu::private(saveAsIcon)
      Menu_Separator $visuNo "$caption(audace,menu,file)"
      Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(audace,menu,entete)" \
         "::keyword::header $visuNo"
      Menu_Separator $visuNo "$caption(audace,menu,file)"
      #--- Affichage des plugins de type tool et de fonction file du menu deroulant Fichier
      ::confChoixOutil::displayPlugins $visuNo file
      Menu_Separator $visuNo "$caption(audace,menu,file)"
      Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(audace,menu,nouveau_script)..." \
         "::audace::newScript"
      Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(audace,menu,editer_script)..." \
         "::audace::editScript"
      Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(audace,menu,lancer_script)..." \
         "::audace::runScript"
      Menu_Separator $visuNo "$caption(audace,menu,file)"
      Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(audace,menu,quitter)" \
         "::audace::quitter"

      #--- Je commence par supprimer le menu cascade du menu Affichage
      Menu_Delete $visuNo "$caption(audace,menu,fcttransfert_titre)" all
      #--- Je supprime toutes les entrees du menu Affichage
      Menu_Delete $visuNo "$caption(audace,menu,display)" entries
      #--- Rafraichissement du menu Affichage
      Menu_Command   $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,nouvelle_visu)" "::confVisu::create" \
         -compound left -image $::confVisu::private(newVisuIcon)
      Menu_Separator $visuNo "$caption(audace,menu,display)"
      Menu_Command   $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,pas_outil)" "::audace::pasOutil $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,efface_image)" "::confVisu::deleteImage"
      Menu_Separator $visuNo "$caption(audace,menu,display)"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,palette_grise)" \
         "1" "conf(visu_palette,visu$visuNo,mode)" "::audace::MAJ_palette $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,palette_inverse)" \
         "2" "conf(visu_palette,visu$visuNo,mode)" "::audace::MAJ_palette $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,palette_iris)" \
         "3" "conf(visu_palette,visu$visuNo,mode)" "::audace::MAJ_palette $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,palette_arc_en_ciel)" \
         "4" "conf(visu_palette,visu$visuNo,mode)" "::audace::MAJ_palette $visuNo"
      Menu_Separator $visuNo "$caption(audace,menu,display)"
      Menu_Cascade   $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,fcttransfert_titre)"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,fcttransfert_titre)" "$caption(audace,menu,fcttransfert_lin)" \
         "1" "conf(fonction_transfert,visu$visuNo,mode)" "::audace::fonction_transfert $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,fcttransfert_titre)" "$caption(audace,menu,fcttransfert_log)" \
         "2" "conf(fonction_transfert,visu$visuNo,mode)" "::audace::fonction_transfert $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,fcttransfert_titre)" "$caption(audace,menu,fcttransfert_exp)" \
         "3" "conf(fonction_transfert,visu$visuNo,mode)" "::audace::fonction_transfert $visuNo"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,fcttransfert_titre)" "$caption(audace,menu,fcttransfert_arc)" \
         "4" "conf(fonction_transfert,visu$visuNo,mode)" "::audace::fonction_transfert $visuNo"
      Menu_Separator $visuNo "$caption(audace,menu,display)"
      Menu_Command   $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,seuils)..." \
         "::seuilWindow::run $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,balance_rvb)..." \
         "::seuilCouleur::run $visuNo"
      Menu_Separator $visuNo "$caption(audace,menu,display)"
         foreach zoom $::confVisu::private($visuNo,zoomList) {
            Menu_Command_Radiobutton $visuNo "$caption(audace,menu,display)" \
               "$caption(audace,menu,zoom) x $zoom" "$zoom" \
               "::confVisu::private($visuNo,zoom)" "::confVisu::setZoom $visuNo"
         }
      Menu_Separator $visuNo "$caption(audace,menu,display)"
      Menu_Check     $visuNo "$caption(audace,menu,display)" \
         "$caption(audace,menu,plein_ecran)" \
         "::confVisu::private($visuNo,fullscreen)" "::confVisu::setFullScreen $visuNo"
      Menu_Separator $visuNo "$caption(audace,menu,display)"
      Menu_Check     $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,miroir_x)" \
         "::confVisu::private($visuNo,mirror_x)" "::confVisu::setMirrorX $visuNo" \
         -compound left -image $::confVisu::private(mirrorVIcon)
      Menu_Check     $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,miroir_y)" \
         "::confVisu::private($visuNo,mirror_y)" "::confVisu::setMirrorY $visuNo" \
         -compound left -image $::confVisu::private(mirrorHIcon)
      Menu_Check     $visuNo "$caption(audace,menu,display)" "$caption(audace,menu,window)" \
         "::confVisu::private($visuNo,window)" "::confVisu::setWindow $visuNo"
      Menu_Separator $visuNo "$caption(audace,menu,display)"
      Menu_Command_Radiobutton $visuNo "$caption(audace,menu,display)" \
         "$caption(audace,menu,vision_nocturne)" "1" "conf(confcolor,menu_night_vision)" \
         "::confColor::switchDayNight ; \
            if { [ winfo exists $audace(base).selectColor ] } { \
               destroy $audace(base).selectColor \
               ::confColor::run $visuNo \
            } \
         "
      Menu_Separator $visuNo "$caption(audace,menu,display)"
      #--- Affichage des plugins de type tool et de fonction display du menu deroulant Affichage
      ::confChoixOutil::displayPlugins $visuNo display
      Menu_Command   $visuNo "$caption(audace,menu,display)" "[ ::Crosshair::getLabel ]..." "::Crosshair::run $visuNo"

      #--- Je commence par supprimer les menus cascade du menu Pretraitement
      Menu_Delete $visuNo "$caption(audace,menu,transform)" all
      Menu_Delete $visuNo "$caption(audace,menu,arithm)" all
      Menu_Delete $visuNo "$caption(audace,menu,improve)" all
      Menu_Delete $visuNo "$caption(audace,menu,pile)" all
      Menu_Delete $visuNo "$caption(audace,menu,convertir)" all
      Menu_Delete $visuNo "$caption(audace,menu,faire_image)" all
      #--- Je supprime toutes les entrees du menu Pretraitement
      Menu_Delete $visuNo "$caption(audace,menu,preprocess)" entries
      #--- Rafraichissement du menu Pretraitement
      Menu_Cascade   $visuNo "$caption(audace,menu,preprocess)" "$caption(audace,menu,transform)"
      set liste_des_fonctions [::prtr::TRANSFORMFunctions 0]
      for { set i 0} { $i < [llength $liste_des_fonctions] } {incr i} {
         set function [lindex $liste_des_fonctions $i]
         if { $function == $caption(audace,menu,miroir_x) } {
            Menu_Command $visuNo "$caption(audace,menu,transform)" "$function..." "::prtr::run \"$function\" " \
               -compound left -image $::confVisu::private(mirrorVIcon)
         } elseif { $function == $caption(audace,menu,miroir_y) } {
            Menu_Command $visuNo "$caption(audace,menu,transform)" "$function..." "::prtr::run \"$function\" " \
               -compound left -image $::confVisu::private(mirrorHIcon)
         } else {
            Menu_Command $visuNo "$caption(audace,menu,transform)" "$function..." "::prtr::run \"$function\" "
         }
      }
      Menu_Separator $visuNo "$caption(audace,menu,preprocess)"
      Menu_Cascade   $visuNo "$caption(audace,menu,preprocess)" "$caption(audace,menu,arithm)"
      set liste_des_fonctions [::prtr::ARITHMFunctions 0]
      for { set i 0} { $i < [llength $liste_des_fonctions] } {incr i} {
         set function [lindex $liste_des_fonctions $i]
         Menu_Command $visuNo "$caption(audace,menu,arithm)" "$function..." "::prtr::run \"$function\" "
      }
      Menu_Separator $visuNo "$caption(audace,menu,preprocess)"
      Menu_Cascade   $visuNo "$caption(audace,menu,preprocess)" "$caption(audace,menu,improve)"
      set liste_des_fonctions [::prtr::IMPROVEFunctions 0]
      for { set i 0} { $i < [llength $liste_des_fonctions] } {incr i} {
         set function [lindex $liste_des_fonctions $i]
         Menu_Command $visuNo "$caption(audace,menu,improve)" "$function..." "::prtr::run \"$function\" "
      }
      Menu_Command   $visuNo "$caption(audace,menu,improve)" "$caption(audace,menu,scar)" "scar $visuNo"
      Menu_Separator $visuNo "$caption(audace,menu,preprocess)"
      Menu_Cascade   $visuNo "$caption(audace,menu,preprocess)" "$caption(audace,menu,pile)"
      set liste_des_fonctions [::prtr::PILEFunctions 0]
      for { set i 0} { $i < [llength $liste_des_fonctions] } {incr i} {
         set function [lindex $liste_des_fonctions $i]
         Menu_Command $visuNo "$caption(audace,menu,pile)" "$function..." "::prtr::run \"$function\" "
      }
      Menu_Separator $visuNo "$caption(audace,menu,preprocess)"
      Menu_Cascade   $visuNo "$caption(audace,menu,preprocess)" "$caption(audace,menu,convertir)"
      set liste_des_fonctions [::conv2::CONVERSIONFunctions 0]
      for { set i 0} { $i < [llength $liste_des_fonctions] } {incr i} {
         set function [lindex $liste_des_fonctions $i]
         Menu_Command $visuNo "$caption(audace,menu,convertir)" "$function..." "::conv2::run \"$function\" "
      }
      Menu_Separator $visuNo "$caption(audace,menu,preprocess)"
      Menu_Cascade   $visuNo "$caption(audace,menu,preprocess)" "$caption(audace,menu,faire_image)"
      Menu_Command $visuNo "$caption(audace,menu,faire_image)" "$caption(audace,menu,faire_offset)..." \
         { ::faireImageRef::run "faire_offset" "$audace(base).faireImageRef" }
      Menu_Command $visuNo "$caption(audace,menu,faire_image)" "$caption(audace,menu,faire_dark)..." \
         { ::faireImageRef::run "faire_dark" "$audace(base).faireImageRef" }
      Menu_Command $visuNo "$caption(audace,menu,faire_image)" "$caption(audace,menu,faire_flat_field)..." \
         { ::faireImageRef::run "faire_flat_field" "$audace(base).faireImageRef" }
      Menu_Command $visuNo "$caption(audace,menu,faire_image)" "$caption(audace,menu,faire_pretraitee)..." \
         { ::faireImageRef::run "pretraitement" "$audace(base).faireImageRef" }
      Menu_Separator $visuNo "$caption(audace,menu,preprocess)"
      #--- Affichage des plugins de type tool et de fonction preprocess du menu deroulant Pretraitement
      ::confChoixOutil::displayPlugins $visuNo preprocess
      Menu_Separator $visuNo "$caption(audace,menu,preprocess)"
      Menu_Command   $visuNo "$caption(audace,menu,preprocess)" "$caption(audace,menu,recentrer)..." \
         { ::traiteWindow::run "serie_recentrer" "$audace(base).traiteWindow" }

      #--- Je commence par supprimer les menus cascade du menu Analyse
      Menu_Delete $visuNo "$caption(audace,menu,extract)" all
      #--- Je supprime toutes les entrees du menu Analyse
      Menu_Delete $visuNo "$caption(audace,menu,analysis)" entries
      #--- Rafraichissement du menu Analyse
      Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,histo)" \
         "::audace::Histo $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,coupe)" \
         "::sectiongraph::init $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,statwin)" \
         "statwin $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,fwhm)" \
         "fwhm $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,fitgauss)" \
         "fitgauss $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,centro)" \
         "center $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,phot)" \
         "photom $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,subfitgauss)" \
         "subfitgauss $visuNo"
      Menu_Separator $visuNo "$caption(audace,menu,analysis)"
      Menu_Cascade   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,extract)"
      set liste_des_fonctions [::prtr::EXTRACTFunctions 0]
      for { set i 0} { $i < [llength $liste_des_fonctions] } {incr i} {
         set function [lindex $liste_des_fonctions $i]
         Menu_Command $visuNo "$caption(audace,menu,extract)" "$function..." "::prtr::run \"$function\" "
      }
      Menu_Separator $visuNo "$caption(audace,menu,analysis)"
      #--- Affichage des plugins de type tool et de fonction file du menu deroulant Analyse
      ::confChoixOutil::displayPlugins $visuNo analysis
      Menu_Separator $visuNo "$caption(audace,menu,analysis)"
      Menu_Command   $visuNo "$caption(audace,menu,analysis)" "$caption(audace,menu,carte)" \
         "::carte::showMapFromBuffer buf$audace(bufNo)"

      #--- Je supprime toutes les entrees du menu Camera
      Menu_Delete $visuNo "$caption(audace,menu,acquisition)" entries
      #--- Rafraichissement du menu Camera
      #--- Affichage des plugins de type tool du menu deroulant Camera
      ::confChoixOutil::displayPlugin $visuNo acquisition

      #--- Je supprime toutes les entrees du menu Telescope
      Menu_Delete $visuNo "$caption(audace,menu,aiming)" entries
      #--- Rafraichissement du menu Telescope
      #--- Affichage des plugins de type tool du menu deroulant Telescope
      ::confChoixOutil::displayPlugin $visuNo aiming

      #--- Je supprime toutes les entrees du menu Configuration
      Menu_Delete $visuNo "$caption(audace,menu,setup)" entries
      #--- Rafraichissement du menu Configuration
      Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,langue)..." \
         { ::confLangue::run "$audace(base).confLangue" }
      Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,repertoire)..." \
         { ::cwdWindow::run "$audace(base).cwdWindow" }
      Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,logiciels_externes)..." \
         { ::confEditScript::run "$audace(base).confEditScript" }
      Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,temps)..." \
         { ::confTemps::run "$audace(base).confTemps" }
      Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,position)..." \
         { ::confPosObs::run "$audace(base).confPosObs" }
      Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,fichier_image)..." \
         { ::confFichierIma::run "$audace(base).confFichierIma" }
      Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,alarme)..." \
         { ::confAlarmeFinPose::run "$audace(base).confAlarmeFinPose" }
      Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,type_fenetre)..." \
         { ::confTypeFenetre::run "$audace(base).confTypeFenetre" }
      Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,apparence)..." \
         "::confColor::run $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,police)..." \
         "::confFont::run $visuNo"
      Menu_Separator $visuNo "$caption(audace,menu,setup)"
      Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,camera)..." \
         "::confCam::run"
      Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,monture)..." \
         "::confTel::run"
      Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,liaison)..." \
         "::confLink::run"
      Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,optique)..." \
         "::confOptic::run $visuNo"
      Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,equipement)..." \
         "::confEqt::run"
      Menu_Separator $visuNo "$caption(audace,menu,setup)"
      Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,raquette)..." \
         "::confPad::run"
      Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,carte)..." \
         "::confCat::run"
      Menu_Separator $visuNo "$caption(audace,menu,setup)"
      Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,choix_outils)..." \
         "::confChoixOutil::run $audace(base).confChoixOutil $visuNo"
      #--- Affichage des plugins de type tool et de fonction setup du menu deroulant Configuration
      ::confChoixOutil::displayPlugins $visuNo setup
      Menu_Separator $visuNo "$caption(audace,menu,setup)"
      Menu_Command   $visuNo "$caption(audace,menu,setup)" "$caption(audace,menu,sauve_config)" \
         "::audace::enregistrerConfiguration $visuNo"

      #---
      set This "$audace(base)"
      Menu_Bind $visuNo $This <Control-o> "$caption(audace,menu,file)" "$caption(audace,menu,charger)..." \
         "$caption(touche,controle,O)"
      bind $audace(Console) <Control-o> "focus $audace(base) ; ::audace::charger $visuNo"
      Menu_Bind $visuNo $This <Control-s> "$caption(audace,menu,file)" "$caption(audace,menu,enregistrer)" \
         "$caption(touche,controle,S)"
      bind $audace(Console) <Control-s> "focus $audace(base) ; ::audace::enregistrer"
      Menu_Bind $visuNo $This <Control-q> "$caption(audace,menu,file)" "$caption(audace,menu,quitter)" \
         "$caption(touche,controle,Q)"
      bind $audace(Console) <Control-q> "focus $audace(base) ; ::audace::quitter"
      Menu_Bind $visuNo $This <F12> "$caption(audace,menu,display)" "$caption(audace,menu,pas_outil)" \
         "$caption(touche,F12)"

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).menubar

      #--- Rafraichissement des menus Fichier, Camera et Telescope pour les visu secondaires
      foreach visuNo [ ::visu::list ] {
         if { $visuNo > 1 } {
            if { [ info exist ::confVisu::private($visuNo,menu) ] } {
               if { $::confVisu::private($visuNo,menu) != "" } {

                  #--- Je supprime toutes les entrees du menu Fichier
                  Menu_Delete $visuNo "$caption(audace,menu,file)" entries
                  #--- Rafraichissement du menu Fichier
                  Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(audace,menu,charger)..." \
                     "::audace::charger $visuNo" \
                     -compound left -image $::confVisu::private(openIcon)
                  Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(audace,menu,enregistrer)" \
                     "::audace::enregistrer $visuNo" \
                     -compound left -image $::confVisu::private(saveIcon)
                  Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(audace,menu,enregistrer_sous)..." \
                     "::audace::enregistrer_sous $visuNo" \
                     -compound left -image $::confVisu::private(saveAsIcon)
                  Menu_Separator $visuNo "$caption(audace,menu,file)"
                  Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(audace,menu,entete)" "::keyword::header $visuNo"
                  #--- Affichage des plugins multivisu de type file du menu deroulant Fichier
                  Menu_Separator $visuNo "$caption(audace,menu,file)"
                  #--- Je reconstitue la liste triee des plugins
                  set liste ""
                  foreach m [array names panneau menu_name,*] {
                     lappend liste [list "$panneau($m) " $m]
                  }
                  set liste [lsort -dictionary $liste]
                  #--- Je recupere le pluginName de chaque plugin
                  foreach m $liste {
                     set m [lindex $m 1]
                     scan "$m" "menu_name,%s" pluginName
                     #--- Je selectionne les plugins multivisu
                     if { [ ::$pluginName\::getPluginProperty multivisu ] == "1" } {
                        #--- Je liste les plugins a afficher
                        foreach { namespace raccourci } $conf(afficheOutils) {
                           #--- Je verifie que le plugin multivisu est dans la liste des plugins a afficher
                           if { $namespace == $pluginName } {
                              #--- Affichage des plugins multivisu de type tool du menu deroulant Fichier
                              if { [ ::$pluginName\::getPluginProperty function ] == "file" } {
                                 Menu_Command $visuNo "$caption(audace,menu,file)" "$panneau($m)" "::confVisu::selectTool $visuNo ::$pluginName"
                              }
                           }
                        }
                     }
                  }
                  Menu_Separator $visuNo "$caption(audace,menu,file)"
                  Menu_Command   $visuNo "$caption(audace,menu,file)" "$caption(confVisu,fermer)" \
                     "::confVisu::close $visuNo" \
                     -compound left -image $::confVisu::private(closeIcon)

                  #--- Je supprime toutes les entrees du menu Camera
                  Menu_Delete $visuNo "$caption(audace,menu,acquisition)" entries
                  #--- Je reconstitue la liste triee des plugins
                  set liste ""
                  foreach m [ array names panneau menu_name,* ] {
                     lappend liste [ list "$panneau($m) " $m ]
                  }
                  set liste [ lsort -dictionary $liste ]
                  set firstTool ""
                  #--- Je recupere le pluginName de chaque plugin
                  foreach m $liste {
                     set m [ lindex $m 1 ]
                     scan "$m" "menu_name,%s" pluginName
                     #--- Je selectionne les plugins multivisu
                     if { [ ::$pluginName\::getPluginProperty multivisu ] == "1" } {
                        #--- Je liste les plugins a afficher
                        foreach { namespace raccourci } $conf(afficheOutils) {
                           #--- Je verifie que le plugin multivisu est dans la liste des plugins a afficher
                           if { $namespace == $pluginName } {
                              #--- Lancement automatique du premier plugin de la liste
                              if { $firstTool == "" } {
                                 set firstTool $pluginName
                                 ::confVisu::selectTool $visuNo ::$firstTool
                              }
                              #--- Affichage des plugins multivisu de type tool du menu deroulant Camera
                              if { [ ::$pluginName\::getPluginProperty function ] == "acquisition" } {
                                 Menu_Command $visuNo "$caption(audace,menu,acquisition)" "$panneau($m)" "::confVisu::selectTool $visuNo ::$pluginName"
                              }
                           }
                        }
                     }
                  }

                  #--- Je supprime toutes les entrees du menu Telescope
                  Menu_Delete $visuNo "$caption(audace,menu,aiming)" entries
                  #--- Je reconstitue la liste triee des plugins
                  set liste ""
                  foreach m [ array names panneau menu_name,* ] {
                     lappend liste [ list "$panneau($m) " $m ]
                  }
                  set liste [ lsort -dictionary $liste ]
                  set firstTool ""
                  #--- Je recupere le pluginName de chaque plugin
                  foreach m $liste {
                     set m [ lindex $m 1 ]
                     scan "$m" "menu_name,%s" pluginName
                     #--- Je selectionne les plugins multivisu
                     if { [ ::$pluginName\::getPluginProperty multivisu ] == "1" } {
                        #--- Je liste les plugins a afficher
                        foreach { namespace raccourci } $conf(afficheOutils) {
                           #--- Je verifie que le plugin multivisu est dans la liste des plugins a afficher
                           if { $namespace == $pluginName } {
                              #--- Affichage des plugins multivisu de type tool du menu deroulant Telescope
                              if { [ ::$pluginName\::getPluginProperty function ] == "aiming" } {
                                 Menu_Command $visuNo "$caption(audace,menu,aiming)" "$panneau($m)" "::confVisu::selectTool $visuNo ::$pluginName"
                              }
                           }
                        }
                     }
                  }

               }
               #--- Mise a jour dynamique des couleurs
               ::confColor::applyColor $::confVisu::private($visuNo,menu)
            }
         }
      }
   }

   proc cursor { visuNo curs } {
      variable private

      $private($visuNo,hCanvas) configure -cursor $curs
   }

   proc bg { coul } {
      variable private

      $private($visuNo,hCanvas) configure -background $coul
   }

   #
   # ::confVisu::screen2Canvas
   # Transforme des coordonnees ecran en coordonnees canvas
   # L'argument est une liste de deux entiers, et retourne egalement une liste de deux entiers
   #
   proc screen2Canvas { visuNo coord } {
      variable private

      scan [$private($visuNo,hCanvas) canvasx [lindex $coord 0]] "%d" xx
      scan [$private($visuNo,hCanvas) canvasy [lindex $coord 1]] "%d" yy
      return [list $xx $yy]
   }

   #
   # ::confVisu::canvas2Picture coord {stick left}
   # Transforme des coordonnees canvas en coordonnees image
   # L'argument est une liste de deux entiers, et retourne egalement une liste de deux entiers
   # Les coordonnees canvas commencent a 0,0 dans le coin superieur gauche de l'image
   # Les coordonnees image  commencent a 1,1 dans le coin inferieur gauche de l'image
   # En passant un argument <> de left pour stick, calcule les coordonnees par arrondi superieur
   #
   proc canvas2Picture { visuNo coord { stick left } } {
      variable private

      set zoom   [visu$visuNo zoom]
      set window [visu$visuNo window]
      set bufNo  [visu$visuNo buf]
      set height $private($visuNo,picture_h)

      if {$window=="full"} {
         set x0 1
         set y0 1
         set x1 $private($visuNo,picture_w)
         set y1 $private($visuNo,picture_h)
      } else {
         set x0 [lindex $window 0]
         set y0 [lindex $window 1]
         set x1 [lindex $window 2]
         set y1 [lindex $window 3]
      }

      if { $private($visuNo,mirror_x) == 1 } {
         lset coord 0 [ expr ($x1 - $x0)*$zoom - [lindex $coord 0] ]
      }
      if { $private($visuNo,mirror_y) == 1 } {
         lset coord 1 [ expr ($y1 - $y0 )*$zoom - [lindex $coord 1] ]
      }

      if {$zoom >= 1} {
         set xx [expr [lindex $coord 0] / $zoom + $x0]
         set yy [expr $y1 - [lindex $coord 1] / $zoom ]
      } else {
         if {$stick == "left"} {
            #--- Ce calcul sert a obtenir la borne inferieure en cas de sous-echantillonnage
            set xx [expr int([lindex $coord 0] / $zoom  + 1 + $x0)]
            set yy [expr int($y1 - ([lindex $coord 1] + 1) / $zoom + 1 )]
         } else {
            #--- Alors que ce calcul sert a obtenir la borne superieure en cas de sous-echantillonnage
            set xx [expr int(([lindex $coord 0] + 1) / $zoom  + $x0)]
            set yy [expr int($y1 - [lindex $coord 1] / $zoom )]
         }
      }

      if { $private($visuNo,applyThickness) == 1 } {
         set yy 1
      }

      return [list $xx $yy]
   }

   #
   # ::confVisu::picture2Canvas coord
   # Transforme des coordonnees image en coordonnees canvas
   # L'argument est une liste de deux entiers, et retourne egalement une liste de deux entiers
   #
   #
   proc picture2Canvas { visuNo coord } {
      variable private

      set zoom   [visu$visuNo zoom]
      set height $private($visuNo,picture_h)

      #--- je prends en compte le fenetrage
      set windowBox [visu$visuNo window]
      if {$windowBox=="full"} {
         set x0 1
         set y0 1
         set x1 $private($visuNo,picture_w)
         set y1 $private($visuNo,picture_h)
      } else {
         set x0 [lindex $windowBox 0]
         set y0 [lindex $windowBox 1]
         set x1 [lindex $windowBox 2]
         set y1 [lindex $windowBox 3]
      }

      #--- j'applique le zoom et j'inverse l'axe Y
      set xx [ expr int(( [lindex $coord 0] - $x0)*$zoom) ]
      set yy [ expr int(( $y1 -[lindex $coord 1] )*$zoom) ]

      #--- j'applique le mirroir sur l'axe x
      if { $private($visuNo,mirror_x) == 1 } {
         set xx [ expr ($x1 -$x0 +1)*$zoom - $xx ]
      }

      #--- j'applique le mirroir sur l'axe y
      if { $private($visuNo,mirror_y) == 1 } {
         set yy [ expr ($y1 -$y0+1)*$zoom - $yy ]
      }

      return [list $xx $yy]
   }

   #------------------------------------------------------------
   #  onPressButton1
   #     demarre le trace de la boite
   #  parametres :
   #    visuNo: numero de la visu
   #    x y : coordonnees de la souris (referentiel ecran)
   #------------------------------------------------------------
   proc onPressButton1 { visuNo x y } {
      variable private
      global caption

      if { [string compare $::confVisu::private($visuNo,MouseState) rien] == 0 } {
         set bufNo [visu$visuNo buf]
         set liste [::confVisu::screen2Canvas $visuNo [list $x $y]]
         if { [ buf$bufNo imageready ] == "1" } {
            set zoom   $private($visuNo,zoom)
            set width  $::confVisu::private($visuNo,picture_w)
            set height $::confVisu::private($visuNo,picture_h)
            set wz [expr $width * $zoom]
            set hz [expr $height * $zoom]
            if {[lindex $liste 0]<$wz && [lindex $liste 1]<$hz} {
               ::confVisu::boxBegin $visuNo [list $x $y]
               set ::confVisu::private($visuNo,MouseState) dragging
            }
         }
      } else {
         if { [string compare $::confVisu::private($visuNo,MouseState) context] == 0 } {
            [MenuGet $visuNo "$caption(audace,menu,display)"] unpost
            set ::confVisu::private($visuNo,MouseState) rien
         }
      }
   }

   #------------------------------------------------------------
   #  onMotionButton1
   #     redessine la boite en suivant le deplacement de la souris
   #  parametres :
   #    visuNo: numero de la visu
   #    x y : coordonnees de la souris (referentiel ecran)
   #------------------------------------------------------------
   proc onMotionButton1 { visuNo x y } {
      variable private

      if { [string compare $::confVisu::private($visuNo,MouseState) dragging] == 0 } {
         #--- Affichage des coordonnees
         ::confVisu::displayCursorCoord $visuNo [list $x $y]
         #--- On n'oublie pas de dragger eventuellement la fenetre
         ::confVisu::boxDrag $visuNo [list $x $y]
      }
   }

   proc onReleaseButton1 { visuNo x y } {
      variable private

      if { [string compare $private($visuNo,MouseState) dragging] == 0 } {
         set private($visuNo,MouseState) rien
         catch { ::confVisu::boxEnd $visuNo [list $x $y] }
      }
   }

   #------------------------------------------------------------------------------
   # createPopupMenuButton3
   #   creation du menu en popup
   #------------------------------------------------------------------------------
   proc createPopupMenuButton3 { visuNo } {
      variable private
      global caption

      set private($visuNo,toplevel) [ winfo toplevel $private($visuNo,hCanvas) ]

      set menu $private($visuNo,toplevel).menuButton3
      set private($visuNo,popupmenuButton3) "$menu"

      menu $menu -tearoff no

      $menu add command -label $caption(audace,menu,histo) \
         -command "::audace::Histo $visuNo"
      $menu add command -label $caption(audace,menu,coupe) \
         -command "::sectiongraph::init $visuNo"
      $menu add command -label $caption(audace,menu,statwin) \
         -command "statwin $visuNo"
      $menu add command -label $caption(audace,menu,fwhm) \
         -command "fwhm $visuNo"
      $menu add command -label $caption(audace,menu,fitgauss) \
         -command "fitgauss $visuNo"
      $menu add command -label $caption(audace,menu,centro) \
         -command "center $visuNo"
      $menu add command -label $caption(audace,menu,phot) \
         -command "photom $visuNo"
      $menu add command -label $caption(audace,menu,subfitgauss) \
         -command "subfitgauss $visuNo"

      $menu add separator
      $menu add checkbutton -label $caption(confVisu,reticule) \
         -variable ::Crosshair::widget($visuNo,currentstate) \
         -command "::confVisu::toggleCrosshair $visuNo"

      bind $private($visuNo,hCanvas) <ButtonPress-1> ""
      bind $private($visuNo,hCanvas) <ButtonPress-3> [list tk_popup $menu %X %Y]
   }

   #------------------------------------------------------------
   #  onMotionMouse
   #     affiche les cordonnees et l'intensite du pixel pointe par la souris
   #  parametres :
   #    visuNo: numero de la visu
   #    x y : coordonnees de la souris (referentiel ecran)
   #------------------------------------------------------------
   proc onMotionMouse { visuNo x y } {
      #--- Affichage des coordonnees
      ::confVisu::displayCursorCoord $visuNo [list $x $y]
   }

   #------------------------------------------------------------
   #  displayCursorCoord
   #     affiche les cordonnees et l'intensite du pixel pointe par la souris
   #  parametres :
   #    visuNo: numero de la visu
   #    x y : coordonnees de la souris (referentiel ecran)
   #------------------------------------------------------------
   proc displayCursorCoord { visuNo coord } {
      variable private
      global caption

      #--- Transformation des coordonnees ecran en coordonnees image
      set coord [ ::confVisu::canvas2Picture $visuNo [ ::confVisu::screen2Canvas $visuNo $coord ] ]
      set xc [lindex $coord 0 ]
      set yc [lindex $coord 1 ]

      set windowBox [visu$visuNo window]
      if {$windowBox=="full"} {
         set x0 1
         set y0 1
         set x1 $private($visuNo,picture_w)
         set y1 $private($visuNo,picture_h)
      } else {
         set x0 [lindex $windowBox 0]
         set y0 [lindex $windowBox 1]
         set x1 [lindex $windowBox 2]
         set y1 [lindex $windowBox 3]
      }

      set This $private($visuNo,This)
      set bufNo [visu$visuNo buf]

      #--- j'affiche les coordonnees si le curseur de la souris est a l'interieur de la fenetre
      if { $xc < $x0 || $xc > $x1 || $yc < $y0 || $yc >$y1 } {
         set xi "$caption(confVisu,tiret)"
         set yi "$caption(confVisu,tiret)"
         set intensite "$caption(confVisu,I) $caption(confVisu,egale) $caption(confVisu,tiret)"
      } else {
         #--- xi et yi sont des 'coordonnees-buffer'
         set xi $xc
         set yi $yc
         #--- si le buffer ne contient qu'une ligne, j'affiche l'intensite de
         #--- cette ligne quelque soit la position verticale du curseur de la
         #--- souris dans l'image car c'est la meme valeur sur toute la colonne
         if { [buf$bufNo getpixelsheight]==1 } {
            set yii 1
         } else {
            set yii $yi
         }
         #--- ii contiendra l'intensite du pixel pointe
         set result [catch { set ii [ buf$bufNo getpix [ list $xi $yii ] ] } ]
         if { $result == 0 } {
            if { $private($visuNo,intensity) == "1" } {
               if { [ lindex $ii 0 ] == "1" } {
                  set intensite "$caption(confVisu,I) $caption(confVisu,egale) [ lindex $ii 1 ]"
               } elseif { [ lindex $ii 0 ] == "3" } {
                  set intensite "$caption(confVisu,rouge)[ lindex $ii 1 ] $caption(confVisu,vert)[ lindex $ii 2 ] $caption(confVisu,bleu)[ lindex $ii 3 ]"
               }
            } elseif { $private($visuNo,intensity) == "0" } {
               if { [ lindex $ii 0 ] == "1" } {
                  set intensite "$caption(confVisu,I) $caption(confVisu,egale) [ string trimleft [ format "%8.0f" [ lindex $ii 1 ] ] " " ]"
               } elseif { [ lindex $ii 0 ] == "3" } {
                  set intensite "$caption(confVisu,rouge)[ string trimleft [ format "%8.0f" [ lindex $ii 1 ] ] " " ] \
                     $caption(confVisu,vert)[ string trimleft [ format "%8.0f" [ lindex $ii 2 ] ] " " ] \
                     $caption(confVisu,bleu)[ string trimleft [ format "%8.0f" [ lindex $ii 3 ] ] " " ]"
               }
            }
         } else {
            #--- je traite le cas ou la taille de l'image a ete changee dans le buffer et que
            #--- les variables private($visuNo,picture_w) et private($visuNo,picture_w) ne
            #--- sont pas encore a jour (par exemple acquisition en cours avec une camera)
            set xi "$caption(confVisu,tiret)"
            set yi "$caption(confVisu,tiret)"
            set intensite "$caption(confVisu,I) $caption(confVisu,egale) $caption(confVisu,tiret)"
         }
      }

      #--- Affichage a l'ecran
      if { $private($visuNo,labcoord_type) == "xy" } {
         $This.fra1.labURLX configure -text "$caption(confVisu,X) $caption(confVisu,egale) $xi"
         $This.fra1.labURLY configure -text "$caption(confVisu,Y) $caption(confVisu,egale) $yi"
         $This.fra1.labI configure -text "$intensite"
      } else {
         if { $xi != "$caption(confVisu,tiret)" } {
            set result [catch { set temp [ buf$bufNo xy2radec [ list $xi $yi ] ] } ]
            if { $result == 1 } {
               #--- en cas d'erreur de conversion, je reviens en coordonnees xy
               set private($visuNo,labcoord_type) "xy"
               return
            }
            $This.fra1.labURLX configure -text "$caption(confVisu,RA) $caption(confVisu,egale) [ mc_angle2hms [ lindex $temp 0 ] 360 zero 1 auto string ]"
            $This.fra1.labURLY configure -text "$caption(confVisu,DEC) $caption(confVisu,egale) [ mc_angle2dms [ lindex $temp 1 ] 90 zero 0 + string ]"
         } else {
            $This.fra1.labURLX configure -text "$caption(confVisu,RA) $caption(confVisu,egale) $caption(confVisu,tiret)"
            $This.fra1.labURLY configure -text "$caption(confVisu,DEC) $caption(confVisu,egale) $caption(confVisu,tiret)"
         }
         $This.fra1.labI configure -text "$intensite"
      }
   }

   #------------------------------------------------------------
   #  getBox
   #     retourne les coordonnees de la boite (referentiel picture)
   #     si elle existe, sinon retourne une chaine vide
   #  parametres :
   #     visuNo : numero de la visu
   #------------------------------------------------------------
   proc getBox { { visuNo } } {
      variable private

      return $private($visuNo,boxSize)
   }

   #------------------------------------------------------------
   #  getCanvas
   #     retourne le nom du canvas (chemin TK)
   #  parametres :
   #     visuNo : numero de la visu
   #------------------------------------------------------------
   proc getCanvas { visuNo } {
      variable private

      return $private($visuNo,hCanvas)
   }

   #------------------------------------------------------------
   #  boxBegin
   #     demarre le trace de la boite
   #     et memorise les coordonnees de la souris dans private($visuNo,box_1)
   #  parametres :
   #    visuNo: numero de la visu
   #    x y : coordonnees de la souris (referentiel ecran)
   #------------------------------------------------------------
   proc boxBegin { visuNo coord } {
      variable private

      set private($visuNo,box_1) [ screen2Canvas $visuNo $coord ]
      set private($visuNo,box_2) $private($visuNo,box_1)
      deleteBox $visuNo
   }

   #------------------------------------------------------------
   #  boxEnd
   #     redessine la boite en suivant le deplacement de la souris
   #     et enregistre les coordonnees (referentiel picture) de la boite
   #     dans privaste($visuNo,boxSize)
   #  parametres :
   #    visuNo: numero de la visu
   #    coord : coordonnees de la souris (referentiel ecran)
   #------------------------------------------------------------
   proc boxEnd { visuNo coord } {
      variable private
      global audace

      if { $private($visuNo,box_1) == $private($visuNo,box_2) } {
         deleteBox $visuNo
      } else {
         ::confVisu::boxDrag $visuNo $coord
         if {[lindex $private($visuNo,box_1) 0] > [lindex $private($visuNo,box_2) 0]} {
            set x1 [lindex $private($visuNo,box_2) 0]
            set x2 [lindex $private($visuNo,box_1) 0]
         } else {
            set x1 [lindex $private($visuNo,box_1) 0]
            set x2 [lindex $private($visuNo,box_2) 0]
         }
         if {[lindex $private($visuNo,box_1) 1] < [lindex $private($visuNo,box_2) 1]} {
            #--- !! Le test est inverse car l'origine en canvas est en haut !!
            set y1 [lindex $private($visuNo,box_2) 1]
            set y2 [lindex $private($visuNo,box_1) 1]
         } else {
            set y1 [lindex $private($visuNo,box_1) 1]
            set y2 [lindex $private($visuNo,box_2) 1]
         }
         set coord1 [::confVisu::canvas2Picture $visuNo [list $x1 $y1]]
         set coord2 [::confVisu::canvas2Picture $visuNo [list $x2 $y2] -right ]

         if {[lindex $coord1 0] < [lindex $coord2 0]} {
            set x1 [lindex $coord1 0]
            set x2 [lindex $coord2 0]
         } else {
            set x1 [lindex $coord2 0]
            set x2 [lindex $coord1 0]
         }

         if {[lindex $coord1 1] < [lindex $coord2 1]} {
            set y1 [lindex $coord1 1]
            set y2 [lindex $coord2 1]
         } else {
            set y1 [lindex $coord2 1]
            set y2 [lindex $coord1 1]
         }
         set private($visuNo,boxSize) [list $x1 $y1 $x2 $y2]
      }
   }

   #------------------------------------------------------------
   #  boxDrag
   #     redessine la boite en suivant le deplacement de la souris
   #     et memorise les coordonnees de la souris dans private($visuNo,box_2)
   #  parametres :
   #    visuNo: numero de la visu
   #    x y : coordonnees de la souris (referentiel ecran)
   #------------------------------------------------------------
   proc boxDrag { visuNo coord } {
      variable private
      global audace

      set zoom  $private($visuNo,zoom)
      set bufNo [visu$visuNo buf]
      set width  $private($visuNo,picture_w)
      set height $private($visuNo,picture_h)

      set wz [expr $width * $zoom]
      set hz [expr $height * $zoom]

      if { $private($visuNo,hBox) != "" } {
         $private($visuNo,hCanvas) delete $private($visuNo,hBox)
      }
      set x [lindex $coord 0]
      if {$x<0} {set coord [lreplace $coord 0 0 0]}
      if {$x>=$wz} {
         set coord [lreplace $coord 0 0 [expr $wz-1]]
      }
      set y [lindex $coord 1]
      if {$y<0} {set coord [lreplace $coord 1 1 0]}
      if {$y>=$hz} {
         set coord [lreplace $coord 1 1 [expr $hz-1]]
      }
      set private($visuNo,box_2) [screen2Canvas $visuNo $coord]
      set private($visuNo,hBox) [eval {$private($visuNo,hCanvas) create rect} $private($visuNo,box_1) \
      $private($visuNo,box_2) -outline $audace(color,drag_rectangle) -tag selBox]
   }

   #------------------------------------------------------------
   #  deleteBox
   #     efface la boite
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc deleteBox { { visuNo "1" } } {
      variable private

      if { $private($visuNo,boxSize) != "" } {
         set private($visuNo,boxSize) ""
         $private($visuNo,hCanvas) delete $private($visuNo,hBox)
      }
   }

   #------------------------------------------------------------
   #  deleteImage
   #     efface l'image presente dans le canvas
   #  parametres :
   #    visuNo: numero de la visu
   #------------------------------------------------------------
   proc deleteImage { { visuNo "1" } } {
      variable private

      set bufNo [ visu$visuNo buf ]
      if { [ buf$bufNo imageready ] == "1" } {
         if { $private($visuNo,window) == "1" } {
            set private($visuNo,window) "0"
            visu$visuNo window full
         }
         loadima "" $visuNo
      }
   }

   #------------------------------------------------------------
   #  visuDynamix
   #      fixe les bornes des glissieres de reglage des seuils
   #------------------------------------------------------------
   proc visuDynamix { visuNo max min } {
      variable private

      $private($visuNo,This).fra1.sca1 configure -from $min -to $max
      $private($visuNo,This).fra1.sca2 configure -from $min -to $max
   }

   #------------------------------------------------------------
   #  changeDisplayIntensity
   #      affiche l'intensite (N&B) ou les intensites (RGB) en decimal ou en entier
   #------------------------------------------------------------
   proc changeDisplayIntensity { visuNo } {
      variable private

      if { $private($visuNo,intensity) == "1" } {
         set private($visuNo,intensity) "0"
      } elseif { $private($visuNo,intensity) == "0" } {
         set private($visuNo,intensity) "1"
      }
   }

   proc onCutLabelLeftClick { visuNo } {
      variable private

      if { $private($visuNo,autovisuEnCours) == "0" } {
         set private($visuNo,autovisuEnCours) "1"
         #--- Le -force permet de forcer la visu si on a choisi
         #--- dans le panneau de config "pas de recalcul automatique"
         ::confVisu::autovisu $visuNo -force
         set private($visuNo,autovisuEnCours) "0"
      }
   }

   proc onCutLabelRightClick { visuNo } {
      ::seuilWindow::run $visuNo
   }

   proc index2cut { visuNo val } {
      variable private

      return [ expr $val * $private($visuNo,a) + $private($visuNo,b) ]
   }

   proc onHiCutCommand { visuNo val } {
      set new_hi_cut [ index2cut $visuNo $val ]
      #::console::affiche_resultat "onHiCutCommand: $val => $new_hi_cut\n"
      set sbh [visu$visuNo cut]
      visu$visuNo cut [list $new_hi_cut [lindex $sbh 1]]
      ChangeCutsDisplay $visuNo
   }

   proc onLoCutCommand { visuNo val } {
      set new_lo_cut [ index2cut $visuNo $val ]
      #::console::affiche_resultat "onLoCutCommand: $val => $new_lo_cut\n"
      set sbh [visu$visuNo cut]
      visu$visuNo cut [list [lindex $sbh 0] $new_lo_cut]
      ChangeCutsDisplay $visuNo
   }

   proc ChangeCutsDisplay { visuNo } {
      variable private

      set bufNo [ visu$visuNo buf ]
      #---
      if { ( [ lindex [ buf$bufNo getkwd NAXIS ] 1 ] == "3" ) || ( [ buf$bufNo imageready ] == "0" ) } {
         #--- je desactive le bind des glissieres
         $private($visuNo,This).fra1.sca1 configure -command ""
         $private($visuNo,This).fra1.sca2 configure -command ""
         #--- J'efface les seuils haut et bas
         $private($visuNo,This).fra1.lab1 configure -text "---"
         $private($visuNo,This).fra1.lab2 configure -text "---"
         return
      } elseif { [ lindex [ buf$bufNo getkwd NAXIS ] 1 ] != "3" } {
         #--- j'active le bind des glissieres
         $private($visuNo,This).fra1.sca1 configure -command "::confVisu::onHiCutCommand $visuNo"
         $private($visuNo,This).fra1.sca2 configure -command "::confVisu::onLoCutCommand $visuNo"
      }
      #---
      set sh [lindex [visu$visuNo cut] 0]
      set sb [lindex [visu$visuNo cut] 1]
      if { [ expr abs( $sh - $sb ) ] > "$private($visuNo,intervalleSHSB)" } {
         $private($visuNo,This).fra1.lab1 configure -text [format %d [expr int($sh)]]
         $private($visuNo,This).fra1.lab2 configure -text [format %d [expr int($sb)]]
      } else {
         $private($visuNo,This).fra1.lab1 configure -text [format %.4e $sh]
         $private($visuNo,This).fra1.lab2 configure -text [format %.4e $sb]
      }
   }

   proc onCutScaleRelease { visuNo } {
      variable private

      ComputeScaleRange $visuNo
      if { [ image type imagevisu[visu$visuNo image] ] == "photo" } {
         while { 1 } {
            set catchResult [catch { visu$visuNo disp } msg ]
            if { $catchResult == 1 && $msg == "NO MEMORY FOR DISPLAY" } {
               #--- en cas d'erreur "NO MEMORY FOR DISPLAY", j'essaie avec un zoom inferieur
               set private($visuNo,zoom) [expr double($private($visuNo,zoom)) / 2]
               if { $private($visuNo,zoom) >= 1 } {
                   set private($visuNo,zoom) [expr int($private($visuNo,zoom))]
               }
               visu$visuNo zoom $private($visuNo,zoom)
               ::console::affiche_erreur "WARNING: NO MEMORY FOR DISPLAY, visuNo=$visuNo set zoom=$private($visuNo,zoom)\n"
            } else {
               break
            }
         }
      }
   }

   proc ComputeScaleRange { visuNo } {
      variable private
      global conf

      set zone(sh1) $private($visuNo,This).fra1.sca1
      set zone(sb1) $private($visuNo,This).fra1.sca2
      if { $conf(seuils,auto_manuel) == 1 } {
         #--- Calcule la nouvelle dynamique de deplacement des curseurs
         set sh [lindex [visu$visuNo cut] 0]
         set sb [lindex [visu$visuNo cut] 1]
         if {$sb<$sh} {
            set maxi $sh
            set mini $sb
         } else {
            set maxi $sb
            set mini $sh
         }
         set range [expr $maxi-$mini]
         if {$range == 0} {
            set range 1024
         }
         set private($visuNo,mincut) [ expr $mini - $conf(seuils,%_dynamique) / 100.0 * $range ]
         set private($visuNo,maxcut) [ expr $maxi + $conf(seuils,%_dynamique) / 100.0 * $range ]
         set private($visuNo,minindex) [ $private($visuNo,This).fra1.sca1 cget -from ]
         set private($visuNo,maxindex) [ $private($visuNo,This).fra1.sca1 cget -to ]

         #--- Calcul des coefficients de transformation seuil de visu = f(position) :
         #---  cut = a * pos + b
         set cut_lo $private($visuNo,mincut)
         set cut_hi $private($visuNo,maxcut)
         set index_lo $private($visuNo,minindex)
         set index_hi $private($visuNo,maxindex)

         set private($visuNo,a) [ expr ( $cut_lo - $cut_hi ) / ( $index_lo - $index_hi ) ]
         set private($visuNo,b) [ expr ( $cut_lo * $index_hi - $cut_hi * $index_lo ) / ( $index_hi - $index_lo ) ]

         #--- Repositionnement des poignees a leur nouvelle position
         $private($visuNo,This).fra1.sca1 set [ expr ( $sh - $private($visuNo,b) ) / $private($visuNo,a) ]
         $private($visuNo,This).fra1.sca2 set [ expr ( $sb - $private($visuNo,b) ) / $private($visuNo,a) ]
#::console::affiche_resultat "ComputeScaleRange: sh=$sh, sb=$sb, min_index=$private($visuNo,minindex), max_index=$private($visuNo,maxindex), maxi=$maxi, mini=$mini, a=$private($visuNo,a), b=$private($visuNo,b)\n"
      } elseif { $conf(seuils,auto_manuel) == 2 } {
         $zone(sb1) configure -from $private($visuNo,mindyn) -to $private($visuNo,maxdyn)
         $zone(sh1) configure -from $private($visuNo,mindyn) -to $private($visuNo,maxdyn)
      }
   }

   #------------------------------------------------------------
   #  setCrosshair
   #  set Crosshair state
   #   state = 0 or 1
   #------------------------------------------------------------
   proc setCrosshair { visuNo state } {
      variable private

      set private($visuNo,crosshairstate) $state
      redrawCrosshair $visuNo
   }

   #------------------------------------------------------------
   #  getCrosshair
   #  returns crosshair state 1=shown 0=hidden
   #
   #------------------------------------------------------------
   proc getCrosshair { visuNo } {
      variable private

      return $private($visuNo,crosshairstate)
   }

   #------------------------------------------------------------
   #  toggleCrosshair
   #  toggle drawing/hiding Crosshair
   #  as check button state indicate
   #------------------------------------------------------------
   proc toggleCrosshair { visuNo } {
      variable private

      if { $private($visuNo,crosshairstate) =="0"} {
         set private($visuNo,crosshairstate) "1"
      } else {
         set private($visuNo,crosshairstate) "0"
      }
      redrawCrosshair $visuNo
   }

   #------------------------------------------------------------
   #  redrawCrosshair
   #  redraw Crosshair if image size is changed
   #------------------------------------------------------------
   proc redrawCrosshair { visuNo } {
      variable private

      #--- je masque le reticule
      hideCrosshair $visuNo
      if { "$private($visuNo,crosshairstate)" == "1" } {
         #--- j'affiche le reticule
         displayCrosshair $visuNo
      }
   }

   #--------------------------------------------------------------
   #  displayCrosshair
   #  draw Crosshair lines ( 1 horizontal line, 1 vertical line )
   #
   #--------------------------------------------------------------
   proc displayCrosshair { visuNo } {
      variable private
      global conf

      set hCanvas $private($visuNo,hCanvas)

      #--- je cree le label representant la ligne horizontale
      if { ![winfo exists $private($visuNo,hCrosshairH)] } {
         label $private($visuNo,hCrosshairH) -bg $conf(crosshair,color)
      } else {
         $private($visuNo,hCrosshairH) configure -bg $conf(crosshair,color)
      }

      #--- je cree le label representant la ligne verticale
      if { ![winfo exists $private($visuNo,hCrosshairV)] } {
         label $private($visuNo,hCrosshairV) -bg $conf(crosshair,color)
      } else {
         $private($visuNo,hCrosshairV) configure -bg $conf(crosshair,color)
      }

      #--- coordonnees du centre du reticule dans le repere canvas
      #--- attention : le reticule est centre sur l'image (pas sur le canvas)
      set xc [expr int($private($visuNo,picture_w) / 2) ]
      set yc [expr int($private($visuNo,picture_h) / 2) ]
      set centerCoord [ picture2Canvas $visuNo [list $xc $yc ] ]
      set xcCanvas [lindex $centerCoord 0]
      set ycCanvas [lindex $centerCoord 1]

      #--- longueur des traits du reticule dans le repere canvas
      #--- en fonction de la fenetre et du zoom
      set windowBox [visu$visuNo window]
      if {$windowBox=="full"} {
         set x0 1
         set y0 1
         set x1 $private($visuNo,picture_w)
         set y1 $private($visuNo,picture_h)
      } else {
         set x0 [lindex $windowBox 0]
         set y0 [lindex $windowBox 1]
         set x1 [lindex $windowBox 2]
         set y1 [lindex $windowBox 3]
      }
      set coord0Canvas [ picture2Canvas $visuNo [list $x0 $y0 ] ]
      set coord1Canvas [ picture2Canvas $visuNo [list $x1 $y1 ] ]
      set widthCanvas [expr abs([lindex $coord1Canvas 0] - [lindex $coord0Canvas 0]) + 1 ]
      set heightCanvas [expr abs([lindex $coord0Canvas 1] - [lindex $coord1Canvas 1]) + 1 ]

      #--- j'affiche le trait horizontal du reticule s'il est a l'interieur de la fenetre
      if { $yc >= $y0 && $yc <= $y1 } {
         $hCanvas create window 1 1 -tag lineh -anchor nw -window $private($visuNo,hCrosshairH) -height 1
         $hCanvas coords lineh 0 $ycCanvas
         $hCanvas itemconfigure lineh -width $widthCanvas
         $hCanvas itemconfigure lineh -state normal
      }

      #--- j'affiche le trait vertical du reticule s'il est a l'interieur de la fenetre
      if { $xc >= $x0 && $xc <= $x1 } {
         $hCanvas create window 1 1 -tag linev -anchor nw -window $private($visuNo,hCrosshairV) -width 1
         $hCanvas coords linev $xcCanvas 0
         $hCanvas itemconfigure linev -height $heightCanvas
         $hCanvas itemconfigure linev -state normal
      }
      raise $private($visuNo,hCrosshairH)
      raise $private($visuNo,hCrosshairV)

   }

   #------------------------------------------------------------
   #  hideCrosshair
   #  hiding Crosshair lines
   #
   #------------------------------------------------------------
   proc hideCrosshair { visuNo } {
      variable private

      $private($visuNo,hCanvas) delete lineh
      $private($visuNo,hCanvas) delete linev

      if { ![winfo exists $private($visuNo,hCrosshairH)] } {
         destroy $private($visuNo,hCrosshairH)
      }
      if { ![winfo exists $private($visuNo,hCrosshairV)] } {
         destroy $private($visuNo,hCrosshairV)
      }
   }

   #------------------------------------------------------------
   #  setFileName
   #    modifie le nom du fichier courant
   #    et affiche le nom dans le titre de la fenetre
   #  parametres :
   #    visuNo : numero de la visu
   #    fileName: nom du fichier
   #------------------------------------------------------------
   proc setFileName { visuNo fileName} {
      variable private
      global caption

      #--- je mets a jour le nom du fichier dans le titre de la fenetre
      if { $fileName != "" } {
        wm title $private($visuNo,This) "$caption(audace,titre) (visu$visuNo) - $fileName"
      } else {
        wm title $private($visuNo,This) "$caption(audace,titre) (visu$visuNo)"
      }

      #--- je mets a jour le nom du fichier
      set private($visuNo,lastFileName) "$fileName"
   }

}

#--- namespace end

#------------------------------------------------------------
#  loadIma
#    charge et affiche une image
#  parametres :
#    visuNo : numero de la visu
#    fileName: nom du fichier
#------------------------------------------------------------
proc ::confVisu::loadIma { visuNo fileName { hduName "" } } {
   variable private

   set catchResult [catch {
      ::confVisu::autovisu $visuNo "-no" $fileName $hduName
   }]

   if { $catchResult == 1 } {
      ::console::affiche_erreur "$::errorInfo\n"
   }
}

#------------------------------------------------------------
# setMode
#   change le mode de visualisation (image, graph, table)
#
#------------------------------------------------------------
proc ::confVisu::setMode { visuNo mode} {
   variable private

   if { $mode == $private($visuNo,mode) } {
      return
   }

   set This $private($visuNo,This)

   #--- j'arrete le mode precedent
   switch $private($visuNo,mode) {
      "image" {
         grid forget $This.fra1
         grid forget $This.can1
      }
      "graph" {
         grid forget $This.graph
         grid forget $This.graphConfig
      }
      "table" {
         grid forget $This.ftable
      }
   }

   #--- j'active le nouveau mode
   switch $mode {
      "image" {
         #--- j'affiche le canvas photo et la frame des seuils
         grid $This.fra1 -row 2 -column 0 -columnspan 2 -sticky ew
         grid $This.can1 -row 1 -column 1 -sticky nsew
      }
      "graph" {
         createGraph $visuNo
         grid $This.graph -row 1 -column 1 -sticky nsew
         grid $This.graphConfig  -row 2 -column 0 -columnspan 2 -sticky ew
      }
      "table" {
         createTable $visuNo
         grid $This.ftable -row 1 -column 1 -sticky nsew
      }

   }
   update
   set private($visuNo,mode) $mode
}

#############################################################
#  Gestion d'un graphe
#############################################################

#------------------------------------------------------------
# createGraph
#    passe en mode graphe (affichage de graphique)
#
#------------------------------------------------------------
proc ::confVisu::createGraph { visuNo } {
   variable private

   package require BLT
   set This $private($visuNo,This)

   if { [winfo exists $This.graph ] } {
      return
   }

   #--- je cree le graphique
   blt::graph $This.graph  -plotbackground $::audace(color,backColor)
   $This.graph crosshairs on
   $This.graph crosshairs configure -color red -dashes 2
   $This.graph axis configure x2 -hide true
   $This.graph axis configure y2 -hide true
   $This.graph legend configure -hide yes

   bind $This.graph <Motion>          "::confVisu::onGraphMotion $visuNo %W %x %y"
   bind $This.graph <ButtonPress-1>   "::confVisu::onGraphRegionStart $visuNo %W %x %y "
   bind $This.graph <B1-Motion>       "::confVisu::onGraphRegionMotion $visuNo %W %x %y"
   bind $This.graph <ButtonRelease-1> "::confVisu::onGraphRegionEnd $visuNo %W %x %y"
   bind $This.graph <ButtonRelease-3> "::confVisu::onGraphUnzoom $visuNo"

   #--- je cree la zone d'affichage des coordonnees
   set private($visuNo,graph,coordinate) ""
   frame $This.graphConfig -borderwidth 2 -cursor arrow -relief groove
      label $This.graphConfig.coordinates -textvariable ::confVisu::private($visuNo,graph,coordinate) -borderwidth 0
      pack $This.graphConfig.coordinates -side top -anchor center -fill none
}

##------------------------------------------------------------
# getGraph
#    retourne le nom tk du graphe servant a afficher les profils
#
# @param visuNo  numero de la visu
# @return nom du widget TK du graphe
#------------------------------------------------------------
proc ::confVisu::getGraph { visuNo } {
   variable private

   if { ! [winfo exists $private($visuNo,This).graph ] } {
      createGraph $visuNo
   }

   return $private($visuNo,This).graph
}

##------------------------------------------------------------
# onGraphMotion
#  affiche les coordonnees du curseur de la souris
#  apres chaque deplacement de la souris
#
# @param  visuNo  numero de la fenetre
# @param  xScreen abcisse de la souris (referentiel screen)
# @param  yScreen ordoonnee de la souris (referentiel screen)
# @return rien
#------------------------------------------------------------
proc ::confVisu::onGraphMotion { visuNo graph xScreen yScreen } {
   variable private

   set This $private($visuNo,This)

   #set x %x
   #set y %y
   set x [$graph  axis invtransform x $xScreen]
   set y [$graph  axis invtransform y $yScreen]
   set lx [string length $x]
   if {$lx>8} { set x [string range $x 0 7] }
   set ly [string length $y]
   if {$ly>8} { set y [string range $y 0 7] }
   $graph  crosshairs configure -position @$xScreen,$yScreen
   #--- je mets a jour la variable des coordonnnees
   set private($visuNo,graph,coordinate) "$x $private($visuNo,graph,xUnit) $y $private($visuNo,graph,yUnit)"
}

#------------------------------------------------------------
# onGraphRegionStart
#  demarre la selection d'une region du graphe avec la souris
#
# Parameters
#    visuNo  numero de la fenetre
#    graph   nom tk du graphe
#    xScreen yScreen  coordoonnees ecran de la souris
#  @return
#    rien
#------------------------------------------------------------
proc ::confVisu::onGraphRegionStart { visuNo graph x y } {
   variable private

   set x [$graph axis invtransform x $x]
   set y [$graph axis invtransform y $y]
   $graph marker create line -coords {} -name myLine \
      -dashes dash -xor yes
   set private($visuNo,regionStartX) $x
   set private($visuNo,regionStartY) $y
}

#------------------------------------------------------------
# onGraphRegionMotion
#  modifie la selection d'une region du graphe avec la souris
#
# Parameters
#    visuNo  numero de la fenetre
#    graph   nom tk du graphe
#    xScreen yScreen  coordoonnees ecran de la souris
#  @return
#     rien
#------------------------------------------------------------
proc ::confVisu::onGraphRegionMotion { visuNo graph x y } {
   variable private

   if { [info exists private($visuNo,regionStartX)] } {
      set x0 $private($visuNo,regionStartX)
      set y0 $private($visuNo,regionStartY)
      set x [$graph axis invtransform x $x]
      set y [$graph axis invtransform y $y]
      $graph marker configure myLine -coords \
         "$x0 $y0 $x0 $y $x $y $x $y0 $x0 $y0"
   }
}

#------------------------------------------------------------
# onGraphRegionEnd
#  termine la selection d'une region du graphe avec la souris
#  et applique un zoom sur cette region

# Parameters
#    visuNo  numero de la fenetre
#    graph   nom tk du graphe
#    xScreen yScreen  coordoonnees ecran de la souris
#  @return
#     rien
#------------------------------------------------------------
proc ::confVisu::onGraphRegionEnd { visuNo graph x y } {
   variable private

   if { [info exists private($visuNo,regionStartX)] } {
      set x0 $private($visuNo,regionStartX)
      set y0 $private($visuNo,regionStartY)
      $graph marker delete myLine
      set x [$graph axis invtransform x $x]
      set y [$graph axis invtransform y $y]
      onGraphZoom $visuNo $x0 $y0 $x $y

      unset private($visuNo,regionStartX)
      unset private($visuNo,regionStartY)
   }
}

#------------------------------------------------------------
# onGraphZoom
#  applique le zoom sur une region du graphe
#
# Parameters
#    visuNo  numero de la fenetre
#    graph   nom tk du graphe
#  @return
#     rien
#------------------------------------------------------------
proc ::confVisu::onGraphZoom { visuNo x1 y1 x2 y2 } {
   variable private

   set graph [::confVisu::getGraph $visuNo]

   if { $x1 > $x2 } {
      $graph axis configure x -min $x2 -max $x1
   } elseif { $x1 < $x2 } {
      $graph axis configure x -min $x1 -max $x2
   }
   if { $y1 > $y2 } {
      $graph axis configure y -min $y2 -max $y1
   } elseif { $y1 < $y2 } {
      $graph axis configure y -min $y1 -max $y2
   }
}

#------------------------------------------------------------
# onGraphUnzoom
#  supprime le zoom sur le graphe
#
# Parameters
#    visuNo  numero de la fenetre
#    graph   nom tk du graphe
#  @return
#     rien
#------------------------------------------------------------
proc ::confVisu::onGraphUnzoom { visuNo  } {
   variable private

   set graph $private($visuNo,This).graph
   $graph axis configure x y -min {} -max {}
}

#############################################################
#  Gestion d'une table
#############################################################

#------------------------------------------------------------
# createTable
#    passe en mode table (affichage d'une table)
#
#------------------------------------------------------------
proc ::confVisu::createTable { visuNo } {
   variable private

   set This $private($visuNo,This)

   package require Tablelist

   if { [winfo exists $This.ftable ] } {
      return
   }

   frame $This.ftable -borderwidth 0
      scrollbar $This.ftable.ysb -command "$This.ftable.table yview"
      scrollbar $This.ftable.xsb -command "$This.ftable.table xview" -orient horizontal
      ::tablelist::tablelist $This.ftable.table \
         -columns { 0 titre center } \
         -xscrollcommand [list $This.ftable.xsb set] \
         -yscrollcommand [list $This.ftable.ysb set] \
         -exportselection 0 \
         -selectmode single \
         -setfocus 1 \
         -activestyle none
      #--- je place la table et les scrollbars dans la frame
      grid $This.ftable.table -row 0 -column 0 -sticky ewns
      grid $This.ftable.ysb   -row 0 -column 1 -sticky nsew
      grid $This.ftable.xsb   -row 1 -column 0 -sticky ew
      grid rowconfig    $This.ftable  0 -weight 1
      grid columnconfig $This.ftable  0 -weight 1
}

#------------------------------------------------------------
# getTable
#    retourne le nom tk de la table
#
#------------------------------------------------------------
proc ::confVisu::getTable { visuNo } {
   variable private

   return $private($visuNo,This).ftable.table
}

#############################################################
#  Gestion de la barre d'outils
#############################################################

proc ::confVisu::createToolBar { visuNo } {
   variable private

   set tkToolbar $private($visuNo,This).bar.toolbar

   if { [winfo exists $tkToolbar ] } {
      #--- la barre d'outils existe deja
      grid $private($visuNo,This).bar -row 0 -column 1 -sticky ew
      return
   }

   #--- je cree la barre d'outils
   frame $tkToolbar -borderwidth 0 -cursor arrow
      Label $tkToolbar.labelHdu  -text $::caption(confVisu,fitsHduList)
      pack $tkToolbar.labelHdu  -side left -fill none -padx 2
      Button $tkToolbar.previous -text "<" -command "::confVisu::onChangeHdu $visuNo -1" -state disabled
      pack $tkToolbar.previous  -side left -fill none -padx 2
      set configList [list ]
      ComboBox $tkToolbar.combo \
         -width 40 -height 0 \
         -relief sunken -borderwidth 1 -editable 0 \
         -modifycmd "::confVisu::onSelectHdu $visuNo" \
         -values $configList
      pack $tkToolbar.combo -side left -fill none -padx 2
      Button $tkToolbar.next -text ">" -command "::confVisu::onChangeHdu $visuNo +1" -state disabled
      pack $tkToolbar.next -side left -fill none -padx 2
   pack $tkToolbar -anchor n -side top -expand 0 -fill x

}

#------------------------------------------------------------
# ::confVisu::deleteToolBar
#    supprime la barre d'outils
#
#------------------------------------------------------------
proc ::confVisu::deleteToolBar { visuNo } {
   variable private

   destroy $private($visuNo,This).bar.toolbar
}

#------------------------------------------------------------
# ::confVisu::showToolBar
#    affiche ou masque la barre d'outils
# parameters
#    visuNo : numero de la visu
#    state  : 1= affiche, 0= masque
#
#------------------------------------------------------------
proc ::confVisu::showToolBar { visuNo state} {
   variable private

   if { $state == 1 } {
      grid $private($visuNo,This).bar -row 0 -column 1 -sticky ew
   } else {
      grid forget $private($visuNo,This).bar
   }
}

#------------------------------------------------------------
# ::confVisu::getToolBar
#    retourne le nom TK de la barre d'outils
#
#------------------------------------------------------------
proc ::confVisu::getToolBar { visuNo } {
   variable private

   return $private($visuNo,This).bar.toolbar
}

#############################################################
#  Gestion des HDU FITS
#############################################################

#------------------------------------------------------------
# ::confVisu::initHduList
#    retourne la liste des HDU contenus dans le fichier FITS
# Parameters :
# @param visuNo : numero de la visu
# @param fileName nom du fichier FITS
# @return
#    liste du nom, type et nombre d'axes des HDU
#    exemple :
#    { { hduName hduType { naxis1 naxis2 ...} } { hduName1 hduType1 { naxis1 naxis2 ...} ... } ... }
#        avec hduType= Image ou Binary
#------------------------------------------------------------
proc ::confVisu::initHduList { visuNo fileName } {
   variable private

   if { [info command fits] == "" } {
      #--- si la commande fits n'existe pas, on ne peut lire que le premier HDU
      return ""
   }
   #--- je recupere la liste des HDU si on n'a pas precise le HDU en suffixe du nom de fichier
   set hFile ""
   set fitsHduList ""
   set catchResult [catch {
      #--- j'ouvre le fichier en mode lecture
      #--- remarque : je normalise le nom du fichier car "fits open" ne trouve pas les fichier du genre ./cdummy.fit
      if { [file extension $fileName] == "" } {
         append fileName $::conf(extension,defaut)
      }
      set hFile [fits open [file normalize $fileName] 0 ]
      set nbHdu [$hFile info nhdu]

      #--- je lis la liste des HDU
      set itemList ""
      for { set i 1 } { $i <= $nbHdu } { incr i } {
         set extensionType [$hFile move $i]
         if { $i == 1 } {
            set hduName  "PRIMARY"
         } else {
            set hduName [string trim [string map {"'" ""} [lindex [lindex [$hFile get keyword "EXTNAME"] 0] 1]]]
         }
         set hduType [lindex [$hFile info hdutype] 0]

         #--- je compose le libelle a mettre dans la combobox en fonction du type du HDU
         #---  si HDU image :   "hduName   width  X height"
         #---  si HDU table :   "hduName   nbcols X nbrows"
         switch $extensionType {
            0  {
               #--- c'est une image
               ###set hduNaxes [string map {" " " X "} [$hFile info imgdim]]
               set hduNaxes [$hFile info imgdim]
            }
            1 {
               #--- c'est une table ASCII
               ###set hduNaxes "[$hFile info ncols] cols X [$hFile info nrows] rows"
               set hduNaxes [list [$hFile info ncols] [$hFile info nrows] ]
            }
            2 {
               #--- c'est une table BINARY
               ###set hduNaxes "[$hFile info ncols] cols X [$hFile info nrows] rows"
               set hduNaxes [list [$hFile info ncols] [$hFile info nrows] ]
            }
         }
         lappend itemList [list $hduName $hduType $hduNaxes ]
      }
      set fitsHduList $itemList

   } ]

   #--- je ferme le fichier
   if { $hFile != "" } {
      $hFile close
   }

   if { $catchResult == 1 } {
      #--- ce n'est pas une image FITS
      return ""
   }

   return $fitsHduList
}

#------------------------------------------------------------
# ::confVisu::getHduList
#    retourne la liste des HDU
#
#    format :  { $hduName $hduType $hduNaxes }
#------------------------------------------------------------
proc ::confVisu::getHduList { visuNo } {
   variable private

   return $private($visuNo,fitsHduList)
}

#------------------------------------------------------------
# ::confVisu::getHduName
#    retourne le nom du HDU courant
#
# @param visuNo : numero de la visu
# @return nom du HDU  ( chaine vide si l'image n'est pas une image FITS)
#------------------------------------------------------------
proc ::confVisu::getHduName { visuNo } {
   variable private

   if { [llength $private($visuNo,fitsHduList)] > 0 } {
      #--- je recupere le nom du HDU numero $private($visuNo,currentHduNo)
      set hduName [lindex [ lindex $private($visuNo,fitsHduList) [expr $private($visuNo,currentHduNo) -1] 0 ]]
   } else {
      set hduName ""
   }
   return $hduName
}

#------------------------------------------------------------
# ::confVisu::getHduNo
#    retourne le numero du HDU courant
#
# @param visuNo : numero de la visu
# @return numero du HDU ( le numero du premier HDU est 1)
#------------------------------------------------------------
proc ::confVisu::getHduNo { visuNo } {
   variable private

   return $private($visuNo,currentHduNo)
}

#------------------------------------------------------------
# ::confVisu::showHduList
#    affiche la liste des HDU dans la barre d'outils
#    et selectionne un HDU
#  Parameters
#     visuNo : numero de la fenetre de profil
#     hduNo  : numero du HDU
#  @return
#     rien
#------------------------------------------------------------
proc ::confVisu::showHduList { visuNo { hduNo 1 } } {
   variable private

   set tkToolbar $private($visuNo,This).bar.toolbar

   #--- je prepare les lignes a affiche dans la combo
   set tempHduNo 0
   set valueList ""
   foreach item $private($visuNo,fitsHduList) {
      incr tempHduNo
      set hduName  [lindex $item 0]
      set hduType  [lindex $item 1]
      ###set hduNaxes [lindex $item 2]
      set hduNaxes [string map {" " " X "} [lindex $item 2]]
      lappend valueList [format "#% 2s %10s %8s %12s" $tempHduNo $hduName $hduType $hduNaxes]
   }

   if { [llength $valueList] < 24  } {
      set height [llength $valueList]
   } else {
      set height 24
   }

   #--- je configure la combo
   $tkToolbar.combo configure -values $valueList -height $height

   #--- je selectionne le HDU
   if { $hduNo <= $tempHduNo } {
      set index [expr $hduNo -1]
   } else {
      set index 0
   }
   $tkToolbar.combo setvalue "@$index"

   #--- je mets a jour les boutons de la barre d'outils
   if { $index == 0 } {
      $tkToolbar.previous configure -state disabled
   } else {
      $tkToolbar.previous configure -state normal
   }

   if { $index == [expr [llength $private($visuNo,fitsHduList)] - 1]  } {
      $tkToolbar.next configure -state disabled
   } else {
      $tkToolbar.next configure -state normal
   }
}

#------------------------------------------------------------
#  onChangeHdu
#    affiche le contenu du HDU suivant ou precedent
#  Parameters
#     visuNo : numero de la fenetre de profil
#     increment : numero relatif du HDU cible ( +1 ou -1)
#  @return
#     rien
#------------------------------------------------------------
proc ::confVisu::onChangeHdu { visuNo increment  } {
   variable private

   #--- je recupere le numero de HDU courant
   set index [$private($visuNo,This).bar.toolbar.combo getvalue]
   #--- j'increment le numero de HDU
   set hduNo [expr $index + $increment + 1]

   #--- je verifie que le numero correspond a un HDU qui existe
   if { $hduNo <1 && $hduNo > [llength $private($visuNo,fitsHduList)] } {
      return
   }

   #--- je selectionne et j'affiche le contenu du HDU
   ::confVisu::onSelectHdu $visuNo $hduNo
}

#------------------------------------------------------------
#  onSelectHdu
#    affiche le contenu du HDU
#    si le parametre index n'est pas fourni, le HDU selectionné dans la combobox est affiché
#  Parameters
#     profileNo : numero de la fenetre de profil
#     index :     numero du HDU a afficher (1 pour le premier HDU)
#  @return
#     rien
#------------------------------------------------------------
proc ::confVisu::onSelectHdu { visuNo { hduNo "" } } {
   variable private

   if { $hduNo == "" } {
      #--- je recupere l'index du HDU dans la combo (index commence a 0)
      set index [$private($visuNo,This).bar.toolbar.combo getvalue]
      if { $index == -1 } {
         #--- je prends le premier HDU si aucun n'est deja selectionné
         set hduNo 1
      } else {
         set hduNo [expr $index +1]
      }
   }

   #--- je selectionne la ligne dans la combobox de HDU
   $private($visuNo,This).bar.toolbar.combo setvalue "@[expr $hduNo -1]"

   #--- j'affiche le HDU
   ::confVisu::loadIma $visuNo "[getFileName $visuNo];$hduNo"

   ###set hFile ""
   ###::blt::busy hold $private($visuNo,This)
   ###update
   ###
   ###set catchResult [catch {
   ###   #--- j'ouvre le fichier en mode lecture
   ###   set hFile [fits open [getFileName $visuNo] 0]
   ###   set extensionType [$hFile move $hduNo]
   ###
   ###   if { $extensionType == 0 } {
   ###      #--- c'est une image
   ###      set hduNaxes [$hFile info imgdim]
   ###      if { [llength $hduNaxes] == 1
   ###         || ( [llength $hduNaxes] == 2 && [lindex $hduNaxes 1 ] == 1 ) } {
   ###         #--- c'est une image de dimension 1, j'affiche un profil
   ###         loadIma $visuNo "[getFileName $visuNo];$hduNo"
   ###      } else {
   ###         #--- c'est une image de dimension 2 ou plus, j'affiche une image
   ###         loadIma $visuNo "[getFileName $visuNo];$hduNo"
   ###      }
   ###   } else {
   ###      #--- c'est une table
   ###      ::confVisu::loadIma $visuNo "[getFileName $visuNo];$hduNo"
   ###   }
   ###} ]
   ###
   ###if { $hFile != "" } {
   ###   $hFile close
   ###}
   ###::blt::busy release $private($visuNo,This)
   ###
   ###if { $catchResult == 1 } {
   ###   tk_messageBox -message  $::errorInfo -icon error -title "$::caption(audace,titre) (visu$visuNo)"
   ###   ::console::affiche_erreur "$::errorInfo\n"
   ###}

   #--- je mets a jour les boutons de la barre d'outils
   if { $hduNo == 1 } {
      $private($visuNo,This).bar.toolbar.previous configure -state disabled
   } else {
      $private($visuNo,This).bar.toolbar.previous configure -state normal
   }

   if { $hduNo == [expr [llength $private($visuNo,fitsHduList)] ]  } {
      $private($visuNo,This).bar.toolbar.next configure -state disabled
   } else {
      $private($visuNo,This).bar.toolbar.next configure -state normal
   }

   #--- je mets a jour la variable a la fin de la procedure car elle est surveillee par un listener
   ###set private($visuNo,currentHduNo) $hduNo
}

::confVisu::init

############################ Fin du namespace confVisu ############################

# Auteur : Raymond ZATCHANTKE

namespace eval ::colorRGB {

   #########################################################################
   #--- Filtre l'image et lit les seuils dans l'en-tête FITS               #
   #########################################################################
   proc run { visuNo } {
      variable private

      #--- j'initialise les glissieres RVB
      ::colorRGB::initConf $visuNo

      #--- je recopie les variables conf dans des variables locales
      ::colorRGB::confToWidget $visuNo

      #--- je recupere les seuils de l'image affichee
      set mycuts [visu$visuNo cut]

      #--- fenetre de base
      set base $::confVisu::private($visuNo,This)

      #---
      set private($visuNo,This) $base.colorRGB
      if { [ winfo exists $private($visuNo,This) ] } {
         #--- actualise les glissieres
         ::colorRGB::configureScale $visuNo
      } else {
         if { [ info exists private(colorRGB,$visuNo,geometry) ] } {
            set deb [ expr 1 + [ string first + $private(colorRGB,$visuNo,geometry) ] ]
            set fin [ string length $private(colorRGB,$visuNo,geometry) ]
            set private(colorRGB,$visuNo,position) "+[string range $private(colorRGB,$visuNo,geometry) $deb $fin]"
         }
         ::colorRGB::createDialog $visuNo
      }
   }

   #########################################################################
   #--- Initialisation des variables de configuration                      #
   #########################################################################
   proc initConf { visuNo } {
      variable private
      global conf

      if { ! [ info exists conf(colorRGB,visu$visuNo,position) ] } { set conf(colorRGB,visu$visuNo,position) "+350+75" }

      set private(colorRGB,child) [ list hir lor hig log hib lob ]
   }

   #########################################################################
   #--- Charge les variables de configuration dans des variables locales   #
   #########################################################################
   proc confToWidget { visuNo } {
      variable private
      global conf

      set private(colorRGB,$visuNo,position) "$conf(colorRGB,visu$visuNo,position)"
   }

   #########################################################################
   #--- Charge les variables locales dans des variables de configuration   #
   #########################################################################
   proc widgetToConf { visuNo } {
      variable private
      global conf

      set conf(colorRGB,visu$visuNo,position) "$private(colorRGB,$visuNo,position)"
   }

   #########################################################################
   #--- Recupere la position de la fenetre                                 #
   #########################################################################
   proc recupPosition { visuNo } {
      variable private

      set private(colorRGB,$visuNo,geometry) [ wm geometry $private($visuNo,This) ]
      set deb [ expr 1 + [ string first + $private(colorRGB,$visuNo,geometry) ] ]
      set fin [ string length $private(colorRGB,$visuNo,geometry) ]
      set private(colorRGB,$visuNo,position) "+[string range $private(colorRGB,$visuNo,geometry) $deb $fin]"
      #---
      ::colorRGB::widgetToConf $visuNo
   }

   #########################################################################
   #--- Cree la fenetre de reglage des seuils                              #
   #########################################################################
   proc createDialog { visuNo } {
      variable private
      global audace caption

      toplevel $private($visuNo,This)
      wm resizable $private($visuNo,This) 0 0
      wm deiconify $private($visuNo,This)
      wm title $private($visuNo,This) "$caption(confVisu,label_1) (visu$visuNo)"
      wm geometry $private($visuNo,This) $private(colorRGB,$visuNo,position)
      wm transient $private($visuNo,This) [ winfo parent $private($visuNo,This) ]
      wm protocol $private($visuNo,This) WM_DELETE_WINDOW "::colorRGB::suppression"

      #--- frame des glissieres
      frame $private($visuNo,This).val_variant -borderwidth 2 -relief raised

         Label $private($visuNo,This).val_variant.title_1 -text $caption(confVisu,label_2)
         grid $private($visuNo,This).val_variant.title_1 -row 0 -column 0
         Label $private($visuNo,This).val_variant.title_2 -text $caption(confVisu,label_3)
         grid $private($visuNo,This).val_variant.title_2 -row 0 -column 2

         #--- les glissieres pour le rouge
         ::colorRGB::createScale $visuNo $private($visuNo,This).val_variant lor 1 0
         Label $private($visuNo,This).val_variant.color_invariant_R -text "  " \
            -bg $audace(color,cursor_rgb_red)
         grid $private($visuNo,This).val_variant.color_invariant_R -row 1 -column 1 -sticky s
         ::colorRGB::createScale $visuNo $private($visuNo,This).val_variant hir 1 2

         #--- les glissieres pour le vert
         ::colorRGB::createScale $visuNo $private($visuNo,This).val_variant log 2 0
         Label $private($visuNo,This).val_variant.color_invariant_V -text "  " \
            -bg $audace(color,cursor_rgb_green)
         grid $private($visuNo,This).val_variant.color_invariant_V -row 2 -column 1 -sticky s
         ::colorRGB::createScale $visuNo $private($visuNo,This).val_variant hig 2 2

         #--- les glissieres pour le bleu
         ::colorRGB::createScale $visuNo $private($visuNo,This).val_variant lob 3 0
         Label $private($visuNo,This).val_variant.color_invariant_B -text "  " \
            -bg $audace(color,cursor_rgb_blue)
         grid $private($visuNo,This).val_variant.color_invariant_B -row 3 -column 1 -sticky s
         ::colorRGB::createScale $visuNo $private($visuNo,This).val_variant hib 3 2

      pack $private($visuNo,This).val_variant

      #--- actualise les glissieres
      ::colorRGB::configureScale $visuNo

      #--- Focus
      focus $private($visuNo,This)

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $private($visuNo,This)
   }

   #########################################################################
   #--- Rafraichit la liste des seuils et la visu                          #
   #########################################################################
   proc updateVisu { visuNo } {
      variable private

      #--- rafraichit la liste des 6 seuils
      set mycuts ""
      foreach scale $private(colorRGB,child) {
         lappend mycuts [ $private($visuNo,This).val_variant.$scale get ]
      }

      #--- rafraichit la visu
      visu$visuNo cut $mycuts
      visu$visuNo disp

      #--- actualise les glissieres
      ::colorRGB::configureScale $visuNo

   }

   #########################################################################
   #--- Configure les glissieres                                           #
   #########################################################################
   proc configureScale { visuNo } {
      variable private

      set mycuts [visu$visuNo cut]

      #--- etablit la liste des seuils bas et haut pour chaque couleur
      foreach indice [ list 0 2 4 ] color [ list r g b ] {

         #--- isole la valeur des seuils
         set maxi [ expr { int([ lindex $mycuts $indice ]) } ]
         incr indice
         set mini [ expr { int([ lindex $mycuts $indice ]) } ]

         #--- inverse les seuils si lo > hi
         if { $maxi < $mini } {
            set mycuts [ lreplace $mycuts $indice $indice $maxi ]
            incr indice -1
            set mycuts [ lreplace $mycuts $indice $indice $mini ]
         }

         set range [ expr $maxi-$mini ]
         if { [ expr $range ] == "0.0" } { set range 10000 }

         set mini [ expr int($mini-$range) ]
         set maxi [ expr int($maxi+$range) ]

         set mini_maxi_$color [ list $mini $maxi ]

      }

      #--- calcule la nouvelle dynamique de deplacement des curseurs a ressort
      if { $::conf(seuils,auto_manuel) == 1 } {

         #--- configure les mini et maxi de chaque glissiere
         foreach child $private(colorRGB,child) {

            #--- identifie le plan couleur
            set color [ string range $child end end ]

            #--- selectionne la bonne liste de seuils
            set seuils [ set mini_maxi_$color ]

            #--- configure le mini et le maxi
            $private($visuNo,This).val_variant.$child configure \
               -from [ lindex $seuils 0 ] -to [ lindex $seuils 1 ] -resolution 1

            #--- fixe la valeur de chaque glissiere
            set index [ lsearch -exact $private(colorRGB,child) $child ]
            set val [ expr { int([ lindex $mycuts $index ]) } ]
            $private($visuNo,This).val_variant.$child set $val

         }

      #--- calcule la nouvelle dynamique de deplacement des curseurs normaux
      } elseif { $::conf(seuils,auto_manuel) == 2 } {

         #--- configure les mini et maxi de chaque glissiere
         foreach child $private(colorRGB,child) {

            $private($visuNo,This).val_variant.$child configure -from $::confVisu::private($visuNo,mindyn) -to $::confVisu::private($visuNo,maxdyn)

         }

      }

   }

   #########################################################################
   #--- Sauve les nouveaux reglages dans l'en-tete FITS                    #
   #########################################################################
   proc saveKWD { visuNo } {
      variable private

      #--- initialise une variable
      set private(colorRGB,child) [ list hir lor hig log hib lob ]

      #--- recupere le numero du buffer de la visu
      set bufNo [ ::confVisu::getBufNo $visuNo ]

      #--- definit un mot cle inexistant
      set mot_vide "{} {} {none} {} {}"

      #--- je recupere les seuils de liimage dans la visu
      set mycuts [visu$visuNo cut]

      foreach scale $private(colorRGB,child) {

         #--- definit le mot cle a rechercher
         set kwd "MIPS-[ string toupper $scale ]"

         #--- capture le contenu du mot cle
         #--- retourne un mot vide si le kwd n'existe pas
         set data [ buf$bufNo getkwd $kwd ]

         #--- analyse le contenu du mot cle
         if { $data != $mot_vide } {

            #--- si le mot contient le mot cle recherche
            #--- procédure normale
            #--- recherche le rang dans la liste
            set i [ lsearch $private(colorRGB,child) $scale ]

            #--- remplace la valeur par la valeur actuelle
            set data [ lreplace $data 1 1 [ lindex $mycuts $i ] ]

         } else {

            #--- si le mot cle est vide
            #--- par defaut cherche MIPS-HI ou MIPS-LO en lieu et place des seuils couleurs
            set defaut_kwd "MIPS-[ string range [ string toupper $scale ] 0 1 ]"

            #--- lit le mot cle
            set data [ buf$bufNo getkwd $defaut_kwd ]

            #--- substitue MIPS-HI par MIPS-HIR etc.
            set data [ lreplace $data 0 0 $kwd ]

         }

         #--- sauve le mot cle modifie
         buf$bufNo setkwd $data

      }
   }

   #########################################################################
   #--- Fermeture de le fenetre                                            #
   #########################################################################
   proc cmdClose { visuNo } {
      variable private

      if { [ info exists private($visuNo,This) ] } {
         if { [ winfo exists $private($visuNo,This) ] } {
            ::colorRGB::recupPosition $visuNo
            destroy $private($visuNo,This)
            unset private($visuNo,This)
         }
      }
   }

   #########################################################################
   #--- Empeche la fenetre d'etre effacee                                  #
   #########################################################################
   proc suppression { } {
   }

   #########################################################################
   #--- Cree une glissiere                                                 #
   #    parametres : nom de la fenetre parent, enfant, row et column       #
   #########################################################################
   proc createScale { visuNo parent child r c } {
      variable private

      scale $parent.$child -orient horizontal -length 150 -width 10 -showvalue 1 \
         -sliderlength 20 -sliderrelief raised -borderwidth 1
      grid $parent.$child -in $parent -row $r -column $c
      #--- binding permettant de recuperer la valeur et de rafraichir la visu
      bind $parent.$child <ButtonRelease> "::colorRGB::updateVisu $visuNo"
   }
}

############################ Fin du namespace colorRGB ############################

