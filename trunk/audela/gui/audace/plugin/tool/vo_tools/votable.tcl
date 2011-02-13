#
# Fichier : votable.tcl
# Description : Implementation du schema VOTable de l'IVOA
#               (http://www.ivoa.net/Documents/latest/VOT.html)
# Auteur : Jerome BERTHIER
# Mise à jour $Id: votable.tcl,v 1.2 2011-02-13 22:51:22 robertdelmas Exp $
#

namespace eval ::votable {
   package provide votable 1.0

   # #############################################################################
   #
   # Implementation des attributs de l'espace de nom votable
   #
   # #############################################################################

   # @var string name-space du schema XML
   variable xmlSchemaNs "http://www.w3.org/2001/XMLSchema-instance"
   # @var string URI du schema VOTable
   variable votableSchemaNS
   # @var string URI de la feuille XSL (vide par defaut)
   variable xsluri
   # @var string Definition de l'espace de nom du data model
   variable dataModelNS
   # @var string Definition du prefixe de l'espace de nom du data model
   variable dataModelPrefix
   # @var string Version du schema VOTable
   variable votableVersion
   # @var string Prefixe des elements VOTable
   variable votablePrefix
   # @var string URL pointant sur le schema XML de la VOTable
   variable votableSchemaFile

   # #############################################################################
   #
   # Implementation de la grammaire VOTable dans l'espace de nom votable
   #
   # #############################################################################

   #
   # Definition des elements hierarchiques du schema VOTable, prefixe avec 'vot:'
   # @link http://www.ivoa.net/Documents/latest/VOT.html
   # @staticvar string $VOTABLE
   # @staticvar string $RESOURCE
   # @staticvar string $TABLE
   # @staticvar string $DATA
   # @staticvar string $TABLEDATA
   # @staticvar string $BINARY
   # @staticvar string $FITS
   # @staticvar string $GROUP
   # @staticvar string $PARAM
   # @staticvar string $FIELD
   # @staticvar string $VALUES
   # @staticvar string $DESCRIPTION
   # @staticvar string $COOSYS
   # @staticvar string $INFO
   # @staticvar string $LINK
   # @staticvar string $TR
   # @staticvar string $TD
   # @staticvar string $STREAM
   # @staticvar string $FIELDREF
   # @staticvar string $PARAMREF
   # @staticvar string $MIN
   # @staticvar string $MAX
   # @staticvar string $OPTION
   #
   namespace eval Element {
      variable VOTABLE     "VOTABLE"
      variable RESOURCE    "RESOURCE"
      variable TABLE       "TABLE"
      variable DATA        "DATA"
      variable TABLEDATA   "TABLEDATA"
      variable BINARY      "BINARY"
      variable FITS        "FITS"
      variable GROUP       "GROUP"
      variable PARAM       "PARAM"
      variable FIELD       "FIELD"
      variable VALUES      "VALUES"
      variable DESCRIPTION "DESCRIPTION"
      variable COOSYS      "COOSYS"
      variable INFO        "INFO"
      variable LINK        "LINK"
      variable TR          "TR"
      variable TD          "TD"
      variable STREAM      "STREAM"
      variable FIELDREF    "FIELDref"
      variable PARAMREF    "PARAMref"
      variable MIN         "MIN"
      variable MAX         "MAX"
      variable OPTION      "OPTION"
   }

   #
   # Definition des attributs de l'element RESOURCE
   # @link http://www.ivoa.net/Documents/latest/VOT.html
   # @staticvar string $ID
   # @staticvar string $NAME
   # @staticvar string $UTYPE
   # @staticvar string $TYPE
   #
   namespace eval Resource {
      variable ID          "ID"
      variable NAME        "name"
      variable UTYPE       "utype"
      variable TYPE        "type"
   }

