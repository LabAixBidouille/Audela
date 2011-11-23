#
# Fichier : vo_tools.tcl
# Description : Outils pour l'Observatoire Virtuel
# Auteur : Alain KLOTZ et Jerome BERTHIER
# Mise à jour $Id$
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
            if {$catalog=="NOMAD1"} { set catalog Vizier(NOMAD1) }
            append texte "get $catalog $coords ${fieldarcmin}'\n"
         }
      }
      #
      set fnameajs [file join $audace(rep_images) ${ftail}.ajs]
      set f [open "$fnameajs" w]
      puts -nonewline $f $texte
      close $f
      #
      if { $::tcl_platform(os) == "Linux" } {
         open "|\"${audace(rep_java)}/java\" -jar \"${audace(rep_aladinjar)}/Aladin.jar\" < \"$fnameajs\" " w+
      } elseif { $::tcl_platform(os) == "Darwin" } {
         open "|\"${audace(rep_java)}/java\" -jar \"${audace(rep_aladinjar)}/Aladin.jar\" < \"$fnameajs\" " w+
      } else {
         if {[file exists "${audace(aladin)}/aladin.exe"]==1} {
            open "|\"${audace(aladin)}/aladin.exe\" \"$fnameajs\" " w+
         } else {
            open "|\"aladin.exe\" \"$fnameajs\" " w+
         }
      }
   } elseif {$method=="object"} {
      # vo_aladin object uranus {USNO-B DSS2}
      if {$argc <= 1} {
         error "Usage: $method objename ?{catalogs}"
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
      #set fname [file join $fdirname ${ftail}${fextension}]
      append texte "get SkyBot.IMCCE(now,511,\"120 arcsec\") $fname \n"
      #
      set catalogs [lindex $args 2]
      if {[llength $catalogs]>0} {
         foreach catalog $catalogs {
            if {$catalog=="USNO-B1"} { set catalog Vizier(I/284) }
            if {$catalog=="DSS2"}    { set catalog Aladin(DSS2) }
            append texte "get $catalog $coords ${fieldarcmin}'\n"
         }
      }
      #
      set fnameajs [file join $audace(rep_images) ${ftail}.ajs]
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
      error "Usage: load|object ?parameters?"
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
###
### Pb sous KDE: The KDE libraries are not designed to run with suid privileges.
###  il faut mettre le user dans le bon group
###
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
# proc        : vo_skybot { JD RA DEC radius [mime] [output] [observer] [filter] }
#                 avec  JD       = jour julien de l'epoque consideree
#                       RA,DEC   = coordonnees equatoriales J2000.0 du centre du FOV (degres)
#                       radius   = rayon du FOV en arcsec
#                       mime     = format de la reponse ('text', 'votable', 'html')
#                       output   = choix des donnees en sortie ('object', 'basic','all')
#                       observer = code UAI de l'observatoire
#                       filter   = filtre sur l'erreur de position
#                       objfilter= masque de filtrage des objets
#
# Description : Skybot webservice
# Auteur      : Jerome BERTHIER &amp; Alain KLOTZ
# Update      : 3 oct. 2010
#
# Ce script interroge la base SkyBoT afin de fournir la liste et les coordonnees
# de tous les corps du systeme solaire contenus dans le FOV a l'epoque et aux
# coordonnees RA,DEC considerees.
#
# La reponse est une liste d'elements contenant les data.
# Le premier element de la liste est le nom des colonnees recuperees.
#
# Plus d'info: http://vo.imcce.fr/webservices/skybot/?conesearch
#
# Dans la console, une fois la cmde executee, on peut executer:
#    SOAP::dump -request skybotconesearch
#    SOAP::dump -reply skybotconesearch
# afin de visualiser le texte de la requete et de la reponse SOAP.
#
# ------------------------------------------------------------------------------------
proc vo_skybotconesearch { args } {
   global audace
   global conf

   package require SOAP

   set argc [llength $args]
   if {$argc >= 4} {
      # reception des arguments
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
      set objfilter "110"
      if {$argc >= 9} { set objfilter [lindex $args 8] }

      # The XML below is ripped straight from the generated request
      variable skybot_xml
      array set skybot_xml {
        skybotconesearch {<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope
    xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns1="http://vo.imcce.fr/webservices/skybot"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
    SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <SOAP-ENV:Header>
    <ns1:clientID><ns1:from>AudeLA</ns1:from><ns1:hostip></ns1:hostip></ns1:clientID>
  </SOAP-ENV:Header>
  <SOAP-ENV:Body>
    <ns1:skybotconesearch>
      <inputArray xsi:type="ns1:skybotConeSearchRequest">
        <epoch xsi:type="xsd:double">${epoch}</epoch>
        <alpha xsi:type="xsd:double">${RA}</alpha>
        <delta xsi:type="xsd:double">${DEC}</delta>
        <radius xsi:type="xsd:string">$radius</radius>
        <mime xsi:type="xsd:string">$mime</mime>
        <output xsi:type="xsd:string">$out</output>
        <observer xsi:type="xsd:string">$observer</observer>
        <filter xsi:type="xsd:double">$filter</filter>
        <objFilter xsi:type="xsd:string">$objfilter</objFilter>
      </inputArray>
    </ns1:skybotconesearch>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>}
}

      # instance du client soap
      SOAP::create skybotconesearch \
         -uri "http://vo.imcce.fr/webservices/skybot" \
         -proxy "http://vo.imcce.fr/webservices/skybot/skybot.php" \
         -name "skybotconesearch" \
         -wrapProc vo_skybotXML \
         -params { epoch double alpha double delta double radius string mime string output string observer string filter string objfilter string }

      # invocation du web service
      set erreur [ catch { skybotconesearch epoch $jd RA $RA DEC $DEC radius $radius mime $mime out $out observer $observer filter $filter objfilter $objfilter } response ]

      # recuperation des resultats
      set flag [lindex $response 1]
      set result [lindex $response 5]

      # On traite 3 cas de figure :
      # 1- une erreur s'est produite
      # 2- pas d'erreur mais la liste des corps est vide
      # 3- pas d'erreur et la liste contient au moins un corps
      #
      # Ces trois cas sont traites differemment suivant le type de table demande
      #  - type text : lorsque la liste est vide on renvoit "no"
      #  - type mime : si la liste est vide pas de traitement particulier
      #
      # Valeur de $flag : 0 == liste vide , > 0 sinon
      #
      if { $erreur == 0 } {
         if { $flag > 0 || $mime eq "votable" } {
            return $result
         } else {
            return "no"
         }
      } else {
         if {[set nameofexecutable [file tail [file rootname [info nameofexecutable]]]]=="audela"} {
            tk_messageBox -title "error" -type ok -message [concat "skybotconesearch: error: " $response]
         }
         return "failed"
      }

   } else {

      error "Usage: vo_skybot Epoch RA_J2000 DEC_J2000 Radius(arcsec) ?text|votable|html? ?object|basic|all? Observer Filter(arcsec) objFilter(bitmask e.g. 110)"

   }
}

# ------------------------------------------------------------------------------------
# proc        : vo_skybotresolver { JD name [mime] [out] [observer] }
#                 avec  JD       = jour julien de l'epoque consideree
#                       name     = nom ou numero ou designation provisoire de l'objet
#                       mime     = format de la reponse ('text', 'votable', 'html')
#                       out      = choix des donnees en sortie ('object', 'basic','all')
#                       observer = code UAI de l'observatoire
#
# Description : SkybotResolver webservice
# Auteur      : Jerome BERTHIER &amp; Alain KLOTZ
# Update      : 3 oct. 2010
#
# Ce script interroge la base SkyBoT afin de resoudre le nom d'un corps
# du systeme solaire en ses coordonnees a l'epoque consideree.
#
# La reponse est une liste d'elements contenant les data.
# Le premier element de la liste est le nom des colonnees recuperees.
#
# Plus d'info: http://vo.imcce.fr/webservices/skybot/?resolver
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

   set argc [llength $args]
   if {$argc >= 2} {
      # reception des arguments
      set jd [mc_date2jd [lindex $args 0]]
      set name [lindex $args 1]
      set mime "text"
      if {$argc >= 3} { set mime [lindex $args 2] }
      set output "basic"
      if {$argc >= 4} { set output [lindex $args 3] }
      set observer "500"
      if {$argc >= 5} { set observer [lindex $args 4] }

      # The XML below is ripped straight from the generated request
      variable skybot_xml
      array set skybot_xml {
        skybotresolver {<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope
    xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns1="http://vo.imcce.fr/webservices/skybot"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
    SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <SOAP-ENV:Header>
    <ns1:clientID><ns1:from>AudeLA</ns1:from><ns1:hostip></ns1:hostip></ns1:clientID>
  </SOAP-ENV:Header>
  <SOAP-ENV:Body>
    <ns1:skybotresolver>
      <inputArray xsi:type="ns1:skybotResolverRequest">
        <epoch xsi:type="xsd:double">$epoch</epoch>
        <name xsi:type="xsd:string">$name</name>
        <mime xsi:type="xsd:string">$mime</mime>
        <output xsi:type="xsd:string">$output</output>
        <observer xsi:type="xsd:string">$observer</observer>
      </inputArray>
    </ns1:skybotresolver>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>}
      }

      # instance du client soap
      SOAP::create skybotresolver \
         -uri "http://vo.imcce.fr/webservices/skybot" \
         -proxy "http://vo.imcce.fr/webservices/skybot/skybot.php" \
         -name "skybotresolver" \
         -wrapProc vo_skybotXML \
         -params { epoch double name string mime string output string observer string }

      # invocation du web service
      set erreur [ catch { skybotresolver epoch $jd name $name mime $mime output $output observer $observer } response ]

      # recuperation des resultats
      set flag [lindex $response 1]
      set result [lindex $response 5]

      # retour du resultat et gestion des cas d'erreur
      if { $erreur == "0" && $flag >= 1 } {
         return $result
      } else {
         if { $erreur == "0" && $flag == 0 } {
            return "no"
         } else {
            if {[set nameofexecutable [file tail [file rootname [info nameofexecutable]]]]=="audela"} {
               tk_messageBox -title "error" -type ok -message [concat "skybotresolver: error: " $response]
            }
            return "failed"
         }
      }

   } else {

      error "Usage: vo_skybotresolver Epoch Name ?text|votable|html? ?object|basic|all? Observer"

   }
}

# ------------------------------------------------------------------------------------
# proc        : vo_skybotstatus { [mime] [epoch] }
#                 avec  mime  = format de la reponse ('text', 'votable', 'html')
#                       epoch = epoque consideree au format JD ou ISO
#
# Description : SkybotStatus webservice
# Auteur      : Jerome BERTHIER &amp; Alain KLOTZ
# Update      : 3 oct. 2010
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
# Plus d'info: http://vo.imcce.fr/webservices/skybot/?status
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
      # reception des arguments
      set mime "text"
      if {$argc >= 1} { set mime [lindex $args 0] }
      set epoch ""
      if {$argc >= 2} { set epoch [lindex $args 1] }
      set epoch [regsub {T} $epoch " "]
      set epoch [regsub {\..*} $epoch ""]

      # The XML below is ripped straight from the generated request
      variable skybot_xml
      array set skybot_xml {
        skybotstatus {<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope
   xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
   xmlns:ns1="http://vo.imcce.fr/webservices/skybot"
   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
   SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
 <SOAP-ENV:Header>
  <ns1:clientID><ns1:from>AudeLA</ns1:from><ns1:hostip></ns1:hostip></ns1:clientID>
 </SOAP-ENV:Header>
 <SOAP-ENV:Body>
  <ns1:skybotstatus>
   <mime xsi:type="xsd:string">$mime</mime>
   <epoch xsi:type="xsd:dateTime">$epoch</epoch>
  </ns1:skybotstatus>
 </SOAP-ENV:Body>
</SOAP-ENV:Envelope>}
      }

      # instance du client soap
      SOAP::create skybotstatus \
         -uri "http://vo.imcce.fr/webservices/skybot" \
         -proxy "http://vo.imcce.fr/webservices/skybot/skybot.php" \
         -name "skybotstatus" \
         -wrapProc vo_skybotXML \
         -params { "mime" "string" "epoch" "string" }

      # invocation du web service
      set erreur [ catch { skybotstatus mime $mime epoch $epoch } response ]

      # cas ou le serveur repond avec une erreur
#TODO
      if {[string range $response 0 11] == "SKYBOTStatus"} {
         set erreur 99
      }

      # construction de la reponse
      if {$erreur == "0"}  {
         return $response
      } else {
         if {[set nameofexecutable [file tail [file rootname [info nameofexecutable]]]]=="audela"} {
            tk_messageBox -title "error" -type ok -message [concat "skybotstatus: error: " $response]
         }
         if {$erreur == "99"} {
            return "error"
         } else {
            return "failed"
         }
      }

   } else {

      error "Usage: vo_skybotstatus ?text|votable|html? ?epoch?"

   }
}

