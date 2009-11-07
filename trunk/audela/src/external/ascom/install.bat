@echo -----------------------------------------------------------
@echo --- Note pour le developpement de l'interface de camera QSI
@echo Les fichiers AscomMasterInterfaces.h et AscomMasterInterfaces.lib
@echo ne sont plus fournis ASCOM. Ils sont generes automatiquement par
@echo VisualC++ v9 @echo a partir du fichier AscomMasterInterfaces.tlb
@echo en fonction du systeme d'exploitation.
@echo
@echo --- Note pour l'utilisation de l'interface de camera QSI
@echo Avant de lancer Audela , l'utilisateur doit installer le driver de
@echo ASCOM disponible sur http://ascom-standards.org
@echo -----------------------------------------------------------

set ASCOM=ascom
@echo --- Je cree le repertoire external\lib
mkdir ..\lib
@echo --- Je copie le fichier QSICamera.dll
copy %ASCOM%\lib\AscomMasterInterfaces.tlb ..\lib
