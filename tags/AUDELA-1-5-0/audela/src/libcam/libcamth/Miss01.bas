REM******************************************
REM*UNE BELLE ROUTINE D'ACQUISITION D'IMAGES*
REM******************************************
'$DYNAMIC
DECLARE SUB chargementa ()
DECLARE SUB chargementc ()
DECLARE SUB acq ()
DECLARE SUB autosave ()
DECLARE SUB stat ()
DECLARE SUB numoffset ()
DECLARE SUB map ()
DECLARE SUB chargement ()
DECLARE SUB saveC ()
DECLARE SUB saveA ()
DECLARE SUB Sauvegarde ()
DECLARE SUB razmemoire ()
DECLARE SUB vidage ()
DECLARE SUB tempo ()
DECLARE SUB warmup ()
DIM SHARED a%(145, 218)
DIM SHARED integration!
DIM SHARED ish%, isb%
DIM SHARED binny%, binnx%
DIM SHARED nom$, cmd$, ChSansBlanc$
DIM SHARED pal&(256)
DIM SHARED lut%(4095)

LOCATE 13, 15
PRINT "!!!! Alimentation +/-18V toujours sur ON avant Warmup!!!"
DO
LOOP WHILE INKEY$ = ""

GOSUB interpreteur

debut:


LOCATE 1, 5
INPUT "Entrer le temps de pose en secondes:"; integration!
LOCATE 2, 5
INPUT "Entrer la valeur de binning en X:"; binnx%
LOCATE 3, 5
INPUT "Entrer la valeur de binning en Y:"; binny%

FOR i% = 1 TO 25
    CALL vidage: REM Appel de la s‚quence de nettoyage du CCD
NEXT


IF integration! <> 0 THEN
CALL tempo: REM D‚lai correspondant au temps d'int‚gration
END IF

FOR i% = 1 TO 25
        CALL razmemoire: REM **** Appel de la sequence de nettoyage de la m‚moire ****
NEXT



FOR i% = 1 TO 145
    OUT 769, 3: REM **** Transfert zone image … zone m‚moire****
        FOR boucle% = 1 TO 30: REM **** Boucle d'attente****
        x% = 0
        NEXT
    OUT 769, 0
        FOR boucle% = 1 TO 30: REM **** Boucle d'attente****
        x% = 0
        NEXT
NEXT

        
      OUT 769, 8: REM Nettoyage du registre horizontal
      FOR n% = 1 TO 5
      NEXT
      OUT 769, 0

ii% = 0
FOR i% = 1 TO 145 STEP binnx%
    ii% = ii% + 1
FOR k% = 1 TO binnx%
    OUT 769, 2: REM Somme binnx% ligne dans le registre horizontal
        FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
        x% = 0
        NEXT
    OUT 769, 0
        FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
        x% = 0
        NEXT
NEXT

jj% = 0
FOR j% = 1 TO 218 STEP binny%
    s% = 0
    jj% = jj% + 1
    FOR k% = 1 TO binny%
     OUT 769, 16
       FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
       x% = 0
       NEXT
     OUT 769, 0
       FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
       x% = 0
       NEXT
     OUT 769, 16
       FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
       x% = 0
       NEXT
      
       ref% = 256 * INP(770) + INP(768): REM Numerisation du palier de r‚f‚rence
    
      OUT 769, 20
        FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
        x% = 0
        NEXT
      OUT 769, 4
        FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
        x% = 0
        NEXT
      OUT 769, 20
        FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
        x% = 0
        NEXT
        REM Palier de signal moins palier vid‚o
        s% = s% + 256 * INP(770) + INP(768) - ref%
      NEXT
        a%(ii%, jj%) = s%
    NEXT
     
    
      OUT 769, 8: REM Nettoyage du registre horizontal
      FOR n% = 1 TO 5
      NEXT
      OUT 769, 0
    

NEXT

REM****************************
REM* Visualisation de l'image *
REM****************************
seuillage:


'LOCATE 6, 5
'INPUT "Entrer le seuil Haut de l'image:"; ish%
'LOCATE 7, 5
'INPUT "Entrer le seuil Bas de l'image:"; isb%
'LOCATE 10, 7
'INPUT "Entrer la position du coin inf. gauche de l'image: (Axe X)"; xpos%
'LOCATE 11, 7
'INPUT "Entrer la position ... (Axe Y):"; ypos%