# ------------------------------------------------------------------------------------
# proc        : vo_sesame { name [resultType] [server] }
#
# Description : Sesame: astronomical object name Resolver
# Auteur      : Jerome BERTHIER
# Update      : 3 oct. 2010
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
   set sesame(ADAC) "http://vizier.nao.ac.jp:8080/axis/services/Sesame"
   set sesame(ADS)  "http://vizier.cfa.harvard.edu:8080/axis/services/Sesame"
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
         if {[set nameofexecutable [file tail [file rootname [info nameofexecutable]]]]=="audela"} {
            tk_messageBox -title "error" -type ok -message $response
         }
         return "failed"
      }

   } else {

      error "Usage: vo_sesame name ?u|H|x?[p|i]? ?CDS|ADS|ADAC|CADC?"

   }
}

# ------------------------------------------------------------------------------------
# proc        : vo_sesame_url { server }
#
# Description : GLU: Generateur de lien uniforme (CDS)
# Auteur      : Jerome BERTHIER
# Update      : 3 oct. 2010
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

# ------------------------------------------------------------------------------------
# proc        : vo_vizier_query { RA DEC [radius] [unit] [criteria] }
#                 avec  RA DEC   = coordonnees equatoriales J2000.0 du centre du FOV (degres)
#                       radius   = rayon du FOV
#                       unit     = unite du rayon du FOV (e.g. deg | arcmin | arcsec)
#                       criteria = citere de selection des catalogues VizieR (e.g. I/289/out)
#                       mime     = type mime de la reponse (e.g. list (def.) | votable)
#
# Description : Interrogation du service VizieR (CDS)
# Auteur      : Jerome BERTHIER
# Update      : 3 oct. 2010
#
# Ce script interroge le webservice VizieR (CDS) pour recuperer tous les objets d'un
# (jeu de) catalogue VizieR pour un FOV donne
#
# Remarques :
# - Le signe + ou - est obligatoire pour DEC
# - Exemples de criteres VizieR:
#     UCAC3 : criteria = "I/315/out
#     UCAC2 : criteria = I/289/out
#     UCAC2A: criteria = I/294A/ucac2bss
#     HIP   : criteria = I/239/hip_main
#     2MASS : criteria = II/246/out
#     TYCHO : criteria = I/239/tyc_main
#
# Plus d'info: http://cds.u-strasbg.fr/cdsws.gml
#
# Dans la console, une fois la cmde executee, on peut executer:
#    SOAP::dump -request vizierquery
#    SOAP::dump -reply vizierquery
# afin de visualiser le texte de la requete et de la reponse SOAP.
# Test: vo_vizier_query 105.0 +3.9 30 "arcmin" "I/239/tyc_main" "votable"
# ------------------------------------------------------------------------------------
proc vo_vizier_query { args } {
   package require SOAP
   package require dom

# TODO remonter dans variables Audace
   set vizier_url "http://cdsws.u-strasbg.fr/axis/services/VizieR"

   set argc [llength $args]
   if { $argc >=2 } {

      # reception des arguments
      set RA [mc_angle2deg [lindex $args 0]]
      set DEC [mc_angle2deg [lindex $args 1] 90]
      set target "[string trim $RA] [string trim [format %+.5f $DEC]]"
      set radius "5.0"
      if {$argc >= 3} { set radius [lindex $args 2] }
      set unit "arcmin"
      if {$argc >= 4} { set unit [lindex $args 3] }
      set criteria "I/315/out"
      if {$argc >= 5} { set criteria [lindex $args 4] }
      set mime "list"
      if {$argc >= 6} { set mime [lindex $args 5] }

      SOAP::create cataloguesData \
         -uri $vizier_url \
         -proxy $vizier_url \
         -action "urn:cataloguesData" \
         -params { "target" "string" "radius" "double" "unit" "string" "text" "string" }

      set erreur [ catch { cataloguesData $target $radius $unit $criteria } response ]

      if { $erreur == "0" } {
         if { $mime eq "votable" } {
            set vizier $response
         } else {
            # Parse la reponse VOTable
            set votable [::dom::parse $response]
            # Recupere les fields -> nom des colonnes
            set fields {}
            foreach n [::dom::selectNode $votable {descendant::FIELD/attribute::name}] {
               lappend fields "[::dom::node stringValue $n]"
            }
            # Recupere le nom du catalogue -> resource/description
            set catalog $criteria
            set catalogDesc [::dom::node stringValue [::dom::selectNode $votable {descendant::RESOURCE/DESCRIPTION/text()}]]
            lappend catalog $catalogDesc
            # Recupere toutes les lignes de la table
            set rows {}
            foreach tr [::dom::selectNode $votable {descendant::TR}] {
               set row {}
               foreach td [::dom::selectNode $tr {descendant::TD/text()}] {
                  lappend row [::dom::node stringValue $td]
               }
               lappend rows $row
            }
            # Cree la liste finale { {catalog} {fields} {rows} }
            set vizier {}
            lappend vizier [list $catalog $fields $rows]
         }
         return $vizier
      } else {
         if {[set nameofexecutable [file tail [file rootname [info nameofexecutable]]]]=="audela"} {
            tk_messageBox -title "error" -type ok -message $response
         }
         return "failed"
      }

   } else {

      error "Usage: vo_vizier_query ra dec ?radius? ?unit? ?VizieRCriteria?"

   }

}