   #
   # Definition des attributs de l'element TABLE
   # @link http://www.ivoa.net/Documents/latest/VOT.html
   # @staticvar string $ID
   # @staticvar string $NAME
   # @staticvar string UCD
   # @staticvar string $UTYPE
   # @staticvar string $REF
   # @staticvar string $NROWS
   #
   namespace eval Table {
      variable ID          "ID"
      variable NAME        "name"
      variable UTYPE       "ucd"
      variable TYPE        "utype"
      variable REF         "ref"
      variable NROWS       "nrows"
   }

   #
   # Definition des attributs de l'element STREAM
   # @link http://www.ivoa.net/Documents/latest/VOT.html
   # @staticvar string $TYPE
   # @staticvar string $HREF
   # @staticvar string $ACTUATE
   # @staticvar string $ENCODING
   # @staticvar string $EXPIRES
   # @staticvar string RIGHTS
   #
   namespace eval Stream {
      variable TYPE        "type"
      variable HREF        "href"
      variable ACTUATE     "actuate"
      variable ENCODING    "encoding"
      variable EXPIRES     "expires"
      variable RIGHTS      "rights"
   }

   #
   # Definition des attributs de l'element FITS
   # @link http://www.ivoa.net/Documents/latest/VOT.html
   # @staticvar string $EXTNUM
   #
   namespace eval Fits {
      variable EXTNUM      "extnum"
   }

   #
   # Definition des attributs de l'element COOSYS
   # @link http://www.ivoa.net/Documents/latest/VOT.html
   # @staticvar string $ID (required attributes)
   # @staticvar string $EQUINOX
   # @staticvar string $EPOCH
   # @staticvar string $SYSTEM
   #
   namespace eval CooSys {
      variable ID          "ID"
      variable EQUINOX     "equinox"
      variable EPOCH       "epoch"
      variable SYSTEM      "system"
   }

   #
   # Definition des attributs de l'element GROUP
   # @link http://www.ivoa.net/Documents/latest/VOT.html
   # @staticvar string $ID
   # @staticvar string $NAME
   # @staticvar string $REF
   # @staticvar string $UCD
   # @staticvar string $UTYPE
   #
   namespace eval Group {
      variable ID          "ID"
      variable NAME        "name"
      variable REF         "ref"
      variable UCD         "ucd"
      variable UTYPE       "utype"
   }

   #
   # Definition des attributs de l'element PARAM
   # @link http://www.ivoa.net/Documents/latest/VOT.html
   # @staticvar string $ID
   # @staticvar string $UNIT
   # @staticvar string $DATATYPE (required attributes)
   # @staticvar string $PRECISION
   # @staticvar string $WIDTH
   # @staticvar string $REF
   # @staticvar string $NAME (required attributes)
   # @staticvar string $UCD
   # @staticvar string $UTYPE
   # @staticvar string $ARRAYSIZE
   # @staticvar string $VALUE (required attributes)
   #
   namespace eval Param {
      variable ID          "ID"
      variable UNIT        "unit"
      variable DATATYPE    "datatype"
      variable PRECISION   "precision"
      variable WIDTH       "width"
      variable REF         "ref"
      variable NAME        "name"
      variable UCD         "ucd"
      variable UTYPE       "utype"
      variable ARRAYSIZE   "arraysize"
      variable VALUE       "value"
   }

   #
   # Definition des attributs de l'element PARAMREF
   # @link http://www.ivoa.net/Documents/latest/VOT.html
   # @staticvar string $REF (required attributes)
   #
   namespace eval ParamRef {
      variable REF         "ref"
   }

   #
   # Definition des attributs de l'element FIELD
   # @link http://www.ivoa.net/Documents/latest/VOT.html
   # @staticvar string $ID
   # @staticvar string $UNIT
   # @staticvar string $DATATYPE (required attributes)
   # @staticvar string $PRECISION
   # @staticvar string $WIDTH
   # @staticvar string $REF
   # @staticvar string $NAME (required attributes)
   # @staticvar string $UCD
   # @staticvar string $UTYPE
   # @staticvar string $ARRAYSIZE
   # @staticvar string $TYPE
   #
   namespace eval Field {
      variable ID          "ID"
      variable UNIT        "unit"
      variable DATATYPE    "datatype"
      variable PRECISION   "precision"
      variable WIDTH       "width"
      variable REF         "ref"
      variable NAME        "name"
      variable UCD         "ucd"
      variable UTYPE       "utype"
      variable ARRAYSIZE   "arraysize"
      variable TYPE        "type"
   }

