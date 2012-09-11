##
# @file calaphot.tcl
#
# @author Olivier Thizy (thizy@free.fr) & Jacques Michelet (jacques.michelet@laposte.net)
#
# @brief Script pour la photométrie d'asteroides ou d'etoiles variables.
#
# $Id$
#

namespace eval ::CalaPhot {
    package provide calaphot 7.1
    #   package require BLT
    source [ file join [ file dirname [ info script ] ] calaphot_cap.tcl ]
    source [ file join [ file dirname [ info script ] ] calaphot_graph.tcl ]
    source [ file join [ file dirname [ info script ] ] calaphot_calcul.tcl ]
    source [ file join [ file dirname [ info script ] ] calaphot_sex.tcl ]
#    source [ file join [ file dirname [ info script ] ] calaphot_catalogues.tcl ]
    source [ file join [ file dirname [ info script ] ] calaphot_principal.tcl ]

    #------------------------------------------------------------
    # getPluginTitle
    #    retourne le titre du plugin dans la langue de l'utilisateur
    #------------------------------------------------------------
    proc getPluginTitle { } {
        variable calaphot

        return "$calaphot(texte,titre_menu)"
    }

    #------------------------------------------------------------
    # getPluginHelp
    #    retourne le nom du fichier d'aide principal
    #------------------------------------------------------------
    proc getPluginHelp { } {
        return "calaphot.htm"
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
        return "calaphot"
    }

    #------------------------------------------------------------
    # getPluginOS
    #    retourne le ou les OS de fonctionnement du plugin
    #------------------------------------------------------------
    proc getPluginOS { } {
        return [ list Windows Linux Darwin ]
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
            subfunction1 { return "photometry_time_serie" }
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

        if {[catch {load libjm[info sharedlibextension]} erreur]} {
            ::console::affiche_erreur "$erreur \n"
            return 1
        }

        if {[catch {jm_versionlib} version_lib]} {
            ::console::affiche_erreur "$version_lib \n"
            return 1
        } else {
            if {[expr double([string range $version_lib 0 2])] < 3.0} {
                ::console::affiche_erreur "LibJM version must be greater than 3.0\n"
                return 1
            }
        }
        catch { package require BLT } erreur
        if { $erreur != "2.4" } {
            catch {load blt24[info sharedlibextension]} erreur
            if {$erreur !=    ""} {
                ::console::affiche_erreur "$erreur\n"
                return 1
            } else {
                if {[catch {package require BLT} erreur]} {
                    ::console::affiche_erreur "$erreur\n"
                    return 1
                }
            }
        }
        package require BWidget
        package require http
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
        ::CalaPhot::Principal
    }

    #------------------------------------------------------------
    # stopTool
    #    masque la fenetre de l'outil
    #------------------------------------------------------------
    proc stopTool { visuNo } {
        #--- Rien a faire, car la fenetre est fermee par l'utilisateur
    }
}

