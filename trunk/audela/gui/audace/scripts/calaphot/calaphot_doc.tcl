##
# @file calaphot_doc.tcl
#
# @author Olivier Thizy (thizy@free.fr) & Jacques Michelet (jacques.michelet@laposte.net)
#
# @brief Documentation generale de Calaphot
#
# $Id: calaphot_doc.tcl,v 1.2 2009-04-09 10:04:05 jacquesmichelet Exp $
#
#


##
# @defgroup calaphot_documentation_fr Manuel d'utilisation de Calaphot
# @ingroup calaphot_notice_fr
# @section calaphot_generalites Generalites
# Calaphot est un script qui utilise l'interface graphique AudACE et la librairie de fonctions fournies par l'ensemble Audela. Ce script a pour but de calculer la magnitude d'astres variables par comparaison avec la magnitude d'astres de référence dont la magnitude peut etre considérée comme constante pour la période de temps considérée.
#
# @subsection calaphot_generalite_conventions Conventions
# Pour la suite de cette documentation, et dans un but de simplification, on va appeler
# - @b astéroïde : un astre dont on veut calculer la magnitude. Dans les faits, il peut s'agir de tout astre suppose variable, que ce soit un veritable astéroïde ou une simple étoile.
# - @b étoile : un astre dont on va se servir comme référence pour calculer la magnitude de l'astéroïde. Il faut donc que cet astre ait une magnitude constante pour la periode de temps consideree.
# - @b astre : de facon generique, tout astéroïde ou étoile tels que precedemment specifie.
# - @b super-étoile : un astre fictif obtenu en additionnant les flux de plusieurs étoiles, et par consequent dont la magnitude est plus faible que toutes les magnitudes des étoiles qui le compose. Ainsi le rapport signal/bruit de cette super-étoile est meilleur (plus grand) que celui des étoiles de référence prises isolément.
# - @b séquence : l'ensemble des images dont on veut extraire la magnitude d'un astéroïde. Les images de la sequence doivent obeir à quelques contraintes (cf @ref calaphot_limitations_logiciel_images )
# .
# @section calaphot_limitations_logiciel Limitations du logiciel
# @subsection calaphot_limitations_logiciel_images Limitations sur les images
# -# Les images doivent correspondre a un champ stellaire <b> avec un fort recouvrement d'une image à l'autre </b>, de façon a pouvoir être recalées en x,y automatiquement. Si ce n'est pas le cas (comme pour un astéroïde géocroiseur avec un déplacement très rapide sur le fond de ciel, par exemple), il faudra "tronçonner" la séquence en plusieurs sous-séquences dont le recouvrement inter-images soit meilleur. Par contre le recalage photométrique des différentes séquences ne sera pas effectué par le script, et sera donc à faire "à la main".
# -# Les images à traiter ont toutes la même taille c'est-a-dire les mêmes dimensions sur les 2 axes.
# -# Les images ont été <b> préalablement pré-traitées </b> : elles ont été nettoyées des artefacts dus à l'électronique de la caméra, à la température du capteur et au dispositif optique à l'aide d'images de calibration comme les offsets, thermiques (darks) et plats (flats).
# -# Les images doivent être numérotées par un champ numéral à la fin de leur nom de ficher (ex : kandrup_27.fit). Les nombres dans les champs numéraux doivent former une suite sans trous. Il n'est pas nécessaire que le suite commence avec le nombre 1. Et il n'est pas nécessaire que l'ordre de la suite corresponde à l'ordre temporel des images (cf @ref référence a completer)
# .
#
# @section calaphot_plan_mode_emploi Plan du mode d'emploi
# De facon logique, le plan reflète le deroulement normal du script
# - @ref calaphot_saisie_parametres
# - @ref calaphot_reperage_astres
# - @ref calaphot_calculs
# - @ref calaphot_exploitation_resultats
# .
#
# @section calaphot_saisie_parametres Saisie des parametres
# Dans cette partie, l'opérateur va saisir ou modifier des paramètres de configuration de la session de Calaphot.
# Dans le cas d'une première utilisation ou dans le cas d'un changement de version de Calaphot, un certain nombre de paramètres recoivent une valeur par défaut.
# Dans les autres cas, les paramètres affichés ont la valeur qu'ils avaient reçus lors de la session précédente de Calaphot.
# L'écran de saisie se présente sous cette forme
# @image html calaphot_saisie_parametres.png Ecran de saisie des paramètres
#
#
# L'écran est divisé en 3 parties, les 2 premières etant générales pour le script, la dernière dépendant du mode de calcul choisi (ouverture, modélisation ou via sextractor)
# @subsection calaphot_saisie_parametres_generaux Parametres généraux
# - <b>Nom de l'objet</b> : l'utilisateur peut mettre là le nom de l'astéroïde dont il veut la courbe de photométrie.  Ce champ sera repris tel quel dans le champ CDR correspondant (cf )
# - <b>Nom de l'opérateur</b> : l'utilisateur peut indiquer le nom de l'auteur des travaux. Ce champ sera repris tel quel dans le champ CDR correspondant (cf )
# - <b>Code UAI de l'observatoire</b> : permet de repérer l'endroit des prises de vue. Ce champ sera repris tel quel dans le champ CDR correspondant (cf )
# - <b>Type du capteur</b> : il s'agit d'indiquer, s'il est connu, le type du capteur d'image. Ce champ sera repris tel quel dans le champ CDR correspondant (cf )
# - <b>Type du télescope</b> : l'utilisateur peut indiquer le type de l'optique principale utilisée (telescope, lunette ou objectif photo). Ce champ sera repris tel quel dans le champ CDR correspondant (cf )
# - <b>Diamètre du telescope</b> : il convient de preciser le diamètre en mètre de l'optique principale (lentille ou miroir). Ce champ sera repris tel quel dans le champ CDR correspondant (cf )
# - <b>Focale du telescope</b> : on mentionne là distance focale de l'optique utilisée, incluant toutes les optiques secondaires (aplanisseur de champ, réducteur de focale, lentille de Barlow, etc...). Ce champ sera repris tel quel dans le champ CDR correspondant (cf ).
# - <b>Filtre optique</b> : l'utilisateur peut indiquer le ou les filtres utilisés durant la prise de vue (R, V, B ou I). Ne rien mettre en l'absence de filtre. Ce champ sera repris tel quel dans le champ CDR correspondant (cf )
# - <b>Nom générique des images</b> : il s'agit du nom des fichiers d'image, sans le chemin d'accès, ni le suffixe numéral, ni l'extension. Exemple : si les fichiers s'appellent @c /tmp/kandrup_18.fit, @c /tmp/kandrup_19.fit, ..., @c /tmp/kandrup_63.fit, on mettra @c kandrup_ dans ce champ.
# - <b>Indice de la première image</b> : en reprenant l'exemple précédent, on met @c 18 dans ce champ.
# - <b>Indice de la dernière image</b> : en reprenant l'exemple précédent, on met @c 63 dans ce champ.
# - <b>Demi-largeur de la fenêtre</b> : la valeur en pixels donnée dans ce champ va définir une fenêtre à l'intérieur de laquelle on va charcher le centroïde des astres. Une largeur faible va accélérer les calculs, mais si les images sont mal recalées, certains astres risquent d'être mal identifiés. A l'inverse, une trop grande fenêtre pourrait faire que 2 astres se trouvent dans la même fenêtre, et fausser les calculs. Par expérience, une valeur égale à 2 ou 3 fois le FWHM moyen des images suffit généralement.
# - <b>Rapport S/B limite</b> : il s'agit de la valeur du rapport signal sur bruit éliminatoire : si au moins un astre (astéroïde ou étoile de référence) a une mesure de rapport S/B en dessous de cette limite dans une image donnée, l'image sera invalidée, c'est-à-dire que que toutes les mesures faites sur cette image seront éliminées. cf @reference_dans_la_doc_technique.
# - <b>Gain de la caméra</b> : il faut indiquer là la valeur du gain @i inverse en électron/ADU de la caméra. Cette valeur sert pour certains @ref doc_tech_incert_mag_ouv "calculs d'incertitude".
# - <b>Bruit de lecture</b> : il faut indiquer là la valeur du bruit de lecture en électron de la caméra. Cette valeur sert pour certains @ref doc_tech_incert_mag_ouv "calculs d'incertitude".
# - <b>Nom du fichier texte résultat</b> : nom du fichier (sans chemin d'accès) qui contiendra l'ensemble des résultats numériques des mesures.
# - <b>Nom du fichier Postscript résultat</b> : nom du fichier au format Postscript (sans chemin d'accès) qui contiendra le graphique de la courbe de lumière.
# - <b>Affichage des calculs</b> : les boutons définissent le niveau de verbiage des messages dans la console de l'interface Audela. Depuis "Erreur", mode le moins bavard à "Info", mode très bavard.
# - <b>Mode de calcul</b> : on indique là le mode de calcul de photométrie retenu pour la séquence. Le détail des calculs effectués pour chacun de ces modes est décrit dans la @ref calaphot_documentation_technique_fr. Le fait de sélectionner une des modes va changer l'aspect de la sous-fenêtre des @ref calaphot_saisie_parametres_specifiques .
# - <b>Type des images</b> : on indique là si les images ont été préalablement recalées ou pas, c'est à dire si les coordonnées en pixels des étoiles sont constantes ou pas dans toute la séquence.
#   - images recalées : le mentionner va accélérer les calculs. Sinon les images seront considérés comme non recalées, et un recalage inutile va être systématiquement fait.
#@note : Si les images sont en fait non recalées, alors qu'on a mentionné qu'elles l'étaient, le script va travailler sur les astres "aléatoires" et va vraisemblablement calculer l'âge du capitaine.
#   - images non recalées : les images vont être alors recalées pour connaître le déplacement de toutes les étoiles, déplacement relatif à la 1ère image de la séquence. Une fois le vecteur translation connu, on en déduit les coordonnées des étoiles dans les images non recalées. <b><i>Tous les calculs de photométrie sont faits sur les images non-recalées.</i></b>
#@note Les algorithmes de recalage procèdent parfois à des filtrages passe-bas destinés à gommer certains effets visuels du au changement d'échantillonage, ce qui peut nuire à la justesse des calculs de photométrie. Pour cette raison, <b><i>il est recommandé de travailler sur des séquences d'images non-recalées</i></b>.
#@note Pour accélérer les calculs, les résultats du recalage sont stockés, et sont donc ré-utilisés si l'utilisateur est amené à relancer le script sur la même séquence. Ainsi l'utilisateur n'est "pénalisé" qu'une seule fois.
# - <b>Date des images</b> : il faut indiquer à quoi correspond la date indiquée dans les entêtes FITS des images (début ou milieu de la pose). Le faible degré de normalisation des entêtes FITS est la cause de cette entrée.
# - <b>Tri des images par date croissante</b> : il faut répondre @c 'oui' dans le cas où l'ordre de numérotation des images de la séquence ne correspond à l'ordre croissant de leur date d'acquisition. En effet, il est nécessaire que le traitement se fasse suivant l'ordre des dates, de façon à pouvoir calculer la position mouvante par essence de l'astéroïde par interpolation linéaire sur les dates précises des images.
# - <b>Durée de la pose</b> : il faut indiquer l'unité du temps de pose des images. Le faible degré de normalisation des entêtes FITS est la cause de cette entrée.
# - <b>Format des données</b> : on definit là le type des informations générées dans le fichier texte résultat. cf @ref calaphot_exploitation_resultats.
# - <b>Reprise des objets déjà saisis</b> : en répondant @c 'oui', on saute l'étape de @ref calaphot_reperage_astres , sous réserve que les astres aient été saisis au moins une fois évidemment.
# @note Si la séquence d'image a changé, il faut impérativement répondre @c 'non' à ce champ, pour éviter que le script ne travaille sur des étoiles inexistantes et ne calcule l'âge du capitaine.
#
# .
# @subsection calaphot_saisie_parametres_specifiques Paramètres dépendant du mode de calcul.
# -# <b> @anchor calaphot_saisie_parametres_specifiques_ouverture Mode photométrie par ouverture </b>
#   - <b>Facteur de division des pixels</b> : pour augmenter la précision des calculs, les pixels sont divisés en sous-pixels (voir @ref doc_tech_mesure_flux_ouv_division_pixels "les explications techniques"). Il faut noter que le temps de calcul du flux d'une étoile va croître comme le carré de ce facteur.
#   - <b>Rayon de l'ovale intérieur (en fwhm)</b> : on définit une distance exprimée en fwhm qui va permettre de calculer le flux de l'astre dans une ellipse (voir @ref doc_tech_mesure_flux_ouv_disque_interne "la mesure du flux dans la fenêtre" ).
#   - <b>Rayon interne de la couronne (en fwhm)</b> : on définit une distance exprimée en fwhm d'une couronne qui va permettre de calculer le niveau moyen du fond de ciel (voir @ref doc_tech_mesure_flux_ouv_couronne_externe "la mesure du flux dans la couronne" ).
#   - <b>Rayon externe de la couronne (en fwhm)</b> : on définit une distance exprimée en fwhm d'une couronne qui va permettre de calculer le niveau moyen du fond de ciel (voir @ref doc_tech_mesure_flux_ouv_couronne_externe "la mesure du flux dans la couronne" ).
#   .
# -# <b> @anchor calaphot_saisie_parametres_specifiques_modelisation Mode photométrie par modélisation </b> : il n'y a pas de paramètre spécifique pour ce mode de calcul.
# -# <b> @anchor calaphot_saisie_parametres_specifiques_sextractor Mode photométrie par Sextractor </b>
#   - <b>Niveau de saturation (en ADU)</b> : Sextractor a besoin de savoir quel est la plus grande valeur possible d'un niveau de gris. Pour une séquence d'images 16 bits issues d'une caméra d'une linéarité parfaite, ce niveau correspond à \f$ \displaystyle 2^{16} - 1 = 65535 \f$.
# .
#
# @section calaphot_reperage_astres Repérage des astres
# @section calaphot_calculs Calculs de photométrie
# Les calculs lancés sur la séquence d'image sont l'objet de la @ref calaphot_documentation_technique_fr , et en particulier du paragraphe @ref  doc_tech_sequencement_operations
# @section calaphot_exploitation_resultats Exploitation des résultats


