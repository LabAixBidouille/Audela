#
# Fichier : vo_tools.tcl
# Description : Outils pour l'Observatoire Virtuel
# Auteur : Alain KLOTZ et Jerome BERTHIER
# Mise a jour $Id: vo_tools.tcl,v 1.9 2007-03-11 19:14:40 robertdelmas Exp $
#

# ------------------------------------------------------------------------------------
#
# proc        : vo_aladin { }
# Description : Lancement de Aladin depuis Audace
# Auteur      : Alain KLOTZ
# Update      : 03 july 2005
#
# ------------------------------------------------------------------------------------

# --- deplacer ces inits
if { $::tcl_platform(os) == "Linux" } {
   set audace(rep_java) "C:/j2sdk1.4.2_06/jre/bin"
   set audace(rep_aladinjar) "c:/vo/votal/"
} elseif { $::tcl_platform(os) == "Darwin" } {
   set audace(rep_java) "C:/j2sdk1.4.2_06/jre/bin"
   set audace(rep_aladinjar) "c:/vo/votal/"
} else {
   set audace(aladin) "C:/Program Files/Aladin"
}

proc vo_aladin { args } {
   global audace
   global conf

   set argc [llength $args]
   if {$argc == 0} {
      error "Usage: method ?options?"
      return
   }

   set method [lindex $args 0]

   if {$method=="load"} {
      # vo_aladin load j1 {USNO-B DSS2}
      if {$argc <= 1} {
         error "Usage: $method filename ?{catalogs}"
         return
      }
      #
      set texte "#AJS\n"
      append texte "#Aladin Java Script created by AudeLA\n"
      #
      set fname [lindex $args 1]
      set ftail [file tail $fname]
      set fdirname [file dirname $fname]
      set fextension [file extension $ftail]
      #::console::affiche_resultat "fdirname=<$fdirname>\n"
      if {($fdirname=="")||($fdirname==".")} {
         set fdirname $audace(rep_images)
      }
      if {$fextension==""} {
         set fextension $conf(extension,defaut)
      }
      set fname [file join $fdirname ${ftail}${fextension}]
      append texte "load $fname \n"
      #
      set catalogs [lindex $args 2]
      if {[llength $catalogs]>0} {
         buf$audace(bufNo) load "$fname"
         set naxis1 [lindex [buf$audace(bufNo) getkwd NAXIS1] 1]
         set naxis2 [lindex [buf$audace(bufNo) getkwd NAXIS2] 1]
         set res [buf$audace(bufNo) xy2radec [list [expr $naxis1/2] [expr $naxis2/2]] ]
         set ra [mc_angle2hms [lindex $res 0]]
         set dec [mc_angle2dms [lindex $res 1] 90]
         set coords "$ra $dec"
         set cdelt1 [lindex [buf$audace(bufNo) getkwd CDELT1] 1]
         set cdelt2 [lindex [buf$audace(bufNo) getkwd CDELT2] 1]
         set fieldx [expr $cdelt1*$naxis1*60.]
         set fieldy [expr $cdelt2*$naxis2*60.]
         if {$fieldx>$fieldy} {
            set fieldarcmin $fieldx
         } else {
            set fieldarcmin $fieldy
         }
         foreach catalog $catalogs {
            if {$catalog=="USNO-B1"} { set catalog Vizier(I/284) }
            if {$catalog=="DSS2"}    { set catalog Aladin(DSS2) }
            append texte "get $catalog $coords ${fieldarcmin}'\n"
         }
      }
      #
      set fnameajs [file join $audace(rep_scripts) ${ftail}.ajs]
      set f [open "$fnameajs" w]
      puts -nonewline $f $texte
      close $f
      #
      if { $::tcl_platform(os) == "Linux" } {
         open "|\"${audace(rep_java)}/java\" -jar \"${audace(rep_aladinjar)}/Aladin.jar\" < \"$fnameajs\" " w+
      } elseif { $::tcl_platform(os) == "Darwin" } {
         open "|\"${audace(rep_java)}/java\" -jar \"${audace(rep_aladinjar)}/Aladin.jar\" < \"$fnameajs\" " w+
      } else {
         open "|\"${audace(aladin)}/aladin.exe\" \"$fnameajs\" " w+
      }
   } else {
      #--- Exemple : vo_aladin load m57 USNO-B1
      #--- Exemple : vo_aladin load m57 { USNO-B1 DSS2 }
      error "Usage: load ?parameters?"
      return
   }
   return $texte
}