seuillage2:

xpos% = 0
ypos% = 0

SCREEN 13

max% = 0
min% = 4095

s! = 0
FOR ii% = 2 TO 143
   FOR jj% = 15 TO 200
      vv% = a%(ii%, jj%)
      s! = s! + vv%
      IF vv% > max% THEN
         max% = vv%
      END IF
      IF vv% < min% THEN
         min% = vv%
      END IF
   NEXT
NEXT


moy% = CINT(s! / 26412)
ish% = max%
isb% = min%


FOR i% = 0 TO 63
        pal&(i%) = i% + i% * 256 + i% * 65536
NEXT

FOR i% = 64 TO 255
        pal&(i%) = 0
NEXT
PALETTE USING pal&(0)



maxdyn% = 4095 'Variable contenant la valeur de la dynamique maxi d'image


xdyn! = 63 / (ish% - isb%)
FOR z% = 0 TO maxdyn%
        couleur% = (z% - isb%) * xdyn!
        IF couleur% < 0 THEN
                lut%(z%) = 0
        ELSEIF couleur% > 63 THEN
                lut%(z%) = 63
        ELSE
                lut%(z%) = couleur%
        END IF
NEXT

ecrany% = 200 'Variable contenant la r‚solution vert. de l'‚cran en mode 13

m% = maxdyn% + 1
j1% = ecrany% - ypos% - 1
FOR i% = 2 TO 145
        x1% = xpos% + i%
        FOR j% = 9 TO 216
                IF a%(i%, j%) < m% THEN k% = a%(i%, j%) ELSE k% = maxdyn%
                IF a%(i%, j%) < 0 THEN k% = 0
                PSET (x1%, j1% - j%), lut%(k%)
        NEXT
NEXT


'LOCATE 15, 20
'PRINT heure$;
LOCATE 16, 20
PRINT "Moyenne="; moy%;
LOCATE 17, 20
PRINT "Tps de pose:"; integration!; "sec"
LOCATE 18, 20
PRINT "Seuil haut="; max%;
LOCATE 19, 20
PRINT "Seuil bas="; min%;


DO
LOOP WHILE INKEY$ = ""


CLS
interpreteur:

SCREEN 11
'LINE (144, 219)-(291, 439), , B
LINE (144, 150)-(291, 215), , B
LOCATE 2, 50
PRINT "CAN One minute warmup!: 100"
LOCATE 4, 50
PRINT "Nouvelle Acquisition: 1"
LOCATE 6, 50
PRINT "Nouveaux seuils: 2"
LOCATE 8, 50
PRINT "Acquisition auto.: 3"
LOCATE 10, 50
PRINT "Autosave: 4"
LOCATE 12, 50
PRINT "Test (Offset palier ref.): 5"
LOCATE 14, 50
PRINT "Coupe photom‚trique: 6"
LOCATE 16, 50
PRINT "Statistique: 7"
LOCATE 18, 50
PRINT "Sauvegarde: 8"
LOCATE 20, 50
PRINT "Chargement: 9"
LOCATE 22, 50
PRINT "Quitter: 10"
LOCATE 24, 50
INPUT "Choix:...?", choix%

           
SELECT CASE choix%
        CASE 100
        CALL warmup
        CASE 1
        GOSUB debut
        CASE 2
        GOSUB seuillage
        CASE 3
        CALL acq
        CASE 4
        CALL autosave
        CASE 5
        CALL numoffset
        GOSUB seuillage
        CASE 6
        CALL map
        CASE 7
        CALL stat
        CASE 8
        CALL Sauvegarde
        CLS
        CASE 9
        CALL chargement
        GOSUB seuillage2
        CASE 10
        END
END SELECT
GOSUB interpreteur
END









REM $STATIC
SUB acq


LOCATE 1, 5
INPUT "Entrer le temps de pose en secondes:"; integration!
LOCATE 2, 5
INPUT "Entrer la valeur de binning en X:"; binnx%
LOCATE 3, 5
INPUT "Entrer la valeur de binning en Y:"; binny%

DO
FOR i% = 1 TO 25
    CALL vidage: REM Appel de la s‚quence de nettoyage du CCD
NEXT


