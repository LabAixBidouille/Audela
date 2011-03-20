##
# @file photometrie_if.tcl
#
# @author Jacques Michelet (jacques.michelet@aquitania.org)
#
# @brief Outil pour l'analyse photométrique d'une image.
#
# $Id$
#

namespace eval ::Photometrie {
    package provide photometrie 1.1

    source [ file join [ file dirname [ info script ] ] photometrie.cap ]
    source [ file join [ file dirname [ info script ] ] photometrie.tcl ]

    #------------------------------------------------------------
    # getPluginTitle
    #    retourne le titre du plugin dans la langue de l'utilisateur
    #------------------------------------------------------------
    proc getPluginTitle { } {
      variable photometrie_texte

      return "$photometrie_texte(titre_menu)"
    }

    #------------------------------------------------------------
    # getPluginHelp
    #    retourne le nom du fichier d'aide principal
    #------------------------------------------------------------
    proc getPluginHelp { } {
        return ""
    }

    #------------------------------------------------------------
    # getPluginType
    #    retourne le type de plugin
    #------------------------------------------------------------
    proc getPluginType { } {
        return "tool"
    }

    #------------------------------------------------------------
    # getPluginDirectory
    #    retourne le type de plugin
    #------------------------------------------------------------
    proc getPluginDirectory { } {
        return "photometry"
        }

    #------------------------------------------------------------
    # getPluginOS
    #    retourne le ou les OS de fonctionnement du plugin
    #------------------------------------------------------------
    proc getPluginOS { } {
        return [ list Linux Windows ]
    }

    #------------------------------------------------------------
    # getPluginProperty
    #    retourne la valeur de la propriete
    #
    # parametre :
    #    propertyName : nom de la propriete
    # return : valeur de la propriete ou "" si la propriete n'existe pas
    #------------------------------------------------------------
    proc getPluginProperty { propertyName } {
        switch $propertyName {
            function     { return "analysis" }
            subfunction1 { return "photometry" }
            display      { return "window" }
        }
    }

    #------------------------------------------------------------
    # initPlugin
    #    initialise le plugin
    #------------------------------------------------------------
    proc initPlugin { tkbase } {
        variable This
        variable widget
        global caption conf

        #--- Inititalisation du nom de la fenetre
        set This "$tkbase"

        if { [ catch { load libjm[info sharedlibextension]} erreur ] } {
            ::console::affiche_erreur "$erreur \n"
            return 1
        }

        if { [ catch { jm_versionlib } version_lib ] } {
            ::console::affiche_erreur "$version_lib \n"
            return 1
        } else {
            if { [ expr double( [ string range $version_lib 0 2 ] ) ] < 4.0 } {
                ::console::affiche_erreur "LibJM version must be greater than 4.0\n"
                return 1
            }
        }
    }

    #------------------------------------------------------------
    # createPluginInstance
    #    cree une nouvelle instance de l'outil
    #------------------------------------------------------------
    proc createPluginInstance { { in "" } { visuNo 1 } } {

    }

    #------------------------------------------------------------
    # deletePluginInstance
    #    suppprime l'instance du plugin
    #------------------------------------------------------------
    proc deletePluginInstance { visuNo } {

    }

    #------------------------------------------------------------
    # startTool
    #    affiche la fenetre de l'outil
    #------------------------------------------------------------
    proc startTool { visuNo } {
        #--- J'ouvre la fenetre
        ::Photometrie::Principal
    }

    #------------------------------------------------------------
    # stopTool
    #    masque la fenetre de l'outil
    #------------------------------------------------------------
    proc stopTool { visuNo } {
        #--- Rien a faire, car la fenetre est fermee par l'utilisateur
    }
}