# ------------------------------------------------------------------------------------
proc vo_name2coord { object_name } {
   package require SOAP
   set name "$object_name"
   set resultType "xp"
   set server "http://cdsws.u-strasbg.fr/axis/services/Sesame"
   SOAP::create sesame -uri $server -proxy $server \
      -action "urn:Sesame" \
      -params { "name" "string" "resultType" "string" }
   set xml_text [sesame $name $resultType]
   set ra [vo_xml_decode $xml_text {Sesame Target Resolver jradeg}]
   set dec [vo_xml_decode $xml_text {Sesame Target Resolver jdedeg}]
   return [list $ra $dec]
}

# ------------------------------------------------------------------------------------
# source $audace(rep_install)/gui/audace/vo_tools.tcl ; set star [vo_neareststar 23.45678 +34.56742 ]
# vo_neareststar ra dec => pour une seule etoile
# vo_neareststar ra dec radius => pour toutes les etoiles dans un rayon en arcmin
proc vo_neareststar { ra dec {radius 0} } {
   set target "[string trim [mc_angle2deg $ra]] [string trim [format %+.5f [mc_angle2deg $dec 90]]]"
   set rad 1
   if {$radius>0} {
	   set rad $radius
   }
   set starlists ""
   if {1==0} {
      package require SOAP
      set server "http://cdsws.u-strasbg.fr/axis/services/VizieRBeta"
      SOAP::create vizier -uri $server -proxy $server \
         -action "urn:VizieRBeta" \
         -params { "target" "string" "radius" "double" "unit" "string" "text" "string"}
      set xml_text [vizier $target 3 arcmin " "]
   } else {	   
      set url "http://vizier.u-strasbg.fr/viz-bin/VizieR/VizieR-2"
      package require http
      set query [::http::formatQuery "!-4c;" "Find Data" "-source" "I/297/out" "-c" "$target" "-c.eq" "J2000" "-c.r" "$rad" "-c.u" "arcmin" "-oc.form" "dec" "-c.geom" "r" "-out.add" "_r" "-sort" "_r"]
      set token [::http::geturl $url -query "$query"]
      upvar #0 $token state
      set html_text $state(body)
      # ----
      set kstar 1
      while {1==1} {
	      set k1 [string first "<EM>$kstar</EM>" $html_text]
	      if {$k1==-1} {
		      break
	      }
	      set texte [string range $html_text $k1 end]
	      set res [vo_html_decode1 $texte]
	      set val [lindex $res 0]
	      set texte [lindex $res 1]
	      set res [vo_html_decode1 $texte <EM>]
	      set id [lindex $res 0]
	      set texte [lindex $res 1]
	      set res [vo_html_decode1 $texte <EM>]
	      set val [lindex $res 0]
	      set texte [lindex $res 1]
	      set res [vo_html_decode1 $texte <EM>]
	      set ra [string trimleft [lindex $res 0] 0]
	      set texte [lindex $res 1]
	      set res [vo_html_decode1 $texte <EM>]
	      set dec [lindex $res 0]
	      set texte [lindex $res 1]
	      for {set k 1} {$k<=5} {incr k} {
	         set res [vo_html_decode1 $texte <EM>]
	         set texte [lindex $res 1]
	         set val [lindex $res 0]
	      }
	      set res [vo_html_decode1 $texte <EM>]
	      set texte [lindex $res 1]
	      set magb [lindex $res 0]
	      if {[catch {expr $magb}]==1} { set magb ""}
	      set res [vo_html_decode1 $texte <EM>]
	      set val [lindex $res 0]
	      set texte [lindex $res 1]
	      set res [vo_html_decode1 $texte <EM>]
	      set texte [lindex $res 1]
	      set magv [lindex $res 0]
	      if {[catch {expr $magv}]==1} { set magv ""}
	      set res [vo_html_decode1 $texte <EM>]
	      set val [lindex $res 0]
	      set texte [lindex $res 1]
	      set res [vo_html_decode1 $texte <EM>]
	      set texte [lindex $res 1]
	      set magr [lindex $res 0]
	      if {[catch {expr $magr}]==1} { set magr ""}
	      set res [vo_html_decode1 $texte <EM>]
	      set val [lindex $res 0]
	      set texte [lindex $res 1]
	      set res [vo_html_decode1 $texte <EM>]
	      set texte [lindex $res 1]
	      set magj [lindex $res 0]
	      if {[catch {expr $magj}]==1} { set magj ""}
	      set res [vo_html_decode1 $texte <EM>]
	      set texte [lindex $res 1]
	      set magh [lindex $res 0]
	      if {[catch {expr $magh}]==1} { set magh ""}
	      set res [vo_html_decode1 $texte <EM>]
	      set texte [lindex $res 1]
	      set magk [lindex $res 0]
	      if {[catch {expr $magk}]==1} { set magk ""}
   		lappend starlists [list [list NOMAD-1 $id] $ra $dec $magb $magv $magr $magj $magh $magk]
   		if {$radius==0} {
	   		break
   		}
   		incr kstar
		}
   }
   set f [open c:/d/a/a/toto.html w]
   puts $f $html_text
   close $f
   return $starlists
}