   #
   # Definition des attributs de l'element FIELDREF
   # @link http://www.ivoa.net/Documents/latest/VOT.html
   # @staticvar string $REF (required attributes)
   #
   namespace eval FieldRef {
      variable REF         "ref"
   }

   #
   # Definition des attributs de l'element VALUES
   # @link http://www.ivoa.net/Documents/latest/VOT.html
   # @staticvar string $ID
   # @staticvar string $TYPE
   # @staticvar string $NULL
   # @staticvar string $REF
   #
   namespace eval Values {
      variable ID          "ID"
      variable TYPE        "type"
      variable NULL        "null"
      variable REF         "ref"
   }

   #
   # Definition des attributs de l'element INFO
   # @link http://www.ivoa.net/Documents/latest/VOT.html
   # @staticvar string $ID
   # @staticvar string $NAME (required attributes)
   # @staticvar string $VALUE (required attributes)
   #
   namespace eval Info {
      variable ID          "ID"
      variable NAME        "name"
      variable VALUE       "value"
   }

   #
   # Definition des attributs de l'element LINK
   # @link http://www.ivoa.net/Documents/latest/VOT.html
   # @staticvar string $ID
   # @staticvar string $CONTENTROLE
   # @staticvar string $CONTENTTYPE
   # @staticvar string $TITLE
   # @staticvar string $VALUE
   # @staticvar string $HREF
   # @staticvar string $ACTION
   #
   namespace eval Link {
      variable ID          "ID"
      variable CONTENTROLE "content-role"
      variable CONTENTTYPE "content-type"
      variable TITLE       "title"
      variable VALUE       "value"
      variable HREF        "href"
      variable ACTION      "action"
   }

   #
   # Definition des attributs de l'element MIN
   # @link http://www.ivoa.net/Documents/latest/VOT.html
   # @staticvar string $VALUE (required attributes)
   # @staticvar string $INCLUSIVE
   #
   namespace eval Min {
      variable VALUE       "value"
      variable INCLUSIVE   "inclusive"
   }

   #
   # Definition des attributs de l'element MAX
   # @link http://www.ivoa.net/Documents/latest/VOT.html
   # @staticvar string $VALUE (required attributes)
   # @staticvar string $INCLUSIVE
   #
   namespace eval Max {
      variable VALUE       "value"
      variable INCLUSIVE   "inclusive"
   }

   #
   # Definition des attributs de l'element OPTION
   # @link http://www.ivoa.net/Documents/latest/VOT.html
   # @staticvar string $NAME
   # @staticvar string $VALUE (required attributes)
   #
   namespace eval Option {
      variable NAME        "name"
      variable VALUE       "value"
   }

}

# #############################################################################
#
# Implementation des methodes de l'espace de nom votable
#
# #############################################################################

#
# Constructeur de classe
# @param $version string versionnage de la VOTable (default 1.1)
# @param $prefix string prefixage de la VOTable (default vot:)
# @param $dm string namespace du data model utilise (default null)
#
proc ::votable::init { version prefix } {
   # Version VOTable
   set ::votable::votableVersion $version
   # Prefixe VOTable
   set ::votable::votablePrefix $prefix
   # Namespace VOTable
   set ::votable::votableSchemaNS [join [list "http://www.ivoa.net/xml/VOTable/v" $version] ""]
   # Schema VOTable
   set ::votable::votableSchemaFile [join [list "http://www.ivoa.net/xml/VOTable/VOTable-" $version ".xsd"] ""]
}

#
# Macro-fonction d'ouverture de la VOTable
# @access public
# @return string element d'ouverture de la VOTable (jusqu'a l'element <VOTABLE>)
#
proc ::votable::openVOTable { } {
   set v [::votable::addXMLHeader]
   if [string length $::votable::xsluri] {
      set v [join [list $v [::votable::addXSLSheet]] ""]
   }
   set v [join [list $v [::votable::openVOTableElement]] ""]
   return $v;
}

