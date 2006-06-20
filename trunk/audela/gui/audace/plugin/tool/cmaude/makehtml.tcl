#
# Fichier : makehtml.tcl
# Description : Ecrit une page HTML au fur et a mesure de la nuit, ou sont disponibles les images JPG et FITS
# Auteur : Sylvain RONDI
# Mise a jour $Id: makehtml.tcl,v 1.3 2006-06-20 20:54:18 robertdelmas Exp $
#

variable cmconf
global compteur

#--- Initialisation de l'heure TU ou TL
set now now
catch {
   set now [::audace::date_sys2ut now]
}
#--- Acquisition of an image
set actuel [mc_date2jd $now]
#---
set namehtml [string range [mc_date2iso8601 $actuel] 0 9].html
::console::affiche_erreur "Creation/Update of the HTML file $namehtml\n"
set existence [file exists $cmconf(folder)$namehtml]
if { $existence == "0" } then {
   #--- Here is made the html page header
   set texte "<!doctype html public \"-//w3c//dtd html 4.0 transitional//en\">\n"
   append texte "<html>\n"
   append texte "<head>\n"
   append texte "   <meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">\n"
   append texte "   <meta name=\"GENERATOR\" content=\"AudeLA\">\n"
   append texte "   <meta name=\"Author\" content=\"S. Rondi\">\n"
   append texte "   <title>MASCOT Images - [string range [mc_date2iso8601 $actuel] 0 9]</title>\n"
   append texte "</head>\n"
   append texte "<body bgcolor=\"#FFFFFF\" background=\"./imghtml/eso.gif\">\n"
   append texte "<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" align=\"center\"> \n"
   append texte "<tr valign=\"top\"><td rowspan=\"2\" align=\"left\"> <img align=\"top\" width=\"80\" "
   append texte "height=\"100\" src=\"./imghtml/eso-logo.gif\" > </td> \n"
   append texte "<td align=\"right\"><h1><font color=\"#006699\">MASCOT Images</font></h1></td></tr></table> "
   append texte "<hr size=\"1\" noshade>\n"
   append texte "<h2><center>\n"
   append texte "Night of [string range [mc_date2iso8601 $actuel] 0 9]<br>\n"
   append texte "Julian Day [string range [mc_date2jd now] 0 6]</h2></center>\n"
   append texte "<h2>\n"
   append texte "1. MASCOT Instrument</h2>\n"
   append texte "<b>MASCOT</b> stands for <b>M</b>ini <b>A</b>ll-<b>S</b>ky <b>C</b>loud <b>O</b>bservation <b>T</b>ool. <br>"
   append texte "Its purpose is to make images of the whole night sky over ESO Paranal Observatory  "
   append texte "in order to permit to evaluate the night sky quality. <br>\n"
   append texte "The observations are made automatically and are available in FITS format as well as\n"
   append texte "in JPEG format. This page is an observation log of the night and makes a link\n"
   append texte "to both formats, allowing the user to browse easily the images of the night\n"
   append texte "by visualising the JPEG version on a web browser.<br>\n"
   append texte "It requires to have the images in the same directory as this HTML document.\n"
   append texte "\n" 	      append texte "<h2>\n"
   append texte "2. Local Ephemeris</h2>\n"
   append texte "Here are some local ephemeris for the current night at Paranal: <br>\n"
   append texte "$resultb<br>\n"
   append texte "$resulte<br>\n"
   set localite "$cmconf(localite)"
  # set phaslun [string range [lindex [mc_ephem moon [list [mc_date2tt now]] {phase} -topo $localite] 0] 0 4]
  # set illufrac [string range [expr 100 * (0.5 + 0.5 * cos ($phaslun / 180. * 3.1415))] 0 4]
   append texte "Lunar phase at the beginning of the night: $phaslun<br>\n"
   append texte "Illuminated fraction of the Moon at the beginning of the night: $illufrac<br>\n"
   append texte "<h2>\n"
   append texte "3. List of images</h2>\n"

   set fileId [open $cmconf(folder)$namehtml w]
   puts $fileId $texte
   close $fileId
}

if { $endofhtml == "0" } then {
   set texte "Image <b>$nameima</b> done the [string range [mc_date2iso8601 $actuel] 0 9] "
   append texte "at <b>[string range [mc_date2iso8601 $actuel] 11 18] UT</b> "
   append texte "(Local Sideral Time $sidertime) - "
   append texte "<a href=\"$nameima.jpg\">| JPG |</a> - "
   append texte " <a href=\"$nameima\">| FITS |</a> <br>"
}

if { $endofhtml == "1" } then {
   append texte "<p>End of observations the [string range [mc_date2iso8601 $actuel] 0 9] at "
   append texte "[string range [mc_date2iso8601 $actuel] 11 20]UT <br>"
   set nbtotimages [expr $compteur-1]
   append texte "<b>$nbtotimages images</b> have been taken during this night.<br>"
   append texte "MASCOT is tired now and it will have a good sleep until next night..."
   append texte "</p> <hr>\n"
   append texte "Here is a fast-to-use Java image browser:"

   append texte "<CENTER>\n"
   append texte "<FORM ACTION=\"\" METHOD=POST\n>"
   append texte "<SCRIPT LANGUAGE=JavaScript>\n"
   append texte "<!--\n"
   append texte "var current = 0;\n"
   append texte "function imageArray() {\n"
   append texte "    this.length = imageArray.arguments.length;\n"
   append texte "    for (var i=0; i<this.length; i++)\n"
   append texte "     {\n"
   append texte "       this[i] = imageArray.arguments[i];  \n"
   append texte "     }\n"
   append texte "}\n"

   append texte "// All images in same dir, same size\n"
   append texte "var imgz = new imageArray("
   for { set k 1 } { $k <= [expr $compteur-2] } { incr k } {
      append texte "\"[string range [mc_date2jd now] 0 6]-$compteur$cmconf(extension).jpg\","
   }
   append texte "\"[string range [mc_date2jd now] 0 6]-[expr $compteur-1]$cmconf(extension).jpg\");\n"
   append texte "document.write('<img name=\"myImages\" border=\"3\" src=\"'+imgz[0]+'\">');\n"
   append texte "function getPosition(val) {\n"
   append texte "    var goodnum = current+val;\n"
   append texte "    //Wrap around\n"
   append texte "	   if (goodnum < 0) goodnum = imgz.length-1;\n"
   append texte "   else if (goodnum > imgz.length-1) goodnum = 0;\n"
   append texte "   document.myImages.src = imgz[goodnum];\n"
   append texte "   current = goodnum; }\n"
   append texte "//-->\n"

   append texte "</SCRIPT> <BR>\n"
   append texte "<INPUT TYPE=button NAME=button VALUE=\"Backward\" onclick=\"getPosition(-1)\">\n"
   append texte "<INPUT TYPE=button NAME=button VALUE=\"Forward\" onclick=\"getPosition(1)\">\n"
   append texte "</FORM><br><hr></CENTER>\n"
   append texte "</body>\n"
   append texte "</html>\n"
}

set fileId [open $cmconf(folder)$namehtml a]
puts $fileId $texte
close $fileId