# ------------------------------------------------------------------------------------
#
# proc        : vo_launch_aladin { coord radius [survey] [catalog] }
#                 avec  coord    = coordonnees du centre du FOV
#                       radius   = rayon du FOV en arcmin
#                       survey   = nom du survey-image
#                       catalog  = nom du catalogue d'objets pour la reconnaissance
#                       epoch    = date de l'observation
#
# Description : Aladin java launcher
# Auteur      : Jerome BERTHIER
# Update      : 10 mars 2007
#
# Ce script lance le client Aladin dans le navigateur par defaut
# et affiche l'image <survey> (par defaut DSS2) centree aux coord. <coord> +/- <radius>
# plus, eventuellement, les objets reconnus par VizieR(<catalog>)
#
# Exemple: vo_launch_aladin "05 35 17.3 -05 23 28" 10 DSS2 USNO2
#
# ------------------------------------------------------------------------------------

proc vo_launch_aladin { args } {

   set unit "arcmin"
   set url_aladin "http://aladin.u-strasbg.fr/java/nph-aladin.pl?from=Audela"

   set argc [llength $args]
   if {$argc >= 2} {
      regsub -all "\"" [lindex $args 0] "" coord
      set radius [lindex $args 1]
      set survey "DSS2"
      if {$argc >= 3} { set survey [lindex $args 2] }
      set catalog "USNO2"
      if {$argc >= 4} { set catalog [lindex $args 3] }
      set epoch "now"
      if {$argc >= 5} { set epoch [lindex $args 4] }

      #--- construction de l'URL
      set url_args [ concat "&script=get Aladin($survey) $coord $radius$unit;sync;get VizieR($catalog);get SkyBoT.IMCCE($epoch,500,'120 arcsec')" ]
      set goto_url [ concat $url_aladin$url_args ]
      #--- invocation de l'url
      ::audace::Lance_Site_htm $goto_url

   } else {

      error "Usage: vo_launch_aladin Coord Radius [Survey Catalog Epoch]"

   }

}