IF integration! <> 0 THEN
CALL tempo: REM D‚lai correspondant au temps d'int‚gration
END IF

FOR i% = 1 TO 25
        CALL razmemoire: REM **** Appel de la sequence de nettoyage de la m‚moire ****
NEXT



FOR i% = 1 TO 145
    OUT 769, 3: REM **** Transfert zone image … zone m‚moire****
        FOR boucle% = 1 TO 30: REM **** Boucle d'attente****
        x% = 0
        NEXT
    OUT 769, 0
        FOR boucle% = 1 TO 30: REM **** Boucle d'attente****
        x% = 0
        NEXT
NEXT

       
      OUT 769, 8: REM Nettoyage du registre horizontal
      FOR n% = 1 TO 5
      NEXT
      OUT 769, 0

ii% = 0
FOR i% = 1 TO 145 STEP binnx%
    ii% = ii% + 1
FOR k% = 1 TO binnx%
    OUT 769, 2: REM Somme binnx% ligne dans le registre horizontal
        FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
        x% = 0
        NEXT
    OUT 769, 0
        FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
        x% = 0
        NEXT
NEXT

jj% = 0
FOR j% = 1 TO 218 STEP binny%
    s% = 0
    jj% = jj% + 1
    FOR k% = 1 TO binny%
     OUT 769, 16
       FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
       x% = 0
       NEXT
     OUT 769, 0
       FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
       x% = 0
       NEXT
     OUT 769, 16
       FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
       x% = 0
       NEXT
     
       ref% = 256 * INP(770) + INP(768): REM Numerisation du palier de r‚f‚rence
   
      OUT 769, 20
        FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
        x% = 0
        NEXT
      OUT 769, 4
        FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
        x% = 0
        NEXT
      OUT 769, 20
        FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
        x% = 0
        NEXT
        REM Palier de signal moins palier vid‚o
        s% = s% + 256 * INP(770) + INP(768) - ref%
      NEXT
        a%(ii%, jj%) = s%
    NEXT
    
   
      OUT 769, 8: REM Nettoyage du registre horizontal
      FOR n% = 1 TO 5
      NEXT
      OUT 769, 0
   

NEXT


REM****************************
REM* Visualisation de l'image *
REM****************************

xpos% = 0
ypos% = 0

SCREEN 13

max% = 0
min% = 4095

s! = 0
FOR ii% = 2 TO 143
   FOR jj% = 15 TO 200
      vv% = a%(ii%, jj%)
      s! = s! + vv%
      IF vv% > max% THEN
         max% = vv%
      END IF
      IF vv% < min% THEN
         min% = vv%
      END IF
   NEXT
NEXT

moy% = CINT(s! / 26412)
ish% = max%
isb% = min%

FOR i% = 0 TO 63
        pal&(i%) = i% + i% * 256 + i% * 65536
NEXT

FOR i% = 64 TO 255
        pal&(i%) = 0
NEXT
PALETTE USING pal&(0)



maxdyn% = 4095 'Variable contenant la valeur de la dynamique maxi d'image


xdyn! = 63 / (ish% - isb%)
FOR z% = 0 TO maxdyn%
        couleur% = (z% - isb%) * xdyn!
        IF couleur% < 0 THEN
                lut%(z%) = 0
        ELSEIF couleur% > 63 THEN
                lut%(z%) = 63
        ELSE
                lut%(z%) = couleur%
        END IF
NEXT

ecrany% = 200 'Variable contenant la r‚solution vert. de l'‚cran en mode 13

m% = maxdyn% + 1
j1% = ecrany% - ypos% - 1
FOR i% = 2 TO 145
        x1% = xpos% + i%
        FOR j% = 9 TO 216
                IF a%(i%, j%) < m% THEN k% = a%(i%, j%) ELSE k% = maxdyn%
                IF a%(i%, j%) < 0 THEN k% = 0
                PSET (x1%, j1% - j%), lut%(k%)
        NEXT
NEXT

LOCATE 16, 20
PRINT "Moyenne="; moy%;
LOCATE 17, 20
PRINT "Tps de pose:"; integration!; "sec"
LOCATE 18, 20
PRINT "Seuil haut="; max%;
LOCATE 19, 20
PRINT "Seuil bas="; min%;

LOOP WHILE INKEY$ = ""


END SUB

