
***********************************************
****              STX-Engine               ****
***********************************************
Librairie de fonctions C écrite en assembleur pour la réalisation de jeux 2D sur Atari STF (avec blitter) et STE. Cette librairie a été developpée avec VBCC dont l'installeur est fourni.


===============================================
|            Licence d'utilisation            |
===============================================
- La librairie ne peut pas être vendue.
- L'utilisation de cette librairie dans des jeux commerciaux est autorisée.
- Le code source de la STX_Engine V1.xx est fourni, vous pouvez la modifier pour vos developpements et la redistribuer avec les mêmes conditions que ci-dessus.
- Droit d'auteur : La STX_Engine reste la propriété intelectuelle de son auteur.



===============================================
|              Installation VBCC              |
===============================================
1)-Executer VBCC Installer
2)-Dans le menu déroulant 'Default compiler target' selectionner Atari TOS 16-bit
3)-Selectionner votre répertoire d'installation
4)-Accepter les termes de la licence
5)-Cliquer sur Install


===============================================
|     Fonctionnalités de la version 1.02      |
===============================================
- Correction de la mauvaise restitution des registres D7 et A6 dans la fonction STX_getjoystickstatus.


===============================================
|     Fonctionnalités de la version 1.01      |
===============================================
- Correction des valeurs de STX_picturetype dans le fichier Type.h et dans la documentation.


===============================================
|     Fonctionnalités de la version 1.00      |
===============================================
- Affichage de l'écran en mode double buffering.
- Affichage de sprite au format 16x16 sur 4 plans.
- Effacement automatique des sprites aprés swap des écrans.
- Gestion des animations des sprites.
- Affichage de tiles 8 ou 16 pixels de large et jusqu'à 16 lignes de hauteur sur 4 plans.
- Gestion des joysticks 1 et 2.
- Gestion des touches du clavier.
- Gestion de la souris (experimentale).
- Dispatcher d'evenements.
- Effets audio avec Yamaha 2149.
- Gestion de l'audio DMA du STE.
- Affichage de Charset redefinissables.
- Gestion des images basse résolution aux formats Néochrome, Degas et Degas Elite non compressées.