#
# Macro-fonction de fermeture de la VOTable
# @access public
# @return string elements de fermeture de la VOTable
#
proc ::votable::closeVOTable { } {
   return [::votable::closeVOTableElement]
}

#
# Definition du type de contenu d'une VOTable (Content-type: text/xml)
# @access public
# @return string entete text/xml
#
proc ::votable::getHeader { } {
   return "header(\"Content-type: text/xml\")"
}

#
# Declaration de l'entete XML du document
# @access public
# @return string entete xml du document
#
proc ::votable::addXMLHeader { } {
   return "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n"
}

#
# Declaration de l'utilisation du feuille XSL
# @access public
# @return string element xml-stylesheet pour l'utilisation d'une feuille XSL
#
proc ::votable::addXSLSheet { } {
   return [join [list "<?xml-stylesheet href=\"" $::votable::xsluri "\" type=\"text/xsl\"?>\n"] ""]
}

#
# Ouverture de l'element VOTABLE (element ouvert qui doit etre ferme avec la methode closeVOTableElement)
# @access public
# @return string ouverture de l'element VOTABLE
#
proc ::votable::openVOTableElement { } {
   set o [join [list "<" $::votable::votablePrefix "VOTABLE version=\"" $::votable::votableVersion "\""] ""]
   set o [join [list $o " xmlns:xsi=\"" $::votable::xmlSchemaNs "\""] ""]
   if {[string length $::votable::votablePrefix] > 0} {
      set o [join [list $o " xmlns:" [string range $::votable::votablePrefix 0 [expr [string length $::votable::votablePrefix]-2]] "=\"" $::votable::votableSchemaNS "\""] ""]
      set o [join [list $o " xsi:schemaLocation=\"" $::votable::votableSchemaNS " " $::votable::votableSchemaFile "\""] ""]
   } else {
      set o [join [list $o " xsi:noNamespaceSchemaLocation=\"" $::votable::votableSchemaNS "/v" $::votable::votableVersion "\""] ""]
   }
   if {[string length $::votable::dataModelNS] > 0} {
      set o [join [list $o " xmlns:" $::votable::dataModelPrefix "=\"" $::votable::dataModelNS "\""] ""]
   }
   set o [join [list $o ">\n"] ""]
   return $o
}

#
# Fermeture de l'element VOTABLE
# @access public
# @return string fermeture de l'element VOTABLE
#
proc ::votable::closeVOTableElement { } {
   return [::votable::closeElement $::votable::Element::VOTABLE]
}

#
# Ouverture de l'element RESOURCE (element ouvert a fermer avec la methode closeResourceElement)
# @access public
# @param list $attributes liste des attributs de l'element RESOURCE sous forme de listes (e.g. [list $::votable::Resource::NAME "ResourceName"])
# @return string ouverture de l'element RESOURCE
#
proc ::votable::openResourceElement { attributes } {
   return [::votable::attributesUnclosedElement $::votable::Element::RESOURCE $attributes]
}

#
# Fermeture de l'element RESOURCE
# @access public
# @return string fermeture de l'element RESOURCE
#
proc ::votable::closeResourceElement { } {
   return [::votable::closeElement $::votable::Element::RESOURCE]
}