SUB autosave

        LOCATE 26, 50
        LINE INPUT "nom de l'image:"; nom$
        LOCATE 27, 50
        INPUT "Premier indice:"; indic%
        LOCATE 28, 50
        LINE INPUT "Sauvegarder sur quelle unit‚:"; cmd2$
    
REM ***** Numerisation de l'image *****

LOCATE 1, 5
INPUT "Entrer le temps de pose en secondes:"; integration!
LOCATE 2, 5
INPUT "Entrer la valeur de binning en X:"; binnx%
LOCATE 3, 5
INPUT "Entrer la valeur de binning en Y:"; binny%

DO

FOR i% = 1 TO 25
    CALL vidage: REM Appel de la s‚quence de nettoyage du CCD
NEXT


IF integration! <> 0 THEN
CALL tempo: REM D‚lai correspondant au temps d'int‚gration
END IF

FOR i% = 1 TO 25
        CALL razmemoire: REM **** Appel de la sequence de nettoyage de la m‚moire ****
NEXT



FOR i% = 1 TO 145
    OUT 769, 3: REM **** Transfert zone image … zone m‚moire****
        FOR boucle% = 1 TO 30: REM **** Boucle d'attente****
        x% = 0
        NEXT
    OUT 769, 0
        FOR boucle% = 1 TO 30: REM **** Boucle d'attente****
        x% = 0
        NEXT
NEXT

       
      OUT 769, 8: REM Nettoyage du registre horizontal
      FOR n% = 1 TO 5
      NEXT
      OUT 769, 0

ii% = 0
FOR i% = 1 TO 145 STEP binnx%
    ii% = ii% + 1
FOR k% = 1 TO binnx%
    OUT 769, 2: REM Somme binnx% ligne dans le registre horizontal
        FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
        x% = 0
        NEXT
    OUT 769, 0
        FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
        x% = 0
        NEXT
NEXT

jj% = 0
FOR j% = 1 TO 218 STEP binny%
    s% = 0
    jj% = jj% + 1
    FOR k% = 1 TO binny%
     OUT 769, 16
       FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
       x% = 0
       NEXT
     OUT 769, 0
       FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
       x% = 0
       NEXT
     OUT 769, 16
       FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
       x% = 0
       NEXT
     
       ref% = 256 * INP(770) + INP(768): REM Numerisation du palier de r‚f‚rence
   
      OUT 769, 20
        FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
        x% = 0
        NEXT
      OUT 769, 4
        FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
        x% = 0
        NEXT
      OUT 769, 20
        FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
        x% = 0
        NEXT
        REM Palier de signal moins palier vid‚o
        s% = s% + 256 * INP(770) + INP(768) - ref%
      NEXT
        a%(ii%, jj%) = s%
    NEXT
    
   
      OUT 769, 8: REM Nettoyage du registre horizontal
      FOR n% = 1 TO 5
      NEXT
      OUT 769, 0
   

NEXT

REM****************************
REM* Visualisation de l'image *
REM****************************

max% = 0
min% = 4095
s! = 0
FOR ii% = 2 TO 143
   FOR jj% = 15 TO 200
      vv% = a%(ii%, jj%)
      s! = s! + vv%
      IF vv% > max% THEN
         max% = vv%
      END IF
      IF vv% < min% THEN
         min% = vv%
      END IF
   NEXT
NEXT

ish% = max%
isb% = min%


xpos% = 0
ypos% = 0

SCREEN 13

FOR i% = 0 TO 63
        pal&(i%) = i% + i% * 256 + i% * 65536
NEXT

FOR i% = 64 TO 255
        pal&(i%) = 0
NEXT
PALETTE USING pal&(0)


maxdyn% = 4095 'Variable contenant la valeur de la dynamique maxi d'image


xdyn! = 63 / (ish% - isb%)
FOR z% = 0 TO maxdyn%
        couleur% = (z% - isb%) * xdyn!
        IF couleur% < 0 THEN
                lut%(z%) = 0
        ELSEIF couleur% > 63 THEN
                lut%(z%) = 63
        ELSE
                lut%(z%) = couleur%
        END IF
NEXT

ecrany% = 200 'Variable contenant la r‚solution vert. de l'‚cran en mode 13

