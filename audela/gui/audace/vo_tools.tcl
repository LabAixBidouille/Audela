#
# File : vo_tools.tcl
# Description : Virtual Observatory Tools
# Auteur : Alain KLOTZ & Jerome BERTHIER
# Update : 10 december 2005
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
 # proc        : vo_skybotresolver { [JD] [name] [mime] [out] }
 #                 avec  JD   = jour julien de l'epoque consideree
 #                       name = nom ou numero ou designation provisoire de l'objet
 #                       mime = format de la reponse ('text', 'votable', 'html')
 #                       out  = choix des donnees en sortie ('object', 'basic','all')
 # Description : SkybotResolver webservice
 # Auteur      : Jerome BERTHIER &amp; Alain KLOTZ
 # Update      : 12 august 2005
 #
 # Ce script interroge la base SkyBoT afin de resoudre le nom
 # d'un corps du systeme solaire en ses coordonnees a l'epoque
 # consideree.
 #
 # La reponse est une liste d'elements contenant les data.
 # Le premier element de la liste est le nom des colonnees recuperees.
 #
 # Plus d'info: http://www.imcce.fr/page.php?nav=webservices/skybot/
 #
 # Dans la console, une fois la cmde executee, on peut executer:
 #    SOAP::dump -request skybotresolver
 #    SOAP::dump -reply skybotresolver
 # afin de visualiser le texte de la requete et de la reponse.
 #
 # ------------------------------------------------------------------------------------

 proc vo_skybotresolver { args } {
    global audace
    global conf

    package require SOAP

   set argc [llength $args]
   if {$argc>=2} {
       # recupere les args (a ecrire)
       #set jd "2453384.92154"
       #set name "1996 TO66"
       #set mime "text"
       #set out "basic"
       set jd [mc_date2jd [lindex $args 0]]
       set name [lindex $args 1]
       set mime text
       set out basic
       if {$argc>=3} {
          set mime [lindex $args 2]
       }
       if {$argc>=4} {
          set out [lindex $args 3]
       }
       SOAP::create skybotresolver -uri "http://www.imcce.fr/webservices/skybot"\
          -proxy "http://www.imcce.fr/webservices/skybot/skybotresolver.php" \
          -params { "epoch" "double"  "name" "string"  "mime" "string"  "out" "string"}
       set response [skybotresolver $jd $name $mime $out]
       return $response
    } else {
       error "Usage: vo_skybotresolver Date Designation ?text|votable|html? ?object|basic|all?"
    }

 }

 # ------------------------------------------------------------------------------------
 #
 # proc        : vo_skybot { [JD] [RA] [DEC] [radius] [mime] [out] }
 #                 avec  JD     = jour julien de l'epoque consideree
 #                       RA,DEC = coordonnees equatoriales J2000 du centre du FOV (degres)
 #                       radius = rayon du FOV en arcsec
 #                       mime   = format de la reponse ('text', 'votable', 'html')
 #                       out    = choix des donnees en sortie ('object', 'basic','all')
 # Description : Skybot webservice
 # Auteur      : Jerome BERTHIER &amp; Alain KLOTZ
 # Update      : 12 august 2005
 #
 # Ce script interroge la base SkyBoT afin de fournir la liste et les coordonnees
 # de tous les corps du systeme solaire contenus dans le FOV a l'epoque et aux
 # coordonnees RA,DEC considerees.
 #
 # La reponse est une liste d'elements contenant les data.
 # Le premier element de la liste est le nom des colonnees recuperees.
 #
 # Plus d'info: http://www.imcce.fr/page.php?nav=webservices/skybot/
 #
 # Dans la console, une fois la cmde executee, on peut executer:
 #    SOAP::dump -request skybotresolver
 #    SOAP::dump -reply skybotresolver
 # afin de visualiser le texte de la requete et de la reponse.
 #
 # ------------------------------------------------------------------------------------

 proc vo_skybot { args } {
    global audace
    global conf

    package require SOAP

   set argc [llength $args]
   if {$argc>=4} {
       # recupere les args (a ecrire)
       #set jd "2453384.92154"
       #set RA "148.67"
       #set DEC "16.3838"
       #set radius "600"
       #set mime "text"
       #set out "basic"
       set jd [mc_date2jd [lindex $args 0]]
       set RA [mc_angle2deg [lindex $args 1]]
       set DEC [mc_angle2deg [lindex $args 2] 90]
       set radius [lindex $args 3]
       set mime text
       set out basic
       if {$argc>=5} {
          set mime [lindex $args 4]
       }
       if {$argc>=6} {
          set out [lindex $args 5]
       }

       SOAP::create skybot -uri "http://www.imcce.fr/webservices/skybot" \
          -proxy "http://www.imcce.fr/webservices/skybot/skybot.php" \
          -params { "epoch" "double"  "alpha" "double"  "delta" "double"  "radius" "double"  "mime" "string"  "out" "string" }
       set response [skybot $jd $RA $DEC $radius $mime $out]
       return $response
    } else {
       error "Usage: vo_skybot Date Designation ra_J2000.0 dec_J2000.0 radius_arcsec ?text|votable|html? ?object|basic|all?"
    }
 }

# ------------------------------------------------------------------------------------
#
# proc        : vo_skybotstatus { [mime] }
#                 avec  mime = format de la reponse ('text', 'votable', 'html')
#
# Description : SkybotStatus webservice
# Auteur      : Jerome BERTHIER &amp; Alain KLOTZ
# Update      : 16 september 2005
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
# Plus d'info: http://www.imcce.fr/page.php?nav=webservices/skybot/
#
# Dans la console, une fois la cmde executee, on peut executer:
#    SOAP::dump -request skybotstatus
#    SOAP::dump -reply skybotstatus
# afin de visualiser le texte de la requete et de la reponse.
#
# ------------------------------------------------------------------------------------

proc vo_skybotstatus { args } {
  global audace
  global conf

  package require SOAP

  set argc [llength $args]
  if {$argc>=0} {
      set mime "text"
      if {$argc>=1} {
         set mime [lindex $args 0]
      }
      SOAP::create skybotstatus -uri "http://www.imcce.fr/webservices/skybot"\
         -proxy "http://www.imcce.fr/webservices/skybot/skybotstatus.php" \
         -params { "mime" "string" }
      set response [skybotstatus $mime]
      return $response
   } else {
      error "Usage: vo_skybotstatus ?text|votable|html?"
   }

}