#
# Ajout d'un element PARAM
# @access public
# @param  list    $attributes   liste des attributs de l'element PARAM (e.g. [list $::votable::Param::ID "idParam"])
# @param  string  $description  description a ajouter dans l'element PARAM (optionnel)
# @param  string  $values       valeur a ajouter dans l'element PARAM (optionnel)
# @param  list    $link         liste des attributs de l'element LINK a ajouter dans l'element FIELD (optionnel)
# @return string
#
proc ::votable::addParamElement { attributes description values link } {
   if {[string length $description] == 0 &&
        [string length $values] == 0 &&
        [string length $link] == 0} {
      set p [::votable::attributesClosedElement $::votable::Element::PARAM $attributes]
   } else {
      set p [::votable::attributesUnclosedElement $::votable::Element::PARAM $attributes]
      if {[string length $description] > 0} {
         set p [join [list $p [::votable::addElement $::votable::Element::DESCRIPTION "" $description]] ""]
      }
      if {[string length $values] > 0} {
         set p [join [list $p [::votable::addElement $::votable::Element::VALUES "" $values]] ""]
      }
      if {[string length $link] > 0} {
         set p [join [list $p [::votable::addElement $::votable::Element::LINK $link ""]] ""]
      }
      set p [join [list $p [::votable::closeElement $::votable::Element::PARAM]] ""]
   }
   return $p
}

#
# Ouverture de l'element TABLE (element ouvert a fermer avec la methode closeTableElement)
# @access public
# @param  list $attributes liste des attributs de l'element TABLE (e.g. [list $::votable::Table::ID "idTable"])
# @return string ouverture de l'element TABLE
#
proc ::votable::openTableElement { attributes } {
   return [::votable::openElement $::votable::Element::TABLE $attributes]
}

#
# Fermeture de l'element TABLE
# @access public
# @return string fermeture de l'element TABLE
#
proc ::votable::closeTableElement { } {
   return [::votable::closeElement $::votable::Element::TABLE]
}

#
# Ajout d'un element FIELD
# @access public
# @param  list    $attributes   liste des attributs de l'element FIELD (e.g. [list $::votable::Field::ID "idField"])
# @param  string  $description  description a ajouter dans l'element FIELD (optionnel)
# @param  string  $values       valeur a ajouter dans l'element FIELD (optionnel)
# @param  list    $link         liste des attributs de l'element LINK a ajouter dans l'element FIELD (optionnel)
# @return string element FIELD
#
proc ::votable::addFieldElement { attributes description values link } {
   if {[string length $description] == 0 &&
        [string length $values] == 0 &&
        [string length $link] == 0} {
      set p [::votable::attributesClosedElement $::votable::Element::FIELD $attributes]
    } else {
      set p [::votable::attributesUnclosedElement $::votable::Element::FIELD $attributes]
      if {[string length $description] > 0} {
         set p [join [list $p [::votable::addElement $::votable::Element::DESCRIPTION "" $description]] ""]
      }
      if {[string length $values] > 0} {
         set p [join [list $p [::votable::addElement $::votable::Element::VALUES "" $values]] ""]
      }
      if {[string length $link] > 0} {
         set p [join [list $p [::votable::addElement $::votable::Element::LINK $link ""]] ""]
      }
      set p [join [list $p [::votable::closeElement $::votable::Element::FIELD]] ""]
    }
    return $p
}

#
# Ajout d'un element GROUP
# @access public
# @param  list    $attributes   liste des attributs de l'element GROUP (e.g. [list $::votable::Group::ID "idGroup"])
# @param  string  $description  description (optionnelle) de l'element FIELD
# @param  list    $fieldRef     liste des references aux elements FIELD (e.g. [list [list $::votable::FieldRef::REF "x"] [list $::votable::FieldRef::REF "y"] ...])
# @param  list    $param        liste des attributs d'un element PARAM a ajouter dans l'element GROUP
# @param  list    $paramRef     liste des references a des parametres (e.g. [list [list $::votable::ParamRef::REF "x"] [list $::votable::ParamRef::REF "y"] ...])
# @return string element GROUP
#
proc ::votable::addGroupElement { attributes description fieldRef param paramRe } {
   set p [::votable::attributesUnclosedElement $::votable::Element::GROUP $attributes]
   if {[string length $description] > 0} {
      set p [join [list $p [::votable::addElement $::votable::Element::DESCRIPTION "" $description]] ""]
   }
   if {[string length $param] > 0} {
      set p [join [list $p [::votable::addParamElement $param "" "" ""]] ""]
   }
   foreach f $fieldRef {
      set p [join [list $p [::votable::attributesClosedElement $::votable::Element::FIELDREF [lindex $f 1]]] ""]
   }
   if {[string length $paramRef] > 0} {
      foreach p $paramRef {
         set p [join [list $p [::votable::attributesClosedElement $::votable::Element::PARAMREF [lindex $p 1]]] ""]
      }
   }
   set p [join [list $p [::votable::closeElement $::votable::Element::GROUP]] ""]
   return $p
}