# ------------------------------------------------------------------------------------
proc vo_html_decode1 { texte {taglim ""} } {
   # set tag "<TD ALIGN=RIGHT NOWRAP>"
   set tag "<TD"
   set k1 [string first "$tag" $texte]
   if {$taglim!=""} {
      set k1e [string first "$taglim" $texte]
      if {$k1e<$k1} {
         return [list "" ""]
      }
   }
   set texte [string range $texte $k1 end]
   set k1 [string first ">" $texte]
   set texte [string range $texte $k1 end]
   set k1 [string first ">" $texte]
   set k2 [string first "<" $texte]
   set res [string range $texte [expr $k1+1] [expr $k2-1]]
   return [list $res $texte]
}

# ------------------------------------------------------------------------------------
proc vo_xml_decode { xml tags {kdeb 0} } {
   set klast -1
   set n [llength $tags]
   set tag [lindex $tags 0]
   #::console::affiche_resultat "tag=$tag n=$n\n"
   set k1 [string first <$tag $xml $kdeb]
   set k11 [string first > $xml $k1]
   #::console::affiche_resultat "k1=$k1 k11=$k11\n"
   if {($k1>=0)&&($n==1)} {
      set k2 [string first </$tag $xml $kdeb]
      #::console::affiche_resultat "k2=$k2\n"
      if {($k2>=0)} {
         set value [string range $xml [expr $k11+1] [expr $k2-1]]
         return $value
      }
   } elseif {($k1>=0)&&($n>1)} {
      set tags [lrange $tags 1 end]
      #::console::affiche_resultat "appel vo_xml_decode xml $tags $k11\n"
      return [vo_xml_decode $xml $tags $k11]
   } else {
      return ""
   }
   return ""
}