# ------------------------------------------------------------------------------------
# variable     : XML character mapping
#
# Auteur       : David Gravereaux
# Update       : 21 may 2006
#
# WARNING! May be incomplete
# ------------------------------------------------------------------------------------
variable entityMap [list & &amp\; < &lt\; > &gt\; \" &quot\;\
        \u0000 &#x0\; \u0001 &#x1\; \u0002 &#x2\; \u0003 &#x3\;\
        \u0004 &#x4\; \u0005 &#x5\; \u0006 &#x6\; \u0007 &#x7\;\
        \u0008 &#x8\; \u000b &#xB\; \u000c &#xC\; \u000d &#xD\;\
        \u000e &#xE\; \u000f &#xF\; \u0010 &#x10\; \u0011 &#x11\;\
        \u0012 &#x12\; \u0013 &#x13\; \u0014 &#x14\; \u0015 &#x15\;\
        \u0016 &#x16\; \u0017 &#x17\; \u0018 &#x18\; \u0019 &#x19\;\
        \u001A &#x1A\; \u001B &#x1B\; \u001C &#x1C\; \u001D &#x1D\;\
        \u001E &#x1E\; \u001F &#x1F\;]

proc vo_entityEncode {text} {
   variable entityMap
   return [string map $entityMap $text]
}

# ------------------------------------------------------------------------------------
# proc        : vo_skybotXML { [proVarName] [args] }
#                 avec procVarName = SOAP methodName
#                      args        = all the parameters required for the method call
#
# Description : Skybot webservices
# Auteur      : inconnu
# Update      : 21 may 2006
#
# Generic skybot XML generation procedure to wrap up the method parameters for
# transport to the server. The procedure returns the generated XML data for the
# RPC call
# ------------------------------------------------------------------------------------
proc vo_skybotXML {procVarName args} {
   variable skybot_xml
   set procName [lindex [split $procVarName {_}] end]
   foreach {key val} $args {
      set $key [vo_entityEncode $val]
   }
   return [subst $skybot_xml($procName)]
}

# ------------------------------------------------------------------------------------
# proc        : vo_skybot { [JD] [RA] [DEC] [radius] [mime] [out] [observer] [filter] }
#                 avec  JD       = jour julien de l'epoque consideree
#                       RA,DEC   = coordonnees equatoriales J2000 du centre du FOV (degres)
#                       radius   = rayon du FOV en arcsec
#                       mime     = format de la reponse ('text', 'votable', 'html')
#                       out      = choix des donnees en sortie ('object', 'basic','all')
#                       observer = code UAI de l'observatoire
#                       filter   = filtre sur l'erreur de position
#
# Description : Skybot webservice
# Auteur      : Jerome BERTHIER &amp; Alain KLOTZ
# Update      : 11 juin 2006
#
# Ce script interroge la base SkyBoT afin de fournir la liste et les coordonnees
# de tous les corps du systeme solaire contenus dans le FOV a l'epoque et aux
# coordonnees RA,DEC considerees.
#
# La reponse est une liste d'elements contenant les data.
# Le premier element de la liste est le nom des colonnees recuperees.
#
# Plus d'info: http://skybot.imcce.fr
#
# Dans la console, une fois la cmde executee, on peut executer:
#    SOAP::dump -request skybotresolver
#    SOAP::dump -reply skybotresolver
# afin de visualiser le texte de la requete et de la reponse SOAP.
#
# ------------------------------------------------------------------------------------

proc vo_skybot { args } {
   global audace
   global conf

   package require SOAP

   set argc [llength $args]
   if {$argc >= 4} {
      set jd [mc_date2jd [lindex $args 0]]
      set RA [mc_angle2deg [lindex $args 1]]
      set DEC [mc_angle2deg [lindex $args 2] 90]
      set radius [lindex $args 3]
      set mime "text"
      if {$argc >= 5} { set mime [lindex $args 4] }
      set out "basic"
      if {$argc >= 6} { set out [lindex $args 5] }
      set observer "500"
      if {$argc >= 7} { set observer [lindex $args 6] }
      set filter "0"
      if {$argc >= 8} { set filter [lindex $args 7] }

      # The XML below is ripped straight from the generated SkyBoTBinding.skybotresolver.req.xml
      variable skybot_xml
      array set skybot_xml {
        skybot {<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope
 xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
 xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xmlns:xsd="http://www.w3.org/2001/XMLSchema"
 xmlns:ns1="http://www.imcce.fr/webservices/skybot">
 <SOAP-ENV:Body SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <ns1:skybot>
   <inputArray>
    <epoch>${epoch}</epoch>
    <alpha>${RA}</alpha>
    <delta>${DEC}</delta>
    <radius>$radius</radius>
    <mime>$mime</mime>
    <output>$out</output>
    <observer>$observer</observer>
    <filter>$filter</filter>
   </inputArray>
  </ns1:skybot>
 </SOAP-ENV:Body>
   </SOAP-ENV:Envelope>}
}
      SOAP::create skybot \
         -uri "http://www.imcce.fr/webservices/skybot" \
         -proxy "http://www.imcce.fr/webservices/skybot/skybot.php" \
         -name "skybot" \
         -wrapProc vo_skybotXML \
         -params { epoch double alpha double delta double radius string mime string out string observer string filter string }

      set erreur [ catch { skybot epoch $jd RA $RA DEC $DEC radius $radius mime $mime out $out observer $observer filter $filter } response ]

      set flag [lindex 1]
      set result [lindex $response 5]
      if { $erreur == "0" && $flag >= 0 } {
         return $result
      } else {
         tk_messageBox -title "error" -type ok -message $result
         return "failed"
      }

   } else {

      error "Usage: vo_skybot Epoch RA_J2000 DEC_J2000 Radius(arcsec) ?text|votable|html? ?object|basic|all? Observer Filter(arcsec)"

   }
}

# ------------------------------------------------------------------------------------
# proc        : vo_skybotresolver { [JD] [target] [mime] [out] [observer] }
#                 avec  JD       = jour julien de l'epoque consideree
#                       target   = nom ou numero ou designation provisoire de l'objet
#                       mime     = format de la reponse ('text', 'votable', 'html')
#                       out      = choix des donnees en sortie ('object', 'basic','all')
#                       observer = code UAI de l'observatoire
#
# Description : SkybotResolver webservice
# Auteur      : Jerome BERTHIER &amp; Alain KLOTZ
# Update      : 11 juin 2006
#
# Ce script interroge la base SkyBoT afin de resoudre le nom d'un corps
# du systeme solaire en ses coordonnees a l'epoque consideree.
#
# La reponse est une liste d'elements contenant les data.
# Le premier element de la liste est le nom des colonnees recuperees.
#
# Plus d'info: http://skybot.imcce.fr/
#
# Dans la console, une fois la cmde executee, on peut executer:
#    SOAP::dump -request skybotresolver
#    SOAP::dump -reply skybotresolver
# afin de visualiser le texte de la requete et de la reponse SOAP.
#
# ------------------------------------------------------------------------------------

proc vo_skybotresolver { args } {
   global audace
   global conf

   package require SOAP

   # reception des arguments
   set argc [llength $args]
   if {$argc >= 2} {

      set jd [mc_date2jd [lindex $args 0]]
      set target [lindex $args 1]
      set mime "text"
      if {$argc >= 3} { set mime [lindex $args 2] }
      set out "basic"
      if {$argc >= 4} { set out [lindex $args 3] }
      set observer "500"
      if {$argc >= 5} { set observer [lindex $args 4] }

      # The XML below is ripped straight from the generated SkyBoTBinding.skybotresolver.req.xml
      variable skybot_xml
      array set skybot_xml {
        skybotresolver {<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope
 xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
 xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xmlns:xsd="http://www.w3.org/2001/XMLSchema"
 xmlns:ns1="http://www.imcce.fr/webservices/skybot-dev">
 <SOAP-ENV:Body SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <ns1:skybotresolver>
   <inputArray>
     <epoch>${epoch}</epoch>
     <name>${target}</name>
     <mime>${mime}</mime>
     <output>${out}</output>
     <observer>${observer}</observer>
   </inputArray>
  </ns1:skybotresolver>
 </SOAP-ENV:Body>
</SOAP-ENV:Envelope>}
      }

      SOAP::create skybotresolver \
         -uri "http://www.imcce.fr/webservices/skybot-dev"\
         -proxy "http://www.imcce.fr/webservices/skybot-dev/skybot.php" \
         -name "skybotresolver" \
         -wrapProc vo_skybotXML \
         -params { epoch double target string mime string out string observer string }

      set erreur [ catch { skybotresolver epoch $jd target $target mime $mime out $out observer $observer } response ]

      set flag [lindex 1]
      set result [lindex $response 5]
      if { $erreur == "0" && $flag >= 0 } {
         return $result
      } else {
         tk_messageBox -title "error" -type ok -message $result
         return "failed"
      }

   } else {

      error "Usage: vo_skybotresolver Epoch Target ?text|votable|html? ?object|basic|all? Observer"

   }
}

# ------------------------------------------------------------------------------------
# proc        : vo_skybotstatus { [mime] }
#                 avec  mime = format de la reponse ('text', 'votable', 'html')
#
# Description : SkybotStatus webservice
# Auteur      : Jerome BERTHIER &amp; Alain KLOTZ
# Update      : 11 juin 2006
#
# Ce script interroge la base SkyBoT afin d'en connaitre le statut
#
# La reponse est une liste d'elements contenant :
#    - l'etat de la base (1 colonne)
#    - les dates de debut et de fin de la periode couverte par la base (2 colonnes)
#    - le nombre de corps dans la base pour les asteroides, les planetes,
#         les satellites naturels et les cometes (4 colonnes)
#    - la date de la derniere mise a jour.
#
# Plus d'info: http://skybot.imcce.fr/
#
# Dans la console, une fois la cmde executee, on peut executer:
#    SOAP::dump -request skybotstatus
#    SOAP::dump -reply skybotstatus
# afin de visualiser le texte de la requete et de la reponse SOAP.
#
# ------------------------------------------------------------------------------------

proc vo_skybotstatus { args } {
   global audace
   global conf

   package require SOAP

   set argc [llength $args]
   if {$argc >= 0} {
      set mime "text"
      if {$argc >= 1} { set mime [lindex $args 0] }

      SOAP::create skybotstatus \
         -uri "http://www.imcce.fr/webservices/skybot" \
         -proxy "http://www.imcce.fr/webservices/skybot/skybot.php" \
         -name "skybotstatus" \
         -params { "mime" "string" }

      set erreur [ catch { skybotstatus $mime } response ]

      if { $erreur == "0" } {
         return $response
      } else {
         tk_messageBox -title "error" -type ok -message $response
         return "failed"
      }

   } else {

      error "Usage: vo_skybotstatus ?text|votable|html?"

   }
}

# ------------------------------------------------------------------------------------
# proc        : vo_sesame { name resultType server }
#
#
# Description : Sesame: astronomical object name Resolver
# Auteur      : Jerome BERTHIER
# Update      : 11 juin 2006
#
# Ce script interroge le webservice SESAME (CDS) pour resoudre les noms des corps
# celestes (hors objets du systeme solaire) reconnus de Simbad
#
# Plus d'info: http://cdsweb.u-strasbg.fr/cdsws.gml
#
# ------------------------------------------------------------------------------------

proc vo_sesame { args } {
   global audace
   global conf

   package require SOAP

   set sesame(CDS)  "http://cdsws.u-strasbg.fr/axis/services/Sesame"
   set sesame(ADS)  "http://vizier.cfa.harvard.edu:8080/axis/services/Sesame"
   set sesame(ADAC) "http://vizier.nao.ac.jp:8080/axis/services/Sesame"
   set sesame(CADC) "http://vizier.hia.nrc.ca:8080/axis/services/Sesame"

   set argc [llength $args]
   if {$argc >=1 } {

      set name [lindex $args 0]
      set resultType "ui"
      if {$argc >= 2} { set resultType [lindex $args 1] }
      set server "CDS"
      if {$argc >= 3} { set server [lindex $args 2] }

      SOAP::create sesame \
         -uri $sesame($server) \
         -proxy $sesame($server) \
         -action "urn:sesame" \
         -params { "name" "string"  "resultType" "string"}

      set erreur [ catch { sesame $name $resultType } response ]

      if { $erreur == "0" } {
         return $response
      } else {
         tk_messageBox -title "error" -type ok -message $response
         return "failed"
      }

   } else {

      error "Usage: vo_sesame name ?u|H|x?[p|i]? ?CDS|ADS|ADAC|CADC?"

   }
}

# ------------------------------------------------------------------------------------
# proc        : vo_sesame_url { server }
#
#
# Description : GLU: Generateur de lien uniforme (CDS)
# Auteur      : Jerome BERTHIER
# Update      : 03 february 2006
#
# Ce script interroge le webservice GLU (CDS) pour determiner l'URL
# d'un service Sesame accessible
#
# Plus d'info: http://cdsweb.u-strasbg.fr/cdsws.gml
#
# ------------------------------------------------------------------------------------

proc vo_sesame_url { args } {
   package require SOAP

   set glu(CDS)  "http://cdsws.u-strasbg.fr/axis/services/Jglu"
   set glu(ADS)  "http://vizier.cfa.harvard.edu:8080/axis/services/Jglu"
   set glu(ADAC) "http://vizier.nao.ac.jp:8080/axis/services/Jglu"
   set glu(CADC) "http://vizier.hia.nrc.ca:8080/axis/services/Jglu"

   set argc [llength $args]
   if {$argc >= 1} {

      set server [lindex $args 0]
      set tag "Sesame"
      if {$argc >= 2} { set tag [lindex $args 1] }

      SOAP::create getURLfromTag \
         -uri $glu($server) \
         -proxy $glu($server) \
         -action "urn:getURLfromTag" \
         -params { "tag" "string" }

      return [ getURLfromTag $tag ]

   } else {
      error "Usage: vo_sesame_url ?CDS|ADS|ADAC|CADC?"
   }
}