m% = maxdyn% + 1
j1% = ecrany% - ypos% - 1
FOR i% = 1 TO 145
        x1% = xpos% + i%
        FOR j% = 1 TO 218
                IF a%(i%, j%) < m% THEN k% = a%(i%, j%) ELSE k% = maxdyn%
                IF a%(i%, j%) < 0 THEN k% = 0
                PSET (x1%, j1% - j%), lut%(k%)
        NEXT
NEXT

  
REM ***** Transformation du type de la variable incr‚ment *****

x$ = STR$(indic%)
ChSansBlanc$ = LTRIM$(RTRIM$(x$))


IF cmd2$ = "C" THEN
ELSEIF cmd2$ = "c" THEN
CALL saveC
        ELSEIF cmd2$ = "A" THEN
        ELSEIF cmd2$ = "a" THEN
        CALL saveA
END IF

REM **** Increment ****
indic% = indic% + 1

LOOP WHILE INKEY$ = ""

REM **** Remise … 0 de l'indicateur ****
indic% = 0
x$ = STR$(indic%)
ChSansBlanc$ = LTRIM$(RTRIM$(x$))

END SUB

SUB chargement

REM ******* Choix du disque source du load ******     

LOCATE 27, 50
LINE INPUT "nom de l'image:"; nom$
LOCATE 28, 50
LINE INPUT "Quelle unit‚ ?"; cmd$
        IF cmd$ = "C" THEN
        ELSEIF cmd$ = "c" THEN
        CALL chargementc
                ELSEIF cmd$ = "A" THEN
                ELSEIF cmd$ = "a" THEN
                CALL chargementa
END IF

END SUB

SUB chargementa

REM ***** Chargement de l'image ******

DEF SEG = VARSEG(a%(1, 1))
BLOAD "a:\" + nom$ + ".pic", VARPTR(a%(1, 1))
ish% = a%(0, 3)
isb% = a%(0, 4)
IF ish% = 0 AND isb% = 0 THEN ish% = 4095

END SUB

SUB chargementc
       
REM ***** Chargement de l'image ******
     DEF SEG = VARSEG(a%(1, 1))
     BLOAD "c:\nuitccd\" + nom$ + ChSansBlanc$ + ".pic", VARPTR(a%(1, 1))
     ish% = a%(0, 3)
     isb% = a%(0, 4)
     IF ish% = 0 AND isbs% = 0 THEN ish% = 4095

END SUB

SUB map
CLS
SCREEN 11

REM ******Detection du point d'intensit‚ maximale*****
max% = 0
jmax% = 0
imax% = 0
 FOR i% = 2 TO 145
        FOR j% = 9 TO 216
                IF a%(i%, j%) > max% THEN
                        max% = a%(i%, j%)
                        imax% = i%
                        jmax% = j%
                END IF
        NEXT
NEXT

REM ****Affichage des valeurs numeriques****

LOCATE 11, 22
PRINT "max=", max%
LOCATE 12, 22
PRINT "jmax=", jmax%; ""
LOCATE 13, 22
PRINT "imax=", imax%

REM *** affichage du profil ***                        

xpos% = 0
ypos% = 200
REM ecrany% = 480
ecrany% = 640
x1% = xpos% + 145
REM x1% = xpos%
j1% = ecrany% - ypos% - 1
     FOR i% = 2 TO 145
        k% = a%(i%, jmax%) * (218 / max%)
        IF a%(i%, jmax%) < 0 THEN k% = 0
        PSET (x1% + i%, j1% - k%)
     NEXT

END SUB

SUB numoffset

FOR i% = 1 TO 25
    CALL vidage: REM Appel de la s‚quence de nettoyage du CCD
NEXT

integration! = 0

IF integration! <> 0 THEN
CALL tempo: REM D‚lai correspondant au temps d'int‚gration
END IF

FOR i% = 1 TO 25
        CALL razmemoire: REM **** Appel de la sequence de nettoyage de la m‚moire ****
NEXT

FOR i% = 1 TO 145
    OUT 769, 3: REM **** Transfert zone image … zone m‚moire****
        FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
        x% = 0
        NEXT
    OUT 769, 0
        FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
        x% = 0
        NEXT
NEXT

binnx% = 1
binny% = 1
       
        
       OUT 769, 8: REM Nettoyage du registre horizontal
       FOR n% = 1 TO 20
       NEXT
       OUT 769, 0
        
 