##
# @defgroup calaphot_documentation_technique_fr Documentation technique de Calaphot
# @ingroup calaphot_notice_fr
#
# @section doc_tech_algo_global Algorithme global
# Dans cette section ne sont décrites que les fonctions propres aux calculs de photométrie. Toutes les fonctions graphiques ou relatives à l'interface humain sont ignorées.
# @subsection doc_tech_principe_base Principe de base des calculs
# Calaphot est un script dédié à des calculs de <b> photométrie différentielle </b> effectués sur une série d'image. Chaque image est considérée individuellement. Et donc dans une image donnée, on mesure le flux d'un astéroïde et les flux d'étoiles dites de référence qui ont été sélectionnées au préalable. Les flux des étoiles de référence sont aggrégés en un flux unique représentant ainsi une super-étoile.
# La magnitude catalogue des étoiles de référence étant connue au préalable, celui de la super-étoile s'en déduit par une formule simple. De ces trois données (flux de l'astéroïde, flux de la super-étoile, magnitude de la super-étoile), on en déduit immédiatement la magnitude de l'astéroïde par appilcation directe de la formule de Pogson.
# @subsection doc_tech_etoiles_reference Etoiles de référence.
# Les étoiles de référence sont des étoiles qui à priori ont une photométrie considérée comme stable pour la durée totale couverte par les images à étudier. Mais il se peut que cette présomption s'avère fausse, soit qu'une ou plusieurs étoiles soient en fait variables, ou que durant la durée des poses, l'atmosphère absorbe différemment les radiations de ces étoiles en fonction de leur classe spectrale (effet du à la variation de la masse d'air). Pour mettre en évidence cette possible variabilité des étoiles de référence, on effectue un calcul similaire à celui effectué pour l'astéroïde, mais en utilisant une pseudo-super-étoile. Pour une étoile de référence donnée, sa pseudo-super-étoile sera formé à partir de toutes les étoiles de référence autres qu'elle-même.
# -# Cas où <b> une seule étoile </b> de référence est sélectionnée : dans ce cas, la comparaison avec une pseudo-super-étoile n'a pas de sens, et ce calcul n'est pas fait. La possible variabilité de cette étoile de référence ne peut pas être mise en évidence.
# -# Cas où @b deux étoiles de référence sont sélectionnées : chaque étoile de référence est comparée à son alter-égo. On obtient alors deux courbes de variabilité symétriques, sans qu'il soit possible de dire si l'une est meilleure que l'autre.
# .
# @subsection doc_tech_constante_magnitudes Constante des magnitudes.
# La constante des magnitudes est la magnitude d'un astre fictif dont le flux serait 1 ADU pour un temps de pose de 1s. Ce calcul est fait pour chaque image à partir du flux de l'étoile de référence et permet de caractériser la transparence du ciel. Sur une nuit très claire, le profil de la constante des magnitudes dessine une courbe en cloche, témoin de la variation de la masse d'air que doit traverser les photons issus des étoiles de référence. Par nuit brumeuse, on voir aussi nettement se dessiner les instants de passage des bancs de nuages élevés (baisse de cette valeur). Ce calcul est juste informatif, mais il permet de repérer rapidement dans une séquence les périodes où les mesures sont les meilleures.
# @subsection doc_tech_sequencement_operations Séquencement des opérations.
# - Saisie d'une certain nombre de paramètres nécessaires aux calculs :
#   - \f$ \displaystyle {\frac {S}{B}}_{lim} \f$ : rapport signal sur bruit limite.
#   - paramètres spécifiques à la photométrie d'ouverture.
#     - \f$ \displaystyle G \f$ : gain de la caméra (en électron/ADU).
#     - \f$ \displaystyle N_R \f$ : bruit de lecture de la caméra (en électrons).
#     - \f$ \displaystyle n_p \f$ : facteur de division des pixels.
#     - \f$ \displaystyle r_1\f$ : rayon exprimé en FWHM du disque entourant l'astre (nécessaire à la mesure du flux de l'astre).
#     - \f$ \displaystyle r_2\f$ : rayon interne exprimé en FWHM de la couronne entourant l'astre (nécessaire à la mesure du flux de fond de ciel).
#     - \f$ \displaystyle r_3\f$ : rayon externe exprimé en FWHM de la couronne entourant l'astre (nécessaire à la mesure du flux de fond de ciel).
#     .
#   .
# - Sélection de l'astéroïde à étudier.
# - Sélection des \f$ \displaystyle N_{ref} \f$ étoiles de référence, et entrée de leur magnitude @b catalogue \f$ \displaystyle M_{rc} \f$.
# - Calcul de la @ref doc_tech_calcul_mag_super_etoile "magnitude de la super-étoile" \f$ \displaystyle M_{se} \f$ à partir des \f$ \displaystyle N_{ref} \f$ valeurs \f$ \displaystyle M_{rc} \f$. Celle-ci est donc une @b constante pour toutes les images qui vont être traitées
# - Boucle pour toutes les images.
#   - Modélisation de tous les astres par une @ref doc_tech_modelisation_nappe_gaussienne "nappe gaussienne" de façon à déterminer précisément le centroïde ainsi que d'autres paramètres utilisés en photométrie d'ouverture.
#   - Mesure du flux de l' @ref doc_tech_calcul_mesure_flux "astéroïde" \f$ \displaystyle F_a \f$.
#   - Mesure du flux de chacune des étoiles de @ref doc_tech_calcul_mesure_flux "référence" \f$ \displaystyle F_r \f$.
#   - Calcul du @ref doc_tech_calcul_flux_super_etoile "flux de la super-étoile"\f$ \displaystyle M_{se} \f$.
#   - Calcul de l' @ref doc_tech_incert_totale_super_etoile "incertitude sur la magnitude de la super-étoile".
#   - Calcul de la @ref doc_tech_calcul_mag_astre "magnitude de l'astéroïde".
#   - Calcul de l' @ref doc_tech_incert_mag "incertitude sur la magnitude de l'astéroïde".
#   - Calcul des magnitudes des étoiles de référence.
#   - Calcul des incertitudes sur les étoiles de référence.
#   - Filtrage sur le rapport signal sur bruit.
#   - Calcul de la @ref doc_tech_calcul_cste_mag "constante des magnitudes".
# - Fin boucle pour toutes les images.
# .
# @section doc_tech_detail_calcul Détail des calculs.
#
# @subsection doc_tech_calcul_mesure_flux Mesure des flux des astres.
# -# @anchor doc_tech_mesure_flux_ouv <b>Photometrie d'ouverture</b> : Toutes les étoiles de référence ont préalablement été modélisés. On dispose pour chacune de ces étoiles des paramètres de l'ellipse qui l'englobe ( \f$ \displaystyle \sigma_x, \sigma_y, \rho, \alpha \f$ ).
#    - @anchor doc_tech_mesure_flux_ouv_ellipse <b>Ellipse moyenne</b> : on détermine tout d'abord une ellipse moyenne de paramètres (\f$ \displaystyle \sigma_{xm}, \sigma_{ym}, \rho_m \f$) par
#       - \f$ \displaystyle \sigma_{xm} = \frac { \sum_{k=1}^{N_{ref}} \sigma_{xk} } {N_{ref}} \f$
#       - \f$ \displaystyle \sigma_{ym} = \frac { \sum_{k=1}^{N_{ref}} \sigma_{yk} } {N_{ref}} \f$
#       - \f$ \displaystyle \rho_m = \frac { \sum_{k=1}^{N_{ref}} \rho_k } {N_{ref}} \f$ où
#           - \f$ \displaystyle N_{ref} \f$ est le nombre d'étoile de référence.
#           - \f$ \displaystyle \sigma_{xk} \f$ et \f$ \displaystyle \sigma_{yk} \f$ sont les écarts-types sur les axes principaux de l'ellipse de l'étoile de référence \f$ \displaystyle k \f$.
#           - \f$ \displaystyle \rho_k \f$ est le facteur d'allongement de l'étoile de référence \f$ \displaystyle k \f$.
#           .
#       .
#    - @anchor doc_tech_mesure_flux_ouv_disque_interne <b>Disque interne</b> : puis on détermine une fenêtre d'ouverture elliptique d'axes \f$ \displaystyle \lambda_{xm} \f$ et \f$ \displaystyle \lambda_{ym} \f$ et de facteur d'allongement \f$ \displaystyle \rho_m \f$ centrée sur l'étoile.@n
#       - \f$ \displaystyle \lambda_{xm} = 1.66511.r_1.\sigma_{xm} \f$
#       - \f$ \displaystyle \lambda_{ym} = 1.66511.r_1.\sigma_{ym} \f$ où
#           - \f$ \displaystyle r_1 \f$ est le rayon exprimé en FWHM du disque elliptique qui entoure l'astre à mesurer. Il a été spécifié par l'utilisateur.
#           .
#       .
# @anchor doc_tech_mesure_flux_ouv_division_pixels Pour augmenter la précision de calcul, les pixels sont artificiellement découpés en \f$ \displaystyle n_p^2 \f$ sous-pixels, \f$ \displaystyle n_p \f$ étant le facteur de division entré par l'utilisateur. Ainsi chaque sous-pixel se voit attribuer un niveau de gris égal à celui du pixel divisé par \f$ \displaystyle n_p^2 \f$.Finalement, on détermine sur l'image l'ensemble des sous-pixels qui sont englobés par l'ellipse et on somme les niveaux de gris de ces sous-pixels dans \f$ \displaystyle F_b \f$. On récupère aussi le nombre décimal de pixels \f$ \displaystyle n_{pix} \f$ inclus dans la fenêtre.
#    - @anchor doc_tech_mesure_flux_ouv_couronne_externe <b>Couronne externe</b> : on procède de même pour déterminer 2 cercles définissant une couronne dans laquelle sera mesuré le niveau de gris du fond de ciel. Les rayons de ces 2 cercles sont donnés par @n
#       - cercle interne : \f$ \displaystyle r_{2c} = 1.66511.r_2.\max ({\sigma_{xm}},{\sigma_{ym}}) \f$
#       - cercle externe : \f$ \displaystyle r_{3c} = 1.66511.r_3.\max ({\sigma_{xm}},{\sigma_{ym}}) \f$
#           - \f$ \displaystyle r_2 \f$ est le rayon interne exprimé en FWHM de la couronne qui entoure l'astre à mesurer. Il a été spécifié par l'utilisateur.
#           - \f$ \displaystyle r_3 \f$ est le rayon externe exprimé en FWHM de la couronne qui entoure l'astre à mesurer. Il a été spécifié par l'utilisateur.
#           .
#       .
# De même que pour le disque interne, chaque pixel est divisé en \f$ \displaystyle n_p^2 \f$ sous-pixels. A partir de tous les sous-pixels compris dans la couronne, on mesure alors le niveau de gris moyen \f$ \displaystyle N_B \f$ du fond de ciel par pixel, ainsi que le nombre de pixels (décimal) correspondant à la surface de la couronne \f$ \displaystyle n_B \f$.
#    - @anchor doc_tech_mesure_flux_ouv_flux <b>Le flux \f$ \displaystyle F \f$ de l'astre </b> considéré est déterminé par \f$ \displaystyle F = F_b - n_B.N_B \f$
#    .
# -# @anchor doc_tech_mesure_flux_mod <b>Photométrie par modélisation</b> : L'astre est tout d'abord modélisée par une @ref doc_tech_modelisation_nappe_gaussienne "nappe gaussienne". Le flux \f$ \displaystyle F \f$ est défini par le volume compris entre la nappe modélisant le profil de l'étoile et le plan du fond de ciel. @n
# \f$ \displaystyle F = \pi . S_o . \frac {\sigma_x.\sigma_y} {\sqrt{1-\rho^2}} \f$ où
#    - \f$ \displaystyle S_0 \f$ : niveau de gris maximum au niveau du centroïde
#    - \f$ \displaystyle \sigma_x \f$ et \f$ \displaystyle \sigma_y \f$ : écart-types suivant les axes principaux de l'ellipse
#    - \f$ \displaystyle \rho \f$ : facteur d'allongement de l'ellipse (\f$ \displaystyle \|\rho\| < 1 \f$)
#    .
# -# @anchor doc_tech_mesure_flux_mod <b>Photométrie par Sextractor</b> :
# .
# @subsection doc_tech_calcul_flux_super_etoile Calcul du flux de la super-étoile.
# Le flux de la super-étoile \f$ \displaystyle F_{se} \f$ est déterminé en sommant les flux \f$ \displaystyle F_r \f$ des \f$ \displaystyle N_{ref} \f$ étoiles de référence.@n
# \f$ \displaystyle F_{se} = \sum_{r=1}^{N_{ref}} F_r \f$
# @subsection doc_tech_calcul_flux_pseudo-super_etoile Calcul du flux de la pseudo-super-étoile.
# Le flux \f$ \displaystyle F_{pse}(r) \f$ de la pseudo-super-étoile \f$ \displaystyle r \f$ (qui sert à vérifier le comportement de l'étoile de référence \f$ \displaystyle r \f$) est déterminé en sommant les flux \f$ \displaystyle F_k \f$ des \f$ \displaystyle N_{ref}-1 \f$ étoiles de référence autres que l'étoile de référence \f$ \displaystyle r \f$).@n
# \f$ \displaystyle F_{pse}(r) = \sum_{k=1,k \neq r}^{N_{ref}} F_k \f$
# @subsection doc_tech_calcul_mag_aster Calcul des magnitudes.
# -# @anchor doc_tech_calcul_mag_astre <b>Magnitude de l'astéroïde</b> : le calcul de la magnitude utilise la formule de Pogson, la référence étant fournies par la magnitude et le flux de la super-étoile @n
#\f$ \displaystyle M_a = M_{se} - 2.5 * \log(\frac {F_a} {F_{se}}) \f$ où @n
#    - \f$ \displaystyle M_{se} \f$ est la magnitude de la super-étoile @n
#    - \f$ \displaystyle F_{se} \f$ est le flux mesuré de la super-étoile @n
#    - \f$ \displaystyle F_a \f$ est le flux mesuré de l'astéroïde @n
#    - \f$ \displaystyle M_a \f$ est la magnitude de l'astéroïde @n
# -# @anchor doc_tech_calcul_cste_mag <b>Constante des magnitudes</b> : la constante des magnitudes est la magnitude d'un astre fictif dont le flux intégré sur une unité de temps (ici la seconde) correspond à 1 ADU au dessus du fond de ciel. Son calcul se fait à partir des flux et magnitudes de la super-étoile.@n
#\f$ C_m = M_{se} + 2.5.\log(F_{se}) - 2.5.\log(T_{exp}) \f$ où : @n
#    - \f$ \displaystyle M_{se} \f$ est la magnitude de la super-étoile @n
#    - \f$ \displaystyle F_{se} \f$ est le flux mesuré de la super-étoile @n
#    - \f$ \displaystyle T_{exp} \f$ est le temps de pose (exprimé en seconde) de l'image considéré @n
#    - \f$ \displaystyle C_m \f$ est la constante des magnitudes.
#    .
# -# @anchor doc_tech_calcul_mag_super_etoile <b>Magnitude de la super-étoile</b> : @n
#\f$ \displaystyle M_{se} = -2.5.\log(\sum_{r=1}^{N_{ref}} 10^{-0.4.M_{rc}}) \f$ où @n
#    - \f$ \displaystyle M_{se} \f$ est la magnitude de la super-étoile @n
#    - \f$ \displaystyle M_{rc} \f$ est la magnitude @b catalogue de l'étoile de référence no r @n
#    - \f$ \displaystyle N_{ref} \f$ est le nombre d'étoile de référence
#    .
# @subsection doc_tech_incert_mag Calcul d'incertitude sur les magnitudes
# -# @anchor doc_tech_incert_mag_ouv <b>Photométrie d'ouverture</b> : la formule générale (dite équation générale des CCD) est celle donnée par Steve B. Howell dans son livre "Handbook of CCD astronomy" au chapitre 4.4. Elle donne le rapport signal à bruit \f$ \displaystyle \frac {S}{B} \f$ : @n
#\f$ \displaystyle \frac {S}{B} = \frac {N_*}{\sqrt{N_* + n_{pix}.(1+\frac{n_{pix}}{n_B}).(N_S+N_D+N_R^2+G^2.\sigma_f^2)}} \f$ où @n
#    - \f$ \displaystyle N_* \f$ est le nombre total de photons correspondant à l'étoile. @n
#    - \f$ \displaystyle n_{pix} \f$ est le nombre de pixels de l'étoile. @n
#    - \f$ \displaystyle n_B \f$ est le nombre total de pixels utilisés pour calculer le fond de ciel moyen. @n
#    - \f$ \displaystyle N_S \f$ est le nombre de photons par pixel correspondant au fond de ciel. @n
#    - \f$ \displaystyle N_D \f$ est le nombre d'électrons par pixel du courant d'obscurité. @n
#    - \f$ \displaystyle N_R \f$ est le nombre total d'électrons par pixel générés par le bruit de lecture du CCD. @n
#    - \f$ \displaystyle G \f$ est le gain de la caméra CCD (exprimé en electron / ADU.) @n
#    - \f$ \displaystyle \sigma_f \f$ est un facteur constant valant approximativement 0.289.
#    .
# @note Les mots photon et électrons sont des synonymes dans les expressions ci-dessus, on devrait normalement parler de photo-electron, notion qui intégrerait le rendement quantique du CCD.@n
#
# La formule ci-dessus est exprimée en photons (ou électrons). Les mesures sur les images s'effectuant en ADU, cette formule devient alors (en reprenant les notations ci-dessus )@n
# \f$ \displaystyle \frac {S}{B} = \frac {G.S_*}{\sqrt{G.S_* + n_{pix}.(1+\frac{n_{pix}}{n_B}).(G*N_B + N_R^2)}} \f$ où :
#    - \f$ \displaystyle S_* \f$ est le nombre d'ADU correspondant à l'étoile
#    - \f$ \displaystyle N_B \f$ est le nombre d'ADU par pixel du fond de ciel
#    .
# Finalement, l'incertitude \f$ \displaystyle E \f$ sur la mesure de la magnitude est donnée par
#\f$ \displaystyle E = \frac {1.0857} {\frac {S}{B}} \f$ .
# -# <b>Photometrie par modelisation</b> .
# -# <b>Photometrie par Sextractor</b> .
# .
# @subsection doc_tech_incert_totale Calcul des incertitudes totales.
# -# @anchor doc_tech_incert_totale_super_etoile Pour la @b super-étoile, l'incertitude \f$ \displaystyle E_{se} \f$ est calculée à partir des incertitudes \f$ \displaystyle E_r \f$ et des magnitudes @b mesurées \f$ \displaystyle M_r \f$ de chacune des \f$ \displaystyle N_{ref} \f$ étoiles de référence : @n
#\f$ \displaystyle E_{se} = \frac {\sum_{r=1}^{N_{ref}} E_r.10^{-0.4.M_r}} {\sum_{r=1}^N 10^{-0.4.M_r}} \f$
# -# Pour l' @b astéroïde, l'incertitude totale \f$ \displaystyle E_{at} \f$ est la somme de son incertitude propre \f$ \displaystyle E_a \f$ et de celle de la super-étoile \f$ \displaystyle E_{se} \f$ @n
#\f$ \displaystyle E_{at} = E_a + E_{se} \f$
# -# Cas particulier des <b>étoiles de référence</b> : pour une étoile de référence \f$ \displaystyle r \f$, on calcule l'incertitude de la pseudo-super_étoile \f$ \displaystyle E_{pse} \f$, puis l'incertitude globale de l'étoile de référence \f$ \displaystyle E_{rt} \f$ à l'aide des formules (\f$ \displaystyle E_r \f$ désignant l'incertitude propre de l'étoile de référence) @n
#\f$ \displaystyle E_{pse} = \frac {\sum_{k=1, k \neq r}^{N_{ref}} E_k.10^{-0.4.M_k}} {\sum_{k=1, k \neq r}^{N_{ref}} 10^{-0.4.M_k}} \f$. @n
#\f$ \displaystyle E_{rt} = E_r + E_{pse} \f$. @n
# où les \f$ \displaystyle M_k \f$ designent les magnitude @b mesurées des étoiles de référence autres que l'étoile \f$ \displaystyle r \f$.
# .
# @subsection doc_tech_modelisation_nappe_gaussienne Modélisation d'une étoile par une nappe gaussienne.
# La modélisation permet de trouver une fonction analytique qui soit la plus proche au sens des moindres carrés de la fonction de niveaux de gris d'un astre. Dans le cas de la nappe gaussienne, la fonction de modélisation \f$ \displaystyle f(x,y) \f$ est donnée par @n
#\f$ \displaystyle f(x,y) = S_0 . e^{-h(x,y)} + B_0 \f$ où \f$ \displaystyle h(x,y) \f$ vaut @n
#\f$ \displaystyle h(x,y) = \frac {(x-x_c)^2}{\sigma_x^2} + \frac{(y-y_c)^2}{\sigma_y^2} - 2.\rho.\frac{x-x_c}{\sigma_x}.\frac{y-y_c}{\sigma_y} \f$
#Il faut noter que l'équation \f$ \displaystyle h(x,y) = constante \f$ est l'équation au centre d'une ellipse, dont les axes sont proportionnels aux valeurs \f$ \displaystyle \sigma_x \f$ et \f$ \displaystyle \sigma_y \f$. Pour les notations :
# - \f$ \displaystyle S_0 \f$ est le niveau de gris maximum au niveau du centroïde.
# - \f$ \displaystyle (x_c,y_c) \f$ sont coordonnées du centroïde.
# - \f$ \displaystyle \sigma_x \f$ et \f$ \displaystyle \sigma_y \f$ sont écart-types suivant les axes principaux de l'ellipse.
# - \f$ \displaystyle \rho \f$ est le facteur d'allongement de l'ellipse (\f$ \displaystyle \|\rho\| < 1 .\f$)
# - \f$ \displaystyle B_0 \f$ est le niveau de gris du fond de ciel.
# .
# La modélisation consiste donc à trouver les sept valeurs précédentes. De ces valeurs, on en tire aisément :
# - \f$ \displaystyle \lambda_x \f$ le FWHM suivant un des axes de l'ellipse, \f$ \displaystyle \lambda_x = 1,66511.\sigma_x \f$
# - \f$ \displaystyle \lambda_y \f$ le FWHM suivant l'axe perpendiculaire au précédent, \f$ \displaystyle \lambda_y = 1,66511.\sigma_y \f$
# - \f$ \displaystyle \alpha \f$ l'angle entre les axes principaux de l'ellipse et les axes de l'image.@n
#   - si \f$ \displaystyle \sigma_x \neq \sigma_y \f$, on a \f$ \displaystyle \alpha = \frac{1}{2}.\arctan \frac {2.\rho.\sigma_x.\sigma_y}{\sigma_x^2 - \sigma_y^2} \f$ .@n
#   - dans le cas contraire, l'ellipse est un cercle, et \f$ \displaystyle \alpha \f$ est indéterminé.
#   .
# .
# @subsection doc_tech_filtrage_sb Filtrage des images à partir des rapports signal sur bruit.
# Ce filtrage vise à éliminer les images douteuses. Sont qualifiées de douteuses les images dont <b>au moins</b> un astre a un rapport signal à bruit inférieur à la limite \f$ \displaystyle {\frac {S}{B}}_{lim} \f$ définie par l'utilisateur.
#
# @section age_du_capitaine Calcul de l'âge du capitaine.
# Le problème soulevé par ce calcul n'est pas récent, puisque Gustave Flaubert avait soumis cette question à sa soeur dans une lettre.:
# <i>Tu diriges un navire, qui part de Boston chargé de coton, il jauge 200 tonneaux, il fait voile vers Le Havre, le grand mât est cassé, il y a un mousse sur le gaillard d'avant, les passagers sont au nombre de douze, le vent souffle NNE, l'horloge marque trois heures un quart d'après-midi, on est au mois de mai ... Quel est l'âge du capitaine ? </i>