#
# Ajout d'un element avec ou sans attribut et avec ou sans valeur
# @access public
# @param  string  $elementName  nom de l'element (e.g. Element::<$VAR>)
# @param  list    $attributes   liste des attributs de l'element $elementName (e.g. [list $::votable::Element::ID "idElem"])
# @param  string  $value        valeur a inserer dans l'element
# @return string element ferme
#
proc ::votable::addElement { elementName attributes value } {
   if {[string length $value] > 0} {
      set p [join [list [::votable::attributesUnclosedElement $elementName $attributes] $value [::votable::closeElement $elementName]] ""]
   } else {
      set p [join [list [::votable::attributesClosedElement $elementName $attributes]] ""]
   }
   return $p
}

#
# Ouverture d'un element avec ou sans attribut (element ouvert a fermer avec la methode closeElement)
# @access public
# @param  string  $elementName   nom de l'element a ouvrir (e.g. Element::<$VAR>)
# @param  list    $attributes    liste des attributs de l'element $elementName (e.g. [list $::votable::Element::ID "idElem"])
# @return string element ouvert
#
proc ::votable::openElement { elementName attributes } {
   if {[info exists $attributes]} {
      set p [join [list [::votable::attributesUnclosedElement $elementName $attributes]] ""]
   } else {
      set p [join [list "<" $::votable::votablePrefix $elementName ">"] ""]
   }
   return $p
}

#
# Fermeture d'un element (ouvert avec la methode openElement)
# @access public
# @param  string  $elementName nom de l'element a fermer (e.g. Element::<$VAR>)
# @return string fermeture de l'element
#
proc ::votable::closeElement { elementName } {
   return [join [list "</" $::votable::votablePrefix $elementName ">\n"] ""]
}

#
# Ajout d'un element TD
# @access public
# @param  string $content valeur a inserer dans une cellule de la table
# @return string element TD
#
proc ::votable::addTD { content } {
   return [join [list [::votable::openElement $::votable::Element::TD ""] $content [::votable::closeElement $::votable::Element::TD]] ""]
}

#
# Construction partielle d'un element avec ses attributs
# @access private
# @param  string  $elementName nom de l'element a affecter (e.g. Element::<$VAR>)
# @param  list    $attributes  liste des attributs de l'element $elementNameE (e.g. [list $::votable::Element::ID "idElem"])
# @return string element partiel
#
proc ::votable::attributes { elementName attributes } {
   set element [join [list "<" $::votable::votablePrefix $elementName] ""]
   if {[info exists attributes]} {
      foreach a $attributes {
         set element [join [list $element " " [lindex $a 0] "=\"" [lindex $a 1] "\" "] ""]
      }
   }
   return [string trim $element]
}

#
# Construction d'un element ouvert avec ses attributs
# @access private
# @param  string  $elementName nom de l'element a affecter (e.g. Element::<$VAR>)
# @param  list    $attributes  liste des attributs de l'element $elementName (e.g. [list $::votable::Element::ID "idElem"])
# @return string element ouvert
#
proc ::votable::attributesUnclosedElement { elementName attributes } {
   return [join [list [::votable::attributes $elementName $attributes] ">"] ""]
}

#
# Construction d'un element ferme avec ses attributs
# @access private
# @param  string  $elementName nom de l'element a affecter (e.g. Element::<$VAR>)
# @param  list    $attributes  liste des attributs de l'element $elementName (e.g. [list $::votable::Element::ID "idElem"])
# @return string element ferme
#
proc ::votable::attributesClosedElement { elementName attributes } {
   return [join [list [::votable::attributes $elementName $attributes] "/>\n"] ""]
}