ii% = 0
FOR i% = 1 TO 145 STEP binnx%
   
    ii% = ii% + 1
FOR k% = 1 TO binnx%
    OUT 769, 2: REM Somme binnx% ligne dans le registre horizontal
        FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
        x% = 0
        NEXT
    OUT 769, 0
        FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
        x% = 0
        NEXT
NEXT

jj% = 0
FOR j% = 1 TO 218 STEP binny%
    s% = 0
    jj% = jj% + 1
    FOR k% = 1 TO binny%
     REM OUT 769, 16
       REM FOR boucle% = 1 TO 10: REM **** Boucle d'attente****
       REM x% = 0
       REM NEXT
     OUT 769, 0
       FOR boucle% = 1 TO 20: REM **** Boucle d'attente****
       x% = 0
       NEXT
      OUT 769, 16
       FOR boucle% = 1 TO 20: REM **** Boucle d'attente****
       x% = 0
       NEXT
      ref% = 256 * INP(770) + INP(768): REM Numerisation du palier de r‚f‚rence
    NEXT
    a%(ii%, jj%) = ref%
        OUT 769, 20
        OUT 769, 4
       ' OUT 769, 20

NEXT

    
    OUT 769, 8: REM Nettoyage du registre horizontal
    FOR n% = 1 TO 20
    NEXT
    OUT 769, 0
    
NEXT

END SUB

SUB razmemoire
      REM***Transfert zone m‚moire au registre horizontal***
      FOR i% = 1 TO 145
        OUT 769, 2: REM 00000010
                FOR boucle% = 1 TO 3: REM **** Boucle d'attente****
                x% = 0: x% = 0: x% = 0: x% = 0
                NEXT
        OUT 769, 0: REM 00000000
                FOR boucle% = 1 TO 3: REM **** Boucle d'attente****
                x% = 0: x% = 0: x% = 0: x% = 0
                NEXT
        REM***Lecture du registre horizontal (Signal G … 1)***
        OUT 769, 8: REM 00001000
        FOR j% = 1 TO 80:  REM *** D‚lai de maintien du signal G au niveau 1 ***
        NEXT
        OUT 769, 0: REM 00000000
      NEXT
END SUB

SUB Sauvegarde

        LOCATE 27, 50
        LINE INPUT "nom de l'image:"; nom$
        LOCATE 28, 50
        LINE INPUT "Sauvegarder sur quelle unit‚:"; cmd$
        IF cmd$ = "C" THEN
        ELSEIF cmd$ = "c" THEN
        CALL saveC
                ELSEIF cmd$ = "A" THEN
                ELSEIF cmd$ = "a" THEN
                CALL saveA
        END IF


END SUB

SUB saveA

REM --- Sauvegarde du header ---

OPEN "a:\" + nom$ + ChSansBlanc$ + ".HDR" FOR OUTPUT AS #1
     PRINT #1, nom$
     PRINT #1, DATE$
     PRINT #1, TIME$
     PRINT #1, STR$(145)
     PRINT #1, STR$(221)
     PRINT #1, binnx%
     PRINT #1, binny%
     PRINT #1, ish%
     PRINT #1, isb%
     PRINT #1, integration!
     PRINT #1, comment$
     PRINT #1, ""
     PRINT #1, ""
     PRINT #1, ""
     CLOSE #1
 
REM --- Sauvegarde de l'image ---
   
     a%(0, 2) = 1
     a%(0, 3) = ish%
     a%(0, 4) = isb%
     a%(0, 5) = ish% - isb%: REM pas
     a%(0, 6) = VAL(MID$(datte$, 7, 4)): REM ann‚e
     a%(0, 7) = VAL(MID$(datte$, 1, 2)): REM mois
     a%(0, 8) = VAL(MID$(datte$, 4, 2)): REM ...
     a%(0, 9) = VAL(MID$(heure$, 1, 2))
     a%(0, 10) = VAL(MID$(heure$, 4, 2))
     a%(0, 11) = VAL(MID$(heure$, 7, 2)): REM secondes
     a%(0, 12) = integration!
     DEF SEG = VARSEG(a%(1, 1))
     BSAVE "a:\" + nom$ + ChSansBlanc$ + ".PIC", VARPTR(a%(1, 1)), 64824
     DEF SEG

END SUB

SUB saveC

REM --- Sauvegarde du header ---

OPEN "c:\mips\nuitccd\" + nom$ + ChSansBlanc$ + ".HDR" FOR OUTPUT AS #1
     PRINT #1, nom$
     PRINT #1, DATE$
     PRINT #1, TIME$
     PRINT #1, STR$(145)
     PRINT #1, STR$(221)
     PRINT #1, binnx%
     PRINT #1, binny%
     PRINT #1, ish%
     PRINT #1, isb%
     PRINT #1, integration!
     PRINT #1, comment$
     PRINT #1, ""
     PRINT #1, ""
     CLOSE #1
  
REM --- Sauvegarde de l'image ---
    
     a%(0, 2) = 1
     a%(0, 3) = ish%
     a%(0, 4) = isb%
     a%(0, 5) = ish% - isb%: REM pas
     a%(0, 6) = VAL(MID$(DATE$, 7, 4)): REM ann‚e
     a%(0, 7) = VAL(MID$(DATE$, 1, 2)): REM mois
     a%(0, 8) = VAL(MID$(DATE$, 4, 2)): REM ...
     a%(0, 9) = VAL(MID$(TIME$, 1, 2))
     a%(0, 10) = VAL(MID$(TIME$, 4, 2))
     a%(0, 11) = VAL(MID$(TIME$, 7, 2)): REM secondes
     a%(0, 12) = integration!
     DEF SEG = VARSEG(a%(1, 1))
     BSAVE "d:\mips2\nuitccd\" + nom$ + ChSansBlanc$ + ".PIC", VARPTR(a%(1, 1)), 64824
     DEF SEG


END SUB

SUB stat STATIC
CLS

max% = 0
min% = 4095
s! = 0
FOR ii% = 2 TO 145
   FOR jj% = 9 TO 216
      vv% = a%(ii%, jj%)
      s! = s! + vv%
      IF vv% > max% THEN
         max% = vv%
      END IF
      IF vv% < min% THEN
         min% = vv%
      END IF
   NEXT
NEXT
moy% = CINT(s! / 26412)

LOCATE 11, 22
PRINT "Max ="; max%
LOCATE 12, 22
PRINT "Min ="; min%
LOCATE 13, 22
PRINT "Moy ="; moy%

END SUB


SUB tempo
        SLEEP (integration!)
END SUB

SUB vidage
      REM***Transfert zone image … zone m‚moire***
      FOR i% = 1 TO 145
        OUT 769, 3: REM 00000011
                FOR boucle% = 1 TO 3: REM **** Boucle d'attente****
                x% = 0: x% = 0: x% = 0: x% = 0
                NEXT
        OUT 769, 0: REM 00000000
                FOR boucle% = 1 TO 3: REM **** Boucle d'attente****
                x% = 0: x% = 0: x% = 0: x% = 0
                NEXT
      NEXT
      REM***Transfert zone m‚moire au registre horizontal***
      FOR i% = 1 TO 145
        OUT 769, 2: REM 00000010
                FOR boucle% = 1 TO 3: REM **** Boucle d'attente****
                x% = 0: x% = 0: x% = 0: x% = 0
                NEXT
        OUT 769, 0: REM 00000000
                FOR boucle% = 1 TO 3: REM **** Boucle d'attente****
                x% = 0: x% = 0: x% = 0: x% = 0
                NEXT
        REM***Lecture du registre horizontal (Signal G … 1)***
        OUT 769, 8: REM 00001000
        FOR j% = 1 TO 80: REM *** D‚lai de maintien du signal G au niveau 1 ***
        NEXT
        OUT 769, 0: REM 00000000
      NEXT
END SUB

SUB warmup
REM*****************************
REM*PROGRAMME DE TEST DU C.A.N.*
REM*****************************

OUT 771, 153: REM Initialisation du PIO

DO
      OUT 769, 0
      x% = 0
      x% = 0
      x% = 0
      x% = 0
      x% = 0
      x% = 0
      x% = 0
      OUT 769, 16: REM Start convert
      x% = 0
      x% = 0
      x% = 0
      x% = 0
      x% = 0
      x% = 0
      x% = 0
      PRINT 256 * INP(770) + INP(768), : REM Lecture du CAN

LOOP WHILE INKEY$ = ""
CLS
END SUB

